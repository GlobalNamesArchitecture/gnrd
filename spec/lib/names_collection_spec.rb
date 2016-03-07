describe Gnrd::NamesCollection do
  include_context "shared_context"
  subject { Gnrd::NamesCollection }

  describe ".new" do
    it "creates an instance" do
      nc = subject.new(names_nn_tt)
      expect(nc).to be_kind_of subject
      expect(nc.names_raw.keys).to eq [:tf, :nn]
      expect(nc.names_raw[:nn]).to be_kind_of Array
    end
  end

  describe "#combine" do
    it "gets back combination of tf and nn results" do
      nc = subject.new(names_nn_tt).combine
      expect(nc.combined[0].keys.sort)
        .to eq %i(engine offsetEnd offsetStart scientificName size verbatim)
    end
  end
end
