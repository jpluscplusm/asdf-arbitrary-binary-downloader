package asdface

v0: tools: {
	qrterminal: #TarGz & {
		source: "https://github.com/mdp/qrterminal/releases/download/" +
			"v\(version.oc)/qrterminal_\(version.oc)_\(go.os.lc)_\(uname.m.lc).tar.gz"
		create: qrterminal: "qrterminal"
	}
}
