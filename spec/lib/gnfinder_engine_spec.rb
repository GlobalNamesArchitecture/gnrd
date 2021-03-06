# frozen_string_literal: true

describe Gnrd::GnfinderEngine do
  include_context "shared_context"
  subject { Gnrd::GnfinderEngine }

  describe ".new" do
    let(:params) do
      Params.new(preferred_data_sources: [1, 11, 179],
                 with_verification: true,
                 engine: 3,
                 detect_language: false).normalize
    end

    it "creates new instance" do
      expect(subject.new(utf_dossier, params))
        .to be_kind_of(Gnrd::GnfinderEngine)
      expect(params[:with_verification]).to be true
      expect(subject.new(utf_dossier, params).dossier)
        .to be_kind_of(Gnrd::Dossier)
    end

    it "takes params" do
      gnf = subject.new(utf_dossier, params)
      opts = gnf.opts
      expect(opts[:verification]).to be true
      expect(opts[:sources]).to eq [1, 11, 179]
    end

    it "does not set resolver without corresponding params" do
      params = Params.new(engine: 3).normalize
      gnf = subject.new(utf_dossier, params)
      opts = gnf.opts
      expect(opts[:verification]).to be nil
    end
  end

  describe "#find_resolve" do
    let(:params) do
      Params.new(preferred_data_sources: [1, 11, 179],
                 detect_language: true,
                 with_verification: true).normalize
    end
    it "finds names" do
      params[:no_bayes] = true
      gnf = subject.new(utf_dossier, params)
      res = gnf.find_resolve
      name = res.names[0].to_h
      expect(name[:type]).to eq "Uninomial"
      expect(name[:verification][:best_result][:current_name]).to eq "Pedicia"
      expect(name[:verification][:best_result][:data_source_id]).to be 1
    end
  end
end
