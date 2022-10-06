include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = autolayout
BUNDLE_NAME = autolayouttests

autolayouttests_HEADER_FILES = \
	CustomBaselineView.h \
	CustomInstrinctContentSizeView.h
autolayouttests_OBJC_FILES = GSAutoLayoutEngineTestCase.m
ADDITIONAL_TOOL_LIBS = -lxctest -lautolayout
ADDITIONAL_LIB_DIRS = -L/home/benjamin/GSAutoLayoutEngine/GSAutoLayoutEngine/obj
autolayouttests_INCLUDE_DIRS = -I./../../tools-xctest -I./../GSAutoLayoutEngine

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble