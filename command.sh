populate() {
    IN=$1
    OUT=$2

    while read REPO_URL; do
        pushd $OUT
        git clone --recursive -j$(nproc) $REPO_URL
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

    echo
}

measure() {
    BT=`ls bundletool*.jar`
    IN=$1
    DEVICES=$2

    for REPO in $(ls $IN); do
        echo "Getting data for ${REPO}"
        echo
        
        APKS=($(find $IN/$REPO -name *.apk))
        echo "APKs found: ${#APKS[*]}"
        echo ${APKS[@]}
        echo

        BUNDLES=($(find $IN/$REPO -name *.aab | grep -v intermediary))
        echo "BUNDLES found: ${#BUNDLES[*]}"
        echo ${BUNDLES[@]}
        echo

        for DEVICE in $(ls $DEVICES); do
            JSON="${DEVICES}/${DEVICE}"
            echo "Processing data for device ${DEVICE}"

            for BINDEX in ${!BUNDLES[@]}; do
                DIR=`mktemp --directory`
                BUNDLE=${BUNDLES[$BINDEX]}
                APK=${APKS[$BINDEX]}

                echo "Processing bundle: $BUNDLE"
                echo "Processing apk: $APK"
                echo

                java -jar $BT build-apks                \
                    --bundle=$BUNDLE                    \
                    --mode=default                      \
                    --output="$DIR/output.apks"         > /dev/null

                java -jar $BT extract-apks              \
                    --apks="$DIR/output.apks"           \
                    --output-dir=$DIR                   \
                    --device-spec=$JSON                 > /dev/null

                echo "-- SUMMARY --"
                du -ch $APK
                du -ch $BUNDLE
                echo "--"
                du -ch $DIR/*.apk
                echo "-- -- - -- --"

                echo
            done
        done
    done
}

start() {
    populate repos.txt repositories
    build repositories
    measure repositories devices
}

FN=$1
shift

$FN "$@" > log.txt