describe "/" do
  it "renders" do
    visit "/"
    expect(page.status_code).to eq 200
    expect(page.body).to match "Recognition and Discovery"
  end
end

describe "/api" do
  it "renders" do
    visit "/api"
    expect(page.status_code).to eq 200
    expect(page.body).to match "This API produces"
  end
end

describe "/feedback" do
  it "renders" do
    visit "/feedback"
    expect(page.status_code).to eq 200
    expect(page.body).to match "Feedback"
  end
end
