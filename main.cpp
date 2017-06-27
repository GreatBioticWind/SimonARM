#include "mbed.h"

extern "C" void init_red();
extern "C" void init_green();
extern "C" void init_button1();
extern "C" void init_button2();
extern "C" int init_game();
extern "C" int play_game();

// Initialize the USB serial port
Serial pc(USBTX, USBRX);


int main()
{
    int value = 0x01;
    
    pc.baud(115200);
    init_red();
    init_green();
    init_button1();
    init_button2();
    init_game();
 
    while (value != 0x00) {
        wait(0.2f); // Wait here introduces wait before the game starts also
        value = play_game();
        
        
        // Serial output for debugging
        pc.printf("State = %d\r\n", value);
       
    }
}