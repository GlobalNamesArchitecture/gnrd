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
  let(:utf) { __dir__ + "/../files/french.txt" }
  let(:ascii) { __dir__ + "/../files/ascii.txt" }
  let(:pdf) { __dir__ + "/../files/file.pdf" }
  let(:image) { __dir__ + "/../files/image.jpg" }
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
      expect { subject.new(image) }.to raise_error TypeError
    end
  end

  describe "#text" do
    it "returns text of the file" do
      expect(subject.new(ascii).text).to match("Noeclytus pusillus")
    end
  end
end
