CC=wine ../fasm/FASM.EXE
OUT=dist
FNAME=main.exe

run:$(FNAME)


$(OUT):
	mkdir -p $(OUT)

clean:
	rm -rf $(OUT)/*.exe

$(FNAME): $(OUT)
	$(CC) main.asm $(OUT)/$(FNAME)
