#!/bin/sh

SEMVER=$1

[ -z "$SEMVER" ] && echo "No semver specified." && exit 7

[ -x $(which curl) ] || (echo "No curl available!" && exit 4)
[ -x $(which unzip) ] || (echo "No unzip available!" && exit 5)

echo "Loading Angular Material Builds for '$SEMVER'..."

git show-ref origin/HEAD >/dev/null || (echo "Remote origin unavailable!" && exit 2)
git show-ref origin/$SEMVER >/dev/null && echo "Build '$SEMVER' already created!" && exit 3

git checkout -B $SEMVER base

echo "Pulling 'bower-material-$SEMVER.zip'..."
curl -L https://github.com/angular/bower-material/archive/$SEMVER.zip > bower-material.zip
echo "Unzipping 'bower-material-$SEMVER.zip'..."
unzip angular.zip || (echo "Unzip failed!" && exit 6)
mv bower-material-$SEMVER/* .
rm -rf bower-material.zip bower-material-$SEMVER/

echo "Adding 'package.json'..."
cat >| package.json <<EOF
{
    "name": "angular-material-builds",
    "version": "$SEMVER",
    "description": "A build of Angular Material version $SEMVER in a format that's friendly for 'npm install angular-material@$SEMVER'"
}
EOF

git add .
git commit -m "Release $SEMVER"
git push origin $SEMVER
npm publish
git checkout master
