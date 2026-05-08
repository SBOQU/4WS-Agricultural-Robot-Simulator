function Desired_Pos_Now = Current_Pos_Desired(...
    Current_Position, ...
    Closest_Point_Index, ...
    Projection_Method)

    // ---------- Parameters
    
    global Smoothed_Traj ;

    X_Robot = Current_Position(1) ;
    Y_Robot = Current_Position(2) ;

    NbPoints      = size(Smoothed_Traj, 1) ;
    Cl_Pt_Index   = Closest_Point_Index    ;

    // ---------- Safeguards for track boundaries
    if Cl_Pt_Index < 2 then 
        Cl_Pt_Index = 2 ; 
    elseif Cl_Pt_Index > NbPoints - 1 then 
        Cl_Pt_Index = NbPoints - 1 ; 
    end

    // ============================================================================================
    //                      Projection Logic
    // ============================================================================================

    select Projection_Method

        // ============================================================================================
        //                               Polynomial Fitting (Polyfit from Matlab)
        // ============================================================================================
        case 1 then
        
            // ---------- Local Window
            X_Traj = Smoothed_Traj((Cl_Pt_Index-1):(Cl_Pt_Index+1), 2) ;
            Y_Traj = Smoothed_Traj((Cl_Pt_Index-1):(Cl_Pt_Index+1), 3) ;
            
            // ---------- Local time vector 
            t = [-1 ; 0 ; 1] ;
            
            // ---------- Vandermonde Matrix Inversion
            Vandermonde = [t.^2, t, ones(3, 1)] ;
            
            // ---------- Solving X and Y with the "\" operator, a left matrix division, to avoid manual matrix inversion
            Coeffs_X = Vandermonde \ X_Traj ; // Coeffs_X = [Ax, Bx, Cx]
            Coeffs_Y = Vandermonde \ Y_Traj ; // Coeffs_Y = [Ay, By, Cy]
            
            // ---------- Generate 100 fine points along this polynomial curve
            t_calc = -1 : 0.02 : 1 ; 
            X_calc = Coeffs_X(1)*t_calc.^2 + Coeffs_X(2)*t_calc + Coeffs_X(3) ;
            Y_calc = Coeffs_Y(1)*t_calc.^2 + Coeffs_Y(2)*t_calc + Coeffs_Y(3) ;
            
            // ---------- Find the minimum distance in this virtual fine curve
            Distances = (X_calc - X_Robot).^2 + (Y_calc - Y_Robot).^2 ;
            [Min_Dist, Best_Idx] = min(Distances) ;
            
            t_best = t_calc(Best_Idx) ;
            X_Proj = X_calc(Best_Idx) ;
            Y_Proj = Y_calc(Best_Idx) ;
            
            // ---------- Compute tangent angle using the polynomial derivatives
            dX_dt = 2 * Coeffs_X(1) * t_best + Coeffs_X(2) ;
            dY_dt = 2 * Coeffs_Y(1) * t_best + Coeffs_Y(2) ;
            Theta_Proj = atan(dX_dt, -dY_dt) ; // "-" because of the orientation of our robot
            


        // ============================================================================================
        //                               Geometric Projection
        // ============================================================================================
        case 2 then
            
            // ---------- Identify the closest segment
            P_Prev = [Smoothed_Traj(Cl_Pt_Index - 1, 2) ; Smoothed_Traj(Cl_Pt_Index - 1, 3)] ; // X-1 and Y-1
            P_Curr = [Smoothed_Traj(Cl_Pt_Index, 2)     ; Smoothed_Traj(Cl_Pt_Index, 3)]     ; // X and Y
            P_Next = [Smoothed_Traj(Cl_Pt_Index + 1, 2) ; Smoothed_Traj(Cl_Pt_Index + 1, 3)] ; // X+1 and Y+1
            P_Rob  = [X_Robot ; Y_Robot] ;
            
            // ---------- Distances to neighbors to know which segment to project onto
            Dist_Prev = norm(P_Rob - P_Prev) ;
            Dist_Next = norm(P_Rob - P_Next) ;
            
            if Dist_Next < Dist_Prev then
                A = P_Curr ;
                B = P_Next ;
            else
                A = P_Prev ;
                B = P_Curr ;
            end
            
            // ---------- Vector projection
            AB = B - A ;
            AR = P_Rob - A ;
            
            // Project AR onto AB & Saturation
            Scalar_Projection = (AR(1)*AB(1) + AR(2)*AB(2)) / (AB(1)^2 + AB(2)^2) ; // Scalar_Projection is sigma in the Theory.md
            
            Scalar_Projection = min( 1, Scalar_Projection ) ;
            Scalar_Projection = max( 0, Scalar_Projection ) ;
            
            // ---------- Compute final point and angle
            Point_Proj = A + Scalar_Projection * AB ;
            X_Proj = Point_Proj(1) ;
            Y_Proj = Point_Proj(2) ;
            
            // ---------- Theta_Proj = atan(AB(2), AB(1)) ;
            Theta_Proj = atan(AB(1), -AB(2))  ;
            
    end
    
    // ---------- Output
    
    Desired_Pos_Now = [X_Proj ; Y_Proj ; Theta_Proj] ;

endfunction