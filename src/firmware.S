.syntax unified
.cpu cortex-m4
.thumb

.section .isr_vector, "a", %progbits
.global _isr_vector
_isr_vector:
    .word _estack_main
    .thumb_func
    .word Reset_Handler_main

.section .text

.type Reset_Handler_main, %function
.global Reset_Handler_main
Reset_Handler_main:
    ldr   r0, =_estack_main
    msr   msp, r0

    bl    init_gpioc
    bl    init_clock
    bl    blink
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

    bx    lr

init_clock:
    ldr   r0, =0x40023800       // rcc base address 
    ldr   r1, [r0, #0x00]       // rcc_cr 

    orr   r1, r1, #(1 << 0)     // enable hsi
    str   r1, [r0, #0x00]      

check_hsi_on:
    ldr   r1, [r0, #0x00]
    tst   r1, #(1 << 1)         
    beq   check_hsi_on          // hsirdy == 0

    /* disable pll before configuring */
    ldr   r1, [r0, #0x00]
    bic   r1, r1, #(1 << 24)    // disable pll
    str   r1, [r0, #0x00]
check_pll_off:
    ldr   r1, [r0, #0x00]
    tst   r1, #(1 << 25)        
    bne   check_pll_off         // pllrdy != 0

    /* setup pll */
    ldr   r1, [r0, #0x04]       // rcc_pllcrgr
    bic   r1, r1, #(0x3F << 0)  // clear pllm
    orr   r1, r1, #(16 << 0)    // set pllm

    ldr   r2, =0x7FC0           // 9 enabled bits
    bic   r1, r1, r2            // plln rest 9 bits
    orr   r1, r1, #(192 << 6)   // set plln
    bic   r1, r1, #(0b11 << 16) // clear pllp
    orr   r1, r1, #(0b00 << 16) // set plln, plln = 2
    bic   r1, r1, #(1 << 22)    // clear pllsrc
    str   r1, [r0, #0x04]

    /* setup flash latency */
    ldr   r2, =0x40023C00       // flash base
    ldr   r1, [r2, #0x00]       // flash_acr
    orr   r1, r1, #(3 << 0)     // set latency to 3 wait states (~96 MHz)
    str   r1, [r2, #0x00]

    /* enable pll */
    ldr   r1, [r0, #0x00]
    orr   r1, r1, #(1 << 24)    // set pllon
    str   r1, [r0, #0x00]
check_pll_on:
    ldr   r1, [r0, #00]
    tst   r1, #(1 << 25)
    beq   check_pll_on          // pllrdy == 0

    /* set system clock to pll */
    ldr   r1, [r0, #0x08]       // rcc_cgfr
    bic   r1, r1, #(0b11 << 0)  // clear system clock switch bits
    orr   r1, r1, #(0b10 << 0)  // set system clock to use pll
    str   r1, [r0, #0x08]       
check_sysclk_set:
    ldr   r1, [r0, #0x08]
    and   r2, r1, #(0b10 << 2)  // get sws clock state
    cmp   r2, #(0b10 << 2)      // check if set as pll
    bne   check_sysclk_set

    bx    lr


led_on:
    ldr r0, =0x40020800
    mov r1, #(1 << (13 + 16))   // led pulled low to enable
    str r1, [r0, #0x18]

    bx  lr

led_off:
    ldr r0, =0x40020800
    mov r1, #(1 << (13))       // led pulled high to disable
    str r1, [r0, #0x18]

    bx  lr

led_toggle:
    ldr  r0, =0x40020800       // gpioc base 
    ldr  r1, [r0, #0x14]       // read gpioc_odr 
    eor  r1, r1, #(1 << 13)    // toggle bit 13 
    str  r1, [r0, #0x14]       // write back new odr 

    bx   lr


blink:
    ldr  r1, =delay_time
    ldr  r1, [r1]

    /* delay and then toggle the led */
delay:
    subs r1, r1, #1
    bne  delay                  // r1 value != 0

    bl    led_toggle

    b     blink


hang:
    bl     hang

.section .rodata
delay_time:
    .word 48000000              // ~1s if we assume 2 cycles
