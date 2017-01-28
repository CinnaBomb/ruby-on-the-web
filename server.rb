require 'socket'               # Get sockets from stdlib
require 'json'

def parse(full_request)
	full_request = full_request.split(/[\n]+/)
	puts full_request.inspect + "full"
	request = full_request[0].split(" ")
	request[2] = request[2].split("\\")[0]
	request_hash = {
		:verb => request[0],
		:path => request[1],
		:version => request[2]
	}
	if request_hash[:verb] == "POST"
		request_hash[:content_length] = full_request[1].match(/[\d]+/)
		request_hash[:params] = JSON.parse(full_request[2])
	end

	request_hash
end


def response(request_hash)
	verb = request_hash[:verb]
	path = request_hash[:path]
	version = request_hash[:version]

	if verb == "GET"
		response = "#{version} "
		if File.exist?(path)
			response += "200 OK\nDate: #{Time.now}\nContent-Type: text/html\n"
			response +=	"Content-Length: #{File.open(path).size}\n"
			File.open(path).each {|line| response += line}
		else 
			response = "#{version} 404 Not Found"
		end
	elsif verb == "POST"
		name = request_hash[:params]["viking"]["name"]
		email = request_hash[:params]["viking"]["email"]
		if File.exist?(path)
			thanks_file = File.read(path)
			thanks_file.gsub!("<%= yield %>", "<li>#{name}</li><li>#{email}</li>")
			response = thanks_file
		end
	end
	response
end

server = TCPServer.open(2000)
loop { 
	client = server.accept 
	request = client.recv(1000)

	client.puts(response(parse(request)))
	client.close 
}
