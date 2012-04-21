class FindController < ApplicationController
  require 'uri'
  require 'tmpdir'
  skip_before_filter :verify_authenticity_token

  def index
    init
  end
  
  def create
    init
  end
  
  protected
  
  def init
    get_params
    setup_name_spotter
    get_agent_response
    build_output
    produce_response
  end
  
  def get_params
    @start = Time.now
    @url = params[:url] || (params[:find] && params[:find][:url]) || nil
    @input = params[:input] || (params[:find] && params[:find][:input]) || nil
    @engine = (params[:engine] && valid_engines.include?(params[:engine])) ? [params[:engine]] : ["TaxonFinder", "NetiNeti"]
    @unique = params[:unique] || false
  end
  
  def get_agent_response
    @agent = { :code => "200", :content_type => "text/html" }
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
  
  def find_names(content)
    content.gsub!("_", " ")
    if @engine.count == 2
      #force encoding for taxon_finder because it cannot properly deal with some unicode characters
      names = @tf_name_spotter.find(content.force_encoding('BINARY').encode('UTF-8',  :invalid => :replace, :undef => :replace, :replace => ''))[:names] | @neti_name_spotter.find(content)[:names]
    else
      names = (@engine[0] == 'TaxonFinder') ? @tf_name_spotter.find(content.force_encoding('BINARY').encode('UTF-8',  :invalid => :replace, :undef => :replace, :replace => ''))[:names] : @neti_name_spotter.find(content)[:names]
    end
    names.each do |name|
      #force encoding for output because it comes back as ASCII-8bit
      name.each { |k,v| name[k] = v.force_encoding('UTF-8') unless v.is_a? Numeric }
    end
    names
  end
  
  def get_content
    content = ""
    if @agent[:code] == "500"
      flash[:error] = "That URL was inaccessible."
      return content
    end
    if !@input.blank?
      content = @input
    elsif !@url.blank?
      if @agent[:content_type].include? "text/html"
        page = new_agent.get @url
        #encode the web page content
        content = page.parser.text.encode!('UTF-8', page.encodings.last, :invalid => :replace, :undef => :replace, :replace => '')
      else
        content = read_doc
      end
    end
    content
  end
  
  def build_output
    begin
      names = find_names(get_content)
      if request.method == "GET" || @unique
        names.each do |name|
          name.delete :offsetStart
          name.delete :offsetEnd
        end
      end
      @output = {
        :status  => "OK",
        :elapsed => (Time.now - @start),
        :total   => @unique ? names.uniq.count : names.count,
        :engines => @engine,
        :names   => @unique ? names.uniq : names
      }
    rescue
      flash[:error] = "The name engines failed. Administrators have been notified."
      @output = {
        :status  => "FAILED",
        :total   => 0,
        :engines => @engine,
        :names   => [],
      }
      Mailer.error_email.deliver
    end
  end
  
  def produce_response
    respond_to do |format|
      format.json do
        render :json => @output, :callback => params[:callback]
      end
      
      format.xml do
        response.headers['Content-type'] = 'text/xml; charset=utf-8'
        render :action => :index, :layout => false
      end
      
      format.html do
        render :action => :index
      end
    end
  end

end
