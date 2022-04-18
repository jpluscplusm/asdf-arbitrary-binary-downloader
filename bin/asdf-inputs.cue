package asdface

import (
	"cue.jonathanmatthews.com/utility:jmstrings"
)

local: {
	download_dir: string | *"UNSET-in-asdf-input.cue" @tag(download_dir)
	install_dir:  string | *"UNSET-in-asdf-input.cue" @tag(install_dir)
}

version: jmstrings.#MCS & {oc: string | *"UNSET-in-asdf-input.cue" @tag(version)}
