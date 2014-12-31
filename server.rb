#!/usr/bin/env ruby
#chmod +x thisfile if permission denied
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
    !!(self.gsub(/\n| /, '')[0..4]=='<?xml' || self.gsub(/\n| /, '')[0..14]=='<methodResponse')
  end
end

def stringify (object)
  return object.gsub(/\n| /, '')
end

def http (uri)
  url = URI.parse(uri)
  begin
    if uri[0..4]=='https'
      response = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get url.request_uri, 'User-Agent' => 'MyLib v1.2'
      end
    elsif uri[0..3]=='http'
      http = Net::HTTP.new(url.host, url.port)
      response = http.request(Net::HTTP::Get.new(url.request_uri))
    end
    return response.body
  rescue
    return "lol"
  end
end

def transformResponse (data)
  begin
    if data.is_xml?
      return Crack::XML.parse(stringify data).to_json
    elsif data.is_json?
      return stringify data
    else
      puts data
      return '{"result":"no valid response from target"}'
    end
  rescue
    return '{"result":"no valid response from target"}'
  end
end


server_thread = Thread.start do
  server = TCPServer.new 2000
  # loop infinitely
  loop do
    print "S"
    # use a seprate thread, acception multiple incoming connections
    Thread.start(server.accept) do |client|
      begin
        request = client.gets
        #client.puts "Hello! Input is #{request}"
        method = request.gsub(/\s+/m, ' ').strip.split(" ")[0]
        #client.puts method
        data = http request.gsub(/\s+/m, ' ').strip.split(" ")[1][1..-1]
        response = transformResponse(data)
        client.print "HTTP/1.1 200 OK\r\n" +
          "Content-Type: text/plain\r\n" +
          "Access-Control-Allow-Origin: * \r\n" +
          "Connection: close\r\n"
        client.print "\r\n"
        client.print response
        client.close
      rescue
      end
      print "E"
    end#do
  end#do
end#do

spam_thread = Thread.start do
  loop do
    print "|"
    sleep 0.1
  end
end

server_thread.join
spam_thread.join
