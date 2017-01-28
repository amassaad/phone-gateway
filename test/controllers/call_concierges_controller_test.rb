require 'test_helper'

class CallConciergesControllerTest < ActionDispatch::IntegrationTest
  test "should get pizza" do
    get call_concierges_pizza_url
    assert_response :success
  end

  test "should get near" do
    get call_concierges_near_url
    assert_response :success
  end

  test "should get inbound_call" do
    get call_concierges_inbound_call_url
    assert_response :success
  end

  test "should get inboud_call_handler" do
    get call_concierges_inboud_call_handler_url
    assert_response :success
  end

  test "should get extension" do
    get call_concierges_extension_url
    assert_response :redirect
  end

  test "should get entry_code" do
    get call_concierges_entry_code_url
    assert_response :success
  end

end
