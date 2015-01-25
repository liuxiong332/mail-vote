require "mongo"

class DBClient
  attr_reader :sync_collect, :action_collect

  def initialize(host="localhost", port=27017)
    client = Mongo::MongoClient.new(host, port)
    @db = client.db("mail-vote")
    @sync_collect = @db.collection("inbox_sync_state")
    @action_collect = @db.collection("action")
  end
end
