#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

long get_file_size(FILE *f) {
    long current_position = ftell(f);
    if (current_position < 0) {
        return current_position;
    }

    int ret;
    if ((ret = fseek(f, 0, SEEK_END)) < 0) {
        return ret;
    }

    long file_size = ftell(f);
    if (file_size < 0) {
        return file_size;
    }

    if ((ret = fseek(f, current_position, SEEK_SET)) < 0) {
        return ret;
    }

    return file_size;
}

int main() {
    const char input_path[] = "input.bin";

    FILE *handle = fopen(input_path, "r");
    if (handle == NULL) {
        printf("no such file\n");
        return 1;
    }

    long file_size = get_file_size(handle);
    if (file_size < 0) {
        printf("unable to get file size\n");
        return 1;
    }

    printf("the file size is: %ld bytes\n", file_size);

    // the file lives for the duration of the program, so no free
    uint8_t *bytes = malloc(sizeof(*bytes) * (file_size + 1));
    if (fread(bytes, file_size, sizeof(*bytes), handle) < 0) {
        printf("unable to read from the file\n");
        return 1;
    }

    printf("The first byte is: %d\n", bytes[0]);
}
