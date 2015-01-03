require_relative 'helper'
counter = 0
root = "https://safe-gorge-6634.herokuapp.com"

get_or_post '/in-call' do
  account_sid = ENV['TSID']
  auth_token = ENV['TTOKEN']
  client = Twilio::REST::Client.new account_sid, auth_token
  bypass = false

  options = "Welcome to York Street. Deliveries, please press 5.
        For a joke, press 1.
        To speak to a person, press 2.
        To check your future, press 3.
        If you know anything else, at all. Please enter it now!"

  if Time.now.thursday?
    if Time.now.hour.between?( 12, 13 )
      if Time.now.min.between?( 42 , 59 ) or Time.now.min.between?( 0, 5 )
        puts "arrived"
        bypass = true
      end
    end
  end
        
  Twilio::TwiML::Response.new do |r|
    if bypass
      r.Say "Hey, please enter."
      sms_create("The Thursday cleaning code was used.", ENV['CELL'])
      r.Redirect root + "/in-call/entrycode?Digits=4321"
    else
      if counter == 0
        sms_create("The door was buzzed.", ENV['CELL'])
        counter = counter + 1
      end
      r.Gather :numDigits => '1', :action => '/in-call/get', :method => 'post' do |g|
        g.Say options
      end
    end
    r.Say "Sorry, I didn't get your response"
    r.Redirect root + "/in-call"
  end.text
end

get_or_post '/in-call/get' do
  if params['Digits']
    opts = params['Digits']

    case opts
    when "1"
      Twilio::TwiML::Response.new do |r|
        r.Say "Four fonts walk into a bar. the barman says Hey - get out! We dont want your type in here. 
        A nurse says: Doctor, there is an invisible man in the waiting room. The Doctor says: Tell him I cant see him."
        r.Redirect root + "/in-call"
      end.text 
    when "2"
      Twilio::TwiML::Response.new do |r|
        r.Gather :numDigits => '1', :action => 'https://safe-gorge-6634.herokuapp.com/in-call/extension', :method => 'post' do |g|
          g.Say "Please enter your partys extension. Press 0 to return to the main menu"
        end
        r.Say "Sorry, I didn't get your response."
        r.Redirect root + "/in-call/get?Digits=2"
      end.text
    when "3"
      Twilio::TwiML::Response.new do |r|
        r.Say "You will be disconnected for your attitude towards the space-time continuum."
        r.Hangup
      end.text 
    when "4"
      Twilio::TwiML::Response.new do |r|
        r.Say "Four is a not yet built feature. Try again later? Lets start over"
        r.Redirect root + "/in-call"
      end.text 
    when "5" 
      Twilio::TwiML::Response.new do |r|
        r.Say "Hello Delivery, I am not here right now but you may enter and drop off the package. Thanks and have a nice day"
        r.Redirect root + "/in-call/entrycode?Digits=4321"
      end.text 
    when "6"
      Twilio::TwiML::Response.new do |r|
        r.Gather :numDigits => '4', :action => 'https://safe-gorge-6634.herokuapp.com/in-call/entrycode', :method => 'post' do |g|
          g.Say "Please enter the secret code. Press 0 to return to the main menu"
        end
        r.Say "Sorry, I didn't get your response."
        r.Redirect root + "/in-call/get?Digits=6"
      end.text
    else
      Twilio::TwiML::Response.new do |r|
        r.Say "Was this not fun? . . Let's play again."
        r.Redirect root + "/in-call/get"
      end.text 
    end
  else
    "you got get method"
  end
end

get_or_post '/in-call/extension' do
  Twilio::TwiML::Response.new do |r|
    r.Say "I could connect you to someone live, but was this not fun? . . For no Press 1, for Yes please press 2. Yes?. or . . . no? Let's play again."
    r.Redirect root + "/in-call/get"
  end.text 
end

get_or_post '/in-call/entrycode' do
  user_pushed = params['Digits']
  secret_code = "1394"
  guest_code = "4321"
  delivery_code = "8297"
  enter_tone = "www99"

  if user_pushed.eql? secret_code
    Twilio::TwiML::Response.new do |r|
      r.Say "Accepted."
      r.Play :digits => enter_tone
      sms_create("Your home code was used", ENV['CELL'])
    end.text 
  elsif user_pushed.eql? guest_code
    Twilio::TwiML::Response.new do |r|
      r.Say "Thanks friend, that was accepted."
      r.Play :digits => enter_tone
      sms_create("Guest code was used", ENV['CELL'])
    end.text 
  elsif user_pushed.eql? delivery_code
    Twilio::TwiML::Response.new do |r|
      r.Say "Thanks, door opening."
      r.Play :digits => enter_tone
      sms_create("Delivery code - something is here?", ENV['CELL'])
    end.text
  else
    Twilio::TwiML::Response.new do |r|
      r.Say "Sorry Punk, stay out in the cold."
      sms_create("Some punk found menu 6", ENV['CELL'])
    end.text
  end
end