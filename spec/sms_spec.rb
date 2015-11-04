require_relative '../safe_gorge'
require 'rack/test'
require 'timecop'

set :environment, :test
welcome_response1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Gather numDigits=\"1\" action=\"/in-call/get\" method=\"post\"><Play>https://s3-us-west-2.amazonaws.com/yorkphonegateway/welcome_to_york.wav</Play></Gather><Say>Sorry, I didn't get your response</Say><Redirect>https://york-phone-gateway.herokuapp.com/in-call</Redirect></Response>"
welcome_response = "<Say>Welcome to York Street. Deliveries, please press 1."

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

	it "should Welcome you to York Street" do
		get '/in-call'
		expect(last_response).to be_ok
		expect(last_response.body).to include(welcome_response)
	end

	it "should not just let you in when it is not cleaning time" do
		get '/in-call'
		expect(last_response).to be_ok
		expect(last_response.body).to include(welcome_response)
		puts "Now #{Time.now}"
	end

	it "should accept your options" do
		get '/in-call/get'
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Sorry, I didn't get your response</Say><Redirect>https://york-phone-gateway.herokuapp.com/in-call</Redirect></Response>")
	end

	it "should not fuck up option 5" do
		get "/in-call/get?Digits=5"
		expect(last_response).to be_ok
		# expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>A guy walks into a bar and asks the bartender for a free drink. The bartender says\n I will give you a free drink if you can tell me a multi-level met-uh joke. So the guy says\n A guy walks into a bar and asks the bartender for a free drink. The bartender says\n I will give you a free drink if you can tell me a met-uh joke. So the guy says A guy walks\n into a bar and asks the bartender for a free drink. The bartender says I will give you a\n free drink if you can tell me a good joke. So the guy says What do you do when you see a\n spaceman? You park, man. So the bartender gives him a free beer. So the bartender gives\n him a free beer. So the bartender gives him a free beer. The end. I hope that was worth it.<Redirect>https://york-phone-gateway.herokuapp.com/in-call</Redirect></Response>")
	end

	it "should not fuck up option 2" do
		get "/in-call/get?Digits=2"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Gather numDigits=\"1\" action=\"https://york-phone-gateway.herokuapp.com/in-call/extension\" method=\"post\"><Say>Press number 2 again to continue or press 0 to return to the main menu</Say></Gather><Say>Sorry, I didn't get your response.</Say><Redirect>https://york-phone-gateway.herokuapp.com/in-call/get?Digits=2</Redirect></Response>")
	end

	it "should not fuck up option 3" do
		get "/in-call/get?Digits=3"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>You will be disconnected for your attitude towards the space-time continuum.</Say><Hangup/></Response>")
	end

	it "should not fuck up option 4" do
		get "/in-call/get?Digits=4"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Four is a not yet built feature. Try again later? Lets start over</Say><Redirect>https://york-phone-gateway.herokuapp.com/in-call</Redirect></Response>")
	end

	it "should not fuck up option 1" do
		Timecop.freeze(Time.gm(2014, 2, 20, 13, 52, 1))
		get "/in-call/get?Digits=1"
		expect(last_response).to be_ok
		expect(last_response.body).to include("<Say>You may enter, but I am not here. Thanks and have a nice day</Say>")
		expect(last_response.body).to include("<Redirect>https://york-phone-gateway.herokuapp.com/in-call/entrycode?Digits=8297</Redirect>")
		Timecop.return
	end

	it "should definitely not fuck up option 6" do
		get "/in-call/get?Digits=6"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Gather numDigits=\"4\" action=\"https://york-phone-gateway.herokuapp.com/in-call/entrycode\" method=\"post\"><Say>Please enter the secret code. Press 0 to return to the main menu</Say></Gather><Say>Sorry, I didn't get your response.</Say><Redirect>https://york-phone-gateway.herokuapp.com/in-call/get?Digits=6</Redirect></Response>")
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

describe 'Door Cleaning and time-based Response Capabilities' do
	include Rack::Test::Methods

	cleaning_response = "Please enter.</Say><Redirect>https://york-phone-gateway.herokuapp.com/in-call/entrycode?Digits=4321</Redirect>"

	def app
		Sinatra::Application
	end

	before do
		Timecop.freeze(Time.gm(2014, 2, 20, 13, 52, 1))
	end

	after do
		Timecop.return
	end

	it "should  just let you in when it is cleaning time" do
		get '/in-call'
		expect(last_response).to be_ok
		expect(last_response.body).to include(cleaning_response)
		puts "Now #{Time.now}"
	end
end


