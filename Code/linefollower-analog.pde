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


#define THRESHOLD 100                     /* Treat analog reads below this value as 0 */
#define MOTORMAX aeiou                        /* No patrick, aeiou is not a number  */
#define PCONST
#define DCONST
#define MAXSPEED

unsigned int[7] data;
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
void cleanData();

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

}

void loop(){

	readData();
	cleanData();
	findLine();
	pid();
	Move();

}

void pid(){
	direction = PCONST * error + DCONST * (error-olderror);
	/* :TODO:02/09/2012 01:29:19 PM:: Add normalization code */
}

void readData(){
	
	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  readData
	 *  Description:  Reads data from the sensors into the data global variable.
	 *  Mama always told me not to use global variables, but arduino didn't listen.
	 * =====================================================================================
	 */

	 /* :TODO:02/09/2012 12:04:34 PM:: Make sure this reads the right pins 
		* and make sure that white low read, not a high read              */
	int read;                                     /* Temp variable */
	for(int i = 0; i<7; i++){          /* Iterate through sensors/array */
		read = analogRead(i);             /* Read into temp variable */

		if ( read < THRESHOLD )             //Treat read as 0
			read = 0;                         //If below white threshold
			
		data[i] = analogRead(i);
	}
}

void cleanData(){
	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  cleanData
	 *  Description:  Sets any values that are not connected to the line center to 0.
	 * =====================================================================================
	 */
	int i = line+1;
	for (;i < 7;i++)
		if ( !data[i] ) break;
	for (;i < 7;i++)
		data[i] = 0;
	i = line - 1;
	for (;i >= 0;i--)
		if ( !data[i] ) break;
	for (;i >= 0;i--)
		data[i] = 0;
}

void findLine(){
	
	int sum;
	line = 0;
	for ( int i = 0; i<7; i++ ) {
		line += newread[i]*(i+1);
		sum += newread[i];
	}
	if (sum>0){
		line /= sum;
		olderror = error;
		error = line-4;
	}
}

void Move(){

	/*-----------------------------------------------------------------------------
	 *  Add movement code here
	 *  Do this by taking the direction var, multiplying them by MOTORCONST
	 *  and passing the result to the motors.
	 *-----------------------------------------------------------------------------*/
	if (direction>0){                       /* If our direction is right of center */
		rightSpeed = MAXSPEED;                      /* Set right wheel speed to max  */
		leftSpeed = /*:TODO:*/ ;                    /* And set left wheel to correct */
	}
	else if (direction < 0){                /* If our direction is left of center */
		leftSpeed = MAXSPEED;                       /* Set left wheel speed to max  */
		rightSpeed = /*:TODO:*/ ;                 /* And set right wheel to correct */
	}
	else{
		leftSpeed = rightSpeed = MAXSPEED;
	}
 /* :TODO:02/09/2012 01:37:42 PM:: Add motor control stuff */
}
