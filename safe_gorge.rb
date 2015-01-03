require 'twilio-ruby'
require 'sinatra'
require 'mail'
require 'rufus-scheduler'
require_relative 'email'
require_relative 'calls'

configure do
  set :protection, :except => :path_traversal
end

configure :production do
  require 'newrelic_rpm'
end

get '/' do
  "Hello Pandas! Have some ban-boo."
end
