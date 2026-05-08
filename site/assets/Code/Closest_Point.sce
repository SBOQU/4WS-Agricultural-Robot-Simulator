function Closest_Point_Index = Find_Closest_Point_Index(Current_Position)

    // ============================================================================================
    //                      Global Trajectory Parameter
    // ============================================================================================
    
    global Smoothed_Traj ;

    // ============================================================================================
    //                      Distance Computation
    // ============================================================================================

    X_Robot = Current_Position(1) ;
    Y_Robot = Current_Position(2) ;

    // Extract the full X and Y columns from the trajectory
    X_Traj = Smoothed_Traj(:, 2) ;
    Y_Traj = Smoothed_Traj(:, 3) ;

    // Calculate squared distances for all points simultaneously
    // Note: Using squared distance saves CPU time (sqrt is not needed to find the minimum)
    Distances_Sq = (X_Traj - X_Robot).^2 + (Y_Traj - Y_Robot).^2 ;

    // Find the index (row number) of the smallest distance
    [Min_Val, Closest_Point_Index] = min(Distances_Sq) ;

endfunction