#include <stdint.h>

float asm_log2(float x1);

float c_log2(float n);

int test_log2(void)
{
	float val = 0.1f;
	
	// Print x, asm_log2(x) and c_log2(x)
	for (uint32_t i=0; i<100; i++) {
		printf("%f\t%f\t%f\r\n", val, asm_log(val), c_log(val));
		val *= 1.1f;
	}
}
