# Welcome, the build status is here: [ ![Codeship Status for massaad/ivr](https://codeship.io/projects/310f4810-2fed-0132-1216-3ad622bf587e/status)](https://codeship.io/projects/39672) #

### What is this repository for? ###

SMS gateway

### How do I get set up? ###

* gem 'sinatra'
* gem 'twilio-ruby'
* gem 'mail'
* bundle install-izzle
* heroku deployment
* Twilio account
* Sadly due to Herofuck limitations this requires a cron job run every 2 minutes that checks the /, this also triggers pop3 check and keep-alive on the app
* I have now set this up to do almost nothing during development or test, so no texts fire off during le testing, we all love getting Twilio text messages.

### Contribution guidelines ###

* Test locally, Twilio is set to send Get requests or POST for most things, check the meta method in helper.rb and the code
* Generally push to master, or to your feature branch? #yolo

### Who do I talk to? ###

* Massaad
 