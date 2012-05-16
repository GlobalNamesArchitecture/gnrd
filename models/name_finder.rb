class NameFinder < ActiveRecord::Base
  after_create :make_output  
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
    
  private

  def make_output
    url_format = ['xml', 'json'].include?(format) ? ".#{format}" : ''
    self.url = SiteConfig.url_base + "/name_finder/" + token + url_format
    self.output = {:url => url, :status => 'In Progress'}
    self.save!
  end

  def set_instance_vars
    @start_process = Time.now
    @engines = [ENGINES[engine]]
    @agent = nil
    @output = nil
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
      rescue
        @agent = { :code => "500", :content_type => "" }
      end
    end
  end
  
  def read_doc
    content = ""
    Dir.mktmpdir{ |dir|
      file = File.join(dir, @agent[:filename])
      new_agent.pluggable_parser.default = Mechanize::Download
      new_agent.get(input_url).save(file)
      Docsplit.extract_text(file, :output => dir, :clean => true)
      for name in Dir.new(dir)
        if name =~ /\.txt$/
          content << File.open(File.join(dir, name), 'r')  { |f| f.read }
        end
      end
    }
    content
  end
  
  def upload_doc
    content = ""
    tmpfile = file_path[:tempfile]
    Dir.mktmpdir{ |dir|
      file = File.join(dir, file_path[:filename])
      open_file = File.open(file, "ab")
      while blk = tmpfile.read(65536)
        open_file.write(blk)
      end
      open_file.close
      Docsplit.extract_text(file, :output => dir, :clean => true)
      for name in Dir.new(dir)
        if name =~ /\.txt$/
          content << File.open(File.join(dir, name), 'r')  { |f| f.read }
        end
      end
    }
    content
  end
  
  def find_names(content)
    content.gsub!("_", " ")
    start_execution = Time.now
    if @engines.size == 2
      names = @tf_name_spotter.find(content)[:names] | @neti_name_spotter.find(content)[:names]
    else
      names = (@engines[0] == 'TaxonFinder') ? @tf_name_spotter.find(content)[:names] : @neti_name_spotter.find(content)[:names]
    end
    names.each { |name| name[:scientificName].gsub!(/[\[\]]/, "") }
    @end_execution = (Time.now - start_execution)
    names
  end
  
  def get_content
    content = ""
    if @agent && @agent[:code] == "500"
      flash[:error] = "That URL was inaccessible."
      return content
    end
    if !input_url.blank?
      if @agent[:content_type].include? "text/html"
        page = new_agent.get input_url
        content = page.parser.text.encode!('UTF-8', page.encodings.last, :invalid => :replace, :undef => :replace, :replace => '')
      else
        content = read_doc
      end
    elsif !file_path.blank?
      content = upload_doc
    elsif !input.blank?
      content = input
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
        :status  => "OK",
        :input_url     => input_url,
        :file    => file_path,
        :agent   => @agent,
        :execution_time => { :find_names_duration => @end_execution, :total_duration => (Time.now - @start_process) },
        :total   => unique ? names.uniq.count : names.count,
        :engines => @engines,
        :names   => unique ? names.uniq : names
      )
    rescue
      self.output.merge!(
        :status  => "FAILED",
        :input_url     => input_url,
        :file    => file_path,
        :agent   => @agent,
        :total   => 0,
        :engines => @engines,
        :names   => [],
      )
    end
    require 'pp'
    pp self.output
    puts 'output printed'
    save!
  end
end
