Pure Ruby implementation (including dependencies) of The Wire Protocol 3 (see twp3.txt).

Make sure you're on Ruby 1.9.3 and have bundler installed. Then run `bundle install` and `rake`.

This library is not thread-safe. `TWP::Server` will start an event-loop for you and will use non-blocking reads. It
will also use a blocking accept if there are no connections open and slow down the loop when there are open
connections but no activity.

This is for a lecture. Code quality/architecture/test coverage is accordingly.
