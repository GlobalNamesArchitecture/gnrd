# frozen_string_literal: true

describe "/main.css" do
  it "renders" do
    visit "/main.css"
    expect(page.status_code).to be 200
  end
end

describe "/" do
  it "renders" do
    visit "/"
    expect(page.status_code).to be 200
    expect(page.current_path).to eq "/"
    expect(page.body).to match "Recognition and Discovery"
  end
end

describe "/api" do
  it "renders" do
    visit "/api"
    expect(page.status_code).to be 200
    expect(page.body).to match "This API produces"
  end
end

describe "/feedback" do
  it "renders" do
    visit "/feedback"
    expect(page.status_code).to be 200
    expect(page.body).to match "Feedback"
  end
end

describe "/history" do
  it "renders" do
    visit "/history"
    expect(page.status_code).to be 200
    expect(page.body).to match "History"
  end
end

describe "/name_finder" do
  context "error handling" do
    it "redirects home when html/empty parameters" do
      visit "/name_finder"
      expect(page.current_path).to eq "/"
      expect(page.status_code).to be 200
      expect(page.body).to include("Parameters missing")
    end

    it "displays empty params error when json" do
      visit "/name_finder.json"
      expect(page.status_code).to be 400
      expect(page.current_path).to match("name_finder")
      expect(page.body).to include('"status":400')
    end

    it "displays empty params error when xml" do
      visit "/name_finder.xml"
      expect(page.status_code).to be 400
      expect(page.current_path).to match("name_finder")
      expect(page.body).to include("<status>400</status>")
    end

    it "redirects home when token not found" do
      visit "/name_finder?token=123"
      expect(page.current_path).to eq "/"
      expect(page.status_code).to be 200
      expect(page.body).to include("no longer exists")
    end

    it "displays 404 when token not found in json" do
      visit "/name_finder.json?token=123"
      expect(page.status_code).to be 404
      expect(page.current_path).to match("name_finder")
      expect(page.body).to include('"status":404')
    end

    it "displays 404 when token not found in xml" do
      visit "/name_finder.xml?token=123"
      expect(page.status_code).to be 404
      expect(page.current_path).to match("name_finder")
      expect(page.body).to include("<status>404</status>")
    end
  end

  context "text string" do
    let(:params) { Addressable::URI.encode("text=Pardosa moesta") }

    it "returns result in json" do
      visit "/name_finder.json?#{params}"
      expect(page.body).to include("200")
    end

    it "returns result in xml" do
      visit "/name_finder.xml?#{params}"
      expect(page.body).to include("<status>200</status>")
    end

    it "returns result in html" do
      visit "/name_finder?#{params}"
      expect(page.body).to include("Pardosa moesta")
    end
  end

  context "url string" do
    let(:url) { "https://en.wikipedia.org/wiki/Asian_long-horned_beetle" }
    let(:url2) { "en.wikipedia.org/wiki/Asian_long-horned_beetle" }
    let(:bad_url) { "http://dunno.com/this/thingie" }
    let(:url404) { "https://example.org/a35jdlsh3sslalh" }

    it "returns result in html" do
      visit "/name_finder?url=#{url}"
      expect(page.body).to include("<td>Anoplophora glabripennis</td>")
    end

    it "returns result in json" do
      visit "/name_finder.json?url=#{url}"
      expect(page.body).to include('scientificName":"Anoplophora glabripennis')
    end

    it "returns result in xml" do
      visit "/name_finder.xml?url=#{url}"
      expect(page.body).to include("scientificName>Anoplophora glabripennis")
    end

    it "adds http:// to urls without prefix" do
      visit "/name_finder.json?url=#{url2}"
      expect(page.body).to include('scientificName":"Anoplophora glabripennis')
    end

    it "redirects home when url is not found" do
      visit "/name_finder?url=#{bad_url}"
      expect(page.current_path).to eq "/"
      expect(page.status_code).to be 200
      expect(page.body).to include("URL retrieval error")
    end

    it "returns timeout code for non-existant domain in json" do
      visit "/name_finder.json?url=#{bad_url}"
      expect(page.status_code).to be 408
      expect(page.body).to include("408")
    end

    it "returns timeout for non-existant domain in xml" do
      visit "/name_finder.xml?url=#{bad_url}"
      expect(page.status_code).to be 408
      expect(page.body).to include("<status>408</status>")
    end

    it "returns not found for known domain, bad path in xml" do
      visit "/name_finder.xml?url=#{url404}"
      expect(page.status_code).to be 404
      expect(page.body).to include("<status>404</status>")
    end
  end

  context "url pdf" do
    let(:url) do
      "http://bmcbioinformatics.biomedcentral.com/track/pdf/" \
        "10.1186/1471-2105-13-211?site=bmcbioinformatics.biomedcentral.com"
    end

    it "returns result in json" do
      path = "/name_finder.json?url=#{Addressable::URI.encode(url)}&unique=true"
      visit path
      expect(page.body)
        .to include("\"scientificName\":\"Oxyuranus temporalis\"")
    end
  end

  context "text file" do
    let(:file1) { File.absolute_path(__dir__ + "/../files/latin1.txt") }

    it "returns result from file" do
      visit "/"
      attach_file("find_file", file1)
      click_button("Find Names")
      expect(page.body).to include("<td>Pedicia spinifera</td>")
    end

    it "returns result from file in json" do
      visit "/"
      attach_file("find_file", file1)
      choose("format_json")
      click_button("Find Names")
      expect(page.body).to include('scientificName":"Pedicia spinifera"')
    end

    it "returns result from file in xml" do
      visit "/"
      attach_file("find_file", file1)
      choose("format_xml")
      click_button("Find Names")
      expect(page.body).to include("scientificName>Pedicia spinifera")
    end
  end

  context "image file" do
    let(:image) { File.absolute_path(__dir__ + "/../files/image.jpg") }
    let(:image2) { File.absolute_path(__dir__ + "/../files/no_names.jpg") }

    it "returns result from image file" do
      visit "/"
      attach_file("find_file", image)
      click_button("Find Names")
      expect(page.body).to include("<td>Baccha elongata</td>")
    end

    it "handles images without names" do
      visit "/"
      attach_file("find_file", image2)
      click_button("Find Names")
      expect(page.body).to match(%r{0</strong>.*<strong>unique}m)
    end
  end

  context "pdf file" do
    let(:pdf) { File.absolute_path(__dir__ + "/../files/file.pdf") }
    let(:image_pdf) { File.absolute_path(__dir__ + "/../files/image.pdf") }

    it "returns result from pdf file" do
      visit "/"
      attach_file("find_file", pdf)
      click_button("Find Names")
      expect(page.body).to include("<td>Tacsonia insignis</td>")
    end

    it "handles image pdfs" do
      visit "/"
      attach_file("find_file", image_pdf)
      click_button("Find Names")
      expect(page.body).to include("<td>Baccha elongata</td>")
    end
  end

  context "Microsoft Office files" do
    let(:msw) { File.absolute_path(__dir__ + "/../files/file.docx") }
    let(:mse) { File.absolute_path(__dir__ + "/../files/file.xlsx") }

    it "returns result from Microsoft Word file" do
      visit "/"
      attach_file("find_file", msw)
      click_button("Find Names")
      expect(page.body).to include("<td>Pangagrellus redivivus</td>")
    end

    it "returns result from Microsoft Excel file" do
      visit "/"
      attach_file("find_file", mse)
      click_button("Find Names")
      expect(page.body).to include("<td>Notostira pubicornis</td>")
    end
  end
end
