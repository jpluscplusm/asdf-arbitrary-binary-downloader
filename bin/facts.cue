package asdface

import (
	"strings"
	"jonathanmatthews.com/utility:jmstrings"
)

local: {
	download_dir: string @tag(download_dir)
	install_dir:  string @tag(install_dir)
}

version: jmstrings.#MCS & {oc: string @tag(version)}

uname: {
	[string]: jmstrings.#MCS & {oc: string}
	m: {oc: string @tag(uname_m)}
	s: {oc: string @tag(uname_s)}
}
go: {
	[string]: jmstrings.#MCS & {oc: string}
	os: {oc: string @tag(os, var=os)}
	arch: {oc: string | *strings.Replace(uname.m.oc, "x86_64", "amd64", -1) @tag(goarch)}
}
