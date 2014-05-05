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
  def quarter_prep

    @quarter = {}

    quarters_array = [[1,2,3], [4,5,6], [7,8,9], [10,11,12]]

    current_quarter = (Time.now.month - 1) / 3

    current_quarter_array = quarters_array[current_quarter]
    
    quarter_start = Date.new(Date.today.year,current_quarter_array[0],1).at_beginning_of_month

    quarter_end = Date.new(Date.today.year,current_quarter_array[2],1).at_end_of_month

    quarter_days = (quarter_end - quarter_start).to_i

    current_year = Time.new.year

    quarter_1_start = Date.new(current_year,1,1)
    quarter_1_end = Date.new(current_year,3,31)
    quarter_1_days = (quarter_1_end - quarter_1_start).to_i

    quarter_2_start = Date.new(current_year,4,1)
    quarter_2_end = Date.new(current_year,6,30)
    quarter_2_days = (quarter_2_end - quarter_2_start).to_i

    quarter_3_start = Date.new(current_year,7,1)
    quarter_3_end = Date.new(current_year,9,30)
    quarter_3_days = (quarter_3_end - quarter_3_start).to_i

    quarter_4_start = Date.new(current_year,10,1)
    quarter_4_end = Date.new(current_year,12,31)
    quarter_4_days = (quarter_4_end - quarter_4_start).to_i

    if current_quarter == 0
      elapsed_days = 0
    elsif current_quarter == 1
      elapsed_days = quarter_1_days
    elsif current_quarter == 2
      elapsed_days = quarter_1_days + quarter_2_days
    else
      elapsed_days = quarter_1_days + quarter_2_days + quarter_3_days
    end

    placeholder_array = []

    (quarter_start..quarter_end).each do |date|
      placeholder_date = date.strftime("%m/%d")
      placeholder_bricks = 0

      placeholder = {
        :date => placeholder_date,
        :bricks => placeholder_bricks
      }

      placeholder_array << placeholder
    end

    @quarter = {
      :current => current_quarter,
      :start_date => quarter_start,
      :end_date => quarter_end,
      :total_days => quarter_days,
      :elapsed_days => elapsed_days,
      :placeholder => placeholder_array
    }

    return @quarter

  end


  def locations_prep
    @locations = {}

    data.company.locations.each_with_index do |location, index|

      # Collect location-specific forecast data into a hash
      @forecasts = {}

      data.weather[index].forecast.simpleforecast.forecastday.each_with_index do |forecast, index|

        @forecast = {
          :date => Time.strptime(forecast["date"]["epoch"], '%s'),
          :icon => forecast["icon"]
        }

        @forecasts.merge!(index => @forecast)
        @forecasts.delete(0)

      end


      # Collect location-specific employee data into a hash
      @employees = {}

      location["employees"].each_with_index do |employee, index|

        @employee = {
          :name => employee["name"],
          :email => employee["email"],
          :department => employee["department"],
          :head => employee["head"]
        }

        @employees.merge!(index => @employee)

      end


      # Collect location data into a hash
      @location = {
        :city => data.weather[index]["current_observation"]["display_location"]["city"],
        :country => data.weather[index]["current_observation"]["display_location"]["state_name"],
        :latitude => data.weather[index]["current_observation"]["display_location"]["latitude"],
        :longitude => data.weather[index]["current_observation"]["display_location"]["longitude"],
        :timezone_offset => data.weather[index]["current_observation"]["local_tz_offset"],
        :timezone_long => data.weather[index]["current_observation"]["local_tz_long"],
        :date => Time.now.in_time_zone(data.weather[index]["current_observation"]["local_tz_long"]).strftime('%-m/%-d'),
        :time => Time.now.in_time_zone(data.weather[index]["current_observation"]["local_tz_long"]).strftime('%l:%M%P'),
        :temperature => data.weather[index]["current_observation"]["temp_f"].round.to_s + '&deg;',
        :icon => data.weather[index]["current_observation"]["icon"],
        :employees => @employees,
        :forecast => @forecasts
      }

      @locations.merge!(index => @location)

    end

    return @locations

  end

  def employees_prep

    @progress = {}

    @employees = {}

    data.employees.each_with_index do |employee, index|

      @issues = {}
      @bricks = []
      total_bricks = 0

      employee["issues"].each_with_index do |issue, index|

        if issue["bricks"].nil?
          issue["bricks"] = 0
        end

        total_bricks += issue["bricks"]
        
        @issue = {
          :project => issue["project"],
          :issuetype => issue["issuetype"],
          :bricks => issue["bricks"],
          :resolutiondate => issue["resolutiondate"]
        }

        @issues.merge!(index => @issue)

        issue_date = DateTime.parse(issue["resolutiondate"]).to_date.strftime("%m/%d")

        @brick = {
          :date => issue_date,
          :bricks => issue["bricks"]
        }

        @bricks << @brick

      end

      @employee = {
        :name => employee["name"],
        :username => employee["username"],
        :goal => employee["goal"],
        :issues => @issues,
        :bricks => @bricks,
        :totalbricks => total_bricks
      }

      @employees.merge!(index => @employee)

    end

    return @employees
  end

  def totals_prep

    @totals = {}

    total_goal = 0
    total_bricks = 0

    data.employees.each_with_index do |employee, index|

      if employee["goal"].nil?
        employee["goal"] = 0
      end

      total_goal += employee["goal"] 

    end

    @employees.each do |index, employee|
      total_bricks += employee[:totalbricks]
    end

    total_progress = (total_bricks/total_goal) * 100

    @totals = {
      :goal => total_goal,
      :bricks => total_bricks,
      :progress => total_progress
    }


    return @totals

  end

end
