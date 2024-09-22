CC=gcc
CFLAGS=-Wall -Wpedantic

FILES=main

EXECUTABLE=finals
EXECUTABLE_FULL=dist/$(EXECUTABLE)

SOURCES=$(addprefix src/, $(addsuffix .c, $(FILES)))
OBJECTS=$(addprefix dist/, $(addsuffix .o, $(FILES)))

.PHONY: run clean


all: $(EXECUTABLE_FULL)

run: $(EXECUTABLE_FULL)
	./$(EXECUTABLE_FULL)

$(EXECUTABLE_FULL): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@

dist/%.o: src/%.c
	$(CC) $(CFLAGS) $(LIBS) -c $< -o $@

clean: 
	rm -f ./$(EXECUTABLE_FULL) $(OBJECTS)
