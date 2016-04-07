require "sinatra"
require "dotenv"
Dotenv.load

require "./parser.rb"

get "/parse" do
	parser = Parser.new
	parser.twitter_test
end