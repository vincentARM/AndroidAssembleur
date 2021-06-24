/* ARM assembleur Android termux  32 bits */
/*  program expchaine32.s   */
/* exemple de routines de chaines de caractères 32 bits   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux
/****************************************************/
/* fichier des macros                   */
/****************************************************/
.include "../ficmacros32.inc"

/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szRetourLigne:        .asciz "\n"
szChaine1:            .asciz "AbcdE"
szChaine2:            .asciz "AbcdE"
szChaine3:            .asciz "A"
szChaine4:            .asciz "AbcdF" 
szChaineNulle:        .asciz ""

szChaineMess:          .asciz "Insertion chaine ici : @ \n"
szMessConv:            .asciz "Valeur décimale du registre : @ \n"
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneConv:           .skip 11
sBuffer:              .skip 200
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
    
    afficherLib "Comparaison 1"
    ldr r0,iAdrszChaine1
    ldr r1,iAdrszChaine2
    bl execComparaison

    afficherLib "Comparaison 2"
    ldr r0,iAdrszChaine1
    ldr r1,iAdrszChaine3
    bl execComparaison
    
    afficherLib "Comparaison 3"
    ldr r0,iAdrszChaine1
    ldr r1,iAdrszChaine4
    bl execComparaison
    
    afficherLib "Exemple insertion :"
    ldr r0,iAdrszChaineMess       @ adresse de la chaine maitre
    ldr r1,iAdrszChaine1          @ adresse de la chaine à insérer
    ldr r2,iAdrsBuffer            @ adresse du buffer
    mov r3,#200                   @ taille du buffer
    bl insererChaineCar
    cmp r0,#0
    bmi 1f
    bl afficherMess               @ affichage si pas d'erreur
    b 2f
1: 
   affreghexa "Erreur : " 
2:
    afficherLib "Cas des chaines nulles :"
    ldr r0,iAdrszChaineNulle     
    ldr r1,iAdrszChaine1
    ldr r2,iAdrsBuffer
    mov r3,#200
    bl insererChaineCar
    cmp r0,#0
    bmi 3f
    bl afficherMess             @ affichage si pas d'erreur
    b 4f
3: 
   affreghexa "Erreur : " 
4:
    ldr r0,iAdrszChaineMess
    ldr r1,iAdrszChaineNulle
    ldr r2,iAdrsBuffer
    mov r3,#200
    bl insererChaineCar
    cmp r0,#0
    bmi 5f
    bl afficherMess             @ affichage si pas d'erreur
    b 6f
5: 
   affreghexa "Erreur : " 
6:
    afficherLib "Cas du buffer trop petit :"
    ldr r0,iAdrszChaineMess
    ldr r1,iAdrszChaine1
    ldr r2,iAdrsBuffer
    mov r3,#10
    bl insererChaineCar
    cmp r0,#0
    bmi 7f
    bl afficherMess             @ affichage si pas d'erreur
    b 8f
7: 
   affreghexa "Erreur : " 
8:
    afficherLib "Cas conversion registre :"
    mov r0,#100                  @ valeur à convertir
    ldr r1,iAdrszZoneConv        @ zone de conversion
    bl conversion10
    ldr r0,iAdrszMessConv        @ adresse du message
    ldr r1,iAdrszZoneConv        @ adresse de la zone de conversion
    ldr r2,iAdrsBuffer           @ adresse du buffer
    mov r3,#200                  @ taille du buffer
    bl insererChaineCar          @ insertion
    bl afficherMess              @ et affichage du buffer
    
100:                             @ fin standard du programme
    ldr r0,iAdrszMessFinPgm      @ adresse du message 
    bl afficherMess              @ appel fonction d'affichage
                                 @ fin du programme
    mov r0, #0                   @ code retour OK
    mov r7, #EXIT                @ code fin LINUX 
    svc 0                        @ appel système LINUX

iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrszRetourLigne:      .int szRetourLigne
iAdrszChaine1:          .int szChaine1
iAdrszChaine2:          .int szChaine2
iAdrszChaine3:          .int szChaine3
iAdrszChaine4:          .int szChaine4
iAdrszChaineMess:       .int szChaineMess
iAdrsBuffer:            .int sBuffer
iAdrszChaineNulle:      .int szChaineNulle
iAdrszZoneConv:         .int szZoneConv
iAdrszMessConv:         .int szMessConv
/***************************************************/
/*   Exemple routine               */
/***************************************************/
/* r0 contient l'adresse de la chaine 1   */
/* r1 contient l'adresse de la chaine 2   */
execComparaison:                   @ INFO: execRoutine
    push {lr}            @ save des registres
    bl comparaison
    cmp r0,#0
    bne 1f
    afficherLib "Les chaines sont égales."
    b 100f
1:
    afficherLib "Les chaines ne sont pas égales."
100:
    pop {pc}             @ restaur des registres et retour main
/************************************/       
/* comparaison de chaines           */
/************************************/      
/* r0 et r1 contiennent les adresses des chaines */
/* retour 0 dans r0 si egalite */
/* retour -1 si chaine r0 < chaine r1 */
/* retour 1  si chaine r0> chaine r1 */
comparaison:              @ INFO: comparaison
    push {r2-r4}          @ save des registres
    mov r2,#0             @ indice
1:    
    ldrb r3,[r0,r2]       @ octet chaine 1
    ldrb r4,[r1,r2]       @ octet chaine 2
    cmp r3,r4
    movlt r0,#-1          @ plus petite
    movgt r0,#1           @ plus grande
    bne 100f              @ pas egaux 
    cmp r3,#0             @ 0 final
    moveq r0,#0           @ egalite
    beq 100f              @ c'est la fin
    add r2,r2,#1          @ sinon plus 1 dans indice
    b 1b                  @ et boucle
100:
    pop {r2-r4}
    bx lr  
/******************************************************************/
/*   insertion d'une sous chaine à la place du caractère @        */ 
/******************************************************************/
/* r0 contient adresse de la chaine maitre */
/* r1 contient l'adresse de la chaine à insérer  */
/* r2 contient l'adresse d'un buffer de taille suffisante  */
/* r3 contient la taille de ce buffer   */
.equ CHARPOS,     '@'
insererChaineCar:
    push {r1-r6,lr}             @ save  registres
    mov r6,#0                   @ compteur de longueur chaine 1
1:                              @ calcule la longueur de la chaine 1
    ldrb r4,[r0,r6]
    cmp r4,#0
    addne r6,#1              @ incremente compteur si pas fini
    bne 1b                      @ boucle si pas fini
    cmp r6,#0                   @ chaine nulle ?
    moveq r0,#-1                 @ erreur -> fin
    beq 100f 
    mov r5,#0                   @ compteur de longueur chaine à inserer 
2:                              @ calcul de la longueur
    ldrb r4,[r1,r5]
    cmp r4,#0
    addne r5,r5,#1              @ incremente compteur si pas fini
    bne 2b                      @ boucle si pas fini
    cmp r5,#0                   @ chaine vide ?
    moveq r0,#-2                @ erreur -> fin
    beq 100f
    add r5,r6                   @ addition des 2 longueurs
    add r5,r5,#1                @ + 1 pour le zéro final
    cmp r5,r3                   @ plus grande que la taille du buffer ?
    movgt r0,#-3                 @ erreur -> fin
    bgt 100f
    
   // mov r6,r0                   @ a revioir   r0 = r6
    
    //mov r5,r2                   @ a revoir
 
    mov r5,#0           @ inverser r2 et r5
    mov r4,#0
3:                              @ boucle de copie du début de la chaine
        ldrb r3,[r0,r5]
        cmp r3,#0               @ fin de la chaine 1 ?
        moveq r0,#-4            @ erreur car pas de caractère d'insertion
        beq 100f
        cmp r3,#CHARPOS         @ caractère d'insertion ?
        beq 5f                  @ oui
        strb r3,[r2,r4]         @ sinon stocke le caractère dans le buffer
        add r5,r5,#1
        add r4,r4,#1
        b 3b                    @ et boucle
5:                              @ r4 contient la position du caractère d'insertion
    add r5,r4,#1                @ init indice position insertion buffer + 1
    mov r3,#0                   @ indice de chargement de la chaine d'insertion
6:
        ldrb r6,[r1,r3]         @ charge un caractère de la chaine d'insertion
        cmp r6,#0               @ fin de chaine ?
        beq 7f                  @ oui
        strb r6,[r2,r4]         @ sinon stocke le caractère à la bonne position dans le buffer 
        add r3,r3,#1            @ incremente l'indice
        add r4,r4,#1            @ incremente l'indice du buffer
        b 6b                    @ et boucle 
7:                              @ boucle de copie de la fin de la chaine maitre 
    ldrb r6,[r0,r5]             @ charge un caractère de la chaine maitre
    strb r6,[r2,r4]             @ et le stocke dans le buffer
    cmp r6,#0                   @ fin de la chaine maitre ?
    beq 8f                      @ oui -> c'est fini
    add r4,r4,#1                @ incremente l'indice du buffer
    add r5,r5,#1                @ incremente l'indice
    b 7b                        @ et boucle
8:
    mov r0,r2                   @ retourne l'adresse de début du buffer
100:
    pop {r1-r6,lr}              @ restaur registres 
    bx lr
