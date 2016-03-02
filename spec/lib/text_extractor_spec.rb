describe Gnrd::TextExtractor do
  subject { Gnrd::TextExtractor }
  let(:pdf) { __dir__ + "/../files/file.pdf" }
  let(:image_pdf) { __dir__ + "/../files/image.pdf" }
  let(:jpg) { __dir__ + "/../files/image.jpg" }

  describe ".new" do
    it "creates instance" do
      expect(subject.new("pdf", pdf)).to be_kind_of Gnrd::TextExtractor
    end
  end

  describe "#text" do
    it "gets text from pdf" do
      expect(subject.new("pdf", pdf).text).to match(/ISSN: 0211-1322/)
    end

    it "gets text from scanned pdf" do
      expect(subject.new("pdf", image_pdf).text)
        .to match(/Baccha elongata 7-10 mm/)
    end
  end
end
