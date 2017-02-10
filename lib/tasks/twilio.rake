namespace :twilio do
  desc 'This creates and/or updates a Twilio app to work with this app'

  task create_and_update_app: :environment do
    unless @twilio_client.account.applications.list.empty?
      puts 'YorkPhoneGateway already exists, skipping creation'
    else
      build = @twilio_client.account.applications.create(:friendly_name => 'YorkPhoneGateway2',
                                          :voice_url => 'https://quiet-bastion-71101.herokuapp.com/call_concierges/inbound_call',
                                          :voice_method => 'GET')
      puts build.voice_url
    end
  end
end
