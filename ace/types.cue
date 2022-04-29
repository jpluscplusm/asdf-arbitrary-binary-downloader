package types

import (
	"strings"
	"path"
)

_#filesytem_inputs: {
	download_dir: string
	install_dir:  string
}

#BinaryDownload: {
	source: string
	create: string
	local:  _#filesytem_inputs
	script: {
		download: {
			_remote_filename: strings.SplitN(path.Base(source, path.Unix), "?", 2)[0]
			_local_file:      local.download_dir + "/" + _remote_filename
			sh:               "curl --fail --location --silent \(source) -o \(_local_file)"
		}
		"list-all": sh: string | *"echo"
		install: {
			_bin_dir: local.install_dir + "/bin"
			sh:       """
				mkdir -p \(_bin_dir)
				mv \(script.download._local_file) \(_bin_dir)/\(create)
				chmod u+x \(_bin_dir)/\(create)
				"""
		}
	}
}

#TarGz: {
	source: string
	create: [string]: string
	local: _#filesytem_inputs
	script: {
		download: {
			_remote_filename: strings.SplitN(path.Base(source, path.Unix), "?", 2)[0]
			_local_file:      local.download_dir + "/" + _remote_filename
			sh:               """
				curl --fail --location --silent \(source) -o \(_local_file)
				"""
		}
		"list-all": sh: string | *"echo"
		install: {
			_bin_dir: local.install_dir + "/bin"
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

#Zip: {
	source: string
	create: [string]: string
	local: _#filesytem_inputs
	script: {
		download: {
			_remote_filename: strings.SplitN(path.Base(source, path.Unix), "?", 2)[0]
			_local_file:      local.download_dir + "/" + _remote_filename
			sh:               """
				curl --fail --location --silent \(source) -o \(_local_file)
				"""
		}
		"list-all": sh: string | *"echo"
		install: {
			_bin_dir: local.install_dir + "/bin"
			sh:       """
				unzip -tq \(download._local_file) # test CRC of entire zipfile
				mkdir -p \(_bin_dir)
				\(strings.Join([ for file in files {file.sh}], "\n"))
				"""
			files: {
				for to, from in create {
					(to): {
						_install_file: _bin_dir + "/" + to
						sh:            """
							unzip -p -q \(download._local_file) \(from) >\(_install_file)
							chmod +x \(_install_file)
							"""
					}
				}
			}
		}
	}
}
