package test

import (
	"jonathanmatthews.com/asdf/ace/facts:golang"
)

"Test architecture map": {

	#fixture: golang.#Go & {
		in: os: "linux" // input
		os: oc: "linux" // fixed output, asserted once, not per-test
	}

	positive_tests: [ArchName=_]: {
		in: m: ArchName
	}

	positive_tests: {

		// x86: maps and pass-through values

		for a in [ "x86_64", "amd64"] {
			(a): #fixture & {
				arch: {
					lc: "amd64"
					oc: "amd64"
				}
			}
		}

		// Golang collapses x86, non-64-bit down to "386"

		for a in [ "386", "i386", "686", "i686"] {
			(a): #fixture & {
				arch: {
					lc: "386"
					oc: "386"
				}
			}
		}
	}

	negative_tests: {
		// this is a misplaced test of the lower-case-only constraint
		Amd64: true     // negative assertion
		Amd64: _|_ == ( // this is how we currently test negatively (see https://github.com/cue-lang/cue/discussions/1690)
			#fixture & {
				in: m: "Amd64"
				arch: {
					lc: "amd64"
					oc: "amd64"
				}
			})
	}

}
