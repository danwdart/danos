#include "io.h"

char kmap[] = " 1234567890-=  qwertyuiop[]  asdfghjkl;'` \\zxcvbnm,./";

#define PSDATA 0x60
#define PSSTAT 0x64
#define PSCMD  0x64

#define CMD_TYPEMATIC_RATE 0xf3
#define GOOD_REPEAT_RATE 0b00011111

void pssetup(void) {
    outb(PSCMD, CMD_TYPEMATIC_RATE);
    outb(PSDATA, GOOD_REPEAT_RATE);
}

char scancode_to_ascii(unsigned char sc) {
    if (0 == (sc & 0x80)) { // check for high byte and return nothing if pressed as we only want released
        return 0;
    }
    sc -= 0x81; // what would it have been if it was pressed?
    return kmap[sc];
}

char get_scancode_poll(void) {
    while (1 == (inb(PSSTAT) & 0xfe)) { }
    return inb(PSDATA);
}

char code = 0;
char lastcode = 0;

char getch_poll(void) {
    while (code == lastcode || 0 == code) {
        code = get_scancode_poll();
    }

    lastcode = code;

    return scancode_to_ascii(code);
}
