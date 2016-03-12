get '/main.css' do
  content_type 'text/css', charset: 'utf-8'
  scss :main
end

get "/" do
  haml :home
end
