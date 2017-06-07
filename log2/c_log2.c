#include <stdint.h>

// C implementation of the algorithm used in asm_log2 (not very optimized)
float c_log2(float n)
{
	uint32_t r0, r2; 
	int32_t r1; 
	float s0, s1, s2, s3;
	r0 = *(uint32_t *)&n;				//vmov r0, s0                 @ Move s0 to r0 to perfom bitwise logic
	r1 = r0 >> 23;					//lsr r1, r0, #23             @ Shift right to obtain exponent
	r1 = r1 & 0x000000FF;				//and r1, r1, #255            @ Put to zero all bits except exponent
	r1 = r1 - 127U;					//sub r1, r1, #127            @ Subtract the IEEE754 exponent offset
							//vmov s1, r1                 @ Convert int exponent to float
	s1 = (float)r1;					//vcvt.f32.s32 s1, s1         @ s1 = exponent(x) (float)
	r2 = (r0 << 8) & 0x7FFFFFFF;			//lsl r2, r0, #9              @ Shift left to keep mantissa in Q32 format *Not Q31*
	s0 = (float)(r2);				//vmov s0, r2                 @ Move to FPU to convert Q32 mantissa to float
	s0 = s0 / (float)(0x80000000);			//vcvt.f32.u32 s0, s0, #32    @ s0 = mantissa(x) (float) Range: 0 < s0 < 1.0
	s2 = 0.5f;					//vmov s2, #0.5               @ Calculate the Taylor polynomial around s0 = 0.5 to spread error.
	s0 = s0 - s2;					//vsub.f32 s0, s0, s2         @ s0 <= mantissa(x) - 0.5
	s2 = -0.0712442f;				//vldr s2, =0xbd91e87b        @ -2^2 / 3^4 / ln(2) a4
	s3 = 0.1424884f;				//vldr s3, =0x3e11e87b        @  2^3 / 3^4 / ln(2) a3
	s3 = s3 + s2 * s0;				//vfma.f32 s3, s2, s0         @ s3 <= a3 + a4 * s0
	s2 = -0.3205989f;				//vldr s2, =0xbea4258a        @ -2   / 3^2 / ln(2) a2
	s2 = s2 + s3 * s0;				//vfma.f32 s2, s3, s0         @ s2 <= a2 + s0 * (a3 + a4 * s0)
	s3 = 0.9617967f;				//vldr s3, =0x3f76384f        @  2   /   3 / ln(2) a1
	s3 = s3 + s2 * s0;				//vfma.f32 s3, s2, s0         @ s3 <= a1 + s0 * ( a2 - s0 * (a3 + a4 * s0))
	s2 = 0.5849625;					//vldr s2, =0x3f15c01a        @ ln(3/2) / ln(2)    a0
	s2 = s2 + s3 * s0;				//vfma.f32 s2, s3, s0         @ s2 <= a0 + s0 * (a1 + s0 * ( a2 - s0 * (a3 + a4 * s0)))
	s0 = s2 + s1;					//vadd.f32 s0, s2, s1         @ s0 <= taylor(mantissa(x)) + exponent(x)
	return s0;					//bx  lr                      @ Return to C
}
