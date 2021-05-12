int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x80; //make a pointer to access the PIO block
	volatile unsigned int *SW_PIO  = (unsigned int*)0x60;
	volatile unsigned int *RUN_PIO = (unsigned int*)0x50;

	*LED_PIO = 0; //clear all LEDs
	while ( (1+1) != 3) //infinite loop
	{
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO |= 0x1; //set LSB
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO &= ~0x1; //clear LSB
		if (*RUN_PIO == 0)
		{
			for (i = 0; i < 100000; i++); //software delay
			*LED_PIO += *SW_PIO;
			while (*RUN_PIO == 0);
		}
	}
	return 1; //never gets here
}
