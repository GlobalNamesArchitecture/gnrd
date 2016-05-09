describe Gnrd::NameFinderEngine do
  include_context "shared_context"
  subject { Gnrd::NameFinderEngine }

  describe ".new" do
    it "creates new instance" do
      expect(subject.new(utf_dossier)).to be_kind_of(Gnrd::NameFinderEngine)
      expect(subject.new(utf_dossier).dossier).to be_kind_of(Gnrd::Dossier)
    end

    it "takes options" do
      opts = { netineti: false }
      nf = subject.new(utf_dossier, opts)
      expect(nf.options[:netineti]).to be false
      nf = subject.new(utf_dossier)
      expect(nf.options[:netineti]).to be true
    end
  end

  describe "#find" do
    it "finds names in a text" do
      nf = subject.new(pdf_txt_dossier)
      names = nf.find
      expect(names).to be_kind_of Gnrd::NamesCollection
    end

    it "returns combined found names correctly" do
      nf =  subject.new(reptile_dossier)
      names = nf.find.combine
      expect(names).to be_kind_of Gnrd::NamesCollection
      sci_names = names.combined.map { |n| n[:scientificName] }
      expect(sci_names).to eq %w(Mammalia Aves Reptilia)
    end
  end
end
