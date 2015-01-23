
require 'viewpoint'
include Viewpoint::EWS

endpoint = "https://bjmail.kingsoft.com/EWS/Exchange.asmx"
user = "liuxiong"
password = "abcdABCD123456"

cli = Viewpoint::EWSClient.new endpoint, user, password, http_opts: { ssl_verify_mode: 0}

folders = cli.folders
