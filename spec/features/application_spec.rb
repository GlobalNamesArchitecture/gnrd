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
  it "redirects home with empty parameters" do
    # visit "/name_finder.json"
    # expect(page.status_code).to be 302
    # follow_redirect!
    # r = last_response
    # expect(r.current_path).to eq "/"
    # expect(r.status).to be 200
  end
end
