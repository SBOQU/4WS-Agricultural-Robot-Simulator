// Definition of the trajectory, vehicle, and ground parameters
global RefTraj ;                      
global Length_Front ;               // Distance from the center of gravity to the front axle.
global Length_Rear ;                // Distance from the center of gravity to the rear axle.
global Wheelbase ;                  // Total wheelbase of the vehicle. 
global Track_Width ;                // Transverse distance between the left and right wheels.
global Wheel_Radius ;               // Radius of the vehicle's wheels in meters.
global Vehicle_Mass ;               // Total mass of the vehicle in kilograms.
global Yaw_Inertia ;                // Yaw moment of inertia of the vehicle.
global Sample_Time ;                // Simulation sampling time in seconds.
global Sensor_Sample_Time ;         // Initial measured lateral deviation or sensor offset.
global Cornering_Stiffness ;        // Tire cornering stiffness for the linear dynamics model.
global Lookahead_Distance           // Look-ahead distance for classical steering control (meters).
global Horizon_Of_Prediction ;      // Spatial window for mathematical optimization of future trajectory states.

// Definition of the initialization and simulation parameters

global X_Init
global Y_Init
global Yaw_Init
global Yaw_Derivative_Init
global Beta_Init
global Front_Lateral_Force_Init
global Rear_Lateral_Force_Init
global Speed_Init
global Speed
global Simulation_Duration
global R_Steer_Ref
global Smoothed_Traj ;
global Act_State_Matrix 
global Act_Input_Matrix 
global Act_Output_Matrix
global Lateral_Error_Dot
global Heading_Error_Dot
global g
// ---------- Trajectory selection

loadmatfile ('Trajectoires/TrajZAdams.mat')       ;
//loadmatfile ('Trajectoires/QuartAdams.mat')     ;
//loadmatfile ('Trajectoires/lineAdamsLong.mat')  ;

Smoothed_Traj = Path_Filter(TrajMere);

// ---------- Vehicle parameters

Wheelbase = 1.3                         ;
Length_Rear = 0.7                       ;
Length_Front = Wheelbase - Length_Rear  ;
Track_Width = 1.2                       ;
Wheel_Radius = 0.4                      ;
Vehicle_Mass = 500                      ;
Yaw_Inertia = 500                       ;
Cornering_Stiffness = 55000             ;
Lookahead_Distance = 10                  ;
Horizon_Of_Prediction = -0.65           ;
Heading_Error_Desired = 0               ;
R_Steer_Ref = 0                         ;
g = 9.81                                ;

// ---------- Initialization

X_Init = 0.5                 ;
Y_Init = -0.5                ;
Yaw_Init = %pi/2               ;
Yaw_Derivative_Init = 0      ;
Beta_Init = 0                ;
Front_Lateral_Force_Init = 0 ;
Rear_Lateral_Force_Init = 0  ;
Speed_Init = 0               ;
Speed = 2                    ;

// ---------- Actuator Parameters ----------
        
Act_a1 =  1.55   ;              // These coefficients represent the physical delay and dynamics of the steering motor
Act_a2 = -0.633  ;
Act_b1 =  0.04   ;
Act_b2 =  0.04   ;
        
Act_State_Matrix  = [Act_b1, Act_b2, Act_a2 ;
                    1,      0,      0       ; 
                    0,      0,      0 ]     ; 
                                  
Act_Input_Matrix  = [Act_a1 ; 0 ; 1]        ;
Act_Output_Matrix = [1, 0, 0]               ;


// ---------- Simulation parameters

Sample_Time = 0.01 ;
Sensor_Sample_Time = 0.01 ;
// Simulation Duration : QuartAdams = 45 / ZAdam = 62
