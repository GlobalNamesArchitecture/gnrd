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
    begin
      nf = NameFinder.find_by_token(params[:token])
      name_finder_presentation(nf, params[:format])
    rescue
      error_presentation(params[:format])
    end
  else
    find(params)
  end
end
