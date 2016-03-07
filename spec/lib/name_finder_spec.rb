describe Gnrd::NameFinder do
  include_context "shared_context"
  subject { Gnrd::NameFinder }

  describe ".new" do
    it "creates new instance" do
      expect(subject.new(utf_dossier)).to be_kind_of(Gnrd::NameFinder)
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
      expect(names).to be_kind_of Hash
    end
  end
end
