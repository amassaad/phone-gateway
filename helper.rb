SCHEDULER = Rufus::Scheduler.new

def self.get_or_post(url,&block)
  get(url,&block)
  post(url,&block)
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