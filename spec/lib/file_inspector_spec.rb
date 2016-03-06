describe Gnrd::FileInspector do
  include_context "shared_context"
  subject { Gnrd::FileInspector }

  describe ".inspect" do
    it "breaks if path is fake" do
      expect { subject.info("fake/path") }.to raise_error Gnrd::FileMissingError
    end

    it "breaks if path is not a string" do
      expect { subject.info(11) }.to raise_error TypeError
    end

    it "finds text_file" do
      expect(subject.info(utf_path))
        .to eq(magic: "UTF-8 Unicode text", type: "text_file")
      expect(subject.info(ascii_path))
        .to eq(magic: "ASCII text", type: "text_file")
      expect(subject.info(latin1_path))
        .to eq(magic: "ISO-8859 text", type: "text_file")
    end

    it "finds pdf_file" do
      expect(subject.info(pdf_path))
        .to eq(magic: "PDF document, version 1.6", type: "pdf_file")
      expect(subject.info(pdf_img_path))
        .to eq(magic: "PDF document, version 1.2", type: "pdf_file")
    end

    it "finds image" do
      expect(subject.info(img_path))
        .to eq(magic: "JPEG image data, JFIF standard 1.02", type: "image_file")
    end

    it "marks other files as unknown" do
      expect(subject.info(binary_path)[:magic]).to match(/ELF 64-bit LSB/)
      expect(subject.info(binary_path)[:type]).to eq "unknown_file"
    end
  end
end
