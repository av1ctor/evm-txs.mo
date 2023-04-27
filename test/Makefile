DEP_DIR := ../src
SRC_DIR := ./src
OBJ_DIR := ./obj
DEP_FILES := $(wildcard $(DEP_DIR)/*.mo)
SRC_FILES := $(wildcard $(SRC_DIR)/*.mo)
WASM_FILES := $(patsubst $(SRC_DIR)/%.mo,$(OBJ_DIR)/%.wasm,$(SRC_FILES))

default: $(WASM_FILES)
	wasmtime $<

clean:
	rm -f $(WASM_FILES)

$(OBJ_DIR)/%.wasm: $(SRC_DIR)/%.mo $(DEP_FILES)
	$(shell vessel bin)/moc $(shell vessel sources) -wasi-system-api -o $@ $<

