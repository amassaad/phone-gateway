class CallConciergesController < ApplicationController
  ROOT_PATH = 'https://york-phone-gateway.herokuapp.com'.freeze
  FROM = ENV['TWILIOFROM'].freeze

  def pizza
    Concierge.first.update(bypass: 1)
    StatsD.gauge('callcontroller.pizza', 1)
    render html: 'OK.
    <img style="-webkit-user-select: none; cursor: zoom-in;" src="https://cdn.shopify.com/s/files/1/0196/8346/files/Supreme_pizza.png?7139639298543844503">'.html_safe
  end

  def near
    Concierge.first.update(bypass: 1)
    StatsD.gauge('callcontroller.near', 1)
    render html: 'OK'
  end

  def inbound_call
    StatsD.measure('InboundCall.performance') do
      if Time.now.thursday? && Time.now.getlocal("-05:00").hour.between?(8, 9) && Time.now.min.between?( 20 , 59 ) or Time.now.min.between?( 0, 5 )
        Concierge.first.update(bypass: 1)
        StatsD.gauge('callcontroller.cleaning_bypass_update', 1)
      end


      @res = Twilio::TwiML::Response.new do |r|
        r.Redirect(ROOT_PATH + '/call_concierges/inbound_call')
        r.Say('Sorry, I didnt get your response')
      end

      if Concierge.first.counter == 0
        @res = Twilio::TwiML::Response.new do |r|
          sms_create('The door was buzzed.', ENV['CELL'])
          sms_create('The door was buzzed.', ENV['V_CELL'])
          Concierge.first.counter += 1
          r.Gather(:numDigits => '1', :action => ROOT_PATH + '/call_concierges/inbound_call_handler', :method => 'get') do |g|
            g.Play(s3_url('welcome_to_york'))
          end
        end
      end

      if Concierge.first.bypass == 1
        @res = Twilio::TwiML::Response.new do |r|
          r.Say('Please enter.')
          sms_create('The bypass code was used.', ENV['CELL'])
          r.Redirect(ROOT_PATH + '/call_concierges/entry_code?Digits=4321')
        end
      end

      render text: @res.text
    end
  end

  def inbound_call_handler
    StatsD.measure('InboundCallHandler.performance') do
      if params['Digits']
        opts = params['Digits']
        case opts
        when '1'
          @res = Twilio::TwiML::Response.new do |r|
            if Time.now.getlocal('-05:00').hour.between?(7, 19)
              r.Play(s3_url('you_may_enter_but_I_am_not_home_now'))
              r.Redirect(ROOT_PATH + '/call_concierges/entry_code?Digits=8297')
              Concierge.first.update(bypass: 0)
            else
              r.Redirect(ROOT_PATH + '/call_concierges/entry_code?Digits=2')
              Concierge.first.update(bypass: 0)
            end
          end
        when "2"
          if Time.now.getlocal('-05:00').hour.between?(5, 22)
            @res = Twilio::TwiML::Response.new do |r|
              r.Gather(:numDigits => '1', :action => ROOT_PATH + '/call_concierges/extension', :method => 'get') do |g|
                g.Play(s3_url('press_2_again_to_continue'))
              end
              r.Play(s3_url('sorry_I_didnt_get_your_response'))
              r.Redirect(ROOT_PATH + '/call_concierges/inbound_call_handler?Digits=2')
            end
          else
            @res = Twilio::TwiML::Response.new do |r|
              r.Say "Sorry, its late here."
              r.hangup
            end
          end
        when "3"
          @res = Twilio::TwiML::Response.new do |r|
            r.Play s3_url('you_will_be_disconnected')
            r.Hangup
          end
        when '4'
          @res = Twilio::TwiML::Response.new do |r|
            r.Play s3_url('option_four_is_not_yet_built')
            r.Redirect(ROOT_PATH + '/call_concierges/inbound_call', method: 'get')
          end
        when '5'
          @res = Twilio::TwiML::Response.new do |r|
             # sms_create('Heh, hehe.', ENV['CELL'])
            r.Play s3_url('joke')
             # sms_create('Hahaha.', ENV['CELL'])
            r.Redirect(ROOT_PATH + '/call_concierges/inbound_call', method: 'get')
          end
        when '6'
          @res = Twilio::TwiML::Response.new do |r|
            r.Gather :numDigits => '4', :action => ROOT_PATH + '/call_concierges/entry_code', :method => 'get' do |g|
              g.Play s3_url('please_enter_the_secret_code')
            end
            r.Play s3_url('sorry_I_didnt_get_your_response')
            r.Redirect ROOT_PATH + '/call_concierges/inbound_call_handler?Digits=6'
          end
        when '7'
          @res = Twilio::TwiML::Response.new do |r|
            r.Redirect 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
          end
        else
          @res = Twilio::TwiML::Response.new do |r|
            r.Say "Was this not fun? . . Let's play again."
            r.Redirect ROOT_PATH + '/call_concierges/inbound_call_handler'
          end
        end
      else
        @res = Twilio::TwiML::Response.new do |r|
          r.Play s3_url('sorry_I_didnt_get_your_response')
          r.Redirect ROOT_PATH + '/call_concierges/inbound_call'
        end
      end
      render text: @res.text
    end
  end

  def extension
    StatsD.measure('ExtensionDialer.performance') do
      @res = Twilio::TwiML::Response.new do |r|
        r.Say 'Attempting to connect you, please wait.'
        r.Dial(callerId: FROM) do |d|
          d.Number(ENV['CELL'])
        end
        r.Say 'The party you are trying to reach is unavailable or has hung up. Goodbye.'
      end
      render text: @res.text
    end
  end

  def entry_code
    user_pushed = params['Digits']
    secret_code = '1394'
    near_entry_code = '4321'
    delivery_code = '8297'
    enter_tone = 'www99'
    Concierge.first.update(bypass: 0)


    if user_pushed.eql? secret_code
      @res = Twilio::TwiML::Response.new do |r|
        r.Say 'Code accepted. Welcome.'
        r.Play :digits => enter_tone
        sms_create('Your home code was used', ENV['CELL'])
      end
    elsif user_pushed.eql? near_entry_code
      @res = Twilio::TwiML::Response.new do |r|
        r.Play :digits => enter_tone
        sms_create('A near entry code was just used', ENV['CELL'])
      end
    elsif user_pushed.eql? delivery_code
      @res = Twilio::TwiML::Response.new do |r|
        r.Say 'Door opening.'
        r.Play :digits => enter_tone
        sms_create('Delivery code - something is here?', ENV['CELL'])
      end
    else
      @res = Twilio::TwiML::Response.new do |r|
        r.Say 'Sorry Punk, stay out in the cold.'
        sms_create('Some punk found menu 6', ENV['CELL'])
      end
    end
    render text: @res.text
  end

  private

  def sms_create(body, to)
    StatsD.measure('SMSCreate.performance') do
      if Rails.env.production?
        @twilio_client = Twilio::REST::Client.new(ENV['TSID'], ENV['TTOKEN'])

        @twilio_client.account.messages.create({
          :body => '[🚪doorbell 🔔] ' + body,
          :to => to,
          :from => FROM
        })
      elsif Rails.env.development?
        puts "I'm sms create in development mode. Body: #{body}"
      else
        # puts "I'm an SMS in I-dont-know-lol or litering gross text into test mode.🤢
        # "
      end
    end
  end

  def s3_url(name)
    "https://s3-us-west-2.amazonaws.com/yorkphonegateway/#{name}.wav"
  end
end
