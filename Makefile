export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5:11.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Terrible

Terrible_FILES = Tweak.x
Terrible_CFLAGS = -fobjc-arc

ADDITIONAL_OBJCFLAGS += -fobjc-arc -fdiagnostics-absolute-paths

include $(THEOS_MAKE_PATH)/tweak.mk
