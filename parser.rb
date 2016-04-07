require "twitter"
require "yaml"
require "json"

class Parser
	def initialize
		@client = Twitter::Streaming::Client.new do |config|
		    config.consumer_key        = ENV['CONSUMER_KEY']
		    config.consumer_secret     = ENV['CONSUMER_SECRET']
		    config.access_token        = ENV['ACCESS_TOKEN']
		    config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
		end
	end

	def twitter_test
	  all_tweets = get_tweets(@client)
	  total_word_count = get_word_count(all_tweets)
	  filtered_tweets = remove_stop_words(all_tweets)
	  word_frequencies = identify_most_common_words(filtered_tweets)
	  format_results(total_word_count, word_frequencies)
	end

	def get_tweets(client)
	  all_tweets = Array.new
	  end_time = Time.now + 300
	  client.sample do |status|
	    if status.is_a?(Twitter::Tweet) && status.user.lang == "en"
	      parsed_tweet = parse_tweet(status.text)
	      all_tweets.push(parsed_tweet)
	    end
	    break if Time.now >= end_time
	  end
	  all_tweets.flatten.compact
	end

	def parse_tweet(text)
	  text.gsub(/[^\w+' #@\/:.-]/, '').downcase.split(' ')
	end

	def get_word_count(all_tweets)
	  all_tweets.length
	end

	def remove_stop_words(all_tweets)
	  words = all_tweets
	  stop_words = YAML.load_file('stop_words.yml')["english"]
	  stop_words.each { |stop_word| words.delete(stop_word) }
	  words
	end

	def identify_most_common_words(filtered_tweets)
	  filtered_tweets.sort
	  filtered_tweets.each_with_object(Hash.new(0)) { |word,count| count[word] += 1 }.sort_by { |word, count| count }.reverse!.take(10)
	end

	def format_results(total_word_count, word_frequencies)
	  response = Array.new
	  response << "Total Word Count - #{total_word_count}"
	  word_frequencies.each_with_index { |word, index| response << "#{index + 1}. #{word[0]} - #{word[1]}"}
	  response.to_json
	end

end