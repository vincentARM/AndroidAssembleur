/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme testRoutines64.s */
/* test des routines 64 bits */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits
/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szMessAffBin:        .asciz "Affichage binaire : \n"
szRetourLigne:       .asciz "\n"
szZoneConvBin:       .fill 72,1,' '
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
szZoneConvHexa:         .skip 17
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entry of program 
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    mov x0,0xFF
    bl afficherHexa
    
    ldr x1,qAdrszZoneConvBin
    bl conversion2
    
    ldr x0,qAdrszMessAffBin
    bl afficherMess
    ldr x0,qAdrszZoneConvBin
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess            // et un retour à la ligne
    
    mvn x0,x0
    bl afficherHexa
    
    ldr x1,qAdrszZoneConvBin
    bl conversion2
    
    ldr x0,qAdrszMessAffBin
    bl afficherMess
    ldr x0,qAdrszZoneConvBin
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess            // et un retour à la ligne
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:      .quad szRetourLigne
qAdrszZoneConvBin:     .quad szZoneConvBin
qAdrszMessAffBin:       .quad szMessAffBin
