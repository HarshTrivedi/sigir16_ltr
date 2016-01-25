# encoding: utf-8
require 'nokogiri'
require 'awesome_print'
# require 'words_counted'
# require 'textoken'

require 'bloomfilter-rb'
require 'csv'
require "benchmark"
require 'fast_stemmer'
require "knjrbfw"
require "newrelic_rpm"

memory_checkpoints = []

$query_attribute_to_index = "summary" #summary, #description
$document_attribute_to_index = "abstract" # title, #abstract, #content

puts "Process start at : #{Time.now}"

Benchmark.bm(7) do |time|


	require File.join(Dir.pwd, "generic_class_extensions.rb")  
	require File.join(Dir.pwd, "query.rb") 
	require File.join(Dir.pwd, "document.rb")
	require File.join(Dir.pwd, "posting.rb")  
	require File.join(Dir.pwd, "feature.rb")

	$stopwords_hash = Hash.new(false)
	File.readlines(Dir.pwd+"/english_stopwords.txt").each{|word| $stopwords_hash[word.strip.downcase] = true } 

	Query.load_from_xml( Dir.pwd + "/query_topics.xml")
	Query.compute_vocabulary

	term_document_frequency_hash = Hash.new
	document_id_length_hash = Hash.new
	document_collection_size = 0

	for token in Query.vocabulary
		term_document_frequency_hash[token] = Hash.new(0)
	end

	ap "Memory Occupied at Check 1: #{memory_occupied}"

	total_number_of_documents = Dir[ Dir.pwd + '/documents/*.xml'].entries.size
	Dir[ Dir.pwd + '/documents/*.xml'].each do |file_name|
		document = Document.new(file_name)
		document_text = File.open( document.file_path ) { |f| Nokogiri::XML(f) }.css( $document_attribute_to_index ).text
		document_tokens = document_text.tokenize
		document_tokens = document_tokens.filter
		
		document_id_length_hash[document.id] = document_tokens.size
		document_collection_size += document_tokens.size
		Document.document_id_length_hash[document.id] = document_tokens.size
		Document.document_id_vocab_size_hash[document.id] = document_tokens.uniq.size
		document_tokens.each{|token| 
			if term_document_frequency_hash[token] == nil 
				term_document_frequency_hash[token] = Hash.new(0)
			end
			term_document_frequency_hash[token][document.id] += 1

			if term_document_frequency_hash[token]["size"].nil?
				term_document_frequency_hash[token]["size"] = Hash.new(0)
			end
			term_document_frequency_hash[token]["size"] += 1
		}
	end

	Document.collection_size = document_collection_size

	Document.average_document_length = document_collection_size.to_f /  total_number_of_documents.to_f

	ap "Memory Occupied at Check 2: #{memory_occupied}"
	puts "First Part Complete at : #{Time.now}"


	Posting.set_whole(term_document_frequency_hash)
	final_feature_set = []

	for query in Query.all
		for document_id in Document.ids
			feats = query.compute_features(document_id)
			final_feature_set << ["#{query.id}:#{document_id}"] + feats
		end
		puts "Completed query #{query.id}"
	end

	puts "Feature computation complete at : #{Time.now}"

	CSV.open(Dir.pwd + "/output/features.csv" , "w") do |csv_object|
		final_feature_set.each do |row_array|
			csv_object << row_array
		end
	end

	puts "Whole process complete at : #{Time.now}"

	ap "Memory Occupied at Check 3: #{memory_occupied}"
end

ap "COMPLEDTED! with memory_checkpoints: #{memory_checkpoints}"
