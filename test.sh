#!/bin/bash

for i in {0..6}; do
  test_out=$(cat tests/test_in$i.txt | ruby ./simple_database.rb)
  correct_out=$(cat tests/correct_out$i.txt)

  if [ -z "$correct_out" ]; then
    echo "Test $i output NOT FOUND"
  else
    if [ "$test_out" = "$correct_out" ]; then
      echo "Test $i.........PASSED"
    else
      echo "Test $i.........FAILED"
      echo "Test Output:"
      echo $test_out
      echo "Correct Output:"
      echo $correct_out
    fi
  fi
done