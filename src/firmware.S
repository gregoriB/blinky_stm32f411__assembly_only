#include "constants.S"

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
    ldr   r0, =RCC_BASE                         
    ldr   r1, [r0, #RCC_AHB1ENR_OFFSET]             // rcc_ahb1enr
    orr   r1, r1, #(1 << 2)                         // enable gpioc clock 
    str   r1, [r0, #RCC_AHB1ENR_OFFSET]

    ldr   r0, =GPIOC_BASE                           
    ldr   r1, [r0, #GPIOC_MODER_OFFSET]             // gpioc_moder 
    bic   r1, r1, #(BITS_2 << 26)                   // clear mode bits for pin 13 
    orr   r1, r1, #(GPIOC_MODER_GP << 26)           // set pin 13 as output 
    str   r1, [r0, #GPIOC_MODER_OFFSET]

    bx    lr

init_clock:
    ldr   r0, =RCC_BASE                        
    ldr   r1, [r0, #RCC_CR_OFFSET]                  // rcc_cr 

    orr   r1, r1, #(1 << 0)                         // enable hsi
    str   r1, [r0, #RCC_CR_OFFSET]      

    check_hsi_on:
        ldr   r1, [r0, #RCC_CR_OFFSET]
        tst   r1, #(1 << 1)         
        beq   check_hsi_on                          // hsirdy == 0

    /* disable pll before configuring */
    ldr   r1, [r0, #RCC_CR_OFFSET]
    bic   r1, r1, #(1 << 25)                        // disable pll
    str   r1, [r0, #RCC_CR_OFFSET]

    check_pll_off:
        ldr   r1, [r0, #RCC_CR_OFFSET]
        tst   r1, #(1 << 25)        
        bne   check_pll_off                          // pllrdy != 0

    /* setup pll */
    ldr   r1, [r0, #RCC_PLLCRGR_OFFSET]             // rcc_pllcrgr
    bic   r1, r1, #(BITS_63 << 0)                   // clear pllm
    orr   r1, r1, #(16 << 0)                        // set pllm

    ldr   r2, =BITS_9
    bic   r1, r1, r2                                // plln rest 9 bits
    orr   r1, r1, #(RCC_PLLCRGR_PLLN_MAX_VAL << 6)  // set plln
    bic   r1, r1, #(BITS_2 << 16)                   // clear pllp
    orr   r1, r1, #(RCC_PLLCRGR_PLLN_MIN_DIV << 16) // set plln, plln = 2
    bic   r1, r1, #(1 << 22)                        // clear pllsrc
    str   r1, [r0, #RCC_PLLCRGR_OFFSET]

    /* setup flash latency */
    ldr   r2, =FLASH_BASE                      
    ldr   r1, [r2, #FLASH_ACR_OFFSET]
    bic   r1, r1, #(BITS_4 << 0)                    // clear pllsrc
    orr   r1, r1, #(FLASH_ACR_LATENCY_96MHZ << 0)   // set latency to 3 wait states (~96 MHz)
    str   r1, [r2, #FLASH_ACR_OFFSET]

    /* enable pll */
    ldr   r1, [r0, #FLASH_ACR_OFFSET]
    orr   r1, r1, #(1 << 24)                        // set pllon
    str   r1, [r0, #FLASH_ACR_OFFSET]

    check_pll_on:
        ldr   r1, [r0, #RCC_CR_OFFSET]
        tst   r1, #(1 << 25)
        beq   check_pll_on                          // pllrdy == 0

    /* set system clock to pll */
    ldr   r1, [r0, #RCC_CFGR_OFFSET]                // rcc_cfgr
    bic   r1, r1, #(BITS_2 << 0)                    // clear system clock switch bits
    orr   r1, r1, #(RCC_CFGR_SW_PLL << 0)           // set system clock to use pll
    str   r1, [r0, #RCC_CFGR_OFFSET]       

    check_sysclk_set:
        ldr   r1, [r0, #RCC_CFGR_OFFSET]
        and   r2, r1, #(RCC_CFGR_SWS_STATE << 2)    // get sws clock state
        cmp   r2, #(RCC_CFGR_SWS_STATE << 2)        // check if set as pll
        bne   check_sysclk_set

    bx    lr


led_on:
    ldr   r0, =GPIOC_BASE
    mov   r1, #(1 << GPIOC_PIN_13_LOW)              // led pulled low to enable
    str   r1, [r0, #GPIOC_BSRR_OFFSET]

    bx    lr

led_off:
    ldr   r0, =GPIOC_BASE
    mov   r1, #(1 << GPIOC_PIN_13_HIGH)             // led pulled high to disable
    str   r1, [r0, #GPIOC_BSRR_OFFSET]

    bx    lr

led_toggle:
    ldr  r0, =GPIOC_BASE
    ldr  r1, [r0, #GPIOC_ODR_OFFSET]                // read gpioc_odr 
    eor  r1, r1, #(1 << GPIOC_PIN_13_HIGH)          // toggle bit 13 
    str  r1, [r0, #GPIOC_ODR_OFFSET]                // write back new odr 

    bx   lr


blink:
    ldr  r1, =DELAY_CYCLES

    /* delay and then toggle the led */
    delay:
        subs r1, r1, #1
        bne  delay                                  // r1 value != 0

        bl    led_toggle

    b     blink


hang:
    bl     hang
