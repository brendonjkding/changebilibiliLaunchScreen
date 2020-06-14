TARGET = iphone:clang:11.2:9.0
include $(THEOS)/makefiles/common.mk
ARCHS = arm64 

APPLICATION_NAME = changebilibiliLaunchScreen

changebilibiliLaunchScreen_FILES = main.m BBLSAppDelegate.m BBLSRootViewController.m LaunchScreenModel.m LaunchScreenDetailViewController.m BBLSSettingsViewController.m BDInfoListController.m
changebilibiliLaunchScreen_FRAMEWORKS = UIKit CoreGraphics
changebilibiliLaunchScreen_PRIVATE_FRAMEWORKS = Preferences
changebilibiliLaunchScreen_CFLAGS = -fobjc-arc -Wno-error=unused-variable

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall changebilibiliLaunchScreen" || true
	install.exec "killall bili-universal" || true
SUBPROJECTS += tweak
include $(THEOS_MAKE_PATH)/aggregate.mk
