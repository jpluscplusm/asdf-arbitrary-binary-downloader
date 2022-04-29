package facts

import (
	"jonathanmatthews.com/utility:jmstrings"
)

#Uname: {
	X="in": {
		m: string
		s: string
	}
	m: jmstrings.#MultiCaseString & {
		in: X.m
	}
	s: jmstrings.#MultiCaseString & {
		in: X.s
	}
}
