# frozen_string_literal: true

describe Gnrd::GnfinderEngine do
  include_context "shared_context"
  subject { Gnrd::GnfinderEngine }

  describe ".new" do
    let(:params) do
      Params.new(preferred_data_sources: [1, 11, 179],
                 all_data_sources: true,
                 detect_language: false).normalize
    end

    it "creates new instance" do
      expect(subject.new(utf_dossier, params))
        .to be_kind_of(Gnrd::GnfinderEngine)
      expect(params[:all_data_sources]).to be true
      expect(subject.new(utf_dossier, params).dossier)
        .to be_kind_of(Gnrd::Dossier)
    end

    it "takes params" do
      gnf = subject.new(utf_dossier, params)
      opts = gnf.opts
      expect(opts[:language]).to eq "eng"
      expect(opts[:with_verification]).to be true
      expect(opts[:sources]).to eq [1, 11, 179]
    end
  end

  describe "#find_resolve" do
    let(:params) do
      Params.new(data_source_ids: [1, 11, 179],
                 detect_language: true,
                 all_data_sources: true).normalize
    end
    it "finds names" do
      params[:with_bayes] = false
      gnf = subject.new(utf_dossier, params)
      names = gnf.find_resolve
      name = names[0].to_h
      expect(name[:type]).to eq "Uninomial"
      expect(name[:verification].to_h[:current_name]).to eq "Pedicia"
      expect(name[:verification].to_h[:data_source_id]).to be 1
    end
  end
end
