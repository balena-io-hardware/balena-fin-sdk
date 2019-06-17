HEADERS = \
	include/fin/fin.h \
	include/fin/client.h

RUST_SOURCES = \
	fin-cli/src/command.rs \
        fin-cli/src/main.rs \
	fin-lib/src/ethtool.rs \
	fin-lib/src/i2c.rs \
	fin-lib/src/lib.rs \
	fin-lib/src/eeprom.rs \
	fin-sdk/src/lib.rs

all: Fin-0.1.gir Fin-0.1.typelib

target/debug/libfin.so: $(RUST_SOURCES)
	cargo build

Fin-0.1.gir: target/debug/libfin.so $(HEADERS)
	g-ir-scanner -v --warn-all --warn-error \
		--namespace Fin --nsversion=0.1 \
		-Iinclude --c-include "fin/fin.h" \
		--library=fin --library-path=$(PWD)/target/debug \
		--include=GObject-2.0 -pkg gobject-2.0 \
		--output $@ \
		$(HEADERS)

Fin-0.1.typelib: Fin-0.1.gir
	g-ir-compiler --includedir=include $< -o $@

clean:
	rm -f Fin-0.1.typelib
	rm -f Fin-0.1.gir
	cargo clean

py: Fin-0.1.typelib
	GI_TYPELIB_PATH=$(PWD) LD_LIBRARY_PATH=$(PWD)/target/debug python3 revision.py

js: Fin-0.1.typelib
	GI_TYPELIB_PATH=$(PWD) LD_LIBRARY_PATH=$(PWD)/target/debug node revision.js

