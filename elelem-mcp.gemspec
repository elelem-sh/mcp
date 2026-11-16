# frozen_string_literal: true

require_relative "lib/elelem/mcp/version"

Gem::Specification.new do |spec|
  spec.name = "elelem-mcp"
  spec.version = Elelem::MCP::VERSION
  spec.authors = ["mo khan"]
  spec.email = ["mo@mokhan.ca"]

  spec.summary = "MCP (Model Context Protocol) client support for elelem."
  spec.description = "Adds MCP server tool discovery (stdio and HTTP transports) as elelem tools."
  spec.homepage = "https://elelem.sh"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elelem-sh/mcp"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "base64", "~> 0.3"
  spec.add_dependency "elelem", ">= 0.12", "< 1"
  spec.add_dependency "fileutils", "~> 1.8"
  spec.add_dependency "json", "~> 3.0"
  spec.add_dependency "net-http", "~> 0.9"
  spec.add_dependency "open3", "~> 0.2"
  spec.add_dependency "securerandom", "~> 0.4"
  spec.add_dependency "timeout", "~> 0.6"
  spec.add_dependency "uri", "~> 1.1"
  spec.add_dependency "webrick", "~> 1.9"
end
