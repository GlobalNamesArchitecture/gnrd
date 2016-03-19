helpers do
  def base_url
    @base_url ||=
      "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def name_finder_result(name_finder)
    errs = errors_detect(name_finder)
    errs.empty? ? result_show(name_finder) : errors_show(name_finder, errs)
  end

  def result_show(name_finder)
    @title = @header = "Discovered Names"
    @page = "home"
    fm = Sinatra::Formatter.new(name_finder)
    fm.show
  end

  def errors_show(name_finder, errors)
    name_finder.output = errors
    name_finder.save!
    fm = Sinatra::Formatter.new(name_finder)
    status(name_finder.status_code)
    content_type(fm.content_type, charset: "utf-8")
  end

  def errors_detect(name_finder)
    errs = []
    errs << error_check_params_empty(name_finder)
    errs.compact
  end

  def error_check_params_empty(name_finder)
    nf = name_finder
    if nf.params[:source].empty?
      nf.status_code = 400
      nf.err_msg = "Bad request. Parameters missing"
      { status: nf.status_code, message: nf.err_msg }
    end
  end
end
