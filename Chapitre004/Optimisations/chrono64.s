/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme squel64.s */
/* squelette programme 64 bits  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

.equ GETTIME,         169    // gettimeofday
.equ TAILLEBUFFER,    100
/****************************************************/
/* fichier des macros                               */
/****************************************************/
.include "../ficmacros64.inc"


/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

szMessTemps: .ascii "Durée calculée : "
sSecondes: .fill 10,1,' '
             .ascii " s "
sMilliS:     .fill 10,1,' '
             .ascii " ms "
sMicroS:   .fill 10,1,' '
             .asciz " µs\n"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
qwDebut:    .skip 16
qwFin:      .skip 16
sBuffer:            .skip TAILLEBUFFER
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    
    afficherLib "Appel 1 "

    mov x0,#5                    // rang du poste à extraire
    bl debutChrono
    mov x0,0xFFFF
    movk x0,0x4FFF,lsl 16
1:
    subs x0,x0,1
    cbnz x0,1b
    
    bl stopChrono
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne

/***************************************************/
/*   execution routine              */
/***************************************************/
/* x0 contient */
execRoutine:                    // INFO: execRoutine
    stp x1,lr,[sp,-16]!         // save  registres
    stp x2,fp,[sp,-16]!         // save  registres

 
100:
    ldp x2,fp,[sp],16           // restaur  registres
    ldp x1,lr,[sp],16           // restaur registres
    ret
/********************************************************/
/* Lancement du chrono                                  */
/********************************************************/
debutChrono:                 // fonction
    stp x0,lr,[sp,-16]!      // save  registres
    stp x1,x8,[sp,-16]!      // save  registres
    ldr x0,qAdrqwDebut       // zone de reception du temps début
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
qAdrqwDebut:         .quad qwDebut
/********************************************************/
/* Affichage du temps      */
stopChrono:                    // fonction
    stp x8,lr,[sp,-16]!        // save  registres
    stp x0,x5,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    ldr x0,qAdrqwFin           // zone de reception du temps fin
    mov x1,0
    mov x8,GETTIME             // appel systeme gettimeofday
    svc 0 
    cmp x0,#0
    blt 99f                    // verification si l'appel est OK
                               // calcul du temps
    ldr x0,qAdrqwDebut         // temps départ
    affichageMemoire "Memoire " x0 5
    ldr x2,[x0]                // secondes
    ldr x3,[x0,#8]             // micro secondes
    ldr x0,qAdrqwFin           // temps arrivée
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
    ldr x1,qAdrsBuffer
    bl conversion10
    ldr x4,qAdrsSecondes      // recopie des secondes dans zone affichage
2:
    ldrb w0,[x1],1
    cbz w0,3f
    strb w0,[x4],1
    b 2b
3:
    mov x2,1000
    udiv x0,x3,x2             // calcul des millisecones
    msub x3,x0,x2,x3          // reste en micro secondes
    ldr x1,qAdrsBuffer        // conversion des millisecondes en base 10 pour l'affichage
    bl conversion10
    affichageMemoire "Buffer " x1 2
    ldr x4,qAdrsMilliS        // recopie des millisecondes dans zone affichage
4:
    ldrb w0,[x1],1
    cbz w0,5f
    strb w0,[x4],1
    b 4b
5:
    mov x0,x3                 // conversion des microsecondes en base 10 pour l'affichage
    ldr x1,qAdrsBuffer
    bl conversion10
    affichageMemoire "Buffer " x1 2
    ldr x4,qAdrsMicroS        // recopie des micro secondes dans zone affichage
6:
    ldrb w0,[x1],1
    cbz w0,7f
    strb w0,[x4],1
    b 6b
7:
    ldr x0,qAdrszMessTemps
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
qAdrqwFin:               .quad qwFin
qAdrszMessTemps:         .quad szMessTemps
qAdrsSecondes:           .quad sSecondes
qAdrsMilliS:             .quad sMilliS
qAdrsMicroS:             .quad sMicroS
qAdrsBuffer:             .quad sBuffer
qSecMicro:               .quad 1000000    
szMessErreurCHS: .asciz "Erreur stop Chrono rencontrée.\n"
.align 4



    
 