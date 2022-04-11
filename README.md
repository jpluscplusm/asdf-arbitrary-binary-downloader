# asdf-arbitrary-code-execution

A plugin for the ASDF version manager that downloads arbitrary binaries that
the user configures, and hands them to ASDF to version-switch.

NB This plugin's name is a "playful" reminder that the security model of ASDF
is very much "buyer beware". ASDF requires you to trust plugin authors, as
plugins execute code directly on your machine. This plugin goes one step
further: **you must explicitly configure this plugin only to download
binaries that you trust**. **The onus is on you, the user, to use only those
binaries that you trust**. _This plugin cannot download binaries that you
haven't **explicitly** told it about_.

You should not use this plugin simply because someone tells you to. You should
know what problem you're trying to solve by using it, and should understand the
links in the chain of trust that you're relying on.

## Usage

This tool is at version v0.0.0. This means its interface is liable to change
completely, as it's currently totally experimental.

Well before v1.0.0 is released, however, a more stable interface will be
iterated towards.

The current version is able to install binaries that are found in compressed
tarballs that curl is able to fetch. Only 1 binary per remote tarball is
currently supported.

The following will allow for a single binary from a gzipped tarball to be
installed.

Populate a `~/TOOLS.json` file (NB this location WILL change) with 1 or more
tool's information inside the top-level `v0` key:

```
{ "v0": {
 "tool_name_underscores_no_hyphens": {
  "url": "https://example.com/path/to/file/containing/${VERSION}/and/${GO_GOOS_LC}/and/${GO_GOARCH_LC}/vars.tgz"
  "tar_file": "path/to/file/in/tarball"
  "bin_name": "binary_filename_we_want_to_use_in_the_shell"
 }
}
```

The `url`, `tar_file` and `bin_name` keys' value can contain the following
variables, referenced in shell-like `${FOO}` form:

- `VERSION`: the literal version of the tool that asdf has been asked to install
- `UNAME_M_LC`: the lowercase value of `uname -m`
- `GO_GOOS_LC`: the lowercase value of `uname -s`
- `GO_GOARCH_LC`: the lowercase value of `uname -m`, but where `x86_64` => `amd64`

Then run:

1. `asdf plugin add tool_name_underscores_no_hyphens https://github.com/jpluscplusm/asdf-arbitrary-code-execution`
1. `asdf install tool_name_underscores_no_hyphens some.version.number`

Note that this tool currently doesn't list remote versions, or know the
latest/stable version that's available. *You need to know and specify the
exact version that you want to install.*

## Development & changes

If you have examples of tools that can use this plugin, please PR them into the
[examples/](examples/) directory as appropriate.

To introduce new variables/features/etc, please:

1. Install [Dagger](https://docs.dagger.io/1200/local-dev)
   - Simply teach it about a Buildkit server with `BUILDKIT_HOST=`, if you'd
     prefer Dagger not to use Docker to bootstrap one for you!
1. Make changes, including tests
   - I know how unwieldy and ugly the current tests are. They will change!
1. Run `dagger do test`
1. Fork, and push your changes to your fork
1. Open a PR.
