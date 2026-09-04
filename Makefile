# mapscam — render parts and previews from the OpenSCAD sources.
#
#   make            # STLs for every variant + assembly previews
#   make check      # fail on any OpenSCAD warning / failed assert (CI gate)
#   make stl        # just the STLs
#   make renders    # just the PNG previews
#   make <variant>  # every part of one variant, e.g. `make generic_29mm_cs`
#   make clean
#
# Override the binary or add flags:  make OPENSCAD=openscad-nightly RENDER_FLAGS=--backend=manifold

OPENSCAD     ?= openscad
RENDER_FLAGS ?=
export OPENSCADPATH = $(CURDIR)/vendor

PARTS    := front body carrier rear base shims
VARIANTS := generic_29mm_c generic_29mm_c_ring generic_29mm_cs

STL_DIR := stl
PNG_DIR := renders

# stl/<variant>-<part>.stl
STLS := $(foreach v,$(VARIANTS),$(foreach p,$(PARTS),$(STL_DIR)/$(v)-$(p).stl))
PNGS := $(foreach v,$(VARIANTS),$(PNG_DIR)/$(v).png)

.PHONY: all stl renders check clean vendor $(VARIANTS)

all: stl renders

stl: $(STLS)

renders: $(PNGS)

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
		--camera=0,0,18,62,0,23,235 $<

# per-variant convenience target
define VARIANT_rule
$(1): $(foreach p,$(PARTS),$(STL_DIR)/$(1)-$(p).stl) $(PNG_DIR)/$(1).png
endef
$(foreach v,$(VARIANTS),$(eval $(call VARIANT_rule,$(v))))

# CI gate: render every variant/part to a throwaway echo file with --hardwarnings.
# Any warning or failed assert makes openscad exit non-zero and fails the build.
check:
	@set -e; \
	for v in $(VARIANTS); do \
	  for p in $(PARTS) assembly; do \
	    echo ">> $$v / $$p"; \
	    $(OPENSCAD) $(RENDER_FLAGS) --hardwarnings -o /tmp/mapscam-check.echo \
	      -D "part=\"$$p\"" scad/variants/$$v.scad; \
	  done; \
	done; \
	echo "OK — all variants render clean"

vendor:
	git submodule update --init --recursive

clean:
	rm -rf $(STL_DIR) $(PNG_DIR)/*.png
