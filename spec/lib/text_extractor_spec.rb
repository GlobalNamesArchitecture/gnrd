describe Gnrd::TextExtractor do
  subject { Gnrd::TextExtractor }
  let(:pdf) { __dir__ + "/../files/file.pdf" }
  let(:image_pdf) { __dir__ + "/../files/image.pdf" }
  let(:jpg) { __dir__ + "/../files/image.jpg" }
  let(:jpg_txt) { File.read(__dir__ + "/../files/txt/image.jpg.txt") }
  let(:pdf_txt) { File.read(__dir__ + "/../files/txt/file.pdf.txt") }

  describe ".new" do
    it "creates instance" do
      expect(subject.new(pdf, "pdf")).to be_kind_of Gnrd::TextExtractor
    end
  end

  describe "#text" do
    it "gets text from pdf" do
      f = open("/tmp/f.txt", "w")
      f.write(subject.new(pdf, "pdf").text)
      f.close
      expect(subject.new(pdf, "pdf").text).to eq pdf_txt
    end

    it "gets text from scanned pdf" do
      expect(subject.new(image_pdf, "pdf").text).to eq jpg_txt
    end

    it "gets text from image" do
      expect(subject.new(jpg).text).to eq jpg_txt
    end
  end
end
