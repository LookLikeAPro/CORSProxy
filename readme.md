CORS Proxy
=========
A ruby server script that makes cross origin requests, to avoid complications with JSONP in applications. Essentially it adds the header `Access-Control-Allow-Origin: * ` to the server's response.
+ Note - XML and JSON responses are supported. All response is automatically returned to application in serialized json format. .

IMPORTANT
---------
Still under development. Please post any issues you may encounter.

Example
---------
```
http://localhost:2000/yourdomain.com?param=arg1
=> {response:'hello'}
```

Installation
---------
+ Install Ruby
+ Install dependency Crack `gem install jnunemaker-crack -s http://gems.github.com`
+ Run script by typing `ruby server.rb`