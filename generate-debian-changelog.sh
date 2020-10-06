#!/usr/bin/env bash
set -e
# set -o pipefail  # exit if pipe command fails
[ -z "$DEBUG" ] || set -x

PACKAGE=$(awk '/Package:/{ print $2 }' debian/control)
VERSION=$(sed -ne 's/^ARG.* VERSION=\(.*\)/\1/p' docker/Dockerfile)
MYVERSION=$(sed -ne 's/^ARG.* MYVERSION=\(.*\)/\1/p' docker/Dockerfile)
[ -n "$MYVERSION" ] && VERSION="$VERSION-$MYVERSION"

LASTCOMMIT=$(git show-ref --tags -d | tail -n 1 | cut -d' ' -f 1)
DEBIAN_CHANGELOG="${PACKAGE} (${VERSION}) unstable; urgency=low\n"
if [ -z "$LASTCOMMIT" ]
then
    echo "* Changes since the beginning: "
    CHANGELOG=$(git log --pretty="- %h %aI %s (%an)")
    DEBIAN_CHANGELOG+="$(git log --pretty='  * %s')\n\n"
    DEBIAN_CHANGELOG+="$(git log --pretty=' -- %aN <%aE>  %aD%n%n' HEAD^..HEAD)"
else
    echo "* Changes since last version with commit $LASTCOMMIT: "
    CHANGELOG=$(git log --pretty="- %h %aI %s (%an)" "${LASTCOMMIT}..@")
    DEBIAN_CHANGELOG+="$(git log --pretty='  * %s' ${LASTCOMMIT}..@)\n\n"
    DEBIAN_CHANGELOG+="$(git log --pretty=' -- %aN <%aE>  %aD%n%n' ${LASTCOMMIT}^..${LASTCOMMIT} | head -n 1)"
fi
if [ -z "$CHANGELOG" ]
then
    echo "ERROR: no commits since last release with commit $LASTCOMMIT!. Please "
    echo "commit your changes to create and publish a new release!"
    exit 1
fi
echo "$CHANGELOG"

# Add changelog to debian/changelog
cp debian/changelog debian/changelog.tmp
echo -e "$DEBIAN_CHANGELOG" > debian/changelog
echo >> debian/changelog
cat debian/changelog.tmp >> debian/changelog
rm -f debian/changelog.tmp

