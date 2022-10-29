#! /usr/bin/env bash
sum_file="${PWD##*/}.md5sum"

file_count=$(find . -type f -not -name "${sum_file}" | wc -l)
echo "Found ${file_count} files in directory"

if [ ! -f "$sum_file" ]; then
  echo "Sum file: '${sum_file}' is missing ... aborting"
  exit 1
fi
echo "Using ${sum_file} as sum file"

sum_count=$(wc -l "$sum_file" | cut -d ' ' -f1)
echo "${sum_file} has ${sum_count} check sums"

if (( "${file_count}" != "${sum_count}" )); then
  echo "Sum file: '${sum_file} does not contain the correct number of check sums ... aborting"
  exit 1
fi

echo "Computing checksums ... please wait"
if ! md5sum --quiet -c "${sum_file}"; then
  echo "Computing checksums failed ... aborting"
  exit 1
fi

echo "Directory has no changes"
