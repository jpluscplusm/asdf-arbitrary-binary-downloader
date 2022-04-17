package asdface

import (
	"strings"
	"path"
)

#BinaryDownload: {
	source: string
	create: string
	script: {
		download: {
			_remote_filename: strings.SplitN(path.Base(source, path.Unix), "?", 2)[0]
			_local_file:      download_dir + "/" + _remote_filename
			sh:               "curl --fail --location --silent \(source) -o \(_local_file)"
		}

		install: {
			_bin_dir: install_dir + "/bin"
			sh:       """
				mkdir -p \(_bin_dir)
				mv \(script.download._local_file) \(_bin_dir)/\(create)
				chmod u+x \(_bin_dir)/\(create)
				"""
		}
	}
}

download_dir: string | *"/tmp/download" @tag(download_dir)
install_dir:  string | *"/tmp/install"  @tag(install_dir)

#TarGz: {
	source: string
	create: [string]: string
	script: {
		download: {
			_remote_filename: strings.SplitN(path.Base(source, path.Unix), "?", 2)[0]
			_local_file:      download_dir + "/" + _remote_filename
			sh:               "curl --fail --location --silent \(source) -o \(_local_file)"
		}

		install: {
			_bin_dir: install_dir + "/bin"
			sh:       """
				mkdir -p \(_bin_dir)
				\(strings.Join([ for file in files {file.sh}], "\n"))
				"""
			files: {
				for to, from in create {
					(to): {
						_install_file: _bin_dir + "/" + to
						sh:            """
						tar -f \(download._local_file) -x -z --to-stdout \(from) >\(_install_file)
						chmod +x \(_install_file)
						"""
					}
				}
			}
		}
	}
}

version: #MCS & {oc: string @tag(version)}
uname: {
	[string]: #MCS & {oc: string}
	m: {oc: string @tag(uname_m)}
	s: {oc: string @tag(uname_s)}
}
go: {
	[string]: #MCS & {oc: string}
	os: {oc: string @tag(os, var=os)}
	arch: {oc: string | *strings.Replace(uname.m.oc, "x86_64", "amd64", -1) @tag(goarch)}
}

// MultiCaseString
#MCS: {
	oc: string
	uc: strings.ToUpper(oc)
	lc: strings.ToLower(oc)
}
