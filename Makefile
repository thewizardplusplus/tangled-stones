# The MIT License (MIT), Copyright (C) 2021 FalcoSuessgott
# The MIT License (MIT), Copyright (C) 2022 Dave Kerr
.PHONY: help
help: # Show available commands
	@grep -E '^[A-Za-z0-9 -]+:.*#' $(MAKEFILE_LIST) | while read -r line; do \
		printf "\033[1;32m$$(echo $$line | cut -f 1 -d':')\033[0m:"; \
		printf "$$(echo $$line | cut -f 2- -d'#')\n"; \
	done

.PHONY: lint
lint: # Lint the code
	@luacheck .

.PHONY: test
test: # Run the tests
	@LUA_PATH= LUA_CPATH= lua test.lua --verbose

.PHONY: run
run: # Run the game
	@LUA_PATH= LUA_CPATH= love .

.PHONY: run-web
run-web: # Build and run the web version
	@$(MAKE) --no-print-directory build target=lovejs
	@readonly web_dir="$$(mktemp -d)"; \
		readonly game_name="$$(grep -w name ./makelove.toml | cut -f 2 -d'"')"; \
		unzip -q "./builds/lovejs/$$game_name-lovejs.zip" -d "$$web_dir"; \
		python3 -m http.server --directory "$$web_dir/$$game_name" 8080

.PHONY: doc
doc: # Build the documentation
	@ldoc .

.PHONY: build
build: # Build the game; parameters: target
	@makelove $(target)
