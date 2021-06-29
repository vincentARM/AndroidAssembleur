/* ARM assembleur Android termux  32 bits */
/*  program nombFloat32.s   */
/*  appel de l'instruction C printf 32 bits   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ STDOUT,       1      @ Linux console de sortie
.equ EXIT,         1      @ code appel système Linux
.equ WRITE,        4      @ code appel système Linux
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
szMessAppelC:         .asciz "valeur = %.15f \n"

.align 4
fNombre1:             .float -10.54321
.align 8
fNombre2:             .double 3.141592653589793
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneConv:           .skip 11
szZoneConvS:          .skip 12
szZoneConvHexa:       .skip 9
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    adr r0,iOfszMessDebPgm        @ adresse du message 
    ldr r1,[r0]
    add r0,r1
    bl afficherMess                @ appel fonction d'affichage
    
    adr r0,iOfszMessAppelC
    ldr r1,[r0]
    add r4,r0,r1                  @ préparation adresse du format
    
    mov r0,r4                     @ affichage d'un float
    adr r2,iOffNombre1
    ldr r3,[r2]
    add r2,r3                     @ adresse du float
    vldr.f32 s0,[r2]              @ chargement dans le registre 32 bits s0
    vcvt.f64.f32  d0,s0           @ conversion en 64 bits dans le registre d0
    vmov r2,r3,d0                 @ copie pour affichage 
    bl printf 
    

                                  @ affichage d'un double
    mov r0,r4
    adr r2,iOffNombre2            @ adresse du double
    ldr r3,[r2]
    add r2,r3
    vldr.f64 d0,[r2]              @ chargement dans le registre d0 64 bits
    vmov r2,r3,d0                 @ copie pour affichage
    bl printf 

    mov r0,#100                   @ conversion entier
    vmov s2,r0                    @ copie 
    vcvt.f32.s32 s2,s2            @ conversion en float
    vcvt.f64.f32  d0,s2           @ conversion en 64 bits dans le registre d0
    mov r0,r4
    vmov r2,r3,d0                 @ copie pour affichage 
    bl printf 
    
                                  @ addition
    vldr.s64  d0,fnombre3
    adr r2,iOffNombre2            @ adresse du double
    ldr r3,[r2]
    add r2,r3
    vldr.s64 d1,[r2]              @ chargement dans le registre d0 64 bits
    vadd.f64 d0,d1
    mov r0,r4
    vmov r2,r3,d0                 @ copie pour affichage 
    bl printf
                                  @ soustraction
    vldr.s64  d0,fnombre3
    adr r2,iOffNombre2            @ adresse du double
    ldr r3,[r2]
    add r2,r3
    vldr.s64 d1,[r2]              @ chargement dans le registre d0 64 bits
    vsub.f64 d0,d1
    mov r0,r4
    vmov r2,r3,d0                 @ copie pour affichage 
    bl printf
    
                                  @ multiplication
    vldr.s64  d0,fnombre3
    vldr.s64  d1,fnombre4
    vmul.f64 d0,d1
    mov r0,r4
    vmov r2,r3,d0                 @ copie pour affichage 
    bl printf
    
                                  @ division
    vldr.s64  d0,fnombre3
    vldr.s64  d1,fnombre4
    vdiv.f64 d2,d0,d1
    mov r0,r4
    vmov r2,r3,d2                 @ copie pour affichage 
    bl printf
    
    vldr.s64  d2,fnombre5         @ extraction partie entière
    vcvt.s32.f64  s0,d2
    vmov r0,s0
    affreghexa "Entier "
    
                                 @ comparaison
   // vcmp.f64 d1,d2             @ pour tester l'un
    vcmp.f64 d2,d1               @ ou l'autre cas
    vmrs apsr_nzcv,fpscr         @ il faut copier les indicateurs dans le registre d'état
    bge 1f                       @ pour pouvoir les utiliser
    afficherLib "d1 est plus petit que d2."
    b 2f
1:
   afficherLib "d1 est plus grand ou égal que d2."
2:

100:                               @ fin standard du programme
    adr r0,iOfszMessFinPgm        @ adresse du message 
    ldr r1,[r0]
    add r0,r1
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iOfszMessDebPgm:       .int szMessDebPgm - .
iOfszMessFinPgm:       .int szMessFinPgm - .
iOfszRetourLigne:      .int szRetourLigne - .
iOfszMessAppelC:       .int szMessAppelC - .
iOffNombre1:           .int fNombre1 - .
iOffNombre2:           .int fNombre2 - .
fnombre3:              .double 5.1E5
fnombre4:              .double -2.524
fnombre5:              .double  9.54321
