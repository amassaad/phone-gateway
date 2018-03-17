class CallConciergesController < ApplicationController
  ROOT_PATH = ENV['PHONE_HOST'] || 'http://www.test.com'
  FROM = ENV['TWILIOFROM'] || '+18005555555'

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
      check_for_cleaning_time

      @res = Twilio::TwiML::VoiceResponse.new do |r|
        r.redirect(ROOT_PATH + '/call_concierges/inbound_call')
        r.say('Sorry, I didnt get your response')
      end

      handle_call_and_sms

      if Concierge.first.bypass == 1
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          r.say('Please enter.')
          sms_create('The bypass code was used.', ENV['CELL'])
          r.redirect(ROOT_PATH + '/call_concierges/entry_code?Digits=4321')
        end
      end

      render xml: @res.to_xml
    end
  end

  def check_for_cleaning_time
    return unless Time.now.thursday? && Time.now.getlocal('-04:00').hour.between?(8, 9) && Time.now.min.between?(20, 59) || Time.now.min.between?(0, 5)

    Concierge.first.update(bypass: 1)
    StatsD.gauge('callcontroller.cleaning_bypass_update', 1)
  end

  def handle_call_and_sms
    return unless Concierge.first.counter.zero?
    @res = Twilio::TwiML::VoiceResponse.new do |r|
      sms_create('The door was buzzed.', ENV['CELL'])
      sms_create('The door was buzzed.', ENV['V_CELL'])
      Concierge.first.counter += 1
      r.gather(:numDigits => '1', :action => ROOT_PATH + '/call_concierges/inbound_call_handler', :method => 'get') do |g|
        g.play(url: s3_url('welcome_to_york'))
      end
    end
  end

  def inbound_call_handler
    StatsD.measure('InboundCallHandler.performance') do
      return unless params['Digits']
      opts = params['Digits']
      case opts
      when '1'
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          if Time.now.getlocal('-04:00').hour.between?(7, 19)
            r.play(url: s3_url('you_may_enter_but_I_am_not_home_now'))
            r.redirect(ROOT_PATH + '/call_concierges/entry_code?Digits=8297')
            Concierge.first.update(bypass: 0)
          else
            r.redirect(ROOT_PATH + '/call_concierges/entry_code?Digits=2')
            Concierge.first.update(bypass: 0)
          end
        end
      when '2'
        if Time.now.getlocal('-04:00').hour.between?(5, 22)
          @res = Twilio::TwiML::VoiceResponse.new do |r|
            r.gather(numDigits: '1', action: ROOT_PATH + '/call_concierges/extension', method: 'get') do |g|
              g.play(url: s3_url('press_2_again_to_continue'))
            end
            r.play(url: s3_url('sorry_I_didnt_get_your_response'))
            r.redirect(ROOT_PATH + '/call_concierges/inbound_call_handler?Digits=2')
          end
        else
          @res = Twilio::TwiML::VoiceResponse.new do |r|
            r.say "Sorry, its late here."
            r.hangup
          end
        end
      when '3'
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          r.play s3_url('you_will_be_disconnected')
          r.hangup
        end
      when '4'
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          r.play s3_url('option_four_is_not_yet_built')
          r.redirect(ROOT_PATH + '/call_concierges/inbound_call', method: 'get')
        end
      when '5'
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          sms_create('Heh, hehehe.', ENV['CELL'])
          r.play s3_url('joke')
          sms_create('HAHAHA!', ENV['CELL'])
          r.redirect(ROOT_PATH + '/call_concierges/inbound_call', method: 'get')
        end
      when '6'
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          r.gather numDigits: '4', action: ROOT_PATH + '/call_concierges/entry_code', method: 'get' do |g|
            g.play s3_url('please_enter_the_secret_code')
          end
          r.play s3_url('sorry_I_didnt_get_your_response')
          r.redirect ROOT_PATH + '/call_concierges/inbound_call_handler?Digits=6'
        end
      when '7'
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          r.redirect 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
        end
      else
        @res = Twilio::TwiML::VoiceResponse.new do |r|
          r.say "Was this not fun? . . Let's play again."
          r.redirect ROOT_PATH + '/call_concierges/inbound_call_handler'
        end
      end
    else
      @res = Twilio::TwiML::VoiceResponse.new do |r|
        r.play(url: s3_url('sorry_I_didnt_get_your_response'))
        r.redirect ROOT_PATH + '/call_concierges/inbound_call'
      end
    end
    render xml: @res.to_xml
  end

  def extension
    StatsD.measure('ExtensionDialer.performance') do
      @res = Twilio::TwiML::VoiceResponse.new do |r|
        r.say 'Attempting to connect you, please wait.'
        r.dial(callerId: FROM) do |d|
          d.number(ENV['CELL'])
        end
        r.say 'The party you are trying to reach is unavailable or has hung up. Goodbye.'
      end
      render xml: @res.to_xml
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
      @res = Twilio::TwiML::VoiceResponse.new do |r|
        r.say 'Code accepted. Welcome.'
        r.play digits: enter_tone
        sms_create('Your home code was used', ENV['CELL'])
      end
    elsif user_pushed.eql? near_entry_code
      @res = Twilio::TwiML::VoiceResponse.new do |r|
        r.play digits: enter_tone
        sms_create('A near entry code was just used', ENV['CELL'])
      end
    elsif user_pushed.eql? delivery_code
      @res = Twilio::TwiML::VoiceResponse.new do |r|
        r.say 'Door opening.'
        r.play digits: enter_tone
        sms_create('Delivery code - something is here?', ENV['CELL'])
      end
    else
      @res = Twilio::TwiML::VoiceResponse.new do |r|
        r.say 'Sorry Punk, stay out in the cold.'
        sms_create('Some punk found menu 6', ENV['CELL'])
      end
    end
    render xml: @res.to_xml
  end

  private

  def sms_create(body, to)
    StatsD.measure('SMSCreate.performance') do
      if Rails.env.production?
        @twilio_client = Twilio::REST::Client.new(ENV['TSID'], ENV['TTOKEN'])

        @twilio_client.account.messages.create({
          body: '[🚪doorbell 🔔] ' + body,
          to: to,
          from: FROM
        })
      elsif Rails.env.development?
        puts "I'm sms create in development mode. Body: #{body}"
      end
    end
  end

  def s3_url(name)
    "https://s3-us-west-2.amazonaws.com/yorkphonegateway/#{name}.wav"
  end
end
