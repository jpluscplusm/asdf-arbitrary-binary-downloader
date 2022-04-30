# asdf-arbitrary-code-execution

A plugin for the [ASDF version manager](https://asdf-vm.com/) that downloads
arbitrary binaries _as configured by the user_, and hands them to ASDF to
version-switch.

<hr>
<details>
<summary>:accordion: Security Klaxon :rotating_light::rotating_light::rotating_light:</summary>

This plugin's name is a "playful" reminder that the security model of ASDF
is very much "buyer beware". ASDF requires you to trust plugin authors, as
plugins execute code directly on your machine. This plugin goes one step
further: **you must explicitly configure this plugin only to download binaries
that you trust**.

**The onus is on you, the user, to use only those binaries that you trust**.

_This plugin can only download binaries that you have **explicitly** told it
about_.

You should not use this plugin simply because someone tells you to. You should
know what problem you're trying to solve by using it, and should understand the
links in the chain of trust that you're relying on.

A later version of this plugin will deal with the thorny issue of validating
downloads. For now, this issue is in the user's hands -- your hands: only tell
this plugin to download binaries from sites, projects and users that you trust.
</details>
<hr>

## Quick start

1. Have a working [ASDF install](https://asdf-vm.com/).
1. Find a tool that you want to install, that publishes pre-compiled binaries
   either as direct downloads, or inside compressed tarballs or zip archives.
1. Grab the appropriate download URL for your machine and operating system.
1. Install [the `CUE`
   CLI](https://cuelang.org/docs/install/#install-cue-from-official-release-binaries).
1. Install `curl`, and optionally either of `unzip` or `tar`, depending on the
   format you're downloading.
1. Configure the file `$HOME/.tool-sources.asdface.cue` [as described
   below](#configuration) with an appropriate tool setup:
   - the tool's name is only an informative alias, and doesn't have to match
     anything specific about the tool you're installing. In this quick start,
     we imagine it to be `example_tool_name`.
   - the `source` value should be the URL you grabbed, above, with any version
     components swapped out for `\(version.oc)`.
   - the `creates` value (either a simple string for direct binary downloads,
     or a key/value pair for tarball/zip archives and their contents) defines
     the name of the binary you want to make available on your machine. In this
     quick start, we imagine this to be `my_tool`.

<hr>
<details>
<summary>:accordion: Example config file</summary>

```
v0: tools: example_tool_name: #BinaryDownload & {
  source: "https://example.com/a_useful_project/releases/\(version.oc)/downloads/project-linux-amd64"
  create: "my_tool"
}
```

</details>
<hr>

7. Install this plugin:

       asdf plugin add example_tool_name https://github.com/jpluscplusm/asdf-arbitrary-code-execution

7. Install a specific version of the tool:

       asdf install example_tool_name v1.2.3

7. Tell ASDF to make this specific version available:

       asdf global example_tool_name v1.2.3

7. Use the tool: `my_tool --help`

It's well worth reading [the configuration section and example](#configuration)
to discover how you can make your config more portable, and how you can make it
available for other folks to use!

## Using this plugin

_This tool hasn't yet reached version 1.0, which means it's still experimental and its
interface may change. We're working towards defining a stable interface - [your
feedback](https://github.com/jpluscplusm/asdf-arbitrary-code-execution/discussions/new?category=general)
about using the current interface will help us make the right choices, and is
extremely welcome!_

Each tool you configure can refer to either a compressed tarball, a zip
archive, or a single unpackaged binary.

A compressed tarball or zip archive can have multiple binaries extracted from
them; a single unpackaged binary provides only a single binary.

### Pre-requisites

Required:

- `curl`
- `cue` (see below)

Optional, depending on which packaging formats are referenced:

- Compressed tarballs: `tar` and `gunzip`
- Zip archives: `unzip`
- Direct binary downloads: no additional pre-requisites

This plugin requires [the `cue`
CLI](https://cuelang.org/docs/install/#install-cue-from-official-release-binaries)
to be installed. I'm well aware of the irony of this plugin -- a tool to
automate the installation of arbitrary binaries off the internet -- requiring
its users to download a binary **manually** ... but this is the last one you
should ever need to fetch!

Make the `cue` CLI available in your `$PATH`, however you usually do that.

### Configuration

Each tool you configure can refer to either a compressed tarball, a zip
archive, or a single unpackaged binary.

A zip file or compressed tarball can have multiple binaries extracted from them;
a single unpackaged binary is, of course, only able to provide a single binary.

Populate the file `$HOME/.tool-sources.asdface.cue` with 1 or more tool's
information inside the top-level `v0` key ("v0" reflects the unstable nature of
this plugin, pre-1.0).

Indicate that each tool is either a `#TarGz`, a `#Zip`, or a `#BinaryDownload`,
as demonstrated here. NB The `& {` suffix is a *vital* part of the config!

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

#### Variables

Any string can contain variables, expressed in the configuration language
[CUE](https://cuelang.org). Expand the next :accordion: section for an
incomplete crash course in CUE, its strings, and variables.

<hr>
<details>
<summary>:accordion: CUE: an incomplete, 90 second guide</summary>

##### CUE: an incomplete, 90 second guide

Because this plugin's configuration is written in [CUE](https://cuelang.org),
you have all the facilities of CUE available when writing your configuration.

But don't let that put you off - **you don't need to learn a whole new language**!

In the **vast** majority of cases you'll only
need to use [CUE's `\(variable)` interpolation
syntax](https://cuelang.org/docs/tutorials/tour/expressions/interpolation/) to
set things up correctly.

Here's a really simple guide to the features of CUE that you'll probably need
to use.

This plugin requires your configuration file to declare itself, on its first
line, to be part of the `asdface` package in order to work correctly.

    package asdface

CUE is a hierarchy of key:value pairs, nested as deeply as you need.

CUE keys are strings. If they only contain only alphanumerics
(`[a-z][A-Z][0-9]`) and underscores then they don't need to be quoted. If they
contain hyphens, spaces, or other punctuation, then they have to be contained
in double quotes.

    key: ...
    key1: ...
    a_key_with_underscores: ...
    "a key with spaces": ...
    "a-key-with-hyphens": ...

Nested keys can also be quoted or unquoted strings, depending on their
alphanumeric contents, as above. Curly braces are used to indicate nesting.

    key: {
      a_nested_key: {
        "a-third-level-key": {
          "A Deeply nested key": ...
        }
      }
    }

CUE values can be any type. This plugin require leaf node values to be strings.

This plugin reads its configuration from keys inside the `v0.tools` hierarchy:

    v0: {
      tools: {
        ...
      }
    }

String values are contained in double quotes.

    key: "a key value"

Line comments extend from a double-forward-slash to the end of the line.

    // this is a comment on a line by itself
    key: "a value" // this is a comment alongside a key

Strings can be concatentated with the `+` operator.

    key: "a value " + "split in 2" // produces ...
    key: "a value split in 2"

Both of the above definitions of `key` can co-exist in the same config
simultaneously, because they agree with one another. CUE config is evaluated
order-independently, except where inherently ordered entities are involved,
such as arrays. This plugin does not require you to use arrays.

Strings can be split across multiple lines at any point, any number of times.
Indentation is unimportant, but the `cue fmt [filename]` command will reformat
your config file to the "official" standards, if you ask it to!

    key: "a long value that " +
       "needs to be split " +
                "across " +
       "multiple lines"
    key: "a long value that needs to be split across multiple lines"

As above, because both definitions of `key` agree with one another they are
able to co-exist in the same CUE configuration. However, the 2nd definition is
not *required* - it is included here solely to demonstrate the end result. It
would be entirely valid if it *were* included, however.

Strings can include variables that are interpolated inline, using `\(value)`
syntax.

    key1: "a value"
    key2: "this string also contains \(key1)"
    key2: "this string also contains a value"

Because CUE evaluation is order-independent, assignment can happen after use.

    key1: "this string contains \(key2)"
    key2: "another string"
    key1: "this string contains another string"

A single string can use both interpolation and concatentation.

    key1: "value"
    key2: "this string contains a \(key1) and also another " + key1
    key2: "this string contains a value and also another value"

The [variables that this plugin provides](#variables-provided-by-this-plugin)
can be interpolated or concatenated into strings, in all the ways laid out
above.

For example, given the variable `go.os.lc` containing the string `"linux"` ...

    key: "the/current-os/is/\(go.os.lc)/" // results in
    key: "the/current-os/is/linux/"

</details>
<hr>

##### Variables provided by this plugin

All variables must contain 2 components: a selector and a modifier, separated
by a `.` (period).

This is the set of valid selectors, which will expand as we discover more
useful values:

- `version`: the literal version requested by the user
- `uname.m`: the output of `uname -m` - the machine's processor architecture
- `uname.s`: the output of `uname -s` - the machine's operating system
- `go.os`:   the Go language's concept of the machine's running OS
- `go.arch`: a reasonable (but incomplete!) approximation of Go's
  `runtime.GOARCH` concept. Please do submit a PR (or [file an
  Issue](https://github.com/jpluscplusm/asdf-arbitrary-code-execution/issues/new))
  if this could be improved in any way!

Modifiers indicate the specific upper/lower/etc case version of the selector's
value that you want to use. You can use the following modifiers:

- `oc` - original case: the exact string that the operating system gave us
- `uc` - upper case: the `.oc` value, with all upper-case characters
- `lc` - lower case: the `.oc` value, with all lower-case characters
- `tc` - title case: the `.oc` value, with all words title-cased
  -this is not very useful, as title-casing works on word boundaries
  - it *might* be useful to get the string "Linux" from the input "linux" or
    "Amd64" from "amd64" or "Bsd" from "BSD"
- `cc` - camel case: the `.oc` value, with all words camel-cased
  - even less useful than title-cased. If this IS useful, please do PR an
    example to this doc!

### An example

So, for example, to reference a binary that's downloadable *for your specific machine* from

```
https://example.com/a_useful_project/releases/v1.2.3/downloads/project-linux-amd64
```

... the smallest reasonable `source` line that you could use is this (notice we
can split the value across lines, to make it more readable):

```
source: "https://example.com/a_useful_project/releases/" +
  "\(version.oc)/downloads/project-linux-amd64"
```

This is because at least one variant of the `version` selector should (*must*!)
be present in the `url` key, because the `$HOME/.tool-sources.asdface.cue` file
isn't the final arbiter of *which* version ASDF will install.  No: **ASDF (and
therefore you, the user) is in charge of WHICH version gets installed, not this
config file.**

The config file teaches ASDF, via this plugin, how to download DIFFERENT
versions.  If the version is hardcoded in the config then ... what's the point?

HOWEVER, this `source` line example, above, only works to switch between
versions on your specific machine: a machine running Linux and containing an
`x86_64`/`amd64` chip.

In order to make this config more portable, so you could re-use it on different
operating systems and physical hardware, you'd need to swap more fixed elements
for variables in the `source` line. All the examples in [this plugin's examples
directory](/examples/) use this feature, so that you can simply copy and paste
any of the examples into your `$HOME/.tool-sources.asdface.cue` file, and install
the appropriate tool instantly. If you're going to PR an example into this
plugin, so other people can benefit from your effort, please make the example
as portable as you can!

To demonstrate doing this, let's pretend that you check your example
`a_useful_project`'s Downloads page and discover that the project publishes
binaries for 3 different system types, on these 3 URL path suffixes:

```
paths relative to the prefix "https://example.com/a_useful_project":

  /releases/\(version.oc)/downloads/project-linux-x86_64
  /releases/\(version.oc)/downloads/project-darwin-arm64
  /releases/\(version.oc)/downloads/project-darwin-x86_64
```

In addition to the `version.oc` variable that you used (so that ASDF can switch
versions for you) there are 2 more variable components of the URL: the
operating system (`linux` vs `darwin` (Mac OS)) and the machine architecture
(`x86_64` vs `arm64`).

These variables are already available in the selectors `uname.s` (operating
system) and `uname.m` (architecture). Putting them in place, we end up with a
single `source` line that works on any machine type for which
`a_useful_project` has published binaries:

```
source: "https://example.com/a_useful_project/releases/" +
  version.oc +
  "/downloads/" +
  "project-\(uname.s.lc)-\(uname.m.lc)"
```

Notice that we split the long line to make it easier to read, and that we mix
our use of [CUE's string interpolation
syntax](https://cuelang.org/docs/tutorials/tour/expressions/interpolation/)
with simply [concatenating string values
togther](https://cuetorials.com/overview/expressions/#mathematical-operations),
where that makes more sense. This plugin doesn't care about how you use CUE to
assemble a value - it only cares that it can download and process the resulting
URL and archive :-)

Next, we add detail in the `create` key about the name of the binary we want to
be able to run on our machine (`useful`). We also wrap it up in the config
hierarchy that the plugin requires:

```
v0: tools: a_useful_project: #BinaryDownload & {
  source: "https://example.com/a_useful_project/releases/" +
    version.oc +
    "/downloads/" +
    "project-\(uname.s.lc)-\(uname.m.lc)"
  create: "useful"
}
```

After seeding the config file with the neccessary information about the tool we
want to install, we can install the binary.

**NB make sure you've [installed the CUE cli](#pre-requisites) -- an easy,
small, single-binary download -- before carrying on!**

```
asdf plugin add a_useful_project \
  https://github.com/jpluscplusm/asdf-arbitrary-code-execution
asdf install a_useful_project v1.2.3
```

... and then, to tell ASDF to make that version available to your shell:

```
asdf global a_useful_project v1.2.3
```

After running this, the (fake!) command `useful` would be available, with the
requested version having been downloaded and the correct binary having been
selected for the machine you're using.

`v1.2.3` in both the commands, above, **is where you tell ASDF which version
you want to install**.

Currently, this tool doesn't list remote versions, or know the latest/stable
version that's available. *You need to know and specify the exact version that
you want to install.*

## Development & changes

If you have examples of tools that can use this plugin, please PR them into the
[examples/](examples/) directory as appropriate.

To introduce new variables/features/etc, please:

1. Install [Dagger](https://docs.dagger.io/1200/local-dev)
   - If you'd prefer Dagger not to use Docker to bootstrap BuildKit for you,
     but instead you've run BuildKit manually, simply teach Dagger about your
     Buildkit server with `BUILDKIT_HOST=`
1. Fork the repo and check out (or branch off) the `develop` branch
1. Make changes, including adding tests
1. Run `dagger do test`
1. Make both your tests and the existing tests pass
1. Push your changes to your fork
1. Open a PR to incoporate your changes into the `develop` branch
