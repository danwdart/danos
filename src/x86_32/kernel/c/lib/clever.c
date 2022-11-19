#include <stdint.h>
#include "io.h"

inline void cpuid(int code, uint32_t *a, uint32_t *d)
{
    asm volatile("cpuid": "=a"(*a), "=d"(*d) : "0"(code) : "ebx", "ecx");
}

inline int cpuid_string(int code, uint32_t where[4]) {
  asm volatile("cpuid":"=a"(*where),"=b"(*(where+1)),"=c"(*(where+2)),"=d"(*(where+3)):"a"(code));
  return (int)where[0];
}

inline void rdtsc(uint32_t *upper, uint32_t *lower)
{
    asm volatile( "rdtsc"
                  : "=a"(*lower), "=d"(*upper) );
}

inline unsigned read_cr0(void)
{
    unsigned val;
    asm volatile( "mov %%cr0, %0"
                  : "=r"(val) );
    return val;
}

void reboot() {
    uint8_t good = 0x02;
    while (good & 0x02) {
        good = inb(0x64);
    }
    outb(0x64, 0xFE);
    asm("hlt");
}
