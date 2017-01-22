class CallConciergesController < ApplicationController
  @counter = 0
  @bypass = false
  @dead_caller = 0

  ROOT_PATH = 'https://york-phone-gateway.herokuapp.com'.freeze

  def pizza
    @bypass = true

    render html: 'OK.
    <img style="-webkit-user-select: none; cursor: zoom-in;" src="https://cdn.shopify.com/s/files/1/0196/8346/files/Supreme_pizza.png?7139639298543844503">'.html_safe
  end

  def near
    @bypass = true
    render html: 'OK'
  end

  def inbound_call
    @dead_caller = 1

    if Time.now.thursday? && Time.now.getlocal("-05:00").hour.between?(8, 9) && Time.now.min.between?( 42 , 59 ) or Time.now.min.between?( 0, 5 )
      puts "arrived"
      bypass = true
    end

    Twilio::TwiML::Response.new do |r|
      if bypass
        r.Say "Please enter."
        # sms_create("The bypass code was used.", ENV['CELL'])
        r.Redirect ROOT_PATH + "/call_concierges/entry_code?Digits=4321"
      else
        if @counter == 0
          # sms_create("The door was buzzed.", ENV['CELL'])
          @counter += 1
        end
        r.Gather :numDigits => '1', :action => '/in-call/get', :method => 'post' do |g|
          g.Play s3_url("welcome_to_york")
        end
      end
      r.Say "Sorry, I didn't get your response"

      r.Redirect ROOT_PATH + "/call_concierges/inboud_call_handler"
    end.text
  end

  def inboud_call_handler
    if params['Digits']
      opts = params['Digits']
      case opts
      when "1"
      puts "option one time" + Time.now.getlocal("-05:00").to_s
        Twilio::TwiML::Response.new do |r|
          if Time.now.getlocal("-05:00").hour.between?(7, 19)
            r.Play s3_url("you_may_enter_but_I_am_not_home_now")
            r.Redirect ROOT_PATH + "/in-call/entrycode?Digits=8297"
            @bypass = false
          else
            r.Redirect ROOT_PATH + "/in-call/get?Digits=2"
            @bypass = false
          end
        end.text
      when "2"
        if Time.now.getlocal("-05:00").hour.between?(5, 22)
          Twilio::TwiML::Response.new do |r|
            r.Gather :numDigits => '1', :action => ROOT_PATH + '/in-call/extension', :method => 'post' do |g|
              g.Play s3_url("press_2_again_to_continue")
            end
            r.Play s3_url("sorry_I_didnt_get_your_response")
            r.Redirect ROOT_PATH + "/in-call/get?Digits=2"
          end.text
        else
          Twilio::TwiML::Response.new do |r|
            r.Say "Sorry, its late here."
            r.hangup
          end
        end
      when "3"
        Twilio::TwiML::Response.new do |r|
          r.Play s3_url("you_will_be_disconnected")
          r.Hangup
        end.text
      when "4"
        Twilio::TwiML::Response.new do |r|
          r.Play s3_url("option_four_is_not_yet_built")
          r.Redirect ROOT_PATH + "/in-call"
        end.text
      when "5"
        Twilio::TwiML::Response.new do |r|
           sms_create("Heh, hehe.", ENV['CELL'])
          r.Play s3_url("joke")
           # sms_create("Hahaha.", ENV['CELL'])
          r.Redirect ROOT_PATH + "/in-call"
        end.text
      when "6"
        Twilio::TwiML::Response.new do |r|
          r.Gather :numDigits => '4', :action => ROOT_PATH + '/in-call/entrycode', :method => 'post' do |g|
            g.Play s3_url("please_enter_the_secret_code")
          end
          r.Play s3_url("sorry_I_didnt_get_your_response")
          r.Redirect ROOT_PATH + "/in-call/get?Digits=6"
        end.text
      else
        Twilio::TwiML::Response.new do |r|
          r.Say "Was this not fun? . . Let's play again."
          r.Redirect ROOT_PATH + "/in-call/get"
        end.text
      end
    else
      Twilio::TwiML::Response.new do |r|
        r.Play s3_url("sorry_I_didnt_get_your_response")
        r.Redirect ROOT_PATH + "/in-call"
      end.text
    end
  end

  def extension
    unless params['Digits'] == '2'
      redirect_to ROOT_PATH + "/in-call/get"
      Twilio::TwiML::Response.new do |r|
        r.Say "Attempting to connect you, please wait."
        r.Dial ENV['CELL']
        r.Say "The party you are trying to reach is unavailable or has hung up. Goodbye."
      end.text
    end
  end

  def entry_code
    user_pushed = params['Digits']
    secret_code = "1394"
    guest_code = "4321"
    delivery_code = "8297"
    enter_tone = "www99"
    @bypass = false

    if user_pushed.eql? secret_code
      Twilio::TwiML::Response.new do |r|
        r.Say "Accepted."
        r.Play :digits => enter_tone
        # sms_create("Your home code was used", ENV['CELL'])
      end.text
    elsif user_pushed.eql? guest_code
      Twilio::TwiML::Response.new do |r|
        r.Say "To the right."
        r.Play :digits => enter_tone
        # sms_create("Guest code was used", ENV['CELL'])
      end.text
    elsif user_pushed.eql? delivery_code
      Twilio::TwiML::Response.new do |r|
        r.Say "Thanks, door opening."
        r.Play :digits => enter_tone
        # sms_create("Delivery code - something is here?", ENV['CELL'])
      end.text
    else
      Twilio::TwiML::Response.new do |r|
        r.Say "Sorry Punk, stay out in the cold."
        # sms_create("Some punk found menu 6", ENV['CELL'])
      end.text
    end
  end

  private
    def s3_url(name)
      "https://s3-us-west-2.amazonaws.com/yorkphonegateway/#{name}.wav"
    end

    def sms_create(body, to)
      if settings.production?
        from = ENV['TWILIOFROM']
        account_sid = ENV['TSID']
        auth_token = ENV['TTOKEN']
        client = Twilio::REST::Client.new account_sid, auth_token
        client.account.messages.create(
          :body => body,
          :to => to,
          :from => from
        )
      elsif settings.development?
        puts "I'm sms create in development mode. Body: #{body}"
      else
        puts "I'm an SMS in I-dont-know-lol or test mode"
      end
    end
end
