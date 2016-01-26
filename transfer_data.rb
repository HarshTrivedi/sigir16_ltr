require 'nokogiri'
require 'awesome_print'

root_path = "/home/irlplab/Documents/Data/CDS/text_format/"

# faulty_files = []
# count = 0
# counter = 0

# Dir[ root_path + '/*/*/*'].each do |file_name|
# 	# ap file_name
# 	x = File.readlines(file_name).join(" ")
# 	y = x.chars.select(&:valid_encoding?).join
# 	if x != y
# 		File.delete(file_name)
# 		faulty_files << file_name 
# 	end
# 	count += 1
# 	counter += 1
# 	if (counter == 1000)
# 		puts count 
# 		counter = 0		
# 	end
# end

# ap faulty_files

target_path = "/home/irlplab/Desktop/Harsh/sigir16_ltr/preprocessed_documents/"

count = 0
counter = 0
Dir[ root_path + '/*/*/*'].each do |file_name|
	title, abstract, content = File.readlines(file_name)

	base_name = File.basename(file_name)
	builder = Nokogiri::XML::Builder.new do |xml|
		xml.document {
			xml.id base_name
		    xml.title title
		    xml.abstract abstract.gsub("Abstract: ", "\n ")
		    xml.content content.gsub("Content: ", "\n ")
		  }
	end

	File.open( target_path + base_name + ".xml", "w") do |file|
		file.puts builder.to_xml
	end

	count += 1
	counter += 1
	if (counter == 1000)
		puts count 
		counter = 0		
	end

end
