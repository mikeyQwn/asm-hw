FILES=$(shell find ./ -name '*.asm' | grep -v 'template')
ARCHIVE_NAME=hw.zip

.PHONY: assemble
assemble:
	zip -j -o $(ARCHIVE_NAME) $(FILES)

.PHONY: clean
clean:
	rm -rf $(ARCHIVE_NAME)
