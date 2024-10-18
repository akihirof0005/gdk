require 'open-uri'
require 'net/http'
require 'fileutils'
require 'yaml'
require 'digest'
require 'fileutils'


module Init

  # Runs the initialization process to resolve Java dependencies.
  #
  # Prompts the user for input on whether to resolve dependencies and set recommended versions.
  # Downloads the necessary libraries based on the settings in the YAML file.
  def self.run
    puts <<-EOT
Would you like to resolve Java dependencies? (No/yes)
    EOT

    case gets.chomp.downcase
    when "yes", "y"
      flag = true
    when "no", "n"
      exit 1
    else
      puts "Invalid input. Exiting..."
      exit 1
    end

    puts <<-EOT
Set recommended Java library version? (No/yes)
    EOT

    case gets.chomp.downcase
    when "yes", "y"
      flag = true
    end

    downloads = load_settings(ENV['HOME'] + "/.glycobook/jar.yml", flag)

    # Execute the downloads
    downloads["libraries"].each do |download|
      url = URI(download["url"])
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')

      request = Net::HTTP::Get.new(url.request_uri)
      response = http.request(request)

      if response.code.to_i == 302
        new_location = response['Location']
        url = URI.parse(new_location)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == 'https')
        request = Net::HTTP::Get.new(url.request_uri)
        response = http.request(request)
      end

      if response.code.to_i == 200
        begin
          File.open(File.dirname(__FILE__) + "/" + download["file"], 'wb') do |file|
            file.write(response.body)
            puts "Installed " + download["file"]
          end
        rescue StandardError => e
          puts "Failed to save file: #{download["file"]}. Error: #{e.message}"
        end
      else
        puts "Failed to download file: #{download["file"]}"
      end
    end
  end
  
  def self.switch_WFW_version(version)
    base = File.dirname(__FILE__) + "/jar/"
    
    source_file = File.join(base, "wurcsframework-#{version}.jar")
    destination_file = File.join(base, "wurcsframework.jar")
  
    if File.exist?(source_file)
      begin
        FileUtils.cp(source_file, destination_file)
        puts "Switched to version #{version} successfully!"
      rescue StandardError => e
        puts "Failed to switch versions: #{e.message}"
      end
    else
      puts "Source file #{source_file} does not exist."
    end
  end

  def self.check_WFW_version()
    target_file_path = File.dirname(__FILE__) + '/jar/wurcsframework.jar'  
    folder_path = File.dirname(__FILE__) + '/jar' 
  
    matching_files = find_matching_files(target_file_path, folder_path)
  
    unless matching_files.empty?
      matching_files.each do |file|
        version = extract_version_from_filename(file)
        if version
          puts "version number: #{version}"
        else
          puts ""
        end
      end
    end
  end

  private
  # Loads the settings from a YAML file and prepares the environment.
  #
  # @param file_path [String] The path to the settings file.
  # @param flag [Boolean] Whether to use the recommended Java library version.
  # @return [Array<Hash>] The list of downloads specified in the settings file.
  def self.load_settings(file_path, flag)
    downloads = []

    unless Dir.exist?(ENV['HOME'] + "/.glycobook")
      Dir.mkdir(ENV['HOME'] + "/.glycobook")
    end

    folder_path = File.dirname(__FILE__) + "/jar"
    unless Dir.exist?(folder_path)
      FileUtils.mkdir_p(folder_path)
    end

    if File.exist?(file_path)
      downloads = YAML.load_file(file_path)
    else
      FileUtils.cp(File.dirname(File.expand_path(__FILE__)) + "/../jar.yml", file_path)
    end

    if flag
      FileUtils.cp(File.dirname(File.expand_path(__FILE__)) + "/../jar.yml", file_path)
      downloads = YAML.load_file(file_path)
    end

    downloads
  end

  def self.calculate_file_hash(file_path)
    hash_func = Digest::SHA256.new
    begin
      File.open(file_path, 'rb') do |file|
        while chunk = file.read(8192)
          hash_func.update(chunk)
        end
      end
    rescue IOError => e
      puts "ファイルの読み込み中にエラーが発生しました: #{file_path}, エラー: #{e}"
      return nil
    end
    hash_func.hexdigest
  end
  
  def self.find_matching_files(target_file_path, folder_path)
    target_file_hash = calculate_file_hash(target_file_path)
    return unless target_file_hash
  
    matching_files = Dir.glob("#{folder_path}/**/*").select do |file_path|
      next unless File.file?(file_path)
      next if File.identical?(target_file_path, file_path) 
  
      file_hash = calculate_file_hash(file_path)
      file_hash == target_file_hash unless file_hash.nil?
    end
  
    matching_files
  end
  
  def self.extract_version_from_filename(filename)
    match_data = filename.match(/-(\d+\.\d+\.\d+)\.jar$/)
    match_data ? match_data[1] : nil
  end

end