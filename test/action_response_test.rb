require "minitest/autorun"
require "action_response"
require 'request_builder'

class EwsClientMock
  attr_accessor :responds
  def initialize
    @request_builder = RequestBuilder.new
    @responds = []
  end

  def respond_action(options, to_recipients)
    @responds.push options.clone
  end
end

class ActionCollectMock
  attr_accessor :items
  def initialize
    @items = []
  end

  def insert(item)
    item = item.clone
    item["_id"] = @items.length
    @items.push(item)
    @items.length - 1
  end

  def update(condition, item)
    puts condition["_id"]

    @items[condition["_id"]] = item
  end

  def find(condition)
    @items[condition["_id"]]
  end
end

class TestActionResponse < Minitest::Test
  def setup
    @ews_client = EwsClientMock.new
    @action_collect = ActionCollectMock.new
    @action_response = ActionResponse.new(@ews_client, @action_collect)
    def @action_response.get_item(params)
      @action_collect.find("_id" => params["id"])
    end
  end

  def test_start
    params = {"receiver" => "receiver1", "promotor" => "promotor1", "id" => 11, "stage" => "start"}
    @action_response.start(params)
    assert_equal @ews_client.responds[0], {"id" => 0, "promotor_id" => 11, "receiver" => "receiver1",
      "promotor" => "promotor1", "stage" => "receiver_vote"}
    assert_equal @ews_client.responds[1], {"id" => 0, "promotor_id" => 11, "receiver" => "receiver1",
      "promotor" => "promotor1", "stage" => "promotor_start"}
  end

  def test_vote
    params = {"receiver" => "receiver1", "promotor" => "promotor1", "id" => 11, "stage" => "start",
      "option" => ["option1", "option2"] }
    @action_response.start(params)
    vote_params = {"id" => 0, "option" => "option1"}
    @action_response.vote(vote_params, "receiver1")
  end
end
