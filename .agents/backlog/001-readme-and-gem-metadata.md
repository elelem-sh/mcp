As a `person who wants to give elelem tools from MCP servers`, I `want
a README and clear RubyGems links for elelem-mcp`, so that `I can
configure servers without reading the code and find the docs and
backlog from the gem page`.

# SYNOPSIS

Add a README, and point the gem's RubyGems links at elelem.sh and this
repository's backlog.

# DESCRIPTION

Two small changes that both shape what a newcomer sees first.

## README

The repository has no README. It should cover:

* Install, and the loader file elelem needs to load a gem plugin
  (`~/.agents/plugins/mcp.rb` containing `require "elelem/mcp"`),
  until core loads installed plugins on its own.
* Configuration: `~/.agents/mcp.json` and `.agents/mcp.json`, with an
  example for a stdio server and an HTTP server.
* OAuth for HTTP servers: the browser step, where tokens are stored,
  and how to remove them.
* How tools appear: one loader thread per server, a server that fails
  is reported on stderr and skipped, and `elelem ask` waits up to 30
  seconds for servers to load.
* A link to https://elelem.sh/plugins/mcp/ for the full guide.

The elelem.sh plugin page can be the source for the text. Show commands
without a leading `$`, so they can be pasted.

## Gem metadata

RubyGems shows `homepage_uri` and the other `metadata` links on every
gem page. Today `elelem-mcp.gemspec` sets `spec.homepage`
to the site root (https://elelem.sh) and sets only `homepage_uri`,
`source_code_uri`, `allowed_push_host` and
`rubygems_mfa_required`.
There is no documentation, bug tracker or changelog link.

Proposed change:

```ruby
spec.homepage = "https://elelem.sh/plugins/mcp/"
spec.metadata["homepage_uri"] = spec.homepage
spec.metadata["source_code_uri"] = "https://github.com/elelem-sh/mcp"
spec.metadata["documentation_uri"] = spec.homepage
spec.metadata["bug_tracker_uri"] = "https://github.com/elelem-sh/mcp/tree/main/.agents/backlog"
spec.metadata["changelog_uri"] = "https://github.com/elelem-sh/mcp/blob/main/CHANGELOG.md"
```

The original proposal pointed `bug_tracker_uri` at GitHub Issues on
elelem-sh/elelem.sh, filtered by label. That no longer fits: the
project is moving its backlog out of GitHub Issues and into
`.agents/backlog` story files in each repository, so the bug tracker
link points at this repository's backlog directory instead.

/man/mcp/ redirects to /plugins/mcp/ on elelem.sh, so a
separate documentation_uri adds nothing. Point both at the plugin page.
CHANGELOG.md exists on main, so the changelog link works today.

Keep `allowed_push_host` and `rubygems_mfa_required` as they are.
RubyGems only shows the new links after the next release.

# SEE ALSO

* [ ] lib/elelem/mcp.rb:37-60 - setup and loader threads
* [ ] lib/elelem/mcp/client.rb:7-10 - config paths
* [ ] lib/elelem/mcp/oauth.rb, lib/elelem/mcp/token_storage.rb
* [ ] elelem-mcp.gemspec:13 - spec.homepage and metadata
* [ ] https://elelem.sh/plugins/mcp/ - source for README text
* [ ] Formerly elelem-sh/elelem.sh#23
* [ ] Formerly elelem-sh/elelem.sh#41

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] README.md exists and covers the points above
* [ ] Defaults in the README match the code
* [ ] Commands in the README have no leading `$`
* [ ] `spec.homepage` and `homepage_uri` are https://elelem.sh/plugins/mcp/
* [ ] `bug_tracker_uri` points at this repository's `.agents/backlog`,
      not at GitHub Issues
* [ ] `changelog_uri` and `source_code_uri` point at this repository
* [ ] `gem build` succeeds and `gem spec` on the built gem shows every
      link
