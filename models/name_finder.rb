# encoding: utf-8
class NameFinder < ActiveRecord::Base
  after_create :add_fields_data
  attr_reader :process_netineti_names

  @queue = :name_finder

  serialize :output, Hash
  ENGINES = { 0 => ["TaxonFinder", "NetiNeti"], 1 => ["TaxonFinder"], 2 => ["NetiNeti"] } 

  def self.perform(name_finder_id)
    nf = NameFinder.find(name_finder_id)
    nf.name_find
  end
  
  def name_find
    set_instance_vars
    setup_name_spotter
    get_agent_response
    build_output
  end
    
  def process_taxon_finder_names(names)
    names.each do |name|
      process_name(name)
    end
    names
  end

  def process_netineti_names(names)
        require 'ruby-debug'; debugger
    names.each do |name|
      process_name(name)
    end
    names
  end

  def process_combined_names(names)
    names = names.sort_by { |n| n[:offsetStart] }
  end

  private

  def add_fields_data
    token = "_"
    while token.match(/[_-]/)
      token = Base64.urlsafe_encode64(UUID.create_v4.raw_bytes)[0..-3]
    end
    unique ||= false
    url_format = ['xml', 'json'].include?(format) ? ".#{format}" : ''
    self.url = SiteConfig.url_base + "/name_finder" + url_format + "?token=" + token 
    self.output = {:url => url, :input_url => input_url, :status => 'In Progress', :engines => ENGINES[engine]}
    self.save!
  end

  def set_instance_vars
    @start_process = Time.now
    @engines = ENGINES[engine]
    @agent = nil
    @output = nil
    @status = nil
  end

  def setup_name_spotter
    neti_client        = NameSpotter::NetiNetiClient.new()
    tf_client          = NameSpotter::TaxonFinderClient.new()
    @neti_name_spotter = NameSpotter.new(neti_client)
    @tf_name_spotter   = NameSpotter.new(tf_client)
  end

  def new_agent
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Mozilla'
    agent
  end

  def get_agent_response
    if !input_url.blank?
      if URI(input_url).scheme.nil?
        input_url.insert(0, "http://")
      end rescue nil
      begin
        head = new_agent.head input_url
        @agent = { :code => head.code, :content_type => head.response["content-type"], :filename => head.filename }
      rescue Mechanize::ResponseCodeError => e
        @agent = { :code => e.response_code, :content_type => "" }
      end
    end
  end
  
  def save_file_from_url
    temp_dir = Dir.mktmpdir
    file_path = File.join(temp_dir, @agent[:filename])
    new_agent.pluggable_parser.default = Mechanize::Download
    new_agent.get(input_url).save(file_path)
    document_sha = Digest::SHA1.hexdigest(file_path)
    self.update_attributes :file_path => file_path, :document_sha => document_sha
  end

  def read_file
    content = ""
    dir = File.dirname(self.file_path)
    file_type = `file #{self.file_path}`
    if file_type.match /text/
      file = File.open(self.file_path, 'r')
      content << file.read
      file.close
    else
      Docsplit.extract_text(self.file_path, :output => dir, :clean => true)
      Dir.entries(dir).each do |name|
        if name.match /\.txt$/
          file = File.open(File.join(dir, name), 'r')
          content << file.read
          file.close
        end
      end
    end
    FileUtils.remove_entry_secure dir
    content
  end
  
  def find_names(content)
    names = []
    content.gsub!("_", " ")
    start_execution = Time.now
    begin
      if @engines.size == 2
        names = process_taxon_finder_names(@tf_name_spotter.find(content)[:names]) | process_netineti_names(@neti_name_spotter.find(content)[:names])
        names = process_combined_names(names)
      else
        names = (@engines[0] == 'TaxonFinder') ? process_taxon_finder_names(@tf_name_spotter.find(content)[:names]) : process_netineti_names(@neti_name_spotter.find(content)[:names])
      end
      @status = 200 if !content.blank?
    rescue
      @status = 500
    end
    @end_execution = (Time.now - start_execution)
    names
  end

  def process_name(name)
    ranks ={"morph" => 1, "f" => 1, "ssp" => 1, "mut" => 1, "nothosubsp" => 1, "convar" => 1, "pseudovar" => 1, "sp" => 1, "sect" => 1, "ser" => 1, "var" => 1, "subvar" => 1, "subsp" => 1, "subf" => 1, "a" => 1, "b" => 1, "c" => 1, "d" => 1, "e" => 1, "d" => 1, "e" => 1, "g" => 1, "k" => 1, "form" => 1, "fo" => 1}
    n = name[:scientificName]
    return if n.size < 2
    n = n.strip
    n.gsub!(/^\.+/, '')
    n.gsub!(/[\[\]]/, "") 
    n = n.gsub(/[^\.\d\w\-\p{Latin}]/, ' ').gsub(/_/, ' ').strip
    if tail = n[2..-1]
      tail.gsub!(/\.+([^\s])/, ' \1')
      tail.gsub!(/ \. /, ' ')
      tail.gsub!(/([^\s]+)\.\s/) do
        ranks[$1] ? "#{$1}." : $1
      end
      n = n[1] == '.' ? n[0..1] + ' ' + tail : n[0..1] + tail
    end
    name[:scientificName] = n.gsub(/\s+/, ' ').strip
  end

  def proces_netineti_names(names)
    names.each do |name|
      process_name(name)
    end
  end
  
  def get_content
    content = ""
    if @agent && @agent[:code] != "200"
      @status = 404
    else
      save_file_from_url if !input_url.blank?
      if !input.blank?
        content = input
      else
        content = read_file
      end
    end
    content
  end
  
  def build_output
    begin
      names = find_names(get_content)
      if unique
        names.each do |name|
          name.delete :offsetStart
          name.delete :offsetEnd
        end
      end
      self.output.merge!(
        :status    => @status,
        :input_url => self.input_url,
        :file      => self.file_name,
        :agent     => @agent,
        :execution_time => { :find_names_duration => @end_execution, :total_duration => (Time.now - @start_process) },
        :total     => self.unique ? names.uniq.count : names.count,
        :engines   => @engines,
        :names     => self.unique ? names.uniq : names
      )
    rescue
      self.output.merge!(
        :status    => @status,
        :input_url => self.input_url,
        :file      => self.file_name,
        :agent     => @agent,
        :total     => 0,
        :engines   => @engines,
        :names     => names,
      )
    end
    self.file_path = nil
    self.input = nil
    save!
  end
end
