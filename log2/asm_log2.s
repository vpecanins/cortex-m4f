.syntax unified
.section .text

.global asm_log2
@ float asm_log2(float x1, float x2)
@ s0 = x1
@ return value in s0
@ Touched: MCU: r0, r1, r2; FPU: s0, s1, s2, s3
asm_log:
    vmov r0, s0                 @ Move s0 to r0 to perfom bitwise logic
    lsr r1, r0, #23             @ Shift right to obtain exponent
    and r1, r1, #255            @ Put to zero all bits except exponent
    sub r1, r1, #127            @ Subtract the IEEE754 exponent offset
    vmov s1, r1                 @ Convert int exponent to float
    vcvt.f32.s32 s1, s1         @ s1 = exponent(x) (float)
    lsl r2, r0, #9              @ Shift left to keep mantissa in Q32 format *Not Q31*
    vmov s0, r2                 @ Move to FPU to convert Q32 mantissa to float
    vcvt.f32.u32 s0, s0, #32    @ s0 = mantissa(x) (float) Range: 0 < s0 < 1.0
    vmov s2, #0.5               @ Calculate the Taylor polynomial around s0 = 0.5 to spread error.
    vsub.f32 s0, s0, s2         @ s0 <= mantissa(x) - 0.5
    vldr s2, =0xbd91e87b        @ -2^2 / 3^4 / ln(2) a4
    vldr s3, =0x3e11e87b        @  2^3 / 3^4 / ln(2) a3
    vfma.f32 s3, s2, s0         @ s3 <= a3 + a4 * s0
    vldr s2, =0xbea4258a        @ -2   / 3^2 / ln(2) a2
    vfma.f32 s2, s3, s0         @ s2 <= a2 + s0 * (a3 + a4 * s0)
    vldr s3, =0x3f76384f        @  2   /   3 / ln(2) a1
    vfma.f32 s3, s2, s0         @ s3 <= a1 + s0 * ( a2 - s0 * (a3 + a4 * s0))
    vldr s2, =0x3f15c01a        @ ln(3/2) / ln(2)    a0
    vfma.f32 s2, s3, s0         @ s2 <= a0 + s0 * (a1 + s0 * ( a2 - s0 * (a3 + a4 * s0)))
    vadd.f32 s0, s2, s1         @ s0 <= taylor(mantissa(x)) + exponent(x)
    bx  lr                      @ Return to C

