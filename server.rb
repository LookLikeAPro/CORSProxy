require 'socket'
require 'net/https'
require 'json'
require 'crack'

def https (uri)
  url = URI.parse(uri)
  response = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
    http.get url.request_uri, 'User-Agent' => 'MyLib v1.2'
  end
  case response
  when Net::HTTPRedirection
    # repeat the request using response['Location']
  when Net::HTTPSuccess
    return response.body
  else
    # response code isn't a 200; raise an exception
    response.error!
  end
end

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  request = client.gets
  #client.puts "Hello! Input is #{request}"
  #method = request.gsub(/\s+/m, ' ').strip.split(" ")[0]
  #client.puts method
  data = https request.gsub(/\s+/m, ' ').strip.split(" ")[1][1..-1]
  response = Crack::XML.parse(data.gsub(/\n| /, '')).to_json
  client.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Access-Control-Allow-Origin: * \r\n" +
               #"Content-Length: #{response.to_s.bytesize}\r\n" +
               "Connection: close\r\n"
  client.print "\r\n"
  client.print response
  client.close
end

