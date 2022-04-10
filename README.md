# asdf-arbitrary-binary-downloader

A plugin for the ASDF version manager that installs arbitrary binaries 

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

The `url` key's value can contain the following variables, referenced in
shell-like `${FOO}` form:

- `VERSION`: the literal version of the tool that asdf has been asked to install
- `GO_GOOS_LC`: the lowercase value of `uname -s`
- `GO_GOARCH_LC`: the lowercase value of `uname -m`, but where `x86_64` => `amd64`

Then run:

1. `asdf plugin add tool_name_underscores_no_hyphens https://github.com/jpluscplusm/asdf-arbitrary-binary-downloader`
1. `asdf install tool_name_underscores_no_hyphens some.version.number`

Note that this tool currently doesn't list remote versions, or know the
latest/stable version that's available. *You need to know and specify the
exact version that you want to install.*
