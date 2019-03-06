# frozen_string_literal: true

describe Gnrd::WebDownloader do
  subject { Gnrd::WebDownloader }

  let(:html_url) { "https://en.wikipedia.org/wiki/Monochamus" }
  let(:pdf_url) { "http://goo.gl/G5lQji" }
  let(:bad_url) { "https://asdfdsafsda.com/a324243jjl.pdf" }
  let(:ssl_url) { "https://example.org" }
  let(:bad_ssl_url) { "https://badssl.globalnames.org" }

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

      it "gets content from a valid ssl page" do
        file_path = subject.new.download(ssl_url, "123-token")
        content = File.read(file_path)
        expect(content).to include("Example")
      end

      it "raises error for bad url" do
        expect { subject.new.download(bad_url, "123-token") }
          .to raise_error(Gnrd::UrlRetrievalError)
      end

      it "raises error for bad ssl cert" do
        expect { subject.new.download(bad_ssl_url, "123-token") }
          .to raise_error(Gnrd::UrlRetrievalError)
      end
    end

    context "pdf file" do
    end
  end
end
