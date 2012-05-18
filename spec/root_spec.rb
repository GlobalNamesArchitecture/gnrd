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
  it "should redirect/point to API page, if there are no parameters" 

  it "should be able to find names in a submitted utf-8 text" do
    text = URI.encode('Betula alba Beçem')
    post "/name_finder?input=#{text}&engine=0"
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("Betula alba").should be_true
  end

  it "should be able to find names in a url" do 
    url = URI.encode("http://eol.org/pages/207212/overview")
    post "/name_finder?engine=0&unique=true&url=#{url}"
    follow_redirect!
    r = last_response
    r.status.should == 200
    r.body.match("Epinephelus drummondhayi").should be_true
    r.body.match("http://eol.org/pages/207212/overview").should be_true
  end
end
