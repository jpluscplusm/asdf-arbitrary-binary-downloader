declare -- exports=""
declare -x export_name
declare -x source_name

for file in 99-exports/*; do
    export_name="$(basename $file)"
    source_name="$(printenv export_name | tr '[:upper:]' '[:lower:]')"
    declare -xr $export_name="$(printenv $source_name)"
    exports="$exports $export_name"
done
unset export_name source_name
readonly exports
