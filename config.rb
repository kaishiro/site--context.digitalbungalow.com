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
end


  helpers CustomHelpers

activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = ENV['S3_BUCKET']
  s3_sync.region                     = ENV['S3_REGION']
  s3_sync.aws_access_key_id          = ENV['S3_KEY']
  s3_sync.aws_secret_access_key      = ENV['S3_SECRET']
  s3_sync.delete                     = false # We delete stray files by default.
  s3_sync.after_build                = false # We do not chain after the build step by default. 
  s3_sync.prefer_gzip                = true
  s3_sync.path_style                 = true
  s3_sync.reduced_redundancy_storage = false
  s3_sync.acl                        = 'public-read'
  s3_sync.encryption                 = false 
end

caching_policy 'text/html', max_age: 0, must_revalidate: true
