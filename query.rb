class Query

	@@all_queries = []
	@@vocabulary = []
	attr_accessor :id, :description, :summary

	def initialize(id, description, summary)
		@id = id
		@description = description
		@summary = summary
	end

	def self.load_from_xml(query_topic_file_path)
		query_topics = File.open( query_topic_file_path) { |f| Nokogiri::XML(f) }		
		for topic in query_topics.css("topic")
			id = topic.attribute("number").value
			description = topic.css("description").text
			summary = topic.css("summary").text
			query = Query.new(id, description, summary)
			@@all_queries << query
		end
	end

	def self.all
		@@all_queries
	end

	def self.compute_vocabulary
		if $query_attribute_to_index == "summary"
			@@vocabulary = @@all_queries.map(&:summary).join(" ").tokenize.uniq.filter
		elsif $query_attribute_to_index == "description"
			@@vocabulary = @@all_queries.map(&:description).join(" ").tokenize.uniq.filter
		end
	end

	def self.vocabulary
		@@vocabulary
	end

	def compute_features(document_id)

		if $query_attribute_to_index == "summary"
			tokens = self.summary.tokenize.filter
		elsif $query_attribute_to_index == "description"
			tokens = self.description.tokenize.filter			
		end

		sum_one = 0
		sum_two = 0
		sum_three = 0
		sum_four = 0
		sum_five = 0
		sum_six = 0
		sum_seven = 0
		sum_eight = 0
		sum_night = 0
		sum_ten = 0

		for token in tokens
			feature = Feature.new( token , document_id )
			cached_feats = Feature.check_cache( token , document_id )
			if cached_feats.nil? or cached_feats.empty?
				# ap "NO HIT POSSIBLE"
				feat_1 = feature.one ; sum_one += feat_1
				feat_2 = feature.two ; sum_two += feat_2
				feat_3 = feature.three ; sum_three += feat_3
				feat_4 = feature.four ; sum_four += feat_4
				feat_5 = feature.five ; sum_five += feat_5
				feat_6 = feature.six ; sum_six += feat_6
				feat_7 = feature.seven ; sum_seven += feat_7
				feat_8 = feature.eight ; sum_eight += feat_8
			else
				# ap "PING. I HIT THE CACHE !!!!!!!!!!!!!!!!!!!!!!!!!!!! : #{cached_feats.inspect}"
				feat_1, feat_2, feat_3, feat_4, feat_5, feat_6, feat_7, feat_8 = cached_feats
				sum_one += feat_1
				sum_two += feat_2
				sum_three += feat_3
				sum_four += feat_4
				sum_five += feat_5
				sum_six += feat_6
				sum_seven += feat_7
				sum_eight += feat_8
			end

			feature.cache([feat_1, feat_2, feat_3, feat_4, feat_5, feat_6, feat_7, feat_8])
		end

		[sum_one, sum_two, sum_three, sum_four, sum_five, sum_six, sum_seven, sum_eight]
	end

	def self.memory_occupied
		Object.memory_occupied(@@all_queries) + 
		Object.memory_occupied(@@vocabulary)			
	end

end