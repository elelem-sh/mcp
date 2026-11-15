# frozen_string_literal: true

require "base64"
require "digest"
require "elelem"
require "fileutils"
require "json"
require "net/http"
require "open3"
require "securerandom"
require "timeout"
require "uri"
require "webrick"

require_relative "mcp/version"
require_relative "mcp/token_storage"
require_relative "mcp/oauth"
require_relative "mcp/client"

module Elelem
  module MCP
    # Waits for every loader, but no more than timeout seconds in all.
    def self.wait(threads, timeout: 30)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
      threads.each { |t| t.join([deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC), 0].max) }
    end

    # A person at a terminal can start typing while servers load. A one-shot
    # run, such as elelem ask, has to wait or its first turn has no MCP tools.
    def self.interactive?(session)
      !session.respond_to?(:input) || session.input.interactive?
    end
  end
end

Elelem.configure do |config|
  config.setup(:mcp) do |session|
    mcp = Elelem::MCP::Client.memoized

    # One thread per server, so a broken or slow server does not hold back the others.
    threads = mcp.server_names.map do |server|
      Thread.new do
        mcp.tools_for(server).each do |name, tool|
          next if session.toolbox.tools.key?(name)

          session.toolbox.add(
            name,
            description: tool[:description],
            params: tool[:params],
            required: tool[:required],
            &tool[:fn]
          )
        end
      rescue StandardError => e
        $stderr.puts "elelem-mcp: #{server}: #{e.message}"
      end
    end
    Elelem::MCP.wait(threads) unless Elelem::MCP.interactive?(session)
    threads
  end
end
