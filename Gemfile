source 'https://rubygems.org'

ruby '2.1.2'

gem 'sinatra'
gem 'twilio-ruby'
gem 'mail'
gem 'thin'
gem 'rufus-scheduler'

group :production do
	gem 'newrelic_rpm'
end

group :development, :test do
	gem 'rspec-rails'
	gem 'webrat'
	gem 'rack'
	gem 'rack-test'
	gem 'timecop'
end
