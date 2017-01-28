require 'socket'
require json

host = 'localhost'
port = 2000 
path = "./index.html" 

request = "GET #{path} HTTP/1.0\r\n\r\n"
socket = TCPSocket.open(host,port)
socket.puts(request) 
response = socket.read 
headers,body = response.split("\r\n\r\n", 2) 
if headers.include? "200 OK" 
	print body
else
	puts "Sorry, the file was not found."
end
