# These tests check that all parameters and fields for web-based user interface
# are working as expected
describe "web user interface" do
  let(:italian) { File.absolute_path(__dir__ + "/../files/italian.txt") }
  let(:url) { "https://en.wikipedia.org/wiki/Asian_long-horned_beetle" }

  context "input" do
    it "takes typed text" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      click_button("Find Names")
      expect(page.body).to include('scientificName":"Pardosa moesta"')
    end

    it "takes url" do
      visit "/"
      fill_in("find_url", with: url)
      choose("format_json")
      click_button("Find Names")
      expect(page.body).to include('scientificName":"Anoplophora nobilis"')
    end

    it "takes file" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      attach_file("find_file", italian)
      choose("format_json")
      click_button("Find Names")
      expect(page.body).to include('scientificName":"Cynocephalus"')
    end
  end

  context "name finding engine" do
    it "uses both engines by default" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 0
      expect(res[:engines]).to eq %w(TaxonFinder NetiNeti)
    end

    it "can be set to use TaxonFinder only" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      choose("engine_TaxonFinder")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 1
      expect(res[:engines]).to eq %w(TaxonFinder)
    end

    it "can be set to use NetiNeti only" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      choose("engine_NetiNeti")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 2
      expect(res[:engines]).to eq %w(NetiNeti)
    end
  end

  context "detect language" do
    it "detects language by default" do
      visit "/"
      attach_file("find_file", italian)
      choose("format_json")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 0
      expect(res[:engines]).to eq %w(TaxonFinder)
    end

    it "can be set to no" do
      visit "/"
      attach_file("find_file", italian)
      choose("format_json")
      choose("detect_language_no")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 0
      expect(res[:engines]).to eq %w(TaxonFinder NetiNeti)
    end
  end

  context "scientific names" do
    it "selects unique names only by default" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:unique]).to be true
    end

    it "can be set to not unique and verbatim" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      choose("unique_all_occurrences")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:unique]).to be false
    end
  end

  context "resolve against" do
    it "does not resolve names by default" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:resolved_names]).to be nil
    end

    it "can be resolved against all data sources" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      check("all_data_sources")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:resolved_names].size).to be 2
    end

    it "can be resolved against specific data sources" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      check("data_source_ids_1")
      check("data_source_ids_3")
      check("data_source_ids_5")
      check("data_source_ids_11")
      check("data_source_ids_167")
      check("data_source_ids_12")
      check("data_source_ids_7")
      check("data_source_ids_169")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:data_sources].map { |ds| ds[:id] }.sort)
        .to eq [1, 3, 5, 7, 11, 12, 167, 169]
      expect(res[:resolved_names].size).to be 2
    end
  end

  context "output" do
    it "can return html" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_html")
      click_button("Find Names")
      expect(page.body).to include("<td>Pardosa moesta</td>")
    end

    it "can return json" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      click_button("Find Names")
      expect(page.body).to include('scientificName":"Pardosa moesta"')
    end

    it "can return xml" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_xml")
      click_button("Find Names")
      expect(page.body).to include("<dwc:scientificName>Pardosa moesta</")
    end

    it "can return content" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      check("return_content")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:content]).to eq "Atlanta and Pardosa moesta"
    end
  end
end
