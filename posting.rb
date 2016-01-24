class Posting

	@@term_document_frequency_hash = Hash.new

	attr_accessor :term, :list, :hash

	def initialize(term)
		@term = term
		@list = []
		@hash = Hash.new(0)
	end

	def append_to_list(document_id, frequency)
		# ap [document_id, frequency]

		@list << [document_id.to_i, frequency.to_i]
		@hash[document_id.to_i] += frequency.to_i

		# size refers to total term frequency of term in whole collection
		@hash["size"] += frequency.to_i 
	end

	def add_list_to_whole
		@@term_document_frequency_hash[self.term] = @hash
		# @@term_document_frequency_hash[self.term]["cts"] = @hash["size"]
	end

	def self.whole
		@@term_document_frequency_hash
	end

	def self.memory_occupied
		Object.memory_occupied(self.whole)
	end

end