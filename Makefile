ARCHS = arm64 arm64e
TARGET = iphone:clang:13.5:11.0

INSTALL_TARGET_PROCESSES = SpringBoard
#PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)-beta

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Greet

Greet_FILES = Tweak.x
Greet_CFLAGS = -fobjc-arc

ADDITIONAL_OBJCFLAGS += -fobjc-arc -fdiagnostics-absolute-paths

include $(THEOS_MAKE_PATH)/tweak.mk
