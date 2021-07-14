/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme fichier64.s */
/* lecture écriture  64 bits  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDIN, 0                 // console d'entrée linux standard
.equ STDOUT, 1                // Linux output console

.equ OPEN,   56
.equ CLOSE,  57
.equ READ,   63               // Linux syscall 64 bits
.equ EXIT,   93               // Linux syscall 64 bits
.equ WRITE,  64               // Linux syscall 64 bits

.equ TAILLEBUF,  100          // taille du buffer
.equ TAILLEBUFLECT,  10000    // taille du buffer de lecture
.equ O_RDWR,   0x0002         // lecture écriture
.equ AT_FDCWD,    -100         // code répertoire courant
/*  fichier */
.equ O_RDONLY, 0               // ouverture lecture seule
.equ O_WRONLY, 0x0001          // ouverture ecriture seule
.equ O_RDWR,   0x0002          // ecriture et lecture

.equ O_CREAT,  0x040           // creation si inexistant
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
sBufferLect:          .skip TAILLEBUFLECT
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
    afficherLib "Veuillez saisir le nom du fichier à lire :"
    mov x0,STDIN                 // console d'entrée linux standard
    mov x1,x19                   // adresse du buffer de saisie
    mov x2,TAILLEBUF             // taille buffer
    mov x8,READ                  // code fonction lecture linux
    svc 0                        // appel système
    
    sub x0,x0,#1                  // longueur - 1 = déplacement
    strb wzr,[x19,x0]             // remplace le 0xA final par 0x0
    
    mov x0,AT_FDCWD               // valeur pour indiquer le répertoire courant
    mov x1,x19                    // Donc le nom du fichier à ouvrir
    mov x2,O_RDWR                 //  flags
    mov x3,0                      // mode
    mov x8,OPEN                   // appel fonction systeme pour ouvrir
    svc #0 
    cmp x0,#0                     // si erreur retourne -1
    bgt 1f
    afficherLib "Ouverture fichier impossible."
    b 100f
1:
    mov x20,x0                   // sauve dans x20 le descriptif de fichier (FD File descriptor)
    ldr x21,qAdrsBufferLect      // adresse du buffer de lecture
    mov x1,x21                   // adresse du buffer de lecture
    mov x2,TAILLEBUFLECT         // taille buffer
    mov x8,READ                  // code fonction lecture linux
    svc 0                        // appel système
    cmp x0,#0                    // si erreur retourne un nombre négatif
    bgt 2f
    afficherLib "Erreur lecture fichier."
    b 95f
2:
    affreghexa "Code retour = "
    affichageMemoire "Lecture : " sBufferLect 3
    
    afficherLib "Veuillez saisir le nom du fichier à écrire :"
    mov x0,STDIN                 // console d'entrée linux standard
    mov x1,x19                   // adresse du buffer de saisie
    mov x2,TAILLEBUF             // taille buffer
    mov x8,READ                  // code fonction lecture linux
    svc 0                        // appel système
    
    sub x0,x0,#1                  // longueur - 1 = déplacement
    strb wzr,[x19,x0]             // remplace le 0xA final par 0x0
    
    mov x0,AT_FDCWD               // valeur pour indiquer le répertoire courant
    mov x1,x19                    // Donc le nom du fichier à ouvrir
    ldr x2,qFicMask               //  flags
    ldr x3,oFicPerm               // permissions
    mov x8,OPEN                   // appel fonction systeme pour ouvrir
    svc #0 
    cmp x0,#0                     // si erreur retourne -1
    bgt 3f
    afficherLib "Création fichier impossible."
    b 100f
3:
    mov x22,x0                   // sauve dans x22 le descriptif de fichier (FD File descriptor)
    mov x1,x21                   // buffer de lecture précédent
    mov x2,10                    // nombre de caractères à écrire
    mov x8, #WRITE               // appel systeme 'write'
    svc #0                       // appel systeme 
    cmp x0,#0  
    bgt 90f
    afficherLib "Erreur ecriture fichier."
90:                               // fermeture fichier ecriture
    mov x0,x22                    // fermeture fichier de sortie Fd
    mov x8,CLOSE                  // appel fonction systeme pour fermer
    svc 0 
    cmp x0,0
    bge 95f
    afficherLib "Erreur fermeture fichier ecriture."
    
95:                                // fermeture fichier lecture
    mov x0,x20                     // FD lecture
    mov x8,CLOSE                   // appel fonction systeme pour fermer
    svc 0 
    cmp x0,0
    bge 99f
    afficherLib "Erreur fermeture fichier lecture."
    
99:
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
qAdrsBufferLect:       .quad sBufferLect
qFicMask:              .quad O_CREAT|O_WRONLY
oFicPerm:              .octa 0644
 