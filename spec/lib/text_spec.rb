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
    it "returns the text from utf sources verbatim" do
      expect(subject.new(utf_txt_dossier).text_orig).to eq utf_txt
      expect(subject.new(utf_dossier).text_orig).to eq utf_txt
    end

    it "returns the text from ascii sources verbatim" do
      expect(subject.new(ascii_dossier).text_orig).to eq ascii_txt
    end

    it "returns text from image" do
      expect(subject.new(img_dossier).text_orig)
        .to match(/Baccha el.ngata 7-10/)
    end

    it "returns empty text from no text image" do
      expect(subject.new(img_no_names_dossier).text_orig.strip).to eq ""
    end

    it "returns text from pdf" do
      expect(subject.new(pdf_dossier).text_orig).to be_kind_of(String)
    end

    it "returns text from image pdf" do
      expect(subject.new(pdf_img_dossier).text_orig)
        .to match(/Baccha el.ngata 7-10/)
    end

    it "returns nil from unknown file" do
      expect(subject.new(binary_dossier).text_orig).to eq ""
    end
  end

  describe "#text_norm" do
    it "returns normalized text" do
      pdf = subject.new(pdf_dossier)
      expect(pdf.text_norm.encoding.to_s).to eq "UTF-8"
      expect(pdf.text_orig).to_not eq pdf.text_norm
    end
  end
end
