module SiteHelpers

  def markdown(source)
    Tilt::KramdownTemplate.new { source }.render
  end

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

  def abbreviate(department)
    abbreviation = ""

    if department == "CEO"
      abbreviation = "CEO"
    elsif department == "Development"
      abbreviation = "Dev"
    elsif department == "Creative"
      abbreviation = "Cre"
    elsif department == "Project Management"
      abbreviation = "PM"
    elsif department == "Sales & Accounts"
      abbreviation = "S&A"
    elsif department == "Marketing & Analytics"
      abbreviation = "M&A"
    else
      abbreviation = ""
    end
    abbreviation.upcase
  end

  def gravatar_url(email)
    @email = Digest::MD5.hexdigest(email)
    @size = '25'
    @default = 'mm'
    @url_root = 'http://www.gravatar.com/avatar/'
    @url_params = '?s=' + @size + '&d=' + @default

    gravatar_url = @url_root + @email + @url_params

    gravatar_url
  end

end
