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
    fm = Gnrd::App::Formatter.new(name_finder)
    fm.show
  end

  def errors_show(name_finder, errors)
    name_finder.output = errors
    name_finder.save!
    fm = Gnrd::App::Formatter.new(name_finder)
    fm.show
  end

  def errors_detect(name_finder)
    errs = []
    errs << error_check_params_empty(name_finder)
    errs.compact
  end

  def error_check_params_empty(name_finder)
    if name_finder.params.empty?
      { status: 400, message: "Bad request. Parameters missing" }
    end
  end
end
