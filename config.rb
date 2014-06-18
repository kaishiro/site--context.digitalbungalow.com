require 'redcarpet'
require 'jiralicious'
require 'wunderground'
require 'active_support/all'

require "lib/custom_helpers"

# Load local ENV vars, for development
require './env' if File.exists?('env.rb')

Jiralicious.configure do |config|
  # Leave out username and password
  config.username = ENV['JIRA_USERNAME']
  config.password = ENV['JIRA_PASSWORD']
  config.uri = ENV['JIRA_URL']
  config.api_version = "latest"
  config.auth_type = :basic
end

w_api = Wunderground.new(ENV['WUNDERGROUND_KEY'])

activate :directory_indexes
activate :automatic_image_sizes
activate :livereload

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :markdown_engine, :redcarpet

configure :build do
  quarters = [[1,2,3], [4,5,6], [7,8,9], [10,11,12]]
  quarter = quarters[(Time.now.month - 1) / 3]

  quarter_start = Date.new(Date.today.year,quarter[0],1).at_beginning_of_month.strftime('%Y/%m/%d')
  quarter_end = Date.new(Date.today.year,quarter[2],1).at_end_of_month.strftime('%Y/%m/%d')

  company = load_json('data/company.json')
  
  locations = company['locations']

  employees_array = []

  locations.each do |location|
    location["employees"].each do |employee|
      if employee["goal"] > 0
       
        # Generate employee username
        name = employee["name"].split(' ')
        first_initial = name[0][0]
        last_name = name[1]
        username = (first_initial + last_name).downcase

        puts "(#{Time.now}) Getting #{username.upcase}'s issues..."

        # Get user's issues
        r = Jiralicious.search("owner = \"#{username}\" AND (resolutiondate >= \"#{quarter_start}\" AND resolutiondate <= \"#{quarter_end}\") AND (status = 'Closed' OR status = 'Resolved') AND (resolution = 'Fixed') AND (issuetype != \"Bug (QA)\" AND issuetype != \"Rework (Post-QA Bug)\")", :max_results=>'2500',:fields=>'customfield_10004,project,issuetype,issuekey,resolutiondate')

        issues_array = []

        r.issues.each do |issue|

          issue_hash = {
            :bricks => issue["fields"]["customfield_10004"],
            :project => issue["fields"]["project"]["key"],
            :issuetype => issue["fields"]["issuetype"]["name"],
            :resolutiondate => issue["fields"]["resolutiondate"]
          }

          issues_array << issue_hash

        end

        puts "(#{Time.now}) Finished!"

        # Build employee hash
        employee = {
          :name => employee["name"],
          :goal => employee["goal"],
          :username => username,
          :issues => issues_array
        }

        # Load employee into array
        employees_array << employee

      end
    end
  end
  
  # Parse array to JSON
  employees_json = employees_array.to_json

  # Write JSON to data
  File.open("./data/employees.json", 'w') do |file|
    file.puts employees_json
  end

  # Initialize empty array
  weather_array = []

  # Loop through company locations
  locations.each do |location|

    location_name = location["location"]
    location_weather = w_api.forecast_and_conditions_for("#{location_name}")

    weather_array << location_weather

  end

  weather_json = weather_array.to_json

  File.open("./data/weather.json", 'w') do |file|
    file.puts weather_json
  end

end


  helpers CustomHelpers

activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = ENV['S3_BUCKET']
  s3_sync.region                     = ENV['S3_REGION']
  s3_sync.aws_access_key_id          = ENV['S3_KEY']
  s3_sync.aws_secret_access_key      = ENV['S3_SECRET']
  s3_sync.delete                     = true # We delete stray files by default.
  s3_sync.after_build                = false # We do not chain after the build step by default. 
  s3_sync.prefer_gzip                = true
  s3_sync.path_style                 = true
  s3_sync.reduced_redundancy_storage = false
  s3_sync.acl                        = 'public-read'
  s3_sync.encryption                 = false 
end

caching_policy 'text/html', max_age: 0, must_revalidate: true
