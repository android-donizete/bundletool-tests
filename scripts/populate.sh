IN=$1
OUT=$2

while read REPO_URL; do
    pushd .
    cd $OUT
    git clone --recursive -j$(nproc) $REPO_URL
    popd
done < $IN