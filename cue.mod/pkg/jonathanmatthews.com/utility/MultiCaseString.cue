package jmstrings

import "strings"

#MultiCaseString: {
	X1="in": string
	oc:      X1
	uc:      strings.ToUpper(oc)
	lc:      strings.ToLower(oc)
	tc:      strings.ToTitle(oc)
	cc:      strings.ToCamel(oc)
}
