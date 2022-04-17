package asdface

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

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
			test: {
				for relative_file in #asdf_script_interface {
					(relative_file): #ShellCheck & {_file_to_check: relative_file}
				}
				#ShellCheck: docker.#Run & {
					_file_to_check: string
					input:          actions._dockerhub.shellcheck.image
					mounts: project_root: {
						dest:     "/mnt/" // ... as per the non -alpine shellcheck image
						type:     "fs"
						contents: client.filesystem.".".read.contents
					}
					command: {
						name: "/bin/shellcheck"
						args: [ "-x", mounts.project_root.dest + _file_to_check]
					}
				}
			}
		}
	}
	//# Run all the system tests
	system: {
		build: docker.#Build & {
			steps: [
				docker.#Run & {
					input: actions._dockerhub.debian.image
					env: DEBIAN_FRONTEND: "noninteractive"
					command: {
						name: "/bin/bash"
						args: [ "-c", """
							apt-get -q update
							apt-get -q install -o=Dpkg::Use-Pty=0 --no-install-recommends --no-install-suggests --assume-yes \\
								curl \\
								git \\
								ca-certificates
							git config --add --global advice.detachedHead false
							git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.9.0
							echo 'PATH+=:$HOME/bin' >> $HOME/.bashrc
							echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc
							mkdir -p ~/bin
							(
							cd bin
							curl --location -s https://github.com/cue-lang/cue/releases/download/v0.4.2/cue_v0.4.2_linux_amd64.tar.gz \\
							| tar xfz - cue
							chmod +x cue
							)
							""",
						]
					}
				},
				docker.#Run & {
					_packages: [
						"coreutils", // env, uname, dirname, tr, basename, chmod, mv, rmdir, md5sum
						"bash",      // bash
						"tar",       // tar
						"curl",      // curl
					]
					env: DEBIAN_FRONTEND: "noninteractive"
					command: {
						name: "apt-get"
						args: [ "-q", "install", "-o=Dpkg::Use-Pty=0", "--assume-yes", "--no-install-recommends", "--no-install-suggests"] + _packages
					}
				},
			]
		}
		examples: {
			qrterminal: docker.#Run & {
				input: system.build.output
				mounts: {
					project_root: {
						dest:     "/project/"
						type:     "fs"
						contents: client.filesystem.".".read.contents
					}
				}
				command: {
					name: "/bin/bash"
					//       -l enters bash's `login` startup flow, so that ~/.bashrc is sourced
					args: [ "-lc", """
						set -euo pipefail
						cd \(mounts.project_root.dest)
						# asdf needs local changes to be present in git commits, so we start from an empty repo and add everything
						git init -b test_in_dagger >/dev/null
						git add .
						git -c user.email=t@example.com -c user.name=testing commit -m testing >/dev/null
						#export ASDF_ACE_DEBUG=1
						asdf plugin add qrterminal \(mounts.project_root.dest)
						# FIXME: the rest of this is bad, and in the wrong place
						export EXAMPLE=\(mounts.project_root.dest)/examples/qrterminal
						cp $EXAMPLE/qrterminal.cue $HOME/.tool-sources.asdface.cue
						# This vvv line vvv *is* the test. ^^^ that ^^^ is setup, and lines +2 onwards are results checking
						# It's probably worth shunting this all into bats at some point, but let's see how far we get without it.
						asdf install qrterminal 2.0.1
						asdf global qrterminal 2.0.1
						cat "$(asdf which qrterminal)" | md5sum --check $EXAMPLE/2.0.1.binary.md5sum
						""",
					]
				}
			}
			hurl: docker.#Run & {
				input: system.build.output
				mounts: {
					project_root: {
						dest:     "/project/"
						type:     "fs"
						contents: client.filesystem.".".read.contents
					}
				}
				command: {
					name: "/bin/bash"
					//       -l enters bash's `login` startup flow, so that ~/.bashrc is sourced
					args: [ "-lc", """
						set -euo pipefail
						cd \(mounts.project_root.dest)
						# asdf needs local changes to be present in git commits, so we start from an empty repo and add everything
						git init -b test_in_dagger >/dev/null
						git add .
						git -c user.email=t@example.com -c user.name=testing commit -m testing >/dev/null
						#export ASDF_ACE_DEBUG=1
						asdf plugin add hurl \(mounts.project_root.dest)
						# FIXME: the rest of this is bad, and in the wrong place
						export EXAMPLE=\(mounts.project_root.dest)/examples/hurl
						cp $EXAMPLE/hurl.cue $HOME/.tool-sources.asdface.cue
						DEBIAN_FRONTEND=noninteractive apt-get -q install libxml2 libicu67 -o=Dpkg::Use-Pty=0 --no-install-suggests --no-install-recommends # ew
						# This vvv line vvv *is* the test. ^^^ that ^^^ is setup, and lines +2 onwards are results checking
						# It's probably worth shunting this all into bats at some point, but let's see how far we get without it.
						asdf install hurl 1.6.1
						asdf global hurl 1.6.1
						cat "$(asdf which hurl)"         | md5sum --check $EXAMPLE/1.6.1.binary.md5sum
						hurl --version | cut -f1-2 -d' ' | md5sum --check $EXAMPLE/1.6.1.version-output.truncated.md5sum
						""",
					]
				}
			}
			honeyvent: docker.#Run & {
				input: system.build.output
				mounts: {
					project_root: {
						dest:     "/project/"
						type:     "fs"
						contents: client.filesystem.".".read.contents
					}
				}
				command: {
					name: "/bin/bash"
					//       -l enters bash's `login` startup flow, so that ~/.bashrc is sourced
					args: [ "-lc", """
						set -euo pipefail
						cd \(mounts.project_root.dest)
						# asdf needs local changes to be present in git commits, so we start from an empty repo and add everything
						git init -b test_in_dagger >/dev/null
						git add .
						git -c user.email=t@example.com -c user.name=testing commit -m testing >/dev/null
						#export ASDF_ACE_DEBUG=1
						asdf plugin add honeyvent \(mounts.project_root.dest)
						# FIXME: the rest of this is bad, and in the wrong place
						export EXAMPLE=\(mounts.project_root.dest)/examples/honeyvent
						ln -s $EXAMPLE/honeyvent.cue $HOME/.tool-sources.asdface.cue
						#DEBIAN_FRONTEND=noninteractive apt-get -q install libxml2 libicu67 -o=Dpkg::Use-Pty=0 --no-install-suggests --no-install-recommends # ew
						# This vvv line vvv *is* the test. ^^^ that ^^^ is setup, and lines +2 onwards are results checking
						# It's probably worth shunting this all into bats at some point, but let's see how far we get without it.
						asdf install honeyvent v1.1.0
						asdf global honeyvent v1.1.0
						cat "$(asdf which honeyvent)"         | md5sum --check $EXAMPLE/v1.1.0.binary.md5sum
						#hurl --version | cut -f1-2 -d' ' | md5sum --check $EXAMPLE/1.6.1.version-output.truncated.md5sum
						""",
					]
				}
			}
		}
	}
}

actions: _dockerhub: {
	shellcheck: docker.#Pull & {source: "koalaman/shellcheck-alpine:stable"}
	debian:     docker.#Pull & {source: "debian:bullseye"}
}

client: filesystem: {
	".": read: {
		contents: dagger.#FS
		exclude: [ ".git", "cue.mod", "dagger.cue"]
	}
}
