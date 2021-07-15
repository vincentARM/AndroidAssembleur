/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme fichierStat64.s */
/*  recup taille fichier et lecture écriture   */

/************************************/
/* Constantes                       */
/************************************/
.equ STDIN, 0                 // console d'entrée linux standard
.equ STDOUT, 1                // Linux output console

.equ FSTAT, 80
.equ OPEN,   56
.equ CLOSE,  57
.equ READ,   63               // Linux syscall 64 bits
.equ EXIT,   93               // Linux syscall 64 bits
.equ WRITE,  64               // Linux syscall 64 bits

.equ TAILLEBUF,  100          // taille du buffer
.equ TAILLEBUFLECT,  100      // taille du buffer de lecture des stats
.equ  TAILLETAS,     10000000 // taille fichier maxi 10MO

.equ O_RDWR,   0x0002         // lecture écriture
.equ AT_FDCWD,    -100        // code répertoire courant
/*  fichier */
.equ O_RDONLY, 0              // ouverture lecture seule
.equ O_WRONLY, 0x0001         // ouverture ecriture seule
.equ O_RDWR,   0x0002         // ecriture et lecture

.equ O_CREAT,  0x040          // creation si inexistant
/****************************************************/
/* fichier des macros                               */
/****************************************************/
.include "../ficmacros64.inc"

/****************************************************/
/* description des structures                               */
/****************************************************/
/* structure de type   stat  : infos fichier  */
    .struct  0
Stat_dev_t:                     // ID of device containing file
    .struct Stat_dev_t + 8
Stat_ino_t:                     // inode
    .struct Stat_ino_t + 8
Stat_mode_t:                    // File type and mode
    .struct Stat_mode_t + 4    
Stat_nlink_t:                   // Number of hard links */
    .struct Stat_nlink_t + 4    
Stat_uid_t:                     // User ID of owner
    .struct Stat_uid_t + 4
Stat_gid_t:                     // Group ID of owner
    .struct Stat_gid_t + 4     
Stat_rdev_t:                    // Device ID (if special file)
    .struct Stat_rdev_t + 8 
Stat_size_deb:                  // ????
     .struct Stat_size_deb + 8 
Stat_size_t:                    // Total size, in bytes
    .struct Stat_size_t + 8     
Stat_blksize_t:                 // Block size for filesystem I/O
    .struct Stat_blksize_t + 8     
Stat_blkcnt_t:                  // Number of 512B blocks allocated
    .struct Stat_blkcnt_t + 8     
Stat_atime:                     //   date et heure fichier
    .struct Stat_atime + 8     
Stat_mtime:                     //   date et heure modif fichier
    .struct Stat_mtime + 8 
Stat_ctime:                     //   date et heure creation fichier
    .struct Stat_ctime + 8     
Stat_Fin:   

/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

.align 8
ptZoneTas:           .quad ZoneTas

/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
sBuffer:              .skip TAILLEBUF
sBufferLect:          .skip TAILLEBUFLECT
.align 8
ZoneTas:              .skip TAILLETAS
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
    mov x8,FSTAT                  // code fonction lecture linux
    svc 0                        // appel système
    cmp x0,#0                    // si erreur retourne un nombre négatif
    bge 11f
    afficherLib "Erreur appel statistiques fichier."
    b 100f
    
    
11:
    affreghexa "Code retour = "
    affichageMemoire "Lecture : " sBufferLect 6
    mov x0,Stat_size_t
    affreghexa "offset "
    ldr x23,[x21,Stat_size_t]
    mov x0,x23
    affreghexa "Taille du fichier "
    bl reserverPlace
    mov x24,x0

    mov x0,x20                   // FD fichier lecture
    mov x1,x24                   // adresse du buffer de lecture
    mov x2,x23                   // taille buffer
    mov x8,READ                  // code fonction lecture linux
    svc 0                        // appel système
    cmp x0,#0                    // si erreur retourne un nombre négatif
    bgt 2f
    afficherLib "Erreur lecture fichier."
    b 95f
2:
    affreghexa "Code retour = "
    mov x0,x24
    affichageMemoire "Lecture : " x0 3
    
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
    mov x1,x24                   // buffer de lecture précédent
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
/***************************************************/
/*   reserver Place              */
/***************************************************/
/* x0 contient la taille à réserver */
reserverPlace:                  // INFO: reserverPlace
    stp x1,lr,[sp,-16]!         // save  registres
    stp x2,fp,[sp,-16]!         // save  registres
    ldr x1,qAdrptZoneTas        // adresse du pointeur de début du tas
    ldr x2,[x1]                 // pointeur de début du tas
    add x0,x0,x2                // ajout de la taille
    lsr x0,x0,3
    lsl x0,x0,3                 // alignement sur une frontière de 8 octets
    add x0,x0,8                 // + 8 pour calculer nouveau pointeur du tas
    str x0,[x1]                 // et maj du pointeur
    ldr x1,ptFinTas             // vérification fin du tas
    cmp x0,x1
    blt 1f
    afficherLib "\033[31mErreur : tas trop petit !!\033[0m"
    mov x0,-1
    b 100f 
1:
    mov x0,x2                   // retourne le début de zone réservée
100:
    ldp x2,fp,[sp],16           // restaur  registres
    ldp x1,lr,[sp],16           // restaur registres
    ret
qAdrptZoneTas:       .quad ptZoneTas
ptFinTas:            .quad ZoneTas + TAILLETAS   // calcule la fin du tas
