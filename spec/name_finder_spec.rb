# encoding: utf-8
require_relative "./spec_helper"

describe NameFinder do 
  before(:all) do 
    @nf = NameFinder.create(:input => "We know many scientific names. For example Plantago major and Pardosa moesta!", :unique => false, :format => 'json')
    @nf.should_not be_nil
    @nf.format.should == 'json'
    @names = JSON.parse(open(File.join(File.dirname(__FILE__), 'files', 'dirty_names.json')).read, :symbolize_names => true)
  end

  it "should process netineti names" do 
    names = @nf.process_netineti_names(@names)
    names.map {|n| n[:scientificName]}.should == {}
  end
end
