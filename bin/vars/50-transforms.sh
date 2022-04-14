declare -- transforms=""

for transform in 50-transforms/*; do
    . $transform
done

readonly transforms
