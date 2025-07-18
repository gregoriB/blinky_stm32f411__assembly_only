# Blinky using only Arm assembly

## Only tested on Linux using an STM32F411CEU6 black pill with an ST-Link

## Usage:
Do:
```
bash run.sh
```
Or do:
```
make && make flash
```

### Description

Uses a bootloader to load in the actual firmware because otherwise power-cycling and reset does not run the program.

Currently uses Systick and NVIC to perform a non-blocking LED toggle.
