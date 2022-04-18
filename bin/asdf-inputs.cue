package asdface

import (
	"jonathanmatthews.com/utility:jmstrings"
)

local: {
	download_dir: string @tag(download_dir)
	install_dir:  string @tag(install_dir)
}

version: jmstrings.#MCS & {oc: string @tag(version)}
