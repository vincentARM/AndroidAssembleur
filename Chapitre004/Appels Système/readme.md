### Appels du système d’exploitation.
Dans l »assembleur ARM, il n’existe pas d’instructions d’entrées sorties. Pour gérér les périphériques, les processeurs ARM utilisent des accès mémoire sur des adresses réservées (voir la documentation arm).

Mais nos programmes assembleur lancés sous linux, ne peuvent pas accéder à ces adresses, ils sont obligés de passer par des appels au système d’exploitation.

Nous avons vu le cas dès le premier programme pour afficher un message où nous avons dû faire appel à la fonction Write de Linux.

La convention d’appel précise que les paramètres sont passés dans les registres x0 à x7, et le code fonction dans le registre x8 . L’appel s’effectue avec l’instruction svc 0 et après l’appel, le code retour se trouve dans le registre x0. Le plus souvent s’il est négatif, il s’agit d’une erreur. Voici une liste des codes habituels :
```
#define EPERM            1      /* Operation not permitted */
#define ENOENT           2      /* No such file or directory */
#define ESRCH            3      /* No such process */
#define EINTR            4      /* Interrupted system call */
#define EIO              5      /* I/O error */
#define ENXIO            6      /* No such device or address */
#define E2BIG            7      /* Arg list too long */
#define ENOEXEC          8      /* Exec format error */
#define EBADF            9      /* Bad file number */
#define ECHILD          10      /* No child processes */
#define EAGAIN          11      /* Try again */
#define ENOMEM          12      /* Out of memory */
#define EACCES          13      /* Permission denied */
#define EFAULT          14      /* Bad address */
#define ENOTBLK         15      /* Block device required */
#define EBUSY           16      /* Device or resource busy */
#define EEXIST          17      /* File exists */
#define EXDEV           18      /* Cross-device link */
#define ENODEV          19      /* No such device */
#define ENOTDIR         20      /* Not a directory */
#define EISDIR          21      /* Is a directory */
#define EINVAL          22      /* Invalid argument */
#define ENFILE          23      /* File table overflow */
#define EMFILE          24      /* Too many open files */
#define ENOTTY          25      /* Not a typewriter */
#define ETXTBSY         26      /* Text file busy */
#define EFBIG           27      /* File too large */
#define ENOSPC          28      /* No space left on device */
#define ESPIPE          29      /* Illegal seek */
#define EROFS           30      /* Read-only file system */
#define EMLINK          31      /* Too many links */
#define EPIPE           32      /* Broken pipe */
#define EDOM            33      /* Math argument out of domain of func */
#define ERANGE          34      /* Math result not representable */
#define EDEADLK         35      /* Resource deadlock would occur */
#define ENAMETOOLONG    36      /* File name too long */
#define ENOLCK          37      /* No record locks available */
#define ENOSYS          38      /* Function not implemented */
#define ENOTEMPTY       39      /* Directory not empty */
#define ELOOP           40      /* Too many symbolic links encountered */
#define EWOULDBLOCK     11  /* Operation would block  idem EAGAIN */
#define ENOMSG          42      /* No message of desired type */
#define EIDRM           43      /* Identifier removed */
#define ECHRNG          44      /* Channel number out of range */
#define EL2NSYNC        45      /* Level 2 not synchronized */
#define EL3HLT          46      /* Level 3 halted */
#define EL3RST          47      /* Level 3 reset */
#define ELNRNG          48      /* Link number out of range */
#define EUNATCH         49      /* Protocol driver not attached */
#define ENOCSI          50      /* No CSI structure available */
#define EL2HLT          51      /* Level 2 halted */
#define EBADE           52      /* Invalid exchange */
#define EBADR           53      /* Invalid request descriptor */
#define EXFULL          54      /* Exchange full */
#define ENOANO          55      /* No anode */
#define EBADRQC         56      /* Invalid request code */
#define EBADSLT         57      /* Invalid slot */
#define EDEADLOCK       35      /* idem EDEADLK
#define EBFONT          59      /* Bad font file format */
#define ENOSTR          60      /* Device not a stream */
#define ENODATA         61      /* No data available */
#define ETIME           62      /* Timer expired */
#define ENOSR           63      /* Out of streams resources */
#define ENONET          64      /* Machine is not on the network */
#define ENOPKG          65      /* Package not installed */
#define EREMOTE         66      /* Object is remote */
#define ENOLINK         67      /* Link has been severed */
#define EADV            68      /* Advertise error */
#define ESRMNT          69      /* Srmount error */
#define ECOMM           70      /* Communication error on send */
#define EPROTO          71      /* Protocol error */
#define EMULTIHOP       72      /* Multihop attempted */
#define EDOTDOT         73      /* RFS specific error */
#define EBADMSG         74      /* Not a data message */
#define EOVERFLOW       75      /* Value too large for defined data type */
#define ENOTUNIQ        76      /* Name not unique on network */
#define EBADFD          77      /* File descriptor in bad state */
#define EREMCHG         78      /* Remote address changed */
#define ELIBACC         79      /* Can not access a needed shared library */
#define ELIBBAD         80      /* Accessing a corrupted shared library */
#define ELIBSCN         81      /* .lib section in a.out corrupted */
#define ELIBMAX         82      /* Attempting to link in too many shared libraries */
#define ELIBEXEC        83      /* Cannot exec a shared library directly */
#define EILSEQ          84      /* Illegal byte sequence */
#define ERESTART        85      /* Interrupted system call should be restarted */
#define ESTRPIPE        86      /* Streams pipe error */
#define EUSERS          87      /* Too many users */
#define ENOTSOCK        88      /* Socket operation on non-socket */
#define EDESTADDRREQ    89      /* Destination address required */
#define EMSGSIZE        90      /* Message too long */
#define EPROTOTYPE      91      /* Protocol wrong type for socket */
#define ENOPROTOOPT     92      /* Protocol not available */
#define EPROTONOSUPPORT 93      /* Protocol not supported */
#define ESOCKTNOSUPPORT 94      /* Socket type not supported */
#define EOPNOTSUPP      95      /* Operation not supported on transport endpoint */
#define EPFNOSUPPORT    96      /* Protocol family not supported */
#define EAFNOSUPPORT    97      /* Address family not supported by protocol */
#define EADDRINUSE      98      /* Address already in use */
#define EADDRNOTAVAIL   99      /* Cannot assign requested address */
#define ENETDOWN        100     /* Network is down */
#define ENETUNREACH     101     /* Network is unreachable */
#define ENETRESET       102     /* Network dropped connection because of reset */
#define ECONNABORTED    103     /* Software caused connection abort */
#define ECONNRESET      104     /* Connection reset by peer */
#define ENOBUFS         105     /* No buffer space available */
#define EISCONN         106     /* Transport endpoint is already connected */
#define ENOTCONN        107     /* Transport endpoint is not connected */
#define ESHUTDOWN       108     /* Cannot send after transport endpoint shutdown */
#define ETOOMANYREFS    109     /* Too many references: cannot splice */
#define ETIMEDOUT       110     /* Connection timed out */
#define ECONNREFUSED    111     /* Connection refused */
#define EHOSTDOWN       112     /* Host is down */
#define EHOSTUNREACH    113     /* No route to host */
#define EALREADY        114     /* Operation already in progress */
#define EINPROGRESS     115     /* Operation now in progress */
#define ESTALE          116     /* Stale NFS file handle */
#define EUCLEAN         117     /* Structure needs cleaning */
#define ENOTNAM         118     /* Not a XENIX named type file */
#define ENAVAIL         119     /* No XENIX semaphores available */
#define EISNAM          120     /* Is a named type file */
#define EREMOTEIO       121     /* Remote I/O error */
#define EDQUOT          122     /* Quota exceeded */
#define ENOMEDIUM       123     /* No medium found */
#define EMEDIUMTYPE     124     /* Wrong medium type */
```

Dans le programme saisie64.s nous allons voir comment lire une chaîne de caractère saisie dans le terminal quel qu’il soit. Ce peut être le clavier du smartphone ou le clavier du terminal sous lequel vous êtes connecté par ssh.

Nous définissons dans la .bss, un buffer avec une taille suffisante pour recueillir les données saisies.

Puis dans le corps du système, nous affichons un libellé indicatif puis nous préparons l’appel système READ (code 63) qui va nous permettre de lire les données saisies.

Rappel : les codes des appels linux 64 bits sont différents des codes 32 bits.

Nous passons un code indiquant la console standard d’entrée Linux (STDIN = 0), l’adresse du buffer de réception et sa taille puis le code fonction (toujours dans le registre x8). Ces paramètres sont trouvés dans la documentation Linux des appels système par exemple :
```C
ssize_t read(int fd, void *buf, size_t count);
```
En retour de l’appel, nous affichons le code retour pour vérification. Normalement il retourne le nombre de caractères saisis ou un nombre négatif s’il y a une erreur de lecture.

Nous affichons ensuite le buffer pour voir le résultat saisi : première surprise, la saisie se termine par le caractère 0xA et non pas par le caractère de fin de chaîne zéro binaire.

Cela signifie qu’il faut remplacer ce caractère par un 0 binaire si nous voulons utiliser cette chaîne dans les routines précédentes.

C’est ce que fait le programme pour effectuer ensuite la comparaison avec le libellé « fin » pour terminer le programme. L’appel système retourne le nombre de caractères saisi (y compris le 0xA final), il faut donc enlever 1 pour avoir le déplacement du dernier caractère.

Voici un exemple d’exécution :
```
Début programme.
Veuillez saisir une chaîne de caractères ou fin :
bonjour
code retour =
Affichage  hexadécimal : 0000000000000008
Aff mémoire  adresse : 0000000000410B00 Memoire
0000000410B00*62 6F 6E 6A 6F 75 72 0A 00 00 00 00 00 00 00 00 bonjour.........
0000000410B10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
Veuillez saisir une chaîne de caractères ou fin :
fin
code retour =
Affichage  hexadécimal : 0000000000000004
Aff mémoire  adresse : 0000000000410B00 Memoire
0000000410B00*66 69 6E 0A 6F 75 72 00 00 00 00 00 00 00 00 00 fin.our.........
0000000410B10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
Fin normale du programme.
```
Un autre exemple concernant les fichiers :

Dans le programme fichier64.s, nous allons voir comment lire un fichier et écrire dans un fichier. Tout d’abord, nous créons dans le répertoire de travail un fichier test1.txt ou nous mettons une dizaine de caractères quelconques.

Nous reprenons la partie saisie du précédent programme pour demander le nom du fichier à lire qui sera stocké dans un buffer.

Puis nous ouvrons le fichier en utilisant l’appel système OPEN (code 56) en passant l’adresse du buffer contenant le nom, un code pour demander l’ouverture en lecture écriture (nous aurions pu demander l’ouverture en lecture seule avec le code .equ O_RDONLY, 0 et un mode à zéro.

Nous testons le code retour et s’il est négatif nous signalons une erreur. Ce test est obligatoire car le fichier peut ne pas exister, ou l’opérateur a pu faire une erreur de saisie.

Si l’ouverture est correcte, le code retour correspond au descripteur de fichier (File Descripor) attribué par le système, FD que nous sauvons dans un registre. Puis nous utilisons l’appel système READ pour lire le fichier dans un buffer de lecture assez grand pour contenir la totalité du fichier.

Nous testons aussi le code retour et s’il est positif, nous l’affichons ainsi que le contenu du buffer de lecture. Vous pouvez constater qu’il contient bien les données du fichier.

Nous continuons en demandant le nom du fichier à écrire et nous le créons en utilisant l’appel système OPEN mais avec des drapeaux (flags) demandant la création. Remarquez que nous passons un code de création en octal et qui correspond aux droits attribués au fichier crée.

Si la création est OK, nous sauvegardons dans un registre le File Descriptor attribué et nous écrivons 10 caractères dans le fichier à partir du buffer de lecture avec l’appel système WRITE.

Si tout se passe bien, nous fermons les 2 fichiers avec l’appel système CLOSE.

Voici l’exécution du programme :
```
Début programme.
Veuillez saisir le nom du fichier à lire :
test1.txt
Code retour =
Affichage  hexadécimal : 0000000000000027
Aff mémoire  adresse : 0000000000411264 Lecture :
0000000411260 00 00 00 00*41 42 43 44 45 46 47 48 49 4A 4B 4C ....ABCDEFGHIJKL
0000000411270 4D 4E 4F 50 51 52 53 54 55 56 0A 31 32 33 34 35 MNOPQRSTUV.12345
0000000411280 36 37 38 39 0A 54 45 53 54 31 0A 00 00 00 00 00 6789.TEST1......
Veuillez saisir le nom du fichier à écrire :
test2.txt
Fin normale du programme.
```
L’affichage du fichier de sortie donne :
```
 more test2.txt
ABCDEFGHIJ
```

Nous trouvons bien les 10 premiers caractères du fichier lu.

Ce programme pose un petit problème : nous devons définir un buffer de lecture avec une taille suffisante pour contenir toutes les données du fichier. Mais hélas nous ne connaissons pas à l’avance quelle doit être la taille maximum.

Pour cela dans le programme fichierStat64.s nous allons exploiter l’appel système STATS (code 80) qui retourne une structure de données contenant des informations sur le fichier dont la taille.

La description de la fonction est de la structure se trouve facilement sur internet par exemple sur ce site :

https://man7.org/linux/man-pages/man2/stat.2.html

Bien sûr, il nous faut créer la structure en assembleur comme vue dans un chapitre précédent en indiquant la taille de chaque donnée. Un affichage du résultat nous donne des indications sur la taille des données.

A partir du programme précédent fichier64.s nous ajoutons un nouvel appel système en passant le FD du fichier demandé et une adresse d’un buffer pour stocker la structure.

Nous affichons le résultat et extrayons la donnée taille que nous affichons . Nous trouvons 0x27 soit 39 en décimal ce qui correspond bien ç la taille du fichier donnée par ls -l test1.txt

Avec cette taille, nous allons réserver une place sur le tas suivant la méthode vue dans le chapitre sur le tas.

Puis nous allons continuer comment dans le programme fichier64.s pour lire les données et écrire les 10 premiers caractères du fichier.

Et là, nous n’avons plus à nous préoccuper de la taille de n’importe quel fichier pouvant être lu.
