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

Elelem.configure do |config|
  config.setup(:mcp) do |agent|
    mcp = Elelem::MCP::Client.memoized

    Thread.new do
      mcp.tools.each do |name, tool|
        next if agent.toolbox.tools.key?(name)

        agent.toolbox.add(
          name,
          description: tool[:description],
          params: tool[:params],
          required: tool[:required],
          &tool[:fn]
        )
      end
    rescue StandardError => e
      warn "MCP failed: #{e.message}"
    end
  end
end
