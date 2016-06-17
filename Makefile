DEBUG = 0

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = SimulatorHooker
SUBPROJECTS = Injector
SUBPROJECTS += Camera_test
#SUBPROJECTS += PreferenceOrganizer2
SUBPROJECTS += SBShortcutMenuSimulator
SUBPROJECTS += InternalPhotos
SUBPROJECTS += FullSafari

include $(THEOS_MAKE_PATH)/aggregate.mk
