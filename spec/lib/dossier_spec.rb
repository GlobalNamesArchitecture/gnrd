describe Gnrd::Dossier do
  let(:utf) { __dir__ + "/../files/french.txt" }
  let(:utf_txt) { File.open(utf) }
  let(:dfile) { subject.new(file: { path: utf }) }
  let(:dtext) { subject.new(text: { orig: utf_txt }) }
  subject { Gnrd::Dossier }

  describe ".new" do
    it "creates a dossier on a file" do
      d = subject.new(file: { path: :utf })
      expect(d).to be_kind_of subject
      expect(d.file).to eq(path: :utf)
      expect(d.text).to eq({})
    end

    it "creates a dossier on a string" do
      d = subject.new(text: { orig: :utf_txt })
      expect(d).to be_kind_of subject
      expect(d.file).to eq({})
      expect(d.text).to eq(orig: :utf_txt)
    end

    it "creates empty dossier without" do
      d = subject.new
      expect(d).to be_kind_of subject
      expect(d.file).to eq({})
      expect(d.text).to eq({})
    end

    it "creates empty dossier with irrelevant input" do
      d = subject.new(birds: true)
      expect(d).to be_kind_of subject
      expect(d.file).to eq({})
      expect(d.text).to eq({})
    end
  end

  describe "#file" do
    it "reads data" do
      expect(dfile.file[:path]).to eq utf
    end

    it "writes data" do
      expect(dfile.file[:type]).to be_nil
      dfile.file(type: "text_file")
      expect(dfile.file[:type]).to eq "text_file"
    end
  end

  describe "#file" do
    it "reads data" do
      expect(dtext.text[:orig]).to eq utf_txt
    end

    it "writes data" do
      expect(dtext.text[:encoding]).to be_nil
      dtext.text(encoding: "utf-8")
      expect(dtext.text[:encoding]).to eq "utf-8"
    end
  end
end
