include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DockPrefs
DockPrefs_FILES = DOCKRootListController.m
DockPrefs_INSTALL_PATH = /Library/PreferenceBundles
DockPrefs_FRAMEWORKS = UIKit
DockPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DockPrefs.plist$(ECHO_END)
