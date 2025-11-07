# Inline remarks: simple helper targets for your collection workflow
.RECIPEPREFIX := >
COLLECTION_ROOT := ansible_collections/stockops/core
GALAXY_YML      := $(COLLECTION_ROOT)/galaxy.yml
# Inline remarks: extract version (strip comments and quotes)
VERSION         := $(shell sed -n 's/^version:[[:space:]]*//p' $(GALAXY_YML) | head -n1 | sed 's/[[:space:]]*#.*//' | tr -d '\047"')
TARBALL         := $(COLLECTION_ROOT)/stockops-core-$(VERSION).tar.gz

.PHONY: build install test clean

build:
> # Inline remarks: build tarball at $(TARBALL)
> cd $(COLLECTION_ROOT) && ansible-galaxy collection build -f

install: build
> # Inline remarks: install to ~/.ansible/collections so Ansible resolves FQCN
> ansible-galaxy collection install --force $(TARBALL) -p ~/.ansible/collections

test:
> # Inline remarks: quick sanity playbook run against localhost
> ansible-playbook -i inventory_example/hosts.ini site.yml

clean:
> # Inline remarks: remove any built tarballs
> rm -f $(COLLECTION_ROOT)/stockops-core-*.tar.gz
