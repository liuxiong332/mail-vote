require "vote_server"
require "response_parser"
require "nokogiri"
require "logger"
require "ews_client"
require "action_response"

class ClientServerRunner < VoteServer
  def initialize
    super
    @ews_client = FakeEwsClient.new(@config["endpoint"], @config["email"], @config["password"])
    @action_response = ActionResponse.new(@ews_client, @mongo_client.action_collect)
    @end = false
    @logger = Logger.new("client_server_runner.log")
    @logger.level = Logger::INFO
    @email = @config["email"]
  end

  def start_vote
    @ews_client.respond_action({"stage" => "start", "id" => "0",
      "subject" => "去哪儿吃饭", "content" => "吃饭好啊",
      "promotor" => @email, "receiver" => @email,
      "option" => ["option1", "option2"]}, @email)
  end

  def promotor_start(params)

  end

  def receiver_vote(params)
    @ews_client.respond_action({"stage" => "vote", "id" => params["id"],
      "option" => "option1"}, @email)
  end

  def promotor_end(params)
    @ews_client.respond_action({"stage" => "publish", "id" => params["id"]}, @email)
  end

  def receiver_publish(params)
    @end = true
    puts "receiver publish successfully!"
  end

  def run
    puts "client run"
    # @ews_client.clear_inbox
    start_vote
    until @end
      @ews_client.sync_inbox_message(@mongo_client.sync_collect) do |item|
        parse_item(item)
      end
    end
  end

  def parse_item(item)
    if item.is_a?(Nokogiri::HTML::Document)
      html_doc = item
    else
      return if item.body_type != "HTML"
      html_doc = Nokogiri::HTML(item.body)
    end
    hash_res = ResponseParser.new.parse(html_doc)
    return if hash_res.nil?
    @logger.info hash_res
    stage = hash_res["stage"]
    if @action_response.respond_to?(stage)
      from = item.respond_to?("from") ? item.from.email_address : nil
      @action_response.send(stage, hash_res, from)
    elsif respond_to?(stage)
      send(stage, hash_res)
    end
  end
end

