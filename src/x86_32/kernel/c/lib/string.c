#include <stddef.h>
void *memcpy(void *dest, const void *src, size_t n) {
	void *ret = dest;
	while (n--) {
		*(char *)dest = *(char*)src;
		dest = (char *)dest + 1;
		src = (char *)src + 1;
	}
	return ret;
}
