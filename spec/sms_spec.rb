require_relative '../safe_gorge'
require 'rack/test'
require 'timecop'

set :environment, :test
welcome_response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Gather numDigits=\"1\" action=\"/in-call/get\" method=\"post\"><Say>Welcome to York Street. Deliveries, please press 5.\n        For a joke, press 1.\n        To speak to a person, press 2.\n        To check your future, press 3.\n        If you know anything else, at all. Please enter it now!</Say></Gather><Say>Sorry, I didn't get your response</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call</Redirect></Response>"


describe 'SMS and Call Response Capabilities' do 
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

	it "should respond plainly to no SMS" do
		get '/smsin'
		expect(last_response).to be_ok
		expect(last_response.body).to eq('No SMS.')
	end

	it "should accept Twilio SMS" do
		get "/smsin?ToCountry=CA&ToState=ON&SmsMessageSid=SM60c8870b5bd81d43f33a107c832b931f&NumMedia=0&ToCity=OTTAWA&FromZip=&SmsSid=SM60c8870b5bd81d43f33a107c832b931f&FromState=ON&SmsStatus=received&FromCity=OTTAWA&Body=Works+still+as+good+as+a+computer&FromCountry=CA&To=%2B16136996738&ToZip=&MessageSid=SM60c8870b5bd81d43f33a107c832b931f&AccountSid=AC4474fb44063b4118e729013bd9e9a5dd&From=%2B16138584587&ApiVersion=2010-04-01"
		expect(last_response).to be_ok
		expect(last_response.body).to eq('The sms arrived. Works still as good as a computer') 
	end

	it "should Welcome you to York Street" do
		get '/in-call'
		expect(last_response).to be_ok
		expect(last_response.body).to eq(welcome_response)
	end

	it "should not just let you in when it is not cleaning time" do
		get '/in-call'
		expect(last_response).to be_ok
		expect(last_response.body).to eq(welcome_response)
		puts "Now #{Time.now}"
	end

	it "should accept your options" do
		get '/in-call/get'
		expect(last_response).to be_ok
		expect(last_response.body).to eq('you got get method') 
	end

	it "should not fuck up option 1" do
		get "/in-call/get?Digits=1"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Four fonts walk into a bar. the barman says Hey - get out! We dont want your type in here. 
        A nurse says: Doctor, there is an invisible man in the waiting room. The Doctor says: Tell him I cant see him.</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call</Redirect></Response>") 
	end

	it "should not fuck up option 2" do
		get "/in-call/get?Digits=2"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Gather numDigits=\"1\" action=\"https://safe-gorge-6634.herokuapp.com/in-call/extension\" method=\"post\"><Say>Please enter your partys extension. Press 0 to return to the main menu</Say></Gather><Say>Sorry, I didn't get your response.</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call/get?Digits=2</Redirect></Response>") 
	end

	it "should not fuck up option 3" do
		get "/in-call/get?Digits=3"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>You will be disconnected for your attitude towards the space-time continuum.</Say><Hangup/></Response>") 
	end

	it "should not fuck up option 4" do
		get "/in-call/get?Digits=4"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Four is a not yet built feature. Try again later? Lets start over</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call</Redirect></Response>") 
	end	

	it "should not fuck up option 5" do
		get "/in-call/get?Digits=5"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Hello Delivery, I am not here right now but you may enter and drop off the package. Thanks and have a nice day</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call/entrycode?Digits=4321</Redirect></Response>") 
	end

	it "should definitely not fuck up option 6" do
		get "/in-call/get?Digits=6"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Gather numDigits=\"4\" action=\"https://safe-gorge-6634.herokuapp.com/in-call/entrycode\" method=\"post\"><Say>Please enter the secret code. Press 0 to return to the main menu</Say></Gather><Say>Sorry, I didn't get your response.</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call/get?Digits=6</Redirect></Response>") 
	end

	it "should handle the secret code properly" do
		get "/in-call/entrycode?Digits=1394"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Accepted.</Say><Play digits=\"www99\"/></Response>")
	end

	it "should handle the entry code properly" do
		get "/in-call/entrycode?Digits=4321"
		expect(last_response).to be_ok
		expect(last_response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Thanks friend, that was accepted.</Say><Play digits=\"www99\"/></Response>")
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

	cleaning_response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say>Hey, please enter.</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call/entrycode?Digits=4321</Redirect><Say>Sorry, I didn't get your response</Say><Redirect>https://safe-gorge-6634.herokuapp.com/in-call</Redirect></Response>"

	def app
		Sinatra::Application
	end

	before do
		Timecop.freeze(Time.gm(2014, 2, 20, 12, 52, 1))
	end

	after do
		Timecop.return
	end

	it "should  just let you in when it is cleaning time" do
		get '/in-call'
		expect(last_response).to be_ok
		expect(last_response.body).to eq(cleaning_response)
		puts "Now #{Time.now}"
	end
end	
