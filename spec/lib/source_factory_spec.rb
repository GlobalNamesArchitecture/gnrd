describe Gnrd::SourceFactory do
  describe ".factory" do
    let(:not_file) { "whateva" }
    let(:utf) { __dir__ + "/../files/french.txt" }
    let(:ascii) { __dir__ + "/../files/ascii.txt" }
    let(:utf16) { __dir__ + "/../files/utf16.txt" }
    let(:latin1) { __dir__ + "/../files/latin1.txt" }
    let(:jpg) { __dir__ + "/../files/image.jpg" }
    let(:pdf) { __dir__ + "/../files/file.pdf" }
    let(:image_pdf) { __dir__ + "/../files/image.pdf" }

    it "raises an error when file is not found" do
      expect { subject.factory(not_file) }.to raise_error Gnrd::FileMissingError
    end

    it "returns TextFile for ascii texts" do
      expect(subject.factory(ascii)).to be_kind_of Gnrd::TextFile
    end

    it "returns TextFile for utf-8 texts" do
      expect(subject.factory(utf)).to be_kind_of Gnrd::TextFile
    end

    it "raises an error for utf-16 encoding" do
      expect { subject.factory(utf16) }.to raise_error TypeError
    end

    it "raises an error for latin1 encodings" do
      expect { subject.factory(latin1) }.to raise_error TypeError
    end

    it "returns PdfFile for text pdf" do
      expect(subject.factory(pdf)).to be_kind_of Gnrd::PdfFile
    end

    it "returns PdfFile for image pdf" do
      expect(subject.factory(image_pdf)).to be_kind_of Gnrd::PdfFile
    end

    it "returns ImageFile for image" do
      expect(subject.factory(jpg)).to be_kind_of Gnrd::ImageFile
    end
  end
end
