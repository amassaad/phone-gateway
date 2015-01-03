source 'https://rubygems.org'

ruby '2.1.5'

gem 'sinatra'
gem 'twilio-ruby'
gem 'thin'

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
