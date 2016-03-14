describe NameFinder do
  subject { NameFinder }

  describe ".new" do
    it "creates instance" do
      expect(subject.new).to be_kind_of subject
    end
  end
end
