package asdface

import (
	"jonathanmatthews.com/utility:jmstrings"
	"jonathanmatthews.com/asdf/ace:types"
	"jonathanmatthews.com/asdf/ace/facts:system"
	"jonathanmatthews.com/asdf/ace/facts:golang"
)

#TarGz:          types.#TarGz & {local:          asdf}
#Zip:            types.#Zip & {local:            asdf}
#BinaryDownload: types.#BinaryDownload & {local: asdf}

version: jmstrings.#MultiCaseString & {
	in: string @tag(version)
}

uname: system.#Uname & {
	in: {
		m: string @tag(uname_m)
		s: string @tag(uname_s)
	}
	m: jmstrings.#MultiCaseString
	s: jmstrings.#MultiCaseString
}

go: golang.#Go & {
	in: {
		os: string @tag(os, var=os)
		m:  uname.m.lc
	}
	os:   jmstrings.#MultiCaseString
	arch: jmstrings.#MultiCaseString
}

asdf: {
	download_dir: string @tag(download_dir)
	install_dir:  string @tag(install_dir)
}
