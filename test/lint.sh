#!/bin/bash
# Lints every QML file against the Omarchy shell's own modules, then
# validates the manifest. qmllint resolves `import qs.Ui` only when an
# import path holds a `qs` directory, so this links one in a temp dir.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

qmllint=${QMLLINT:-/usr/lib/qt6/bin/qmllint}
shell=${OMARCHY_SHELL_DIR:-/usr/share/omarchy/shell}

imports=$(mktemp -d)
trap 'rm -rf "$imports"' EXIT
ln -s "$shell" "$imports/qs"

mapfile -t files < <(find "$ROOT" -name '*.qml' -not -path '*/.git/*' | sort)
"$qmllint" -I "$imports" --max-warnings 0 "${files[@]}" || fail "qmllint reports no warnings"
pass "qmllint reports no warnings"

# Call the validator script directly, so CI can point OMARCHY_PATH at a clone
# of Omarchy instead of needing it installed.
validate="${OMARCHY_PATH:-/usr/share/omarchy}/bin/omarchy-plugin-validate"
"$validate" "$ROOT" >/dev/null || fail "omarchy-plugin-validate accepts the manifest"
pass "omarchy-plugin-validate accepts the manifest"

# qmllint cannot see inside Omarchy's Style, Color and Border objects, so the
# QML files turn off its missing-property check. This puts typo detection
# back: every Style.*, Color.* and Border.* name used here must be declared
# in the Omarchy source.
# vibekit: a name passes if it is declared anywhere in the file, not only under the right parent. Parse the QtObject blocks if a misplaced name ever slips through.
commons="$shell/Commons"
unknown=""
while IFS= read -r ref; do
  singleton=${ref%%.*}
  for name in $(tr '.' ' ' <<< "${ref#*.}"); do
    grep -Eq "property [A-Za-z]+ $name\b|function $name\(" "$commons/$singleton.qml" || unknown+="$ref "
  done
done < <(grep -rhoE '\b(Style|Color|Border)\.[a-zA-Z]+(\.[a-zA-Z]+)?' --include=*.qml --exclude-dir=.git "$ROOT" | sort -u)
[[ -z $unknown ]] || fail "every Style, Color and Border name exists in Omarchy" "unknown: $unknown"
pass "every Style, Color and Border name exists in Omarchy"

# Qt's default AutoText renders anything that looks like HTML, so a string
# from muslimtify's output or config could load a remote image. Every Text
# must be plain, with textFormat on the line right after `Text {`.
rich=$(find "$ROOT" -name '*.qml' -not -path '*/.git/*' -exec awk '
  FNR == 1 { prev = "" }
  prev ~ /^[[:space:]]*Text \{[[:space:]]*$/ && $0 !~ /textFormat: Text\.PlainText/ { print FILENAME ":" FNR - 1 }
  { prev = $0 }' {} +)
[[ -z $rich ]] || fail "every Text renders plain text" "$rich"
pass "every Text renders plain text"
