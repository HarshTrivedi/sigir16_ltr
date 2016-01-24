class Document

	@@ids = []
	@@document_term_frequencies_hash = Hash.new
	@@document_id_length_hash = Hash.new(0)
	@@collection_size = 0

	attr_accessor :id, :file_path #, :term_frequencies_path

	def initialize(file_name)
	    @id = File.basename(file_name).to_i
	    @file_path = file_name
		@@ids << self.id.to_i
	end

	def save_term_frequencies
		
		document_text = File.open( self.file_path ) { |f| Nokogiri::XML(f) }.css( $document_attribute_to_index ).text

		document_tokens = document_text.tokenize
		document_tokens = document_tokens.filter
		@@document_id_length_hash[self.id] = document_tokens.size

		# term_frequencies_hash = Hash.new(0)
		@@document_term_frequencies_hash[self.id] = Hash.new(0)

		document_tokens.each{|token| 
			# term_frequencies_hash[token] += 1
			@@document_term_frequencies_hash[self.id][token] += 1
		}

		# CSV.open(Dir.pwd + "/term_frequencies/#{self.id}" , "w") do |csv_object|
		# 	term_frequencies_hash.to_a.each do |row_array|
		# 		csv_object << row_array
		# 	end
		# end
		# @term_frequencies_path = (Dir.pwd + "/term_frequencies/#{self.id}")

	end

	def self.document_term_frequencies_hash
		@@document_term_frequencies_hash
	end

	def self.document_id_length_hash=(document_id_length_hash)
		@@document_id_length_hash = document_id_length_hash
	end

	def self.document_id_length_hash
		@@document_id_length_hash
	end

	def self.collection_size=(collection_size)
		@@collection_size = collection_size
	end

	def self.collection_size
		@@collection_size
	end

	def self.ids
		@@ids
	end

	def self.memory_occupied
		(Object.memory_occupied( self.document_term_frequencies_hash ) + 
			Object.memory_occupied( self.document_id_length_hash ) + 
			Object.memory_occupied( self.collection_size ) + 
			Object.memory_occupied( self.ids ) )
	end
end