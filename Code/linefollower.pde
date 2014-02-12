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
 *       Compiler:  arduino
 *
 *         Author:  Spencer Duncan,  Mark Bradley
 *
 * =====================================================================================
 */

// < -- DATA READ MACROS -- >
#define NS1 (newdata & 0x40)>>6
#define NS2 (newdata & 0x20)>>5
#define NS3 (newdata & 0x10)>>4
#define NS4 (newdata & 0x08)>>3
#define NS5 (newdata & 0x04)>>2
#define NS6 (newdata & 0x02)>>1
#define NS7 (newdata & 0x01)
// < -- END -- >

// < -- NOT USED -- >
#define OS1 (olddata & 0x40)
#define OS2 (olddata & 0x20)
#define OS3 (olddata & 0x10)
#define OS4 (olddata & 0x08)
#define OS5 (olddata & 0x04)
#define OS6 (olddata & 0x02)
#define OS7 (olddata & 0x01)
// < -- END -- > 

// < -- SENSOR PIN MACROS -- >
#define S1 5 
#define S2 4
#define S3 3
#define S4 2
#define S5 1
#define S6 0
#define S7 6
// < -- END -- > 

// < -- SENSOR THRESHOLD CONSTANTS -- >
#define THRESHOLD1 738                     /* Treat analog reads below this value as 0 */
#define THRESHOLD2 765
#define THRESHOLD3 729
#define THRESHOLD4 767
#define THRESHOLD5 741
#define THRESHOLD6 807
#define THRESHOLD7 0xDEADBEEF                   /* Broken sensor */
// < -- END -- >

// < -- CONTROL CONSTANTS -- > 
#define PCONST 1
#define DCONST 0
#define MAXSPEED -86
// < -- END -- >

unsigned char newdata = 0x00;
signed char diff;
float line = 4;                                   /* Assume we start perfectly on the line */
float error = 0;
float olderror = 0;
float direction;
int leftspeed, rightspeed;

void findLine();
void pid();
void Move();
void readData();

void setup(){
	
	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  setup
	 *  Description:  Setup function called first by the arduino. Call any run-first
	 *  functions here.
	 * =====================================================================================
	 */
	/*-----------------------------------------------------------------------------
	 * Add pinMode(m, INPUT) for all the sensor pins
	 * Also Hbridge init if there is any
	 *-----------------------------------------------------------------------------*/

	analogReference(DEFAULT);

}

void loop(){

	readData();
	findLine();
	pid();
	Move();

}

void pid(){
	direction = PCONST * error + DCONST * (error-olderror);
	/* :TODO:02/09/2012 01:29:19 PM:: Add normalization code */
}


void readData(){

//	if ( analogRead(S1) > THRESHOLD1 ) readData |= 0x40;
//	else                              readData &= ~0x40;
	if ( analogRead(S2) > THRESHOLD2 ) readData |= 0x20;
	else                              readData &= ~0x20;
	if ( analogRead(S3) > THRESHOLD3 ) readData |= 0x10;
	else                              readData &= ~0x10;
	if ( analogRead(S4) > THRESHOLD4 ) readData |= 0x08;
	else                              readData &= ~0x08;
	if ( analogRead(S5) > THRESHOLD5 ) readData |= 0x04;
	else                              readData &= ~0x04;
	if ( analogRead(S6) > THRESHOLD6 ) readData |= 0x02;
	else                              readData &= ~0x02;
//	if ( analogRead(S7) > THRESHOLD7 ) readData |= 0x01;
//	else                              readData &= ~0x01;

}

}
void findLine(){
	if (!newline)
		return;
	line = NS1 + NS2*2 + NS3*3 + NS4*4 + NS5*5 + NS6*6 + NS7*7;
	line /= NS1 + NS2 + NS3 + NS4 + NS5 + NS6 + NS7;
	olderror = error;
	error = 4-line;
}
void Move(){

	/*-----------------------------------------------------------------------------
	 *  Add movement code here
	 *  Do this by taking the direction var, multiplying them by MAXSPEED
	 *  and passing the result to the motors.
	 *-----------------------------------------------------------------------------*/
	if (direction>0){                       /* If our direction is right of center */
		rightSpeed = MAXSPEED;                      /* Set right wheel speed to max  */
		leftSpeed = floor(MAXSPEED - MAXSPEED/(3*PCONST + 6*DCONST)*direction);     /* And set left wheel to correct */
	}
	else if (direction < 0){                /* If our direction is left of center */
		leftSpeed = MAXSPEED;                       /* Set left wheel speed to max  */
		rightSpeed = floor(MAXSPEED - MAXSPEED/(3*PCONST + 6*DCONST)*(-1*direction));   /* And set right wheel to correct */
	}
	else{
		leftSpeed = rightSpeed = MAXSPEED;
	}
	motors.setSpeed(leftSpeed, rightSpeed);
}

