# Import data from a Bagit folder
#
# Run: `bundle exec rake 'import:bagit[BAGIT_DIR, EXISTING_DRUW_USER_ID]`
#  e.g. bundle exec rake 'import:bagit[/tmp/weatherstation/, netid@uw.edu]'

namespace :import do
  task :bagit, %i[bagit_dir user_id] => [:environment] do |_, args|
    druw_params, attachables = extract_item_creation_data(args[:bagit_dir])
    depositor_key = get_user_key(args[:user_id])
    item = create_item(druw_params, depositor_key)
    attach_files(item, attachables)
  end
end

def extract_item_creation_data(bagit_dir)
  # Extract DRUW item creation data from BagIt directory
  bag = BagIt::Bag.new(bagit_dir)
  druw_params = nil
  attachables = []
  bag.bag_files.each do |f|
    if File.basename(f, '.json') != 'druw-metadata'
      attachables << f
    else
      file = File.read(f)
      druw_params = JSON.parse(file)
      if druw_params['date_uploaded']
        date_str = druw_params['date_uploaded']
        druw_params['date_uploaded'] = DateTime.parse(date_str)
      end
    end
  end
  [druw_params, attachables]
end

def get_user_key(name)
  # Get DRUW user key
  user = User.find_by_user_key(name)
  abort("Depositor #{name} cannot be found") if user.nil?
  user.user_key
end

def create_item(params, depositor_key)
  # Create a DRUW item
  new_id = ActiveFedora::Noid::Service.new.mint
  puts "Create new DRUW item: #{new_id}"
  item = GenericWork.new(id: new_id)
  item.update(params)
  item.apply_depositor_metadata(depositor_key)
  item.save
  item
end

def attach_files(item, files)
  # Attach files to a DRUW item
  uploaded_files = []
  files.each do |f|
    puts "Attach file: #{f}"
    file = File.open(f)
    hyrax_file = Hyrax::UploadedFile.create(file: file)
    hyrax_file.save
    uploaded_files << hyrax_file
    file.close
  end
  AttachFilesToWorkJob.perform_now(item, uploaded_files)
end
