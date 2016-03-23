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
  haml :api
end

get "/feedback" do
  @page = "feedback"
  @title = "Feedback"
  @header = "Feedback"
  haml :feedback
end

get "/name_finder.?:format?" do
  @page = "name_finder"
  @title = "Name Finder"
  @header = "Feedback"
  @nf = name_finder_init(params)
  if @nf.errors?
    handle_errors(@nf)
  else
    handle_process(@nf)
  end
end

post "/name_finder.?:format?" do
  params_normalized = Gnrd.symbolize_keys(params) # to get path to file
  @nf = NameFinder.create(params: params_normalized)
  if @nf.errors?
    handle_errors(@nf)
  else
    handle_process(@nf)
  end
end
