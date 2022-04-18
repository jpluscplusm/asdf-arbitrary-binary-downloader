package asdface

import (
	"strings"
	"jonathanmatthews.com/utility:jmstrings"
)

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
