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

  describe ".symbolize_keys" do
    let(:hash) do
      { one: { "two" => { three: "four" } }, "five" => [1, 2, 3, 4] }
    end
    let(:ary) do
      [1, { "two" => ["three", { four: 5 }] }, nil, "six"]
    end

    it "symbolizes keys recursively" do
      expect(subject.symbolize_keys(hash))
        .to eq(one: { two: { three: "four" } }, five: [1, 2, 3, 4])
    end

    it "deals with arrays" do
      expect(subject.symbolize_keys(ary))
        .to eq([1, { two: ["three", { four: 5 }] }, nil, "six"])
    end
  end
end
