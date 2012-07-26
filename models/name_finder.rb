# encoding: utf-8
class NameFinder < ActiveRecord::Base
  after_create :initiate_data
  attr_reader :process_netineti_names

  @queue = :name_finder
  RANKS = { "morph" => 1, "f" => 1, "ssp" => 1, "mut" => 1, "nothosubsp" => 1, "convar" => 1, "pseudovar" => 1, "sp" => 1, "sect" => 1, "ser" => 1, "var" => 1, "subvar" => 1, "subsp" => 1, "subf" => 1, "a" => 1, "b" => 1, "c" => 1, "d" => 1, "e" => 1, "d" => 1, "e" => 1, "g" => 1, "k" => 1, "form" => 1, "fo" => 1 }
  REGEX = { leftmost_dot: Regexp.new(/^\.+/), square_brackets: Regexp.new(/[\[\]]/), non_name_chars: Regexp.new(/[^\(\)\.\d\w\-\p{Latin}]/), dot_before_word: Regexp.new(/\.+([^\s])/), dot_after_word: Regexp.new(/([^\s]+)\.\s/), multiple_spaces: Regexp.new(/\s+/) }

  serialize :output, Hash
  ENGINES = { 0 => ["TaxonFinder", "NetiNeti"], 1 => ["TaxonFinder"], 2 => ["NetiNeti"] } 

  def self.perform(name_finder_id)
    nf = NameFinder.find(name_finder_id)
    nf.name_find
  end
  
  def name_find
    setup_instance_vars
    setup_name_engines
    get_agent_response
    build_output
  end
    
  def process_taxon_finder_names(names)
    names.each do |name|
      name[:identifiedName] = name[:scientificName].gsub(/\[[^()]*\]/,".")
      name[:engine] = 1
      process_name(name)
    end
    names
  end

  def process_netineti_names(names)
    names.each do |name|
      name[:identifiedName] = name[:scientificName]
      name[:engine] = 2
      process_name(name)
    end
    names
  end
  
  private

  def setup_instance_vars
    @start_process = Time.now
    @engines = ENGINES[engine]
    @agent = nil
    @output = nil
    @status = 200
  end
  
  def setup_name_engines
    neti_client        = NameSpotter::NetiNetiClient.new()
    tf_client          = NameSpotter::TaxonFinderClient.new()
    @neti_name_spotter = NameSpotter.new(neti_client)
    @tf_name_spotter   = NameSpotter.new(tf_client)
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
      rescue SocketError => e
        @agent = { :code => 404, :content_type => ""}
      end
    end
  end

  def build_output
    begin
      content = get_content
      is_english = NameSpotter.english? content
      names = find_names(content, is_english)

      self.unique = true if !self.verbatim
      names.each do |name|
        if !self.verbatim
          name.delete :verbatim
          name.delete :identifiedName
        end
        name.delete :offsetStart
        name.delete :offsetEnd
      end if self.unique

      self.output.merge!(
        :engines   => @engines,
        :status    => @status,
        :unique    => self.unique,
        :agent     => @agent || "",
        :english   => is_english,
        :created   => self.created_at,
        :execution_time => { :find_names_duration => @end_execution, :total_duration => (Time.now - @start_process) },
        :total     => self.unique ? names.uniq.count : names.count,
        :names     => self.unique ? names.uniq : names
      )
    rescue
      self.output.merge!(
        :status    => @status,
        :unique    => self.unique,
        :agent     => @agent || "",
        :created   => self.created_at,
        :total     => 0,
        :names     => [],
      )
    end
    self.file_path = nil
    self.input = nil
    save!
  end

  def find_names(content, is_english)
    names = []
    start_execution = Time.now
    content.gsub!("_", " ")
    begin
      if @engines.size == 2
        if !is_english && content.length > 1_000
          names = process_taxon_finder_names(@tf_name_spotter.find(content)[:names])
          @engines = [@engines.shift]
        else
          names = process_taxon_finder_names(@tf_name_spotter.find(content)[:names]) + process_netineti_names(@neti_name_spotter.find(content)[:names])
        end
      else
        names = (@engines[0] == 'TaxonFinder') ? process_taxon_finder_names(@tf_name_spotter.find(content)[:names]) : process_netineti_names(@neti_name_spotter.find(content)[:names])
      end
      names = process_combined_names(names)
    rescue => e
      @status = 500
    end
    @end_execution = (Time.now - start_execution)
    names
  end

# CONTENT HANDLING METHODS

  def get_content
    content = ""
    if @agent && @agent[:code] != "200"
      @status = 404
    else
      save_file_from_url if !input_url.blank?
      content = !input.blank? ? input : read_file
    end
    content
  end

  def save_file_from_url
    temp_dir = Dir.mktmpdir
    file_path = File.join(temp_dir, @agent[:filename])
    page = new_agent.get(input_url)
    page.content.encode!("UTF-8", page.detected_encoding, :invalid => :replace, :undef => :replace, :replace => "") if @agent[:content_type].match /html/
    page.save(file_path)
    document_sha = Digest::SHA1.hexdigest(file_path)
    self.update_attributes :file_path => file_path, :document_sha => document_sha
  end

  def read_file
    content = ""
    dir = File.dirname(self.file_path)
    file_type = `file #{self.file_path}`
    if file_type.match /text/
      File.open(self.file_path, 'r') do |f|
        content = f.read
        if file_type.match /html/
          begin
            content = Sanitize.clean(content)
            content.gsub!("\n", "")
          rescue
            @status = 500
          end
        end
      end
    else
      opts = { :output => dir, :clean => true }
      opts.merge!({ :pages => 'all' }) if file_type.match /PDF/
      Docsplit.extract_text(self.file_path, opts)
      Dir.entries(dir).each do |name|
        if name.match /\.txt$/
          File.open(File.join(dir, name), 'r') do |f|
            content << f.read
          end
        end
      end
    end
    FileUtils.remove_entry_secure dir
    content
  end

# SET-UP AGENT

  def new_agent
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Mozilla'
    agent.pluggable_parser.default = Mechanize::Download
    agent
  end

# NAME PROCESSING METHODS

  def process_name(name)
    n = name[:scientificName]
    n = n.gsub(NameFinder::REGEX[:leftmost_dot], "").gsub(NameFinder::REGEX[:square_brackets], "").gsub("_", " ").gsub(NameFinder::REGEX[:non_name_chars], " ").strip
    if tail = n[2..-1]
      tail.gsub!(NameFinder::REGEX[:dot_before_word], ' \1')
      tail.gsub!(' . ', ' ')
      tail.gsub!(NameFinder::REGEX[:dot_after_word]) do
        NameFinder::RANKS[$1] ? "#{$1}." : $1
      end
      n = n[1] == '.' ? n[0..1] + ' ' + tail : n[0..1] + tail
    end
    name[:scientificName] = n.gsub(NameFinder::REGEX[:multiple_spaces], ' ').strip
  end

  def process_combined_names(names)
    return [] if names.empty?
    names = names.sort_by { |n| n[:offsetStart] }
    @deduped_names = []
    name = names.shift
    name_group = start_name_group(name)
    until names.empty?
      name = names.shift
      if name[:offsetStart].between?(name_group[:start], name_group[:end])
        name_group = update_name_group(name, name_group)
      else
        add_deduped_name(name_group)
        name_group = start_name_group(name)
      end
    end
    add_deduped_name(name_group)
    @deduped_names.each { |x| x.delete :engine }
  end

  def start_name_group(name)
    name_group = {:start => name[:offsetStart], :end => name[:offsetEnd], :preferred_name => nil, :taxon_finder_name => nil, :neti_neti_names => [], :neti_neti_size => 0}
    if name[:engine] == 1
      name_group[:taxon_finder_name] = name
      name_group[:preferred_name] = 1
    else
      name_group[:neti_neti_names] << name
      name_group[:neti_neti_size] = name[:offsetEnd] - name[:offsetStart]
      name_group[:preferred_name] = 2
    end
    name_group
  end

  def add_deduped_name(name_group)
    deduped_name = name_group[:preferred_name] == 1 ? name_group[:taxon_finder_name] : name_group[:neti_neti_names].shift
    @deduped_names << deduped_name
  end

  def find_preferred_name(name, name_group)
    name_group[:end] = name[:offsetEnd] if name_group[:end] < name[:offsetEnd]
    name_size = name[:offsetEnd] - name[:offsetStart]
    #when incoming name is found through TaxonFinder
    if name[:engine] == 1
      name_group[:taxon_finder_name] = name
      if name[:offsetStart] == name_group[:start]
        #prefer incoming TaxonFinder name if it and name in existing group start at same offset
        name_group[:preferred_name] = 1
      else
        #prefer incoming TaxonFinder name if it is larger than the largest NetiNeti name already in the group
        name_group[:preferred_name] = 1 if name_size > name_group[:neti_neti_size]
      end
    else
      #when incoming name is found through NetiNeti, put largest at start of NetiNeti collection in group
      if name_size > name_group[:neti_neti_size]
        name_group[:neti_neti_names].unshift(name)
        name_group[:neti_neti_size] = name_size
      else
        name_group[:neti_neti_names].push(name)
      end
      #add logic like this if you want less conservative results
      # if name_group[:preferred_name] == 1
      #   if name[:offsetStart] == name_group[:offsetStart]
      #     name_group[:preferred_name] = 2 if name_size > name_group[:neti_neti_size]
      #   end
      # end
    end
    name_group
  end

  def update_name_group(name, name_group)
    if name[:engine] == 1
      if name_group[:taxon_finder_name]
        add_deduped_name(name_group)
        name_group = start_name_group(name)
      else
        name_group = find_preferred_name(name, name_group)
      end
    else
      if name_group[:neti_neti_names].size > 2
        add_deduped_name(name_group)
        name_group = start_name_group(name)
      else
        name_group = find_preferred_name(name, name_group)
      end
    end
    name_group
  end

# AFTER_CREATE

  def initiate_data
    self.token = "_"
    while token.match(/[_-]/)
      self.token = Base64.urlsafe_encode64(UUID.create_v4.raw_bytes)[0..-3]
    end
    url_format = ['xml', 'json'].include?(format) ? ".#{format}" : ''
    self.token_url = SiteConfig.url_base + "/name_finder" + url_format + "?token=" + token
    self.output = { :token_url => token_url, :input_url => input_url || "", :file => file_name || "", :status => 303, :engines => ENGINES[engine], :unique => unique, :verbatim => verbatim }
    self.save!
    self.reload
  end

end
