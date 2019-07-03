#!/usr/bin/env bash
ORG_REPOS=("jenkins-x/jx-ts-client")
JX=$(readlink -f ./build/linux/jx)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR
pushd ../../docs/apidocs/openapi-spec
SRCDIR=`pwd`
popd
popd
SRC="${SRCDIR}/openapiv2.yaml"
for org_repo in "${ORG_REPOS[@]}"; do
  OUTDIR="$($JX step git fork-and-clone -b --print-out-dir --dir=$TMPDIR https://github.com/$org_repo)"
  echo "Forked repo to $OUTDIR"
  pushd $OUTDIR
  echo "Running make all in $ORG_REPOS"
  make all
  echo "make all complete in $ORG_REPOS"
  git add -N .
  git diff --exit-code
  if [ $? -ne 0 ]; then
    set -x
    $JX create pullrequest -b --push=true --fork=true --body "upgrade $org_repo client to jx $VERSION" --title "upgrade to jx $VERSION" --label="updatebot"
    set +x
  else
    echo "No changes to generated code"
  fi
  popd
done

exit 0