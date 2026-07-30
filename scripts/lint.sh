#!/usr/bin/env bash
#
# Repo-wide sanity checks. Run locally with ./scripts/lint.sh, or in CI via
# .github/workflows/ci.yml. Each check is optional-if-missing so the script is
# still useful on a machine that does not have every tool installed.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

FAILED=0

section() { printf '\n\033[1;33m==> %s\033[0m\n' "$1"; }
fail()    { printf '\033[0;31m[FAIL]\033[0m %s\n' "$1"; FAILED=1; }
pass()    { printf '\033[0;32m[ OK ]\033[0m %s\n' "$1"; }
skip()    { printf '\033[0;36m[SKIP]\033[0m %s\n' "$1"; }

# Files that are shell scripts but do not end in .sh.
EXTRA_SHELL_FILES=(
    "Bash/Storage/topdiskconsumer"
    "Bank-Systems/mifos-x/tomcat9"
)

shell_files() {
    find . -path ./.git -prune -o -name '*.sh' -print
    printf '%s\n' "${EXTRA_SHELL_FILES[@]}"
}

section "bash syntax"
while read -r f; do
    [ -f "$f" ] || continue
    if bash -n "$f" 2>/dev/null || sh -n "$f" 2>/dev/null; then
        pass "$f"
    else
        fail "$f"
        bash -n "$f"
    fi
done < <(shell_files)

section "shellcheck (errors only)"
if command -v shellcheck >/dev/null 2>&1; then
    while read -r f; do
        [ -f "$f" ] || continue
        if shellcheck -S error -f gcc "$f"; then
            pass "$f"
        else
            fail "$f"
        fi
    done < <(shell_files)
else
    skip "shellcheck not installed"
fi

section "YAML parses"
if python3 -c 'import yaml' 2>/dev/null; then
    if python3 - <<'PY'
import os, sys
import yaml

bad = 0
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in ('.git', 'node_modules', '.terraform')]
    for fn in files:
        if not fn.endswith(('.yml', '.yaml')):
            continue
        path = os.path.join(root, fn)
        try:
            list(yaml.safe_load_all(open(path)))
        except Exception as exc:
            bad += 1
            print(f'  {path}: {str(exc).splitlines()[0]}')
sys.exit(1 if bad else 0)
PY
    then
        pass "all YAML files parse"
    else
        fail "YAML parse errors"
    fi
else
    skip "PyYAML not installed"
fi

section "ansible playbook syntax"
if command -v ansible-playbook >/dev/null 2>&1; then
    # vars.yml / tasks/*.yml are not playbooks, so only check top-level plays.
    while read -r f; do
        grep -qE '^\s*-\s+(hosts|name):' "$f" || continue
        grep -q 'hosts:' "$f" || continue
        if ansible-playbook --syntax-check "$f" >/dev/null 2>&1; then
            pass "$f"
        else
            fail "$f"
            ansible-playbook --syntax-check "$f" 2>&1 | tail -5
        fi
    done < <(find Ansible -name '*.yml' -not -path '*/tasks/*')
else
    skip "ansible-playbook not installed"
fi

section "terraform fmt + validate"
if command -v terraform >/dev/null 2>&1; then
    while read -r d; do
        if ! terraform -chdir="$d" fmt -check -recursive >/dev/null 2>&1; then
            fail "$d (needs terraform fmt)"
            terraform -chdir="$d" fmt -check -diff
            continue
        fi
        terraform -chdir="$d" init -backend=false -input=false -no-color >/dev/null 2>&1
        if terraform -chdir="$d" validate -no-color >/dev/null 2>&1; then
            pass "$d"
        else
            fail "$d"
            terraform -chdir="$d" validate -no-color
        fi
    done < <(find . -path ./.git -prune -o -name '*.tf' -print | xargs -n1 dirname | sort -u)
else
    skip "terraform not installed"
fi

section "python compiles"
while read -r f; do
    if python3 -m py_compile "$f" 2>/dev/null; then
        pass "$f"
    else
        fail "$f"
        python3 -m py_compile "$f"
    fi
done < <(find . -path ./.git -prune -o -name '*.py' -print)

section "javascript parses"
if command -v node >/dev/null 2>&1; then
    while read -r f; do
        if node --check "$f" >/dev/null 2>&1; then
            pass "$f"
        else
            fail "$f"
            node --check "$f"
        fi
    done < <(find . -path ./.git -prune -o -path '*/node_modules' -prune -o -name '*.js' -print)
else
    skip "node not installed"
fi

section "JSON parses"
while read -r f; do
    if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
        pass "$f"
    else
        fail "$f"
    fi
done < <(find . -path ./.git -prune -o -path '*/node_modules' -prune -o -name '*.json' -print)

printf '\n'
if [ "$FAILED" -ne 0 ]; then
    printf '\033[0;31mSome checks failed.\033[0m\n'
    exit 1
fi
printf '\033[0;32mAll checks passed.\033[0m\n'
