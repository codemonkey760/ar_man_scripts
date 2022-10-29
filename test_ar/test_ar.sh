#! /usr/bin/env bash

sum_file="${PWD##*/}.md5sum"

file_count () {
    find . -type f -not -name "${sum_file}" | wc -l
}

sum_count () {
  wc -l "$sum_file" | cut -d ' ' -f1
}

if [ ! -f "$sum_file" ]; then
  echo "Sum file: '${sum_file}' is missing ... aborting"
  exit 1
fi

if (( "$(file_count)" != "$(sum_count)" )); then
  echo "Sum file: '${sum_file} does not contain the correct number of check sums ... aborting"
  exit 1
fi

echo "Script reached end"
