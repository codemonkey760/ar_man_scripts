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
  echo ""
  echo "---UNIT-TEST-RESULTS---"
  echo -e "\e[1;49;32mPASSING: ${passing_count}\e[0m"
  echo -e "\e[1;49;31mFAILING: ${failing_count}\e[0m"
  echo -e "\e[1;49;34m  TOTAL: ${total_count}\e[0m"
  echo ""
}

setup_checksums_match_directory_contents () {
  tear_down

  mkdir "$test_data_dir"
  cd "${test_data_dir}" || exit 1
  echo "File1" > "${file_name_1}"
  echo "File2" > "${file_name_2}"
  echo "File3" > "${file_name_3}"
  md5sum -- * > "${check_sum_file}"
  cd ..
}

test_ar_returns_success_when_check_sums_match_directory_contents () {
  setup_checksums_match_directory_contents

  total_count=$((total_count + 1))
  cd ${test_data_dir} || exit 1
  script_output=$(../test_ar.sh)
  if [[ $? != 0 ]]; then
    failing_count=$((failing_count + 1))
    echo -e "\n\e[1;49;31mTEST FAILURE:\e[0m" 'test_ar_returns_success_when_check_sums_match_directory_contents'
    echo "script failed when test data was good"
  else
    passing_count=$((passing_count + 1))
    echo -n '.'
  fi
  cd ..

  tear_down
}

setup_checksum_file_missing () {
  tear_down

  mkdir "$test_data_dir"
  cd "${test_data_dir}" || exit 1
  echo "File1" > "${file_name_1}"
  echo "File2" > "${file_name_2}"
  echo "File3" > "${file_name_3}"
  cd ..
}

test_ar_returns_failure_when_check_sum_file_missing () {
  setup_checksum_file_missing

  total_count=$((total_count + 1))
  cd ${test_data_dir} || exit 1
  script_output=$(../test_ar.sh)
  if [[ $? = 0 ]]; then
    failing_count=$((failing_count + 1))
    echo -e "\n\e[1;49;31mTEST FAILURE:\e[0m" 'test_ar_returns_failure_when_check_sum_file_missing'
    echo "script exited successfully when checksum file was missing"
  else
    passing_count=$((passing_count + 1))
    echo -n '.'
  fi
  cd ..

  tear_down
}

setup_file_count_less_than_sum_count () {
  tear_down

  mkdir "$test_data_dir"
  cd "${test_data_dir}" || exit 1
  echo "File1" > "${file_name_1}"
  echo "File2" > "${file_name_2}"
  echo "File3" > "${file_name_3}"
  md5sum -- * > "${check_sum_file}"
  rm "${file_name_3}"
  cd ..
}

test_ar_returns_failure_when_file_count_less_than_sum_count () {
  setup_file_count_less_than_sum_count

  total_count=$((total_count + 1))
  cd ${test_data_dir} || exit 1
  script_output=$(../test_ar.sh)
  if [[ $? = 0 ]]; then
    failing_count=$((failing_count + 1))
    echo -e "\n\e[1;49;31mTEST FAILURE:\e[0m" 'test_ar_returns_failure_when_file_count_less_than_sum_count'
    echo "script exited successfully when file count was less then check sum count"
  else
    passing_count=$((passing_count + 1))
    echo -n '.'
  fi
  cd ..

  tear_down
}

setup_file_count_greater_than_sum_count () {
  tear_down

  mkdir "$test_data_dir"
  cd "${test_data_dir}" || exit 1
  echo "File1" > "${file_name_1}"
  echo "File2" > "${file_name_2}"
  md5sum -- * > "${check_sum_file}"
  echo "File3" > "${file_name_3}"
  cd ..
}

test_ar_returns_failure_when_file_count_greater_than_sum_count () {
  setup_file_count_greater_than_sum_count

  total_count=$((total_count + 1))
  cd ${test_data_dir} || exit 1
  script_output=$(../test_ar.sh)
  if [[ $? = 0 ]]; then
    failing_count=$((failing_count + 1))
    echo -e "\n\e[1;49;31mTEST FAILURE:\e[0m" 'test_ar_returns_failure_when_file_count_greater_than_sum_count'
    echo "script exited successfully when file count was greater then check sum count"
  else
    passing_count=$((passing_count + 1))
    echo -n '.'
  fi
  cd ..

  tear_down
}

setup_checksum_failure () {
  tear_down

  mkdir "$test_data_dir"
  cd "${test_data_dir}" || exit 1
  echo "File1" > "${file_name_1}"
  echo "File2" > "${file_name_2}"
  echo "File3" > "${file_name_3}"
  md5sum -- * > "${check_sum_file}"
  echo "Bad file contents" > ${file_name_3}
  cd ..
}

test_ar_returns_failure_when_check_sum_fails () {
  setup_checksum_failure

  total_count=$((total_count + 1))
  cd ${test_data_dir} || exit 1
  script_output=$(../test_ar.sh 2>&1)
  if [[ $? = 0 ]]; then
    failing_count=$((failing_count + 1))
    echo -e "\n\e[1;49;31mTEST FAILURE:\e[0m" 'test_ar_returns_failure_when_check_sum_fails'
    echo "script exited successfully when a file checksum does not match"
  else
    passing_count=$((passing_count + 1))
    echo -n '.'
  fi
  cd ..

  tear_down
}

echo "Starting unit test suite for 'test_ar.sh'"
test_ar_returns_success_when_check_sums_match_directory_contents
test_ar_returns_failure_when_check_sum_file_missing
test_ar_returns_failure_when_file_count_less_than_sum_count
test_ar_returns_failure_when_file_count_greater_than_sum_count
test_ar_returns_failure_when_check_sum_fails
print_report

if [[ "$failing_count" = 0 ]]; then
  exit 0
else
  exit 1
fi