describe Gnrd::App::Formatter do
  include_context "shared_context"
  subject { Gnrd::App::Formatter }
  let(:nc) { FactoryGirl.create(:name_finder) }

  describe ".new" do
    it "creates an instance" do
      expect(subject.new(nc)).to be_kind_of subject
    end
  end
end
