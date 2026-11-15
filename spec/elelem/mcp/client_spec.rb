# frozen_string_literal: true

RSpec.describe Elelem::MCP::Client do
  subject(:client) { described_class.new([config]) }

  let(:dir) { Dir.mktmpdir }
  let(:config) { File.join(dir, "mcp.json") }
  let(:echo) { { "command" => RbConfig.ruby, "args" => [File.expand_path("../../fixtures/echo_server.rb", __dir__)] } }

  before do
    servers = { "echo" => echo, "broken" => { "command" => "/nonexistent/mcp" } }
    File.write(config, JSON.generate("mcpServers" => servers))
  end

  after do
    client.close
    FileUtils.rm_rf(dir)
  end

  it "lists every configured server" do
    expect(client.server_names).to eq(%w[echo broken])
  end

  it "loads one server's tools when another fails" do
    expect { client.tools_for("broken") }.to raise_error(SystemCallError)
    expect(client.tools_for("echo").keys).to eq(["echo_say"])
  end

  it "answers when the server writes a lot to stderr" do
    noisy = { "command" => RbConfig.ruby, "args" => [File.expand_path("../../fixtures/noisy_server.rb", __dir__)] }
    File.write(config, JSON.generate("mcpServers" => { "noisy" => noisy }))

    Timeout.timeout(10) { expect(client.tools_for("noisy").keys).to eq(["noisy_say"]) }
  end

  it "accepts type stdio, and takes a url without a type as http" do
    servers = { "s" => echo.merge("type" => "stdio"), "h" => { "url" => "http://127.0.0.1:1/mcp" } }
    File.write(config, JSON.generate("mcpServers" => servers))

    expect(client.tools_for("s").keys).to eq(["s_say"])
    expect { client.tools_for("h") }.to raise_error(SystemCallError)
  end

  it "names an unsupported type" do
    File.write(config, JSON.generate("mcpServers" => { "x" => { "type" => "sse", "url" => "http://h/" } }))

    expect { client.tools_for("x") }.to raise_error("unsupported type: sse")
  end

  it "asks for 2025-11-25 and keeps the version the server answers with" do
    client.tools_for("echo")
    server = client.send(:server, "echo")

    expect(Elelem::MCP::PROTOCOL_VERSION).to eq("2025-11-25")
    expect(server.protocol_version).to eq("2025-06-18")
  end

  it "calls a loaded tool" do
    expect(client.tools_for("echo")["echo_say"][:fn].call("text" => "hi")).to eq(content: "hi")
  end
end
