
require 'viewpoint'
include Viewpoint::EWS

endpoint = "https://ex07.bolt07.com/EWS/Exchange.asmx"
user = "vote"
password = "a111111"

cli = Viewpoint::EWSClient.new endpoint, user, password, http_opts: { ssl_verify_mode: 0}
cli.ews.server_version = "none"

mail_content = File.read(File.expand_path('../output/mail.html', File.dirname(__FILE__)))
cli.send_message(subject: "ruby send test email", body: mail_content,
  to_recipients:  ["vote@bolt07.com"], body_type: "HTML")
