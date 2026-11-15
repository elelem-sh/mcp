# frozen_string_literal: true

# A stdio MCP server with one tool, "say", that returns its text.
require "json"

SAY = {
  name: "say",
  description: "Echo text",
  inputSchema: { type: "object", properties: { text: { type: "string" } }, required: ["text"] }
}.freeze

RESULTS = {
  "initialize" => ->(_) { { protocolVersion: "2025-06-18", capabilities: {}, serverInfo: { name: "echo" } } },
  "tools/list" => ->(_) { { tools: [SAY] } },
  "tools/call" => ->(m) { { content: [{ type: "text", text: m.dig("params", "arguments", "text") }] } }
}.freeze

$stdout.sync = true
$stdin.each_line do |line|
  message = JSON.parse(line)
  next unless message["id"]

  puts({ jsonrpc: "2.0", id: message["id"], result: RESULTS.fetch(message["method"]).call(message) }.to_json)
end
