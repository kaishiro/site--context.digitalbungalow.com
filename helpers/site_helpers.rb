module SiteHelpers
  
  def page_title
    title = ""

    if current_page.url == "/"
      title = data.site["title"]
    else
      if data.page.title
        title = data.page.title + " | " + data.site["title"]
      elsif yield_content(:title)
        title = yield_content(:title) + " | " + data.site["title"]
      else
        title = data.site["title"]
      end
    end
    title
  end

end
