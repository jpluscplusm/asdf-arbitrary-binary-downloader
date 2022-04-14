declare -- facts=""
declare -- name
declare -- value

for file in 01-facts/*; do
    name="$(basename $file)"
    value="$(env -i sh -c ". $file")"
    declare -rx $name="$value"
    facts="$facts $name"
done
#readonly facts
