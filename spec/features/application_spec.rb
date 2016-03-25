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
      expect(page.current_path).to match("name_finder")
      expect(page.body).to include('"status":400')
    end

    it "displays empty params error when xml" do
      visit "/name_finder.xml"
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
      expect(page.current_path).to match("name_finder")
      expect(page.body).to include('"status":404')
    end

    it "displays 404 when token not found in xml" do
      visit "/name_finder.xml?token=123"
      expect(page.current_path).to match("name_finder")
      expect(page.body).to include("<status>404</status>")
    end
  end

  context "text string" do
    let(:params) { "text=Pardosa moesta" }

    it "returns result in json" do
      visit "/name_finder.json?text=Pardosa+moesta"
      expect(page.body).to include("200")
    end

    it "returns result in xml" do
      visit "/name_finder.xml?text=Pardosa+moesta"
      expect(page.body).to include("<status>200</status>")
    end

    it "returns result in html" do
      visit "/name_finder?text=Pardosa+moesta"
      expect(page.body).to include("Pardosa moesta")
    end
  end

  context "url string" do
    let(:url) { "https://en.wikipedia.org/wiki/Asian_long-horned_beetle" }
    let(:url2) { "eol.org/pages/207212/overview" }
    let(:bad_url) { "http://dunno.com/this/thingie" }

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
      expect(page.body).to include("verbatim\":\"Epinephelus drummondhayi")
    end

    it "redirects home when url is not found" do
      visit "/name_finder?url=#{bad_url}"
      expect(page.current_path).to eq "/"
      expect(page.status_code).to be 200
      expect(page.body).to include("URL resource not found")
    end

    it "returns not found for non-existant url in json" do
      visit "/name_finder.json?url=#{bad_url}"
      expect(page.body).to include("404")
    end

    it "returns not found for non-existant url in xml" do
      visit "/name_finder.xml?url=#{bad_url}"
      expect(page.body).to include("<status>404</status>")
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
      expect(page.body).to match(/0<\/strong>.*<strong>unique/m)
    end
  end
end
