describe Gnrd::FileInspector do
  let(:utf) { __dir__ + "/../files/french.txt" }
  let(:ascii) { __dir__ + "/../files/ascii.txt" }
  let(:latin1) { __dir__ + "/../files/latin1.txt" }
  let(:pdf) { __dir__ + "/../files/file.pdf" }
  let(:image_pdf) { __dir__ + "/../files/image.pdf" }
  let(:image) { __dir__ + "/../files/image.jpg" }
  let(:binary) { __dir__ + "/../files/binary" }
  subject { Gnrd::FileInspector }

  describe ".inspect" do
    it "breaks if path is fake" do
      expect { subject.info("fake/path") }.to raise_error Gnrd::FileMissingError
    end

    it "breaks if path is not a string" do
      expect { subject.info(11) }.to raise_error TypeError
    end

    it "finds text_file" do
      expect(subject.info(utf)).to eq(magic: "UTF-8 Unicode text",
                                      type: "text_file")
      expect(subject.info(ascii)).to eq(magic: "ASCII text", type: "text_file")
      expect(subject.info(latin1)).to eq(magic: "ISO-8859 text",
                                         type: "text_file")
    end

    it "finds pdf_file" do
      expect(subject.info(pdf)).to eq(magic: "PDF document, version 1.6",
                                      type: "pdf_file")
      expect(subject.info(image_pdf)).to eq(magic: "PDF document, version 1.2",
                                            type: "pdf_file")
    end

    it "finds image" do
      expect(subject.info(image))
        .to eq(magic: "JPEG image data, JFIF standard 1.02", type: "image_file")
    end

    it "marks other files as unknown" do
      expect(subject.info(binary)).to eq(
        magic: "ELF 64-bit LSB  executable, x86-64, version 1 (SYSV), " \
               "dynamically linked (uses shared libs), for GNU/Linux 2.6.32, " \
               "BuildID[sha1]=b1d6e1509704208218820b836618ecc624df836c, " \
               "not stripped", type: "unknown_file"
      )
    end
  end
end
