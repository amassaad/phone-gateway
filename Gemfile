source 'https://rubygems.org'

ruby '2.1.5'

gem 'sinatra',          '~> 1.4.5'
gem 'twilio-ruby',      '~> 3.14.2'
gem 'thin',             '~> 1.6.3'
gem 'figaro',           '~> 1.0.0'

group :production do
	gem 'newrelic_rpm',    '~> 3.9.9.275'
end

group :development, :test do
	gem 'rspec-rails',     '~> 3.1.0'
	gem 'webrat',          '~> 0.7.3'
	gem 'rack',            '~> 1.6.0'
	gem 'rack-test',       '~> 0.6.2'
	gem 'timecop',         '~> 0.7.1'
end
