helpers do
  def base_url
    @base_url ||=
      "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end
