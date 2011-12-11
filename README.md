Pure Ruby implementation (including dependencies) of The Wire Protocol 3 (see twp3.txt).

Make sure you're on Ruby 1.9.3 and have bundler installed. Then run `bundle install` and `rake`.

This library is not thread-safe (i.e. don't access the same connection from multiple threads, it's ok to use different
connections in different threads). `TWP::Server` will start an event-loop for you and will use non-blocking reads. It
will also use a blocking accept if there are no connections open and slow down the loop when there are open
connections but no activity.

This is for a lecture. Code quality/architecture/test coverage is accordingly.

Juggling with file descriptors between threads seems to be dangerous on Ruby 1.9.3-p0, if you get a segfault or
"Bad file descriptor", simply try again.
