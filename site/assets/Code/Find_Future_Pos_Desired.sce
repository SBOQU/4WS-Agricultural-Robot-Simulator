function [Index_Future,Desired_Pos_Future] = Future_Pos_Desired(...
     Lookahead_Distance,...
     Closest_Point_Index)

    // ============================================================================================
    //                      Global Trajectory Parameter
    // ============================================================================================
    
    global Smoothed_Traj ;

    NbPoints = size(Smoothed_Traj, 1) ;
    
    if Closest_Point_Index < 1 then
        Closest_Point_Index = 1 ;
    elseif Closest_Point_Index > NbPoints - 1 then
        Closest_Point_Index = NbPoints - 1 ;
    end

    // Variables for the loop
    Accumulated_Dist = 0 ;
    Current_Idx      = Closest_Point_Index ;

    // ============================================================================================
    //                      Path Walking Logic (Accumulating distance)
    // ============================================================================================
    
    // We walk forward on the track until we reach the Lookahead_Distance, 
    // OR until we reach the very last point of the track.
    while (Accumulated_Dist < Lookahead_Distance) & (Current_Idx < NbPoints - 1)
        
        // Extract current point and the very next one
        P_Current = [Smoothed_Traj(Current_Idx, 2)     ; Smoothed_Traj(Current_Idx, 3)] ;
        P_Next    = [Smoothed_Traj(Current_Idx + 1, 2) ; Smoothed_Traj(Current_Idx + 1, 3)] ;
        
        // Calculate the small distance between these two consecutive points
        Step_Dist = Compute_Distance(P_Current, P_Next) ;
        
        // Add it to our total traveled distance
        Accumulated_Dist = Accumulated_Dist + Step_Dist ;
        
        // Move our virtual cursor one point forward
        Current_Idx = Current_Idx + 1 ;
        
    end

    // ============================================================================================
    //                      Output Generation
    // ============================================================================================

    Index_Future = Current_Idx ;
    
    X_Desired_Future = Smoothed_Traj(Index_Future, 2) ;
    Y_Desired_Future = Smoothed_Traj(Index_Future, 3) ;
    
    Desired_Pos_Future = [X_Desired_Future ; Y_Desired_Future] ;

endfunction