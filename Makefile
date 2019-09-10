NODE_ENV ?= development
RUNTIME ?= Node

run: build run.$(RUNTIME)

clean:
	rm -rf \
		elm-stuff    		\
		node_modules/.cache	\
		worker/script.js 	\
		dist/main.js     	\
		public/client.js 	\
		build/Server.js  	\
		build/Client.js  	\
		src/Runtime

watch:
	@which fswatch || (echo "Missing `fswatch`"; exit 1)
	make build # we do want `build` to complete; not tucked inside `&` tripping fswatch
	make run &
	while fswatch --recursive --one-event .; do \
		echo CTRL-C again to quit...; \
		sleep 1; \
		make build stop; \
		make run & \
	done

stop:
	killall node

#
# Implement
#

run.Node: index.Node.js
	node index.Node.js

run.Cloudflare: index.Cloudflare.js package.json
	node prep.Cloudflare.js > index.js
ifeq ($(CLOUDFLARE_KV_NAMESPACE),)
	cat index.Cloudflare.js >> index.js
else
	sed 's/CLOUDFLARE_KV_NAMESPACE/$(CLOUDFLARE_KV_NAMESPACE)/g' < index.Cloudflare.js >> index.js
endif
ifeq ($(DEPLOY),1)
	wrangler publish
else
	wrangler preview --watch
endif

build: public/client.js build/Server.js
.PHONY: build

src/Runtime:
	rm -f src/Runtime ; ln -s ../runtimes/$(RUNTIME) src/Runtime
.PHONY: src/Runtime

build/Server.js: src/Runtime node_modules $(shell find src extensions -iname '*.elm')
	elm make --output build/Server.js src/Server.elm

build/Client.js: node_modules $(shell find src extensions -iname '*.elm')
	elm make --output build/Client.js src/Client.elm

public/client.js: node_modules build/Client.js
	cp build/Client.js public/client.js

node_modules:
	touch index.js
	npm init --yes
	which elm || npm add "elm@~0.19"
	npm add \
		"full-url" \
		"node-static" \
		"w3c-xmlhttprequest" \
		"webpack" \
		"webpack-cli" \
		"form-data" \
		"nodemailer"

index.Cloudflare.js: wrangler.toml

wrangler.toml:
	wrangler --help
	exit 1
