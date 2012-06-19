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
    names.map {|n| n[:scientificName]}.should == ["Generilfus quod tentavi", "Melgii jingha", "Planta cauadenfes propcdlcm", "Curcuma radicelohga", "Panicnln denfayfiaccida", "Europa rivulos", "Europae hortis arvisque", "Adhatoda fpicata", "Caules angulati pedale", "Folia latq-pvata apice", "H. 9 ionium", "Yjndihumiiyus", "Sauiuru arborefccns fiudu", "Saururus arborefceiis foliis", "Valeriana dioica", "Valeriana alpina minor", "Berimidiana cgpcjifi capitulis", "Gramen eriophorum africanum", "I. theatr", "A. nglia", "Acaulis foliis", "Cramen nemorofum panrculis", "Calycibns unif-oris carina fcabris", "Fejlsca ovina", "Vlmtn rigida", "Jltpulds quttiis", "S. ii - v", "Scabiofa (iellata", "Hifpania maritimls lapidofis", "Panicula rarior fere", "Europx ( ultis", "Pctala 4 oblonga", "I. jf", "Qvata teriiiiaante", "Flores liacemum", "Turpitlum v -mcmbranaceo", "Ainerica vulgaris", "Ukckcngi indicum glab ui r-chenopodii", "Lcvifaiius africanusericx", "Polygonuni mlnu caiidicans", "Folia alfcrnafparfa", "Scammoniis monrpeliaca affinis", "Apocymim (olio fubfotimdo", "Apocynum latifblium", "Apocynum canadenfe foliis", "Cali bacciferum foliis", "Dlmiatts acutis multifidis", "Ixvr genlculis", "Gallia) 2 tjj", "Rhus folirsternatis foliolis", "Tinus lylycflris", "Europa aujlralioris fcpihus", "Italia l i -li y"]
  end
end
