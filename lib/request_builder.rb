require 'nokogiri'

class RequestBuilder
  def new_action(stage, id)
    Nokogiri::HTML::Builder.new(encoding: "UTF-8") do |doc|
      doc.html {
        doc.body {
          doc.action(type: "vote", stage: stage, id: id) {
            yield doc if block_given?
          }
        }
      }
    end.doc
  end

  def transfer_key(key)
    "action_" + key.gsub(/_/, '-')
  end

  def action_param(doc, param_key, value)
    param_key = transfer_key(param_key)
    if value.is_a?(Hash)
      doc.div(value.keys[0], class: param_key) {
        action_params(doc, value.values[0])
      }
    elsif value.is_a? Array
      value.each do |each_val|
        action_param(doc, param_key, each_val)
      end
    else
      doc.div(value, class: param_key)
    end
  end

  def action_params(doc, param_hash)
    param_hash.each do |key, value|
      action_param(doc, key, value)
    end
  end

  def action(options)
    new_action(options.stage, options.id) do |doc|
      options = options.reject {|key| ["stage", "id"].include?(key) }
      action_params(doc, options)
    end
  end

  # def start(options)
  #   new_action("start", options.id) do |doc|

  #     action_params(doc, {
  #       "action-subject" => "去哪儿吃饭",
  #       "action-content" => "吃饭好啊",
  #       "action-option" => ["地点一", "地点二", "地点三"],
  #       "action-receiver" => "user@example.com"
  #     })
  #   end
  # end
end
