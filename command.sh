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
    JSON=$2

    for REPO in $(ls $IN); do
        echo "Getting data for ${REPO}"
        
        APKS=($(find $IN/$REPO -name *.apk))
        echo "APKs found: ${#APKS[*]}"
        echo ${APKS[@]}

        echo

        BUNDLES=($(find $IN/$REPO -name *.aab | grep -v intermediary))
        echo "BUNDLES found: ${#BUNDLES[*]}"
        echo ${BUNDLES[@]}
        echo

        for INDEX in ${!BUNDLES[@]}; do
            DIR=`mktemp --directory`

            BUNDLE=${BUNDLES[$INDEX]}
            APK=${APKS[$INDEX]}
            echo "Processing bundle: $BUNDLE"
            echo "Processing apk: $APK"

            java -jar $BT build-apks                \
                --bundle=$BUNDLE                    \
                --output="$DIR/output.apks"         \
                --device-spec=$JSON                 > /dev/null

            java -jar $BT extract-apks              \
                --apks="$DIR/output.apks"           \
                --output-dir=$DIR                   \
                --device-spec=$JSON                 > /dev/null

            echo "-- SUMMARY --"
                du -ch $APK
                du -ch $BUNDLE
            echo "--"
                du -ch $DIR/base-*
            echo "-- -- - -- --"

            echo
        done

        echo ----------------------------------------------
    done
}

start() {
    populate data/repos.txt external
    build external
    measure external data/medium_phone_36.json > log.txt
}

FN=$1
shift

$FN "$@"