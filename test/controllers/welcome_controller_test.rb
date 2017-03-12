require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get root" do
    assert_statsd_gauge('welcomecontroller.bamboo') do
      get root_url
    end
    assert_response :success
  end
end
