

class MongoClient

  attr_accessor sync_collect

  def initialize(host="localhost", port=27017)
    @mongo_client = MongoClient.new(host, port)

    @db = mongo_client.db("mail-vote")
    @sync_collect = @db.collection("inbox_sync_state")
  end
end
