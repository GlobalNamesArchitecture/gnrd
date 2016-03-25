helpers do
  CONTENT_TYPE = { html: "text/html",
                   json: "application/json",
                   xml:  "application/xml" }.freeze

  def name_finder_init
    return find_by_token if params[:token]
    create_name_finder
  end

  def find_names
    case @nf.state
    when :idle
      init_find
    when :working
      wait_find
    when :finished
      show_find
    end
  end

  private

  def create_name_finder
    nf = NameFinder.create(params: Gnrd.symbolize_keys(params))
    err = nf.valid? ? [] : nf.errors[:base]
    [nf, err]
  end

  def find_by_token
    err = []
    nf = NameFinder.find_by_token(params[:token])
    if nf
      nf.params_update(params)
    else
      err << { status: 404,
               message: "Not Found. That result no longer exists." }
    end
    [nf, err]
  end

  def workers_running?
    !Resque.redis.smembers("workers").empty?
    false
  end

  def format
    @format ||= Params.new(params).format
  end

  def show_errors(err)
    e = err.first
    if format == :html
      redirect "/", error: e[:message]
    else
      present(e[:status], e)
    end
  end

  def present(status_code, output)
    status status_code
    content_type CONTENT_TYPE[format]
    @output = output
    case format
    when :html then haml :name_finder
    when :xml  then builder :namefinder
    when :json then JSON.dump output
    end
  end

  def init_find
    if workers_running?
      NameFinder.enqueue(@nf)
      @nf.state = :working
    else
      @nf.find_names
      @nf.state = :finished
    end
    @nf.save!
    redirect_find_names
  end

  def wait_find
    redirect_find_names
  end

  def redirect_find_names
    if @nf.errs.empty?
      ext = format == :html ? "" : ".#{format}"
      redirect "/name_finder#{ext}?token=#{@nf.token}", 303
    else
      show_errors(@nf.errs)
    end
  end

  def show_find
    if @nf.errors[:base].empty?
      present(200, @nf.output)
    else
      show_errors(@nf.errors[:base])
    end
  end
end
