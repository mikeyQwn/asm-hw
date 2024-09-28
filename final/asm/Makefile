CC=wine ../../fasm/FASM.EXE
OUT=dist
FNAME=main.exe

run: $(FNAME)
	chmod u+x $(OUT)/$(FNAME)
	./$(OUT)/$(FNAME)

$(OUT):
	mkdir -p $(OUT)

clean:
	rm -rf $(OUT)/*.exe

$(FNAME): $(OUT)
	$(CC) wcdll.asm $(OUT)/wcdll.dll
	$(CC) 05-wave-class.asm $(OUT)/$(FNAME)
