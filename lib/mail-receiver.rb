
require 'viewpoint'
require 'nokogiri'
require 'logger'
require 'mongo'
require 'response_parser'

include Mongo
include Viewpoint::EWS

log = Logger.new("mail-receiver")
log.level = Logger::INFO

def mongo_client
  if not @mongo_client
    @mongo_client = MongoClient.new("localhost", 27017)
  end
  @mongo_client
end

def sync_collect
  if not @sync_collect
    db = mongo_client.db("mail-vote")
    @sync_collect = db.collection("inbox_sync_state")
  end
  @sync_collect
end

Email = "vote@bolt07.com"
def ews_client
  if not @ews_client
    endpoint = "https://ex07.bolt07.com/EWS/Exchange.asmx"
    user = "vote"
    password = "a111111"

    cli = Viewpoint::EWSClient.new endpoint, user, password, http_opts: { ssl_verify_mode: 0}
    cli.ews.server_version = "none"
    @ews_client = cli
  end
  @ews_client
end

def inbox
  if not @inbox
    @inbox = ews_client.get_folder_by_name('inbox')
  end
  @inbox
end

# mail_content = File.read(File.expand_path('../output/mail.html', File.dirname(__FILE__)))
# cli.send_message(subject: "ruby send test email", body: mail_content,
#   to_recipients:  ["vote@bolt07.com"], body_type: "HTML")

ActionId = 12

def sync_inbox_message
  items = []
  sync_set = sync_collect.find(action_id: ActionId).to_a
  sync_item = sync_set.empty? ? nil : sync_set[0]
  unless inbox.synced?
    changes = inbox.sync_items!(sync_item ? sync_item["sync_state"] : nil)
    changes[:create].each do |message|
      item = ews_client.get_item(message.id)
      block_given? ? yield(item) : items.push(item)
    end
  end

  if sync_item.nil?
    sync_collect.insert({action_id: ActionId, sync_state: inbox.sync_state})
  else
    sync_item["sync_state"] = inbox.sync_state
  end
  block_given? ? items: nil
end

def parse_item(item)
  return if item.body_type != :html
  html_doc = Nokogiri::HTML(item.body)
  hash_res = ResponsePraser.new.parse(html_doc)
  return if hash_res.nil?
  stage = hash_res["stage"]
  send(stage, hash_res) if respond_to?(stage)
end



# log.info(items[0].sender.email_address)
# log.info(items[0].body)
