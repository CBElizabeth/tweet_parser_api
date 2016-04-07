require "sinatra"
require "dotenv"
Dotenv.load

require "./parser.rb"

get "/parse" do
	Parser.new
end