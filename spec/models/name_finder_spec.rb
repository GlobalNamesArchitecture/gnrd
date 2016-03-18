describe NameFinder do
  subject { NameFinder }

  describe ".new" do
    it "creates instance" do
      expect(subject.new).to be_kind_of subject
    end
  end

  describe ".token" do
    it "creates a token" do
      expect(subject.token).to match(/^[0-9a-z]{10}$/)
    end
  end

  describe ".create" do
    it "populates id, token" do
      nf = subject.create
      expect(nf.id).to be > 0
      expect(nf.id).to be_kind_of Fixnum
      expect(nf.token).to match(/^[0-9a-z]{10}$/)
    end

    it "saves parameters" do
      token = subject
              .create(params: { format: "json", text: "Pardosa moesta" }).token
      expect(subject.find_by_token(token).params)
        .to eq(engine: 0, format: "json", source: { text: "Pardosa moesta" },
               unique: false, verbatim: false, return_content: false,
               best_match_only: false, detect_language: true,
               all_data_sources: false, data_source_ids: [],
               preferred_data_sources: [])
    end
  end
end
