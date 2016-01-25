class Posting

	@@term_document_frequency_hash = Hash.new

	attr_accessor :term, :hash #, :list

	def initialize(term)
		@term = term
		@list = []
		@hash = Hash.new(0)
	end

	def append_to_list(document_id, frequency)
		@hash[document_id.to_i] += frequency.to_i
		@hash["size"] += frequency.to_i 
	end

	def add_list_to_whole
		@@term_document_frequency_hash[self.term] = @hash
	end

	def self.whole
		@@term_document_frequency_hash
	end

	def self.memory_occupied
		Object.memory_occupied(self.whole)
	end

	def self.set_whole(term_document_frequency_hash)
		@@term_document_frequency_hash = term_document_frequency_hash
	end

end