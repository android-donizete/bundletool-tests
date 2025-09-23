populate() {
    IN=$1
    OUT=$2

    while read REPO_URL; do
        pushd $OUT
        (git clone --recursive -j$(nproc) $REPO_URL &)
        popd
    done < $IN
}

build() {
    IN=$1
    for REPO in $(ls $IN); do
        pushd $IN/$REPO
        ./gradlew assembleDebug
        ./gradlew bundleDebug
        popd
    done
}

measure() {
    BT=`ls bundletool*.jar`

    echo $BT
}

start() {
    populate data/repos.txt external
    build external
    measure external
}

FN=$1
shift

$FN "$@"