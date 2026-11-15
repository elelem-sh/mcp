# frozen_string_literal: true

module Elelem
  module MCP
    class OAuth
      CALLBACK_PORT = 18_273
      REDIRECT_URI = "http://127.0.0.1:#{CALLBACK_PORT}/callback".freeze

      def initialize(resource_url, http: HttpAdapter.new)
        @resource_url = resource_url
        @http = http
        @storage = TokenStorage.new
      end

      def token
        stored = @storage.load(@resource_url)
        return stored[:access_token] if stored && !expired?(stored)
        return refresh(stored[:refresh_token]) if stored&.dig(:refresh_token)

        authorize
      end

      private

      def expired?(stored)
        return false unless stored[:expires_at]

        Time.now.to_i >= stored[:expires_at] - 60
      end

      def authorize
        metadata = discover_auth_server
        client = load_or_register_client(metadata)
        verifier, challenge = generate_pkce
        state = SecureRandom.hex(16)

        auth_url = build_auth_url(metadata, client, challenge, state)
        open_browser(auth_url)

        code = wait_for_callback(state)
        tokens = exchange_code(metadata, client, code, verifier)

        @storage.save(
          @resource_url,
          access_token: tokens["access_token"],
          refresh_token: tokens["refresh_token"],
          expires_in: tokens["expires_in"]
        )

        tokens["access_token"]
      end

      def refresh(refresh_token)
        metadata = discover_auth_server
        client = load_or_register_client(metadata)
        uri = URI.parse(metadata["token_endpoint"])

        body = {
          grant_type: "refresh_token",
          refresh_token: refresh_token,
          client_id: client[:client_id]
        }

        response = post_form(uri, body)
        tokens = JSON.parse(response.body)

        @storage.save(
          @resource_url,
          access_token: tokens["access_token"],
          refresh_token: tokens["refresh_token"] || refresh_token,
          expires_in: tokens["expires_in"]
        )

        tokens["access_token"]
      rescue StandardError => e
        $stderr.puts "elelem-mcp: token refresh failed: #{e.message}"
        authorize
      end

      def discover_auth_server
        metadata_url = URI.join(@resource_url, "/.well-known/oauth-protected-resource").to_s

        resource_metadata = fetch_json(metadata_url)
        auth_server_url = resource_metadata["authorization_servers"]&.first
        raise "No authorization server found" unless auth_server_url

        auth_metadata_url = "#{auth_server_url}/.well-known/oauth-authorization-server"
        fetch_json(auth_metadata_url)
      end

      def load_or_register_client(metadata)
        stored = @storage.load_client(@resource_url)
        return stored if stored

        client = register_client(metadata)
        @storage.save_client(@resource_url, client)
        @storage.load_client(@resource_url)
      end

      def register_client(metadata)
        endpoint = metadata["registration_endpoint"]
        raise "Dynamic registration not supported" unless endpoint

        body = {
          client_name: "elelem",
          redirect_uris: [REDIRECT_URI],
          grant_types: %w[authorization_code refresh_token],
          response_types: ["code"],
          token_endpoint_auth_method: "none"
        }

        response = post_json(endpoint, body)
        JSON.parse(response.body)
      end

      def generate_pkce
        verifier = SecureRandom.urlsafe_base64(32)
        challenge = Base64.urlsafe_encode64(
          Digest::SHA256.digest(verifier),
          padding: false
        )
        [verifier, challenge]
      end

      def build_auth_url(metadata, client, challenge, state)
        params = {
          response_type: "code",
          client_id: client[:client_id],
          redirect_uri: REDIRECT_URI,
          scope: metadata["scopes_supported"]&.join(" ") || "openid",
          state: state,
          code_challenge: challenge,
          code_challenge_method: "S256"
        }

        "#{metadata["authorization_endpoint"]}?#{URI.encode_www_form(params)}"
      end

      def open_browser(url)
        commands = %w[xdg-open open start]
        opened = commands.any? { |cmd| system(cmd, url, out: File::NULL, err: File::NULL) }
        $stderr.puts "Open this URL in your browser: #{url}" unless opened
      end

      def wait_for_callback(expected_state)
        code = nil
        @server = WEBrick::HTTPServer.new(
          Port: CALLBACK_PORT,
          BindAddress: "127.0.0.1",
          Logger: WEBrick::Log.new(File::NULL),
          AccessLog: []
        )

        at_exit { @server&.shutdown }

        @server.mount_proc("/callback") do |req, res|
          state = req.query["state"]
          raise "State mismatch" unless state == expected_state

          code = req.query["code"]
          res.content_type = "text/html"
          res.body = "<html><body><h1>Authorization complete</h1><p>You can close this window.</p></body></html>"
          @server.shutdown
        end

        Timeout.timeout(120) { @server.start }
        code
      rescue Timeout::Error
        @server.shutdown
        raise "OAuth callback timed out"
      end

      def exchange_code(metadata, client, code, verifier)
        uri = URI.parse(metadata["token_endpoint"])

        body = {
          grant_type: "authorization_code",
          code: code,
          redirect_uri: REDIRECT_URI,
          client_id: client[:client_id],
          code_verifier: verifier
        }

        response = post_form(uri, body)
        JSON.parse(response.body)
      end

      def fetch_json(url)
        response = nil
        @http.get(url) { |r| response = r }
        JSON.parse(response.body)
      end

      def post_json(url, body)
        response = nil
        @http.post(
          url,
          headers: { "Content-Type" => "application/json" },
          body: body.to_json
        ) { |r| response = r }
        response
      end

      def post_form(uri, body)
        response = nil
        @http.post(
          uri.to_s,
          headers: { "Content-Type" => "application/x-www-form-urlencoded" },
          body: URI.encode_www_form(body)
        ) { |r| response = r }
        response
      end

      class HttpAdapter
        def get(url)
          uri = URI.parse(url)
          Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |conn|
            yield conn.get(uri.request_uri)
          end
        end

        def post(url, headers: {}, body: nil)
          uri = URI.parse(url)
          request = Net::HTTP::Post.new(uri)
          headers.each { |k, v| request[k] = v }
          request.body = body

          Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |conn|
            yield conn.request(request)
          end
        end
      end
    end
  end
end
