describe Gnrd::WebDownloader do
  subject { Gnrd::WebDownloader }

  let(:html_url) { "https://en.wikipedia.org/wiki/Monochamus" }
  let(:pdf_url) { "http://goo.gl/G5lQji" }
  let(:bad_url) { "https://asdfdsafsda.com/a324243jjl.pdf" }

  describe ".new" do
    it "creates an instance" do
      expect(subject.new).to be_kind_of subject
    end
  end

  describe "#download" do
    context "html file" do
      it "returns path of a file" do
        file_path = subject.new.download(html_url, "123-token")
        content = File.read(file_path)
        expect(content).to include("Monochamus")
      end

      it "raises error for bad url" do
        expect { subject.new.download(bad_url, "123-token") }
          .to raise_error(Gnrd::UrlRetrievalError)
      end
    end

    context "pdf file" do
    end
  end
end
