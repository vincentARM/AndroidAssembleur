/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme instruc64.s */
/* flot instructions  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

.equ LGBUFFER,  200
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

szMessTrouve:        .asciz "Caractère trouvé en position @ \n"
szMessLongueur:      .asciz "Longueur = @ \n"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss
sZoneConv:         .skip 22
sBuffer:           .skip LGBUFFER
.align 8

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    
    
    afficherLib "exemple SI ALORS SINON "
    mov x0,#5                    // valeur à changer pour tester autre branche
    cmp x0,10
    blt 1f
    afficherLib "Supérieur ou égal."
    b 2f
1:
    afficherLib "Inférieur."
    
2:
    afficherLib "Alternative cas simple"
    mov x0,#15                    // valeur à changer pour tester autre branche
    mov x1,3
    mov x2,8
    cmp x0,10
    csel x0,x1,x2,lt             // met dans x0 soit x1 soit x2 en fonction du test
    affreghexa "resultat = " 
    cset x0,gt                   // met 0 dans x0 si le test est faux sinon met 1
    affreghexa "resultat1 = " 
    
    afficherLib "Exemple de boucle : "
    mov x19,0
    ldr x20,qAdrszMessDebutPgm
boucle:
    ldrb w0,[x20,x19]           // charge un caractère
    cbz w0,nontrouve            // si fin de chaine -> fin de boucle
    cmp w0,'p'                  // caractère trouvé ?
    beq trouve                  // oui
    add x19,x19,1               // incremente l'indice
    b boucle                    // et boucle
trouve:
    mov x0,x19                  // indice trouvé
    ldr x1,qAdrsZoneConv
    bl conversion10             // conversion décimale
    ldr x0,qAdrszMessTrouve
    ldr x1,qAdrsZoneConv
    ldr x2,qAdrsBuffer
    mov x3,LGBUFFER
    bl insererChaineCar         // insertion de la zone de conversion dans le message
    bl afficherMess             // et affichage
    b suite
nontrouve:
    afficherLib "Caractère non trouvé."
suite:
    afficherLib "autre boucle :"
    mov x0,0
3:
    ldrb w1,[x20,x0]           // charge un caractère
    cmp w1,0                   // fin de chaine ?
    cinc x0,x0,ne              // incremente de 1 x0 tant que le test est faux
    bne 3b                     // et boucle 
    ldr x1,qAdrsZoneConv
    bl conversion10            // conversion décimale
    ldr x0,qAdrszMessLongueur
    ldr x1,qAdrsZoneConv
    ldr x2,qAdrsBuffer
    mov x3,LGBUFFER
    bl insererChaineCar         // insere la zone de conversion dans le message
    bl afficherMess
    
    bl execRoutine             // exemple execution routine
     
    adr x5,execRoutine         // autre exemple execution routine
    blr x5 
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrszMessTrouve:      .quad szMessTrouve
qAdrsZoneConv:         .quad sZoneConv
qAdrsBuffer:           .quad sBuffer
qAdrszMessLongueur:    .quad szMessLongueur
/***************************************************/
/*   exemple execution routine                     */
/***************************************************/

execRoutine:                    // INFO: execRoutine
    stp x1,lr,[sp,-16]!         // save  registres

    afficherLib "Je suis la routine"
 
100:
    ldp x1,lr,[sp],16           // restaur registres
    ret



 