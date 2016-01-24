# encoding: utf-8
require 'nokogiri'
require 'awesome_print'
require 'words_counted'
require 'bloomfilter-rb'
require 'csv'
require "benchmark"
require 'fast_stemmer'
require "knjrbfw"
require "newrelic_rpm"

memory_checkpoints = []

$query_attribute_to_index = "summary" #summary, #description
$document_attribute_to_index = "abstract" # title, #abstract, #content


Benchmark.bm(7) do |time|


	time.report("Completed loading required classes in:"){
		require File.join(Dir.pwd, "generic_class_extensions.rb")  
		require File.join(Dir.pwd, "query.rb") 
		require File.join(Dir.pwd, "document.rb")
		require File.join(Dir.pwd, "posting.rb")  
		require File.join(Dir.pwd, "feature.rb")
	}#ap "Completed loading required classes."

	time.report("Completed loading stop words in:"){
		$stopwords_hash = Hash.new(false)
		File.readlines(Dir.pwd+"/english_stopwords.txt").each{|word| $stopwords_hash[word.strip.downcase] = true } 
	}#ap "Completed loading stop words"

	time.report("Completed loading Query class in:"){
		Query.load_from_xml( Dir.pwd + "/query_topics.xml")
		Query.compute_vocabulary
	}#ap "Completed loading Query class"

	ap "Memory Occupied at Check 1: #{memory_occupied}" ; memory_checkpoints << memory_occupied
	ap "Memory Occupied by Queries : #{Query.memory_occupied}"

	## compute and store termfrequencies for each document
	time.report("Completed all Documents loading in:"){
		Dir['/home/harsh/sigir_workspace/documents/*.xml'].each do |file_name|
			document = Document.new(file_name)
			document.save_term_frequencies
		end
		ap "Completed saving term frequencies"
		document_collection_size = 0.0
		Document.ids.each{|id| document_collection_size += Document.document_id_length_hash[id].to_f }
		Document.collection_size = document_collection_size
		ap "Completed pre-calculating required attributes"
	}
	ap "Memory Occupied at Check 2: #{memory_occupied}" ; memory_checkpoints << memory_occupied
	ap "Memory Occupied by Documents : #{Document.memory_occupied}"

	## compute postings list for each term in query vocabulary
	ap "About to start postings computation: (#{Query.vocabulary.size} terms)"
	count = 0
	vocabulary_size = Query.vocabulary.size
	time.report("Completed postings computation in:"){
		for query_term in Query.vocabulary
			posting = Posting.new(query_term)
			Document.document_term_frequencies_hash.each do |document_id, document_term_frequency_hash|
				document_term_frequency_hash.each do |term, frequency|
					if query_term == term
						posting.append_to_list(document_id.to_i, frequency.to_i)
					end
				end
			end
			posting.add_list_to_whole
			count += 1 
			ap ("#{count} terms of Query Vocabulary(#{vocabulary_size}) completed")
		end
	}#ap "Completed postings computation"

	ap "Memory Occupied at Check 3: #{memory_occupied}" ; memory_checkpoints << memory_occupied
	ap "Memory Occupied by posting : #{Posting.memory_occupied}"

	ap "About to start postings computation: (#{Query.vocabulary.size} terms)"
	final_feature_set = []
	time.report("Completed Computing Features in:"){
		for query in Query.all
			for document_id in Document.ids
				feats = query.compute_features(document_id)
				final_feature_set << ["#{query.id}:#{document_id}"] + feats
			end
			puts "Completed query #{query.id}"
		end
		CSV.open(Dir.pwd + "/output/features.csv" , "w") do |csv_object|
			final_feature_set.each do |row_array|
				csv_object << row_array
			end
		end
	}

	ap "Memory Occupied at Check 4: #{memory_occupied}" ; memory_checkpoints << memory_occupied
	ap "Memory Occupied by Feature : #{Object.memory_occupied( final_feature_set )}"

end

ap "COMPLEDTED! with memory_checkpoints: #{memory_checkpoints}"

ap "Memory Occupied by Queries : #{Query.memory_occupied}"
ap "Memory Occupied by Feature : #{Feature.memory_occupied}"
ap "Memory Occupied by Documents : #{Document.memory_occupied}"
ap "Memory Occupied by posting : #{Posting.memory_occupied}"