#include "video.h"
#include "io.h"
/* #include "clever.h" */
#include "string.h"
#include "8042.h"

int main(void) {
    clear();
    print("Welcome to DanOS32!");
    print(" Thanks for choosing us!");
    pssetup();
    unsigned char ch = 0;
    while(1) {
        ch = getch_poll();
        printch(&ch, 1);
    }
    /*
    asm volatile ("int $0x3");
    asm volatile ("int $0x4");
    */

    return 0;
}
