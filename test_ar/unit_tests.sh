#! /usr/bin/env bash

test_data_dir="test_data"
file_name_1="file1.txt"
file_name_2="file2.txt"
file_name_3="file3.txt"
check_sum_file="${test_data_dir}.md5sum"
total_count=0
passing_count=0
failing_count=0

tear_down () {
  if [[ -d "$test_data_dir" ]]; then
    rm -rf "$test_data_dir"
  fi
}

print_report () {
  echo "---UNIT-TEST-RESULTS---"
  echo -e "\e[1;49;32mPASSING: ${passing_count}\e[0m"
  echo -e "\e[1;49;31mFAILING: ${failing_count}\e[0m"
  echo -e "\e[1;49;34m  TOTAL: ${total_count}\e[0m"
  echo ""
}

setup_checksums_match_directory_contents () {
  tear_down

  mkdir "$test_data_dir"
  echo "File1" > "${test_data_dir}/${file_name_1}"
  echo "File2" > "${test_data_dir}/${file_name_2}"
  echo "File3" > "${test_data_dir}/${file_name_3}"
  cd "${test_data_dir}" || exit 1
  md5sum -- * > "${check_sum_file}"
  if ! md5sum --status -c "${check_sum_file}"; then
    echo "Check sum of test data failed ... something's up"
    echo "Cannot get usable unit test result if check sum fails here"
    exit 1
  fi
  cd ..
}

test_ar_returns_success_when_check_sums_match_directory_contents () {
  setup_checksums_match_directory_contents

  total_count=$((total_count + 1))
  cd ${test_data_dir} || exit 1
  echo ""
  if ! ../test_ar.sh; then
    failing_count=$((failing_count + 1))
    echo -e "\e[1;49;31mTEST FAILURE:\e[0m" 'test_ar_returns_success_when_check_sums_match_directory_contents'
    echo "script failed when test data was good"
  else
    passing_count=$((passing_count + 1))
    echo -e "\e[1;49;32mTEST PASSED:\e[0m" 'test_ar_returns_success_when_check_sums_match_directory_contents'
  fi
  echo ""
  cd ..

  tear_down
}

test_ar_returns_success_when_check_sums_match_directory_contents
print_report