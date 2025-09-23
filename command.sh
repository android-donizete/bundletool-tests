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
    IN=$1

    for REPO in $(ls $IN); do
        echo "Getting data for ${REPO}"
        
        APKS=($(find $IN/$REPO -name *.apk))
        echo "APKs found: ${#APKS[*]}"
        echo ${APKS[@]}

        echo

        BUNDLES=($(find $IN/$REPO -name *.aab | grep -v intermediary))
        echo "BUNDLES found: ${#BUNDLES[*]}"
        echo ${BUNDLES[@]}

        echo -------------------------------
        echo
    done
}

start() {
    populate data/repos.txt external
    build external
    measure external > log.txt
}

FN=$1
shift

$FN "$@"