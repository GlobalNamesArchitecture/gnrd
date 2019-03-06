# frozen_string_literal: true

describe "api" do
  let(:text) do
    Addressable::URI.escape("Falsificus erundiculus var. " \
    "pridumalus, Atlanta brunnea and Pardosa moesta")
  end
  let(:html) do
    Addressable::URI
      .escape("<html><body><p>Falsificus erundiculus var. pridumalus, " \
        "Atlanta brunnea and Pardosa moesta</p></body></html>")
  end
  let(:file) { File.absolute_path(__dir__ + "/../files/utf8.txt") }
  let(:url) do
    Addressable::URI
      .escape("https://en.wikipedia.org/wiki/Asian_long-horned_beetle")
  end

  context "input" do
    it "accepts text" do
      get "/name_finder.json?text=Pardosa+moesta"
      follow_redirect!
      expect(last_response.body).to include('scientificName":"Pardosa moesta"')
    end

    it "accepts url" do
      get "/name_finder.json?url=#{url}&unique=1"
      follow_redirect!
      res = last_response.body
      expect(res).to include('unique":true')
      expect(res)
        .to include('{"scientificName":"Coleoptera"}')
    end

    it "accepts file" do
      post("/name_finder.json",
           file: Rack::Test::UploadedFile.new(file, "text/plain"),
           unique: true)
      follow_redirect!
      expect(last_response.body)
        .to include('{"scientificName":"Pedicia spinifera"}')
    end
  end

  context "parameters" do
    it "sets default parameters" do
      get "/name_finder.json"
      params = JSON.parse(last_response.body,
                          symbolize_names: true)[:parameters]
      expect(params).to eq(unique: false,
                           return_content: false,
                           with_verification: false,
                           preferred_data_sources: [],
                           detect_language: false,
                           no_bayes: false,
                           engine: 0)
    end

    it "sets all parmeters" do
      params = [%w[unique true], %w[return_content true],
                %w[with_verification true],
                %w[preferred_data_sources 1|2], %w[detect_language true],
                %w[engine 1]]
               .each_with_object([]) { |(k, v), obj| obj << "#{k}=#{v}" }
               .join("&")
      get "/name_finder.json?#{Addressable::URI.escape(params)}"
      params = JSON.parse(last_response.body,
                          symbolize_names: true)[:parameters]
      expect(params).to eq(unique: true,
                           return_content: true,
                           with_verification: true,
                           preferred_data_sources: [1, 2],
                           detect_language: true,
                           no_bayes: true,
                           engine: 1)
    end

    it "sets parmeters with 0 and 1 too" do
      params = [%w[unique 1], %w[return_content 1],
                %w[with_verification 1],
                %w[preferred_data_sources 1|2], %w[detect_language 1],
                %w[engine 1]]
               .each_with_object([]) { |(k, v), obj| obj << "#{k}=#{v}" }
               .join("&")
      get "/name_finder.json?#{Addressable::URI.escape(params)}"
      params = JSON.parse(last_response.body,
                          symbolize_names: true)[:parameters]
      expect(params).to eq(unique: true,
                           return_content: true,
                           with_verification: true,
                           preferred_data_sources: [1, 2],
                           detect_language: true,
                           no_bayes: true,
                           engine: 1)
    end
  end

  context "engines" do
    it "runs heuristic and Bayes by default" do
      get "/name_finder.json?text=#{text}"
      expect(last_response.status).to be 303
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(res[:parameters][:engine]).to eq 0
      expect(res[:engine]).to eq "gnfinder"
      expect(names).to eq ["Falsificus erundiculus var. pridumalus",
                           "Atlanta brunnea", "Pardosa moesta"]
    end

    it "runs only heuristic algorithms when engine is 1" do
      get "/name_finder.json?engine=1&text=#{text}"
      expect(last_response.status).to be 303
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(res[:parameters][:engine]).to eq 1
      expect(res[:engine]).to eq "gnfinder_no_bayes"
      expect(names).to eq ["Atlanta brunnea", "Pardosa moesta"]
    end

    it "runs gnfinder by default" do
      text = "Pardosa moesta and Plantago major and Homo sapiens"
      text = Addressable::URI.escape(text)
      ds = Addressable::URI.escape("1|12|13")
      get "/name_finder.json?&preferred_data_sources=#{ds}&text=#{text}"
      expect(last_response.status).to be 303
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(res[:parameters][:engine]).to eq 0
      expect(res[:engine]).to eq "gnfinder"
      expect(names).to eq ["Pardosa moesta", "Plantago major", "Homo sapiens"]
      expect(res[:verified_names].size).to be 3
      expect(res[:verified_names][0][:supplied_name_string])
        .to eq "Pardosa moesta"
    end
  end

  context "language detection" do
    let(:italian) { File.absolute_path(__dir__ + "/../files/italian.txt") }

    it "uses Bayes on italian when language_detection is off" do
      post("/name_finder.json",
           file: Rack::Test::UploadedFile.new(italian, "text/plain"),
           detect_language: false, unique: true)
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(names.size).to be > 5
      expect(names.join(", "))
        .to match(/L�arteria vertebrale/)
      expect(res[:parameters][:engine]).to eq 0
      expect(res[:engine]).to eq "gnfinder"
    end

    it "uses Bayes on italian when language_detection is on" do
      post("/name_finder.json",
           file: Rack::Test::UploadedFile.new(italian, "text/plain"),
           detect_language: true, unique: true)
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(names.size).to be > 5
      expect(names.join(", "))
        .to match(/L�arteria vertebrale/)
      expect(res[:parameters][:engine]).to eq 0
      expect(res[:engine]).to eq "gnfinder"
    end

    it "uses only no_bayes on italian when engine is 1" do
      post("/name_finder.json",
           file: Rack::Test::UploadedFile.new(italian, "text/plain"),
           engine: 1, unique: true)
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      names = res[:names].map { |n| n[:scientificName] }
      expect(names.size).to be > 5
      expect(names.join(", "))
        .to match(/L�arteria vertebrale/)
      expect(res[:parameters][:engine]).to eq 1
      expect(res[:engine]).to eq "gnfinder_no_bayes"
    end
  end

  context "return_content" do
    it "returns normalized text when on" do
      get("/name_finder.json?text=#{text}&return_content=true")
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      content = res[:content]
      expect(content).to eq "Falsificus erundiculus var. pridumalus, " \
      "Atlanta brunnea and Pardosa moesta"
    end

    it "returns stripped tags text from html" do
      get("/name_finder.json?text=#{html}&return_content=true")
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      content = res[:content]
      expect(content).to eq "Falsificus erundiculus var. pridumalus, " \
      "Atlanta brunnea and Pardosa moesta"
    end

    it "returns no content by default" do
      get("/name_finder.json?text=#{html}")
      follow_redirect!
      res = JSON.parse(last_response.body, symbolize_names: true)
      content = res[:content]
      expect(content).to be_nil
    end
  end

  context "verification" do
    context "with_verification" do
      it "returns verification result" do
        get("/name_finder.json?text=#{text}&with_verification=true")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:parameters][:preferred_data_sources]).to eq []
        expect(res[:verified_names].size).to eq 3
        expect(res[:verified_names][-1][:preferred_results]).to be_empty
        expect(res[:execution_time][:find_names_duration]).to be > 0.05
      end

      it "returns only best-scored match" do
        params = "text=#{text}&with_verification=true"
        get("/name_finder.json?#{params}")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:verified_names][0][:results].is_a?(Hash)).to be true
      end
    end

    context "preferred_data_sources" do
      it "resolves using specific data sources" do
        params = "text=#{text}&preferred_data_sources=" \
                 "#{Addressable::URI.escape('1|4')}"
        get("/name_finder.json?#{params}")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:parameters][:preferred_data_sources]).to eq [1, 4]
        expect(res[:verified_names].size).to eq 3
        expect(res[:verified_names][-1][:supplied_name_string])
          .to eq "Pardosa moesta"
        expect(res[:verified_names][-1][:preferred_results].size)
          .to eq 2
        pref_res = res[:verified_names][-1][:preferred_results][0]
        expect(pref_res[:matched_canonical]).to eq "Pardosa moesta"
        expect(pref_res[:match_type]).to eq "EXACT"
      end

      it "returns data from preferred data sources if exist" do
        params = "text=#{text}"
        params += "&with_verification=true&preferred_data_sources=11"
        get("/name_finder.json?#{params}")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:verified_names][-1][:preferred_results].size).to be > 0
        expect(res[:verified_names][-1][:supplied_name_string])
          .to eq "Pardosa moesta"
        expect(res[:verified_names][-1][:preferred_results].size)
          .to eq 1
      end

      it "does not return data from preferred data sources nothing matched" do
        params = "text=#{text}"
        params += "&with_verification=true&preferred_data_sources=167"
        get("/name_finder.json?#{params}")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:verified_names][-1][:supplied_name_string])
          .to eq "Pardosa moesta"
        expect(res[:verified_names][-1][:preferred_results])
          .to be_empty
      end

      it "doesn't exist when not set" do
        params = "text=#{text}&with_verification=true"
        get("/name_finder.json?#{params}")
        follow_redirect!
        res = JSON.parse(last_response.body, symbolize_names: true)
        expect(res[:verified_names][0][:preferred_results]).to be_empty
      end
    end
  end
end
