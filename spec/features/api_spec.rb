describe "api" do
  let(:text) { URI.escape("Atlanta and Pardosa moesta") }
  let(:html) do
    URI.escape("<html><body><p>Atlanta and Pardosa moesta</p></body></html>")
  end

  context "parameters" do
    it "sets default parameters" do
      get "/name_finder.json"
      params = JSON.parse(last_response.body,
                          symbolize_names: true)[:parameters]
      expect(params).to eq(unique: false,
                           return_content: false,
                           all_data_sources: false,
                           best_match_only: false,
                           data_source_ids: [],
                           preferred_data_sources: [],
                           detect_language: true,
                           engine: 0)
    end

    it "sets all parmeters" do
      params = [%w(unique true), %w(return_content true),
                %w(all_data_sources true), %w(best_match_only true),
                %w(data_source_ids 1|2|3), %w(preferred_data_sources 1|2),
                %w(detect_language false), %w(engine 1)
      ].each_with_object([]) { |(k, v), obj| obj << "#{k}=#{v}" }.join("&")
      get "/name_finder.json?#{URI.escape(params)}"
      params = JSON.parse(last_response.body,
                          symbolize_names: true)[:parameters]
      expect(params).to eq(unique: true,
                           return_content: true,
                           all_data_sources: true,
                           best_match_only: true,
                           data_source_ids: [1, 2, 3],
                           preferred_data_sources: [1, 2],
                           detect_language: false,
                           engine: 1)
    end
  end

  context "engines" do
    it "runs both engines by default" do
      get "/name_finder.json?text=#{text}"
      expect(last_response.status).to be 303
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(res[:engines]).to eq %w(TaxonFinder NetiNeti)
      expect(names).to eq ["Atlanta", "Pardosa moesta"]
    end

    it "runs only TaxonFinder when engine is 1" do
      get "/name_finder.json?engine=1&text=#{text}"
      expect(last_response.status).to be 303
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(res[:engines]).to eq ["TaxonFinder"]
      expect(names).to eq ["Pardosa moesta"]
    end
  end

  context "language detection" do
    let(:italian) { File.absolute_path(__dir__ + "/../files/italian.txt") }

    it "uses both engines on italian when language_detection is off" do
      post("/name_finder.json",
           file: Rack::Test::UploadedFile.new(italian, "text/plain"),
           detect_language: false, unique: true)
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(names.size).to be > 10
      expect(names)
        .to match(/(Vibrionidi quali esseri|Appunti geologici sul)/)
      expect(res[:engines]).to eq %w(TaxonFinder NetiNeti)
    end

    it "uses only TaxonFinder on italian when language_detection is on" do
      post("/name_finder.json",
           file: Rack::Test::UploadedFile.new(italian, "text/plain"),
           detect_language: true, unique: true)
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(names.size).to be < 10
      expect(names)
        .to_not match(/(Vibrionidi quali esseri|Appunti geologici sul)/)
      expect(res[:engines]).to eq ["TaxonFinder"]
    end
  end

  context "return_content" do
    it "returns normalized text when on" do
      get("/name_finder.json?text=#{text}&return_content=true")
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      content = res[:content]
      expect(content).to eq "Atlanta and Pardosa moesta"
    end

    it "returns stripped tags text from html" do
      get("/name_finder.json?text=#{html}&return_content=true")
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      content = res[:content]
      expect(content).to eq "Atlanta and Pardosa moesta"
    end

    it "returns no content by default" do
      get("/name_finder.json?text=#{html}")
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      content = res[:content]
      expect(content).to be_nil
    end
  end

  context "resolution" do
    context "all_data_sources" do
      it "returns resolution result" do
        get("/name_finder.json?text=#{text}&all_data_sources=true")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:data_sources]).to eq []
        expect(res[:resolved_names].size).to eq 2
      end
    end

    context "data_source_ids" do
      it "resolves using specific data sources" do
        params = "text=#{text}&data_source_ids=#{URI.escape('1|4')}"
        get("/name_finder.json?#{params}")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:data_sources]).to eq(
          [
            { id: 1, title: "Catalogue of Life" },
            { id: 4, title: "NCBI" }
          ])
        expect(res[:resolved_names].size).to eq 2
      end
    end
  end
end
