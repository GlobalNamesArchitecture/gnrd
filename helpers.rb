helpers do
  def base_url
    @base_url ||=
      "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def output(name_finder, opts)
    @title = @header = "Discovered Names"
    @page = "home"
    fm = Gnrd::App::Formatter.new(name_finder, opts)
    fm.show
  end
end
