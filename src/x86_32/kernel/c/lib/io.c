extern inline void outb( unsigned short port, unsigned char val )
{
    asm volatile( "outb %0, %1"
                  : : "a"(val), "Nd"(port) );
}

extern inline unsigned char inb( unsigned short port )
{
    unsigned char ret;
    asm volatile( "inb %1, %0"
                  : "=a"(ret) : "Nd"(port) );
    return ret;
}

extern inline void io_wait( void )
{
    asm volatile( "jmp 1f\n\t"
                  "1:jmp 2f\n\t"
                  "2:" );
}

extern inline void io_wait_sneaky( void )
{
    // port 0x80 is used for 'checkpoints' during POST.
    // The Linux kernel seems to think it is free for use :-/
    asm volatile( "outb %%al, $0x80"
                  : : "a"(0) );
}
