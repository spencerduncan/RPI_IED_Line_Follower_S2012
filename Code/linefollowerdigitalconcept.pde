/*
 * =====================================================================================
 *
 *       Filename:  linefollower.pde
 *
 *    Description:  Code for IED line follower miniproject
 *
 *        Version:  1.0
 *        Created:  2/7/2012 7:52:05 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Spencer Duncan,  Mark Bradley
 *
 * =====================================================================================
 */


/* #####   MACROS  -  LOCAL TO THIS SOURCE FILE   ################################### */
#define NS1 (newdata & 0x40)
#define NS2 (newdata & 0x20)
#define NS3 (newdata & 0x10)
#define NS4 (newdata & 0x08)
#define NS5 (newdata & 0x04)
#define NS6 (newdata & 0x02)
#define NS7 (newdata & 0x01)
#define OS1 (olddata & 0x40)
#define OS2 (olddata & 0x20)
#define OS3 (olddata & 0x10)
#define OS4 (olddata & 0x08)
#define OS5 (olddata & 0x04)
#define OS6 (olddata & 0x02)
#define OS7 (olddata & 0x01)

#define THRESHOLD 500
#define MOTORCONST aieou


/* Define sensor pin values, using names S1-S7 */

unsigned char newread = 0x00;
unsigned char oldread = 0x00;
signed char diff;
float line;
int rightturnF, leftturnF; /* These will fall between 0 and 4*/

void TurnRight();
void TurnLeft();
void GoForward();

void readData(unsigned char &newread){
	if ( analogRead(S1) > THRESHOLD ) readData |= 0x40;
	else                              readData &= ~0x40;
	if ( analogRead(S2) > THRESHOLD ) readData |= 0x20;
	else                              readData &= ~0x20;
	if ( analogRead(S3) > THRESHOLD ) readData |= 0x10;
	else                              readData &= ~0x10;
	if ( analogRead(S4) > THRESHOLD ) readData |= 0x08;
	else                              readData &= ~0x08;
	if ( analogRead(S5) > THRESHOLD ) readData |= 0x04;
	else                              readData &= ~0x04;
	if ( analogRead(S6) > THRESHOLD ) readData |= 0x02;
	else                              readData &= ~0x02;
	if ( analogRead(S7) > THRESHOLD ) readData |= 0x01;
	else                              readData &= ~0x01;

}

void setup(){
	
	/*-----------------------------------------------------------------------------
	 * Add pinMode(m, INPUT) for all the sensor pins
	 * Also Hbridge init if there is any
	 *-----------------------------------------------------------------------------*/
}

void loop(){
	
	readData(newread);
	if(!newread){
		diff = ( oldread & 0x07 ) - ( ( OS3 >> 2 ) + ( OS2 >> 4 ) + ( OS1 >> 6) );
		if (diff > 0) TurnRight();
		if (diff < 1) TurnLeft();
		else GoForward();
	}
	else{
		oldread = newread;
		line = NS1 + NS2*2 + NS3*3 + NS4*4 + NS5*5 + NS6*6 + NS7*7;
		line /= NS1 + NS2 + NS3 + NS4 + NS5 + NS6 + NS7;
		rightturnF = floor( line + 0.5 );
		leftturnF = floor( (8-line) + 0.5 );
	}
	Move();

}

void TurnLeft(){
	rightturnF = 0;                               /* Maybe make this 1 */
	leftturnF = 3;
}

void TurnLeft(){
	rightturnF = 3;
	leftturnF = 0;
}

void GoForward(){
	rightturnF = leftturnF = 2;
}

void Move(){

	/*-----------------------------------------------------------------------------
	 *  Add movement code here
	 *  Do this by taking the turnF variables, multiplying them by MOTORCONST
	 *  and passing the result to the motors.
	 *-----------------------------------------------------------------------------*/
}
