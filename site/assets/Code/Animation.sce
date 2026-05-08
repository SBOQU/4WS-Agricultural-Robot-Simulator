// ============================================================================
// FONCTION D'ANIMATION DU VEHICULE (POST-SIMULATION XCOS)
// ============================================================================
function Animate_Xcos_Replay(Traj_Data, X_Out, Y_Out, Theta_Out, F_Steer_Out, R_Steer_Out)
    
    // --- EXPLICATION DES ENTREES ---
    // Traj_Data    : La trajectoire de référence (ex: Smoothed_Traj) [Temps, X, Y]
    // X_Out, Y_Out : Structures générées par les blocs TOWS_c de Xcos pour la position
    // Theta_Out    : Structure du cap du véhicule
    // F_Steer_Out  : Structure de l'angle de braquage Avant (Front_Steering_Angle)
    // R_Steer_Out  : Structure de l'angle de braquage Arrière (Rear_Steering_Angle)

    // ========================================================================
    // 1. IMPORTATION DES PARAMÈTRES PHYSIQUES DU VÉHICULE
    // ========================================================================
    // On récupère directement les variables de ton fichier Parameters.sce
    global Wheelbase Track_Width Wheel_Radius ;    
    diam_roue = Wheel_Radius * 2 ;
    
    // ========================================================================
    // 2. EXTRACTION DES DONNÉES DE SIMULATION
    // ========================================================================
    // Les blocs TOWS_c de Xcos génèrent une structure. Les vraies valeurs 
    // se trouvent dans le sous-champ ".values".
    X_vals = X_Out.values ;
    Y_vals = Y_Out.values ;
    Theta_vals = Theta_Out.values ;
    F_Steer_vals = F_Steer_Out.values ;
    R_Steer_vals = R_Steer_Out.values ;
    
    nb_pts = length(X_vals);

    // ========================================================================
    // 3. PRÉPARATION DE LA FIGURE ET DU DÉCOR
    // ========================================================================
    f = gcf();
    clf();
    f.background = 8; // Fond blanc
    
    // Tracé de la trajectoire de référence (en noir pointillé)
    plot(Traj_Data(:,2), Traj_Data(:,3), 'k--', 'thickness', 2);
    xgrid();
    a = gca();
    a.isoview = "on"; // Force l'échelle 1:1 pour ne pas écraser le dessin du robot
    title("Simulation Xcos");
    
    // ========================================================================
    // 4. INITIALISATION DES OBJETS GRAPHIQUES DU VÉHICULE
    // ========================================================================
    drawlater();
    couleur_tracteur = 5; // Rouge
    
    // Création des lignes vides que l'on va déformer à chaque image
    h_chassis = xpoly([0,0],[0,0], "lines"); e_chassis = gce(); e_chassis.thickness = 2; e_chassis.foreground = couleur_tracteur;
    h_essieu  = xpoly([0,0],[0,0], "lines"); e_essieu  = gce(); e_essieu.thickness  = 2; e_essieu.foreground  = couleur_tracteur;
    h_roueRL  = xpoly([0,0],[0,0], "lines"); e_roueRL  = gce(); e_roueRL.thickness  = 3; e_roueRL.foreground  = couleur_tracteur;
    h_roueRR  = xpoly([0,0],[0,0], "lines"); e_roueRR  = gce(); e_roueRR.thickness  = 3; e_roueRR.foreground  = couleur_tracteur;
    h_roueAV  = xpoly([0,0],[0,0], "lines"); e_roueAV  = gce(); e_roueAV.thickness  = 3; e_roueAV.foreground  = couleur_tracteur;
    h_roueAR  = xpoly([0,0],[0,0], "lines"); e_roueAR  = gce(); e_roueAR.thickness  = 3; e_roueAR.foreground  = 2; // Bleu pour la directrice arrière
    drawnow();

    // GIF_1
    //fichier_gif = "GIF_Simu.gif";
    // 50 est le délai en ms entre les images (ajuste-le si le gif est trop lent/rapide), 0 = boucle infinie
    //idGif = animaGIF(f, fichier_gif, 50, 0);
    // ========================================================================
    // 5. BOUCLE D'ANIMATION TEMPORELLE
    // ========================================================================
    // On saute des points (step=5) pour que l'animation ne soit pas trop lente
    //a.data_bounds = [min(Traj_Data(:,2))-5, min(Traj_Data(:,3))-5; max(Traj_Data(:,2))+5, max(Traj_Data(:,3))+5];
    for i = 1 : 10 : nb_pts
        
        // Variables à l'instant t
        X_t      = X_vals(i);
        Y_t      = Y_vals(i);
        Theta_t  = Theta_vals(i);
        delta_Av = F_Steer_vals(i);
        delta_Ar = R_Steer_vals(i);
        
        // --- A. Géométrie locale (Robot centré sur 0, pointant vers le haut) ---
        x_loc = zeros(1, 12); y_loc = zeros(1, 12);
        
        // Axe central (du train arrière vers le train avant)
        x_loc(1:2) = [0, 0];                                     y_loc(1:2) = [0, Wheelbase];
        // Roue Arrière Gauche (Rear Left)
        x_loc(3:5) = [-Track_Width/2, -Track_Width/2, -Track_Width/2]; y_loc(3:5) = [-diam_roue/2, 0, diam_roue/2];
        // Roue Arrière Droite (Rear Right)
        x_loc(6:8) = [Track_Width/2, Track_Width/2, Track_Width/2];    y_loc(6:8) = [-diam_roue/2, 0, diam_roue/2];
        
        // Roue Avant directrice (Modèle Tricycle)
        x_loc(9)  = diam_roue/2 * sin(delta_Av);    y_loc(9)  = Wheelbase - diam_roue/2 * cos(delta_Av);
        x_loc(10) = -diam_roue/2 * sin(delta_Av);   y_loc(10) = Wheelbase + diam_roue/2 * cos(delta_Av);
        
        // Roue Arrière directrice (Superposée au centre de l'essieu arrière)
        x_loc(11) = diam_roue/2 * sin(delta_Ar);    y_loc(11) = -diam_roue/2 * cos(delta_Ar);
        x_loc(12) = -diam_roue/2 * sin(delta_Ar);   y_loc(12) = diam_roue/2 * cos(delta_Ar);
        
        // --- B. Matrice de Rotation et de Translation globale ---
        // On applique l'angle Theta et on translate aux coordonnées X_t, Y_t
        X_trac = -x_loc * cos(Theta_t) + y_loc * sin(Theta_t) + X_t;
        Y_trac = -y_loc * cos(Theta_t) - x_loc * sin(Theta_t) + Y_t;
        
        // --- C. Rafraîchissement Graphique ---
        drawlater(); // Suspend l'affichage (anti-scintillement)
        
        e_chassis.data = [X_trac(1:2)', Y_trac(1:2)'];
        e_essieu.data  = [X_trac([4,7])', Y_trac([4,7])']; // Ligne reliant les roues arrières
        e_roueRL.data  = [X_trac([3,5])', Y_trac([3,5])'];
        e_roueRR.data  = [X_trac([6,8])', Y_trac([6,8])'];
        e_roueAV.data  = [X_trac(9:10)', Y_trac(9:10)'];
        e_roueAR.data  = [X_trac(11:12)', Y_trac(11:12)'];
        
        // Fenêtre glissante : La caméra suit le véhicule (+/- 5 mètres) --- Vomitif
        a.data_bounds = [X_t - 5, Y_t - 5 ; X_t + 5, Y_t + 5];
        
        drawnow(); // Déclenche l'affichage complet
        //GIF_2 : Capture de l'image actuelle APRES le drawnow()
        //idGif = animaGIF(f, idGif);
        //sleep(2);  // Pause pour rythmer la vitesse d'animation
    end
    // GIF_3 : Finalisation et sauvegarde du fichier
    //(idGif);
    disp("Animation terminée !");
endfunction

// ============================================================================
// COMMANDE DE LANCEMENT (À exécuter APRÈS la fin de la simulation Xcos)
// ============================================================================
// Décommente la ligne ci-dessous dans Scilab une fois que tes variables 
// Sim_X, Sim_Y, etc. sont apparues dans ton Workspace.

// Animate_Xcos_Replay(Smoothed_Traj, Sim_X, Sim_Y, Sim_Theta, Sim_F_Steer, Sim_R_Steer)