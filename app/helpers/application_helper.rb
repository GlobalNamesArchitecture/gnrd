module ApplicationHelper
  def title(page_title, options={})
    content_for(:title, page_title.to_s)
  end
end
