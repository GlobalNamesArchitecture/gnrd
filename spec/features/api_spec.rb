context "parameters" do
  it "sets default parameters" do
    get "/name_finder.json"
    params = JSON.parse(last_response.body, symbolize_names: true)[:parameters]
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
    get "/name_finder.json?#{params}"
    params = JSON.parse(last_response.body, symbolize_names: true)[:parameters]
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
  let(:text) { URI.escape("Atlanta and Pardosa moesta") }

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
    expect(names).to include("Vibrionidi quali esseri")
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
    expect(names).to_not include("Vibrionidi quali esseri")
    expect(res[:engines]).to eq ["TaxonFinder"]
  end
end
