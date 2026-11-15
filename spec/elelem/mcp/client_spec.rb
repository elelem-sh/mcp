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

  it "calls a loaded tool" do
    expect(client.tools_for("echo")["echo_say"][:fn].call("text" => "hi")).to eq(content: "hi")
  end
end
