/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme fen1X1164.s */
/* création fenetre X11 + dessin pixel ligne rectangle et bouton */

/************************************/
/* Constantes                       */
/************************************/
.equ FALSE, 0
.equ TRUE,  1
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

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
szMessErrGcBT:       .asciz "Création contexte graphique Bouton impossible.\n"
szMessErrbt:         .asciz "Création bouton impossible.\n"
szMessErrGc:         .asciz "Création contexte graphique impossible.\n"
szMessErrPol:        .asciz "Chargement police impossible.\n"

szTexteAff:          .asciz "Dessin d'un rectangle"
                     .equ LGTEXTEAFF, . -  szTexteAff

szTitreBouton:       .asciz "Appuyez"
                     .equ LGTITREBOUTON,  . - szTitreBouton
                  
szTexteAppui:        .asciz "Vous avez appuyé sur le bouton."
                     .equ LGTEXTEAPPUI, . - szTexteAppui
                  

szNomPolice:      .asciz  "-*-helvetica-bold-*-normal-*-16-*"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
qKey:           .skip 8               // valeur de la touche
qDisplay:       .skip 8               // pointeur vers Display
stEven:         .skip 400             // structure évenement TODO: revoir cette taille 
qGC1:           .skip 8               // pointeur vers contexte graphique 1
qGC2:           .skip 8               // pointeur vers contexte graphique 2
qPolice:        .skip 8               // ident police caractères
stBouton1:      .skip BT_fin          // structure Bouton
.align 8
stXGCValues:    .skip XGC_fin         // structure paramètres X
.align 8
stAttrs:        .skip Att_fin         // structure attributs fenêtre
sBuffer:        .skip 500
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
    
    afficherLib "Debut "
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

    mov x2,x0
    ldr x0,[x2,#232]           // pointeur de la liste des écrans
                               // zones ecran
    ldr x5,[x0,#+88]           // white pixel
    ldr x3,[x0,#+96]           // black pixel
    ldr x4,[x0,#+56]           // bits par pixel
    ldr x1,[x0,#+16]           // root windows
 
    /* CREATION DE LA FENETRE       */
    mov x0,x28                 // display
    mov x2,#10                 // position X 
    mov x3,#20                 // position Y
    mov x4,600                 // largeur
    mov x5,400                 // hauteur
    mov x6,2                   // largeur bordure
    mov x7,0                   // couleur bordure = noir
    ldr x8,qGris               // couleur du fond
    str x8,[sp,-16]!           // passé par la pile
    bl XCreateSimpleWindow
    add sp,sp,16               // alignement pile
    cbz x0,98f                 // erreur création ?

    afficherLib "Création OK "
    mov x27,x0                 // save ident fenetre
    
    mov x0,x28                 // adresse du display
    mov x1,x27                 // ident fenetre
    bl creationGC              // création des Contexte Graphiques
    cbz x0,98f                 // erreur création ?
    
    /* affichage de la fenetre */
    mov x0,x28                 // adresse du display
    mov x1,x27                  // ident fenetre
    bl XMapWindow
    
    mov x0,x28                 // adresse du display
    mov x1,x27                 // ident fenetre
    adr x2,qOfqGC1             // adresse contexte graphique
    ldr x3,[x2]
    add x2,x2,x3
    ldr x2,[x2]
    bl dessinrectangle
    
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident fenetre
    bl ecrireTextePolice
    
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident fenetre
    bl dessinerPoint
    
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident fenetre
    bl dessinerLigne
    
                                // création bouton
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident fenetre
    mov x2,200                  // position X
    mov x3,300                  // position Y
    mov x4,100                  // largeur
    mov x5,50                   // hauteur
    adr x6,qOfstBouton1
    ldr x7,[x6]
    add x6,x6,x7
    adr x7,qOfszTitreBouton      // adresse du titre du bouton
    ldr x8,[x7]
    add x7,x7,x8
    mov x8,LGTITREBOUTON         // longueur du texte
    bl creationBouton

                                // autorisation des saisies
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident de la fenetre
    ldr x2,qSaisieMask          // Code autorisation saisies
    bl XSelectInput
    
boucleevt:                      // boucle des evenements
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident de la fenetre
    bl gestionevenements
    cbz x0,boucleevt            // si zero on boucle sinon on termine

                                // liberation des ressources
    mov x0,x28                  // adresse du display
    adr x2,qOfqGC1              // adresse pointeur adresse contexte graphique 1
    ldr x3,[x2]
    add x2,x2,x3
    ldr x1,[x2]                 // adresse du contexte
    bl XFreeGC                  // liberation GC1
    mov x0,x28                  // adresse du display
    adr x2,qOfqGC2
    ldr x3,[x2]
    add x2,x2,x3
    ldr x1,[x2]                // adresse du contexte GC2
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
    mov x0,#0                   // code retour OK
    b 100f                      // saut vers fin normale du programme
    
98:                             // erreur creation fenêtre mais ne sert peut être à rien car erreur directe X11
    adr x0,qOfszMessErrfen
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    mov x0,-1
    b 100f
99:                              // erreur car pas de serveur X
    adr x0,qOfszMessErreur
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    mov x0,-1
    b 100f

100:                            // fin standard du programme
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
qOfstBouton1:         .quad stBouton1 - .
qOfszTitreBouton:     .quad szTitreBouton - .
qSaisieMask:          .quad  StructureNotifyMask|ExposureMask|KeyPressMask|ButtonPressMask
/********************************************************************/
/*  Gestion des évenements d une fenetre                          ***/
/********************************************************************/
/* x0  contient le Display */
/* x1  contient l'ident de la fenêtre */
gestionevenements:
    stp x21,lr,[sp,-16]!        // save  registres
    stp x19,x20,[sp,-16]!
    mov x20,x0                  // save adresse du display
    mov x19,x1                  // save ident fenetre
    adr x1,qOfstEven            // adresse structure evenements
    ldr x2,[x1]
    add x1,x1,x2
    mov x21,x1                  // save adresse structure
    bl XNextEvent
    //afficherLib "Evenement"
    ldr x0,[x21,#+XAny_type]
    cmp x0,#KeyPressed          // cas d'une touche
    beq touche
    cmp x0,#ButtonPress         // cas d'un bouton souris
    beq bouton

    cmp x0,#Expose              // affichage fenêtre
    beq evtexpose
    cmp x0,#EnterNotify         // la souris passe sur le bouton
    beq evtenter
    cmp x0,#LeaveNotify         // la souris sort du bouton
    beq evtleave
    /* autre evenement à  traiter */
    b suiteBoucleEvt
/************************************************/    
touche:                        // appui sur une touche
    mov x0,x21                 // adresse structure evenement
    //afficherLib Touche
    adr x1,qOfsBuffer
    ldr x2,[x1]
    add x1,x1,x2
    mov x22,x1                 // save adresse buffer
    mov x2,#255 
    adr x3,qOfqKey
    ldr x4,[x3]
    add x3,x3,x4
    mov x4,#0
    bl XLookupString 
    cmp x0,#1                 // touche caractères
    bne autretouche

    ldrb w0,[x22]
    affreghexa touche1
    cmp w0,#0x71              // caractere q (pour quitter)
    beq finBoucleEve          // fin du programme
autretouche:    
    b suiteBoucleEvt
/***************************************/
evtexpose:                    // modification fenetre
    mov x0,x20                // adresse du display
    bl boutonExpose
    b suiteBoucleEvt
/*******************************************/
bouton:    
    mov x0,x20         // adresse du display
    mov x2,x21         // adresse structure evenement
    mov x1,x19         // ident fenêtre
    /* TODO il faut determiner le bouton et appeler la fonction correcte */
    bl boutonAppel
    b suiteBoucleEvt

/***************************************/
evtenter:                // passage de la souris sur le bouton */
    mov x0,x21
    bl boutonEnter
    b suiteBoucleEvt
/***************************************/    
evtleave:                // sortie de la souris du bouton */
    mov x0,x21
    bl boutonLeave
    b suiteBoucleEvt    
    
/***************************************/    
suiteBoucleEvt:                // suite de la boucle des evenements */
    mov  x0,#0
    ldp x19,x20,[sp],16
    ldp x21,lr,[sp],16          // restaur des  2 registres 
    ret                         // retour adresse lr x30
 
/**************************************************/    
finBoucleEve:                   // Fin boucle des évenements de la fenêtre
    mov  x0,#1
    ldp x19,x20,[sp],16
    ldp x21,lr,[sp],16          // restaur des  2 registres
    ret                         // retour adresse lr x30  
qOfqKey:       .quad qKey - .
qOfsBuffer:    .quad sBuffer - .

/********************************************************************/
/*   Création des contextes graphiques                            ***/
/********************************************************************/
/* x0 adresse du display */
/* x1 identification de la fenêtre */
creationGC:                     // INFO: creationGC
    stp x20,lr,[sp,-16]!        // save  registres
    str x21,[sp,-16]! 
    mov x20,x0                  // save du display
    mov x21,x1                  // save fenetre
                                //  creation du premier contexte graphique
    mov x2,#0                   // le plus simple
    mov x3,#0
    bl XCreateGC
    cbz x0,99f                  // erreur création
    adr x1,qOfqGC1
    ldr x2,[x1]
    add x1,x1,x2
    str x0,[x1]                 // stockage adresse contexte graphique dans zone gc

    afficherLib "Creation GC1 OK"
                                // chargement police de caractères */
    mov x0,x20                  // adresse du display
    adr x1,qOfszNomPolice       // nom de la police 
    ldr x2,[x1]
    add x1,x1,x2
    bl XLoadQueryFont
    cbz x0,98f                  // police non trouvée
    adr x1,qOfqPolice
    ldr x2,[x1]
    add x1,x1,x2
    str x0,[x1]                 // stockage de la police
    afficherLib "Recup Police OK"
                                //creation  autre contexte graphique
    mov x4,x0                   // recup police
    mov x0,x20                  // adresse du display
    mov x1,x21                  // adresse fenetre
    ldr x2,qGcmask              // identifie les zones a mettre à jour
    ldr x4,[x4,#+XFontST_fid]   // info dans adresse police + 4
    adr x3,qOfstXGCValues       // la zone complete est passée en paramètre
    ldr x5,[x3]
    add x3,x3,x5
    str x4,[x3,#XGC_font]       // maj dans la zone de XGCValues
    ldr x4,qRouge               // Couleur du texte du contexte graphique
    str x4,[x3,#XGC_foreground] // maj dans la zone de XGCValues

    bl XCreateGC
    cbz x0,99f                   // erreur ?
    adr x1,qOfqGC2
    ldr x2,[x1]
    add x1,x1,x2
    str x0,[x1]                 //stockage adresse contexte graphique dans zone gc2
                                // tout est ok
    b 100f
98:                             // erreur chargement police
    adr x0,qOfszMessErrPol
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    mov x0,#0
    b 100f
99:                            // erreur création gc
    adr x0,qOfszMessErrGc
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    mov x0,#0
    b 100f
100:    
    ldr x21,[sp],16 
    ldp x20,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30
.align 8
qOfqGC1:         .quad qGC1 - .
qOfqGC2:         .quad qGC2 - .
qOfqPolice:      .quad qPolice - .
qOfstXGCValues:  .quad stXGCValues - .
qOfszNomPolice:  .quad szNomPolice - . 
qOfszMessErrGc:  .quad szMessErrGc - .
qOfszMessErrPol: .quad szMessErrPol - .
qGcmask:         .quad GCFont|GCForeground
qRouge:          .quad 0xFFFF0000
/********************************************************************/
/*   Dessin d'un rectangle                                        ***/
/********************************************************************/
/* x0 adresse du display */
/* x1 identification de la fenêtre */
/* x2 GC1 */
dessinrectangle:          // INFO: dessinrectangle
    stp x0,lr,[sp,-16]!   // save  registres
    mov x3,#100           // position x 
    mov x4,#50            // position y
    mov x5,#150           // position x1
    mov x6,#150           // position y1
    bl XFillRectangle
    ldp x0,lr,[sp],16     // restaur des  2 registres
    ret                   // retour adresse lr x30
/******************************************************************/
/*     Ecriture de texte avec une police differente              */ 
/******************************************************************/
/* x0 adresse du display */
/* x1 identification de la fenêtre */
ecrireTextePolice:           // INFO: ecrireTextePolice
    stp x0,lr,[sp,-16]!      // save  registres
    adr x5,qOfszTexteAff
    ldr x2,[x5]
    add x5,x5,x2             // adresse du texte à afficher
    adr x2,qOfqGC2
    ldr x3,[x2]
    add x2,x2,x3
    ldr x2,[x2]              // adresse du contexte graphique
    mov x3,#40               // position x
    mov x4,#20               // position y
    mov x6,#LGTEXTEAFF  - 1  // longueur de la chaine à ecrire
    bl XDrawString
    ldp x0,lr,[sp],16        // restaur des  2 registres
    ret                      // retour adresse lr x30
.align 8
qOfszTexteAff:        .quad szTexteAff - .
/******************************************************************/
/*     Affichage d'un pixel                                       */ 
/******************************************************************/
/* x0 adresse du display */
/* x1 identification de la fenêtre */
dessinerPoint:             // INFO: dessinerPoint
    stp x0,lr,[sp,-16]!    // save  registres
    adr x2,qOfqGC1
    ldr x3,[x2]
    add x2,x2,x3
    ldr x2,[x2]            // adresse du contexte graphique
    mov x3,#10             // position x
    mov x4,#10             // position y
    bl XDrawPoint
    ldp x0,lr,[sp],16      // restaur des  2 registres
    ret                    // retour adresse lr x30
/******************************************************************/
/*     Dessin d'une ligne avec le contexte standard               */ 
/******************************************************************/
/* x0 adresse du display */
/* x1 identification de la fenêtre */
dessinerLigne:             // INFO: dessinerLigne
    stp x0,lr,[sp,-16]!    // save  registres
    adr x2,qOfqGC1
    ldr x3,[x2]
    add x2,x2,x3
    ldr x2,[x2]            // adresse du contexte graphique
    mov x3,#10             // position x
    mov x4,#250            // position y
    mov x5,#300            // position x1
    mov x6,#250            // position y1
    bl XDrawLine
    ldp x0,lr,[sp],16      // restaur des  2 registres
    ret                    // retour adresse lr x30
/********************************************************************/
/*   Creation bouton                                        ***/
/********************************************************************/
/* x0 adresse du display */
/* x1 identification de la fenêtre */
/*  x2 x x3 y x4 largeur x5 hauteur x6 adresse structure bouton */
/* x7 adresse du texte du bouton et x8 longueur du texte  */
creationBouton:                  // INFO: creationBouton
    stp x19,lr,[sp,-16]!         // save  registres
    stp x20,x21,[sp,-16]!        // save  registres
    str x22,[sp,-16]!
    mov x20,x0
    mov x19,x1
    mov x21,x6
    afficherLib debutBouton
    str x7,[x21,#+BT_texte]     // texte du bouton
    str x8,[x21,#BT_texte_long] // longueur du texte
    /* CREATION DE LA FENETRE BOUTON */
    str x4,[x21,#+BT_width]     // largeur
    str x5,[x21,#+BT_height]    // hauteur
    mov x6,2                    // bordure ???
    ldr x7,qGris2               // couleur de la bordure
    str x7,[x21,#+BT_border]
    ldr x8,qBlanc               // couleur du fond
    str x8,[x21,#+BT_background]
    str x8,[sp,-16]!            // passé par la pile  
    bl XCreateSimpleWindow
    add sp,sp,#16               // alignement pile
    cbz x0,99f                  // erreur ?

                                // alimentation donnees du bouton
    str x0,[x21,#+BT_adresse]
    mov x22,x0                  // save adresse du bouton pour utilisation fonction suivante
    adr x0,boutonAppel
    str x0,[x21,#+BT_release]   // fonction a appeler
    str xzr,[x21,#+BT_cbdata]   // pas de donnees complementaires
                                // autorisation des saisies */
    mov x0,x20                  // adresse du display
    mov x1,x22
    ldr x2,qBoutonMask
    bl XSelectInput
    
                                //  creation du contexte graphique du bouton
    mov x0,x20                  // adresse du display
    mov x1,x22                  // adresse du bouton
    mov x2,#0                   // le plus simple possible
    mov x3,#0
    bl XCreateGC
    cbz x0,98f 
    str x0,[x21,#+BT_GC]        // stockage contexte graphique
                                // affichage du bouton
    mov x0,x20                  // adresse du display
    mov x1,x22                  // adresse du bouton
    bl XMapWindow
    
    b 100f
98:                             // erreur création GC bouton
    adr x0,qOfszMessErrGcBT
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    b 100f
99:                             // erreur creation bouton
    ldr x0,qOfszMessErrbt
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    
100:
    ldr x22,[sp],16          // restaur des  2 registres
    ldp x20,x21,[sp],16      // restaur des  2 registres
    ldp x19,lr,[sp],16       // restaur des  2 registres
    ret                      // retour adresse lr x30
.align 8
qBlanc:            .quad 0xFFFFFF
qGris1:            .quad 0xFFE0E0E0
qGris2:            .quad 0xFFA0A0A0
qBoutonMask :      .quad ButtonPressMask|ButtonReleaseMask|StructureNotifyMask|ExposureMask|LeaveWindowMask|EnterWindowMask
qOfszMessErrGcBT:  .quad szMessErrGcBT - .
qOfszMessErrbt:    .quad szMessErrbt - .
/******************************************************************/
/*       Affichage du titre du bouton                             */    
/******************************************************************/
/* x0 adresse du display */ 
boutonExpose:                    // INFO: boutonExpose
    stp x19,lr,[sp,-16]!         // save  registres
    afficherLib boutonExpose
    adr x3,qOfstBouton1          // structure du bouton
    ldr x4,[x3]
    add x3,x3,x4
    ldr x1,[x3,#+BT_adresse]     // adresse du bouton
    ldr x2,[x3,#+BT_GC]          // adresse du contexte graphique
    mov x3,#30                   // position x
    mov x4,#30                   // position y
    adr x5,qOfszTitreBouton
    ldr x6,[x5]
    add x5,x5,x6
    mov x6,#LGTITREBOUTON  - 1   // longueur de la chaine a ecrire
    bl XDrawString
    ldp x19,lr,[sp],16           // restaur des  2 registres
    ret                          // retour adresse lr x30
/******************************************************************/
/*    fonction appelee lors de l'appui sur le bouton              */    
/******************************************************************/
/* x0 adresse du display */
/* x1 ident de la fenêtre */
/* x2 doit contenir l'adresse de l'evenement */
boutonAppel:                    // INFO: boutonAppel
    stp x0,lr,[sp,-16]!         // save  registres
    //afficherLib AppuiBouton
    adr x3,qOfstBouton1         // structure du bouton
    ldr x4,[x3]
    add x3,x3,x4
    ldr x4,[x3,#+BT_adresse]    // ident du bouton
    ldr x2,[x2,#+XAny_window]   // ident de la fenêtre sur laquel a lieu l'évenement */
    cmp x4,x2                   // le même ?
    bne 100f                    // non
                                // affichage du texte  */
    adr x2,qOfqGC1              // adresse du contexte graphique
    ldr x3,[x2]
    add x2,x2,x3
    ldr x2,[x2]
    mov x3,#100                 // position x
    mov x4,#280                 // position y
    adr x5,qOfszTexteAppui
    ldr x6,[x5]
    add x5,x5,x6
    mov x6,#LGTEXTEAPPUI  - 1   // longueur de la chaine à écrire
    bl XDrawString
100:
    ldp x0,lr,[sp],16      // restaur des  2 registres
    ret                    // retour adresse lr x30
.align 8
qOfszTexteAppui:      .quad szTexteAppui - .
/******************************************************************/
/*     Modification du bouton si la souris est dessus             */                                   
/******************************************************************/
/* x0 doit contenir l'adresse de l'evenement */
boutonEnter:                            // INFO: boutonenter
    stp x19,lr,[sp,-16]!                // save  registres
    str x20,[sp,-16]!                   // save  registres
    //afficherLib enterBouton
    adr x19,qOfstBouton1                // structure du bouton
    ldr x4,[x19]
    add x19,x19,x4
    adr x3,qOfstAttrs                   // structure des attributs
    ldr x5,[x3]
    add x3,x3,x5
    ldr x1,[x19,#+BT_background]        // inversion du fond
    str x1,[x3,#+Att_border_pixel]
    ldr x1,[x19,#+BT_border]            //  et de la bordure
    str x1,[x3,#+Att_background_pixel]
    mov x20,x0                          // pointeur vers evenement
    ldr x0,[x20,#+XAny_display]
    ldr x1,[x20,#+XAny_window]
    ldr x2,qAttrsMask                   // et x3 contient l'adresse structure des attributs
    bl XChangeWindowAttributes          // changement des attributs

    ldr x0,[x20,#+XAny_display]
    ldr x1,[x20,#+XAny_window]
    mov x2,#0                           // position X
    mov x3,#0                           // position Y
    ldr x4,[x19,#+BT_width]             // largeur
    ldr x5,[x19,#+BT_height]            // hauteur
    mov x6,TRUE
    bl XClearArea                       // redessin du bouton
    ldr x20,[sp],16                     // restaur des  2 registres
    ldp x19,lr,[sp],16                  // restaur des  2 registres
    ret                                 // retour adresse lr x30
.align 8
qOfstAttrs:        .quad stAttrs - .
qAttrsMask:        .quad CWBackPixel|CWBorderPixel
/******************************************************************/
/*     Modification du bouton si la souris est dessus             */                                   
/******************************************************************/
/* x0 doit contenir l'adresse de l'evenement */
boutonLeave:                            // INFO: boutonLeave
    stp x19,lr,[sp,-16]!                // save  registres
    str x20,[sp,-16]!                   // save  registres
    //afficherLib boutonLeave
    adr x19,qOfstBouton1                // structure du bouton
    ldr x4,[x19]
    add x19,x19,x4
    adr x3,qOfstAttrs                   // structure des attributs
    ldr x5,[x3]
    add x3,x3,x5
    ldr x1,[x19,#+BT_border]            //  remise à niveau de la bordure
    str x1,[x3,#+Att_border_pixel]
    ldr x1,[x19,#+BT_background]        // et du fond
    str x1,[x3,#+Att_background_pixel]
    mov x20,x0                          // pointeur vers evenement
    ldr x0,[x20,#+XAny_display]
    ldr x1,[x20,#+XAny_window]
    ldr x2,qAttrsMask                   // et x3 contient l'adresse structure des attributs
    bl XChangeWindowAttributes          // changement des attributs

    ldr x0,[x20,#+XAny_display]
    ldr x1,[x20,#+XAny_window]
    mov x2,#0                           // position X
    mov x3,#0                           // position Y
    ldr x4,[x19,#+BT_width]             // largeur
    ldr x5,[x19,#+BT_height]            // hauteur
    mov x6,TRUE
    bl XClearArea                       // redessin du bouton
    ldr x20,[sp],16                     // restaur des  2 registres
    ldp x19,lr,[sp],16                  // restaur des  2 registres
    ret                                 // retour adresse lr x30
    