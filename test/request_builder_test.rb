require "minitest/autorun"
require "request_builder"

class TestRequestBuilder < Minitest::Test
  def setup
    @builder = RequestBuilder.new
  end

  def test_new_action
    doc = @builder.new_action("start")
    node_set = doc.css("action[type=vote]")
    assert !node_set.empty?
    assert_equal node_set[0]["stage"], "start"
  end

  def test_action_param
    doc = @builder.new_action("start") do |doc|
      @builder.action_param(doc, "action-option", "value")
    end
    assert_equal doc.at_css("[class=action-option]").content, "value"
  end
end
