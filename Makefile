# mapscam — render parts and previews from the OpenSCAD sources.
#
#   make            # STLs for every component + preview PNGs
#   make gen        # regenerate scad/variants/*.scad + build wiring from components/*.toml
#   make gen-check  # fail if a committed generated file is stale (run `make gen`)
#   make check      # gen-check + every component/part with --hardwarnings + asserts
#   make stl        # just the STLs
#   make renders    # just the PNG previews
#   make <variant>  # every part of one component, e.g. `make generic_29mm_cs`
#   make clean
#
# A component is one TOML file under components/. `tools/gen.py` expands it; see
# docs/components.md. Do not hand-edit scad/variants/*.scad or components.json.
#
# Override the binary or add flags:  make OPENSCAD=openscad-nightly RENDER_FLAGS=--backend=manifold

OPENSCAD     ?= openscad
RENDER_FLAGS ?=
export OPENSCADPATH = $(CURDIR)/vendor

STL_DIR := stl
PNG_DIR := renders

# tools/gen.py expands components/*.toml into scad/variants/*.scad, components.json, the
# README tables, and build/components.mk (ALL_VARIANTS, VARIANTS_<type>, PARTS_<v>,
# CHECKPARTS_<v>, PREVIEW_CAM_<v>, TITLE_<v>, CHECK_JOBS). The stamp reruns it whenever a
# TOML or the generator changes, so `make` always renders current geometry.
COMPONENT_TOML := $(wildcard components/*/*.toml)

build/.gen-stamp: tools/gen.py $(COMPONENT_TOML)
	python3 tools/gen.py
	@touch $@
-include build/components.mk
build/components.mk: build/.gen-stamp ;

# stl/<variant>-<part>.stl  (variant names use '_', parts have no '-', so split on '-')
STLS := $(foreach v,$(ALL_VARIANTS),$(foreach p,$(PARTS_$(v)),$(STL_DIR)/$(v)-$(p).stl))
PNGS := $(foreach v,$(ALL_VARIANTS),$(PNG_DIR)/$(v).png)

.PHONY: all gen gen-check stl renders check clean vendor $(ALL_VARIANTS)

all: stl renders

gen:
	python3 tools/gen.py

gen-check:
	python3 tools/gen.py --check

stl: build/.gen-stamp $(STLS)

renders: build/.gen-stamp $(PNGS)

$(STL_DIR)/%.stl:
	@mkdir -p $(STL_DIR)
	$(eval V := $(word 1,$(subst -, ,$*)))
	$(eval P := $(word 2,$(subst -, ,$*)))
	$(OPENSCAD) $(RENDER_FLAGS) --hardwarnings -o $@ \
		-D 'part="$(P)"' scad/variants/$(V).scad

$(PNG_DIR)/%.png: scad/variants/%.scad
	@mkdir -p $(PNG_DIR)
	$(OPENSCAD) $(RENDER_FLAGS) -o $@ --imgsize=1000,750 \
		--colorscheme=Tomorrow --view=axes \
		--camera=$(PREVIEW_CAM_$*) $<

# per-component convenience target
define VARIANT_rule
$(1): build/.gen-stamp $(foreach p,$(PARTS_$(1)),$(STL_DIR)/$(1)-$(p).stl) $(PNG_DIR)/$(1).png
endef
$(foreach v,$(ALL_VARIANTS),$(eval $(call VARIANT_rule,$(v))))

# CI gate: generated files current, then render every component/part to a throwaway echo
# file with --hardwarnings. Any warning or failed assert makes openscad exit non-zero.
check: gen-check build/.gen-stamp
	@set -e; \
	for job in $(CHECK_JOBS); do \
	  v=$${job%/*}; p=$${job#*/}; \
	  echo ">> $$v / $$p"; \
	  $(OPENSCAD) $(RENDER_FLAGS) --hardwarnings -o /tmp/mapscam-check.echo \
	    -D "part=\"$$p\"" scad/variants/$$v.scad; \
	done; \
	echo "OK — all components render clean"

vendor:
	git submodule update --init --recursive

clean:
	rm -rf $(STL_DIR) $(PNG_DIR)/*.png build
