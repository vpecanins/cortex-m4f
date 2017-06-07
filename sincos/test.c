#include <stdint.h>
#include <stdio.h>

struct cfloat {
	float re;
	float im;
};

struct cfloat asm_sincos(float x1);

void test_sincos(void)
{
	float val = -3.14f;
	struct cfloat y;

	// Print x, cos(x), sin(x) for -3.14 < x < 3.14
	while (val < 3.14f) {
		y = asm_sincos(val);
		printf("%f\t%f\t%f\r\n", val, y.re, y.im);
		val += 0.1;
	}
}
