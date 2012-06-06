# encoding: utf-8
require_relative "./spec_helper"

describe NameFinder do 
  before(:all) do 
    @nf = NameFinder.create(:input => "We know many scientific names. For example Plantago major and Pardosa moesta!", :unique => false, :format => 'json')
    @nf.should_not be_nil
    @nf.format.should == 'json'
  end

end
