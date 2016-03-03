# Texts can come from a variety of sources: strings, text files, pdf text
# files, scanned pdfs, images, html pages.:w

describe "sources of texts" do
  let(:utf) { __dir__ + "/../files/french.txt" }
  let(:ascii) { __dir__ + "/../files/ascii.txt" }
  let(:pdf) { __dir__ + "/../files/file.pdf" }
  let(:image_pdf) { __dir__ + "/../files/image.pdf" }
  let(:jpg) { __dir__ + "/../files/image.jpg" }
  let(:jpg_no_txt) { __dir__ + "/../files/no_names.jpg" }
  let(:pdf_txt) { File.read(__dir__ + "/../files/txt/file.pdf.txt") }
  let(:image_pdf_txt) { /Baccha el.ngata 7-10/ }

  describe Gnrd::TextString do
    let(:txt) { "Hello world" }
    subject { Gnrd::TextString }

    describe ".new" do
      it "creates an instance" do
        expect(subject.new(txt)).to be_kind_of(Gnrd::TextString)
      end

      it "raises error for non-strings" do
        expect { subject.new(123) }.to raise_error TypeError
      end
    end

    describe "#text" do
      it "returns the string" do
        expect(subject.new(txt).text).to eq txt
      end
    end
  end

  describe Gnrd::TextFile do
    subject { Gnrd::TextFile }

    describe ".new" do
      it "creates an instance" do
        expect(subject.new(utf)).to be_kind_of(Gnrd::TextFile)
      end

      it "raises error if file is not found" do
        expect { subject.new("not-a-path") }.to raise_error TypeError
      end

      it "it accepts ascii files" do
        expect(subject.new(ascii)).to be_kind_of(Gnrd::TextFile)
      end

      it "raises error with pdf" do
        expect { subject.new(pdf) }.to raise_error TypeError
      end

      it "raises error with image" do
        expect { subject.new(jpg) }.to raise_error TypeError
      end
    end

    describe "#text" do
      it "returns text of the file" do
        expect(subject.new(ascii).text).to match("Noeclytus pusillus")
      end
    end
  end

  describe Gnrd::PdfFile do
    subject { Gnrd::PdfFile }

    describe ".new" do
      it "creates instance from text pdf" do
        expect(subject.new(pdf)).to be_kind_of Gnrd::PdfFile
      end

      it "creates instance from scanned pdf" do
        expect(subject.new(image_pdf)).to be_kind_of Gnrd::PdfFile
      end

      it "raises error with image" do
        expect { subject.new(jpg) }.to raise_error TypeError
      end

      it "raises error with text file" do
        expect { subject.new(ascii) }.to raise_error TypeError
      end

      it "raises error with string" do
        expect { subject.new("ascii") }.to raise_error TypeError
      end
    end

    describe "#text" do
      it "gets text from pdf" do
        expect(subject.new(pdf).text).to eq pdf_txt
      end

      it "gets text from scanned pdf" do
        expect(subject.new(image_pdf).text).to match(image_pdf_txt)
      end
    end
  end

  describe Gnrd::ImageFile do
    subject { Gnrd::ImageFile }

    describe ".new" do
      it "creates instance" do
        expect(subject.new(jpg)).to be_kind_of Gnrd::ImageFile
      end

      it "raises error with string" do
        expect { subject.new("hello") }.to raise_error TypeError
      end

      it "raises error with pdf" do
        expect { subject.new(pdf) }.to raise_error TypeError
      end

      it "raises error with test file" do
        expect { subject.new(utf) }.to raise_error TypeError
      end
    end

    describe "#text" do
      it "extracts text from images" do
        expect(subject.new(jpg).text).to match(image_pdf_txt)
      end

      it "deals with images without text" do
        expect(subject.new(jpg_no_txt).text.strip).to eq ""
      end
    end
  end
end
