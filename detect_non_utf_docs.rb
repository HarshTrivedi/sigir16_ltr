
require 'awesome_print'
faulty_files = []
Dir['/home/harsh/sigir_workspace/documents/*'].each do |file_name|
	x = File.readlines(file_name).join(" ")
	y = x.chars.select(&:valid_encoding?).join
	faulty_files << file_name if x != y
end

ap faulty_files
