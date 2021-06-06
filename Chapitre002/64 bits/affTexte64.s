/* Programme assembleur ARM android avec Termux */
/* Assembleur 64 bits ARM   : Vincent Leboulou */
/*  */
/* affichage message standard  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits
/*********************************/
/* Données initialisées          */
/*********************************/
.data
szMess:   .asciz "Bonjour, le monde 64 bits s'ouvre à nous.\n"

/*********************************/
/* données non initialisée       */
/*********************************/
.bss  
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                           // point d'entrée du programme
                                //  affichage du message par la routine
    ldr x0,qAdrszMess
    bl affichageMess

100:                            // fin standard
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0

qAdrszMess:   .quad szMess

/******************************************************************/
/*     affichage texte avec calcul de la longueur                */ 
/******************************************************************/
/* x0 contient l' adresse du message */
affichageMess:
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    str x8,[sp,-16]!           // save registre
    mov x2,#0                  // compteur taille
1:                             // boucle calcul longueur chaine
    ldrb w1,[x0,x2]            // lecture un octet
    cmp w1,#0                  // fin de chaine si zéro
    beq 2f
    add x2,x2,#1
    b 1b
2:
    mov x1,x0                  // adresse du texte
    mov x0,#STDOUT             // sortie Linux standard
    mov x8, #WRITE             // code call system "write"
    svc #0                     // call systeme Linux
    ldr x8,[sp],16             // restaur registre
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30
