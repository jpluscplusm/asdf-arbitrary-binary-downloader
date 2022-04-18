package jmstrings

import "strings"

// MultiCaseString
#MCS: {
	oc: string
	uc: strings.ToUpper(oc)
	lc: strings.ToLower(oc)
	tc: strings.ToTitle(oc)
	cc: strings.ToCamel(oc)
}
