#include <stdint.h>
#include <stdio.h>

float asm_sin(float x1);

void test_sin(void)
{
	float val = -3.14f;

	// Print x, sin(x) for -3.14 < x < 3.14
	while (val < 3.14f) {
		printf("%f\t%f\r\n", val, asm_sin(val));
		val += 0.1;
	}
}
