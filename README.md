Pure Ruby implementation (including dependencies) of The Wire Protocol 3 (see twp3.txt).

Make sure you're on Ruby 1.9.3 and have bundler installed. Then run `bundle install` and `rake`.

This library is not thread-safe (i.e. don't access the same connection from multiple threads, it's ok to use different
connections in different threads). `TWP::Server` will start an event-loop for you and will use non-blocking reads. It
will also use a blocking accept if there are no connections open and slow down the loop when there are open
connections but no activity.

This is for a lecture. Code quality/architecture/test coverage/documentation is accordingly.

Juggling with file descriptors between threads seems to be dangerous on Ruby 1.9.3-p0, if you get a segfault or
"Bad file descriptor", simply try again.

This library includes, amongst other things:

* TDL parser and compiler
* Generic TWP3 Server/Client
* CLI toolkit
* Echo TWP3 Server/Client
* FAM TWP3 Server/Client
* RPC TWP3 Server/Client (CORBA subset)
* TFS RPC Server/Client
* Proper error handling
* Various command line tools based on TFS (all wrapped in bin/tfs)
* Fancy stream visualization for development

Strings in binary encoding are treated as binary data, other strings as strings (will be converted to UTF-8 when
streaming).

Code is written to tolerate network issues and resource failures.

Use RPC like this:

``` ruby
require 'twp'

# server
server = TWP::RPC::Server.new(host, port)
server.object = some_local_object
server.start

def some_local_object.foo
  "bar"
end

# client
some_remote_object = TWP::RPC::Client.get(host, port)
some_remote_object.foo # => "bar"
```

How does that differ from DRb? Well, it also works with servers/clients *not* written in Ruby.