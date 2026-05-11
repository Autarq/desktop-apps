#!/usr/bin/env bash
set -euo pipefail

DRAWIO_PLUGIN_GUID="{DB38923B-A8C0-4DE9-8AEE-A61BB5C901A5}"
DRAWIO_PLUGIN_REV="${DRAWIO_PLUGIN_REV:-21786582fe638a434f31253f0ac366ef97f9a381}"
DRAWIO_PLUGIN_SHA256="${DRAWIO_PLUGIN_SHA256:-7e47536ec11e11503506dec12ca95bb246376049b9696283b3c7a945bedd5359}"
DRAWIO_PLUGIN_URL="${DRAWIO_PLUGIN_URL:-https://raw.githubusercontent.com/ONLYOFFICE/onlyoffice.github.io/${DRAWIO_PLUGIN_REV}/sdkjs-plugins/content/drawio/deploy/drawio.plugin}"
DRAWIO_PLUGIN_CACHE_DIR="${DRAWIO_PLUGIN_CACHE_DIR:-${HOME}/Library/Caches/autarq-office/drawio}"

usage() {
  cat <<EOF
Usage:
  macos/scripts/install-drawio-plugin.sh /path/to/sdkjs-plugins

Environment:
  DRAWIO_PLUGIN_ARCHIVE=/path/to/drawio.plugin
  DRAWIO_PLUGIN_CACHE_DIR=/path/to/cache
  DRAWIO_PLUGIN_REV=${DRAWIO_PLUGIN_REV}
  DRAWIO_PLUGIN_URL=${DRAWIO_PLUGIN_URL}
  DRAWIO_PLUGIN_SHA256=${DRAWIO_PLUGIN_SHA256}
EOF
}

info() {
  printf '[drawio] %s\n' "$*"
}

fail() {
  printf '[drawio] error: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

target_plugins_dir="${1:-}"
if [[ -z "${target_plugins_dir}" || "${target_plugins_dir}" == "-h" || "${target_plugins_dir}" == "--help" ]]; then
  usage
  exit 0
fi

need_cmd curl
need_cmd shasum
need_cmd unzip
need_cmd ditto

mkdir -p "${target_plugins_dir}" "${DRAWIO_PLUGIN_CACHE_DIR}"

archive="${DRAWIO_PLUGIN_ARCHIVE:-${DRAWIO_PLUGIN_CACHE_DIR}/drawio-${DRAWIO_PLUGIN_REV}.plugin}"
if [[ ! -f "${archive}" ]]; then
  tmp_archive="${archive}.tmp"
  rm -f "${tmp_archive}"
  info "downloading draw.io plugin ${DRAWIO_PLUGIN_REV}"
  curl --fail --location --retry 3 --output "${tmp_archive}" "${DRAWIO_PLUGIN_URL}"
  mv "${tmp_archive}" "${archive}"
fi

actual_sha="$(shasum -a 256 "${archive}" | awk '{ print $1 }')"
if [[ "${actual_sha}" != "${DRAWIO_PLUGIN_SHA256}" ]]; then
  fail "checksum mismatch for ${archive}: expected ${DRAWIO_PLUGIN_SHA256}, got ${actual_sha}"
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/autarq-drawio.XXXXXX")"
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

mkdir -p "${tmp_dir}/plugin"
unzip -q "${archive}" -d "${tmp_dir}/plugin"

if [[ ! -f "${tmp_dir}/plugin/config.json" ]]; then
  fail "draw.io plugin archive does not contain config.json"
fi

plugin_dir="${target_plugins_dir}/${DRAWIO_PLUGIN_GUID}"
rm -rf "${plugin_dir}"
mkdir -p "${plugin_dir}"
ditto "${tmp_dir}/plugin/" "${plugin_dir}"

info "installed ${plugin_dir}"
