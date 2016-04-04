get "/main.css" do
  content_type "text/css", charset: "utf-8"
  scss :main
end

get "/" do
  @page = "home"
  @tagline = "Global Names recognition and discovery tools and services"
  Today.expire_old_data
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

get "/history" do
  @page = "history"
  @title = "History"
  @header = "History"
  @records = NameFinder
             .select(:token, :params, :created_at)
             .where("params #> '{source}' ?| array['file', 'url']")
  @meta_norobots = true
  haml :history
end

post_get "/name_finder.?:format?" do
  @title = "Discovered Names"
  @page = "home"
  @header = "Discovered Names"
  @nf, @err = name_finder_init
  @err.empty? ? find_names : show_errors(@err)
end
