.PHONY: clean

FUNCTION_TARGET = function
PORT = 8080

# bin/server.dart is the generated target for lib/functions.dart
bin/server.dart:
	dart run build_runner build --delete-conflicting-outputs

test:
	clean build
	dart test

clean:
	dart run build_runner clean
	rm -rf bin/server.dart

nuke:
	dart pub cache clean
	clean

run:
	dart run bin/server.dart --port=$(PORT) --target=$(FUNCTION_TARGET)

gen_all:
	dart run build_runner build --delete-conflicting-outputs
	cd packages/jobstash_api && dart run build_runner build --delete-conflicting-outputs

get_all:
	dart pub get
	cd packages/database && dart pub get
	cd packages/jobstash_api && dart pub get

build_all:
	make get_all
	make gen_all
	dart compile exe bin/server.dart -o bin/server

update_webhook_url:
	@chmod +x ./scripts/update_webhook_url_script.sh
	./scripts/update_webhook_url_script.sh

update_menu:
	@chmod +x ./scripts/update_commands_script.sh
	@./scripts/update_commands_script.sh

docker_build:
	docker build -t image .

docker_run:
	docker run -p 8080:8080 image