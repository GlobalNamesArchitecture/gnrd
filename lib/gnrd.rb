require 'uri'
require 'tmpdir'
require 'mechanize'
require 'docsplit'

module GNRD
  class NameFinder

    def initialize(params)
      @start_process = Time.now
      @url = params[:url] || (params[:find] && params[:find][:url]) || nil
      @file = params[:file] || (params[:find] && params[:find][:file]) || nil
      @input = params[:input] || (params[:find] && params[:find][:input]) || nil
      @valid_engines = ["TaxonFinder", "NetiNeti"]
      @engine = (params[:engine] && @valid_engines.include?(params[:engine])) ? [params[:engine]] : @valid_engines
      @unique = params[:unique] || false
      @format = params[:format] || "html"
      @agent = nil
      @output = nil
    end
    
    def find
      setup_name_spotter
      get_agent_response
      build_output
      @output
    end

    private

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
      if !@url.blank?
        if URI(@url).scheme.nil?
          @url.insert(0, "http://")
        end rescue nil
        begin
          head = new_agent.head @url
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
        new_agent.get(@url).save(file)
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
      tmpfile = @file[:tempfile]
      Dir.mktmpdir{ |dir|
        file = File.join(dir, @file[:filename])
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
      if @engine.size == 2
        names = @tf_name_spotter.find(content)[:names] | @neti_name_spotter.find(content)[:names]
      else
        names = (@engine[0] == 'TaxonFinder') ? @tf_name_spotter.find(content)[:names] : @neti_name_spotter.find(content)[:names]
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
      if !@url.blank?
        if @agent[:content_type].include? "text/html"
          page = new_agent.get @url
          content = page.parser.text.encode!('UTF-8', page.encodings.last, :invalid => :replace, :undef => :replace, :replace => '')
        else
          content = read_doc
        end
      elsif !@file.blank?
        content = upload_doc
      elsif !@input.blank?
        content = @input
      end
      content
    end
    
    def build_output
      begin
        names = find_names(get_content)
        if @unique
          names.each do |name|
            name.delete :offsetStart
            name.delete :offsetEnd
          end
        end
        @output = {
          :status  => "OK",
          :url     => @url,
          :file    => @file,
          :agent   => @agent,
          :execution_time => { :find_names_duration => @end_execution, :total_duration => (Time.now - @start_process) },
          :total   => @unique ? names.uniq.count : names.count,
          :engines => @engine,
          :names   => @unique ? names.uniq : names
        }
      rescue
        @output = {
          :status  => "FAILED",
          :url     => @url,
          :file    => @file,
          :agent   => @agent,
          :total   => 0,
          :engines => @engine,
          :names   => [],
        }
      end
    end
  end
end
