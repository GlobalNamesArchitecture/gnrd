require_relative "./spec_helper"

describe "/" do 
  it "should open home page" do
    get "/"
    require 'ruby-debug'; debugger
    puts ''
  end
end
