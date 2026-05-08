function Tracking_Errors = Calculate_Tracking_Errors(...
    Current_Position, ...
    Current_Pos_Desired)
    
    // Robot's current state
    X_Robot     = Current_Position(1) ;
    Y_Robot     = Current_Position(2) ;
    Theta_Robot = Current_Position(3) ;
    
    // Projected point on the reference trajectory
    X_Proj     = Current_Pos_Desired(1) ;
    Y_Proj     = Current_Pos_Desired(2) ;
    Theta_Proj = Current_Pos_Desired(3) ;

    // ---------- Computation ----------
    Lat_Err = (X_Robot - X_Proj) * cos(Theta_Proj) + (Y_Robot - Y_Proj) * sin(Theta_Proj) ;
    H_Err   = Theta_Robot - Theta_Proj                                                    ;
    
    // ---------- Angular Fitting ----------
    if H_Err > %pi then
        H_Err = H_Err - 2 * %pi ;
    elseif H_Err < -%pi then
        H_Err = H_Err + 2 * %pi ;
    end
  
    // ---------- Output ----------
    Tracking_Errors = [Lat_Err ; H_Err] ;

endfunction