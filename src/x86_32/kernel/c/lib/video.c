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

void printch(char* string, short len) {
    while (0 < len) {
	printc(string[len]);
        len--;
    }
}

void printhex_le(char ch) {
    char low;
    char high;

    low = 0x30 + (ch & 0x0f);
    high = 0x30 + ((ch & 0xf0) >> 4);
    
   if (0x39 < low)
        low += 0x07;

    if (0x39 < high)
        high += 0x07;

    printc(high);
    printc(low);
    printc(0x20);
}
