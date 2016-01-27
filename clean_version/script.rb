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
$document_attribute_to_index = "title|abstract" # title, #abstract, #content
$documents_path = "/home/harsh/Desktop/clean_workplace/documents"

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

	# number_of_words_in_document
	# number_of_words_in_collection
	# vocabulary_size_of_document
	# number_of_documents_in_collection
	# average_number_of_words_per_document

	Document.number_of_documents_in_collection = Dir[ $documents_path + '/*.xml'  ].entries.size

	count = 0
	counter = 0
	# inverted_index_hash = Posting.inverted_index_hash
	inverted_index_hash = Hash.new()
	Dir[ $documents_path + '/*.xml' ].each do |file_name|

		document = Document.new(file_name)
		attributes = $document_attribute_to_index.split("|") ; document_text = ""
		attributes.each{ |attribute|
			document_text += File.open( document.file_path ) { |f| Nokogiri::XML(f) }.css( attribute ).text  
		}

		document_tokens = document_text.tokenize.filter		
		Document.number_of_words_in_collection += document_tokens.size		
		Document.number_of_words_in_document[document.id] = document_tokens.size
		Document.vocabulary_size_of_document[document.id] = document_tokens.uniq.size

		ap document_tokens.size
		document_tokens.each{|token|
			inverted_index_hash[token] = Hash.new(0) if inverted_index_hash[token].nil?
			inverted_index_hash[token][document.id] += 1
			inverted_index_hash[token]["size"] += 1
		}
		# ap inverted_index_hash
		count += 1 ; counter += 1
		if (counter == 1000)
			puts "Documents Loaded #{count} "
			counter = 0
		end
	end
	Document.average_number_of_words_per_document = Document.number_of_words_in_collection.to_f /  Document.number_of_documents_in_collection.to_f
	Posting.inverted_index_hash = inverted_index_hash

	puts "First Part Complete at : #{Time.now}"

	# NOTE: paste -d " " file_1 file_2 file_3  can be used to join files vertically side-by-side
	features_file = File.open(Dir.pwd + "/output/features.dat", "w")
	isolated_features_metadata_file = File.open(Dir.pwd + "/output/isolated_features_metadata.dat", "w")
	isolated_features_file = File.open(Dir.pwd + "/output/isolated_features.dat", "w")

	for query in Query.all
		for document_id in Document.ids
			feats = query.compute_features(document_id)
			feats = feats.map{|x| ("%f" % x) }
			
			features_line = "qid:#{query.id} #{(1..15).to_a.zip(feats).map{|x| x.join(":") }.join(" ")} # docid = #{document_id}"
			isolated_features_metadata_line = "qid:#{query.id} # docid = #{document_id}"			
			isolated_features_line = "#{(1..15).to_a.zip(feats).map{|x| x.join(":") }.join(" ")}"
			ap features_line
			features_file.puts features_line
			isolated_features_metadata_file.puts isolated_features_metadata_line
			isolated_features_file.puts isolated_features_line

			puts "Completed query #{query.id}"
		end
	end
	features_file.close ; isolated_features_metadata_file.close ; isolated_features_file.close
	puts "Whole process complete at : #{Time.now}"

end

ap "COMPLEDTED!"
