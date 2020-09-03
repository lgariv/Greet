TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Terrible

Terrible_FILES = Tweak.x
Terrible_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
