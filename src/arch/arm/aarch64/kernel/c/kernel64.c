#include "pl011.h"

void main(void)
{
    struct pl011 serial;

    pl011_setup(
        &serial, /* base_address = */0x9000000, /* base_clock = */24000000);
    pl011_send(&serial, "Hello World\n", sizeof("Hello, World\n"));

    // There is nowhere to exit, so just hang here
    while (1) {}
}