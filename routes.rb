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
  @ns = if params[:token]
          NameFinder.find_by_token(params[:token])
        else
          NameFinder.create(params: params)
        end
  name_finder_result(@ns)
end

post "/name_finder.?:format?" do
  @ns = NameFinder.create(params: params)
  output(@ns)
end
