SDK := $(shell cat "$(HOME)/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")
KEY := $(HOME)/.garmin/developer_key.der
DEVICE := fr165
PRG := bin/BeerCounter.prg

.PHONY: build test sideload

build:
	"$(SDK)bin/monkeyc" -f monkey.jungle -d $(DEVICE) -y "$(KEY)" -o $(PRG) -l 2

# Needs the simulator running: open it with "$(SDK)bin/connectiq"
test:
	"$(SDK)bin/monkeyc" -f monkey.jungle -d $(DEVICE) -y "$(KEY)" -o bin/BeerCounterTest.prg -l 2 -t
	# monkeydo exits 1 even when every test passes, so read the result line instead.
	"$(SDK)bin/monkeydo" bin/BeerCounterTest.prg $(DEVICE) -t | tee /dev/stderr | grep -q '^PASSED'

bin/mtp-put: tools/mtp-put.c
	mkdir -p bin
	cc $< -o $@ $$(pkg-config --cflags --libs libmtp)

sideload: build bin/mtp-put
	bin/mtp-put $(PRG) BeerCounter.prg
