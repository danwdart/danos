#include <stdint.h>
#include "gdt.h"

extern void gdt_flush(uint32_t);

static void init_gdt();
static void gdt_set_gate(int32_t,uint32_t,uint32_t,uint8_t,uint8_t);

gdt_entry_t gdt_entries[5]; // the actual entries
gdt_ptr_t   gdt_ptr; // base and limit pointer

idt_entry_t idt_entries[256];
idt_ptr_t   idt_ptr;

static void init_gdt()
{
   gdt_ptr.limit = (sizeof(gdt_entry_t) * 5) - 1;
   gdt_ptr.base  = (uint32_t)&gdt_entries;

   // Each gate is set from 0 - 4G
   gdt_set_gate(0, 0, 0, 0, 0);                // Null segment - has to be there - bleh
   // Configs -
   // All granularities are 1k, 32b, SegLen 256
   // Present, ring 0, DT1, type 10
   gdt_set_gate(1, 0, 0xFFFFFFFF, 0b10011010, 0b11001111); // Code segment - runnable by root
   // Present, ring 0, DT1, type 2
   gdt_set_gate(2, 0, 0xFFFFFFFF, 0b10010010, 0b11001111); // Data segment - usable by root
   // Present, ring 3, DT1, type 10
   gdt_set_gate(3, 0, 0xFFFFFFFF, 0b11111010, 0b11001111); // User mode code segment - runnable by user
   // Present, ring 3, DT1, type 2
   gdt_set_gate(4, 0, 0xFFFFFFFF, 0b11110010, 0b11001111); // User mode data segment - usable by user

   gdt_flush((uint32_t)&gdt_ptr);
}

// Set the value of one GDT entry.
static void gdt_set_gate(int32_t num, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran)
{
   gdt_entries[num].base_low    = (base & 0xFFFF);
   gdt_entries[num].base_middle = (base >> 16) & 0xFF;
   gdt_entries[num].base_high   = (base >> 24) & 0xFF;

   gdt_entries[num].limit_low   = (limit & 0xFFFF);
   gdt_entries[num].granularity = (limit >> 16) & 0x0F;

   gdt_entries[num].granularity |= gran & 0xF0;
   gdt_entries[num].access      = access;
}