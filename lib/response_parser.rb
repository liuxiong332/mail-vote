
class ResponseParser
  # merge all of the hash result into one hash container
  # @param [Array] res_array array of hash result that wants to merge
  # @return [Hash] the merged hash
  def merge_hash_res(res_array)
    merge_res = {}
    res_array.each do |res|
      res.each do |key, value|
        if merge_res.key? key
          origin_val = merge_res[key]
          unless origin_val.is_a?(Array)
            origin_val = [origin_val]
          end
          origin_val.push(value)
          merge_res[key] = origin_val
        else
          merge_res[key] = value
        end
      end
    end
    merge_res
  end

  def replace_to_underscore(str)
    str.gsub(/-/, '_')
  end
  # analyze children DOM nodes of the specific action_node, get all of action-* node params
  # @param [Nokogiri::Node] action_node the node to parse
  # @return [Hash] hash result of children of action_node
  def analyze_node_children(action_node)
    res_array = []
    action_node.element_children.each do |child|
      if child.key?("class")
        reg_res = /action-([\w-]+)/.match(child["class"])
        unless reg_res.nil?
          arg_name =  replace_to_underscore(reg_res[1])
          arg_value = child["data-value"] || child.content
        end
        child_res = analyze_node_children(child)
        if arg_name && arg_value
          if child_res
            info = {arg_name => {arg_value => child_res}}
          else
            info = {arg_name => arg_value}
          end
        else
          info = child_res
        end
        res_array.push info
      end
    end
    res_array.empty? ? nil : merge_hash_res(res_array)
  end

  # prase document and return hash result
  # for example, this code
  #    <div class="action-option" data-value="1">
  #      <div class="action-receiver">user@example.com</div>
  #    </div>
  # will parse as {option: {"1" => {receiver: user@example.com } }}
  # @param [Nokogiri::Document] doc document will to parse
  # @return [Hash] result to parse
  def parse(doc)
    action_node = doc.at_css("action[type=vote]")
    unless action_node.nil?
      hash_res = analyze_node_children(action_node)
      hash_res["stage"] = action_node["stage"]
      hash_res["id"] = action_node["id"]
      hash_res
    end
  end
end
