
require 'viewpoint'
require 'nokogiri'
require 'logger'
require 'mongo'

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

def ews_client
  if not @ews_client
    endpoint = "https://ex07.bolt07.com/EWS/Exchange.asmx"
    email = "vote@bolt07.com"
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

def analyze_content(item)
  if (item.body_type != :html)
    return
    html_doc = Nokogiri::HTML(item.body)
    action_node = html_doc.at_css("action[type=vote]")
    return if action_node.nil?
    action_info = {stage: action_node["stage"], id: action_node["id"]}

end

def analyze_action_node(action_node)
  child_nodes = action_node.xpath('/*[starts-with(@class, "action-"')
  child_nodes.each do |node|
    reg_res = /action-(\w+)/.match(node["class"])
    next if reg_res.nil?
    arg_name =  reg_res[1]
    arg_value = node["data-value"] || node.content

  end
end

def build_start_html
  builder = Nokogiri::HTML::Builder.new(encoding: "UTF-8") do |doc|
    doc.html {
      doc.body {
        doc.action(type: "vote", state: "start", id: ActionId) {
          doc.div("去哪儿吃饭", class: "action-subject")
          doc.div("吃饭好啊", class: "action-content")
          doc.div("地点一", class: "action-option")
          doc.div("地点二", class: "action-option")
          doc.div("地点三", class: "action-option")
          doc.div(email, class: "action-receiver")
        }
      }
    }
  end
end

# log.info(items[0].sender.email_address)
# log.info(items[0].body)
