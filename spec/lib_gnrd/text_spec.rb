# encoding: utf-8

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

    it "returns empty string from unknown file" do
      expect(subject.new(binary_dossier).text_orig).to eq ""
    end
  end

  describe "#text_norm" do
    it "returns normalized text" do
      pdf = subject.new(pdf_dossier)
      norm = pdf.text_norm
      expect(norm).to match("Tacsonia ×rosea")
    end

    it "normalizes latin1" do
      latin1 = subject.new(latin1_dossier)
      expect(latin1.text_norm.encoding.to_s).to eq "UTF-8"
      expect(latin1.text_norm)
        .to match("Ujvárosi and Bálint 2012")
    end

    it "normalizes html" do
      html = subject.new(html_dossier)
      norm = html.text_norm
      expect(html.text_orig).to match(%r{</html>})
      expect(norm).to_not match(%r{</html>})
    end

    it "normalizes xml" do
      xml = subject.new(xml_dossier)
      norm = xml.text_norm
      expect(xml.text_orig).to match(%r{</article>})
      expect(norm).to_not match(%r{</article>})
    end

    it "normalizes utf-16" do
      utf16 = subject.new(utf16_dossier)
      norm = utf16.text_norm
      expect(norm).to match(/Algérie un plus/)
      expect(norm.encoding.to_s).to eq "UTF-8"
    end

    it "normalizes unknown" do
      binary = subject.new(binary_dossier)
      expect(binary.text_norm).to eq ""
    end
  end
end
