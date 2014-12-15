CORS Proxy
=========
A ruby server script that makes cross origin requests, to avoid complications with JSONP in applications.

IMPORTANT
---------
Still under development. It currently only works with https protocol and only accepts xml as response.

Example
---------
```
http://localhost:2000/yourdomain.com?param=arg1
=> {response:'hello'}
```

Installation
---------
+ Install Ruby
+ Install dependencies `gem install jnunemaker-crack -s http://gems.github.com`