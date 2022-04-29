package test

import (
	"jonathanmatthews.com/asdf/ace/facts:golang"
)

x86_64: {
	x86="fixture": {
		m: "x86_64"
	}
	linux: {
		fixture: x86 & {
			os: "Linux"
		}
		test1: {
			sut: golang.#Go & {
				in: fixture
			}
			assert: sut & {
				os: {
					oc: "Linux"
					lc: "linux"
					uc: "LINUX"
				}
				arch: {
					oc: "amd64"
					lc: "amd64"
					uc: "AMD64"
					tc: "Amd64"
				}
			}
		}
	}
}
