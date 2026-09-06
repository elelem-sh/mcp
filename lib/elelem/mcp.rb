# frozen_string_literal: true

require "digest"
require "elelem"
require "fileutils"
require "json"
require "net/http"
require "open3"
require "uri"

require_relative "mcp/version"
require_relative "mcp/token_storage"
require_relative "mcp/client"

Elelem::Plugins.register(:mcp) do |agent|
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
  rescue => e
    warn "MCP failed: #{e.message}"
  end
end
