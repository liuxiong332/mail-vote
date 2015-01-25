
require 'viewpoint'
require 'nokogiri'
require 'logger'
require 'mongo'
# require 'response_parser'

include Mongo
include Viewpoint::EWS

log = Logger.new("mail-receiver")
log.level = Logger::INFO


Email = "vote@bolt07.com"


# mail_content = File.read(File.expand_path('../output/mail.html', File.dirname(__FILE__)))
# cli.send_message(subject: "ruby send test email", body: mail_content,
#   to_recipients:  ["vote@bolt07.com"], body_type: "HTML")

ActionId = 12



def parse_item(item)
  return if item.body_type != :html
  html_doc = Nokogiri::HTML(item.body)
  hash_res = ResponsePraser.new.parse(html_doc)
  return if hash_res.nil?
  stage = hash_res["stage"]
  send(stage, hash_res) if respond_to?(stage)
end


 mongo_client = MongoClient.new("localhost", 27017)

db = mongo_client.db("mail-vote")
test_collect = db.collection("test")
id = test_collect.insert({stage: "start", id: "my_id", option: ["option 1", "option 2"] })
doc = test_collect.find(_id: id).to_a[0]
puts doc.to_s
doc["id"] = "next_id"
puts doc.to_s
doc["option"][0] = {doc["option"][0] => {"receiver" => "liuxiong"} }
puts doc.to_s
test_collect.update({_id: id}, doc)
puts test_collect.find(_id: id).to_a[0].to_s

# log.info(items[0].sender.email_address)
# log.info(items[0].body)
