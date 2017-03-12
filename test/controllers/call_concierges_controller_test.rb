require 'test_helper'
# require 'nokogiri'
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

  test "inbound_call should produce valid xml" do
    get call_concierges_inbound_call_url
    # byebug
    doc = Nokogiri::XML(@response.body)
    assert_empty doc.errors
  end
end
