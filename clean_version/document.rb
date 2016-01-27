class Document

	@@ids = []
	@@document_term_frequencies_hash = Hash.new
	@@number_of_words_in_document = Hash.new(0)
	@@number_of_words_in_collection = 0
	@@average_number_of_words_per_document = 0
	@@vocabulary_size_of_document = Hash.new(0)
	@@number_of_documents_in_collection = 0

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
		@@number_of_words_in_document[self.id] = document_tokens.size

		@@document_term_frequencies_hash[self.id] = Hash.new(0)

		document_tokens.each{|token| 
			@@document_term_frequencies_hash[self.id][token] += 1
		}
	end

	def self.document_term_frequencies_hash
		@@document_term_frequencies_hash
	end

	def self.number_of_words_in_document=(number_of_words_in_document)
		@@number_of_words_in_document = number_of_words_in_document
	end

	def self.number_of_words_in_document
		@@number_of_words_in_document
	end

	def self.number_of_words_in_collection=(number_of_words_in_collection)
		@@number_of_words_in_collection = number_of_words_in_collection
	end

	def self.number_of_words_in_collection
		@@number_of_words_in_collection
	end

	def self.ids
		@@ids
	end

	def self.memory_occupied
		(Object.memory_occupied( self.document_term_frequencies_hash ) + 
			Object.memory_occupied( self.number_of_words_in_document ) + 
			Object.memory_occupied( self.number_of_words_in_collection ) + 
			Object.memory_occupied( self.ids ) )
	end

	def self.average_number_of_words_per_document=(average_number_of_words_per_document)
		@@average_number_of_words_per_document = average_number_of_words_per_document
	end

	def self.average_number_of_words_per_document
		@@average_number_of_words_per_document
	end

	def self.vocabulary_size_of_document
		@@vocabulary_size_of_document
	end

	def self.vocabulary_size_of_document=(vocabulary_size_of_document)
		@@vocabulary_size_of_document
	end

	def self.number_of_documents_in_collection
		@@number_of_documents_in_collection
	end

	def self.number_of_documents_in_collection=(number_of_documents_in_collection)
		@@number_of_documents_in_collection = number_of_documents_in_collection
	end


end