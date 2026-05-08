function [F_Steer_A, Steer_H_Pred, Int_Lat_Err, Corrective_Steering] = Model_Front_Axle_Output(...
    Lateral_Error, ...
    Heading_Error, ...
    Curvature, ...
    Front_Beta, ...
    Rear_Beta, ...
    Speed, ...
    Rear_Steering_Angle, ...
    N_1_Front_Steering_Angle, ...
    N_2_Front_Steering_Angle, ...
    N1_Corrective_Steering, ...
    Integral_Lateral_Error, ...
    Horizon_Of_Prediction, ...
    Curvature_Horizon_Of_Prediction, ...
    Steering_Horizon_Of_Prediction, ...
    Rear_Steering_Reference, ...
    Law_Type)


    // ============================================================================================
    //                      Local renaming for compactness
    // ============================================================================================

    global Wheelbase Act_State_Matrix Act_Input_Matrix  ;

    Lat_Err           = Lateral_Error                   ;
    H_Err             = Heading_Error                   ;
    C                 = Curvature                       ;
    F_Beta            = Front_Beta                      ; 
    R_Beta            = Rear_Beta                       ;
    R_Steer_A         = Rear_Steering_Angle             ;
    N1_F_Stee_A       = N_1_Front_Steering_Angle        ;
    N2_F_Stee_A       = N_2_Front_Steering_Angle        ;
    N1_Correct_Steer  = N1_Corrective_Steering          ;
    Int_Lat_Err       = Integral_Lateral_Error          ;
    H_Pred            = Horizon_Of_Prediction           ;
    C_H_Pred          = Curvature_Horizon_Of_Prediction ;
    Steer_H_Pred      = Steering_Horizon_Of_Prediction  ;
    R_Steer_Ref       = Rear_Steering_Reference         ;

    // ============================================================================================
    //                      The Command Law
    // ============================================================================================
        
    Min_Angle = -30  ;   
    Max_Angle =  30  ;
    Max_Rad = Max_Angle * %pi / 180 ;
    Min_Rad = Min_Angle * %pi / 180 ;

    select Law_Type

        // ============================================================================================
        //                       Proportional Derivative
        // ============================================================================================
        case 1 then

        // ---------- Parameters
        Kd        = -0.6 ;
        Kp        = -0.2 ;

        // ---------- Computation
        F_Steer_A  = Kp * Lat_Err + Kd * H_Err    ;

        F_Steer_A = min( Max_Rad, F_Steer_A )     ;
        F_Steer_A = max( Min_Rad, F_Steer_A )     ;
        
        // ---------- Output Adaptation
        Steer_H_Pred = 0                          ;
        Int_Lat_Err  = Int_Lat_Err + Lat_Err      ;
        Corrective_Steering = 0                   ;

        // ============================================================================================
        //                      Predictive Chained System
        // ============================================================================================
        case 2 then

        // ---------- Parameters
        Kd        = -0.9 ;
        Kp        = -0.3 ;

        // ---------- Effective Rear Heading
        Eff_R_H = H_Err + R_Beta + R_Steer_A ; 

        // ---------- Path_Scale_Factor
        Path_Scale_Factor = 1 - (C_H_Pred * Lat_Err) ;   // Use of C_H_Pred instead of C
        PSF               = Path_Scale_Factor        ;   // For compacteness
        if PSF < 0.1 then PSF = 0.1 ; end

        // ---------- Desired Yaw Rate Computation
        Omega_Desired = Kp * (Lat_Err) / PSF ;
        Omega         = tan(Eff_R_H)         ;
        
        // ---------- Computation
        Virtual_Control          = (cos(Eff_R_H)^3) * Kd * (Omega - Omega_Desired) / PSF + C_H_Pred * cos(Eff_R_H) / PSF               ; // From chained System        
        F_Steer_A                = atan((Wheelbase / cos(R_Steer_A + R_Beta)) * Virtual_Control + tan(R_Steer_A + R_Beta)) - F_Beta    ; // Inverse Kinematics

        // ---------- Saturation
        F_Steer_A = min( Max_Rad, F_Steer_A )     ;
        F_Steer_A = max( Min_Rad, F_Steer_A )     ;
    
        // ---------- Output Adaptation
        Steer_H_Pred = 0                     ;
        Int_Lat_Err  = Int_Lat_Err + Lat_Err ;
        Corrective_Steering = 0              ;

        // ============================================================================================
        //                      Exact Linearization with Curvature Feedforward
        // ============================================================================================
        case 3 then
        
        // ---------- Parameters
        Y_Desired     = 0
        Kd        = -0.9 ;
        Kp        = -0.3 ;
        F_Steer_A   = N1_F_Stee_A           ;

        // ---------- Path_Scale_Factor
        Path_Scale_Factor = 1 - (C * Lat_Err) ;
        PSF               = Path_Scale_Factor ;   // For compacteness
        if PSF < 0.1 then PSF = 0.1 ; end

        // ---------- Prediction Loop
        for i = 1 : round(20 * abs(H_Pred))
            Lat_Err = Lat_Err + Speed * sin(H_Err + R_Beta + R_Steer_A) * 0.05 ;
            H_Err   = H_Err + 0.05 * Speed * cos(R_Beta) * (tan(F_Steer_A + F_Beta) - tan(R_Steer_A + R_Beta)) / Wheelbase ...
                            - 0.05 * Speed * (C * cos(R_Steer_A + H_Err + R_Beta)) / PSF ;
        end

      
        // ---------- Effective Rear Heading
        Eff_R_H  = H_Err + R_Beta + R_Steer_A ;


        // ---------- Desired Yaw Rate Computation 
        Omega_Desired = Kp * (Lat_Err - Y_Desired) / PSF ;
        Omega         = tan(Eff_R_H) ;

        // ---------- Computation
        Virtual_Control          = (cos(Eff_R_H)^3) * Kd * (Omega - Omega_Desired) / PSF + C_H_Pred * cos(Eff_R_H) / PSF               ; // From chained System        
        F_Steer_A                   = atan((Wheelbase / cos(R_Steer_A + R_Beta)) * Virtual_Control + tan(R_Steer_A + R_Beta)) - F_Beta ; // Inverse Kinematics

        // ---------- Saturation
        F_Steer_A = min( Max_Rad, F_Steer_A )     ;
        F_Steer_A = max( Min_Rad, F_Steer_A )     ;
    
        // ---------- Output Adaptation
        Steer_H_Pred = 0                     ;
        Int_Lat_Err  = Int_Lat_Err + Lat_Err ;
        Corrective_Steering = 0              ;

        // ============================================================================================
        //                      Exact Linearization with Actuator Delay Compensation AND GPC
        // ============================================================================================
        case 4 then
        
        // ---------- Parameters
        Y_Desired   = 0                         ; // Target lateral error
        Kd          = 1.5                       ;
        Xi          = 1.0                       ; // Damping ratio
        Kp          = (Kd^2) / (4 * sqrt(Xi))   ; 
        Ki          = 0.1                       ;
        Gamma       = 0.5                       ; // Between 0(Fast) and 1(Slow) ---> How fast the robot join the trajectory
        Preview_Steps = round(20 * abs(H_Pred)) ;
        if Preview_Steps < 1 then Preview_Steps = 10 ; end
        
        // ---------- Computation
        Int_Lat_Err = Int_Lat_Err + 0.1 * Lat_Err ;
        Eff_R_H     = H_Err + R_Beta + R_Steer_A  ; 

        // ---------- Path_Scale_Factor
        Path_Scale_Factor = 1 - (C * Lat_Err) ;
        PSF               = Path_Scale_Factor ;   // For compacteness
        if PSF < 0.1 then PSF = 0.1 ; end
        
        // ---------- Computation
        Deviation_Correction_Effort = -Kd * PSF * tan(Eff_R_H) - Kp * (Lat_Err - Y_Desired) - Ki * Int_Lat_Err + C * PSF * (tan(Eff_R_H)^2) ;
        
        U_H_Term = Wheelbase * C_H_Pred ;
        U_Term = (Wheelbase / cos(R_Steer_A + R_Beta)) * (C * cos(Eff_R_H) / PSF) ;
        V_Term = (Wheelbase / cos(R_Steer_A + R_Beta)) * ( ((cos(Eff_R_H)^3) / (PSF^2)) * Deviation_Correction_Effort ) + tan(R_Steer_A + R_Beta) ;
        
        Corrective_Steering = atan(V_Term / (1 + U_Term * V_Term + U_Term^2)) - F_Beta ;

        // ---------- Trajectory Prevailing Parts
        Preview_Trajectory_Steering = atan(U_H_Term) ; 
        Current_Trajectory_Steering = atan(U_Term)   ; 

        Actuator_State_Error = [N1_F_Stee_A - N1_Correct_Steer    ;
                                N2_F_Stee_A - N1_Correct_Steer    ;
                                Steer_H_Pred]                     ;   
        
        //---------- GPC
        Delta_Future                     = Future_Reference(Preview_Trajectory_Steering, Current_Trajectory_Steering)         ;
        Delta_Desired                    = Desired_Response(Delta_Future ,Actuator_State_Error(1) ,Preview_Steps ,Gamma )     ;
        Free_Response                    = Free_Response_Computation(Actuator_State_Error ,Act_State_Matrix ,Preview_Steps )  ;
        Forced_Response                  = Forced_Response_Function(Act_State_Matrix ,Act_Input_Matrix ,Preview_Steps )       ;
        Command_Shape                    = Control_Structure("Echelon", Preview_Steps)                                        ;
        Optimal_Trajectory_Steering      = Optimal_Minimization(Delta_Desired, Free_Response, Forced_Response, Command_Shape) ;
        
        // ---------- Saturation
        
        F_Steer_A  = Corrective_Steering + Optimal_Trajectory_Steering(1) ;
        Steer_H_Pred = Optimal_Trajectory_Steering(1)                     ;
        
        // ---------- Saturation
        F_Steer_A = min( Max_Rad, F_Steer_A )     ;
        F_Steer_A = max( Min_Rad, F_Steer_A )     ;
    
        end

endfunction