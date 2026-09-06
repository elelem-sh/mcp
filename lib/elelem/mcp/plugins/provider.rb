# frozen_string_literal: true

require "elelem/plugins"
require_relative "../../mcp"

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
