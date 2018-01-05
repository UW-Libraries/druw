# Create a BagIt directory from a DSpace export zip
#
# Run: `ds2bi.rb DSPACE_ZIPFILE [OUTPUT_DIR]`
#  e.g. ds2bi.rb weatherstation.zip /tmp

require 'nokogiri'
require 'zip'
require 'bagit'
require 'json'

ATTRIBUTES = {
  'dc.title' => 'title',
  'dc.creator' => 'creator',
  'dc.contributor.author' => 'creator'
}.freeze

SINGULARS = {
  'dc.date.accessioned' => 'date_uploaded'
}

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
  name_map.each_pair do |old_name, new_name|
    old_path = File.join(stage_dir, old_name)
    new_path = File.join(stage_dir, new_name)
    File.rename(old_path, new_path)
  end
end

def cleanup(stage_dir)
  FileUtils.rm_rf(stage_dir)
end

# ---- METS.XML parsing ----

def parse_mets(mets_xml_str)
  # Retrieve data from mets file for creating DRUW item
  dom = Nokogiri::XML(mets_xml_str)
  field_elems = get_field_elems(dom)
  params = get_params(field_elems)
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
    params[SINGULARS[field]] = element.inner_html if SINGULARS.key? field
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

# ---- BagIt ----

def make_bagit_data(mets_data)
  # Add attachable files to passed in METS data
  files = []
  mets_data[:files].each_value do |new_name|
    files << new_name
  end
  mets_data[:files] = files
  mets_data
end

def make_bag(bagit_dir, stage_dir, bagit_data)
  # Create a BagIt directory with all data inserted within
  Dir.mkdir(bagit_dir) unless Dir.exist?(bagit_dir)
  bag = BagIt::Bag.new bagit_dir
  add_metadata_file(bag, bagit_data[:params])
  add_files(bag, stage_dir, bagit_data[:files])
  bag.manifest!
end

def add_metadata_file(bag, params)
  # Add a DRUW metadata file to a BagIt directory
  bag.add_file('druw-metadata.json') do |io|
    io.puts JSON.generate(params)
  end
end

def add_files(bag, stage_dir, files)
  # Add files to BagIt directory
  files.each do |file|
    bag.add_file(file, File.join(stage_dir, file))
  end
end

# ---- main ----

zipfile = ARGV[0]
out_dir = ARGV.length > 1 ? ARGV[1] : '.'

stage_dir = File.join('/tmp', 'unpacked')
stage_unzipped(zipfile, stage_dir)
mets_xml_str = File.read(File.join(stage_dir, 'mets.xml'))
mets_data = parse_mets(mets_xml_str)
rename_files(stage_dir, mets_data[:files])
bagit_data = make_bagit_data(mets_data)
bagit_dir = File.join(out_dir, File.basename(zipfile, '.zip'))
make_bag(bagit_dir, stage_dir, bagit_data)

cleanup(stage_dir)
