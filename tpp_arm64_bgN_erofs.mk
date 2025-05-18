$(call inherit-product, device/changanmoon/tpp/device.mk)

PRODUCT_NAME := tpp_arm64_bgN_erofs

GSI_FILE_SYSTEM_TYPE := erofs
BOARD_EROFS_COMPRESSOR := lz4hc,9
TARGET_PRODUCT_PROP += device/phh/treble/product.prop
