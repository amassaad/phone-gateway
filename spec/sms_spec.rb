require_relative '../safe_gorge'
require 'rack/test'
require 'timecop'

set :environment, :test

describe 'SMS and Call Response Handler' do
	include Rack::Test::Methods

	before do
		Timecop.freeze(Time.gm(2014, 2, 17))
	end

	after do
		Timecop.return
	end

	def app
		Sinatra::Application
	end

	it "should load the home page and feed Pandas" do
		get '/'
		expect(last_response).to be_ok
		expect(last_response.body).to eq('Hello Pandas! Have some ban-boo.')
	end

r	it "should not fuck up option 5" do
		get "/in-call/get?Digits=5"
		expect(last_response).to be_ok
	end

	it "should not fuck up option 2" do
		get "/in-call/get?Digits=2"
		expect(last_response).to be_ok
	end

	it "should not fuck up option 3" do
		get "/in-call/get?Digits=3"
		expect(last_response).to be_ok
	end

	it "should not fuck up option 4" do
		get "/in-call/get?Digits=4"
		expect(last_response).to be_ok
	end

	it "should not fuck up option 1" do
		Timecop.freeze(Time.gm(2014, 2, 20, 13, 52, 1))
		get "/in-call/get?Digits=1"
		expect(last_response).to be_ok
		expect(last_response.body).to include("<Redirect>https://york-phone-gateway.herokuapp.com/in-call/entrycode?Digits=8297</Redirect>")
		Timecop.return
	end

	it "should definitely not fuck up option 6" do
		get "/in-call/get?Digits=6"
		expect(last_response).to be_ok
	end

	it "should handle the secret code properly" do
		get "/in-call/entrycode?Digits=1394"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Accepted.</Say><Play digits=\"www99\"/></Response>")
	end

	it "should handle the entry code properly" do
		get "/in-call/entrycode?Digits=4321"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>To the right.</Say><Play digits=\"www99\"/></Response>")
	end

	it "should handle the delivery code properly" do
		get "/in-call/entrycode?Digits=8297"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Thanks, door opening.</Say><Play digits=\"www99\"/></Response>")
	end

	it "should deal with punks properly" do
		get "/in-call/entrycode?Digits=4422"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Sorry Punk, stay out in the cold.</Say></Response>")
	end
end
