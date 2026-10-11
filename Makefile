TARGET := iphone:clang:latest:15.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = Spotify
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Prism

Prism_FILES = Tweak.x PrismSettings.m
Prism_CFLAGS = -fobjc-arc
Prism_FRAMEWORKS = UIKit
# Hooks via the ObjC runtime instead of CydiaSubstrate, so the dylib runs
# in a sideloaded IPA without bundling a hooking library.
Prism_LOGOS_DEFAULT_GENERATOR = internal

include $(THEOS_MAKE_PATH)/tweak.mk
