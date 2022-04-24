package asdface

// NB this example is not well structured, and may well fail on Apple machines,
// and non-x86_64 machines. It is a work in progress!

v0: {
	tools: {
		op: #Zip & {
			source: "https://cache.agilebits.com/dist/1P/op2/pkg/" +
				"\(version.lc)/op_\(uname.s.lc)_\(go.arch.lc)_\(version.lc).zip"
			create: op: "op"
		}
	}
}
