.syntax unified
.cpu cortex-m4
.thumb

.section .isr_vector, "a", %progbits
.global _isr_vector
_isr_vector:
    .word _estack_main
    .word Reset_Handler_main

.global Reset_Handler_main
.type Reset_Handler_main, %function

Reset_Handler_main:
    ldr   r0, =_estack_main
    msr   msp, r0

    bl    init_gpioc
    bl    led_toggle

hang:
    b     hang

init_gpioc:
    ldr   r0, =0x40023800       // rcc base address 
    ldr   r1, [r0, #0x30]       // rcc_ahb1enr with offset
    orr   r1, r1, #(1 << 2)     // enable gpioc clock 
    str   r1, [r0, #0x30]

    ldr   r0, =0x40020800       // gpioc base 
    ldr   r1, [r0, #0x00]       // gpioc_moder 
    bic   r1, r1, #(0b11 << 26) // clear mode bits for pin 13 
    orr   r1, r1, #(0b01 << 26) // set pin 13 as output 
    str   r1, [r0, #0x00]

    bx lr

led_on:
    ldr r0, =0x40020800
    mov r1, #(1 << (13 + 16))   // led pulled low to enable
    str r1, [r0, #0x18]
    bx  lr


led_toggle:
    ldr  r0, =0x40020800       // gpioc base 
    ldr  r1, [r0, #0x14]       // read gpioc_odr 
    eor  r1, r1, #(1 << 13)    // toggle bit 13 
    str  r1, [r0, #0x14]       // write back new odr 
    bl   delay
    b    led_toggle

delay:
    mov  r0, #500

outer_loop:
    mov  r1, #5000

inner_loop:
    subs r1, r1, #1
    bne  inner_loop

    subs r0, r0, #1
    bne  outer_loop

    bx lr  


.section .stack
.space 0x400
_estack_main:
