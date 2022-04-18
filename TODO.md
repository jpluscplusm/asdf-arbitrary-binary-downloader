# The road to 1.0

## UX

- Make README friendlier
  - explain the "why"
  - expain the "how" flowchart
- Make it easier to contribute
  - examples
  - machine types
  - facts
  - fixes to facts

## Tests to add

- in-CUE scripts:
  - shellcheck
- more test cases, probably combinatorial:
  - tar with multiple files
  - remote file, tarball member, and installed-binary with:
    - hyphens in name
    - spaces in name
    - dots in name
  - more than one tool in config
    - maybe make this combinatorially exhaustive; but only inside GHA?
- assert against binary --help output, needs per-binary param config
- multiple binary version tests/matrix-in-dagger
- local HTTP server for system test speed-up
  - less traffic, too
  - don't inject fake binaries into /this/ repo, so actual users don't take that download hit
- cross-OS system tests
  - probably just GHA's macos runners for now
- cross-distro system tests
  - where we're using `debian`, add some more

# post 1.0, but API-compatible

- list-versions/list-all
  - use a Definition as a user-configured, opt-in, per-remote-host-type decorator
  - e.g.
      toolX: #TarGz & #GithubRelease & { ... }
  - because we're only defaulting list-all.sh right now, this can be a seamless upgrade

# 2.0

- many-to-many remote-file-to-binary installs
  - I don't need this, so I need to get example from people who /do/
  - probably API-breaking
  - may never get implemented!
