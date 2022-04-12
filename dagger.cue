package asdface

import (
	"dagger.io/dagger/core"
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

_remote_test_ref: "https://github.com/jpluscplusm/asdf-arbitrary-code-execution"

dagger.#Plan

//# Run all the tests: unit + system (use `dagger do test --help` for more help ...)
actions: test: {
	//# Run all the unit tests (use `dagger do test unit --help` for info about more deeply-nested tasks ...)
	unit: {
		#asdf_script_interface: [
			"bin/list-all",
			"bin/download",
			"bin/install",
		]

		//# Use shellcheck to perform static analysis of the scripts in the defined ASDF interface
		shellcheck: {
			_container: docker.#Pull & {source: "koalaman/shellcheck-alpine:stable"}
			test: {
				for relative_file in #asdf_script_interface {
					(relative_file): #ShellCheck & {_file_to_check: relative_file}
				}
				#ShellCheck: docker.#Run & {
					_file_to_check: string
					input:          shellcheck._container.image
					mounts: project_root: {
						dest:     "/mnt/" // ... as per the non -alpine shellcheck image
						type:     "fs"
						contents: client.filesystem.".".read.contents
					}
					command: {
						name: "/bin/shellcheck"
						args: [ mounts.project_root.dest + _file_to_check]
					}
				}
			}
		}
	}
	//# Run all the system tests
	system: {
		// get debian
		debian: container: docker.#Pull & {source: "debian:bullseye"}
		// run tests for all examples
		examples: {
			// validate this example
			qrterminal: {
				// install asdf
				asdf: {
					// install asdf's dependencies
					dependencies: docker.#Run & {
						input: debian.container.image
						command: {
							name: "/bin/bash"
							args: [ "-c", """
								apt-get update
								apt-get install curl git ca-certificates --no-install-recommends --no-install-suggests --assume-yes
								""",
							]
						}
					}
					// install asdf itself
					install: docker.#Run & {
						input: asdf.dependencies.output
						command: {
							name: "/bin/bash"
							args: [ "-c", """
								git config --add --global advice.detachedHead false
								git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.9.0
								echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc
								""",
							]
						}
					}
				}

				// test the ACE project
				ace: {
					// install my dependencies
					dependencies: docker.#Run & {
						_packages: [
							"coreutils",    // env, uname, dirname, tr, basename, chmod, mv, rmdir, md5sum
							"bash",         // bash
							"tar",          // tar
							"gettext-base", // envsubst
							"curl",         // curl
							"jq",           // jq
						]
						input: asdf.install.output
						command: {
							name: "apt-get"
							args: [ "install", "--assume-yes", "--no-install-recommends", "--no-install-suggests"] + _packages
						}
					}
					// instantiate me as a plugin for this test
					instantiate: docker.#Run & {
						input:     ace.dependencies.output
						_examples: core.#Subdir & {
							input: client.filesystem.".".read.contents
							path:  "examples/"
						}
						mounts: examples_root: {
							dest:     "/examples/"
							type:     "fs"
							contents: _examples.output
						}
						command: {
							name: "/bin/bash"
							//       -l enters bash's `login` startup flow, so that ~/.bashrc is sourced
							args: [ "-lc", """
									set -euo pipefail
									asdf plugin add qrterminal \(_remote_test_ref) # make _ref dynamic
									# FIXME: the rest of this is bad, and in the wrong place
									export EXAMPLE=/examples/qrterminal
									cp $EXAMPLE/TOOLS.json ~/TOOLS.json
									asdf install qrterminal 2.0.1
									asdf global qrterminal 2.0.1
									cd "$(dirname "$(asdf which qrterminal)")"
									md5sum --check $EXAMPLE/md5sum.txt
									# FIXME: can't do stdout/stderr comparions, as something makes qrt inject its
									# full path into its -v output. Fix later.
									""",
							]
						}
					}
				}
				// add timings
			}
		}
	}
}

client: filesystem: {
	".": read: {
		contents: dagger.#FS
		exclude: [ ".git", "cue.mod"]
	}
}
