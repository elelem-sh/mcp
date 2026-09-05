# frozen_string_literal: true

require_relative "lib/elelem/mcp/version"

Gem::Specification.new do |spec|
  spec.name = "elelem-mcp"
  spec.version = Elelem::MCP::VERSION
  spec.authors = ["mo khan"]
  spec.email = ["mo@mokhan.ca"]

  spec.summary = "MCP (Model Context Protocol) client support for elelem."
  spec.description = "Adds MCP server tool discovery (stdio and HTTP transports) as elelem tools."
  spec.homepage = "https://src.mokhan.ca/xlgmokha/elelem"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.0"
  spec.required_rubygems_version = ">= 4.0.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://git.mokhan.ca/xlgmokha/elelem.git"

  spec.files = [
    "LICENSE.txt",
    "lib/elelem/mcp.rb",
    "lib/elelem/mcp/version.rb",
    "lib/elelem/mcp/client.rb",
    "lib/elelem/mcp/token_storage.rb",
    "lib/elelem/mcp/plugin.rb",
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "elelem", "~> 0.11"
  spec.add_dependency "json", "~> 2.0"
  spec.add_dependency "net-http", "~> 0.9"
  spec.add_dependency "open3", "~> 0.1"
  spec.add_dependency "uri", "~> 1.0"
end
