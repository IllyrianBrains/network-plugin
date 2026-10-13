PLUGIN_NAME    := discourse-professional-network
PLUGIN_VERSION := $(shell sed -n 's/^# version: //p' plugin.rb | head -n1)
THEME_NAME     := illyrian-brains-community-theme
THEME_VERSION  := $(shell sed -n 's/.*"theme_version": *"\([^"]*\)".*/\1/p' theme/about.json | head -n1)

BUILD := build
DIST  := dist

PLUGIN_ZIP := $(DIST)/$(PLUGIN_NAME)-$(PLUGIN_VERSION).zip
THEME_ZIP  := $(DIST)/$(THEME_NAME)-$(THEME_VERSION).zip

# What actually ships inside a Discourse container. dev/, spec/,
# astro-integration/ and theme/ are not part of the plugin itself -- see
# AGENTS.md "Repository layout".
PLUGIN_FILES := plugin.rb lib app assets config db public README.md

.PHONY: help package plugin theme lengths clean

help:
	@echo "make plugin   - build $(DIST)/$(PLUGIN_NAME)-<version>.zip"
	@echo "make theme    - build $(DIST)/$(THEME_NAME)-<version>.zip"
	@echo "make package  - build both of the above"
	@echo "make lengths  - run dev/check-file-lengths.sh"
	@echo "make clean    - remove $(BUILD)/ and $(DIST)/"

package: plugin theme

plugin:
	rm -rf "$(BUILD)/$(PLUGIN_NAME)"
	mkdir -p "$(BUILD)/$(PLUGIN_NAME)" "$(DIST)"
	cp -R $(PLUGIN_FILES) "$(BUILD)/$(PLUGIN_NAME)/"
	rm -f "$(PLUGIN_ZIP)"
	cd "$(BUILD)" && zip -rq "../$(PLUGIN_ZIP)" "$(PLUGIN_NAME)"
	@echo "Built $(PLUGIN_ZIP)"
	@echo "Extract into containers/plugins/ so the plugin lives at"
	@echo "containers/plugins/$(PLUGIN_NAME)/, then ./launcher rebuild app"

theme:
	mkdir -p "$(DIST)"
	rm -f "$(THEME_ZIP)"
	cd theme && zip -rq "../$(THEME_ZIP)" .
	@echo "Built $(THEME_ZIP)"
	@echo "Install via Admin > Customize > Themes > Install > From a file"

lengths:
	./dev/check-file-lengths.sh

clean:
	rm -rf "$(BUILD)" "$(DIST)"
