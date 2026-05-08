// ==========================================================================================================
//                  STEP 1 : Computation of the future reference
// ==========================================================================================================

// Equation : Delta_Future = arctan(L * c(s + s_H))

function Delta_Future = Future_Reference(Curvature_Future,Wheelbase)
    Delta_Future = atan(Wheelbase * Curvature_Future) ;
endfunction

// ==========================================================================================================
//                  STEP 2 : Computation of the desired response
// ==========================================================================================================

// Equation : Delta_Desired = Delta_Future - Gamma^i * (Delta_Future - Delta_Present)

function Delta_Desired = Desired_Response(Delta_Future, Current_Delta, Prediction_Horizon, Gamma)

    Delta_Desired = zeros(1, Prediction_Horizon) ;
    for i = 1 : Prediction_Horizon
        Delta_Desired(i) = Delta_Future - (Gamma^i) * (Delta_Future - Current_Delta) ;
    end
endfunction
// ==========================================================================================================
//                  STEP 3 : Computation of the free response and the forced response
// ==========================================================================================================
// ----------------------------------------------------- Free Response -----------------------------------------------------
// Equation : Free_Response = C * F^i * X(n)

function Free_Response = Free_Response_Computation(Current_State, System_Matrix, Prediction_Horizon)
    C = [1, 0, 0] ;
    Free_Response = zeros(1, Prediction_Horizon) ;
    for i = 1 : Prediction_Horizon
        Free_Response(i) = C * (System_Matrix^i) * Current_State ;
    end
endfunction

// ----------------------------------------------------- Forced Response -----------------------------------------------------

// Equation : Forced_Response = Sum of (C * F(i-j) * K * Delta_C_B(n+j-1) ), with Delta_C_B(n+j-1) = 1, because we supose a echelon's response

function Forced_Response = Forced_Response_Function(System_Matrix, Input_Matrix, Prediction_Horizon)
    
    C = [1, 0, 0] ; 
    Forced_Response = zeros(1, Prediction_Horizon) ;
    
    for i = 1 : Prediction_Horizon
        Forced_Response_Valors = 0 ;
        for j = 0 : i-1
            Forced_Response_Valors = Forced_Response_Valors + C * (System_Matrix^(i - 1 - j)) * Input_Matrix ;
        end
        Forced_Response(i) = Forced_Response_Valors ;
    end
endfunction

// ==========================================================================================================
//                  STEP 4 : Selection of the structure command for the forced response
// ==========================================================================================================

function Command_Shape = Control_Structure(Shape_Type, Prediction_Horizon)
    // Allow the choosing of the shape for the command*

    // Echelon command ---> 1   => Most simple and common shape.
    // Ramp command    ---> i   => Useful for spiral shape courvature.
    // Parabol command ---> i^2 => Uncomon in robotic, but usefull for hyper dynamics systems.

    select Shape_Type

        case "Echelon" then
            Command_Shape = ones(1, Prediction_Horizon) ; // Vecteur de 1
        case "Ramp" then
            Command_Shape = 1:Prediction_Horizon        ; // Vecteur [1, 2, 3...]
        case "Parabola" then
            Command_Shape = (1:Prediction_Horizon).^2   ; // Vecteur [1, 4, 9...]
    end
endfunction 


// ==========================================================================================================
//                  STEP 5 : Optimize command
// ==========================================================================================================


function Delta_Pred = Optimal_Minimization(Delta_Desired, Free_Response, Forced_Response, Command_Shape)
    
    // Criteria d(n_i) = Delta_Desired(i) - Free_Response(i)
    
    R1 = 0 ;
    R2 = 0 ;
    Lambda = 0.05 ; // <-- FACTEUR DE RÉGULARISATION VITAL

    Prediction_Horizon = length(Delta_Desired) ;
    
    for i = 1 : Prediction_Horizon
        d_i = Delta_Desired(i) - Free_Response(i);
        
        R1 = R1 + (d_i * Forced_Response(i));
        R2 = R2 + (Forced_Response(i)^2);
    end
    
    mu_opt = R1 / (R2);
    Delta_Pred = mu_opt * Command_Shape;
endfunction