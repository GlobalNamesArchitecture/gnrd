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

describe "/name_finder" do
  def get_url(text)
    is_xml = !!text.match(/<\?xml.*version.*>/)
    if is_xml
      text.match(/<url>([^<]*)<\/url>/)[1]
    else
      JSON.load(text)["url"]
    end
  end

  it "should redirect if there are no parameters" do
    get "/name_finder"
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
  end
  
  it "should give warning when a URL is not found" do
    url = URI.encode("http://eol.org/pages/a/overview")
    get "/name_finder?url=#{url}"
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("That URL was inaccessible.").should be_true
  end
  
  it "should be able to find names in a URL as a parameter" do
    url = URI.encode("http://eol.org/pages/207212/overview")
    get "/name_finder?url=#{url}"
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("Epinephelus drummondhayi").should be_true
  end

  it "should be able to find names in text as a parameter" do
    text = URI.encode('Betula alba Beçem')
    get "/name_finder?text=#{text}"
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("Betula alba").should be_true
  end

  it "should be able to find names in a URL" do 
    url = "http://eol.org/pages/207212/overview"
    post("/name_finder", :engine => 0, :unique => true, :url => url)
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("Epinephelus drummondhayi").should be_true
    r.body.match("http://eol.org/pages/207212/overview").should be_true
  end
  
  it "should be able to find names in a submitted utf-8 text" do
    text = 'Betula alba Beçem'
    post("/name_finder", :text => text, :engine => 0)
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("Betula alba").should be_true
  end

  it "should be able to find names in an uploaded file" do
    utf_text_file = File.join(SiteConfig.root_path, 'spec', 'files', 'utf_names.txt')
    post('/name_finder', :file => Rack::Test::UploadedFile.new(utf_text_file, 'text/plain'))
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("Plantago major").should be_true
    r.body.match("Pomatomus saltator").should be_true
  end

  it "should be able to find names in image" do
    image_file = File.join(SiteConfig.root_path, 'spec', 'files', 'image.jpg')
    post('/name_finder', :file => Rack::Test::UploadedFile.new(image_file, 'image/jpeg'))
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match('Pseudodoros').should be_true
    r.body.match('Ocyptamus').should be_true
  end
  
  it "should be able to find names in PDF" do
    pdf_file = File.join(SiteConfig.root_path, 'spec', 'files', 'file.pdf')
    post('/name_finder', :file => Rack::Test::UploadedFile.new(pdf_file, 'application/pdf'), :engine => 2)
    last_response.status.should == 302
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match('Passiflora pilosicorona').should be_true
  end

  it "API should return correct http respsonse code if there are no parameters" do
    get "/name_finder.json"
    last_response.status.should == 400
  end
  
  it "API should be able to find names in a small submitted utf-8 text" do
    text = 'Betula alba Beçem'
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :text => text, :engine => 0)
      r = last_response
      r.status.should == 200
      r.body.match("Betula alba").should be_true
    end
  end
  
  it "API should be able to find names in a BIG submitted utf-8 text" do
    text = open(File.join(File.dirname(__FILE__), 'files', 'big.txt')).read
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :text => text, :engine => 0)
      r = last_response
      url = get_url(r.body)
      r.status.should == 200
      r.body.match('Passiflora acutissima').should be_false
      count = 10
      while count > 0
        get(url)
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
      r = last_response
      status_url = get_url(r.body)
      r.status.should == 200
      r.body.match('Epinephelus drummondhayi').should be_false
      count = 10
      while count > 0
        get(status_url)
        r = last_response
        r.body.match('Epinephelus drummondhayi').should be_true if count == 1
        if r.body.match('Epinephelus drummondhayi')
          r.body.match('Epinephelus drummondhayi').should be_true
          break
        end
        sleep(5)
        count -= 1
      end
    end
  end
  
  it "API should be able to find names in a text file" do
    file = File.join(File.dirname(__FILE__), 'files', 'big.txt')
    ['xml', 'json'].each do |format|
      post("/name_finder", :format => format, :file => Rack::Test::UploadedFile.new(file, 'text/plain'), :engine => 0)
      r = last_response
      url = get_url(r.body)
      r.status.should == 200
      r.body.match('Passiflora acutissima').should be_false
      count = 10
      while count > 0
        get(url)
        r = last_response
        r.status.should == 200
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
      r = last_response
      url = get_url(r.body)
      r.status.should == 200
      r.body.match('Pseudodoros').should be_false
      count = 10
      while count > 0
        get(url)
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
      r = last_response
      url = get_url(r.body)
      r.status.should == 200
      r.body.match('Passiflora acutissima').should be_false
      count = 10
      while count > 0
        get(url)
        r = last_response
        r.status.should == 200
        r.body.match('Passiflora acutissima').should be_true if count == 1
        break if r.body.match('Passiflora acutissima')
        sleep(5)
        count -= 1
      end
    end
  end

end
