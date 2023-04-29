DEP_DIR := ../src
SRC_DIR := ./wasi
OBJ_DIR := ./wasi/obj
DEP_FILES := $(wildcard $(DEP_DIR)/*.mo) $(wildcard $(DEP_DIR)/transactions/*.mo) $(wildcard $(DEP_DIR)/utils/*.mo)
SRC_FILES := $(wildcard $(SRC_DIR)/*.mo)
WASM_FILES := $(patsubst $(SRC_DIR)/%.mo,$(OBJ_DIR)/%.wasm,$(SRC_FILES))

default: $(WASM_FILES)
	for i in $(WASM_FILES); do wasmtime "$$i"; done
	find interpreted -type f -name '*.test.mo' -print0 | xargs -0 $(shell vessel bin)/moc $(shell vessel sources) -r

clean:
	rm -f $(WASM_FILES)

$(OBJ_DIR)/%.wasm: $(SRC_DIR)/%.mo $(DEP_FILES)
	$(shell vessel bin)/moc $(shell vessel sources) -wasi-system-api -o $@ $<

