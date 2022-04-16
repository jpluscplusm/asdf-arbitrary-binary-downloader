package asdface

import "strings"

v0: tools: hurl: {
	url: "https://github.com/Orange-OpenSource/hurl/releases/download/" +
		"\(version.oc)/hurl-\(version.oc)-x86_64-" +
		strings.Replace(go.os.lc, "darwin", "osx", -1) +
			".tar.gz"
	tar_path: "hurl-\(version.oc)/hurl"
	bin_name: "hurl"
}
