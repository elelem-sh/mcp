# frozen_string_literal: true

# The echo server, after writing more to stderr than a pipe holds.
$stderr.write("x" * 1_000_000)
load File.expand_path("echo_server.rb", __dir__)
