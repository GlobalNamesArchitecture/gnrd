describe Gnrd::App::Formatter do
  include_context "shared_context"
  subject { Gnrd::App::Formatter }
  let(:nc) { FactoryGirl.build(:name_finder) }
  let(:opts) { {} }

  describe ".new" do
    it "creates an instance" do
      expect(subject.new(nc, opts)).to be_kind_of subject
    end
  end
end
