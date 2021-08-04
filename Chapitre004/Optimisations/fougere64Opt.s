/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme fougere64.s */
/* dessin de la fougère de Barnsley X11  */
/* voir les exemples de calcul dans Wikipedia */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits
.equ GETTIME,         169    // gettimeofday

.equ NBPOINTS, 400000

/* constantes X11 */
.equ KeyPressed,    2
.equ ButtonPress,   4
.equ MotionNotify,  6
.equ EnterNotify,   7
.equ LeaveNotify,   8
.equ Expose,        12
.equ ClientMessage, 33
.equ KeyPressMask,  1
.equ ButtonPressMask,     4 
.equ ButtonReleaseMask,   8 
.equ ExposureMask,        1<<15
.equ StructureNotifyMask, 1<<17
.equ EnterWindowMask,     1<<4
.equ LeaveWindowMask,     1<<5 
.equ ConfigureNotify,     22

.equ GCForeground,   1<<2
.equ GCBackground,   1<<3
.equ GCLine_width,   1<<4
.equ GCLine_style,   1<<5
.equ GCFont,         1<<14

.equ CWBackPixel,    1<<1
.equ CWBorderPixel,  1<<3
.equ CWEventMask,    1<<11
.equ CWX,            1<<0
.equ CWY,            1<<1
.equ CWWidth,        1<<2
.equ CWHeight,       1<<3
.equ CWBorderWidth,  1<<4
.equ CWSibling,      1<<5 
.equ CWStackMode,    1<<6

/****************************************************/
/* fichier des macros                               */
/****************************************************/
.include "../ficmacros64.inc"

/***********************************/
/* description des structures */
/***********************************/
.include "./defStruct64.inc"


/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

szMessErreur:        .asciz "Serveur X non trouvé.\n"
szMessErrfen:        .asciz "Création fenetre impossible.\n"
szMessErreurGC:      .asciz "Erreur création contexte graphique.\n"

szMessTemps:         .ascii "Durée calculée : "
sSecondes:           .fill 10,1,' '
                     .ascii " s "
sMilliS:             .fill 10,1,' '
                     .ascii " ms "
sMicroS:             .fill 10,1,' '
                     .asciz " µs\n"
             
/*table des couleurs */
szCouleur1: .asciz "green"
szCouleur2: .asciz "pink"    
szCouleur3: .asciz "blue"    
szCouleur4: .asciz "red"
szCouleur5: .asciz "grey"
.align 8
tabCouleur:
        .quad szCouleur1
        .quad szCouleur2
        .quad szCouleur3
        .quad szCouleur4
        .quad szCouleur5
        .equ NBCOULEUR, (. -  tabCouleur) / 8

qGraine:     .quad 123456789            // graine pour génération nombres aléatoires
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
qwDebut:    .skip 16
qwFin:      .skip 16
qDisplay:         .skip 8               // pointeur vers Display
qEcran:           .skip 8               // pointeur vers écran
qGc1:             .skip 8               // pointeur vers contexte graphique 1
qKey:             .skip 8               // valeur touche saisie
stEven:           .skip 400             // structure évenement TODO: revoir cette taille 
qClosest:         .skip XColor_fin      // structure des couleurs
tabPixel:         .skip 8 * NBCOULEUR   // Table valeur des pixels
stXGCValues:      .skip XGC_fin         // structure paramètres GC
stCouleurExacte:  .skip XColor_fin      // structure des couleurs exactes
sBuffer:          .skip 100
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                           // entrée du programme
    adr x0,qOfszMessDebutPgm
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    
    mov x0,#0                  // ouverture du serveur X
    bl XOpenDisplay
    cbz x0,99f                 // pas de serveur X ?

    afficherLib "Serveur X OK "
                               //  Ok retour zone display */
    adr x1,qOfqDisplay
    ldr x2,[x1]
    add x2,x2,x1
    str x0,[x2]                // stockage adresse du DISPLAY
    mov x28,x0                 // mais aussi dans le registre 28
    
    ldr x2,[x0,#Disp_default_screen] // récup adresse de l'écran dans le display
    adr x3,qOfqEcran
    ldr x1,[x3]
    add x1,x1,x3
    str x2,[x1]                // stockage   default_screen

    mov x2,x0
    ldr x0,[x2,#232]           // pointeur de la liste des écrans
                               //zones ecran
    ldr x5,[x0,#+88]           // white pixel
    ldr x3,[x0,#+96]           // black pixel
    ldr x4,[x0,#+56]           // bits par pixel
    ldr x1,[x0,#+16]           // root windows
 
    /* CREATION DE LA FENETRE       */
    mov x0,x28                 //display
    mov x2,#10                 // position X 
    mov x3,#20                 // position Y
    mov x4,700                 // largeur
    mov x5,1200                // hauteur
    mov x6,1                   // largeur bordure
    mov x7,0                   // pixel boerdure = noir
    ldr x8,qGris               // couleur du fond
    str x8,[sp,-16]!           // passé par la pile
    bl XCreateSimpleWindow
    add sp,sp,16               // alignement pile
    cbz x0,98f                 // erreur création ?

    afficherLib "Création OK "
    mov x27,x0                 // save ident fenetre
    
    mov x0,x28
    mov x1,x27
    bl creationGC
    adr x1,qOfqGc1
    ldr x2,[x1]
    add x1,x1,x2
    str x0,[x1]                  // stockage adresse contexte graphique dans zone gc
    mov x26,x0                   // et dans x26
    afficherLib "Création GC OK"
    
    /* affichage de la fenetre */
    mov x0,x28                   // adresse du display
    mov x1,x27                   // ident fenetre
    bl XMapWindow

   bl debutChrono
    mov x0,x28                   // adresse du display
    mov x1,x27                   // adresse fenetre
    mov x2,x26                   // adresse contexte graphique
    bl dessinerFougere
    bl stopChrono
                                // autorisation des saisies
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident de la fenetre
    ldr x2,qSaisieMask          // masque des autorisations
    bl XSelectInput

1:                              // boucle des evenements
    mov x0,x28                  // adresse du display
    adr x1,qOfstEven            // adresse structure evenements
    ldr x2,[x1]
    add x1,x1,x2
    mov x25,x1                  // save adresse structure evenement
    bl XNextEvent
    afficherLib "Evenement"
    
    ldr x0,[x25]                // code évenement
    cmp x0,#KeyPressed          // appui touche ?
    bne 2f
                                 // cas d'une touche
    mov x0,x25
    adr x1,qOfsBuffer            // adresse buffer
    ldr x2,[x1]
    add x1,x1,x2
    mov x2,#255
    adr x3,qOfqKey              // adresse zone clé
    ldr x4,[x3]
    add x3,x3,x4
    mov x4,#0
    bl XLookupString            // recup touche dans buffer
    cmp x0,#1                   // touche caractères ?
    bne 2f

    adr x0,qOfsBuffer           // adresse du buffer
    ldr x2,[x0]
    add x0,x0,x2
    ldrb w0,[x0]                // charge le 1er caractère du buffer
    affreghexa "Touche du buffer"
    cmp w0,#0x71                // caractere q ?
    beq 3f                      // oui -> fin
2:    
    b 1b                        // sinon boucle evenements
    
3:
    mov x0,x28                  // adresse du display
    adr x2,qOfqGc1
    ldr x3,[x2]
    add x2,x2,x3
    ldr x1,[x2]                // adresse du contexte GC1
    bl XFreeGC                 // liberation GC1

    mov x0,x28                 // adresse du display
    mov x1,x27                 // ident fenetre
    bl XDestroyWindow          // destruction de la fenêtre
    
    mov x0,x28                 // adresse du display
    bl XCloseDisplay           // fermeture de la connexion 
    
    adr x0,qOfszMessFinPgm
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    b 100f                     // saut vers fin normale du programme
    
98:                            // erreur creation fenêtre mais ne sert peut être à rien car erreur directe X11
    adr x0,qOfszMessErrfen
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    b 100f
99:                            // erreur car pas de serveur X
    adr x0,qOfszMessErreur
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    b 100f


100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qOfszMessDebutPgm:    .quad szMessDebutPgm - .
qOfszMessFinPgm:      .quad szMessFinPgm - .
qOfszRetourLigne:     .quad szRetourLigne - .
qOfqDisplay:          .quad qDisplay - .
qGris:                .quad 0xF0F0F0F0
qOfszMessErreur:      .quad szMessErreur - .
qOfszMessErrfen:      .quad szMessErrfen - .
qOfstEven:            .quad stEven - .
qOfqEcran:            .quad qEcran - .
qOfqGc1:              .quad qGc1 - .
qOfsBuffer:           .quad sBuffer - .
qOfqKey:              .quad qKey - .
qSaisieMask:          .quad  StructureNotifyMask|ExposureMask|KeyPressMask|ButtonPressMask

/********************************************************************/
/*   Création du contexte graphique GC1                            ***/
/********************************************************************/
/* x0 Display   */
/* x1 fenêtre */
creationGC:
    stp x20,lr,[sp,-16]!        // save  registres
    stp x21,x22,[sp,-16]!       // save  registres
    stp x23,x24,[sp,-16]!       // save  registres
    stp x25,x26,[sp,-16]!       // save  registres
    stp x27,x28,[sp,-16]!       // save  registres
    mov x20,x0                  // adresse du display
    mov x21,x1                  // ident de la fenêtre
                                // preparation des couleurs
    adr x2,qOfqEcran            // structure ecran défaut
    ldr x1,[x2]
    add x1,x1,x2
    ldr x1,[x1]
    bl XDefaultColormap         // charge la table des couleurs associées à l'écran
    cmp x0,#0
    ble 99f                     // erreur acces
    mov x24,x0                  // save  colormap dans x24
    adr x2,qOftabCouleur        // table des noms de couleurs
    ldr x25,[x2]
    add x25,x25,x2
    adr x2,qOfstCouleurExacte
    ldr x22,[x2]
    add x22,x22,x2
    adr x2,qOfiClosest
    ldr x26,[x2]
    add x26,x26,x2
    adr x2,qOftabPixel
    ldr x23,[x2]
    add x23,x23,x2
    mov x27,#0                // compteur de boucle
1:    
    mov x0,x20                // adresse du display
    mov x1,x24                // adresse colormap
    ldr x2,[x25,x27,LSL #3]   // en fonction de l'indice
    mov x3,x22
    mov x4,x26
 
    bl XAllocNamedColor
    cmp x0,#0
    ble 99f                   // erreur acces
    ldr x0,[x22,#XColor_pixel]
    affreghexa codeCouleur
    str x0,[x23,x27,LSL #3]
    add x27,x27,#1
    cmp x27,#NBCOULEUR
    blt 1b

                             // création du contexte graphique
    mov x0,x20               // adresse du display
    mov x1,x21               // adresse fenetre 
    ldr x2,qGcmask1          // identifie les zones a mettre à jour 
    ldr x4,[x23]             // poste 0 table pixel couleur
    adr x3,qOfstXGCValued1
    ldr x5,[x3]
    add x3,x3,x5
    str x4,[x3,#XGC_foreground]  // maj dans la zone de XGCValues
    ldr x4,[x23]                 // poste 0 table pixel couleur
    str x4,[x3,#XGC_background]
    //mov x2,#0
    //mov x3,#0
    bl XCreateGC
    affreghexa GCcreation
    cmp x0,#0
    bne 100f                    //  création OK
99:                             // erreur création GC
    adr x0,qOfszMessErreurGC
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    mov x0,#0
100:
    ldp x27,x28,[sp],16          // restaur des  2 registres
    ldp x25,x26,[sp],16          // restaur des  2 registres
    ldp x23,x24,[sp],16          // restaur des  2 registres
    ldp x21,x22,[sp],16          // restaur des  2 registres
    ldp x20,lr,[sp],16           // restaur des  2 registres
    ret                          // retour adresse lr x30
    
qOftabCouleur:        .quad tabCouleur - .
qOfstCouleurExacte:   .quad stCouleurExacte - .
qOfiClosest:          .quad qClosest - .
qOftabPixel:          .quad tabPixel - .
qGcmask1:             .quad GCForeground|GCBackground
qOfszMessErreurGC:    .quad szMessErreurGC - .
qOfstXGCValued1:      .quad stXGCValues - .
/******************************************************************/
/*     dessin fougère                 */ 
/******************************************************************/
/* x0 contient l adresse du display */
/* x1 l'identifiant de la fenêtre */
/* x2 le contexte graphique */
dessinerFougere:             // INFO: dessinerFougere
    stp x20,lr,[sp,-16]!     // save  registres
    stp x21,x22,[sp,-16]!    // save  registres
    stp x23,x24,[sp,-16]!    // save  registres
    mov x20,x0               // save du display
    mov x21,x1               // ident fenêtre
    mov x22,x2               // contexte graphique
    mov x3,#0                // valeur x départ
    mov x4,#0                // valeur y départ
    ucvtf d0,x3 
    ucvtf d1,x4
    ldr x23,iNbpoints
1:                           // dans la boucle calcul de x3 (position X) et x4 (position Y)
    mov x0,x20               // adresse du display
    mov x1,x21               // ident fenêtre
    mov x2,x22               // contexte graphique
    bl XDrawPoint            // affichage d'un pixel
    mov x0,#100
    bl genererAlea           // génération nombre aléatoire entre 0 et 100
    cmp x0,1
    bgt 2f
                             // cas pour un % des cas
    ldr d0,dZero             // x = 0
    ldr d2,dConst1           // 0,16
    fmul  d1,d1,d2           // * y
    b 10f
2:
    cmp x0,86
    bgt 3f
                            // cas pour 85% des cas
    ldr d2,dConst2          // 0,85
    fmul  d3,d0,d2          // * x
    ldr d2,dConst3          // 0,04
    fmul  d4,d1,d2          // * y
    fadd d3,d3,d4           // nouveau x
    fmul  d4,d0,d2          // x * 0,04
    ldr d2,dConst2          // 0,85
    fmul d1,d1,d2           // y * 0,85
    fsub d1,d1,d4           //   y * 0,85 - x * 0,04
    ldr d2,dConst5          // 1,6
    fadd d1,d1,d2           // nouveau y
    fmov d0,d3              // nouveau x
    b 10f
3:
    mov x6,#93
    cmp x0,x6
    bgt 4f
                            // cas pour 93-86 = 7% des cas
    ldr d2,dConst6          // 0,2
    fmul d3,d0,d2           // * x
    ldr d2,dConst7          // 0,26
    fmul  d4,d1,d2          // * y
    fsub d3,d3,d4           // nouveau x
    ldr d2,dConst8          // 0,23
    fmul  d4,d0,d2          // * x
    ldr d2,dConst9          // 0,22
    fmul  d1,d1,d2          // * y
    fadd  d1,d1,d4
    ldr d2,dConst5          // 1,6
    fadd d1,d1,d2
    fmov d0,d3
    b 10f
4:                         // reste des cas
    ldr d2,dConst10        // 0,15
    fmul  d3,d0,d2         // * x
    ldr d2,dConst11        // 0,28
    fmul  d4,d1,d2         // * y
    fsub d3,d4,d3          // nouveau x = -15x + 28 y
    ldr d2,dConst7         // 0,26
    fmul  d4,d0,d2         // * x
    ldr d2,dConst12        // 0,24
    fmul  d1,d1,d2         // * y
    fadd  d1,d1,d4
    ldr d2,dConst13        // 0,44
    fadd d1,d1,d2          // nouveau y
    fmov d0,d3             // nouveau x

10:
    ldr d5,dCent
    fmul d3,d0,d5             // multiplication de x par 100
    fcvtzs x3,d3              // conversion X  partie entière signée
    add x3,x3,#320            // cadrage X de la fougère
    fmul d4,d1,d5             // multiplication de y par 100
    fcvtzs x4,d4              // conversion Y  partie entière signée
    add x4,x4,#10             // cadrage Y de la fougère

    subs x23,x23,#1           // décremente le nombre de points 
    bge 1b                    // fin ? -> boucle
    
    afficherLib "Fin affichage fougere"
    ldp x23,x24,[sp],16       // restaur des  2 registres
    ldp x21,x22,[sp],16       // restaur des  2 registres
    ldp x20,lr,[sp],16        // restaur des  2 registres
    ret                       // retour adresse lr x30

iNbpoints:     .quad NBPOINTS
dConst1:       .double 0.16
dConst2:       .double 0.85
dConst3:       .double 0.04
dConst5:       .double 1.6
dConst6:       .double 0.2
dConst7:       .double 0.26
dConst8:       .double 0.23
dConst9:       .double 0.22
dConst10:      .double 0.15
dConst11:      .double 0.28
dConst12:      .double 0.24
dConst13:      .double 0.44
dZero:         .double 0.0
dCent:         .double 100.0

/***************************************************/
/*   génération d'un nombre aléatoire              */
/***************************************************/
/* x0 contient la borne superieure */
genererAlea:                // INFO: genererAlea
    stp x1,lr,[sp,-16]!     // save  registres
    stp x2,x3,[sp,-16]!     // save  registres
    mov x3,x0               // valeur maxi
    adr x0,qOfqGraine       // adresse de la graine
    ldr x1,[x0]
    add x0,x0,x1
    ldr x1,[x0]             // charger la graine
    ldr x2,qVal1 
    mul x1,x2,x1
    ldr x2,qVal2
    add x1,x1,x2
    str x1,[x0]             // sauver graine
    udiv x2,x1,x3           // 
    msub x0,x2,x3,x1        // calcul resultat modulo plage
100:
    ldp x2,x3,[sp],16       // restaur des  2 registres
    ldp x1,lr,[sp],16       // restaur des  2 registres
    ret                     // retour adresse lr x30

qVal1:         .quad 0x0019660d   // valeur 1
qVal2:         .quad 0x3c6ef35f   // valeur 2
qOfqGraine:    .quad qGraine - .
/********************************************************/
/* Lancement du chrono                                  */
/********************************************************/
debutChrono:                 // fonction
    stp x0,lr,[sp,-16]!      // save  registres
    stp x1,x8,[sp,-16]!      // save  registres
    adr x0,qOfqwDebut       // zone de reception du temps début
    ldr x1,[x0]
    add x0,x0,x1
    mov x1,0
    mov x8,GETTIME           // appel systeme gettimeofday
    svc 0 
    cmp x0,#0                // verification si l'appel est OK
    bge 100f
                             // affichage erreur
    adr x0,szMessErreurCH
    bl   afficherMess
100:                         // fin standard  de la fonction  */
    ldp x1,x8,[sp],16        // restaur des  2 registres
    ldp x0,lr,[sp],16        // restaur des  2 registres
    ret                      // retour adresse lr x30
szMessErreurCH: .asciz "Erreur debut Chrono rencontrée.\n"
.align 8 
qOfqwDebut:         .quad qwDebut - .
/********************************************************/
/* Affichage du temps      */
stopChrono:                    // fonction
    stp x8,lr,[sp,-16]!        // save  registres
    stp x0,x5,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    adr x0,qOfqwFin           // zone de reception du temps fin
    ldr x1,[x0]
    add x0,x0,x1
    mov x1,0
    mov x8,GETTIME             // appel systeme gettimeofday
    svc 0 
    cmp x0,#0
    blt 99f                    // verification si l'appel est OK
                               // calcul du temps
    adr x0,qOfqwDebut         // temps départ
    ldr x1,[x0]
    add x0,x0,x1
    ldr x2,[x0]                // secondes
    ldr x3,[x0,#8]             // micro secondes
    adr x0,qOfqwFin           // temps arrivée
    ldr x1,[x0]
    add x0,x0,x1
    ldr x4,[x0]                // secondes
    ldr x5,[x0,#8]             // micro secondes
    sub x2,x4,x2               // nombre de secondes ecoulées
    subs x3,x5,x3              // nombre de microsecondes écoulées
    bge 1f
    sub x2,x2,#1               // si negatif on enleve 1 seconde aux secondes
    ldr x4,qSecMicro
    add x3,x3,x4               // et on ajoute 1000000 pour avoir un nb de microsecondes exact
1:
    mov x0,x2                  // conversion des secondes en base 10 pour l'affichage
    adr x1,qOfsBuffer
    ldr x2,[x1]
    add x1,x1,x2
    bl conversion10
    adr x4,qOfsSecondes      // recopie des secondes dans zone affichage
    ldr x2,[x4]
    add x4,x4,x2
2:
    ldrb w0,[x1],1
    cbz w0,3f
    strb w0,[x4],1
    b 2b
3:
    mov x2,1000
    udiv x0,x3,x2             // calcul des millisecones
    msub x3,x0,x2,x3          // reste en micro secondes
    adr x1,qOfsBuffer        // conversion des millisecondes en base 10 pour l'affichage
    ldr x2,[x1]
    add x1,x1,x2
    bl conversion10
    affichageMemoire "Buffer " x1 2
    adr x4,qOfsMilliS        // recopie des millisecondes dans zone affichage
    ldr x2,[x4]
    add x4,x4,x2
4:
    ldrb w0,[x1],1
    cbz w0,5f
    strb w0,[x4],1
    b 4b
5:
    mov x0,x3                 // conversion des microsecondes en base 10 pour l'affichage
    adr x1,qOfsBuffer
    ldr x2,[x1]
    add x1,x1,x2
    bl conversion10
    adr x4,qOfsMicroS        // recopie des micro secondes dans zone affichage
    ldr x2,[x4]
    add x4,x4,x2
6:
    ldrb w0,[x1],1
    cbz w0,7f
    strb w0,[x4],1
    b 6b
7:
    adr x0,qOfszMessTemps
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess         // affichage message dans console
    b 100f
99:                          // erreur rencontrée
    adr x0,szMessErreurCHS
    bl   afficherMess       // appel affichage message
100:                         // fin standard  de la fonction
    ldp x1,x2,[sp],16        // restaur des  2 registres
    ldp x3,x4,[sp],16        // restaur des  2 registres
    ldp x0,x5,[sp],16        // restaur des  2 registres
    ldp x8,lr,[sp],16        // restaur des  2 registres
    ret                      // retour adresse lr x30   
/* variables */
.align 8
qOfqwFin:               .quad qwFin - .
qOfszMessTemps:         .quad szMessTemps - .
qOfsSecondes:           .quad sSecondes - .
qOfsMilliS:             .quad sMilliS - . 
qOfsMicroS:             .quad sMicroS - .
qSecMicro:               .quad 1000000    
szMessErreurCHS: .asciz "Erreur stop Chrono rencontrée.\n"
.align 4
