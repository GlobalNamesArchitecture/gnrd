helpers do
  def base_url
    @base_url ||=
      "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
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
    url = redirect_url(e[:status_code], fmt.format)
    url ? redirect(url, 303, flash) : present(nf, fmt)
  end

  def present(name_finder, formatter)
    @nf = name_finder
    status @nf.status_code
    content_type(formatter.content_type, encoding: "utf-8")
    format_render(formatter)
  end

  def format_render(formatter)
    case formatter.format
    when :html
      haml formatter.content
    when :xml
      @output = formatter.content
      builder :namefinder
    when :json
      formatter.content
    end
  end

  def handle_process(name_finder)
  end
end
