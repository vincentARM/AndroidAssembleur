/* ARM assembleur Android termux  32 bits */
/*  program fichier32.s   */
/*  lecture ecriture de fichiers 32 bits   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux
.equ READ,         3      @ code appel système Linux
.equ WRITE,        4
.equ OPEN,         5
.equ CLOSE,        6
.equ CREATE,       8
.equ TAILLEBUF,  100    @ taille du buffer
.equ TAILLEBUFLECT,  10000    @ taille du buffer de lecture
.equ STDIN, 0             @ console d'entrée linux standard
.equ O_RDWR,   0x0002     @ lecture écriture
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
szLibFin:             .asciz "fin"
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneConv:           .skip 11
szZoneConvS:          .skip 12
szZoneConvHexa:       .skip 9
sBuffer:              .skip TAILLEBUF
sBufferLect:          .skip TAILLEBUFLECT
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
    ldr r4,iAdrsBuffer
    ldr r5,iAdrsBufferLect
    afficherLib "Veuillez saisir le nom du fichier à lire :"
    
    mov r0,#STDIN                  @ console entrée standard Linux
    mov r1,r4                      @ adresse du buffer de lecture
    mov r2,#TAILLEBUF              @ taille buffer
    mov r7, #READ                  @ code appel systeme Linux
    svc 0 
    
    mov r1,#0
    sub r0,#1                      @ longueur - 1 = déplacement
    strb r1,[r4,r0]                @ remplace le 0xA final par 0x0
    
                                   @ ouverture du fichier
    mov r0,r4                      @ nom du fichier
    mov r1,#O_RDWR                 @ paramètre d'ouverture
    mov r2,#0                      @ mode
    mov r7,#OPEN                   @ appel fonction systeme pour ouvrir
    svc 0 
    cmp r0,#0                      @ si erreur retourne un nombre négatif
    bgt 1f
    afficherLib "Ouverture fichier impossible."
    b 100f
1:
    mov r6,r0                      @ save du File Descriptor
    mov r1,r5                      @ adresse du buffer de lecture
    mov r2,#TAILLEBUFLECT              @ taille buffer
    mov r7, #READ                  @ code appel systeme Linux
    svc 0 
    cmp r0,#0                      @ si erreur retourne un nombre négatif
    bgt 2f
    afficherLib "Erreur lecture fichier."
    b 95f
2:
    affreghexa "Code retour = "
    affichageMemoire "Lecture : " sBufferLect 3
    
    afficherLib "Veuillez saisir le nom du fichier à écrire :"
    
    mov r0,#STDIN                  @ console entrée standard Linux
    mov r1,r4                      @ adresse du buffer de lecture
    mov r2,#TAILLEBUF              @ taille buffer
    mov r7, #READ                  @ code appel systeme Linux
    svc 0 
    
    mov r1,#0
    sub r0,#1                      @ longueur - 1 = déplacement
    strb r1,[r4,r0]                @ remplace le 0xA final par 0x0
    
                                   @ ouverture du fichier écriture
    mov r0,r4                      @ nom du fichier
    ldr r1,#oficmask1              @ paramètre d'ouverture
    mov r2,#0                      @ mode
    mov r7,#CREATE                 @ appel fonction systeme pour crer le fichier
    svc 0 
    cmp r0,#0                      @ si erreur retourne un nombre négatif
    bgt 3f
    afficherLib "Creation fichier écriture impossible."
    b 95f
3:
    mov r8,r0                      @ save du File Descriptor
    mov r1,r5                      @ adresse du buffer de lecture
    mov r2,#10                     @ nombre d'octets à écrire
    mov r7, #WRITE                 @ code appel systeme Linux
    svc 0 
    cmp r0,#0                      @ si erreur retourne un nombre négatif
    bgt 90f
    afficherLib "Erreur ecriture fichier."
90:                                @ fermeture fichier
    mov r0,r8                      @ Fd  fichier ecriture
    mov r7, #CLOSE                 @ appel fonction systeme pour fermer
    svc 0                           
    cmp r0,#0
    bge 95f
    afficherLib "Erreur fermeture fichier ecriture."
    
95:                                @ fermeture fichier
    mov r0,r6                      @ Fd  fichier lecture
    mov r7, #CLOSE                 @ appel fonction systeme pour fermer
    svc 0                           
    cmp r0,#0
    bge 100f
    afficherLib "Erreur fermeture fichier lecture."
    

100:                               @ fin standard du programme
    ldr r0,iAdrszMessFinPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrszRetourLigne:      .int szRetourLigne
iAdrsBuffer:            .int sBuffer
iAdrsBufferLect:        .int sBufferLect
iAdrszLibFin:           .int szLibFin
oficmask1:              .octa 0644 
