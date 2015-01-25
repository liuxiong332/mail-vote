require "ews_client"
require "db_client"
require "action_response"
require "json"

class VoteServer
  def initialize
    get_config
    @ews_client = EwsClient.new(@config["endpoint"], @config["email"], @config["password"])
    @mongo_client = DBClient.new
    @action_response = ActionResponse.new(@ews_client, @mongo_client.action_collect)
  end

  def get_config
    config_file = File.expand_path("../config.json", File.dirname(__FILE__))
    @config = JSON.parse(File.read(config_file))
  end

  def run
    puts "run"
    while true
      @ews_client.sync_inbox_message(@mongo_client.sync_collect) do |item|
        parse_item(item)
      end
      sleep(30)
    end
  end

  def parse_item(item)
    return if item.body_type != "HTML"
    html_doc = Nokogiri::HTML(item.body)
    hash_res = ResponseParser.new.parse(html_doc)
    return if hash_res.nil?
    stage = hash_res["stage"]
    @action_response.send(stage, hash_res) if @action_response.respond_to?(stage)
  end
end

