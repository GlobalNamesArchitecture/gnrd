describe HashSerializer do
  subject { HashSerializer }

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
