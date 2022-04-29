package asdface

import (
	"jonathanmatthews.com/utility:jmstrings"
	"jonathanmatthews.com/asdf/ace:types"
)

#TarGz:          types.#TarGz & {local:          asdf}
#Zip:            types.#Zip & {local:            asdf}
#BinaryDownload: types.#BinaryDownload & {local: asdf}

version: jmstrings.#MultiCaseString & {
	in: string @tag(version)
}

uname: {
	m: jmstrings.#MultiCaseString & {
		in: string @tag(uname_m)
	}
	s: jmstrings.#MultiCaseString & {
		in: string @tag(uname_s)
	}
}
go: {
	os: jmstrings.#MultiCaseString & {
		in: string @tag(os, var=os)
	}
	arch: jmstrings.#MultiCaseString & {
		in: *_arch_map[uname.m.lc] | uname.m.lc
	}
	_arch_map: {
		x86_64: "amd64"
	}
}

asdf: {
	download_dir: string @tag(download_dir)
	install_dir:  string @tag(install_dir)
}
