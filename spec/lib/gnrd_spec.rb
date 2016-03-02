describe Gnrd do
  describe ".version" do
    it "returns app version" do
      expect(subject.version).to match(/\d+\.\d+\.\d+/)
    end
  end
end
