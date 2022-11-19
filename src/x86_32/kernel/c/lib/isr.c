#include "isr.h"
#include "video.h"

// This gets called from our ASM interrupt handler stub.

void isr_handler(registers_t regs)
{
   print("recieved interrupt: "+regs.int_no+"\n");
}