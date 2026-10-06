#!/bin/sh
# Rebuilds the press kit zip from this folder and publishes the site.
# To add or replace the trailer, save it as trailer/trailer.mp4 and run this.
set -e
cd "$(dirname "$0")"

NAME="The-Halloway-Haunting-Press-Kit"
STAGE="$(mktemp -d)"
mkdir "$STAGE/$NAME"
cp -R screenshots logo key-art trailer README.txt "$STAGE/$NAME/"
cp index.html "$STAGE/$NAME/Press-Kit.html"
rm -f "$NAME.zip"
(cd "$STAGE" && zip -q -r -X "$OLDPWD/$NAME.zip" "$NAME" -x '*.DS_Store' '*/.keep')
rm -rf "$STAGE"

# GitHub rejects any single file over 100 MB.
for f in "$NAME.zip" trailer/trailer.mp4; do
	if [ -f "$f" ] && [ "$(stat -f%z "$f")" -gt 99000000 ]; then
		echo "$f is over 99 MB and GitHub will reject it. Use a smaller trailer file." >&2
		exit 1
	fi
done

git add -A
git commit -m "${1:-Update press kit}" || echo "Nothing new to commit."
if git remote get-url origin >/dev/null 2>&1; then
	git push
else
	echo "Zip rebuilt and committed. No GitHub remote is set, so nothing was pushed."
fi
