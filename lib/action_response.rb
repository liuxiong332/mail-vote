

class ActionResponse
  def initialize(ews_client, action_collect)
    @ews_client = ews_client
    @action_collect = action_collect
  end

  def start(params, from)
    params["promotor_id"] = params["id"]
    params.delete("stage")
    id = @action_collect.insert(params)
    params["id"] = id.to_s
    item = get_item(params)
    puts item ? "insert item not nil" : "insert item is nil"

    receiver_vote_request(params)
    promotor_start_request(params)
  end

  def receiver_vote_request(params)
    params["stage"] = "receiver_vote"
    @ews_client.respond_action(params, params["receiver"])
  end

  def promotor_start_request(params)
    params["stage"] = "promotor_start"
    @ews_client.respond_action(params, params["promotor"])
  end

  def get_item(params)
    id = params["id"].is_a?(String) ? BSON::ObjectId.from_string(params["id"]) : params["id"]
    set = @action_collect.find("_id" => id).to_a
    set.empty? ? nil : set[0]
  end

  def vote(params, from)
    item = get_item(params)
    puts item ? item : "item is nil"
    return if item.nil?
    options = item["option"]

    if options.is_a?(Array)
      origin_options = item["option"]
      options = item["option"] = {}
      origin_options.each {|val| options[val] = nil}
    end

    user_option = params["option"]
    if options[user_option].nil?
      options[user_option] = []
    end
    options[user_option].push({"receiver" => from})
    puts "generate item:", item
    @action_collect.update({"_id" => item["_id"]}, item)

    promotor_fresh_request(item)
    promotor_end_request(item)
  end

  def promotor_fresh_request(params)
    params["stage"] = "promotor_fresh"
    @ews_client.respond_action(params, params["promotor"])
  end

  def promotor_end_request(params)
    params["stage"] = "promotor_end"
    @ews_client.respond_action(params, params["promotor"])
  end

  def publish(params, from)
    item = get_item(params)
    receiver_publish(item)
  end

  def receiver_publish_request(params)
    params["stage"] = "receiver_publish"
    @ews_client.respond_action(params, params["promotor"])
  end
end
