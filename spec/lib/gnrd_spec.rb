describe Gnrd do
  describe ".version" do
    it "returns app version" do
      expect(subject.version).to match(/\d+\.\d+\.\d+/)
      expect(subject::VERSION).to eq subject.version
    end
  end
end
