function Curvature = Calculate_Curvature(...
    Point_Index, ... 
    Pos_Desired)

    // ============================================================================================
    //                      Global Trajectory Parameter
    // ============================================================================================
    
    global Smoothed_Traj ;

    // ============================================================================================
    //                      Extraction of 3 local points
    // ============================================================================================
    
    NbPoints = size(Smoothed_Traj, 1) ;
    Spacing  = 3                      ;  // Spacing between points to avoid numerical instability (division by zero) if the point are aligned

    // ---------- Window Slide ----------
    // Begin of the track
    if Point_Index <= Spacing then
        p1 = 1               ;
        p2 = 1 + Spacing     ;
        p3 = 1 + 2 * Spacing ;

    // End of the track    
    elseif Point_Index >= (NbPoints - Spacing) then
        p1 = NbPoints - 2 * Spacing ;
        p2 = NbPoints - Spacing     ;
        p3 = NbPoints               ;
    
    // Normal use
    else
        p1 = Point_Index - Spacing ;
        p2 = Point_Index           ;
        p3 = Point_Index + Spacing ;
    end

    // Coordinate extraction centered on the robot
    x1 = Smoothed_Traj(p1, 2) ; y1 = Smoothed_Traj(p1, 3) ;
    x2 = Smoothed_Traj(p2, 2) ; y2 = Smoothed_Traj(p2, 3) ;
    x3 = Smoothed_Traj(p3, 2) ; y3 = Smoothed_Traj(p3, 3) ;

    // ============================================================================================
    //                      Computation of the circumcenter
    // ============================================================================================

    Num_X = ((x1^2 + y1^2 - x2^2 - y2^2)*(y1 - y3) - (x1^2 + y1^2 - x3^2 - y3^2)*(y1 - y2)) ;
    Den_X = (2 * ((x1 - x2)*(y1 - y3) - (x1 - x3)*(y1 - y2))) + 1e-9;
    X_Center = Num_X / Den_X ;

    Num_Y = ((x1^2 + y1^2 - x2^2 - y2^2)*(x1 - x3) - (x1^2 + y1^2 - x3^2 - y3^2)*(x1 - x2)) ;
    Den_Y = (2 * ((y1 - y2)*(x1 - x3) - (y1 - y3)*(x1 - x2))) + 1e-9;
    Y_Center = Num_Y / Den_Y ;

    // ============================================================================================
    //                      Curvature Output
    // ============================================================================================
    
    // If points are aligned -> Curvature is 0
    if abs(X_Center) == %inf | abs(Y_Center) == %inf | isnan(X_Center) then
        Curvature = 0 ;
    else
        X_Proj     = Pos_Desired(1) ;
        Y_Proj     = Pos_Desired(2) ;
        Theta_Proj = Pos_Desired(3) ;
        
        // Signed radius calculation relative to the projected orientation
        Radius_Curvature = (X_Center - X_Proj) * cos(Theta_Proj) + (Y_Center - Y_Proj) * sin(Theta_Proj) ;
        
        if Radius_Curvature == 0 then
            Curvature = 0 ;
        else
            Curvature = 1 / Radius_Curvature ;
        end
    end

endfunction