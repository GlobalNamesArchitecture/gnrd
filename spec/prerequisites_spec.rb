# encoding: utf-8
require_relative "./spec_helper"

#checking if we have connections to TaxonFinder, NetiNeti, and Resque Worker

describe "TaxonFinder Connector" do
  it "should create TaxonFinder client" do
    tf_client = NameSpotter::TaxonFinderClient.new()
    tf_client.should_not be_nil
    tf_client.class.should == NameSpotter::TaxonFinderClient
    tf_client.socket.class.should == TCPSocket
  end
end

describe "NetiNeti Connector" do
  it "should create NetiNeti client" do
    nn_client = NameSpotter::NetiNetiClient.new()
    nn_client.should_not be_nil
    nn_client.class.should == NameSpotter::NetiNetiClient
    names = nn_client.find("Plantago major foreva!!!")
    names[0].verbatim.should == "Plantago major foreva" 
    #hopefully we will fix that netineti's relaxed infraspecies finds
  end
end

describe "Resque worker" do
  it "should check if worker is running" do
   Resque.workers.select {|w| w.queues.include? "name_finder"}.should_not be_empty
  end
end
