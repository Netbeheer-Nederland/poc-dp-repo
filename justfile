set dotenv-required
set dotenv-load
set shell := ["bash", "-uc"]
set windows-shell := ["bash", "-uc"]

_default:
    @just --list --justfile {{justfile()}}

# Generate everything
[group("generators")]
gen-all: clean gen-json-schema gen-ld gen-docs show-output

# Generate JSON Schema
[group("generators")]
gen-json-schema:
    @echo "Generating JSON Schema…"
    @echo -en "\t"
    mkdir -p "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"/json_schema
    @echo -en "\t"
    linkml generate json-schema \
        --not-closed \
        "$DP_CAPACITY_HEATMAP_LOGICAL_SCHEMA" \
        > "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR/json_schema/$DP_CAPACITY_HEATMAP_PROJECT_FILENAME.json_schema.json"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Generated JSON Schema at: $DP_CAPACITY_HEATMAP_SCHEMAS_DIR/json_schema/$DP_CAPACITY_HEATMAP_PROJECT_FILENAME.json_schema.json"
    @echo

# Generate MkDocs files
[group("generators")]
_gen-mkdocs:
    @echo "Generating MkDocs files…"
    @echo -en "\t"
    mkdir -p "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"/mkdocs
    @echo -en "\t"
    linkml generate doc \
       --directory "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR/mkdocs" \
        --hierarchical-class-view \
        --subfolder-type-separation \
        --use-class-uris \
        --use-slot-uris \
        --no-include-top-level-diagram \
        --format markdown \
        --diagram-type er_diagram \
        "$DP_CAPACITY_HEATMAP_LOGICAL_SCHEMA"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Generated MkDocs files at: $DP_CAPACITY_HEATMAP_SCHEMAS_DIR/mkdocs/"
    @echo

# Generate the documentation site
[group("documentation")]
gen-docs: _gen-mkdocs
    @echo "Generating MkDocs site…"
    @echo -en "\t"
    mkdocs build --config-file "${DP_CAPACITY_HEATMAP_MKDOCS_CONFIG}"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Generated documentation site at: $DP_CAPACITY_HEATMAP_DOCS_DIR"
    @echo

# Serve the documentation site locally (with hot reload)
[group("documentation")]
serve-docs:
    mkdocs serve --config-file "${DP_CAPACITY_HEATMAP_MKDOCS_CONFIG}"

# Generate SHACL
[group("generators")]
gen-shacl:
    @echo "Generating SHACL model…"
    @echo -en "\t"
    mkdir -p "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"/linked_data
    @echo -en "\t"
    linkml generate shacl \
        --closed \
        --format ttl \
        "$DP_CAPACITY_HEATMAP_LOGICAL_SCHEMA" \
        > "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR/linked_data/$DP_CAPACITY_HEATMAP_PROJECT_FILENAME.shacl.ttl"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Generated SHACL model at: $DP_CAPACITY_HEATMAP_SCHEMAS_DIR/linked_data/$DP_CAPACITY_HEATMAP_PROJECT_FILENAME.shacl.ttl"
    @echo

# Generate JSON-LD context
[group("generators")]
gen-json-ld-ctx:
    @echo "Generating JSON-LD context…"
    @echo -en "\t"
    mkdir -p "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"/linked_data
    @echo -en "\t"
    linkml generate jsonld-context \
        "$DP_CAPACITY_HEATMAP_LOGICAL_SCHEMA" \
        > "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR/linked_data/$DP_CAPACITY_HEATMAP_PROJECT_FILENAME.json_ld_ctx.json"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Generated JSON-LD context at: $DP_CAPACITY_HEATMAP_SCHEMAS_DIR/linked_data/$DP_CAPACITY_HEATMAP_PROJECT_FILENAME.json_ld_ctx.json"
    @echo

# Clean up the output directory
[group("general")]
clean:
    @echo "Cleaning up project"
    @echo -n "… "
    @if [ -d "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR" ]; then \
        ( shopt -s dotglob; rm -rf "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"/* ); \
    else \
        mkdir "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"; \
    fi
    @echo -e "OK."
    @echo

# Show the contents of the output directory
[group("general")]
show-output:
    @if [ -x "$(which tree)" ]; then \
        tree "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"; \
    else \
        find "$DP_CAPACITY_HEATMAP_SCHEMAS_DIR"; \
    fi

# Edit the information model
[group("schema")]
edit-schema:
    @${VISUAL:-${EDITOR:-nano}} "$DP_CAPACITY_HEATMAP_LOGICAL_SCHEMA"

# Deploy documentation site.
[group("documentation")]
deploy-docs:
    @echo "Publishing documentation site…"
    @echo -en "\t"
    mkdocs gh-deploy --config-file "${DP_CAPACITY_HEATMAP_MKDOCS_CONFIG}"
    @echo -n "… "
    @echo "OK."
    @echo
    @echo -e "Documentation site deployed at: $DP_CAPACITY_HEATMAP_DOCS_URL"
    @echo

# Generate Linked Data schemas.
[group("generators")]
gen-ld: gen-shacl gen-json-ld-ctx

# Show class hierarchy in information model
[group("schema")]
q-schema-classes:
    yq '.classes.* | key' "$DP_CAPACITY_HEATMAP_LOGICAL_SCHEMA"
