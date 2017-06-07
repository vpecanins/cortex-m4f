@ Calculate sin(angle) of the angle in radians
@ Input range:   -pi < angle  < pi
@ Output range: -1.0 < sin(x) < 1.0
@
@ Register usage:
@   Argument in s0.
@   Result in s0.
@
@ Intermediate polynomial calculation:
@   s0 = do not touch
@   s1 = variable
@   s2 / s3 = accumulator
@   s3 / s2 = constant
@
@ Call from C/C++:   float asm_sin(float angle)
.syntax unified
.section .text
.global asm_sin
asm_sin:
    vabs.f32 s1, s0             @ s1 = abs(s0)
    vldr s2, =0x3fc90fdb        @ s2 = pi/2
    vldr s3, =0x40490fdb        @ s3 = pi
    vcmp.f32 s1, s2             @ if (s1 > pi/2)
    vmrs apsr_nzcv, fpscr       @ {
    it gt                       @     s1 = pi - s1
    vsubgt.f32 s1, s3, s1       @ }
    vldr s3, =0x3ce7989b        @ a4 = 0.02827101
    vldr s2, =0xbe4c585c        @ a3 = -0.19955582
    vfma.f32 s2, s3, s1         @ s2 <= a3 + a4 * x
    vldr s3, =0x3c4aadf9        @ s3 = 0.01237058
    vfma.f32 s3, s2, s1         @ s3 <= a2 + x * (a3 + a4 * x)
    vmul.f32 s2, s3, s1         @ s2 <= x * (a2 + x * (a3 + a4 * x) )
    vfma.f32 s1, s2, s1         @ s1 <= x + x^2 * (a2 + x * (a3 + a4 * x) )
    vcmp.f32 s0, #0.0           @ if (s0 < 0)
    vmrs apsr_nzcv, fpscr       @ {
    ite lt                      @   s0 = -s1
    vneglt.f32 s0, s1           @ } else
    vmovge.f32 s0, s1           @   s0 = s1
    bx  lr                      @ Return to C
