class Feature

	@@cached_feature_hash = Hash.new(nil)
	@@cached_feature_hash = nil
	attr_accessor :term, :document_id, :a, :b, :c, :d, :e

	# (a) => c(qi,d) 	| TF: term frequency in document d 
	# (b) => |d| 		| number of words (tokens) in document d
	# (c) => df(qi)		| DF: for the term (number of documents which have the term)
	# (d) => |C|		| Number of total documents (ie. the collection size)
	# (e) => c(qi,C)	| CF: number of times term is present in the whole collection (of documents)
	# (f) => avgdl		| average document length in the text collection
	# (g) => idf		| inverse document frequency

	def initialize(term, document_id)
		posting_hash = Posting.whole[term]
		collection_term_frequency = posting_hash["size"]

		@term = term
		@document_id = document_id
		@a = posting_hash[document_id.to_i]
		@b = Document.document_id_length_hash[document_id].to_f
		@c = posting_hash.size.to_f
		@d = Document.collection_size.to_f
		@e = collection_term_frequency.to_f
		@f = Document.average_document_length.to_f
		@g = Math::log((@d-@c+0.5)/(@c+0.5))

		# ap "a #{@a} ; b #{@b} ; c #{@c} ; d #{@d} ; e #{@e} ; f #{@f} ; g #{@g}"

		k1 = 2.5 ; k3 = 0 ; b = 0.8 ;
		@bm25 = @g*(  ( @a * (k1+1))/(@a + k1*(1 - b + (b*(@b/@f))) )  ) * ( ((k3+1)*@a)/(k3+@a) )

		u = 2000
		@lmir_dir = (@a + u * ( @a / @d)) / (@e + u)

		l = 0.1
		@lmir_jm = ((1 - l) * (@a/@e)) + (l)*(@a/@d)

		# d = 0.7
		# @lmir_abs = (( [@a - d, 0].max )/@e ) + ((d*X*@a)/(@b*@d))

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

	def eleven
		@bm25
	end

	def twelve
		Math::log(@bm25)
	end

	def thirteen
		@lmir_dir
	end

	def fourteen
		@lmir_jm
	end

	def fifteen
		@lmir_abs
	end

	def self.memory_occupied
		Object.memory_occupied(@@cached_feature_hash)
	end
end