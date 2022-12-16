/* We can no longer use BIOS calls */
extern void _start() {
    print("Hello from C! I am 32-bit protected mode C.");
}

unsigned char *videoram = (unsigned char *)0xB8000;
unsigned short vrpos = 0;

void clear() {
    short num = 80 * 50 * 2,
        i = 0;
    for (i = 0; i <= num; i += 2) {
        videoram[i] = 0x20;
    }
}

void printc(char ch) {
    videoram[vrpos*2] = ch;
    vrpos++;
}

void print(char* string) {
    short i = 0;
    do {
        printc(string[i]);
        i++;
    } while ('\0' != string[i]);
}