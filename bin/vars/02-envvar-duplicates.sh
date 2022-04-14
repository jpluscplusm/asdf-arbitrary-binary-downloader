declare -x value

for file in $(find 02-envvar-duplicates/ -maxdepth 1 -type f); do
    name="$(basename $file)"
    value="$(cat $file)"
    declare -rx $name="$(printenv $value)"
    facts="$facts $name"
done

unset name value
readonly facts
