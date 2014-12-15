require 'socket'
require 'net/https'
require 'net/http'
require 'json'
require 'crack'

class String
  def is_json?
    !!(self.gsub(/\n| /, '')[0..0]=='{')
  end
  def is_xml?
    !!(self.gsub(/\n| /, '')[0..0]=='<')
  end
end

def stringify (object)
  return object.gsub(/\n| /, '')
end

def http (uri)
  url = URI.parse(uri)
  if uri[0..4]=='https'
    response = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.get url.request_uri, 'User-Agent' => 'MyLib v1.2'
    end
  elsif uri[0..3]=='http'
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(Net::HTTP::Get.new(url.request_uri))
  end
  return response.body
end

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  request = client.gets
  #client.puts "Hello! Input is #{request}"
  #method = request.gsub(/\s+/m, ' ').strip.split(" ")[0]
  #client.puts method
  data = http request.gsub(/\s+/m, ' ').strip.split(" ")[1][1..-1]
  if data.is_xml?
    response = Crack::XML.parse(stringify data).to_json
  elsif data.is_json?
    response = stringify data
  else
    response = '{"result":"no valid response from target"}'
  end

  client.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Access-Control-Allow-Origin: * \r\n" +
               "Connection: close\r\n"
  client.print "\r\n"
  client.print response
  client.close
end

