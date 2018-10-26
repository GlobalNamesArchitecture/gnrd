# frozen_string_literal: true

describe Gnrd::GnfinderEngine do
  include_context "shared_context"
  subject { Gnrd::GnfinderEngine }

  describe ".new" do
    it "creates new instance" do
      expect(subject.new(utf_dossier, {})).to be_kind_of(Gnrd::GnfinderEngine)
      expect(subject.new(utf_dossier, {}).dossier).to be_kind_of(Gnrd::Dossier)
    end

    # it "takes options" do
    #   opts = { netineti: false }
    #   nf = subject.new(utf_dossier, opts)
    #   expect(nf.options[:netineti]).to be false
    #   nf = subject.new(utf_dossier)
    #   expect(nf.options[:netineti]).to be true
    # end
  end

  describe "#find" do
    it "finds names" do
      names = subject.new(utf_dossier, {}).find
      require 'byebug'; byebug
      puts ''
    end
  end
end
