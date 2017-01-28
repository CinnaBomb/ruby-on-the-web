require 'socket'
require 'json'

def get_post_hash
	puts "What's your name?"
	name = gets.chomp!
	puts "What's your email address?"
	email = gets.chomp!
	post_hash = {:viking=>
		{
			:name =>name,
			:email =>email
		}
	}
end

host = 'localhost'
port = 2000
get_path = "./index.html" 
post_path = "./thanks.html"
puts "Would you like to GET or POST"
choice = gets.downcase.chomp!
if choice == "get"
	request = "GET #{get_path} HTTP/1.0\n"
	socket = TCPSocket.open(host,port)
	socket.puts(request) 
	response = socket.read 
	puts response
	headers,body = response.split("/[\r]?[\n]+/", 2) 
	if headers.include? "200 OK" 
		print body
	else
		puts "Sorry, the file was not found."
	end
elsif choice =="post"
	post_json = get_post_hash.to_json
	request = "POST #{post_path} HTTP/1.0\nContent Length: #{post_json.length}\n#{post_json}"
	socket = TCPSocket.open(host, port)
	#puts request
	socket.puts(request)
	response = socket.read
	puts response

else
	puts "Sorry, I didn't understand your request"

end