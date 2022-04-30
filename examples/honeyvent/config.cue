package asdface

v0: tools: {
	honeyvent: #BinaryDownload & {
		source: "https://github.com/honeycombio/honeyvent/releases/download/" +
			"\(version.oc)/honeyvent-\(go.os.lc)-\(go.arch.lc)"
		create: "honeyvent"
	}
}
