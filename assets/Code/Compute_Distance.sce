function d = Compute_Distance(Point_A, Point_B)

    // ============================================================================================
    //                      Euclidean Distance Computation
    // ============================================================================================
    // Point_A and Point_B must be arrays of at least 2 elements [X ; Y]

    X_Diff = Point_B(1) - Point_A(1) ;
    Y_Diff = Point_B(2) - Point_A(2) ;

    d = sqrt(X_Diff^2 + Y_Diff^2) ;

endfunction