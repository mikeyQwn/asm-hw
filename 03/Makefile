CC=WINEDEBUG=-all wine ../fasm/FASM.EXE
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
	$(CC) 03-list-macro.asm $(OUT)/$(FNAME)
