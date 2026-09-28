#!/bin/bash
# Shared helpers for the shell tests. Source it from a test, do not run it.

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export ROOT

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  if [[ -n ${2:-} ]]; then printf '%s\n' "$2" >&2; fi
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null || fail "required command is available: $1"
}

# Runs the JavaScript on stdin under node, after a small assertion prelude.
run_node_test() {
  require_command node

  {
    cat <<'JS_PRELUDE'
const path = require('path')
const root = process.env.ROOT

function fail(description, detail) {
  if (detail) console.error(detail)
  console.error(`not ok - ${description}`)
  process.exit(1)
}

function pass(description) {
  console.log(`ok - ${description}`)
}

function assert(condition, description, detail) {
  if (!condition) fail(description, detail)
  pass(description)
}

function assertEqual(actual, expected, description) {
  assert(actual === expected, description, `expected: ${expected}\nactual:   ${actual}`)
}

function assertDeepEqual(actual, expected, description) {
  const a = JSON.stringify(actual)
  const e = JSON.stringify(expected)
  assert(a === e, description, `expected: ${e}\nactual:   ${a}`)
}

function requireFromRoot(relativePath) {
  return require(path.join(root, relativePath))
}

JS_PRELUDE
    cat
  } | node
}
