// An Actual GDT
struct gdt_entry_struct
{
   uint16_t limit_low;           // The lower 16 bits of the limit.
   uint16_t base_low;            // The lower 16 bits of the base.
   uint8_t  base_middle;         // The next 8 bits of the base.
   uint8_t  access;              // Access flags, determine what ring this segment can be used in.
   // Access = [Segment Present, Priv Level 2, DescType, SegType 4]
   uint8_t  granularity;		   // Granularity flags
   // Granularity = [Granularity: 0=1,1=1024, Opsize=0=16b,1=32b, 0. Available(0), 4(SegmentLengthHigh)]
   uint8_t  base_high;           // The last 8 bits of the base.
} __attribute__((packed));
typedef struct gdt_entry_struct gdt_entry_t;

// Where is our GDT - this is like a pointer
struct gdt_ptr_struct
{
   uint16_t limit;               // The upper 16 bits of all selector limits.
   uint32_t base;                // The address of the first gdt_entry_t struct.
} __attribute__((packed));
typedef struct gdt_ptr_struct gdt_ptr_t;

// Initialisation function is publicly accessible.
void init_descriptor_tables();

