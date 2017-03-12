class WelcomeController < ApplicationController
  def index
    StatsD.gauge('welcomecontroller.bamboo', 1)
  end
end
