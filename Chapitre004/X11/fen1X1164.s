/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme fen1X1164.s */
/* création fenetre X11  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
.macro afficherLib str 
    str x0,[sp,-16]!        // save x0
    mrs x0,nzcv             // save du registre d'état  dans x0
    str x0,[sp,-16]!        // puis sur la pile
    adr x0,libaff1\@        // recup adresse libellé passé dans str
    bl afficherMess
    ldr x0,[sp],16
    msr nzcv,x0             // restaur registre d'état
    ldr x0,[sp],16          // restaur x0
    b smacroafficheMess\@   // pour sauter le stockage de la chaine.  
libaff1\@:     .ascii "\str"
               .asciz "\n"
.align 4
smacroafficheMess\@:     
.endm                       // fin de la macro


/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

szMessErreur: .asciz "Serveur X non trouvé.\n"
szMessErrfen: .asciz "Création fenetre impossible.\n"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
qDisplay:   .skip 8               // pointeur vers Display
stEven:     .skip 400             // structure évenement TODO: revoir cette taille 

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
                               //zones ecran
    ldr x5,[x0,#+88]           // white pixel
    ldr x3,[x0,#+96]           // black pixel
    ldr x4,[x0,#+56]           // bits par pixel
    ldr x1,[x0,#+16]           // root windows
 
    /* CREATION DE LA FENETRE       */
    mov x0,x28                 //display
    mov x2,#10                 // position X 
    mov x3,#20                 // position Y
    mov x4,600                 // largeur
    mov x5,400                 // hauteur
    mov x6,0                   // bordure ???
    mov x7,0                   // ?
    ldr x8,qGris               // couleur du fond
    str x8,[sp,-16]!           // passé par la pile
    bl XCreateSimpleWindow
    add sp,sp,16               // alignement pile
    cbz x0,98f                 // erreur création ?

    afficherLib "Création OK "
    mov x27,x0                 // save ident fenetre
    
    /* affichage de la fenetre */
    mov x1,x0                  // ident fenetre
    mov x0,x28                 // adresse du display
    bl XMapWindow
   // mov x0,x28                 // adresse du display  
   // bl XFlush                  // TODO: Voir utilisation
                                // autorisation des saisies
    mov x0,x28                  // adresse du display
    mov x1,x27                  // ident de la fenetre
    mov x2,#5                   // Code 0b101 pour simuler ceci : KeyPressMask|ButtonPressMask
    bl XSelectInput

1:                              // boucle des evenements
    mov x0,x28                  // adresse du display
    adr x1,qOfstEven            // adresse structure evenements
    ldr x2,[x1]
    add x1,x1,x2
    bl XNextEvent
    afficherLib "Evenement"
    b 1b                        // boucle evenements
    
    adr x0,qOfszMessFinPgm
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    b 100f                 // saut vers fin normale du programme
    
98:                        // erreur creation fenêtre mais ne sert peut être à rien car erreur directe X11
    adr x0,qOfszMessErrfen
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    b 100f
99:                        // erreur car pas de serveur X
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
/******************************************************************/
/*     affichage texte avec calcul de la longueur                */ 
/******************************************************************/
/* x0 contient l' adresse du message */
afficherMess:                  // INFO: afficherMess
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    str x8,[sp,-16]!           // save registre
    mov x2,#0                  // compteur taille
1:                             // boucle calcul longueur chaine
    ldrb w1,[x0,x2]            // lecture un octet
    cmp w1,#0                  // fin de chaine si zéro
    beq 2f
    add x2,x2,#1               // incremente compteur
    b 1b
2:
    mov x1,x0                  // adresse du texte
    mov x0,#STDOUT             // sortie Linux standard
    mov x8,#WRITE              // code call system "write"
    svc #0                     // call systeme Linux
    ldr x8,[sp],16             // restaur registre
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30
    
 