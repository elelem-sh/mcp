# frozen_string_literal: true

RSpec.describe "the mcp setup" do
  let(:dir) { Dir.mktmpdir }
  let(:config) { File.join(dir, "mcp.json") }
  let(:client) { Elelem::MCP::Client.new([config]) }
  let(:toolbox) { Elelem::Toolbox.new }
  let(:setup) do
    block = nil
    Elelem::Config.default.configure { |registration| block = registration.setups["mcp"] }
    block
  end

  before do
    echo = { "command" => RbConfig.ruby, "args" => [File.expand_path("../fixtures/echo_server.rb", __dir__)] }
    servers = { "broken" => { "command" => "/nonexistent/mcp" }, "echo" => echo }
    File.write(config, JSON.generate("mcpServers" => servers))
    allow(Elelem::MCP::Client).to receive(:memoized).and_return(client)
  end

  after do
    client.close
    FileUtils.rm_rf(dir)
  end

  def run_setup
    setup.call(Struct.new(:toolbox).new(toolbox)).each(&:join)
  end

  it "waits for the servers before returning when the input is not interactive" do
    session = Struct.new(:toolbox, :input).new(toolbox, Elelem::NullInput.new)
    expect { setup.call(session) }.to output(/broken/).to_stderr

    expect(toolbox.tools.keys).to include("echo_say")
  end

  it "loads the tools of a working server when another fails, and names the failure" do
    expect { run_setup }.to output(%r{\Aelelem-mcp: broken: No such file or directory - /nonexistent/mcp\n\z}).to_stderr
    expect(toolbox.tools.keys).to include("echo_say")
  end
end
