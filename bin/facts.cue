package asdface

import (
	"strings"
)

local: {
	download_dir: string @tag(download_dir)
	install_dir:  string @tag(install_dir)
}

version: #MCS & {oc: string @tag(version)}

uname: {
	[string]: #MCS & {oc: string}
	m: {oc: string @tag(uname_m)}
	s: {oc: string @tag(uname_s)}
}
go: {
	[string]: #MCS & {oc: string}
	os: {oc: string @tag(os, var=os)}
	arch: {oc: string | *strings.Replace(uname.m.oc, "x86_64", "amd64", -1) @tag(goarch)}
}

// MultiCaseString
#MCS: {
	oc: string
	uc: strings.ToUpper(oc)
	lc: strings.ToLower(oc)
}
