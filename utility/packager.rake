@attributes = {
  "dc.title" => "title",
  "dc.description.abstract" => "description",
  "dc.contributor.author" => "creator",
  "dc.date.issued" => "date_created",
  "dc.publisher" => "publisher",
  "dc.language" => "language",
  "dc.subject" => "subject",
  "dc.description" => "description",
  "dc.title.alternative" => "alt_title",
  "dc.type" => "resource_type",
  "dc.contributor.advisor" => "contributor",
  "dc.creator" => "creator",
  "dc.identifier.uri" => "source",
  "dc.advisor" => "contributor",
  "dc.date.created" => "date_created",
  "dc.contributor" => "contributor",
}

@singulars = {
  "dc.date.submitted" => "date_uploaded",
  "dc.date.updated" => "date_modified",
}

# embargo fields
# :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
# :visibility_during_embargo: authenticated
# :visibility: embargo

# This is a variable to use during XML parse testing to avoid submitting new items
@debugging = FALSE

namespace :packager do

  task :aip, [:file, :user_id] =>  [:environment] do |t, args|
    puts "loading task import"


    @unmappedFields = File.open("/tmp/unmappedFields.txt", "w")

    @source_file = args[:file] or raise "No source input file provided."
    #@current_user = User.find_by_user_key(args[:user_id])

    @defaultDepositor = User.find_by_user_key(args[:user_id]) # THIS MAY BE UNNECESSARY

    # @uncapturedFields = Hash.new(0) # Hash.new {|h,k| h[k]=[]}

    puts "Building Import Package from AIP Export file: " + @source_file

    abort("Exiting packager: input file [" + @source_file + "] not found.") unless File.exists?(@source_file)

    @input_dir = File.dirname(@source_file)
    @output_dir = File.join(@input_dir, "unpacked") ## File.basename(@source_file,".zip"))
    Dir.mkdir @output_dir unless Dir.exist?(@output_dir)

    unzip_package(File.basename(@source_file))

    # puts @uncapturedFields
    @unmappedFields.close

  end
end

def unzip_package(zip_file,parentColl = nil)

  zpath = File.join(@input_dir, zip_file)

  if File.exist?(zpath)
    file_dir = File.join(@output_dir, File.basename(zpath, ".zip"))
    @bitstream_dir = file_dir
    Dir.mkdir file_dir unless Dir.exist?(file_dir)
    Zip::File.open(zpath) do |zipfile|
      zipfile.each do |f|
        fpath = File.join(file_dir, f.name)
        zipfile.extract(f,fpath) unless File.exist?(fpath)
      end
    end
    if File.exist?(File.join(file_dir, "mets.xml"))
      File.rename(zpath,@input_dir + "/complete/" + zip_file)
      return process_mets(File.join(file_dir,"mets.xml"),parentColl)
    else
      puts "No METS data found in package."
    end
  end

end

def process_mets (mets_file,parentColl = nil)

  children = Array.new
  files = Array.new
  uploadedFiles = Array.new
  depositor = ""
  type = ""
  params = Hash.new {|h,k| h[k]=[]}

  if File.exist?(mets_file)
    # xml_data = Nokogiri::XML.Reader(open(mets_file))
    dom = Nokogiri::XML(File.open(mets_file))

    current_type = dom.root.attr("TYPE")
    current_type.slice!("DSpace ")
    # puts "TYPE = " + current_type

    # puts dom.class
    # puts dom.xpath("//mets").attr("TYPE")

    data = dom.xpath("//dim:dim[@dspaceType='"+current_type+"']/dim:field", 'dim' => 'http://www.dspace.org/xmlns/dspace/dim')

    data.each do |element|
     field = element.attr('mdschema') + "." + element.attr('element')
     field = field + "." + element.attr('qualifier') unless element.attr('qualifier').nil?
     # puts field + " ==> " + element.inner_html

     # Due to duplication and ambiguity of output fields from DSpace
     # we need to do some very simplistic field validation and remapping
     case field
     when "dc.creator"
       if element.inner_html.match(/@/)
         # puts "Looking for User: " + element.inner_html
         depositor = getUser(element.inner_html) unless @debugging
         # depositor = @defaultDepositor
         # puts depositor
       end
     else
       params[@attributes[field]] << element.inner_html if @attributes.has_key? field
       params[@singulars[field]] = element.inner_html if @singulars.has_key? field
     end
     # @uncapturedFields[field] += 1 unless (@attributes.has_key? field || @singulars.has_key? field)
     @unmappedFields.write(field) unless @attributes.has_key? field
    end

    case dom.root.attr("TYPE")
    when "DSpace COMMUNITY"
      type = "admin_set"
      puts params
      puts "*** COMMUNITY  ***"
      # puts params
    when "DSpace COLLECTION"
      type = "admin_set"
      puts "***** COLLECTION  *****"
      # puts params
    when "DSpace ITEM"
      puts "******* ITEM ["+params["source"][0]+"] *******"
      type = "work"
    end

    # if type == 'collection'
    if type == 'admin_set'
      structData = dom.xpath('//mets:mptr', 'mets' => 'http://www.loc.gov/METS/')
      structData.each do |fileData|
        case fileData.attr('LOCTYPE')
        when "URL"
          unzip_package(fileData.attr('xlink:href'))
          # puts coverage unless coverage.nil?
        end
      end
    elsif type == 'work'
      # item = createItem(params,parentColl)

      fileMd5List = dom.xpath("//premis:object", 'premis' => 'http://www.loc.gov/standards/premis')
      fileMd5List.each do |fptr|
        fileChecksum = fptr.at_xpath("premis:objectCharacteristics/premis:fixity/premis:messageDigest", 'premis' => 'http://www.loc.gov/standards/premis').inner_html
        originalFileName = fptr.at_xpath("premis:originalName", 'premis' => 'http://www.loc.gov/standards/premis').inner_html
        # newFileName = dom.at_xpath("//mets:fileGrp[@USE='THUMBNAIL']/mets:file[@CHECKSUM='"+fileChecksum+"']/mets:FLocat/@xlink:href", 'mets' => 'http://www.loc.gov/METS/', 'xlink' => 'http://www.w3.org/1999/xlink').inner_html
        # puts newFileName

        ########################################################################################################################
        # This block seems incredibly messy and should be cleaned up or moved into some kind of method
        newFile = dom.at_xpath("//mets:file[@CHECKSUM='"+fileChecksum+"']/mets:FLocat", 'mets' => 'http://www.loc.gov/METS/')
        thumbnailId = nil
        case newFile.parent.parent.attr('USE') # grabbing parent.parent seems off, but it works.
        when "THUMBNAIL"
          newFileName = newFile.attr('xlink:href')
          puts newFileName + " -> " + originalFileName
          File.rename(@bitstream_dir + "/" + newFileName, @bitstream_dir + "/" + originalFileName)
          file = File.open(@bitstream_dir + "/" + originalFileName)

          hyraxFile = Hyrax::UploadedFile.create(file: file)
          hyraxFile.save
          # thumbnailId = hyraxFile.id

          uploadedFiles.push(hyraxFile)
          file.close
          ## params["thumbnail_id"] << hyraxFile.id
        when "TEXT"
        when "ORIGINAL"
          newFileName = newFile.attr('xlink:href')
          puts newFileName + " -> " + originalFileName
          File.rename(@bitstream_dir + "/" + newFileName, @bitstream_dir + "/" + originalFileName)
          file = File.open(@bitstream_dir + "/" + originalFileName)
          hyraxFile = Hyrax::UploadedFile.create(file: file)
          hyraxFile.save
          uploadedFiles.push(hyraxFile)
          file.close
        when "LICENSE"
          # Temp commented to deal with PDFs
          # newFileName = newFile.attr('xlink:href')
          # puts "license text: " + @bitstream_dir + "/" + newFileName
          # file = File.open(@bitstream_dir + "/" + newFileName, "rb")
          # params["rights_statement"] << file.read
          # file.close
        end
        # puts newFile.class
        # puts newFile.attr('xlink:href')
        # puts newFile.parent.parent.attr('USE')
        # File.rename(@bitstream_dir + "/" + newFileName, @bitstream_dir + "/" + originalFileName)
        # file = File.open(@bitstream_dir + "/" + originalFileName)
        # uploadedFiles.push(Hyrax::UploadedFile.create(file: file))
        ########################################################################################################################

        # sleep(10) # Sleeping 10 seconds while the file upload completes for large files...

      end

      puts "-------- UpLoaded Files ----------"
      puts uploadedFiles
      puts "----------------------------------"

      puts "** Creating Item..."
      item = createItem(params,depositor) unless @debugging
      puts "** Attaching Files..."
      workFiles = AttachFilesToWorkJob.perform_now(item,uploadedFiles) unless @debugging
      # workFiles.save
      # puts workFiles
      # item.thumbnail_id = thumbnailId unless thumbnailId.nil?
      puts "Item id = " + item.id
      # item.save

      return item

    end
  end
end

def createCollection (params, parent = nil)
  coll = AdminSet.new(params)
#  coll = Collection.new(id: ActiveFedora::Noid::Service.new.mint)
#  params["visibility"] = "open"
#  coll.update(params)
#  coll.apply_depositor_metadata(@current_user.user_key)
  coll.save
#  return coll
end


def createItem (params, depositor, parent = nil)
  if depositor == ''
    depositor = @defaultDepositor
  end
  
  item = GenericWork.new(id: ActiveFedora::Noid::Service.new.mint)
  if params.key?("embargo_release_date")
    # params["visibility"] = "embargo"
    params["visibility_after_embargo"] = "open"
    params["visibility_during_embargo"] = "authenticated"
  else
    params["visibility"] = "open"
  end
  item.update(params)
  item.apply_depositor_metadata(depositor.user_key)
  item.save
  return item
end

def getUser(email)
  user = User.find_by_user_key(email)
  if user.nil?
    pw = (0...8).map { (65 + rand(52)).chr }.join
    puts "Created user " + email + " with password " + pw
    user = User.new(email: email, password: pw)
    user.save
  end
  # puts "returning user: " + user.email
  return user
end
