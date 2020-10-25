TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

DEBUG = 0

FINALPACKAGE = 1


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FloatingDarkMode

FloatingDarkMode_FILES = Tweak.xm UIView+draggable.m
FloatingDarkMode_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
