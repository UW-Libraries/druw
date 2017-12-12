# Import data from a DSpace export in zip format
#
# Run: `bundle exec rake 'import:dspace[ZIPFILE, EXISTING_DRUW_USER_ID]`

require 'nokogiri'
require 'zip'
require 'date'

ATTRIBUTES = {
  'dc.title' => 'title',
  'dc.creator' => 'creator',
  'dc.contributor.author' => 'creator'
}.freeze

namespace :import do
  task :dspace, %i[zipfile user_id] => [:environment] do |_, args|
    stage_dir = File.join('/tmp', 'dspace-unpacked')
    stage_unzipped(args[:zipfile], stage_dir)
    mets_xml_str = File.read(File.join(stage_dir, 'mets.xml'))
    admin_set = AdminSet::DEFAULT_ID
    abort("Default Admin Set doesn't exist") unless admin_set
    mets_data = parse_mets(mets_xml_str, admin_set)
    rename_files(stage_dir, mets_data[:files])
    depositor_key = get_user_key(args[:user_id])
    item = create_item(mets_data[:params], depositor_key)
    attach_files(item, mets_data[:files].values, stage_dir)
    cleanup(stage_dir)
  end
end

# ---- File staging and cleanup ----

def stage_unzipped(zipfile, stage_dir)
  # Unzip file to a specified directory
  Dir.mkdir stage_dir unless Dir.exist?(stage_dir)
  Zip::File.open(zipfile) do |z|
    z.each do |f|
      extract_path = File.join(stage_dir, f.name)
      z.extract(f, extract_path) unless File.exist?(extract_path)
    end
  end
end

def rename_files(stage_dir, name_map)
  # Rename files in directory by old_name->new_name hash
  name_map.each do |old_name, new_name|
    old_path = File.join(stage_dir, old_name)
    new_path = File.join(stage_dir, new_name)
    File.rename(old_path, new_path)
  end
end

def cleanup(stage_dir)
  FileUtils.rm_rf(stage_dir)
end

# ---- METS.XML parsing ----

def parse_mets(mets_xml_str, admin_set)
  # Retrieve data from mets file for creating DRUW item
  dom = Nokogiri::XML(mets_xml_str)
  field_elems = get_field_elems(dom)
  params = get_params(field_elems)
  params['admin_set_id'] = admin_set
  file_mappings = get_file_mappings(dom)
  { params: params, files: file_mappings }
end

def get_field_elems(dom)
  # Get all fields elements in a DOM
  current_type = dom.root.attr('TYPE')
  current_type.slice!('DSpace ')
  abort('Cannot handle collections yet.') unless current_type == 'ITEM'
  xpath = "//dim:dim[@dspaceType='" + current_type + "']/dim:field"
  dom.xpath(xpath, 'dim' => 'http://www.dspace.org/xmlns/dspace/dim')
end

def get_params(field_elems)
  # Get select DRUW item parameters from DOM elements
  params = Hash.new { |h, k| h[k] = [] }
  field_elems.each do |element|
    field = construct_attribute_name(element)
    params[ATTRIBUTES[field]] << element.inner_html if ATTRIBUTES.key? field
  end
  params.update(default_params)
  params
end

def construct_attribute_name(element)
  # Make name for hash lookup
  field = element.attr('mdschema') + '.' + element.attr('element')
  unless element.attr('qualifier').nil?
    field = field + '.' + element.attr('qualifier')
  end
  field
end

def default_params
  {
    'rights_statement' => ['No Known Copyright'],
    'visibility' => 'open',
    'keyword' => %w[foo bar],
    'date_uploaded' => Date.today
  }
end

def get_file_mappings(dom)
  # Get DSpace bitstream->filename hash
  namespace = { 'premis' => 'http://www.loc.gov/standards/premis' }
  file_mappings = []
  file_md5_list = dom.xpath('//premis:object', namespace)
  file_md5_list.each do |fptr|
    type, bitstream, original_filename = get_filename_mapping(fptr, dom)
    if %w[ORIGINAL TEXT].include?(type)
      file_mappings << [bitstream, original_filename]
    end
  end
  Hash[file_mappings.map { |key, value| [key, value] }]
end

def get_filename_mapping(fptr, dom)
  # Get single bitstream->orig_filename mapping
  checksum = get_checksum(fptr)
  orig_filename = get_orig_filename(fptr)
  type, bitstream_filename = get_bitstream_filename(checksum, dom)
  [type, bitstream_filename, orig_filename]
end

def get_checksum(fptr)
  # Get the checksum of a file
  namespace = { 'premis' => 'http://www.loc.gov/standards/premis' }
  xpath = 'premis:objectCharacteristics/premis:fixity/premis:messageDigest'
  fptr.at_xpath(xpath, namespace).inner_html
end

def get_orig_filename(fptr)
  # Get the of a bitstream artifact
  namespace = { 'premis' => 'http://www.loc.gov/standards/premis' }
  fptr.at_xpath('premis:originalName', namespace).inner_html
end

def get_bitstream_filename(checksum, dom)
  # Get the type of original file and its bitstream name
  xpath = "//mets:file[@CHECKSUM='" + checksum + "']/mets:FLocat"
  new_file = dom.at_xpath(xpath, 'mets' => 'http://www.loc.gov/METS/')
  [new_file.parent.parent.attr('USE'), new_file.attr('xlink:href')]
end

# ---- DRUW item creation ----

def get_user_key(name)
  user = User.find_by_user_key(name)
  abort("Depositor #{name} cannot be found") if user.nil?
  user.user_key
end

def create_item(params, depositor_key)
  # create a DRUW item
  item = GenericWork.new(id: ActiveFedora::Noid::Service.new.mint)
  item.update(params)
  item.apply_depositor_metadata(depositor_key)
  item.save
  item
end

def attach_files(item, files, stage_dir)
  # Attach files to a DRUW item
  uploaded_files = []
  files.each do |f|
    file = File.open(File.join(stage_dir, f))
    hyrax_file = Hyrax::UploadedFile.create(file: file)
    hyrax_file.save
    uploaded_files << hyrax_file
    file.close
  end
  AttachFilesToWorkJob.perform_now(item, uploaded_files)
end
