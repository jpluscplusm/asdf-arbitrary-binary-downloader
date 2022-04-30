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
		in: !~"[A-Z]" // insist that input is lower-case
	}
	arch: jmstrings.#MultiCaseString & {
		in: *_arch_map[X.m] | X.m
		in: !~"[A-Z]" // insist that input is lower-case
	}
	_arch_map: {
		x86_64:     "amd64"
		i386:       "386"
		"686":      "386"
		i686:       "386"
		i86pc:      "386"
		arm6:       "arm"
		arm7:       "arm"
		arm6l:      "arm"
		arm7l:      "arm"
		aarch32:    "arm"
		aarch64:    "arm64"
		aarch64_be: "arm64"
		armv8b:     "arm64"
		armv8l:     "arm64"
		aarch64:    "arm64"
	}
}
