package asdface

v0: {
	tools: {
		agebox: #BinaryDownload & {
			source: "https://github.com/slok/agebox/releases/download/\(version.oc)/agebox-\(go.os.lc)-\(go.arch.lc)"
			create: "agebox"
		}
	}
}
