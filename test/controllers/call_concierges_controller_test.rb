require 'test_helper'

class CallConciergesControllerTest < ActionDispatch::IntegrationTest
  test "should get pizza and set bypass correctly" do
    assert 0, Concierge.first.bypass
    assert_statsd_gauge('callcontroller.pizza') do
      get call_concierges_pizza_url
    end
    assert 1, Concierge.first.bypass
    assert_response :success
  end

  test "should get near and set bypass correctly" do
    assert 0, Concierge.first.bypass
    assert_statsd_gauge('callcontroller.near') do
      get call_concierges_near_url
    end
    assert 1, Concierge.first.bypass
    assert_response :success
  end

  test "should get inbound_call" do
    get call_concierges_inbound_call_url
    assert_response :success
  end

  test "should get inboud_call_handler" do
    get call_concierges_inbound_call_handler_url
    assert_response :success
  end

  test "should get extension" do
    get call_concierges_extension_url
    assert_response :success
  end

  test "should get entry_code" do
    get call_concierges_entry_code_url
    assert_response :success
  end

  test "Should open door when its time for cleaning" do
    Timecop.freeze(Time.gm(2014, 2, 20, 13, 52, 1))
    get call_concierges_inbound_call_url
    assert_equal 1, Concierge.first.bypass
    Timecop.return
  end
end
