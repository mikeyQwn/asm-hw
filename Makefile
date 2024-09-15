FILES=$(shell find ./ -name '*.asm' | grep -v 'template')
ARCHIVE_NAME=hw.zip
$(info $(FILES))

.PHONY: assemble
assemble:
	python3 scripts/assemble.py

.PHONY: zip
zip: assemble
	zip -r -j $(ARCHIVE_NAME) hw


.PHONY: clean
clean:
	rm -rf $(ARCHIVE_NAME)
