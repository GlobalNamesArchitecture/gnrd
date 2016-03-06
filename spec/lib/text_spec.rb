describe Gnrd::Text do
  include_context "shared_context"
  subject { Gnrd::Text }

  describe ".new" do
    it "creates an instance from dossier" do
      ts = subject.new(utf_dossier)
      expect(ts).to be_kind_of(subject)
      expect(ts.dossier).to be_kind_of(Gnrd::Dossier)
    end

    it "fails creating an instance with string" do
      expect { subject.new("hello") }.to raise_error TypeError
    end
  end

  describe "#text_orig" do
    it "returns the text from source verbatim" do
      expect(subject.new(utf_txt_dossier).text_orig).to eq utf_txt
      # utf has the same original text as utf_txt, so we can say
      expect(subject.new(utf_dossier).text_orig).to eq utf_txt
    end
  end
end
