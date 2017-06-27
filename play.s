    AREA  asm_data, DATA, READWRITE

// It is likely not all of these definitions are needed but I   
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

PORT_PCR29              EQU  0x74 
PORT_PCR3               EQU  0x0C
PORT_PCR5               EQU  0x14   
PORT_PCR_MUX_MASK       EQU  0x700
PORT_PCR_MUX_SHIFT      EQU  8
SIM_SCGC5_LPTMR_MASK    EQU  0x1
SIM_SCGC5_LPTMR_SHIFT   EQU  0
SIM_SCGC5_PORTA_MASK    EQU  0x200
SIM_SCGC5_PORTA_SHIFT   EQU  9
SIM_SCGC5_PORTB_MASK    EQU  0x400
SIM_SCGC5_PORTB_SHIFT   EQU  10
SIM_SCGC5_PORTC_MASK    EQU  0x800
SIM_SCGC5_PORTC_SHIFT   EQU  11
SIM_SCGC5_PORTD_MASK    EQU  0x1000
SIM_SCGC5_PORTD_SHIFT   EQU  12
SIM_SCGC5_PORTE_MASK    EQU  0x2000
SIM_SCGC5_PORTE_SHIFT   EQU  13
GPIOA_BASE              EQU  0x400FF000
GPIOB_BASE              EQU  0x400FF040
GPIOC_BASE              EQU  0x400FF080
GPIOD_BASE              EQU  0x400FF0C0
GPIOE_BASE              EQU  0x400FF100
GPIO_PDOR               EQU  0x00   ; Port Data Output Register, offset: 0x0
GPIO_PSOR               EQU  0x04   ; Port Set Output Register, offset: 0x4
GPIO_PCOR               EQU  0x08   ; Port Clear Output Register, offset: 0x8
GPIO_PTOR               EQU  0x0C   ; Port Toggle Output Register, offset: 0xC
GPIO_PDIR               EQU  0x10   ; Port Data Input Register, offset: 0x10
GPIO_PDDR               EQU  0x14   ; Port Data Direction Register, offset: 0x14


RESET_STATE     EQU  0x00
BLINK_STATE     EQU  0x01
BUTTON_CHECK    EQU  0x03
WIN_STATE       EQU  0x04
LOSE_STATE      EQU  0x05
WIN_MAX         EQU  33      // Add one to prevent off-by-one

count DCD 0x00
input_count DCD 0x00
max   DCD 0x01
state DCD 0x00  
left_press  DCD 0x00
right_press DCD 0x00
pat DCD 0xAAAAAAAA
m_z DCD 0x4626
m_w DCD 0x6558

    AREA asm_func, CODE, READONLY

    
    EXPORT play_game
    EXPORT init_game

//**************************************************//
init_game
    // Random code generated here

    LDR R2, =m_z
    LDR R0,[R2]
    LDR R2, =0xFFFF
    ANDS R2, R0, R2     // (m_z & 0xFFFF)
    LDR R3, = 0x9069    
    MULS R2, R3, R2     // 0x9069 * (m_z & 0xFFFF)
    LSRS R3, R0, #16    // (m_z >> 16)
    ADDS R0, R3, R2     // 0x9069 * (m_z & 0xFFFF) + (m_z >> 16)
    LDR R2, =m_z
    STR R0, [R2]

    LDR R2, =m_w
    LDR R1,[R2]
    LDR R2, =0xFFFF     
    ANDS R2, R1, R2     // (m_w & 0xFFFF)
    LDR R3, = 0x4650    
    MULS R2, R3, R2     // 0x4650 * (m_w & 0xFFFF)
    LSRS R3, R1, #16    // (m_w >> 16)
    ADDS R1, R3, R2     // 0x4650 * (m_w & 0xFFFF) + (m_w >> 16)
    LDR R2, =m_w
    STR R1, [R2]
    
    LSLS R0, R0, #16    //(m_z << 16) + m_w
    ADDS R0, R0, R1
    LDR R1, =pat
    STR R0, [R1]        //store the new pattern
    

    
init_done    
    
    // Force LEDs off
    LDR     R0, =GPIOD_BASE 
    LDR     R1, =(1<<5)
    STR     R1, [R0, #GPIO_PSOR]
    LDR     R0, =GPIOE_BASE
    LDR     R1, =(1<<29)
    STR     R1, [R0, #GPIO_PSOR]
    
    // Update state
    LDR R0, =BLINK_STATE
    LDR R1, =state
    STR R0, [R1] 
    LDR R1, =pat
    LDR R0, [R1] 
    BX      LR
 
 
//***************************************//
play_game 

//check the states   
    
    LDR R1, =state
    LDR R0, [R1]
    
    LDR R1, =RESET_STATE
    CMP R1, R0
    BEQ init_game
    
    LDR R1, =BLINK_STATE
    CMP R1, R0
    BEQ blink
    
    LDR R1, =BUTTON_CHECK
    CMP R1, R0
    BEQ button_check
    
    LDR R1, =LOSE_STATE
    CMP R1, R0
    BEQ lose

    LDR R1, =WIN_STATE
    CMP R1, R0
    BEQ win
    
lose  // Turn red on and green off
    LDR     R0, =GPIOE_BASE
    LDR     R1, =(1<<29)
    STR     R1, [R0, #GPIO_PCOR]
    LDR     R0, =GPIOD_BASE
    LDR     R1, =(1<<5)
    STR     R1, [R0, #GPIO_PSOR]
    BX      LR

win   // Turn green on and red off
    LDR     R0, =GPIOD_BASE
    LDR     R1, =(1<<5)
    STR     R1, [R0, #GPIO_PCOR]
    LDR     R0, =GPIOE_BASE
    LDR     R1, =(1<<29)
    STR     R1, [R0, #GPIO_PSOR]
    LDR R0, =WIN_STATE              // Update the state
    LDR R1, =state
    STR R0, [R1]
    BX      LR
    
//************************************************//
blink
   

// Cycle the LEDs so there is a off state between each blink

green_check
    LDR R0, =GPIOD_BASE
    LDR R1, =(1<<5)
    LDR R2, [R0,#GPIO_PDOR] 
    ANDS R1, R1, R2 
    LDR R2, =0
    CMP R1, R2   
    BEQ green_off
    
    
    
    LDR R0, =GPIOE_BASE
    LDR R1, =(1<<29)
    LDR R2, [R0,#GPIO_PDOR] 
    ANDS R1, R1, R2 
    LDR R2, =0
    CMP R1, R2   
    BEQ red_off
    
    BNE blinking     

green_off
 
    LDR     R0, =GPIOD_BASE
    LDR     R1, =(1<<5)
    STR     R1, [R0, #GPIO_PTOR]
    LDR R0, =BLINK_STATE
    BX      LR

red_off     
    LDR     R0, =GPIOE_BASE
    LDR     R1, =(1<<29)
    STR     R1, [R0, #GPIO_PTOR]
     
    LDR R0, =BLINK_STATE
    BX      LR
    
//**************************************************************//

//  
blinking 
    
    // Check if the round is over
    LDR     R1, =max
    LDR     R0, [R1]
    LDR     R1, =count
    LDR     R2, [R1]
    CMP     R2, R0
    BGE     blink_finished
    
    // Check if player has won
    CMP     R0, #WIN_MAX
    BEQ     win
    
    // Else increment count
    LDR     R3, =1
    ADDS    R2, R2, R3
    LDR     R1, =count
    STR     R2, [R1]
    
    // Load flash patteren
    LDR     R0, =pat
    LDR     R1, [R0]
    LDR     R0, =count
    LDR     R2, [R0]
    RORS    R1, R1, R2      // Rotate

    

    
    BCS     passover        // Branch if there is a carry bit
    
    
    LDR     R0, =GPIOD_BASE 
    LDR     R1, =(1<<5)
    STR     R1, [R0, #GPIO_PSOR]
    LDR     R0, =GPIOE_BASE
    LDR     R1, =(1<<29)
    STR     R1, [R0, #GPIO_PCOR]
    B       blink_done
passover  
    
    LDR     R0, =GPIOD_BASE
    LDR     R1, =(1<<5)
    STR     R1, [R0, #GPIO_PCOR]
    LDR     R0, =GPIOE_BASE
    LDR     R1, =(1<<29)
    STR     R1, [R0, #GPIO_PSOR]
    

blink_done
    // Update state
    LDR     R0, =BLINK_STATE
    LDR     R1, =state        
    LDR     R0, [R1]
   
    
    BX  LR
    
blink_finished
    
    LDR R1, =input_count
    LDR R0, =1
    STR R0, [R1]
    
    
    // Update state
    LDR R0, =BUTTON_CHECK
    LDR R1, =state
    STR R0, [R1]
    BX  LR
 

//********************************************//
button_check
    
    LDR     R2, =input_count
    LDR     R0, [R2]
    LDR     R2, =max
    LDR     R1, [R2]
    LDR     R3, =1
    SUBS    R0, R0, R3      
    CMP R1, R0
    // Round over?
    BEQ checking_done
    

    
    LDR     R2, =input_count
    LDR     R0, [R2]
    LDR     R3, =pat
    LDR     R2, [R3]
    
    // Step to next bit
    RORS    R2, R2, R0      
    
    // Check left if carry bit exists
    BCS     left_check      

    // Check right if no carry bit
    B     right_check       
                            
    
    
left_check
    
button_left
    LDR R0, =GPIOC_BASE
    LDR R1, =(1<<12)
    LDR R2, [R0,#GPIO_PDIR] 
    ANDS R1, R1, R2 
    LDR R2, =0
    CMP R1, R2              // Check if left_button was pressed
    BEQ set_left
    BNE check_left
  

set_left                    // Set left_press to 1 when pressed or held   
    

    LDR     R3, =left_press
    LDR     R4, =1
    STR     R4, [R3]
    
    B       button_right    // Step to next button
    
check_left                  // Button state not pressed
    

    LDR     R3, =left_press
    LDR     R4, [R3]
    CMP     R4, #1          // Check for button press
    BEQ     toggle_left     // Toggle if it has
    B       button_right
    
toggle_left  
    LDR     R3, =left_press  // Press is correct, increment and move on
    LDR     R4, =0
    STR     R4, [R3]
    LDR     R2, =input_count
    LDR     R0, [R2]
    LDR     R3, =1
    ADDS    R0, R0, R3
    LDR     R3, =input_count
    STR     R0, [R3]    

    LDR     R0, =BUTTON_CHECK
    BX      LR
    
button_right
    LDR R0, =GPIOC_BASE
    LDR R1, =(1<<3)
    LDR R2, [R0,#GPIO_PDIR] 
    ANDS R1, R1, R2 
    LDR R2, =0
    CMP R1, R2                  // Check for right button press
    BEQ set_right
    BNE check_right
  

set_right                       // Set right_press to 1 on press    
    LDR     R3, =right_press
    LDR     R4, =1
    STR     R4, [R3]
    
    B       done
    
check_right                     // Button state not pressed
    LDR     R4, =right_press
    LDR     R3, [R4]
    CMP     R3, #1              // Check for button press
    BEQ     toggle_right        // Toggle if it has
    B       done
    
toggle_right                    // Lose state      

   
    LDR     R2, =state
    LDR     R0, =LOSE_STATE
    STR     R0, [R2]
    BX      LR
done 
    LDR     R0, =BUTTON_CHECK
    BX      LR
    
right_check
    
button_left_right
    LDR R0, =GPIOC_BASE
    LDR R1, =(1<<12)
    LDR R2, [R0,#GPIO_PDIR] 
    ANDS R1, R1, R2 
    LDR R2, =0
    CMP R1, R2                  // Check for left button press
    BEQ set_left_right
    BNE check_left_right
  

set_left_right                  // Set left_press to 1 on press   
    

    LDR     R3, =left_press
    LDR     R4, =1
    STR     R4, [R3]
    
    B       button_right_right  // Move on to next button
    
check_left_right                // 
    

    LDR     R3, =left_press
    LDR     R4, [R3]
    CMP     R4, #1              // Check for button press
    BEQ     toggle_left_right   // Toggle if it has
    B       button_right_right
    
toggle_left_right               // Lose state

    LDR     R2, =state
    LDR     R0, =LOSE_STATE
    STR     R0, [R2]
      

    BX      LR
    
button_right_right
    LDR R0, =GPIOC_BASE
    LDR R1, =(1<<3)
    LDR R2, [R0,#GPIO_PDIR] 
    ANDS R1, R1, R2 
    LDR R2, =0
    CMP R1, R2                  // Check if right button was pressed
    BEQ set_right_right
    BNE check_right_right
  

set_right_right                 // Set right_press to 1 on press    
    LDR     R3, =right_press
    LDR     R4, =1
    STR     R4, [R3]
    
    B       done_right
    
check_right_right               // Button currently not pressed
    LDR     R4, =right_press
    LDR     R3, [R4]
    CMP     R3, #1              // Check if it has been pressed
    BEQ     toggle_right_right  // Toggle if it has
    B       done_right
    
toggle_right_right              // Correct input, increment and continue
       
    LDR     R3, =right_press
    LDR     R4, =0
    STR     R4, [R3]
    LDR     R2, =input_count
    LDR     R0, [R2]
    LDR     R3, =1
    ADDS    R0, R0, R3
    LDR     R3, =input_count
    STR     R0, [R3]

   
    LDR     R0, =BUTTON_CHECK    
    BX      LR
done_right 
    LDR R0, =BUTTON_CHECK       // Update state
    BX      LR
         
    
still_checking
    
    LDR R0, =BUTTON_CHECK       // Update state
    LDR R1, =state
    STR R0, [R1]
    
    BX  LR

checking_done
    
    LDR R1, =0                  // Set count=0
    LDR R2, =count
    STR R1, [R2]
    LDR R2, =input_count
    STR R1, [R2]
    
    LDR  R1, =1                 // Increment max
    LDR  R2, =max
    LDR  R0, [R2]
    ADDS R0, R0, R1
    STR  R0, [R2]
    
    // Reset tje blink state
    LDR     R0, =BLINK_STATE
    LDR     R1, =state
    STR     R0, [R1]
       
    BX      LR
    
    ALIGN
    END