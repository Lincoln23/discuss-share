module MessagesHelper
  # uses a Github-flavored markdown
  def markdown_to_html(text)
    Kramdown::Document.new(text, input: 'GFM').to_html
  end
end
