class Posting

	@@inverted_index_hash = Hash.new(Hash.new(0))

	def self.memory_occupied
		Object.memory_occupied(self.whole)
	end

	def self.inverted_index_hash
		@@inverted_index_hash
	end

	def self.inverted_index_hash=(inverted_index_hash)
		@@inverted_index_hash = inverted_index_hash
	end

end