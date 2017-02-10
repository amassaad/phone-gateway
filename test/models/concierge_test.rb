require 'test_helper'

class ConciergeTest < ActiveSupport::TestCase
  test "can set counter" do
    c = Concierge.new
    assert_equal false, c.counter?

    c.counter = 1
    assert_equal true, c.counter?
  end

  test "can set bypass" do
    c = Concierge.new
    assert_equal false, c.bypass?

    c.bypass = 1
    assert_equal true, c.bypass?
  end
end
