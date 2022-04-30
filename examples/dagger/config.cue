package asdface

v0: tools: {
	dagger: #TarGz & {
		source: "https://github.com/dagger/dagger/releases/download/" +
			"\(version.oc)/dagger_\(version.oc)_\(go.os.lc)_\(go.arch.lc).tar.gz"
		create: dagger: "dagger"
	}
}
