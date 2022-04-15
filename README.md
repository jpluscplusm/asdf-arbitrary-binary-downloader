# asdf-arbitrary-code-execution

A plugin for the [ASDF version manager](https://asdf-vm.com/) that downloads
arbitrary binaries _as configured by the user_, and hands them to ASDF to
version-switch.

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

This tool is at version v0.0.2. This means its interface is liable to change
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
{
 "v0": {
  "tool-name": {
   "url": "https://example.com/path/to/file/containing/${V}/and/${GO_GOOS_LC}/and/${GO_GOARCH_LC}/vars.tgz"
   "tar_file": "path/to/file/in/tarball"
   "bin_name": "binary_filename_we_want_to_use_in_the_shell"
  }
 }
}
```

The `url`, `tar_file` and `bin_name` keys' value can contain variables,
referenced in shell-like `${FOO}` form. The set of valid variables is found in
[bin/vars/99-exports](bin/vars/99-exports). The names are currently "obvious"
enough that they're not documented. This will change as people (you?!) PR more
interesting "facts", "transforms" and "exports", and their complexity
increases.

All variables have `.._UC` and `.._LC` variants, representing all-upper-case
and all-lower-case strings respectively.

The variable `V` (and its `V_LC`/`V_UC`) variants contains the literal version
of the tool that asdf has been asked to install. It should (*must*!) be present
in the `url` key, because the TOOLS.json file is *not* the arbiter of *which*
version ASDF will install - ASDF is in charge of that. The TOOLS.json file
teachs ASDF, via this plugin, *how* to download DIFFERENT versions. If the
version is hardcoded in TOOLS.json then ... what's the point?

After seeding TOOLS.json with the information about the tool you want to install,

- `asdf plugin add tool-name https://github.com/jpluscplusm/asdf-arbitrary-code-execution`
- `asdf install tool-name some.version.number`

... and then maybe

- `asdf global tool-name some.version.number`.

`some.version.number` in both the commands, above, **is where you tell ASDF
which version you want to install**. Currently, this tool doesn't list remote
versions, or know the latest/stable version that's available. *You need to know
and specify the exact version that you want to install.*

## Development & changes

If you have examples of tools that can use this plugin, please PR them into the
[examples/](examples/) directory as appropriate.

To introduce new variables/features/etc, please:

1. Install [Dagger](https://docs.dagger.io/1200/local-dev)
   - Simply teach it about a Buildkit server with `BUILDKIT_HOST=`, if you'd
     prefer Dagger not to use Docker to bootstrap one for you!
1. Make changes, including tests
1. Run `dagger do test`
1. Fork, and push your changes to your fork
1. Open a PR.
