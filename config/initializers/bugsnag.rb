Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG']
  config.notify_release_stages = %w(production staging)
end
