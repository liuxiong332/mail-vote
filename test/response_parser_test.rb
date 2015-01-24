require "minitest/autorun"
require "nokogiri"
require "response_parser"

class TestResponseParser < Minitest::Test
  DataValue = "Hello World"
  ReceiverMail = "user@example.com"
  ID = 12
  def setup
    @doc = Nokogiri::HTML::Builder.new do |doc|
      doc.html {
        doc.body {
          doc.action(type: "vote", stage: "start", id: ID) {
            doc.div(class: "action-option", "data-value" => DataValue) {
              doc.div(ReceiverMail, class: "action-receiver")
            }
          }
        }
      }
    end.doc
  end

  def test_parse
    hash_res = ResponseParser.new.parse(@doc)
    assert_equal(hash_res["stage"], "start")
    assert_equal(hash_res["id"], ID.to_s)
    assert_equal(hash_res["option"], {DataValue => {"receiver" => ReceiverMail} })
  end
end
