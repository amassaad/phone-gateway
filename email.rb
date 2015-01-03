# require_relative 'helper'

# SCHEDULER.every '33s', :first_in => 0 do
#   if settings.production?
#     mailin_user = ENV['MAILINUSER']
#     mailin_pass = ENV['MAILINPASS']

#     Mail.defaults do
#     retriever_method :pop3, :address    => "pop.zoho.com",
#                             :port       => 995,
#                             :user_name  => mailin_user,
#                             :password   => mailin_pass,
#                             :enable_ssl => true
#     end

#     email_reply = Mail.first

#     if Mail.all.any?
#       to_gorp = email_reply.subject
#       to_gorp[0..4] = ""

#       sms_create(email_reply.body.decoded, to_gorp)

#       Mail.delete_all
#     end
#   end
# end

# get '/smsin' do
#   sms_body = params['Body'] 
#   sms_from = params['From']
  
#   if settings.production?
#     mailout_user = ENV['MAILOUTUSER']
#     mailout_pass = ENV['MAILOUTPASS']
#     mailin_user = ENV['MAILINUSER']
    
#     mailoptions = { :address              => "smtp.gmail.com",
#               :port                 => 587,
#               :domain               => 'gmail.com',
#               :user_name            => mailout_user,
#               :password             => mailout_pass,
#               :authentication       => 'plain',
#               :enable_starttls_auto => true  }
      
#     Mail.defaults do
#       delivery_method :smtp, mailoptions
#     end

#     Mail.deliver do
#       to 'massaad@gmail.com'
#       from 'massaad@gmail.com'
#       reply_to mailin_user
#       subject "#{sms_from}"
#       body "From: #{sms_from} SMS: #{sms_body} "
#     end
#   end

#   if sms_body.to_s.length < 1
#     "No SMS."    
#   else 
#     "The sms arrived. #{sms_body}"
#   end
# end