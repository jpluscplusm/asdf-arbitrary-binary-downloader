package test

import (
	"jonathanmatthews.com/asdf/ace/facts:system"
)

setup1: {
	fixture: {
		s: "teStS"
		m: "teStM"
	}
	test1: {
		sut: system.#Uname & {
			in: fixture
		}
		assert: sut & {
			m: {
				oc: "teStM"
				lc: "testm"
				uc: "TESTM"
			}
			s: {
				oc: "teStS"
				lc: "tests"
				uc: "TESTS"
			}
		}
	}
}
