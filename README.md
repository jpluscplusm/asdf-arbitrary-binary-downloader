# asdf-arbitrary-code-execution

A plugin for the [ASDF version manager](https://asdf-vm.com/) that downloads
arbitrary binaries _as configured by the user_, and hands them to ASDF to
version-switch.

NB This plugin's name is a "playful" reminder that the security model of ASDF
is very much "buyer beware". ASDF requires you to trust plugin authors, as
plugins execute code directly on your machine. This plugin goes one step
further: **you must explicitly configure this plugin only to download binaries
that you trust**. **The onus is on you, the user, to use only those binaries
that you trust**. _This plugin cannot download binaries that you haven't
**explicitly** told it about_.

You should not use this plugin simply because someone tells you to. You should
know what problem you're trying to solve by using it, and should understand the
links in the chain of trust that you're relying on.

## Using this plugin

This tool is at version v0.0.5. This means its interface is liable to change,
as it's currently pretty experimental.

Well before v1.0.0 is released, however, a more stable interface is being
iterated towards. Feedback about the current interface is very welcome!

Each tool you configure can refer to either a compressed tarball, a zip
archive, or a single unpackaged binary.

A compressed tarball or zip archive can have multiple binaries extracted from
them; a single unpackaged binary provides only a single binary.

### Pre-requisites

- `curl`
- `cue` (see below)
- [optional] `tar`
- [optional] `gunzip`
- [optional] `unzip`

This plugin requires [the `cue`
CLI](https://cuelang.org/docs/install/#install-cue-from-official-release-binaries)
to be installed. I'm well aware of the irony of this plugin -- a tool to
automate the installation of arbitrary binaries off the internet -- requiring
its users to download a binary **manually** ... but this is the last one you
should ever need to fetch!

Make the `cue` CLI available in your `$PATH`, however you usually do that.

You will also need the tools installed that understand the types of files you
want this plugin to fetch.

Using compressed tarballs requires `tar` and `gunzip` to be available. These
are usually already installed as part of the base operating system, and you may
well not need to install them yourself.

Using zip archives requires the `unzip` command to be available. This is
usually trivially installable, if it's not already installed.

Using direct binary downloads requires no additional tools.

### Configuration

Each tool you configure can refer to either a compressed tarball, a zip
archive, or a single unpackaged binary.

A zip file or compressed tarball can have multiple binaries extracted from them;
a single unpackaged binary is, of course, only able to provide a single binary.

Populate a `~/.tool-sources.asdface.cue` file (NB this name & location is up
for discussion) with 1 or more tool's information inside the top-level `v0` key
("v0" reflects the unstable nature of this plugin, pre-1.0).

Indicate that each tool is either a `#TarGz` or a `#BinaryDownload`, as
demonstrated here. NB The `& {` suffix is a *vital* part of the config!

```CUE
package asdface

v0: {
  tools: {
    tool_name: #BinaryDownload & {
      source: "https://example.com/path/to/binary/containing/\(version.oc)/and/\(go.os.lc)/and/\(go.arch.uc)/vars"
      create: "binary_filename_we_want_to_use_in_the_shell"
    }
    "tool-names-containing-hyphens-need-to-be-in-quotes": #TarGz & {
      source: "https://example.com/path/to/file/containing/\(version.oc)/and/\(go.os.lc)/and/\(go.arch.uc)/vars.tgz"
      create: binary_filename_we_want_to_use_in_the_shell: "path/to/file/in/tarball"
      create: {
        "more-binaries-we-want-to-use-this-time-containing-hyphens": "path/to/this/file/in/the/same/tarball"
        simpleFilename: "fileAtRootOfTarball"
      }
    }
    someTool: #Zip & {
      source: "https://example.com/path/\(version.oc)/withvars/\(go.os.lc)/and/\(go.arch.uc)/archive-\(version.oc).zip"
      create: {
        binary_name:    "path/to/file/in/ziparchive"
        binary_name_2:  "path/to/this/file/in/the/same/ziparchive"
        simpleFilename: "fileAtRootOfArchive"
      }
    }
  }
}
```

Any keys' value can contain variables, referenced in [CUE's `\(variable)`
interpolation
syntax](https://cuelang.org/docs/tutorials/tour/expressions/interpolation/).
The set of valid variable prefixes is currently:

- `version`: the literal version requested by the user
- `uname.m`: the output of `uname -m`
- `uname.s`: the output of `uname -s`
- `go.os`:   the Go language's concept of the machine's running OS
- `go.arch`: the output of `uname -m`, with `x86_64` changed to `amd64`, which (AFAICT?) matches Go's GOARCH concept. PR's very welcome!

A letter-case modifier suffix is required for all references. For the identity
modifier, which does not change any letter cases, use the `.oc` (original case)
suffix. `.uc` and `.lc` suffixes are also available for upper- and lower-case,
respectively. `.tc` and `.cc` suffixes denote title-case and camel-case, but
because these both split on word boundaries they are less useful than one
might anticipate.

For example, if the version string "v1.2.3" has been provided to the ASDF CLI,
the following variables are available for use in the config file, to be
interpolated at install-time:

- `version.oc`: "v1.2.3"
- `version.uc`: "V1.2.3"
- `version.lc`: "v1.2.3"
- `version.tc`: "V1.2.3"
- `version.cc`: "v1.2.3"

At least one variant of the `version` variable should (*must*!) be present in
the `url` key, because the `~/.tool-sources.asdface.cue` file is *not* the
arbiter of *which* version ASDF will install - ASDF is in charge of that. This
config file teachs ASDF, via this plugin, **how** to download DIFFERENT
versions.  If the version is hardcoded in the config then ... what's the point?

After seeding the config file with the information about the tool you want to
install, make sure you've [installed the CUE cli](#pre-requisites) (an easy,
small, single-binary download!), and then run:

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
