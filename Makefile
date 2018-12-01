export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2223

export TARGET=iphone:11.2:10.0
export FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk

ARCHS = armv7 arm64
TWEAK_NAME = FlexInjected
FlexInjected_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
