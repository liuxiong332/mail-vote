

class ActionResponse
  def initialize(ews_client, action_collect)
    @ews_client = ews_client
    @action_collect = action_collect
  end

  def start(params)
    params["promotor_id"] = params["id"]
    params.delete("stage")
    id = @action_collect.insert(params)
    params["id"] = id
    receiver_vote(params)
    promotor_start(params)
  end

  def receiver_vote(params)
    params["stage"] = "receiver_vote"
    @ews_client.respond_action(params, params["receiver"])
  end

  def promotor_start(params)
    params["stage"] = "promotor_start"
    @ews_client.respond_action(params, params["promotor"])
  end

  def get_item(params)
    set = @action_collect.find("_id" => params["id"]).to_a
    set.empty? ? nil : set[0]
  end

  def vote(params, from)
    item = get_item(params)
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
    @action_collect.update({"_id" => item["_id"]}, item)

    promotor_fresh(item)
    promotor_end(item)
  end

  def promotor_fresh(params)
    params["stage"] = "promotor_fresh"
    @ews_client.respond_action(params, params["promotor"])
  end

  def promotor_end(params)
    params["stage"] = "promotor_end"
    @ews_client.respond_action(params, params["promotor"])
  end

  def publish
    set = @action_collect.find("_id" => params["id"]).to_a
    return if set.empty?
    item = set[0]
    receiver_publish(item)
  end

  def receiver_publish(params)
    params["stage"] = "receiver_publish"
    @ews_client.respond_action(params, params["promotor"])
  end
end
