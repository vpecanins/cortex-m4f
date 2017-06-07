@ Calculate sine and cosine of an angle in radians
@ Input range:   -pi < angle  < pi
@ Output range: -1.0 < sin(x), cos(x) < 1.0
@
@ Register usage:
@   Argument in s0.
@   Result:
@       s0 = cos(x)
@       s1 = sin(x)
@
@ Call from C/C++:
@   struct cfloat {float re; float im};
@   struct cfloat y = asm_sincos(float x);


.syntax unified
.section .text
.global asm_sincos
asm_sincos:
    vpush {s4, s5}              @ We need to touch s4 and s5
    vmov.f32 r0, s0             @ Save s0 to r0
    and r0, #0x80000000         @ Keep only the sign of s0
    vabs.f32 s0, s0             @ s0 = abs(x)
    vldr s2, =0x3fc90fdb        @ s2 = pi/2
    vldr s3, =0x40490fdb        @ s3 = pi
    vcmp.f32 s0, s2             @ if (abs(x) > pi/2)
    vmrs apsr_nzcv, fpscr       @ {
    itt gt                      @   s0 = pi - x
    vsubgt.f32 s0, s3, s0       @   save quadrant bit in r0
    orrgt r0, #0x40000000       @ }
    vsub.f32 s1, s2, s0         @ s1 = pi/2 - x (to calculate cosine from sine)
    vmov.f32 s4, s0             @ {
    vmov.f32 s0, s1             @   Swap s0 and s1
    vmov.f32 s1, s4             @ }
    vldr s3, =0x3ce7989b        @ a4 = 0.02827101
    vldr s2, =0xbe4c585c        @ a3 = -0.19955582
    vfma.f32 s2, s3, s0         @ s2 <= a3 + a4 * x
    vldr s4, =0xbe4c585c        @ a3 = -0.19955582
    vfma.f32 s4, s3, s1         @ s4 <= a3 + a4 * (90-x)
    vldr s3, =0x3c4aadf9        @ a2 = 0.01237058
    vfma.f32 s3, s2, s0         @ s3 <= a2 + x * (a3 + a4 * x)
    vldr s5, =0x3c4aadf9        @ a2 = 0.01237058
    vfma.f32 s5, s4, s1         @ s3 <= a2 + (90-x) * (a3 + a4 * (90-x) )
    vmul.f32 s2, s3, s0         @ s2 <= x * (a2 + x * (a3 + a4 * x) )
    vmul.f32 s4, s5, s1         @ s2 <= (90-x) * (a2 + x * (a3 + a4 * (90-x) ) )
    vfma.f32 s0, s2, s0         @ s0 <= x + x^2 * (a2 + x * (a3 + a4 * x) )
    vfma.f32 s1, s4, s1         @ s1 <= x + x^2 * (a2 + x * (a3 + a4 * x) )
    tst r0, #0x80000000         @ {
    it ne                       @		Fix sign of sin according to input sign
    vnegne.f32 s1, s1           @ }
    tst r0, #0x40000000         @ {
    it ne                       @		Fix sign of cos according to quadrant
    vnegne.f32 s0, s0           @	}
    vpop {s4, s5}               @ Restore s4 / s5 (ARM Procedure Call Std)
    bx  lr                      @ Return to C
