function Smoothed_Traj = Path_Filter(Traj)

    // ---------- Extraction of the starting points

    X0 = Traj(1,2);
    Y0 = Traj(1,3);
    
    // ---------- Creation of a Butterworth filter

    Butterworth_Filter = iir(1, 'lp', 'butt', 0.0125, [0, 0]);  
    // 1 : Defines the filter order, where a value of 1 creates the simplest and smoothest mathematical curve without adding too much delay.
    // lp : Stands for "low-pass", meaning it allows smooth, slow movements (the track's shape) to pass while blocking sudden, jerky noises.
    // butt : Selects the Butterworth filter design, which is famous for keeping the signal perfectly flat without creating artificial waves.
    // 0.0125 : Sets the normalized cutoff frequency, determining the exact threshold where the smoothing starts.
    // [0, 0] : Defines the ripple tolerance in the passband and stopband, set to zero here because a Butterworth filter naturally has no ripples.
    

    // ---------- Center the trajectory on (0,0)

    X = Traj(:,2) - X0;
    Y = Traj(:,3) - Y0;
    
    // ---------- Prepare the output matrix

    Smoothed_Traj = zeros(size(Traj,1), size(Traj,2));                 // Preallocation of memories and construction of the table by extraction of the 2 dimension of 'Traj'
    Smoothed_Traj(:,1) = Traj(:,1);                                    // Extraction of the time stamp locating in the 1st column
    
    // ---------- Apply the filter and add the initial offset back

    Smoothed_Traj(:,2) = flts(X', Butterworth_Filter)' + X0;          // flts (Filter Time Series) applies the previously designed mathematical filter to our actual sequence of data points in order to physically smooth out the trajectory.
    Smoothed_Traj(:,3) = flts(Y', Butterworth_Filter)' + Y0;
    
endfunction