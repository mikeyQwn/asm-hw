#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

uint8_t get_cmp(uint16_t a, uint16_t b) {
    if (a < b)
        return 0;
    if (a == b)
        return 1;
    return 2;
}

uint8_t get_type_by_cmps(uint8_t a, uint8_t b, uint8_t c) {
    const uint8_t LOOKUP[3][3][3] = {
        {
            {2, 2, 2},
            {4, 4, 4},
            {9, 8, 10},
        },
        {
            {5, 5, 5},
            {3, 3, 3},
            {6, 6, 6},
        },
        {
            {12, 11, 13},
            {7, 7, 7},
            {1, 1, 1},
        },
    };
    return LOOKUP[a][b][c];
}

uint8_t alternative_lookup(uint8_t a, uint8_t b, uint8_t c) {
    const uint8_t LOOKUP[27] = {
        2, 2, 2, 4, 4,  4,  9,  8, 10, 5, 5, 5, 3, 3,
        3, 6, 6, 6, 12, 11, 13, 7, 7,  7, 1, 1, 1,
    };
    const uint8_t a9 = (a << 3) + a;
    const uint8_t b3 = (b << 1) + b;
    return LOOKUP[a9 + b3 + c];
}

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

int test_fnx() {
    for (int a = 0; a < 3; ++a) {
        for (int b = 0; b < 3; ++b) {
            for (int c = 0; c < 3; ++c) {
                if (get_type_by_cmps(a, b, c) != alternative_lookup(a, b, c)) {
                    printf("a: %d, b: %d, c: %d", a, b, c);
                    return 1;
                }
            }
        }
    }
    printf("[info] All done!\n");
    return 0;
}

int main() {
    if (test_fnx() != 0) {
        return 1;
    }

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

    size_t no_entries = 0;
    size_t expected_no_entries = (file_size / 4) / 2;
    uint8_t *result = malloc(sizeof(*result) * expected_no_entries);

    size_t ptr = 0;
    while (ptr < file_size - 8) {
        uint16_t sumA = bytes[ptr + 2] + bytes[ptr + 3];
        uint16_t sumB = bytes[ptr + 2 + 4] + bytes[ptr + 3 + 4];
        uint16_t sumC = bytes[ptr + 2 + 8] + bytes[ptr + 3 + 8];
        uint8_t cmp_a = get_cmp(sumA, sumB);
        uint8_t cmp_b = get_cmp(sumB, sumC);
        uint8_t cmp_c = get_cmp(sumC, sumA);
        printf("AMP measures are %02x, %02x, %02x\n", bytes[ptr],
               bytes[ptr + 4], bytes[ptr + 8]);
        printf("1 measure is %d\n", sumA);
        printf("2 measure is %d\n", sumB);
        printf("3 measure is %d\n", sumC);
        printf("1 cmp is %d\n", cmp_a);
        printf("2 cmp is %d\n", cmp_b);
        printf("3 cmp is %d\n", cmp_c);
        printf("the type is %d\n", alternative_lookup(cmp_a, cmp_b, cmp_c));
        result[no_entries] = alternative_lookup(cmp_a, cmp_b, cmp_c);
        ptr += 8;
        no_entries += 1;
    }

    for (size_t ptr = 0; ptr < expected_no_entries; ptr += 1) {
        printf("the type is %d\n", result[ptr]);
    }

    printf("No entries: %ld, expected: %ld", no_entries, expected_no_entries);
}
