ROOT_DIR="$(pwd)"
cd $ROOT_DIR

ANDROID_SOURCE_VERSION="15.0"
ANDROID_QPR="QPR2"
ANDROID_BUILD_VERSION="bp1a"

echo "Building The Pixel Project version $ANDROID_SOURCE_VERSION ($ANDROID_BUILD_VERSION)"
echo "---------------------------"

source build/envsetup.sh
ccache -M 50G -F 0

START_TIME=$(date +%s)
RELEASE_DATE=$(date +%Y%m%d)
RELEASE_DATE_FMT=$(date +%Y-%m-%d)

cd ~/tpp

compress() {
    echo "----- Compressing the variant -----"
    cd $ROOT_DIR/out/target/product/tdgsi_arm64_ab
    xz -9 -T0 -v -z system.img
    mv system.img.xz $HOME/Downloads/tpp_arm64_$variant-$ANDROID_SOURCE_VERSION-unofficial-$RELEASE_DATE.img.xz
}

build() {
    cd $ROOT_DIR
    lunch tpp_arm64_$variant-$ANDROID_BUILD_VERSION-userdebug
    make systemimage -j$(nproc --all) || exit
    compress
}

echo "----- Building EXT4 variant -----"
variant="bgN_ext4"
build

echo "----- Building EROFS variant -----"
variant="bgN_erofs"
build

END_TIME=$(date +%s)
DELTA_TIME=$((END_TIME - START_TIME))
DELTA_MINUTES=$((DELTA_TIME / 60))

echo "----- Done! -----"
echo "Start time: $START_TIME"
echo "End time: $END_TIME"
echo "Delta time (minutes): $DELTA_MINUTES"
ext4_size=$(wc -c < $HOME/Downloads/tpp_arm64_bgN_ext4-$ANDROID_SOURCE_VERSION-unofficial-$RELEASE_DATE.img.xz)
echo "EXT4 size: $ext4_size"
erofs_size=$(wc -c < $HOME/Downloads/tpp_arm64_bgN_erofs-$ANDROID_SOURCE_VERSION-unofficial-$RELEASE_DATE.img.xz)
echo "EROFS size: $erofs_size"

echo "----- OTA -----"
echo "{
    \"version\": \"$RELEASE_DATE_FMT (The Pixel Project - Android $ANDROID_QPR)\",
    \"date\": \"$START_TIME\",
    \"variants\": [
        {
            \"name\": \"tpp_arm64_bgN_erofs\",
            \"size\": \"$erofs_size\",
            \"url\": \"https://github.com/changanmoon/treble_tpp/releases/download/$RELEASE_DATE/tpp_arm64_bgN_erofs-$ANDROID_SOURCE_VERSION-unofficial-$RELEASE_DATE.img.xz\"
        },
        {
            \"name\": \"tpp_arm64_bgN_ext4\",
            \"size\": \"$ext4_size\",
            \"url\": \"https://github.com/changanmoon/treble_tpp/releases/download/$RELEASE_DATE/tpp_arm64_bgN_ext4-$ANDROID_SOURCE_VERSION-unofficial-$RELEASE_DATE.img.xz\"
        }
    ]
}"
