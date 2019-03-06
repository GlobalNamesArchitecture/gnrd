# frozen_string_literal: true

describe Gnrd do
  describe ".version" do
    it "returns app version" do
      expect(subject.version).to match(/\d+\.\d+\.\d+/)
      expect(subject::VERSION).to eq subject.version
    end
  end

  describe ".env" do
    it "returns app env setting" do
      expect(subject.env).to eq :test
    end
  end

  describe ".env" do
    it "saves new environment" do
      expect(subject.env = :test).to eq :test
    end

    it "does not take unknown environments" do
      expect { subject.env = :whateva }.to raise_error TypeError
    end
  end
end
