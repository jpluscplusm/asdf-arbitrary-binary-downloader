package asdface

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

dagger.#Plan
actions: {
	//: Unit test the project
	unit: shellcheck: {
		container: docker.#Pull & {source: "koalaman/shellcheck-alpine:stable"}
		#asdf_interface: [
			"bin/list-all",
			"bin/download",
			"bin/install",
		]
		test: {
			for relative_file in #asdf_interface {
				"\(relative_file)": docker.#Run & {
					input: shellcheck.container.image
					mounts: project_root: {
						dest:     "/mnt/" // ... the non -alpine shellcheck container defaults to this
						type:     "fs"
						contents: client.filesystem.".".read.contents
					}
					command: {
						name: "/bin/shellcheck"
						args: [ mounts.project_root.dest + relative_file]
					}
				}
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
