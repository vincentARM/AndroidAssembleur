/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme struct64.s */
/* exemple structure 64 bits  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

/****************************************************/
/* fichier des macros                               */
/****************************************************/
.include "../ficmacros64.inc"

/*************************************************/
/* Définitions des structures                   */
/*********************************************/
/* exemple de définition */
    .struct  0
Client_valeur1:	                  // premier double
    .struct  Client_valeur1 + 8   
Client_valeur2:	                  // deuxieme double
    .struct  Client_valeur2 + 8 
Client_entier1:	                  // premier entier
    .struct  Client_entier1 + 4 
Client_octet1:	                  // premier octet
    .struct  Client_octet1 + 1 
Client_fin:                       // donne la longueur de la structure

/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
tbClients:            .skip Client_fin * 10

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    
    ldr x19,qAdrtbClients
    afficherLib "stockage du rang 5"
    mov x1,#5                    // rang
    mov x2,#Client_fin           // taille d'un enregistrement client
    madd x3,x2,x1,x19            // calcul de l'adresse du rang 5
    mov x0,#0x123                // première valeur
    str x0,[x3,#Client_valeur1]  // stocke la première valeur
    mov x0,#0x456
    str x0,[x3,#Client_valeur2]  // stocke la deuxième valeur
    mov x0,-1
    str w0,[x3,#Client_entier1]  // stocke la valeur de l'entier de 4 octets

    mov x0,#1
    strb w0,[x3,#Client_octet1]  // stocke la valeur de l'octet

    affichageMemoire "Tableau client" tbClients 10
    
    afficherLib "Chargement valeur du rang 5"
    mov x1,#5                    // rang
    mov x2,#Client_fin           // taille d'un enregistrement client
    madd x3,x2,x1,x19            // calcul de l'adresse du rang 5
    ldr x0,[x3,#Client_valeur2]  // charge la deuxième valeur
    affreghexa "Valeur2="        // et affichage

    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrtbClients:         .quad tbClients
