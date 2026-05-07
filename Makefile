.PHONY: sync check status

sync:
	scripts/sync_from_source.sh

check:
	scripts/check_release.sh

status:
	git status --short

