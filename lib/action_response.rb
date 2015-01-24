

class ActionResponse
  def initialize(ews_client, action_collect)
    @ews_client = ews_client
    @action_collect = action_collect
  end

  def start(params)
    params[:promotor_id] = params["id"]
    params.delete("stage")
    id = action_collect.insert(params)
    params[:id] = id
    receiver_vote(params)
    promotor_start(params)
  end

  def receiver_vote(params)
    params["stage"] = "receiver_vote"
    @ews_client.respond_action(params, params["receiver"])
  end

  def promotor_start(params)
    params["stage"] = "receiver_vote"
    @ews_client.respond_action(params, params["promotor"])
  end

  def vote(params, from)
    set = @action_collect.find("_id" => params["id"]).to_a
    return if set.empty?
    res = set[0]
    option = params["option"]
    unless res["option"][option].is_a?(Array)
      res["option"][option] = []
    end
    res["option"][option].push(from)
  end

  def publish
  end
end
