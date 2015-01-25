require "minitest/autorun"
require "request_builder"

class TestRequestBuilder < Minitest::Test
  def setup
    @builder = RequestBuilder.new
  end

  def test_new_action
    doc = @builder.new_action("start", 12)
    node_set = doc.css("action[type=vote]")
    assert !node_set.empty?
    assert_equal node_set[0]["stage"], "start"
  end

  def test_action_param
    doc = @builder.new_action("start", 12) do |doc|
      @builder.action_param(doc, "option", "value")
      @builder.action_params(doc, {option: {"situation 1" => {receiver: "people"}}})
    end

    assert_equal doc.at_css("[class=action-option]").content, "value"
    assert_equal doc.at_css("[class=action-option][data-value='situation 1']")
      .at_css("[class=action-receiver]").content, "people"
  end
end
