package asdface

import (
	"strings"
	"cue.jonathanmatthews.com/utility:jmstrings"
)

uname: {
	[string]: jmstrings.#MCS & {oc: string}
	m: {oc: string | *"UNSET-in-system-info.cue" @tag(uname_m)}
	s: {oc: string | *"UNSET-in-system-info.cue" @tag(uname_s)}
}
go: {
	[string]: jmstrings.#MCS & {oc: string}
	os: {oc: string | *"UNSET-in-system-info.cue" @tag(os, var=os)}
	arch: {oc: string | *strings.Replace(uname.m.oc, "x86_64", "amd64", -1) @tag(goarch)}
}
