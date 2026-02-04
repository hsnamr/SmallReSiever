# SmallReSiever – RSS reader for GNUStep
# Depends: SmallStep (../SmallStep), libxml2

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallReSiever

SmallReSiever_OBJC_FILES = \
	App/main.m \
	App/AppDelegate.m \
	Compat/SmallStepCompat.m \
	RSS/RSSParser.m \
	RSS/RSSFeed.m \
	RSS/RSSItem.m

SmallReSiever_RESOURCE_FILES =

# Include paths for subdirectories (App/, RSS/, Compat/)
ADDITIONAL_INCLUDE_DIRS += -I. -IApp -IRSS -ICompat
# SmallStep: use ../SmallStep when building without install (optional)
SMALLSTEP_DIR ?= ../SmallStep
ADDITIONAL_INCLUDE_DIRS += -I$(SMALLSTEP_DIR) -I$(SMALLSTEP_DIR)/SmallStep/Core -I$(SMALLSTEP_DIR)/SmallStep/Platform/Linux

# libxml2 (FOSS) for RSS/Atom parsing
ADDITIONAL_OBJCFLAGS += -std=gnu99 $(shell xml2-config --cflags 2>/dev/null || echo -I/usr/include/libxml2)
ADDITIONAL_LDFLAGS   += $(shell xml2-config --libs 2>/dev/null || echo -lxml2)

# SmallStep: link only if installed; otherwise SmallStepCompat.m provides the API
SmallReSiever_LIBRARIES_DEPEND_UPON = -lxml2
# Ensure libxml2 is on the link line (DSO missing from command line)
ADDITIONAL_GUI_LIBS = $(shell xml2-config --libs 2>/dev/null || echo -lxml2)

include $(GNUSTEP_MAKEFILES)/application.make
