#!/usr/bin/env bash
set -e

VERSION=$(grep "^version=" module/module.prop | cut -d'=' -f2 | tr -d 'v')
OUTPUT_DIR="out"
ZIP_NAME="premium-oos-v${VERSION}.zip"

mkdir -p "${OUTPUT_DIR}"
rm -f "${OUTPUT_DIR}/${ZIP_NAME}"

cd module
zip -r9 "../${OUTPUT_DIR}/${ZIP_NAME}" ./* -x "*.DS_Store"
cd ..

echo "Module build complete: ${OUTPUT_DIR}/${ZIP_NAME}"
