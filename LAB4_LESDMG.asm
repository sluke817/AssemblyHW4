***************************************
*
* Name: Luke Schaefer
* ID: 18186970
* Date: Oct 24 2022
* Lab 4
*
* Program description: This program calculates the squares of each number in the provided array and stores them in a result array
*	This program uses all local variables on the stack
*	This program passes the parameter through the A register 
*
*
* Pseudocode of Main Program:
* #define SENTIN $FF
* unsigned int array[] = {1, 5, 100, 200, 254, $FF};
* unsigned int result[5];
* 
* int* pointer1=array;
* int* pointer2=result;
*
* while(*pointer1!=SENTIN) {
*	*pointer2=sub(*pointer1);
* 	pointer1++;
*   pointer2++;
* }
*
*---------------------------------------
*
* Pseudocode of Subroutine:
*
* int sub(int number) {
* 	unsigned int result;
* 	unsigned int i;
* 	unsigned int j;
* 	unsigned int topEnd;
* 	unsigned int sqr;
* 	result=0;
*	j=number;
*	while(j>0){
* 		i=1;
*   	topEnd=2*j;
*		sqr=0;
* 		while(i<topEnd){
* 			sqr+=i;
* 			i+=2;
*		}
*		result+=sqr;
* 	}
*   return result;
* }
*
*	
***************************************
* start of data section
	ORG $B000
NARR	FCB	1, 5, 100, 200, 254, $FF
SENTIN	EQU	$FF

	ORG $B010
RESARR	RMB	20	

* define any variables that your MAIN program might need here
* REMEMBER: Your subroutine must not access any of the main
* program variables including NARR and RESARR.
P1	RMB	2
P2	RMB	2



	ORG $C000
	LDS	#$01FF	//initialize stack pointer
* start of your program
	CLR	P1
	CLR 	P1+1
	CLR	P2
	CLR	P2+1

	LDX	#NARR		//int* pointer1=array
	STX	P1
	LDX	#RESARR	//int* pointer2=result
	STX	P2

WHLE	LDX	P1		//while(*pointer1!=SENTIN) {
	LDAA	0,X	
	CMPA	#SENTIN
	BEQ	ENDWHILE
	JSR	SUB		//*pointer2 = sub(*pointer1)
	PULA				
	LDX	P2
	STAA	0,X
	PULA
	STAA	1,X
	PULA
	STAA	2,X
	PULA
	STAA	3,X

	INC	P1+1		//pointer1++;
	LDAA	P2+1		//pointer2++;
	ADDA	#4
	STAA	P2+1
	
	BRA	WHLE
ENDWHILE	STOP



* define any other variables that you might need here using RMB (not FCB or FDB)
* remember that your main program must not access any of these variables, including


	ORG $D000
* start of your subroutine 
SUB	PULX			//getting the return addr
	DES			//opening a hole for the return variable
	DES	
	DES
	DES
	PSHX			//putting the return address back on the stack
	DES			//opening for j
	DES		
	DES			//opening for i
	DES
	DES			//opening for topEnd
	DES
	DES			//opening for sqr
	DES
	DES
	DES
	DES			//opening for result
	DES
	DES
	DES		
	TSX			//storing the first variable location in x register. 0-3 = result | 4-7 = sqr | 8-9 = topEnd | 10-11 = i | 12-13 = j | 14-15 = return addr | 16-19 = return val  //big endian, first byte in stack is high byte
	
	CLR 	12,X		//j=n;
	CLR	13,X
	STAA	13,X

	CLR	0,X		//result=0
	CLR	1,X
	CLR	2,X
	CLR	3,X

	CLR	4,X		//process of making sqr a 4 byte variable
	CLR	5,X

WHLE1	LDD	12,X		//while(j>0) {
	CMPB	#0
	BLS	ENDWHLE1

	CLR 	10,X		//i=1
	CLR	11,X
	INC	11,X

	CLR 	8,X		//topEnd=2*j
	CLR	9,X
	CLRA
	CLRB
	ADDD	12,X
	ADDD	12,X
	STD	8,X

	CLR	6,X		//sqr=0
	CLR	7,X

WHLE2	LDD	10,X		//while(i<topEnd) {
	CMPD	8,X
	BHS 	ENDWHLE2

	LDD	6,X		//sqr+=i
	ADDD	10,X
	STD	6,X

	LDD	10,X		//i+=2
	ADDD	#2
	STD	10,X
	BRA	WHLE2 	//}
ENDWHLE2

	TSY			
	INY
	INY
	INY			//Y register points to the result variable

	INX			
	INX
	INX
	INX
	INX
	INX
	INX			//X register now points to the sqr variable
		

	CLRB			//4 byte addition process
	INCB
	INCB
	INCB
	INCB
	CLC			
DO1	LDAA	0,Y		//result+=sqr
	ADCA	0,X
	STAA	0,Y
	DEX
	DEY
	DECB
UNTL1	BNE	DO1

	TSX			//getting the stack pointer back into X register to properly locate variables

	LDD	12,X		//j--;
	DECB
	STD	12,X
	BRA	WHLE1 	//}
ENDWHLE1


	LDAA	0,X		//process of copying result variable into a returnable value over the stack
	STAA	16,X	
	LDAA	1,X
	STAA	17,X
	LDAA	2,X
	STAA	18,X
	LDAA 	3,X
	STAA	19,X

	CLRB			//closing the variables to get back to the return address (destroying the variables)
	ADDB	#14
	CLC
DO2	INS
	DECB
UNTL2	BNE	DO2
	RTS			//return result;