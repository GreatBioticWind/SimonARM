//Define our file as assembly language
    AREA  asm_data, DATA, READWRITE

PORTA_BASE             EQU  0x40049000
PORTB_BASE             EQU  0x4004A000
PORTC_BASE             EQU  0x4004B000
PORTD_BASE             EQU  0x4004C000
PORTE_BASE             EQU  0x4004D000
PTA_BASE               EQU  0x400FF000
PTB_BASE               EQU  0x400FF040
PTC_BASE               EQU  0x400FF080
PTD_BASE               EQU  0x400FF0C0
PTE_BASE               EQU  0x400FF100
SIM_BASE               EQU  0x40047000
SIM_SCGC5              EQU  0x1038 
PORT_PCR12   EQU  0x30   
PORT_PCR29             EQU  0x74 
PORT_PCR3    EQU  0x0C
PORT_PCR5    EQU  0x14   
PORT_PCR_MUX_MASK        EQU  0x700
PORT_PCR_MUX_SHIFT       EQU  8
SIM_SCGC5_LPTMR_MASK     EQU  0x1
SIM_SCGC5_LPTMR_SHIFT    EQU  0
SIM_SCGC5_PORTA_MASK     EQU  0x200
SIM_SCGC5_PORTA_SHIFT    EQU  9
SIM_SCGC5_PORTB_MASK     EQU  0x400
SIM_SCGC5_PORTB_SHIFT    EQU  10
SIM_SCGC5_PORTC_MASK     EQU  0x800
SIM_SCGC5_PORTC_SHIFT    EQU  11
SIM_SCGC5_PORTD_MASK     EQU  0x1000
SIM_SCGC5_PORTD_SHIFT    EQU  12
SIM_SCGC5_PORTE_MASK     EQU  0x2000
SIM_SCGC5_PORTE_SHIFT    EQU  13
GPIOA_BASE             EQU  0x400FF000
GPIOB_BASE             EQU  0x400FF040
GPIOC_BASE             EQU  0x400FF080
GPIOD_BASE             EQU  0x400FF0C0
GPIOE_BASE             EQU  0x400FF100
GPIO_PDOR  EQU  0x00   ; Port Data Output Register, offset: 0x0
GPIO_PSOR  EQU  0x04   ; Port Set Output Register, offset: 0x4
GPIO_PCOR  EQU  0x08   ; Port Clear Output Register, offset: 0x8
GPIO_PTOR  EQU  0x0C   ; Port Toggle Output Register, offset: 0xC
GPIO_PDIR  EQU  0x10   ; Port Data Input Register, offset: 0x10
GPIO_PDDR  EQU  0x14   ; Port Data Direction Register, offset: 0x14

    AREA asm_func, CODE, READONLY

//Export function location so that C compiler can find it and link
    EXPORT init_red
    EXPORT init_green
    EXPORT init_button1
    EXPORT init_button2


//assembly code goes here       
init_red
    
    //System Clock Gating Control Register (SCGC)
    //Enable Clock of GPIO Port E
    LDR     R1, =SIM_BASE    ; Base address
    LDR     R2, =SIM_SCGC5   ; Offset
    LDR     R0, [R1, R2]
    LDR     R3, =SIM_SCGC5_PORTE_MASK
    ORRS    R0, R0, R3
    STR     R0, [R1, R2]
    
    //Set PORTE bit 29 as General GPIO pin  
    LDR     R1, =PORTE_BASE
    LDR     R0, [R1, #PORT_PCR29]
    LDR     R2, =~PORT_PCR_MUX_MASK
    ANDS    R0, R0, R2
    LDR     R2, =(0x001<<PORT_PCR_MUX_SHIFT) 
    ORRS    R0, R0, R2
    LDR     R2, =~0x03
    ANDS    R0, R0, R2
    STR     R0, [R1, #PORT_PCR29]
    
    //Set PORTE bit 29 Data Direction Register (PDDR)
    //0 = digital input, 1 = digital output
    LDR     R1, =GPIOE_BASE
    LDR     R0, [R1, #GPIO_PDDR]
    LDR     R2, =(1<<29)
    ORRS    R0, R0, R2    ; PTB 29 as output
    STR     R0, [R1, #GPIO_PDDR]

    ; Clear Set PORTE bit 29 output
    LDR     R1, =GPIOE_BASE
    LDR     R2, =(1<<29) 
    STR     R2, [R1,#GPIO_PCOR]

    BX      LR

init_green

    //System Clock Gating Control Register (SCGC)
    //Enable Clock of GPIO Port D
    LDR     R1, =SIM_BASE    ; Base address
    LDR     R2, =SIM_SCGC5   ; Offset
    LDR     R0, [R1, R2]
    LDR     R3, =SIM_SCGC5_PORTD_MASK
    ORRS    R0, R0, R3
    STR     R0, [R1, R2]
    
    //Set PORTD bit 5 as General GPIO pin  
    LDR     R1, =PORTD_BASE
    LDR     R0, [R1, #PORT_PCR5]
    LDR     R2, =~PORT_PCR_MUX_MASK
    ANDS    R0, R0, R2
    LDR     R2, =(0x001<<PORT_PCR_MUX_SHIFT) 
    ORRS    R0, R0, R2
    LDR     R2, =~0x03
    ANDS    R0, R0, R2
    STR     R0, [R1, #PORT_PCR5]
    
    //Set PORTE bit 5 Data Direction Register (PDDR)
    //0 = digital input, 1 = digital output
    LDR     R1, =GPIOD_BASE
    LDR     R0, [R1, #GPIO_PDDR]
    LDR     R2, =(1<<5)
    ORRS    R0, R0, R2    ; PTB 5 as output
    STR     R0, [R1, #GPIO_PDDR]

    //Clear Set PORTE bit 5 output
    LDR     R1, =GPIOD_BASE
    LDR     R2, =(1<<5) 
    STR     R2, [R1,#GPIO_PCOR]

    BX      LR


init_button1

    //System Clock Gating Control Register (SCGC)
    //Enable Clock of GPIO Port C
    LDR     R1, =SIM_BASE    ; Base address
    LDR     R2, =SIM_SCGC5   ; Offset
    LDR     R0, [R1, R2]
    LDR     R3, =SIM_SCGC5_PORTC_MASK
    ORRS    R0, R0, R3
    STR     R0, [R1, R2]
    
    //Set PORTD bit 3 as General GPIO pin  
    LDR     R1, =PORTC_BASE
    LDR     R0, [R1, #PORT_PCR3]
    LDR     R2, =~PORT_PCR_MUX_MASK
    ANDS    R0, R0, R2
    LDR     R2, =(0x001<<PORT_PCR_MUX_SHIFT) 
    LDR     R3, =0x03
    ADDS    R2, R2, R3
    ORRS    R0, R0, R2

    STR     R0, [R1, #PORT_PCR3]

    BX      LR



init_button2

    //System Clock Gating Control Register (SCGC)
    //Enable Clock of GPIO Port C
    LDR     R1, =SIM_BASE    ; Base address
    LDR     R2, =SIM_SCGC5   ; Offset
    LDR     R0, [R1, R2]
    LDR     R3, =SIM_SCGC5_PORTC_MASK
    ORRS    R0, R0, R3
    STR     R0, [R1, R2]
    
    //Set PORTD bit 12 as General GPIO pin  
    LDR     R1, =PORTC_BASE
    LDR     R0, [R1, #PORT_PCR12]
    LDR     R2, =~PORT_PCR_MUX_MASK
    ANDS    R0, R0, R2
    LDR     R2, =(0x001<<PORT_PCR_MUX_SHIFT) 
    LDR     R3, =0x03
    ADDS    R2, R2, R3
    ORRS    R0, R0, R2

    STR     R0, [R1, #PORT_PCR12]

    BX      LR      
done 
    BX      LR
    ALIGN
    END