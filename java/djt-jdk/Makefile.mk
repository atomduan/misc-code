CXX      := -c++
CXXFLAGS := -pedantic-errors -Wall -Wextra -Werror
LDFLAGS  := -L/usr/lib -lstdc++ -lm
BUILD    := ./build
OBJ_DIR  := $(BUILD)/objects
DST_DIR  := $(BUILD)/dist
TARGET   :=	target.bin 
INCLUDE  := -Iinclude/							\
			-Iinclude/linux/					\
			-Isrc/
SRC      :=	$(wildcard src/memory/*.cc)			\
			$(wildcard src/runtime/*.cc)		\
			$(wildcard src/services/*.cc)		\
			$(wildcard src/utilities/*.cc)		\
			$(wildcard src/*.cc)

OBJECTS := $(SRC:%.cpp=$(OBJ_DIR)/%.o)

all: build $(DST_DIR)/$(TARGET)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(INCLUDE) -o $@ -c $<

$(DST_DIR)/$(TARGET): $(OBJECTS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) -o $(DST_DIR)/$(TARGET) $(OBJECTS)

.PHONY: all build clean debug release

build:
	@mkdir -p $(DST_DIR)		
	@mkdir -p $(OBJ_DIR)

debug: CXXFLAGS += -DDEBUG -g
debug: all

release: CXXFLAGS += -O2
release: all

clean:
	@rm -rvf $(BUILD)/objects/*
	@rm -rvf $(BUILD)/dist/*
