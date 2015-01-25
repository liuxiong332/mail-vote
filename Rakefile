require 'rake/testtask'

# Dir["asset/*.html"].each do |html_file|
# 	file_content = File.read(html_file)
# 	doc = Nokogiri::HTML(file_content)
# end
# log = Logger.new(STDOUT)
# log.level = Logger::DEBUG
# log.info File.expand_path('mail.html', File.dirname(__FILE__) + '/asset')

# directory "output"
# file "output/mail.html" => ["asset/mail.html", "output"] do |t|
# 	file_content = File.read("asset/mail.html")
# 	doc = Nokogiri::HTML(file_content, nil, "UTF-8")
# 	links = doc.xpath "//link"
# 	links.each do |link_node|
# 		if link_node.key?("href")
# 			relative_path = link_node["href"]
# 			link_file_path = File.expand_path relative_path, File.dirname(__FILE__) + '/asset'
# 			new_link = doc.create_element('style', File.read(link_file_path), type: "text/css")
# 			link_node.replace new_link
# 		end
# 	end

# 	File.write(t.name, doc.to_s, mode: "w+")
# end

Rake::TestTask.new do |t|
	t.libs << "lib"
	t.test_files = FileList['test/*_test.rb']
end

task :run do
	ruby "-Ilib lib/run_server.rb"
end

task :autorun do
	ruby "-Ilib lib/autorun.rb"
end
