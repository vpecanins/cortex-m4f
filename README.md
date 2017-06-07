# Cortex-M4F ASM
DSP functions for the Cortex-M4F FPU written in assembly. 

I've decided to implement some DSP functions in assembly language for the Cortex-M4 family of microcontrollers that incorporate a FPU. The goal is to gain a better understanding of the architecture and explore the limits on performance. Hopefully this will produce a more optimized code and a faster execution.

The functions follow the [ARM Procedure Call Standard](http://infocenter.arm.com/help/topic/com.arm.doc.espc0002/ATPCS.pdf) thus they can be called from your C/C++ code without problem.

## Functions implemented so far

### [Logarithm Base-2](/log2)

This function exploits the layout of the IEEE754 representation that implicitly has the base 2 exponent and mantissa. The function calculates log2 from the mantissa using a 4th degree Taylor polynomial and adds the exponent extracted from IEEE754. The formula used is:

```
log2(x) = exponent(x) + log2_taylor( mantissa(x) )
```

The implementation only uses registers r0-r2 and s0-s3 so there's no need to push and pull data to the stack, using just 30 ASM instructions.

### [Sine](/sin)

Computes the sine of an angle between (-pi, pi). First, the angle is reduced to a value between (0, pi/2). Then calculate 4th degree Taylor polynomial and change the sign if necessary.
