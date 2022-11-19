#include "io.h"

char kmap[] = " 1234567890-=  qwertyuiop[]  asdfghjkl;'` \\zxcvbnm,./";

#define PSDATA 0x60
#define PSSTAT 0x64
#define PSCMD  0x64

void pssetup(void) {
    outb(PSCMD, 0xf3);
    outb(PSDATA, 0b00011111);
}

char sc2as(unsigned char sc) {
    if (0 == (sc & 0x80)) {
        return 0;
    }
    sc -= 0x81;
    return kmap[sc];
}
    
char getsc_poll(void) {
    while (1 == (inb(PSSTAT) & 0xfe)) { }
    return inb(PSDATA);
}

char code = 0;
char lastcode = 0;

char getch_poll(void) {
    while (code == lastcode || 0 == code) {
        code = getsc_poll();
    }

    lastcode = code;

    return sc2as(code);
}
