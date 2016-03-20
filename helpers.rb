helpers do
  def base_url
    @base_url ||=
      "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def handle_errors(name_finder)
    nf = name_finder
    e = nf.errs.first
    fmt = Sinatra::Formatter.new(nf)
    url = redirect_url(e[:status_code], fmt.format)
    url ? redirect(url, 303) : present(nf, fmt)
  end

  def present(name_finder, formatter)
    @nf = name_finder
    status @nf.status_code
    content_type(formatter.content_type, encoding: "utf-8")
    case formatter.format
    when :html
      set_flash(@nf)
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
