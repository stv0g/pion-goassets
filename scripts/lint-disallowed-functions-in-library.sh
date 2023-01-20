#!/usr/bin/env bash

set -e

# Disallow usages of functions that cause the program to exit in the library code
SCRIPT_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)
if [ -f ${SCRIPT_PATH}/.ci.conf ]; then
  . ${SCRIPT_PATH}/.ci.conf
fi

EXCLUDE_DIRECTORIES=${DISALLOWED_FUNCTIONS_EXCLUDED_DIRECTORIES:-"examples"}
DISALLOWED_FUNCTIONS=('os.Exit(' 'panic(' 'Fatal(' 'Fatalf(' 'Fatalln(' 'fmt.Println(' 'fmt.Printf(' 'log.Print(' 'log.Println(' 'log.Printf(' 'print(' 'println(')

FILES=$(
  find "${SCRIPT_PATH}/.." -name "*.go" \
    | grep -v -e '^.*_test.go$' \
    | while read FILE; do
      EXCLUDED=false
      for EXCLUDE_DIRECTORY in ${EXCLUDE_DIRECTORIES}; do
        if [[ ${FILE} == */${EXCLUDE_DIRECTORY}/* ]]; then
          EXCLUDED=true
          break
        fi
      done
      ${EXCLUDED} || echo "${FILE}"
    done
)

for DISALLOWED_FUNCTION in "${DISALLOWED_FUNCTIONS[@]}"; do
  if grep -e "\s${DISALLOWED_FUNCTION}" ${FILES} | grep -v -e 'nolint'; then
    echo "${DISALLOWED_FUNCTION} may only be used in example code"
    exit 1
  fi
done