# frozen_string_literal: true

describe Gnrd::SourceFactory do
  include_context "shared_context"

  describe "inst" do
    it "creates instance accoding to dossier" do
      expect(subject.inst(utf_dossier)).to be_kind_of(Gnrd::TextFile)
    end
  end
end
