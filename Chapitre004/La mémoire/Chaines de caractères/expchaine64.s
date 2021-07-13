/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme expchaine64.s */
/* gestion des chaines de caractères 64 bits  */

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

/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"
szChaine1:            .asciz "AbcdE"
szChaine2:            .asciz "AbcdE"
szChaine3:            .asciz "A"
szChaine4:            .asciz "AbcdF" 
szChaineNulle:        .asciz ""

szChaineMess:          .asciz "Insertion chaine ici : @ \n"
szMessConv:            .asciz "Valeur décimale du registre : @ \n"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
szZoneConv:           .skip 11
sBuffer:              .skip 200

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    
    afficherLib "Comparaison 1"
    ldr x0,qAdrszChaine1
    ldr x1,qAdrszChaine2
    bl execComparaison

    afficherLib "Comparaison 2"
    ldr x0,qAdrszChaine1
    ldr x1,qAdrszChaine3
    bl execComparaison
    
    afficherLib "Comparaison 3"
    ldr x0,qAdrszChaine1
    ldr x1,qAdrszChaine4
    bl execComparaison
    
    afficherLib "Exemple insertion :"
    ldr x0,qAdrszChaineMess       // adresse de la chaine maitre
    ldr x1,qAdrszChaine1          // adresse de la chaine à insérer
    ldr x2,qAdrsBuffer            // adresse du buffer
    mov x3,#200                   // taille du buffer
    bl insererChaineCar
    cmp x0,#0
    bmi 1f
    bl afficherMess               // affichage si pas d'erreur
    b 2f
1: 
   affreghexa "Erreur : " 
2:
    afficherLib "Cas des chaines nulles :"
    ldr x0,qAdrszChaineNulle       // adresse de la chaine maitre
    ldr x1,qAdrszChaine1          // adresse de la chaine à insérer
    ldr x2,qAdrsBuffer            // adresse du buffer
    mov x3,#200                   // taille du buffer
    bl insererChaineCar
    cmp x0,#0
    bmi 3f
    bl afficherMess               // affichage si pas d'erreur
    b 4f
3: 
   affreghexa "Erreur : " 
4:
    ldr x0,qAdrszChaineMess       // adresse de la chaine maitre
    ldr x1,qAdrszChaineNulle         // adresse de la chaine à insérer
    ldr x2,qAdrsBuffer            // adresse du buffer
    mov x3,#200                   // taille du buffer
    bl insererChaineCar
    cmp x0,#0
    bmi 5f
    bl afficherMess               // affichage si pas d'erreur
    b 6f
5: 
   affreghexa "Erreur : " 
6:
    afficherLib "Buffer trop petit :"
    ldr x0,qAdrszChaineMess       // adresse de la chaine maitre
    ldr x1,qAdrszChaine1          // adresse de la chaine à insérer
    ldr x2,qAdrsBuffer            // adresse du buffer
    mov x3,#20                   // taille du buffer
    bl insererChaineCar
    cmp x0,#0
    bmi 7f
    bl afficherMess               // affichage si pas d'erreur
    b 8f
7: 
   affreghexa "Erreur : " 
8:
    afficherLib "Cas conversion registre :"
    mov x0,#100                  // valeur à convertir
    ldr x1,qAdrszZoneConv        // zone de conversion
    bl conversion10
    ldr x0,qAdrszMessConv        // adresse du message
    ldr x1,qAdrszZoneConv        // adresse de la zone de conversion
    ldr x2,qAdrsBuffer           // adresse du buffer
    mov x3,#200                  // taille du buffer
    bl insererChaineCar          // insertion
    bl afficherMess              // et affichage du buffer
    
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrszChaine1:         .quad szChaine1
qAdrszChaine2:         .quad szChaine2
qAdrszChaine3:         .quad szChaine3
qAdrszChaine4:         .quad szChaine4
qAdrszChaineNulle:     .quad szChaineNulle
qAdrszChaineMess:      .quad szChaineMess
qAdrsBuffer:           .quad sBuffer
qAdrszMessConv:        .quad szMessConv
qAdrszZoneConv :       .quad szZoneConv 
/***************************************************/
/*   Comparaison               */
/***************************************************/
/* x0 contient l'adresse de la chaine 1   */
/* x1 contient l'adresse de la chaine 2   */
execComparaison:                  // INFO: execComparaison
    str lr,[sp,-16]!              // save registre de retour uniquement
    bl comparaison
    cbnz x0,1f
    afficherLib "Les chaines sont égales."
    b 100f
1:
    afficherLib "Les chaines ne sont pas égales."
100:
    ldr lr,[sp],16
    ret
/************************************/       
/* comparaison de chaines           */
/************************************/      
/* x0 et x1 contiennent les adresses des chaines */
/* retour 0 dans x0 si egalite */
/* retour -1 si chaine x0 < chaine x1 */
/* retour 1  si chaine x0> chaine x1 */
comparaison:              // INFO: comparaison
    stp x2,lr,[sp,-16]!   // save registres
    stp x3,x4,[sp,-16]!   // save registres
    mov x2,#0             // indice
1:    
    ldrb w3,[x0,x2]       // octet chaine 1
    ldrb w4,[x1,x2]       // octet chaine 2
    cmp w3,w4
    blt 3f                // plus petite
    bgt 4f                // plus grande
    cbz w3,2f             // si egalite test si fin de chaine
    add x2,x2,#1          // sinon plus 1 dans indice
    b 1b                  // et boucle
2:
    mov x0,#0             // egalite
    b 100f
3:
    mov x0,#-1            // plus petite
    b 100f
4:
    mov x0,#1             // plus grande
100:
    ldp x3,x4,[sp],16     // restaur registres
    ldp x2,lr,[sp],16     // restaur registres
    ret
/******************************************************************/
/*   insertion d'une sous chaine à la place du caractère //        */ 
/******************************************************************/
/* x0 contient adresse de la chaine maitre */
/* x1 contient l'adresse de la chaine à insérer  */
/* x2 contient l'adresse d'un buffer de taille suffisante  */
/* x3 contient la taille de ce buffer   */
.equ CHARPOS,     '@'
insererChaineCar:
    stp x2,lr,[sp,-16]!   // save registres
    stp x3,x4,[sp,-16]!   // save registres
    stp x5,x6,[sp,-16]!   // save registres
    mov x6,#0                   // compteur de longueur chaine 1
1:                              // calcule la longueur de la chaine 1
    ldrb w4,[x0,x6]
    cmp w4,#0
    cinc  x6,x6,ne              // incremente le compteur si pas fini
    bne 1b                      // boucle si pas fini
    cmp x6,#0                   // chaine nulle ?
    beq 99f                     // erreur
    mov x5,#0                   // compteur de longueur chaine à inserer 
2:                              // calcul de la longueur
    ldrb w4,[x1,x5]
    cmp w4,#0
    cinc  x5,x5,ne              // incremente le compteur si pas fini
    bne 2b                      // boucle si pas fini
    cmp x5,#0                   // chaine vide ?
    beq 98f
    add x5,x5,x6                // addition des 2 longueurs
    add x5,x5,#1                // + 1 pour le zéro final
    cmp x5,x3                   // plus grande que la taille du buffer ?
    bgt 97f

 
    mov x5,#0
    mov x4,#0
3:                              // boucle de copie du début de la chaine
    ldrb w3,[x0,x5] 
    cmp w3,#0                   // fin de la chaine 1 ?
    beq 96f
    cmp w3,#CHARPOS             // caractère d'insertion ?
    beq 5f                      // oui
    strb w3,[x2,x4]             // sinon stocke le caractère dans le buffer
    add x5,x5,#1
    add x4,x4,#1
    b 3b                        // et boucle
5:                              // x4 contient la position du caractère d'insertion
    add x5,x4,#1                // init indice position insertion buffer + 1
    mov x3,#0                   // indice de chargement de la chaine d'insertion
6:
    ldrb w6,[x1,x3]             // charge un caractère de la chaine d'insertion
    cbz w6,7f                   // fin de chaine ?
    strb w6,[x2,x4]             // sinon stocke le caractère à la bonne position dans le buffer 
    add x3,x3,#1                // incremente l'indice
    add x4,x4,#1                // incremente l'indice du buffer
    b 6b                        // et boucle 
7:                              // boucle de copie de la fin de la chaine maitre 
    ldrb w6,[x0,x5]             // charge un caractère de la chaine maitre
    strb w6,[x2,x4]             // et le stocke dans le buffer
    cbz w6,8f                   // fin de la chaine maitre ?
    add x4,x4,#1                // incremente l'indice du buffer
    add x5,x5,#1                // incremente l'indice
    b 7b                        // et boucle
8:
    mov x0,x2                   // retourne l'adresse de début du buffer
    b 100f
96:
    mov x0,-4                   // erreur détectée : pas de caractère d'insertion
    b 100f
97:
    mov x0,-3                   // erreur détectée : buffer trop petit
    b 100f
98:
    mov x0,-2                   // erreur détectée : chaine 2 nulle
    b 100f
99:
    mov x0,-1                   // erreur détectée : chaine 1 nulle
100:
    ldp x5,x6,[sp],16     // restaur registres
    ldp x3,x4,[sp],16     // restaur registres
    ldp x2,lr,[sp],16     // restaur registres
    ret
