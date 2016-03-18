describe Params do
  subject { Params }

  describe ".new" do
    it "creates and instance" do
      expect(subject.new({})).to be_kind_of subject
    end
  end

  describe "#normalize" do
    let(:params1) do
      { preferred_data_sources: "1|2", engine: 2,
        format: "json ", aparam: "one two" }
    end
    let(:params2) do
      { preferred_data_sources: [1, 3], engine: "1",
        format: "xml", file: "/usr/bin/file" }
    end
    let(:params3) do
      { preferred_data_sources: "some|nonsense", engine: "whaa?",
        detect_language: "false\n ", verbatim: true, unique: "whaa?",
        format: "klenon" }
    end
    let(:params4) { { find: { detect_language: false } } }

    it "does not remove params which are not normalized" do
      prm = subject.new(params1).normalize
      expect(prm[:aparam]).to eq "one two"
    end

    it "moves source fields under :sources" do
      expect(params2[:file]).to eq "/usr/bin/file"
      prm = subject.new(params2).normalize
      expect(prm[:file]).to be nil
      expect(prm[:source][:file]).to eq "/usr/bin/file"
    end

    it "deals with booleans" do
      prm = subject.new(params3).normalize
      expect(prm[:verbatim]).to be true
      expect(prm[:unique]).to be true
      expect(prm[:return_content]).to be false
    end

    it "deals with detect_language false param" do
      prm = subject.new(params3).normalize
      expect(prm[:detect_language]).to be false
      prm = subject.new(params4).normalize
      expect(prm[:detect_language]).to be false
    end

    it "sets detect_language to true by default" do
      prm = subject.new(params2).normalize
      expect(prm[:detect_language]).to be true
    end

    it "normalizes format" do
      expect(subject.new(params1).normalize[:format]).to eq "json"
      expect(subject.new(params2).normalize[:format]).to eq "xml"
      expect(subject.new(params3).normalize[:format]).to eq "html"
      expect(subject.new(params4).normalize[:format]).to eq "html"
    end

    it "normalizes engine" do
      expect(subject.new(params1).normalize[:engine]).to be 2
      expect(subject.new(params2).normalize[:engine]).to be 1
      expect(subject.new(params3).normalize[:engine]).to be 0
      expect(subject.new(params4).normalize[:engine]).to be 0
    end

    it "normalizes data sources" do
      expect(subject.new(params1).normalize[:preferred_data_sources])
        .to eq [1, 2]
      expect(subject.new(params2).normalize[:preferred_data_sources])
        .to eq [1, 3]
      expect(subject.new(params3).normalize[:preferred_data_sources])
        .to eq []
      expect(subject.new(params4).normalize[:preferred_data_sources])
        .to eq []
    end
  end
end
