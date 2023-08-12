/* Stolen from https://krinkinmu.github.io/2020/11/29/PL011.html */

#include <stddef.h>
#include <stdint.h>  // needed for uint32_t type

#ifndef _PL011_H_
#define _PL011_H_

static const uint32_t DR_OFFSET = 0x000;
static const uint32_t FR_OFFSET = 0x018;
static const uint32_t IBRD_OFFSET = 0x024;
static const uint32_t FBRD_OFFSET = 0x028;
static const uint32_t LCR_OFFSET = 0x02c;
static const uint32_t CR_OFFSET = 0x030;
static const uint32_t IMSC_OFFSET = 0x038;
static const uint32_t DMACR_OFFSET = 0x048;

struct pl011 {
    uint64_t base_address;
    uint64_t base_clock;
    uint32_t baudrate;
    uint32_t data_bits;
    uint32_t stop_bits;
};

volatile uint32_t *reg(const struct pl011 *dev, uint32_t offset);

static const uint32_t FR_BUSY = (1 << 3);


static const uint32_t CR_TXEN = (1 << 8);
static const uint32_t CR_UARTEN = (1 << 0);

static const uint32_t LCR_FEN = (1 << 4);
static const uint32_t LCR_STP2 = (1 << 3);

int pl011_reset(const struct pl011 *dev);

int pl011_setup(struct pl011 *dev, uint64_t base_address, uint64_t base_clock);

int pl011_send(const struct pl011 *dev, const char *data, size_t size);

#endif