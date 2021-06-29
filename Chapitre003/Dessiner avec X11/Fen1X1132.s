/* fenetre X11 avec gestion des evenements assembleur ARM  */
/*  test sur android 32 bits */
/* avec couleurs  */
/*********************************************/
/*constantes */
/********************************************/
.include "../constantesARM.inc"

/******************************************************************/
/*     include des macros                                       */ 
/******************************************************************/
.include "../ficmacros32.inc"

/******************************************************************/
/*     include des structures                                       */ 
/******************************************************************/
.include "../descStruct.inc"

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDebut:    .asciz "Début programme.\n"
szRetourligne:  .asciz  "\n"
szMessErreur:   .asciz "Serveur X non trouvé.\n"
szMessErrfen:   .asciz "Création fenetre impossible.\n"
szMessErreurGC: .asciz "Erreur création contexte graphique.\n"
szLibDW:        .asciz "WM_DELETE_WINDOW"
                .equ LGLIBDW, . - szLibDW  

szTitreFen:    .asciz "Android"

/*table des couleurs */
szCouleur1: .asciz "green"
szCouleur2: .asciz "pink"    
szCouleur3: .asciz "blue"    
szCouleur4: .asciz "red"
szCouleur5: .asciz "grey"
.align 4
tabCouleur:
        .int szCouleur1
        .int szCouleur2
        .int szCouleur3
        .int szCouleur4
        .int szCouleur5
        .equ NBCOULEUR, (. -  tabCouleur) /4

/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
ptDisplay:       .skip 4
ptEcran:         .skip 4
iFenetre:        .skip 4
Key:             .skip 4
gc:              .skip 4
wmDeleteMessage: .skip 400   /* a revoir cette taille */ 
eve:             .skip 400      /* revoir cette taille */

iClosest:         .skip XColor_fin
tabPixel:         .skip 4 * NBCOULEUR
stXGCValues:      .skip XGC_fin
stCouleurExacte:  .skip XColor_fin
sBuffer:          .skip 500 

/**********************************************/
/* -- Code section                            */
/**********************************************/
.text           
.global main                   @ 'main' point d'entrée doit être  global

main:
    adr r0,iAdrszMessDebut
    ldr r1,[r0]
    add r0,r1
    bl afficherMess
                                @ attention r7 sert de compteur
    mov r0,#0
    bl XOpenDisplay             @ ouverture du serveur X
    cmp r0,#0
    beq erreur
    adr r2,iOfptDisplay
    ldr r1,[r2]
    add r1,r2
    str r0,[r1]                  @ stockage adresse du DISPLAY
    mov r6,r0                    @ mais aussi dans le registre 6
                                 @ recup ecran par defaut
    ldr r2,[r0,#Disp_default_screen]
    adrl r3,iOfptEcran
    ldr r1,[r3]
    add r1,r3
    str r2,[r1]                  @ stockage   default_screen
    mov r2,r0
    ldr r0,[r2,#Disp_screens]    @ pointeur de la liste des écrans
                                 @ zones ecran
    ldr r5,[r0,#+48]             @ white pixel
    mov r10,r0
    mov r0,r5
    affreghexa blanc
    mov r0,r10
    ldr r3,[r0,#+52]             @ black pixel
    ldr r4,[r0,#+28]             @ bits par pixel
    ldr r1,[r0,#+8]              @ root windows
                                 @ CREATION DE LA FENETRE
    mov r0,r6                    @ display
    mov r2,#50
    mov r3,#50                   @ position ?
    mov r8,#0                    @ alignement pile
    push {r8}
    ldr r3,iBlanc
    push {r3}                    @ fond
    mov r5,#1
    push {r5}                    @ black pixel
    mov r8,#2                    @ bordure
    push {r8}
    mov r8,#400                  @ hauteur
    push {r8}
    mov r8,#600                  @ largeur 
    push {r8}   
    bl XCreateSimpleWindow
    cmp r0,#0
    beq erreurF
    afficherLib fincreation
    adrl r3,iOfiFenetre
    ldr r1,[r3]
    add r1,r3
    str r0,[r1]                  @ stockage adresse fenetre dans zone w
    mov r9,r0                    @ et aussi dans le registre r9
                                 @ ajout de proprietes de la fenêtre
    mov r0,r6                    @ adresse du display
    mov r1,r9                    @ adresse fenetre
    adrl r2,iOfszTitreFen        @ titre de la fenêtre
    ldr r4,[r2]
    add r2,r4
    mov r3,r2                    @ titre de la fenêtre reduite 
    afficherLib avantappel
    mov r4,#0
    push {r4}          /* TODO à voir */
    push {r4}
    push {r4}
    push {r4}
    bl XSetStandardProperties
    add sp,sp,#16   // pour les 4 push
                                 @ tentative correction erreur fermeture fenetre
    mov r0,r6                    @ adresse du display
    adr r2,iOfszLibDW            @ adresse libellé
    ldr r1,[r2]
    add r1,r2
    mov r2,#1                    @ False  à verifier
    bl XInternAtom
    adr r1,iOfwmDeleteMessage
    ldr r2,[r1]
    add r1,r2
    str r0,[r1]
    mov r2,r1                    @ adresse zone retour precedente
    mov r0,r6                    @ adresse du display
    mov r1,r9                    @ adresse fenetre
    mov r3,#1
    bl XSetWMProtocols
                                 @ creation du contexte graphique
    mov r0,r6                    @ adresse du display
    mov r1,r9                    @ adresse fenetre
    adr r3,iOfstXGCValues
    ldr r4,[r3]
    add r3,r4
    ldr r4,iCouleur
    str r4,[r3,#XGC_background]
    ldr r2,iGcMask
    bl creationGC
    adr r1,iOfgc
    ldr r2,[r1]
    add r1,r2
    str r0,[r1]                  @ stockage adresse contexte graphique dans zone gc
    mov r10,r0                   @ et dans r10
                                 @ affichage de la fenetre
    mov r0,r6                    @ adresse du display
    mov r1,r9                    @ adresse fenetre
    bl XMapWindow
    
    mov r0,r6                    @ adresse du display
    mov r1,r9                    @ adresse fenetre
    mov r2,r10                   @ adresse contexte graphique
    bl dessinerRectangle
    
    mov r0,r6                    @ adresse du display
    bl XFlush                    @ TODO: Voir utilisation
                                 @ autorisation des saisies
    mov r0,r6                    @ adresse du display
    mov r1,r9                    @ adresse de la fenetre
    mov r2,#5                    @ TODO:  revoir pour simuler ceci : KeyPressMask|ButtonPressMask
    bl XSelectInput
    afficherLib avantEVT
1:                               @ boucle des evenements
    mov r0,r6                    @ adresse du display
    adr r1,iOfeve                @ adresse evenements
    ldr r2,[r1]
    add r1,r2
    bl XNextEvent
    adr r0,iOfeve                @ adresse evenements
    ldr r2,[r0]
    add r0,r2

    ldr r0,[r0]
    cmp r0,#KeyPressed
    bne 2f
    
    afficherLib touche
                                 @ cas d'une touche
    adr r1,iOfeve                @ adresse evenements
    ldr r0,[r1]
    add r0,r1

    adr r1,iOfsBuffer
    ldr r2,[r1]
    add r1,r2
    
    mov r2,#255
    adr r3,iOfKey
    ldr r4,[r3]
    add r3,r4
    mov r4,#0
    push {r4}
    bl XLookupString 
    cmp r0,#1                   @ touche caractères
    bne 2f

    adr r0,iOfsBuffer
    ldr r2,[r0]
    add r0,r2
    ldrb r0,[r0]
    cmp r0,#0x71                @ caractere q
    beq 5f
    b 4f
2:    
    cmp r0,#ButtonPress         @ cas d'un bouton souris
    bne 3f
    afficherLib bouton
    adr r1,iOfeve                @ adresse evenements
    ldr r0,[r1]
    add r0,r1
    ldr r1,[r0,#+32]            @ position X
    ldr r2,[r0,#+36]            @ position Y
3:
    cmp r0,#ClientMessage       @ cas pour fermeture fenetre sans erreur
    bne 4f
    adr r1,iOfeve               @ adresse evenements
    ldr r0,[r1]
    add r0,r1
    
    ldr r1,[r0,#+28]            @ position code message
    adr r2,iOfwmDeleteMessage
    ldr r3,[r2]
    add r2,r3
    ldr r2,[r2]   
    cmp r1,r2
    bne 4f
    add r7,r7,#1                @ comptage fermeture
    cmp r7,#1
    bgt 5f                      @ fin du programme
4:    
    b 1b
5:    
 
    b 100f
erreurF:                        @ erreur création fenêtre
    adr r0,iOfszMessErrfen
    ldr r1,[r0]
    add r0,r1
    bl afficherMess
    b 100f
erreur:                         @ erreur serveur X
    adr r0,iOfszMessErreur
    ldr r1,[r0]
    add r0,r1
    bl afficherMess
100:                            @ fin de programme standard
    mov r0,#0                   @ code retour
    mov r7, #EXIT
    svc 0 
iAdrszMessDebut:  .int szMessDebut - .
iOfszMessErreur:  .int szMessErreur - .
iOfszMessErrfen:  .int szMessErrfen - .
iOfeve:           .int eve - .
iOfptDisplay:     .int ptDisplay - .
iOfptEcran:       .int ptEcran - .
iOfiFenetre:      .int iFenetre - .
iOfszLibDW:       .int szLibDW - .
iOfwmDeleteMessage: .int wmDeleteMessage - .
iOfgc:             .int gc - .
iOfsBuffer:         .int sBuffer - .
iOfKey:             .int Key - .
iOfszTitreFen:      .int szTitreFen - .
iOfstXGCValues:     .int stXGCValues - .
iGris:              .int 0xFFE0E0E0
iBlanc:             .int 0xFFFFFFFF
iGcMask:            .int GCBackground
iCouleur:           .int 0x00FF
/******************************************************************/
/*     dessin rectangle                  */ 
/******************************************************************/
/* r0 contient l adresse du display */
/* r1 l'identifiant de la fenêtre */
/* r2 le contexte graphique */
dessinerRectangle:
    push {r1,r3,r4,lr}      @ save des registres
    mov r3,#180             @ position x
    sub sp,sp,#4
    mov r4,#250             @ position y1 
    push {r4}               @ sur la pile
    mov r4,#250             @ position x1
    push {r4}               @ sur la pile
    mov r4,#120             @ position y
    push {r4}
    bl XFillRectangle
    add sp,sp,#16           @ alignement pile pour les 4 push
    pop {r1,r3,r4,lr}       @ restaur des registres
    bx lr
/********************************************************************/
/*   Création des contextes graphiques                            ***/
/********************************************************************/
/* r0 Display   */
/* r1 fenêtre */
creationGC:
    push {r1-r11,lr}          @ save des registres
    mov r7,r0
    mov r4,r1
                               @ preparation des couleurs
    adr r2,iOfptEcran
    ldr r1,[r2]
    add r1,r2
    ldr r1,[r1]
    bl XDefaultColormap
    cmp r0,#0
    ble 99f                    @ erreur acces
    mov r6,r0                  @ save  colormap dans r6
    adr r2,iOftabCouleur       @ table des noms de couleurs
    ldr r8,[r2]
    add r8,r2
    adr r2,iOfstCouleurExacte
    ldr r9,[r2]
    add r9,r2
    adr r2,iOfiClosest
    ldr r10,[r2]
    add r10,r2
    adr r2,ioftabPixel
    ldr r11,[r2]
    add r11,r2
    mov r5,#0               @ compteur de boucle
1:    
    mov r0,r7               @ adresse du display
    mov r1,r6               @ adresse colormap
    ldr r2,[r8,r5,LSL #2]   @ en fonction de l'indice
    mov r3,r9
    push {r10}
    push {r10}
    bl XAllocNamedColor
    add sp,sp,#8            @ pour les 2 push
    cmp r0,#0
    ble 99f                 @ erreur acces
    ldr r0,[r9,#XColor_pixel]
       affreghexa codeCouleur
    str r0,[r11,r5,LSL #2]
    add r5,r5,#1
    cmp r5,#NBCOULEUR
    blt 1b

                            @ création du premier contexte graphique
    mov r0,r7               @ adresse du display
    mov r1,r4               @ adresse fenetre 
    ldr r2,iGcmask1         @ identifie les zones a mettre à jour 
    ldr r4,[r11,#16]        @ poste 5 table pixel couleur
    adr r3,iOfstXGCValues
    ldr r5,[r3]
    add r3,r5
    str r4,[r3,#XGC_foreground]        @ maj dans la zone de XGCValues
    ldr r4,[r11]          @ poste 0 table pixel couleur
    str r4,[r3,#XGC_background]
    bl XCreateGC
    affreghexa GCcreation
    cmp r0,#0
    bne 100f                    @  création OK
99:                             @ erreur cr&ation GC
    adr r0,iOfszMessErreurGC
    ldr r1,[r0]
    add r0,r1
    bl afficherMess
    mov r0,#0
100:
    pop {r1-r11,lr}            @ restaur des registres
    bx lr
    
iOftabCouleur:        .int tabCouleur - .
iOfstCouleurExacte:   .int stCouleurExacte - .
iOfiClosest:          .int iClosest - .
ioftabPixel:          .int tabPixel - .
iGcmask1:             .int GCForeground|GCBackground
iOfszMessErreurGC:    .int szMessErreurGC - .

