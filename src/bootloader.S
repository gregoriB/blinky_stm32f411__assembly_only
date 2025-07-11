.syntax unified
.cpu cortex-m4
.thumb

.section .isr_vector, "a", %progbits
.global _isr_vector
_isr_vector:
    .word _estack
    .word Reset_Handler

.section .text

.global Reset_Handler
.type Reset_Handler, %function

Reset_Handler:
    ldr   r0, =_estack
    msr   msp, r0
    ldr   r0, =0x08004000   // main firmware

    ldr   r1, [r0]
    msr   msp, r1           // set main stack pointer to main firmware

    ldr   r1, [r0, #4]      // load in main firmware entrypoint 
    bx    r1                // jump to main firmware

    b     hang              // should be unreachable


hang:
    b     hang
