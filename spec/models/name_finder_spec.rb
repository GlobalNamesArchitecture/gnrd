# frozen_string_literal: true

describe NameFinder do
  subject { NameFinder }
  let(:params) { { format: "json", text: "Pardosa moesta" } }

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
      nf = subject.create(params: params)
      expect(nf.id).to be > 0
      expect(nf.id).to be_kind_of Integer
      expect(nf.token).to match(/^[0-9a-z]{10}$/)
    end

    it "saves parameters" do
      token = subject
              .create(params: { format: "json", text: "Pardosa moesta" }).token
      expect(subject.find_by_token(token).params)
        .to eq(source: { text: "Pardosa moesta" },
               unique: false,
               return_content: false,
               with_verification: false,
               preferred_data_sources: [],
               detect_language: false,
               format: "json",
               engine: 0,
               no_bayes: false)
    end
  end
end
