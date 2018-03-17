source 'https://rubygems.org'

ruby '2.4.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# gem 'rails', github: 'rails/rails', tag: '5-0-stable'
gem 'bugsnag'
gem 'coffee-rails', '~> 4.2'
gem 'figaro'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'newrelic_rpm'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'rails', '5.1.5'
gem 'sass-rails', '~> 5.0'
gem 'statsd-instrument'
gem 'turbolinks', '~> 5'
gem 'twilio-ruby'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :test do
  gem 'minitest-ci'
  gem 'timecop'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
