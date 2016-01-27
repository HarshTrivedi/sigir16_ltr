# encoding: utf-8


class String

	def tokenize
		# ap self
		# WordsCounted::Tokeniser.new(self).tokenise
		# Textoken(self).tokens
		self.scan(/[\p{Alpha}\-']+/).map(&:downcase)

	end

	def is_stop_word?
		# $bloomfilter.include?(self.strip.downcase)
		$stopwords_hash[self.strip.downcase]
	end

end

class Array

	def filter_out_stopwords
		self.select{|x| not x.is_stop_word?}
	end

	def filter
		self.map{|element|
			if element.is_stop_word?
				nil
			else
				element.stem
			end
		}.compact
	end

end

class Object

	def memory_occupied
		Knj::Memory_analyzer::Object_size_counter.new(self)
	end

	def self.memory_occupied(obj)
		(Knj::Memory_analyzer::Object_size_counter.new(obj).calculate_size / (1024.0 * 1024.0))#.to_i
	end

end


def memory_occupied
	NewRelic::Agent::Samplers::MemorySampler.new.sampler.get_sample.to_i
end

def object_memory_occupied(obj)
	(Knj::Memory_analyzer::Object_size_counter.new(obj).calculate_size / (1024.0 * 1024.0)).to_i
end



