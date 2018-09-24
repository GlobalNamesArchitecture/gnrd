# frozen_string_literal: true

describe Gnrd::Dossier do
  include_context "shared_context"
  subject { Gnrd::Dossier }

  describe ".new" do
    it "creates a dossier on a file" do
      d = subject.new(file: { path: utf_path })
      expect(d).to be_kind_of subject
      expect(d.file).to eq(path: utf_path)
      expect(d.text).to eq({})
    end

    it "creates a dossier on a string" do
      d = subject.new(text: { orig: utf_txt })
      expect(d).to be_kind_of subject
      expect(d.file).to eq({})
      expect(d.text).to eq(orig: utf_txt)
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
      expect(utf_dossier.file[:path]).to eq utf_path
    end

    it "writes data" do
      expect(utf_dossier.file[:type]).to be_nil
      utf_dossier.file(type: "text_file")
      expect(utf_dossier.file[:type]).to eq "text_file"
    end
  end

  describe "#file" do
    it "reads data" do
      expect(utf_txt_dossier.text[:orig]).to eq utf_txt
    end

    it "writes data" do
      expect(utf_txt_dossier.text[:encoding]).to be_nil
      utf_txt_dossier.text(encoding: "utf-8")
      expect(utf_txt_dossier.text[:encoding]).to eq "utf-8"
    end
  end
end
