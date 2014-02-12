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
 *         Author:  Spencer Duncan, Mark Bradley
 *
 * =====================================================================================
 */

// < -- INCLUDE LIBRARYS -- >
#include <OrangutanMotors.h>
#include <SoftwareSerial.h>

// < -- SENSOR PIN MACROS -- >
#define S1 5                                    // The way the sensors are wired to the 
#define S2 4                                    // board don't match how they are arranged 
#define S3 3                                    // on the front. These macros match pin numbers 
#define S4 2                                    // to where they physically are, from left 
#define S5 1 																		// to right. 
#define S6 0
#define S7 6

// < -- SENSOR THRESHOLD CONSTANTS -- >
#define THRESHOLD1 738                          // Theshold values for the sensors 
#define THRESHOLD2 765                          // analog read values above this are 
#define THRESHOLD3 729                          // interpreted as being part of the line 
#define THRESHOLD4 767
#define THRESHOLD5 741
#define THRESHOLD6 807
#define THRESHOLD7 0xDEADBEEF                   /* Broken sensor */

// < -- CONTROL CONSTANTS -- > 
#define PCONST 0.5                              /* Proportional constant */
#define DCONST 4                                /* Derivative constant */
#define MAXSPEED -70                            /* Max speed (Should be negative) */

// < -- DEBUG ENABLE FLAGS -- >
#define SENSORDEBUG false                       // Enable/Disable serial output for debugging 
                                                // Note: This does take a good bit of processor to use 
                                                // So only use it if you need it 

// < -- GLOBAL VARIABLES -- >
bool data[8] = {0, 0, 0, 0, 0, 0, 0, 0};
float error = 0;                                /* Assume we start perfectly on the line */
float olderror = 0;
float direction;
int leftSpeed, rightSpeed;
OrangutanMotors motors;

// < -- FUNCTION PROTOTYPES -- >
bool checkNull();
void findLine();
void cleanData();
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

	analogReference(DEFAULT);
	Serial.begin(9600);
}

void loop(){

	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  loop
	 *  Description:  Main loop function. Will indefinatly be called repeatedly after setup
	 *  is called once.
	 * =====================================================================================
	 */
	readData();                                   /* Read in */
//	cleanData(); /* NYI / BROKEN */
	findLine();                                   /* Process data */
	pid();                                        /* Process more */
	Move();                                       /* Move */

}

void pid(){
	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  pid
	 *  Description:  Applys proportional / derivative processing to the data
	 * =====================================================================================
	 */
	if ( abs(error) >= 1 )
		direction = PCONST * error + DCONST * (error-olderror);
	else direction = PCONST * error;
#if SENSORDEBUG
 Serial.print(" Direction: ");
 Serial.print( direction );
 Serial.print( " " );
#endif
}


void readData(){

	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  readData
	 *  Description:  Reads analog data from the sensors, compares against the threshold
	 *  values, and writes true/false to the bool data array
	 * =====================================================================================
	 */

	if ( analogRead(S1) > THRESHOLD1 ) data[0] = true;
	else                               data[0] = false;
	if ( analogRead(S2) > THRESHOLD2 ) data[1] = true;
	else                               data[1] = false;
	if ( analogRead(S3) > THRESHOLD3 ) data[2] = true;
	else                               data[2] = false;
	if ( analogRead(S4) > THRESHOLD4 ) data[3] = true;
	else                               data[3] = false;
	if ( analogRead(S5) > THRESHOLD5 ) data[4] = true;
	else                               data[4] = false;
	if ( analogRead(S6) > THRESHOLD6 ) data[5] = true;
	else                               data[5] = false;
	if ( analogRead(S7) > THRESHOLD7 ) data[6] = true;
	else                               data[6] = false;

#if SENSORDEBUG
	Serial.print((int)data[1]);
	Serial.print(" ");
	Serial.print((int)data[2]);
	Serial.print(" ");
	Serial.print((int)data[3]);
	Serial.print(" ");
	Serial.print((int)data[4]);
	Serial.print(" ");
	Serial.print((int)data[5]);
#endif

}

bool checkNull(){
	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  checkNull
	 *  Description:  Checks if the data array sees any part of the line. Returns false
	 *  if the last read sees no values above threshold.
	 * =====================================================================================
	 */
	for ( int i = 0; i<7; i++)
		if (data[i]) return true;
	return false;
}

void findLine(){
	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  findLine
	 *  Description:  Estimates current margin of error based on the last data read.
	 * =====================================================================================
	 */
	if (!checkNull()) return; /* Keep going where we were going if we have a null read */
	int sum = 0;
	error = 0;
#if SENSORDEBUG
  Serial.print(" Line0 ");
	Serial.print(line);
  Serial.print(" ");
#endif
	for (int i = 0; i<7; i++){                    /* Find average location */
		if (data[i]){
			error+=i+1; 
			sum++;
		}
	}
	error /= sum;
	error -= 4;                                   /* Center around zero */
	olderror = ( error + olderror )/2;            /* Move delta estimate */
#if SENSORDEBUG
        Serial.print(" Line: ");
        Serial.print(line);
        Serial.print(" Error: ");
        Serial.print(error);
        Serial.print( " ");
        Serial.print(" Old Error: ");
        Serial.print(olderror);
#endif
}

void cleanData(){
	
	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  cleanData
	 *  Description:  Sets any values that are not connected to the line center to 0.
	 *  Currently NYI, can cause the robot to go in circles.
	 * =====================================================================================
	 */
	int i = floor(line+1);
	for (;i < 7;i++)
		if ( !data[i] ) break;
	for (;i < 7;i++)
		data[i] = 0;
	i = floor(line - 1);
	for (;i >= 0;i--)
		if ( !data[i] ) break;
	for (;i >= 0;i--)
		data[i] = 0;
#if SENSORDEBUG
	Serial.print(" Cleaned Data: ");
	for (int j = 0; j < 7; j++)
		Serial.print((int)data[j]);
	Serial.print(" ");
#endif

}

void Move(){

	/* 
	 * ===  FUNCTION  ======================================================================
	 *         Name:  Move
	 *  Description:  Sets the wheel speed based on the direction value
	 * =====================================================================================
	 */
	if (direction>0){                                             // If our direction is right of center 
		rightSpeed = floor(MAXSPEED - 0.4*MAXSPEED*direction);      // set right wheel speed to max  
		leftSpeed = floor(MAXSPEED - (MAXSPEED*direction));         // and set left wheel to correct 
	}
	else if (direction < 0){                                      // If our direction is left of center 
		leftSpeed = floor(MAXSPEED - -1*0.4*MAXSPEED*direction);    // set left wheel speed to max  
		rightSpeed = floor(MAXSPEED - (MAXSPEED*(-1*direction)));   // and set right wheel to correct 
	}
	else{
		leftSpeed = rightSpeed = MAXSPEED;          /* Full speed ahead! */
	}
#if SENSORDEBUG
	Serial.print(rightSpeed);
	Serial.print(" ");
	Serial.println(leftSpeed);
#endif
	if ( leftSpeed < MAXSPEED ) leftSpeed = MAXSPEED;    // Make sure we didn't go past maxspeed 
	if ( rightSpeed < MAXSPEED ) rightSpeed = MAXSPEED;  // < is used because maxspeed is negative 
	motors.setSpeeds(leftSpeed, rightSpeed);
}

