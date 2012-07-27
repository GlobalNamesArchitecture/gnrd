# encoding: utf-8
require_relative "./spec_helper"

describe "/" do 
  it "should open home page" do
    get "/"
    r = last_response
    r.status.should == 200
    r.body.match("Find scientific names on web pages").should be_true
  end
end

describe "/api" do 
  it "should open api page" do
    get "/api"
    r = last_response
    r.status.should == 200
    r.body.match("Application Programming Interface").should be_true
    r.body.match("This API produces an immediate response containing a token URL to be polled.").should be_true
  end
end

describe "/feedback" do 
  it "should open the feedback page" do
    get "/feedback"
    r = last_response
    r.status.should == 200
    r.body.match("Feedback").should be_true
  end
end

describe "/history" do 
  it "should open the history page" do
    get "/history"
    r = last_response
    r.status.should == 200
    r.body.match("History").should be_true
    r.body.match("Results are limited to files and URLs for the last 7 days").should be_true
  end
end

describe "/name_finder" do
  def get_url(text)
    is_xml = !!text.match(/<\?xml.*version.*>/)
    if is_xml
      text.match(/<token_url>([^<]*)<\/token_url>/)[1]
    else
      JSON.load(text)["token_url"]
    end
  end

  it "should redirect if there are no parameters" do
    get "/name_finder"
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
  end
  
  it "should give error when a token does not exist" do
    get "/name_finder?token=9999999"
    r = last_response
    r.status.should == 200
    r.body.match("That result no longer exists")
  end
  
  it "should give warning when a URL is not found" do
    url = URI.encode("http://eol.org/pages/a/overview")
    get "/name_finder?url=#{url}"
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('That URL was inaccessible').should be_true if count == 1
      if r.body.match("That URL was inaccessible")
        r.body.match("That URL was inaccessible").should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end
  
  it "should be able to find names in a URL as a parameter" do
    url = URI.encode("http://eol.org/pages/207212/overview")
    get "/name_finder?url=#{url}"
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Epinephelus drummondhayi').should be_true if count == 1
      if r.body.match("Epinephelus drummondhayi")
        r.body.match("Epinephelus drummondhayi").should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end
  
  it "should expand URL as a parameter to include http:// if absent" do
    url = URI.encode("eol.org/pages/207212/overview")
    get "/name_finder?url=#{url}"
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Epinephelus drummondhayi').should be_true if count == 1
      if r.body.match("Epinephelus drummondhayi")
        r.body.match("Epinephelus drummondhayi").should be_true
        r.body.match("http://eol.org/pages/207212/overview").should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "should be able to find names in text as a parameter" do
    text = URI.encode('Betula alba Beçem')
    get "/name_finder?text=#{text}"
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Betula alba').should be_true if count == 1
      if r.body.match("Betula alba")
        r.body.match("Betula alba").should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "should be able to find names in a URL" do 
    url = "http://eol.org/pages/207212/overview"
    post("/name_finder", :engine => 0, :unique => true, :url => url)
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Epinephelus drummondhayi').should be_true if count == 1
      if r.body.match("Epinephelus drummondhayi")
        r.body.match("Epinephelus drummondhayi").should be_true
        r.body.match("http://eol.org/pages/207212/overview").should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end
  
  it "should be able to find names in a submitted utf-8 text" do
    text = 'Betula alba Beçem'
    post("/name_finder", :text => text, :engine => 0)
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Betula alba').should be_true if count == 1
      if r.body.match("Betula alba")
        r.body.match("Betula alba").should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "should be able to find names in an uploaded file" do
    utf_text_file = File.join(SiteConfig.root_path, 'spec', 'files', 'utf_names.txt')
    post('/name_finder', :file => Rack::Test::UploadedFile.new(utf_text_file, 'text/plain'))
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Plantago major').should be_true if count == 1
      if r.body.match("Plantago major")
        r.body.match("Plantago major").should be_true
        r.body.match("Pomatomus saltator").should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "should be able to find names in image" do
    image_file = File.join(SiteConfig.root_path, 'spec', 'files', 'image.jpg')
    post('/name_finder', :file => Rack::Test::UploadedFile.new(image_file, 'image/jpeg'))
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Pseudodoros').should be_true if count == 1
      if r.body.match('Pseudodoros')
        r.body.match('Pseudodoros').should be_true
        r.body.match('Ocyptamus').should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end
  
  it "should produce a non result when no names are in an image" do
    image_file = File.join(SiteConfig.root_path, 'spec', 'files', 'no_names.jpg')
    post('/name_finder', :file => Rack::Test::UploadedFile.new(image_file, 'image/jpeg'), :unique => true)
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      content = Sanitize.clean(r.body).gsub!("\n", "").gsub!(/\s\s+/,' ')
      content.match('0 unique names').should be_true if count == 1
      if content.match('0 unique names')
        content.match('0 unique names').should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end
  
  it "should be able to find names in PDF" do
    pdf_file = File.join(SiteConfig.root_path, 'spec', 'files', 'file.pdf')
    post('/name_finder', :file => Rack::Test::UploadedFile.new(pdf_file, 'application/pdf'), :engine => 2)
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.body.match('Passiflora pilosicorona').should be_true if count == 1
      if r.body.match('Passiflora pilosicorona')
        r.body.match('Passiflora pilosicorona').should be_true
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "API should give error when a token does not exist" do
    get "/name_finder.json?token=9999999"
    r = last_response
    r.status.should == 404
    r.body.match("That result no longer exists")
  end

  it "API should return correct http respsonse code if there are no parameters" do
    get "/name_finder.json"
    last_response.status.should == 400
  end
  
  it "API should be able to find names in submitted utf-8 text" do
    text = open(File.join(File.dirname(__FILE__), 'files', 'big.txt')).read
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :text => text, :engine => 0)
      last_response.status.should == 303
      last_response.body.match('Passiflora acutissima').should be_false
      follow_redirect!
      r = last_response
      r.body.match('Passiflora acutissima').should be_false
      count = 10
      while count > 0
        get(last_request.url)
        r = last_response
        r.body.match('Passiflora acutissima').should be_true if count == 1
        if r.body.match('Passiflora acutissima')
          r.body.match('Passiflora acutissima').should be_true
          break
        end
        sleep(5)
        count -= 1
      end
    end
  end
  
  it "API should be able to find names from submitted url" do
    url = URI.encode("http://eol.org/pages/207212/overview")
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :url => url, :engine => 0)
      last_response.status.should == 303
      follow_redirect!
      count = 10
      while count > 0
        get(last_request.url)
        r = last_response
        r.body.match('Epinephelus drummondhayi').should be_true if count == 1
        break if r.body.match('Epinephelus drummondhayi')
        sleep(5)
        count -= 1
      end
    end
  end
  
  it "API should be able to find names in a text file" do
    file = File.join(File.dirname(__FILE__), 'files', 'big.txt')
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :file => Rack::Test::UploadedFile.new(file, 'text/plain'), :engine => 0)
      last_response.status.should == 303
      follow_redirect!
      last_response.body.match('Passiflora acutissima').should be_false
      count = 10
      while count > 0
        get(last_request.url)
        r = last_response
        r.body.match('Passiflora acutissima').should be_true if count == 1
        break if r.body.match('Passiflora acutissima')
        sleep(5)
        count -= 1
      end
    end
  end

  it "API should be able to find names in a image file" do
    file = File.join(File.dirname(__FILE__), 'files', 'image.jpg')
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :file => Rack::Test::UploadedFile.new(file, 'image/jpeg'), :engine => 0)
      last_response.status.should == 303
      follow_redirect!
      last_response.body.match('Pseudodoros').should be_false
      count = 10
      while count > 0
        get(last_request.url)
        r = last_response
        r.status.should == 200
        r.body.match('Pseudodoros').should be_true if count == 1
        break if r.body.match('Pseudodoros')
        sleep(5)
        count -= 1
      end
    end
  end

  it "API should be able to find names in a pdf file" do
    file = File.join(File.dirname(__FILE__), 'files', 'file.pdf')
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :file => Rack::Test::UploadedFile.new(file, 'text/plain'), :engine => 0)
      last_response.status.should == 303
      follow_redirect!
      last_response.body.match('Passiflora acutissima').should be_false
      count = 10
      while count > 0
        get(last_request.url)
        r = last_response
        r.status.should == 200
        r.body.match('Passiflora acutissima').should be_true if count == 1
        break if r.body.match('Passiflora acutissima')
        sleep(5)
        count -= 1
      end
    end
  end
  
  it "API should return an identifiedName element for found abbreviations" do
    file = File.join(File.dirname(__FILE__), 'files', 'abbreviations.txt')
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :file => Rack::Test::UploadedFile.new(file, 'text/plain'), :engine => 0)
      last_response.status.should == 303
      follow_redirect!
      last_response.body.match('identifiedName').should be_false
      count = 10
      while count > 0
        get(last_request.url)
        r = last_response
        r.body.match('identifiedName').should be_true if count == 1
        r.body.match('Pardosa distincta').should be_true if count == 1
        r.body.match('P. distincta').should be_true if count == 1
        break if r.body.match('identifiedName')
        sleep(5)
        count -= 1
      end
    end
  end

  it "should properly handle abbreviations" do
    text = 'Pardosa moesta is the name of the spider and the abbreviation is P. moesta. A few more spiders are called P. distincta, P. moiica, and P. xerampelina. Another genus is Plexippus and its species are P. purpuratus.'
    post("/name_finder", :format => 'json', :text => text, :engine => 0)
    last_response.status.should == 303
    follow_redirect!
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.status.should == 200
      res = JSON.parse(r.body, :symbolize_names => true)[:names]
      if res
        res.should == [{:verbatim=>"Pardosa moesta", :scientificName=>"Pardosa moesta", :offsetStart=>0, :offsetEnd=>13, :identifiedName=>"Pardosa moesta"}, {:verbatim=>"P. moesta", :scientificName=>"Pardosa moesta", :offsetStart=>65, :offsetEnd=>73, :identifiedName=>"P. moesta"}, {:verbatim=>"P. distincta", :scientificName=>"Pardosa distincta", :offsetStart=>106, :offsetEnd=>117, :identifiedName=>"P. distincta"}, {:verbatim=>"P. moiica", :scientificName=>"P. moiica", :offsetStart=>120, :offsetEnd=>128, :identifiedName=>"P. moiica"}, {:verbatim=>"P. xerampelina", :scientificName=>"Pardosa xerampelina", :offsetStart=>135, :offsetEnd=>148, :identifiedName=>"P. xerampelina"}, {:verbatim=>"Plexippus", :scientificName=>"Plexippus", :offsetStart=>168, :offsetEnd=>176, :identifiedName=>"Plexippus"}, {:verbatim=>"P. purpuratus", :scientificName=>"Plexippus purpuratus", :offsetStart=>198, :offsetEnd=>210, :identifiedName=>"P. purpuratus"}]
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "should properly dedup names when both engines are used" do
    text = 'The Structure of Meteridium (Actinoloba) marginata Milne-Edw. with special reference to its neuro-muscular mechanism. Jour.'
    post("/name_finder", :format => 'json', :text => text, :unique => true)
    last_response.status.should == 303
    follow_redirect!
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.status.should == 200
      res = JSON.parse(r.body, :symbolize_names => true)[:names]
      if res
        res.size.should == 1
        res[0].should == {:verbatim=>"Meteridium (Actinoloba) marginata", :scientificName=>"Meteridium (Actinoloba) marginata", :identifiedName=>"Meteridium (Actinoloba) marginata"}
        break
      end
      sleep(5)
      count -= 1
    end
  end
  
  it "should use TaxonFinder exclusively if language of large text is not English" do
    text = open(File.join(File.dirname(__FILE__), 'files', 'french.txt')).read
    post("/name_finder", :format => 'json', :text => text, :engine => 0)
    last_response.status.should == 303
    follow_redirect!
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.status.should == 200
      res = JSON.parse(r.body, :symbolize_names => true)
      if res[:names]
        res[:names].size.should == 1
        res[:engines].should == ['TaxonFinder']
        res[:english].should == false
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "should use both engines if language detection is disabled" do
    text = open(File.join(File.dirname(__FILE__), 'files', 'french.txt')).read
    post("/name_finder", :format => 'json', :text => text, :engine => 0, :detect_language => false)
    last_response.status.should == 303
    follow_redirect!
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.status.should == 200
      res = JSON.parse(r.body, :symbolize_names => true)
      if res[:names]
        res[:names].size.should == 2
        res[:engines].should == ["TaxonFinder", "NetiNeti"]
        res[:english].should == false
        break
      end
      sleep(5)
      count -= 1
    end
  end

  it "should use both engines as requested if language of text is English" do
    text = open(File.join(File.dirname(__FILE__), 'files', 'abbreviations.txt')).read
    post("/name_finder", :format => 'json', :text => text, :engine => 0)
    last_response.status.should == 303
    follow_redirect!
    count = 10
    while count > 0
      get(last_request.url)
      r = last_response
      r.status.should == 200
      res = JSON.parse(r.body, :symbolize_names => true)
      if res[:names]
        res[:names].size.should == 3
        res[:engines].should == ["TaxonFinder", "NetiNeti"]
        res[:english].should == true
        break
      end
      sleep(5)
      count -= 1
    end
  end

end
