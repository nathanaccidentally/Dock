include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dock
Dock_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += dockprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
