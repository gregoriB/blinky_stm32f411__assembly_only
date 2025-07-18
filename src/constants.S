.equ MAIN_APP,                  0x08004000
.equ MAIN_APP_ENTRY_OFFSET,     0x4
.equ DELAY_CYCLES,              (16000000 - 1)

.equ BITS_2,                    0x3
.equ BITS_4,                    0xF
.equ BITS_9,                    0x7FC0
.equ BITS_6,                    0x3F

.equ RCC_BASE,                  0x40023800  
.equ RCC_AHB1ENR_OFFSET,        0x30 
.equ RCC_CR_OFFSET,             0x00
.equ RCC_PLLCRGR_OFFSET,        0x04
.equ RCC_PLLCRGR_PLLN_MAX_VAL,  0xC0
.equ RCC_PLLCRGR_PLLN_MIN_DIV,  0b00
.equ RCC_CFGR_OFFSET,           0x08
.equ RCC_CFGR_SW_PLL,           0x2
.equ RCC_CFGR_SWS_STATE,        0x2

.equ GPIOC_BASE,                0x40020800
.equ GPIOC_ODR_OFFSET,          0x14
.equ GPIOC_BSRR_OFFSET,         0x18
.equ GPIOC_MODER_OFFSET,        0x00
.equ GPIOC_MODER_GP,            0b01
.equ GPIOC_PIN_13_HIGH,         0xD
.equ GPIOC_PIN_13_LOW,          0xD + 0x10

.equ FLASH_BASE,                0x40023C00
.equ FLASH_ACR_OFFSET,          0x00
.equ FLASH_ACR_LATENCY_96MHZ,   0x3

.equ SYST_CSR,                  0xE000E010
.equ SYST_RVR,                  0xE000E014
.equ SYST_CVR,                  0xE000E018

.equ VTOR,                      0xE000ED08
