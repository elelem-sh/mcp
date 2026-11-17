# Changelog

## [0.2.2](https://github.com/elelem-sh/mcp/compare/v0.2.1...v0.2.2) (2026-11-17)


### Bug Fixes

* require elelem &gt;= 0.13.1, the release the specs are written against ([08ee8ac](https://github.com/elelem-sh/mcp/commit/08ee8ace24fc152783a2e26eca1339c8b634130a))

## [0.2.1](https://github.com/elelem-sh/mcp/compare/v0.2.0...v0.2.1) (2026-11-16)


### Bug Fixes

* drain MCP server stderr, wait for servers in elelem ask, and accept type stdio (elelem-sh/elelem.sh[#45](https://github.com/elelem-sh/mcp/issues/45)) ([e8d2ed6](https://github.com/elelem-sh/mcp/commit/e8d2ed6ee292cf2c1274bc866f682317a6248ca8))
* drop the digest dependency, which ships with ruby and clashes with the publish job ([e8fd648](https://github.com/elelem-sh/mcp/commit/e8fd648ca0658399a93887d02d413fd68bea7255))
* load each MCP server on its own and print the ones that fail ([67b0939](https://github.com/elelem-sh/mcp/commit/67b0939646d6ddd3eb7c1846169de2fa334a605c))
* MCP asks for protocol 2025-11-25, keeps the server's answer, and sends it over HTTP (elelem-sh/elelem.sh[#33](https://github.com/elelem-sh/mcp/issues/33)) ([dbd9f96](https://github.com/elelem-sh/mcp/commit/dbd9f96b711c764ed329bfe09af82e2e45209f3e))
* name the unsupported MCP server type in the error ([cd5f8fc](https://github.com/elelem-sh/mcp/commit/cd5f8fc08f33252dbb6fa2f49723461fadb47629))
* OAuth discovery keeps the server's port (elelem-sh/elelem.sh[#33](https://github.com/elelem-sh/mcp/issues/33)) ([6f81560](https://github.com/elelem-sh/mcp/commit/6f81560c76f8a434e62e5589e59d4cc00a916cf1))
* relock elelem to 0.11.0, a real published version ([b0f0e6b](https://github.com/elelem-sh/mcp/commit/b0f0e6b68423df31a406434b236dd6eef5e15bd9))
* require elelem ~&gt; 0.12, the floor builtins/skills actually need ([c26b32d](https://github.com/elelem-sh/mcp/commit/c26b32dcaba7d7952a02f2b79f29cb1d4fbd0d32))
* the OAuth callback listens on 127.0.0.1, and tool payloads log at debug (elelem-sh/elelem.sh[#5](https://github.com/elelem-sh/mcp/issues/5)) ([1d19539](https://github.com/elelem-sh/mcp/commit/1d19539e4b342c41e813923470265f6fc29b4d54))
