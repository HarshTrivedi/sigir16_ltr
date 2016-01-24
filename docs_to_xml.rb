require 'nokogiri'
require 'awesome_print'


Dir['/home/harsh/sigir_workspace/documents/*'].each do |file_name|
	title, abstract, content = File.readlines(file_name)


	builder = Nokogiri::XML::Builder.new do |xml|
		xml.document {
			xml.id File.basename(file_name)
		    xml.title title
		    xml.abstract abstract.gsub("Abstract: ", "\n ")
		    xml.content content.gsub("Content: ", "\n ")
		  }
	end

	File.open(file_name + ".xml", "w") do |file|
		file.puts builder.to_xml
	end
	File.delete(file_name)
end

#2648745