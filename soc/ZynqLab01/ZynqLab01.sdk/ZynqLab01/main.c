/*
 * main.c
 *
 *  Created on: 2024. 10. 13.
 *      Author: dlwns
 */


#include "stdio.h"
#include "xgpio.h"

XGpio Gpio;

int main(){
   volatile int i;
   int j = 0;

   XGpio_Initialize(&Gpio, XPAR_AXI_GPIO_0_DEVICE_ID);

   while(1){
      XGpio_DiscreteWrite(&Gpio, 1, j);
      printf("Hello World%d\n", j++);
      for(i=0; i<1e8; i++);
   }

   return 0;
}
