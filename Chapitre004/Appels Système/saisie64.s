/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme saisie64.s */
/* exemple de saisie d'une chaine  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1           // Linux output console
.equ READ,   63          // Linux syscall 64 bits
.equ EXIT,   93          // Linux syscall 64 bits
.equ WRITE,  64          // Linux syscall 64 bits
.equ TAILLEBUF,  100     // taille du buffer
.equ STDIN, 0            // console d'entrée linux standard
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
szLibFin:            .asciz "fin"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
sBuffer:              .skip TAILLEBUF
.align 8

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    
    ldr x19,qAdrsBuffer         // adresse du buffer de saisie
1:
    afficherLib "Veuillez saisir une chaîne de caractères ou fin :"
    mov x0,STDIN                 // console d'entrée linux standard
    mov x1,x19                   // adresse du buffer de saisie
    mov x2,TAILLEBUF             // taille buffer
    mov x8,READ                  // code fonction lecture linux
    svc 0                        // appel système


    affreghexa "code retour = "  // vérification du code retour
    
    mov x1,x19                    // adresse du buffer
    affichageMemoire "Memoire " x1 4
    
    sub x0,x0,#1                  // longueur - 1 = déplacement
    strb wzr,[x19,x0]             // remplace le 0xA final par 0x0
    
    mov x0,x19                    // adresse buffer
    ldr x1,qAdrszLibFin           // adresse du libellé "fin"
    bl comparerChaines            // la saisie = fin ?
    bne 1b                        // non -> boucle

    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrsBuffer:           .quad sBuffer
qAdrszLibFin:          .quad szLibFin

 