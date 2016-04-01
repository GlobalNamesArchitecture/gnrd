describe Gnrd::TextExtractor do
  subject { Gnrd::TextExtractor }
  let(:pdf) { __dir__ + "/../files/file.pdf" }
  let(:image_pdf) { __dir__ + "/../files/image.pdf" }
  let(:jpg) { __dir__ + "/../files/image.jpg" }
  let(:jpg_txt) { "Baccha el.ngata 7-10" }
  let(:pdf_txt) { File.read(__dir__ + "/../files/txt/file.pdf.txt") }

  describe ".new" do
    it "creates instance" do
      expect(subject.new(pdf)).to be_kind_of Gnrd::TextExtractor
    end
  end

  describe "#text" do
    it "gets text from pdf" do
      expect(subject.new(pdf).text).to eq pdf_txt
    end

    it "gets text from scanned pdf" do
      expect(subject.new(image_pdf).text).to match(jpg_txt)
    end

    it "gets text from image" do
      expect(subject.new(jpg).text).to match(jpg_txt)
    end
  end
end
