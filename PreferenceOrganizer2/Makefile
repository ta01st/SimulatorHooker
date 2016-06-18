TARGET = simulator:clang

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PreferenceOrganizer2
PreferenceOrganizer2_FILES = PreferenceOrganizer2.xm
PreferenceOrganizer2_USE_SUBSTRATE = 0
PreferenceOrganizer2_PRIVATE_FRAMEWORKS = Preferences
PreferenceOrganizer2_LIBRARIES = karenlocalizer karenprefs

SUBPROJECTS = POPreferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk