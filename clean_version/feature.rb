class Feature


	attr_accessor :term, :document_id, :tdf, :d, :df, :c, :tcf, :avgdl, :idf, :du

	# (a) => c(qi,d) 	| TF: term frequency in document d 
	# (b) => |d| 		| number of words (tokens) in document d
	# (c) => df(qi)		| DF: for the term (number of documents which have the term)
	# (d) => |C|		| Number of total documents (ie. the collection size)
	# (e) => c(qi,C)	| CF: number of times term is present in the whole collection (of documents)
	# (f) => avgdl		| average document length in the text collection
	# (g) => idf		| inverse document frequency
	# (i) => du   		| vocabulary (uniq words) in document 

	def initialize(term, document_id)
		inverted_index_hash = Posting.inverted_index_hash[term]

		@term = term
		@document_id = document_id
		
		@tdf = inverted_index_hash[document_id.to_i].to_f				# Terms Frequency in Document
		@dws = Document.number_of_words_in_document[document_id].to_f	# Document word size. Number of Words in a Document
		@df = inverted_index_hash.size.to_f								# Document Frequency of the Term
		@cws = Document.number_of_words_in_collection.to_f				# Collection's words size (number of words in collection)
		@cds = Document.number_of_documents_in_collection.to_f			# Collection's document size (number of docs in collection)
		@tcf = inverted_index_hash["size"].to_f							# Term Frequency in whole collection
		@avgdl = Document.average_number_of_words_per_document.to_f		# Average Document Length (in no. of words)



		ap "#{@term} #{@cds} : #{@df}"

		@idf = Math::log((@cds-@df+0.5)/(@df+0.5))						# Inverted Document Frequency
		@du = Document.vocabulary_size_of_document[document_id].to_f	# Unique words (vocabulary) of the document

		# ap "a #{@tdf} ; b #{@d} ; c #{@cf} ; d #{@c} ; e #{@tcf} ; f #{@avgdl} ; g #{@idf}"

		k1 = 2.5 ; k3 = 0 ; b = 0.8 ;
		@@bm25 = @idf*(  ( @tdf * (k1+1))/(@tdf + k1*(1 - b + (b*(@dws/@avgdl))) )  ) * ( ((k3+1)*@tdf)/(k3+@tdf) )

		u = 2000
		@lmir_dir = (@tdf + u * ( @tcf / @cws)) / (@dws + u)

		l = 0.1
		@lmir_jm = ((1 - l) * (@tdf/@dws)) + (l)*(@tcf/@cws)

		d = 0.7
		@lmir_abs = (( [@tdf - d, 0].max )/@dws ) + ((d*@du*@tdf)/(@dws*@cws))

	end

	def one
		@tdf
	end

	def two
		Math::log(@tdf+1)
	end

	def three
		(@tdf.to_f/@dws.to_f)
	end

	def four
		Math::log((@tdf.to_f/@dws.to_f)+1)
	end

	def five
		Math::log((@cws.to_f/@df.to_f)+1)
	end

	def six
		Math::log( Math::log(@cws.to_f/@df.to_f))
	end

	def seven
		Math::log( (@cws.to_f/@tcf.to_f)+1)
	end

	def eight
		Math::log( ((@tdf.to_f/@dws.to_f)*(Math::log( @cws.to_f/@df.to_f)))+1)
	end

	def nine
		@tdf.to_f*Math::log(@cws.to_f/@df.to_f)
	end

	def ten
		Math::log( ((@tdf.to_f/@dws.to_f)*(@cws.to_f/@tcf.to_f) ) + 1)
	end

	def eleven
		@@bm25
	end

	def twelve
		Math::log(@@bm25)
	end

	def thirteen
		Math::log(@lmir_dir)
	end

	def fourteen
		Math::log(@lmir_jm)
	end

	def fifteen
		Math::log(@lmir_abs)
	end

	# def self.memory_occupied
	# 	Object.memory_occupied(@@cfached_feature_hash)
	# end
end