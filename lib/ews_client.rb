require 'request_builder'
require "viewpoint"

class EwsClient
  attr_accessor :email

  def initialize(endpoint, email, password)
    @email = email
    user = /\A(\w+)/.match(email)[1]
    cli = Viewpoint::EWSClient.new(endpoint, user, password, http_opts: { ssl_verify_mode: 0})
    cli.ews.server_version = "none"
    @ews_client = cli
    @inbox = @ews_client.get_folder_by_name('inbox')

    @request_builder = RequestBuilder.new
  end

  def sync_inbox_message(sync_collect)
    items = []
    sync_item = sync_collect.find_one
    unless @inbox.synced?
      changes = @inbox.sync_items!(sync_item ? sync_item["sync_state"] : nil)
      changes && changes.key?(:create) && changes[:create].each do |message|
        item = @ews_client.get_item(message.id)
        block_given? ? yield(item) : items.push(item)
      end
    end

    if sync_item.nil?
      sync_collect.insert({sync_state: @inbox.sync_state})
    else
      sync_item["sync_state"] = @inbox.sync_state
      sync_collect.update({"_id" => sync_item["_id"]}, sync_item)
    end
    block_given? ? items: nil
  end

  # respond to to_recipients by sending message
  # @param [Hash] options to build document
  # @option opts [Array] :to_recipients An array of e-mail addresses to send to
  # @return [Message,Boolean] Returns true if the message is sent, false if
  def respond_action(options, to_recipients)
    to_recipients = [to_recipients] unless to_recipients.is_a?(Array)
    doc = @request_builder.action(options)
    msg, send_res = @ews_client.send_message(subject: options["subject"], body: doc.to_s,
      body_type: "HTML", to_recipients: to_recipients)
  end

  def clear_inbox
    @inbox.items.each {|item| item.delete! }
  end
end

class FakeEwsClient
  attr_accessor :email

  def initialize(endpoint, email, password)
    @email = email
    @mails = []
    @request_builder = RequestBuilder.new
  end

  def sync_inbox_message(sync_collect)
    yield @mails.pop
  end

  # respond to to_recipients by sending message
  # @param [Hash] options to build document
  # @option opts [Array] :to_recipients An array of e-mail addresses to send to
  # @return [Message,Boolean] Returns true if the message is sent, false if
  def respond_action(options, to_recipients)
    doc = @request_builder.action(options)
    @mails.push(doc)
  end

  def clear_inbox
  end
end
