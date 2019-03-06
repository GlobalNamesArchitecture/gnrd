# frozen_string_literal: true

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
      expect(page.body).to include('scientificName":"Coleoptera"')
    end

    it "takes file" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      attach_file("find_file", italian)
      choose("format_json")
      click_button("Find Names")
      expect(page.body).to include('scientificName":"Cynocephalus')
    end
  end

  context "name finding engine" do
    it "uses full gnfinder by default" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 0
      expect(res[:engine]).to eq "gnfinder"
    end

    it "can be set not to use Bayes" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      choose("engine_gnfinder_no_bayes")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 1
      expect(res[:engine]).to eq "gnfinder_no_bayes"
    end
  end

  context "detect language" do
    it "does not detect language by default" do
      visit "/"
      attach_file("find_file", italian)
      choose("format_json")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 0
      expect(res[:parameters][:detect_language]).to be false
      expect(res[:language_used]).to eq "eng"
      expect(res[:language_detected].to_s).to eq ""
      expect(res[:engine]).to eq "gnfinder"
    end

    it "can be set to yes" do
      visit "/"
      attach_file("find_file", italian)
      choose("format_json")
      choose("detect_language_yes")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:engine]).to be 0
      expect(res[:parameters][:detect_language]).to be true
      expect(res[:language_used]).to eq "eng"
      expect(res[:language_detected]).to eq "ita"
      expect(res[:engine]).to eq "gnfinder"
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

  context "verification" do
    it "does not verify names by default" do
      visit "/"
      fill_in("find_text", with: "Atlanta and Pardosa moesta")
      choose("format_json")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:verified_names]).to be nil
    end

    it "can be verified with best match only" do
      visit "/"
      fill_in("find_text", with: "Homo sapiens and Pardosa moesta")
      choose("format_json")
      check("with_verification")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:verified_names].size).to be 2
    end

    it "can be verified with preferred data sources" do
      visit "/"
      fill_in("find_text", with: "Atlanta fragilis and Pardosa moesta")
      choose("format_json")
      check("preferred_data_sources_1")
      check("preferred_data_sources_3")
      check("preferred_data_sources_5")
      check("preferred_data_sources_11")
      check("preferred_data_sources_167")
      check("preferred_data_sources_12")
      check("preferred_data_sources_179")
      check("preferred_data_sources_169")
      click_button("Find Names")
      res = JSON.parse(page.body, symbolize_names: true)
      expect(res[:parameters][:preferred_data_sources].sort)
        .to eq [1, 3, 5, 11, 12, 167, 169, 179]
      expect(res[:verified_names].size).to be 2
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
