
require 'awesome_print'
faulty_files = []
count = 0
Dir[ Dir.pwd + '/documents/*'].each do |file_name|
	x = File.readlines(file_name).join(" ")
	y = x.chars.select(&:valid_encoding?).join
	faulty_files << file_name if x != y
	count += 1
	puts count
end

ap faulty_files
