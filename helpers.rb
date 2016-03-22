helpers do
  def base_url
    @base_url ||=
      "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def workers_running?
    !Resque.redis.smembers('workers').empty?
  end

  def name_finder_init(params)
    return NameFinder.find_by_token(params[:token]) if params[:token]
    NameFinder.create(params: params)
  end

  def handle_errors(name_finder)
    nf = name_finder
    e = nf.errs.first
    fmt = Sinatra::Formatter.new(nf)
    flash = { error: e[:message] }
    url = redirect_url(e[:status_code], fmt)
    url ? redirect(url, 303, flash) : present(fmt)
  end

  def present(formatter)
    @nf = formatter.name_finder
    @nf.status_code = 200
    @nf.save!
    status @nf.status_code
    content_type(formatter.content_type, encoding: "utf-8")
    format_render(formatter)
  end

  def format_render(formatter)
    case formatter.format
    when :html
      @output = formatter.content
      haml :name_finder
    when :xml
      @output = formatter.content
      builder :namefinder
    when :json
      formatter.content
    end
  end

  def handle_process(name_finder)
    case name_finder.state
    when :idle
      init_name_find(name_finder)
    when :working
      handle_waiting(name_finder)
    when :finished
      fmt = Sinatra::Formatter.new(name_finder)
      present(fmt)
    end
  end

  def init_name_find(nf)
    if workers_running? && false
      NameFinder.enqueue(nf)
      nf.state = :working
    else
      nf.find_names
      nf.state = :finished
    end
    nf.save!
    fmt = Sinatra::Formatter.new(nf)
    url = redirect_url(303, fmt)
    redirect url, 303
  end

  def handle_waiting(nf)
    fmt = Sinatra::Formatter.new(nf)
    present(fmt)
  end
end
