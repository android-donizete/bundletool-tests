populate() {
    IN=$1
    OUT=$2

    while read REPO_URL; do
        pushd $OUT
        git clone --recursive -j$(nproc) $REPO_URL &
        popd
    done < $IN
}

measure() {
    BT=`ls bundletool*.jar`

    echo $BT
}

start() {
    populate repos.txt external
}

FN=$1
shift

$FN "$@"