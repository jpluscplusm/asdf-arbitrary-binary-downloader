# `asdf-ace`: Arbitrary Code Execution

In this README:
  [Introduction](#introduction)
| [Quick start](#quick-start)
| [Using this plugin](#using-this-plugin)
| [Variables provided by this plugin](#variables-provided-by-this-plugin)
| [An example](#an-example-tool-and-configuration-file)
| [Contributing to this plugin](#contributing-to-this-plugin)
| [Why does this plugin exist?](#why-does-this-plugin-exist)
| [Technical details](#technical-details)

## Introduction

`asdf-ace` is a plugin for the [ASDF version manager](https://asdf-vm.com/) that
installs different version of arbitrary binaries _as configured by the user_,
and lets ASDF switch between those versions.

To use it, follow the [Quick start](#quick-start) guide. This guide:

- tells you about [the small set of pre-requisites](#pre-requisites) that
  you'll need to install first.
- takes you through [configuring this plugin](#configuration) via a simple file
  in your home directory. This file is your personally-unique list of all the
  tools that this plugin is allowed to install on your machine, and it can
  contain any tool that you find useful. It's not limited to tools that appear in
  [this plugin's examples directory](/examples) - that directory is just a
  starting point.
- shows you how to [use ASDF to add this plugin](#using-asdf-with-this-plugin)
  for each tool you want to install
- finally, shows you how to use ASDF to install a specific version of a tool
  and make it available to your user

Before doing that, however, folks who care about the security of their systems
should expand and read the following Security Klaxon section:

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
1. Find a tool that you want to install that publishes pre-compiled binaries
   either as direct downloads, or inside compressed tarballs or zip archives.
1. Grab the appropriate download URL for your machine and operating system.
1. Install [the `CUE`
   CLI](https://cuelang.org/docs/install/#install-cue-from-official-release-binaries).
1. Install `curl`, and optionally either of `unzip` or `tar`, depending on the
   format you're downloading.
1. Configure the file `$XDG_CONFIG_HOME/asdf-ace/tools.cue` [as described
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
package asdface

v0: tools:{
  example_tool_name: #TarGz & {
    source: "https://example.com/a_useful_project/releases/\(version.oc)/downloads/project-linux-amd64.tar.gz"
    create: my_tool: "from/this/file/in/the/tarball"
  }
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

_This tool hasn't yet reached version 1.0, which means it's still experimental
and its interface may change. We're working towards defining a stable
interface, so [your
feedback](https://github.com/jpluscplusm/asdf-arbitrary-code-execution/discussions/new?category=general)
about using the current interface will help us make the right choices, and is
extremely welcome!_

### Pre-requisites

Required:

- `curl`
- `cue` ([see below](#the-cue-cli))

Optional, depending on which packaging formats are referenced:

- Compressed tarballs: `tar` and `gunzip`
- Zip archives: `unzip`
- Direct binary downloads: no additional pre-requisites

#### The `cue` CLI

This plugin requires the `cue` CLI in order to work.

If you don't already have it on your machine, it can be easily installed from
[its official release
binaries](https://cuelang.org/docs/install/#install-cue-from-official-release-binaries)
on Windows, macOS, and Linux, or [installed from
source](https://cuelang.org/docs/install/#install-cue-from-source) on any other
platform that Go supports.

*I'm well aware of the irony of this plugin -- a tool to
automate the installation of arbitrary binaries off the internet -- requiring
its users to download a binary **manually** ... but this is the last one you
should ever need to fetch!*

Make the `cue` CLI available in your `$PATH`, however you usually do that.

If you're installing from CUE's [official release
binaries](https://cuelang.org/docs/install/#install-cue-from-official-release-binaries)
then it's an easy 3-step process:

<hr>
<details>
<summary>:accordion: Installing the `cue` CLI in 3 easy steps</summary>

Here's how to install `cue` from a package [published by the CUE
project](https://github.com/cue-lang/cue/releases/latest):

1. download the appropriate .tar.gz or .zip package for your operating system
   and machine from their [GitHub releases
   page](https://github.com/cue-lang/cue/releases/latest), near the bottom,
   under "Assets".
1. unpack just the `cue` binary from the package.
   - you don't need the `doc/` directory that's also included in the package.
   - for example:

         tar xfz path/to/the/package/you/just/downloaded.tar.gz cue

1. move the `cue` binary into a directory that's in your `$PATH`.
   - `$HOME/bin/` will probably work, as would `/usr/local/bin/` (but it's your
     machine, so it's up to you!).
   - for example:

         mkdir -p ~/bin/
         mv -i cue ~/bin/

   - If this is the first binary you've ever put in `$HOME/bin/`, you'll
     probably need to close and re-open your terminal to pick it up. Test this
     out by running `cue version` and seeing if your shell tells you "command
     not found". If so, close and re-open the terminal window.

If you find doing this even *slightly* annoying, then congratulations: you're
in the right place! The entire purpose of this ASDF plugin is to avoid having
to do this *slightly* annoying process ever again!

</details>
<hr>

### Configuration

Each tool you configure can refer to either a compressed tarball, a zip
archive, or a single unpackaged binary.

A compressed tarball or zip archive can have multiple binaries extracted from
them. An unpackaged binary can only provide that single binary.

Populate the file `$XDG_CONFIG_HOME/asdf-ace/tools.cue` with 1 or more tool's
information inside the top-level `v0` key ("v0" reflects the unstable nature of
this plugin, pre-1.0). If `$XDG_CONFIG_HOME` is unset (for instance if the tool
is being used on a non-Linux OS, or the XDG conventions are not being used),
the configuration file should be placed at `$HOME/.config/asdf-ace/tools.cue`.

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
need to use [CUE's `\(variable)`
interpolation](https://cuelang.org/docs/tutorials/tour/expressions/interpolation/)
to set things up correctly, and this syntax is extremely plain and
straightforward.

Here's a really simple guide to the features of CUE that you'll probably need
to use.

This plugin requires your configuration file to declare itself, on its first
line, to be part of the `asdface` package in order to work correctly.

    package asdface

Note that this package name doesn't contain a hyphen.

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

All variables contain 2 components: a selector and a modifier, separated by a
`.` (period).

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
value that you want to use. You can use the following modifiers on all
selectors:

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

Combining all the selectors with all the modifiers means that there are
currently 25 variables available to interpolate into your configuration keys:

```
    case>|   original         upper         lower         title         camel
---------+--------------------------------------------------------------------
Version  | version.oc    version.uc    version.lc    version.tc    version.cc
CPU      | uname.m.oc    uname.m.uc    uname.m.lc    uname.m.tc    uname.m.cc
OS       | uname.s.oc    uname.s.uc    uname.s.lc    uname.s.tc    uname.s.cc
GOOS     | go.os.oc      go.os.uc      go.os.lc      go.os.tc      go.os.cc
GOARCH   | go.arch.oc    go.arch.uc    go.arch.lc    go.arch.tc    go.arch.cc
```

### An example tool and configuration file

So, for example, to reference a binary that's downloadable *for your specific
machine* from

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
be present in the `url` key, because the `$XDG_CONFIG_HOME/asdf-ace/tools.cue`
file isn't the final arbiter of *which* version ASDF will install.  No: **ASDF
(and therefore you, the user) is in charge of WHICH version gets installed, not
this config file.**

The config file teaches ASDF, via this plugin, how to download DIFFERENT
versions.  If the version is hardcoded in the config then ... what's the point?

HOWEVER, this `source` line example, above, only works to switch between
versions on your specific machine: a machine running Linux and containing an
`x86_64`/`amd64` chip.

In order to make this config more portable, so you could re-use it on different
operating systems and physical hardware, you'd need to swap more fixed elements
for variables in the `source` line. All the examples in [this plugin's examples
directory](/examples/) use this feature, so that you can simply copy and paste
any of the examples into your `$XDG_CONFIG_HOME/asdf-ace/tools.cue` file, and
install the appropriate tool instantly. If you're going to PR an example into
this plugin, so other people can benefit from your effort, please make the
example as portable as you can!

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

### Using ASDF with this plugin

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

## Contributing to this plugin

### Examples of tools that other folks might find useful

If you have an example of a tool that can installed by this plugin, we'd love
to hear about them! If we can make the example portable enough, it'll be added
to the [example library](/examples) of tools that users can simply copy'n'paste
into their config files.

Please [start an "Ideas"
Discussion](https://github.com/jpluscplusm/asdf-arbitrary-code-execution/discussions/new?category=ideas)
with as much detail as you have about the tool, and how you've configured this
plugin to install it.

If you feel like [opening a
PR](https://github.com/jpluscplusm/asdf-arbitrary-code-execution/pulls) to add
the tool into the [examples/](examples/) directory, that would be really
helpful. If you add [a system test](dagger.cue#L96) to make sure that your
example is working, that would be awesome!

### New variables and features

If you're considering adding new variables or features to this plugin, we'll
assume you know a bit about development, and will simply outline the process to
you. Please read [the plugin's rationale](#why-does-this-plugin-exist) to check
if the feature you're thinking of proposing looks like a good fit.

Please:

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

## Why does this plugin exist?

I got bored with the repeated process of having to check that ASDF plugins
weren't malicious, so I wrote a plugin to replace ~90% of the ASDF plugins that
I use. This is that plugin: `asdf-ace`. If you'd like more detail, read the
:accordion:.

<hr>
<details>
<summary>:accordion: Why oh why oh why?</summary>

[ASDF](https://asdf-vm.com) is *great*! Just look at [the long list of all the
plugins](https://github.com/asdf-vm/asdf-plugins#plugin-list) folks have
written for it, and the size of its ecosystem! The folks who bother to take the
time to write those plugins are excellent human beings - their efforts helped
me start using ASDF, and I thank them for all their hard work :-)

I started using ASDF a while ago, as I wanted to replace a DIY version
management system I'd hacked into existence. But as I added to the set of tools
that I managed via ASDF, a boring process kept happening.

For every tool I installed, I found myself having to go into the associated
plugin's repo and double-check that its installer did what it said. After all,
it's running code on my machine ... I need to check it's not malicious.

I began to notice that each of the tools I installed, using plugins in that
long list, seemed to belong to one of three categories:

1. tools that are complex to install, and perhaps bring their own package
   manager along with them (e.g. `ruby`, `node`, `npm`)
1. tools that require several steps to compile, install; or perhaps unpack and
   arrange many files from an installer on the target system
1. tools whose installers download a single file from the internet, maybe
   uncompress it, and then chmod+x the result.

Over time, a pattern emerged.

I noticed that a significant majority of the tools I installed belonged to
category #3: `download`, then *maybe* `extract`, then `chmod`. And very often
their plugins were copy/paste versions of some normalised ASDF shell script ...
but I **still** had to manually check each one, as I couldn't be sure they
actually *were* a copy/paste.

This commonality strongly suggested that there was a repeatable, automatable
solution to this problem. And so, because I wanted to stop repeatedly
performing this mini-audit, over and over again, I wrote this plugin.

This plugin, `asdf-ace` tries to handle the simple, boring, "download a binary
off the internet and chmod it" case for tools that fit into category #3.

It takes a *tiny* bit of setup and 1% more effort to use than the many-plugins
approach, but it's worth it to me.

By publishing [config examples that users can cut'n'paste](/examples), even
that tiny bit of setup and +1% effort is reduced.

By allowing users to put anything they like in their configuration file, **this
plugin's repo doesn't act as a gatekeeper** of which tools are "allowed" to be
installed with this plugin. Adding any specific tool's config into the
[examples](/examples) directory is merely a **friendly, positive addition to
the ecosystem**, and *not a required step* in the process of using this plugin
to install that tool.

Hopefully, if you also like to know what code is running on your machine, you
don't have to *trust* this plugin: you can audit the code in this repo once,
pin to a specific commit for all your boring-tool ASDF installs, and not have
to repeat the audit rigamarole of a subtly different plugin for each new tool
you teach it about. Yes, you'll miss out on new features that this plugin
introduces (remote version listing and binary checksum checking is planned!),
but you'll *know* that you understand what's running on your machine.

To understand the plugin's inner workings, please read the [technical
details](#technical-details) section.

</details>
<hr>

## Technical details

### Summary

This plugin:

- learns which tool is it being told to install, by looking at the directory
  hierarchy into which it has been git-cloned by ASDF
- learns which version of the tool it is being told to install, by looking at
  an environment variable set by ASDF
- discovers various runtime-specific facts about the machine it's running on
  (e.g. processor architecture; OS type)
- feeds all the above data points into a CUE-based templating system, which ...
- reads the user-specified configuration, which contains user-authored mappings
  from facts to tool-and-version-specific download and install parameters; and
- emits a pair of download and install snippets, tailored to the machine on
  which the tool is being installed.

The plugin then:

- executes the download snippet to fetch the remote file
- executes the install snippet, which involves it:
  - uncompressing the downloaded file, if the user indicates that the remote
    file is a `.zip` or `.tar.gz`
  - renaming the resulting file to the name the user chose
  - making the file executable
  - moving the executable into the directory that ASDF told it to use

If the user points to a remote `.zip` or `.tar.gz`, the tool can be told to
extract more than one executable binary from the archive. This mechanism is
deliberately intended not to scale beyond a few files.

### A poor analogy to a shell script

This plugin is a more capable but more complicated version of the following
(fake, non-functional) shell script. It's hidden behind a :accordion: because
it's so ugly that it's offputting, and *this shell script plays absolutely no
part in this plugin's job: **it's shown here solely as a pseudo-code analogy**!*

<hr>
<details>
<summary>:accordion: Don't worry - this isn't the actual implementation!</summary>

```bash
config_file=~/.config/asdf-ace/tools.not-really.this-is-fake.txt

read TOOL_TO_INSTALL
read VERSION_TO_INSTALL
read INSTALL_DIRECTORY

URL=$(grep "^${TOOL_TO_INSTALL}.url" $config_file | cut -f2)
UNAME_M=$(uname -m)
UNAME_S=$(uname -s)

cat generic-download-script                      \
| sed -e "s/__URL__/$URL/g"                      \
      -e "s/__VERSION__/$VERSION_TO_INSTALL/g"   \
      -e "s/__UNAME_M__/$UNAME_M/g"              \
      -e "s/__UNAME_S__/$UNAME_S/g"              \
| bash                                           \
> downloaded-file

UNPACKER=$(grep "^${TOOL_TO_INSTALL}.unpacker" $config_file | cut -f2)
BINARY=$(grep   "^${TOOL_TO_INSTALL}.binary"   $config_file | cut -f2)

cat generic-install-script                       \
| sed -e "s/__UNPACKER__/$UNPACKER/g"            \
      -e "s/__BINARY__/$BINARY/g"                \
      -e "s/__DOWNLOAD__/downloaded-file/g"      \
      -e "s/__VERSION__/$VERSION_TO_INSTALL/g"   \
      -e "s/__INSTALL_TO__/$INSTALL_DIRECTORY/g" \
      -e "s/__UNAME_M__/$UNAME_M/g"              \
      -e "s/__UNAME_S__/$UNAME_S/g"              \
| bash
```

</details>
<hr>

More detail will be added here.
