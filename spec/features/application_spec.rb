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
  context "insufficient parameters" do
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
  end
end
