/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme accesmem64.s */
/* exemple accès à la mémoire 64 bits  */

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

bOctet1:              .byte 5            // définit un octet de valeur 5
.align 2
hDemiMot1:            .hword 0x1234      // définit un demi mot (2 octets)
.align 4
iEntier1:             .int  0x12345678   // définit un entier de 4 octets

.align 8
qValeur1:            .quad 0x1234567890123456  // définit un double mot de 8 octets
qValeurNeg:          .int -1
tabValeurs:          .quad 1,2,3,4,5,6,7,8     // définit une table de double mots
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
qValeur2:           .skip 8       // réserve la place pour un double mot
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    afficherLib "Accès valeur 8 octets :"
    ldr x1,qAdrqValeur1
    mov x0,x1
    bl afficherHexa
    ldr x0,[x1]
    bl afficherHexa
 
    afficherLib "accès valeur 1 octet :"
    ldr x1,qAdrqValeur1
    ldrb w0,[x1]
    bl afficherHexa
    
    afficherLib "accès valeur 2 octets :"
    ldr x1,qAdrqValeur1
    ldrh w0,[x1,4]
    bl afficherHexa
    
    afficherLib "accès valeur 4 octets :"
    ldr x1,qAdrqValeur1
    ldr w0,[x1]
    bl afficherHexa
    
    afficherLib "accès valeur 2 registres :"
    ldr x1,qAdrtabValeurs
    ldp x0,x2,[x1]
    bl afficherHexa
    mov x0,x2
    bl afficherHexa
    
    afficherLib "accès valeur negative :"
    ldr x1,qAdrqValeurNeg
    ldr w0,[x1]
    bl afficherHexa
    
    afficherLib "accès valeur negative avec report du signe:"
    ldr x1,qAdrqValeurNeg
    ldrsw x0,[x1]
    bl afficherHexa
    
     afficherLib "accès valeur avec offset dans registre:"
    ldr x1,qAdrtabValeurs
    mov x2,16
    ldr x0,[x1,x2]
    bl afficherHexa
    
    afficherLib "accès valeur avec offset immediat et maj:"
    ldr x1,qAdrtabValeurs
    mov x0,x1                // pour afficher l'adresse contenue dans x1
    bl afficherHexa
    ldr x0,[x1,16]!          // charge la 3ième valeur
    bl afficherHexa
    ldr x0,[x1,16]!          // charge la 6 ième valeur
    bl afficherHexa
    mov x0,x1                // pour afficher l'adresse contenue dans x1
    bl afficherHexa
    
    afficherLib "accès valeur avec offset post et maj:"
    ldr x1,qAdrtabValeurs
    mov x0,x1                // pour afficher l'adresse contenue dans x1
    bl afficherHexa
    ldr x0,[x1],16
    bl afficherHexa
    ldr x0,[x1],16
    bl afficherHexa
    mov x0,x1                // pour afficher l'adresse contenue dans x1
    bl afficherHexa
    
    
    afficherLib "stockage et destokage sur la pile:"
    mov x0,4
    mov x1,10
    stp x0,x1,[sp,-16]!
    ldp x0,x1,[sp],16
    bl afficherHexa
    mov x0,x1                // affiche valeur de x1
    bl afficherHexa
    
    afficherLib "Stockage 8 octets en mémoire :"
    ldr x1,qAdrqValeur2
    mov x0,0x6666
    str x0,[x1]
    ldr x2,[x1]
    mov x0,x2
    bl afficherHexa
    
    afficherLib "Stockage 1 octet en mémoire :"
    ldr x1,qAdrqValeur2
    mov x0,0x12
    strb w0,[x1,3]
    ldr x2,[x1]
    mov x0,x2
    bl afficherHexa
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrqValeur1:          .quad qValeur1
qAdrtabValeurs:        .quad tabValeurs
qAdrqValeurNeg:        .quad qValeurNeg
qAdrqValeur2:          .quad qValeur2
