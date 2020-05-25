#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

HOSTNAME="$(hostname)"
BACKUP_USER="cscutcher"
ETC_BACKUP_ROOT="/home/${BACKUP_USER}/syncthing/etc-backup"
BACKUP_FILE="${ETC_BACKUP_ROOT}/${HOSTNAME}.bundle.asc"
BUNDLE_OUTPUT="$(mktemp)"
TMP_OUTPUT="$(mktemp)"



if [ ! -d "$ETC_BACKUP_ROOT" ]; then
    echo "BACKUP FOLDER '$ETC_BACKUP_ROOT' DOESN'T EXIST!"
    exit 1
fi

pushd /etc
git bundle create "$BUNDLE_OUTPUT" --all
popd

rm "$TMP_OUTPUT"
gpg --encrypt \
    --batch \
    --output="$TMP_OUTPUT" \
    --auto-key-retrieve \
    --recipient 2351AD620C3D83F2A5A562E17B8C6179AA1CD475 \
    --recipient 855A5FB329E1AF09! \
    --recipient 0AD8CAA3C0A22D938C8324260642A14A3E26BC70 \
    "$BUNDLE_OUTPUT"

rm "$BUNDLE_OUTPUT"
mv -f "$TMP_OUTPUT" "$BACKUP_FILE"
chown -R "$BACKUP_USER" "$BACKUP_FILE"
