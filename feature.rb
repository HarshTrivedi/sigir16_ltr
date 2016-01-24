class Feature

	@@cached_feature_hash = Hash.new(nil)
	@@cached_feature_hash = nil
	attr_accessor :term, :document_id, :a, :b, :c, :d, :e

	# (a) => c(qi,d) 	| TF: term frequency in document d 
	# (b) => |d| 		| number of words (tokens) in document d
	# (c) => df(qi)		| DF: for the term (number of documents which have the term)
	# (d) => |C|		| Number of total documents (ie. the collection size)
	# (e) => c(qi,C)	| CF: number of times term is present in the whole collection (of documents)


	def initialize(term, document_id)
		posting_hash = Posting.whole[term]
		collection_term_frequency = posting_hash["size"]

		@term = term
		@document_id = document_id
		@a = posting_hash[document_id.to_i]
		@b = Document.document_term_frequencies_hash[document_id].size.to_f
		@c = posting_hash.size.to_f
		@d = Document.collection_size.to_f
		@e = collection_term_frequency.to_f
	end

	def cache(features)
		# @@cached_feature_hash["#{@term}::::#{@document_id}"] = features
	end

	def self.check_cache( token , document_id )
		# @@cached_feature_hash["#{token}::::#{document_id}"]
		nil
	end

	def one
		@a
	end

	def two
		Math::log(@a+1)
	end

	def three
		(@a.to_f/@b.to_f)
	end

	def four
		Math::log((@a.to_f/@b.to_f)+1)
	end

	def five
		Math::log((@d.to_f/@c.to_f)+1)
	end

	def six
		Math::log( Math::log(@d.to_f/@c.to_f))
	end

	def seven
		Math::log( (@d.to_f/@e.to_f)+1)
	end

	def eight
		Math::log( ((@a.to_f/@b.to_f)*(Math::log( @d.to_f/@c.to_f)))+1)
	end

	def nine
		@a.to_f*Math::log(@d.to_f/@c.to_f)
	end

	def ten
		Math::log( ((@a.to_f/@b.to_f)*(@d.to_f/@e.to_f) ) + 1)
	end

	def self.memory_occupied
		Object.memory_occupied(@@cached_feature_hash)
	end
end