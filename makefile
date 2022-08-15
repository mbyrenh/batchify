install:
	install -T batchify.sh $(HOME)/.local/bin/batchify
	install -T batch-execute.sh $(HOME)/.local/bin/batch-exec

uninstall:
	rm $(HOME)/.local/bin/batchify
	rm $(HOME)/.local/bin/batch-exec

.PHONY: install uninstall
