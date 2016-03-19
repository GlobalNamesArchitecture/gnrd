get "/main.css" do
  content_type "text/css", charset: "utf-8"
  scss :main
end

get "/" do
  @page = "home"
  @tagline = "Global Names recognition and discovery tools and services"
  haml :home
end

get "/api" do
  @page = "api"
  @title = "API"
  @header = "Application Programming Interface"
  base_url
  haml :api
end

get "/feedback" do
  @page = "feedback"
  @title = "Feedback"
  @header = "Feedback"
  haml :feedback
end

get "/name_finder.?:format?" do
  if params[:token]
    @ns = NameFinder.find_by_token(params[:token])
    @ns.init_find
  else
    @ns = NameFinder.create(params: params)
  end
  @ns.prepare
  redirect(@ns) if @ns.redirect_path
  if @ns.error?
    show_error(@ns)
  else
    show(@ns)
  end
end

post "/name_finder.?:format?" do
  @ns = NameFinder.create(params: params)
  redirect(@ns)
end
