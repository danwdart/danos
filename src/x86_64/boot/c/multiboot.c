#include <stdint.h>
#include "loader.h"
/* We can only use:
 *
 * <float.h>
 * <iso646.h>
 * <limits.h>
 * <stdalign.h>
 * <stdarg.h>
 * <stdbool.h>
 * <stddef.h>
 * <stdint.h>
 * <stdnoreturn.h>
 */

void kmain(void)
{
   extern uint32_t magic;
/*   extern void *mbd; */
   extern void halt(void);
 
   if ( magic != 0x2BADB002 )
   {
      halt();
   }
 
/*    char * boot_loader_name =(char*) ((long*)mbd)[16]; */
 
   main();
}
