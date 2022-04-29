package golang

import (
	"jonathanmatthews.com/utility:jmstrings"
)

#Go: {
	X="in": {
		m:  string
		os: string
	}
	os: jmstrings.#MultiCaseString & {
		in: X.os
	}
	arch: jmstrings.#MultiCaseString & {
		in: *_arch_map[X.m] | X.m
	}
	_arch_map: {
		x86_64: "amd64"
	}
}
