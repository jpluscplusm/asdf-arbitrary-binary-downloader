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
		test:      docker.#Run & {
			input: shellcheck.container.image
			mounts: project_root: {
				dest:     "/mnt/" // ... the non -alpine shellcheck container defaults to this
				type:     "fs"
				contents: client.filesystem.".".read.contents
			}
			command: {
				name: "/bin/shellcheck"
				args: [
					for file in client.filesystem.".".read.include {// .include must be files, not dirs
						mounts.project_root.dest + file
					},
				]
			}
		}
	}
}

client: filesystem: {
	".": read: {
		contents: dagger.#FS
		include: [
			"bin/list-all",
			"bin/download",
		]
	}
}
