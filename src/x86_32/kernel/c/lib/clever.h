#include <stdint.h>
inline void cpuid( int code, uint32_t * a, uint32_t * d );
inline void rdtsc( uint32_t * upper, uint32_t * lower );
inline unsigned read_cr0( void );
void reboot();
