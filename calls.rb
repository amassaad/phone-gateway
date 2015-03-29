require_relative 'helper'
counter = 0
root = "https://york-phone-gateway.herokuapp.com"
bypass = false
dead_caller = 0

get '/pizza' do
  bypass= true
  "OK."
end

get_or_post '/in-call' do

  account_sid = ENV['TSID']
  auth_token = ENV['TTOKEN']
  client = Twilio::REST::Client.new account_sid, auth_token


  options = "Welcome to York Street. Deliveries, please press 1.
        For a joke, press 5.
        To speak to a person, press 2.
        To check your future, press 3.
        If you know anything else, at all. Please enter it now!"

  if Time.now.thursday?
    if Time.now.getlocal("-04:00").hour.between?(8, 9)
      if Time.now.min.between?( 42 , 59 ) or Time.now.min.between?( 0, 5 )
        puts "arrived"
        bypass = true
      end
    end
  end
  dead_caller += 1
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

    unless dead_caller > 2
      r.Redirect root + "/in-call"
    end
    r.hangup
  end.text
end

get_or_post '/in-call/get' do

  if params['Digits']

    opts = params['Digits']

    case opts
    when "5"
      Twilio::TwiML::Response.new do |r|
        r.Say "A guy walks into a bar and asks the bartender for a free drink. The bartender says
         I will give you a free drink if you can tell me a multi-level met-uh joke. So the guy says
         A guy walks into a bar and asks the bartender for a free drink. The bartender says
         I will give you a free drink if you can tell me a met-uh joke. So the guy says A guy walks
         into a bar and asks the bartender for a free drink. The bartender says I will give you a
         free drink if you can tell me a good joke. So the guy says What do you do when you see a
          spaceman? You park, man. So the bartender gives him a free beer. So the bartender gives
          him a free beer. So the bartender gives him a free beer. The end. I hope that was worth it."
        r.Redirect root + "/in-call"
      end.text
    when "2"
      if Time.now.getlocal("-04:00").hour.between?(5, 22)
        Twilio::TwiML::Response.new do |r|
          r.Gather :numDigits => '1', :action => root + '/in-call/extension', :method => 'post' do |g|
            g.Say "Press number 2 again to continue or press 0 to return to the main menu"
          end
          r.Say "Sorry, I didn't get your response."
          r.Redirect root + "/in-call/get?Digits=2"
        end.text
      else
        Twilio::TwiML::Response.new do |r|
          r.Say "Sorry, its late here."
          r.hangup
        end
      end

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
    when "1"
    puts "option one time" + Time.now.getlocal("-04:00").to_s
      Twilio::TwiML::Response.new do |r|
        if Time.now.getlocal("-04:00").hour.between?(7, 19)
          r.Say "You may enter, but I am not here. Thanks and have a nice day"
          r.Redirect root + "/in-call/entrycode?Digits=8297"
        else
          r.Redirect root + "/in-call/get?Digits=2"
        end
      end.text


    when "6"
      Twilio::TwiML::Response.new do |r|
        r.Gather :numDigits => '4', :action => root + '/in-call/entrycode', :method => 'post' do |g|
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
    Twilio::TwiML::Response.new do |r|
      r.Say "Sorry, I didn't get your response"
      r.Redirect root + "/in-call"
    end.text
  end
end

get_or_post '/in-call/extension' do
  redirect root + "/in-call/get" unless params['Digits'] == '2'
  Twilio::TwiML::Response.new do |r|
    r.Say "Attempting to connect you, please wait."
    r.Dial ENV['CELL'] #hope this works
    r.Say "The party you are trying to reach is unavailable or has hung up. Goodbye."
  end.text
end

get_or_post '/in-call/entrycode' do
  user_pushed = params['Digits']
  secret_code = "1394"
  guest_code = "4321"
  delivery_code = "8297"
  enter_tone = "www99"
  bypass = false

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
