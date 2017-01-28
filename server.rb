require 'socket' 
require 'json'

def parse(full_request)
	full_request = full_request.split(/[\n]+/)
	header = full_request[0].split(" ")
	#remove trailing newlines and carriage returns. find better way
	header[2] = header[2].split("\\")[0]
	request_hash = {
		:verb => header[0],
		:path => header[1],
		:version => header[2]
	}
	if request_hash[:verb] == "POST"
		#add extra info to request_hash
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
		#response is standard HTTP response
		response = "#{version} "
		if File.exist?(path)
			response += "200 OK\nDate: #{Time.now}\nContent-Type: text/html\n"
			response +=	"Content-Length: #{File.open(path).size}\n"
			File.open(path).each {|line| response += line}
		else 
			response = "#{version} 404 Not Found"
		end
	elsif verb == "POST"
		#response is path file with new info in place of yield
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
	#difficult to find a way to read from the server that doesn't close it.
	request = client.recv(1000)

	client.puts(response(parse(request)))
	client.close 
}
