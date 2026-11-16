# frozen_string_literal: true

require "open3"

RSpec.describe "the mcp setup" do
  let(:lib) { File.expand_path("../../lib", __dir__) }
  let(:echo) { File.expand_path("../fixtures/echo_server.rb", __dir__) }
  let(:script) do
    'require "elelem/mcp"; ' \
      "puts Elelem.build(input: Elelem::NullInput.new, output: Elelem::NullOutput.new).toolbox.tools.keys"
  end

  def build_session_in(dir)
    servers = {
      "broken" => { "command" => "/nonexistent/mcp" },
      "echo" => { "command" => RbConfig.ruby, "args" => [echo] }
    }
    FileUtils.mkdir_p(File.join(dir, ".agents"))
    File.write(File.join(dir, ".agents/mcp.json"), JSON.generate("mcpServers" => servers))
    Open3.capture3({ "HOME" => dir }, RbConfig.ruby, "-I", lib, "-e", script, chdir: dir)
  end

  it "waits for the servers when the input is not interactive, and loads the tools of the working one" do
    Dir.mktmpdir do |dir|
      tools, _, status = build_session_in(dir)

      expect(status).to be_success
      expect(tools.lines(chomp: true)).to include("echo_say")
    end
  end

  it "names the server that failed" do
    Dir.mktmpdir do |dir|
      _, errors, = build_session_in(dir)

      expect(errors).to eq("elelem-mcp: broken: No such file or directory - /nonexistent/mcp\n")
    end
  end
end
