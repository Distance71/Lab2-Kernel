Compilar un kernel y lanzarlo en QEMU

Ej: kern0-boot

Compilar kern0 y lanzarlo en QEMU tal y como se ha indicado. Responder:

- ¿emite algún aviso el proceso de compilado o enlazado? Si lo hubo, indicar cómo usar la opción --entry de ld(1) para subsanarlo.

Rta: Si, fue ld: 
aviso: no se puede encontrar el símbolo de entrada _start; se usa por defecto 0000000000100000. Se soluciona con –entry y e ingresando un número, como el anterior.

- ¿cuánta CPU consume el proceso qemu-system-i386 mientras ejecuta este kernel? ¿Qué está haciendo?

Rta: 100%. Lo que hace es ejecutar una actividad que mantiene al cpu ocupado, sin hacer nada en cada loop.

Ej: kern0-quit
Asimismo, la combinación Ctrl-a c permite entrar al “monitor” de QEMU, desde donde se puede obtener información adicional sobre el entorno de ejecución. Ejecutar el comando info registers en el monitor de QEMU, e incluir el resultado en la entrega.

EAX=2badb002 EBX=00009500 ECX=00100000 EDX=00000511
ESI=00000000 EDI=00102000 EBP=00000000 ESP=00006f08
EIP=00100000 EFL=00000006 [-----P-] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0010 00000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]
SS =0010 00000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
DS =0010 00000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
FS =0010 00000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
GS =0010 00000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
LDT=0000 00000000 0000ffff 00008200 DPL=0 LDT
TR =0000 00000000 0000ffff 00008b00 DPL=0 TSS32-busy
GDT=     000caa68 00000027
IDT=     00000000 000003ff
CR0=00000011 CR2=00000000 CR3=00000000 CR4=00000000
DR0=00000000 DR1=00000000 DR2=00000000 DR3=00000000 
DR6=ffff0ff0 DR7=00000400
EFER=0000000000000000
FCW=037f FSW=0000 [ST=0] FTW=00 MXCSR=00001f80
FPR0=0000000000000000 0000 FPR1=0000000000000000 0000
FPR2=0000000000000000 0000 FPR3=0000000000000000 0000
FPR4=0000000000000000 0000 FPR5=0000000000000000 0000
FPR6=0000000000000000 0000 FPR7=0000000000000000 0000
XMM00=00000000000000000000000000000000 XMM01=00000000000000000000000000000000
XMM02=00000000000000000000000000000000 XMM03=00000000000000000000000000000000
XMM04=00000000000000000000000000000000 XMM05=00000000000000000000000000000000
XMM06=00000000000000000000000000000000 XMM07=00000000000000000000000000000000

Ej: kern0-hlt

Leer la página de Wikipedia HLT (x86 instruction), y responder:

- una vez invocado hlt ¿cuándo se reanuda la ejecución?

Rta: Una vez que se recibe una solicitud externa, que se traduce en la emisión de una interrupción.

Usar el comando powertop para comprobar el consumo de recursos de ambas versiones del kernel. En particular, para cada versión, anotar:

    columna Usage: fragmento de tiempo usado por QEMU en cada segundo.
    Rta: Uso sin hlt: 998,7 ms/s  Uso con hlt: 3,2 ms/s 

    columna Events/s: número de veces por segundo que QEMU reclama la atención de la CPU.
    Rta: Eventos sin hlt: 150,6  Eventos con hlt: 331,1

Ej: kern0-gdb

Mostrar una sesión de GDB en la que se realicen los siguientes pasos:

    - poner un breakpoint en la función comienzo (p.ej. b comienzo)

    - continuar la ejecución hasta ese punto (c)

    - mostrar el valor del stack pointer en ese momento (p $esp), así como del registro %eax en formato hexadecimal (p/x $eax).
Rta p $esp: $1 = (void *) 0x6f08
Rta p/x $eax: $2 = 0x2badb002

(Opcional: leer la sección Machine state en la documentación de Multiboot para entender el valor peculiar del registro %eax.)

el estándar Multiboot proporciona cierta informacion (Multiboot Information) que se puede consultar desde la función principal vía el registro %ebx. Desde el breakpoint en comienzo imprimir, con el comando x/4xw, los cuatro primeros valores enteros de dicha información, y explicar qué significan. 

Rta:
$ebx:
    0x0000024f      0x0000027f      0x0001fb80      0x8000ffff
    Los primeros 4 bytes se utilizan como flags de configuración.
    Los siguientes 4 bytes se utilizan como dirección inicial de la memoría asignada.
    Los siguientes 4 bytes se utilizan como dirección final de la memoría asignada.
    Los últimos 4 bytes nos dan la información de que bootloader cargó el sistema operativo.

A continuación, usar y mostrar las distintas invocaciones de x/... $ebx + ... necesarias para imprimir:

    - El campo flags en formato binario (x/t ...)
    	Rta: 001001001111 
    
    - La cantidad de memoria “baja” en formato decimal (x/d ...); ¿en qué unidad está?
	Rta: 639, expresada en kiloBytes (x/2dw $ebx)
    - La línea de comandos o “cadena de arranque” recibida por el kernel (x/s ...)
	Rta:
	(gdb) x/5xw $ebx
    	0x9500: 0x0000024f      0x0000027f      0x0001fb80      0x8000ffff
    	0x9510: 0x00103000
    	(gdb) x/s 0x00103000
    	0x103000:       "kern0 " 

El buffer VGA

Ej: kern0-vga

Explicar el código anterior, en particular:

    -Qué se imprime por pantalla al arrancar.
    	Rta: OK en el borde superior izquierdo.
    -Qué representan cada uno de los valores enteros (incluyendo 0xb8000).
    	Rta: Son direcciones especificas del video de la pantalla modificables. El primer byte representa una letra en código ASCII y segundo su color. 0xB8000 es la dirección de memoría de video para monitores de color.
    -Por qué se usa el modificador volatile para el puntero al buffer.
	Rta: Para indicar que la variable no depende solo de lo que se modifique en el programa, ya que se trata de hardware fisicamente modificable.

Ahora, implementar una función más genérica para imprimir en el buffer VGA:

#define LINE_LENGTH 160
#define Q_LINES 24

static void vga_write(const char *s, int linea, int color){
    volatile char *buf = VGABUF;
    unsigned int lineNumber;

    if(abs(linea) > Q_LINES || !s) //No imprime, no se valida color
	return;

    if (linea < 0)
        lineNumber = (Q_LINES + linea) * LINE_LENGTH;
    else
        lineNumber = linea * LINE_LENGTH;

    buf += lineNumber;
    while(*s != '\0'){
	*buf++ = *s++;
	*buf++ = color;
    }
}


Ej: kern0-endian

1.Compilar el siguiente programa y justificar la salida que produce en la terminal
	Rta: imprime He110 World. Esto está relacionado con que 57616 corresponde, en hexadecimal, a e110, y printf permite imprimirlo en este formato. Por otro lado, 0x00646c72 corresponde a los caracteres Ascii de rld y Null, teniendo en cuenta que la arquitectura es little endian. Al leerlo como string, printf permite imprimirlo.

A continuación, reescribir el código para una arquitectura big-endian, de manera que imprima exactamente lo mismo.
	Rta: Es necesario cambiar el orden de los bytes en i y fijar i = 0x726c6400

2.: *p++ = 0x2F4B2F4B;

3.: volatile uint64_t  *p = VGABUF + 160;
    *p = 0xEF41EF4CEF4FEF48;


Llamadas a biblioteca y llamadas al sistema

Ej: x86-write

Sobre el código anterior, responder:

    ¿Por qué se le resta 1 al resultado de sizeof?
	Rta: Porque se trata del tamaño del carácter \0.
    ¿Funcionaría el programa si se declarase msg como const char *msg = "...";? ¿Por qué?
	Rta: No, porque sizeof devuelve el tamaño de lo que contenga en tiempo de compilación.
    El sizeof de un const char* es el tamaño de un puntero, mientras que const char [] devuelve el tamaño de un array.

Compilar ahora libc_hello.S y verificar que funciona correctamente. Explicar el propósito de cada instrucción, y cómo se corresponde con el código C original.
	Rta: -Pushea la variable len con la longitud del string
	     -Pushea el string
	     -Pushea 1, de Stdout
	     -Se invoca la syscall write
	     -Se pushea a la pila el num 7 (código de salida)
	     -Se invoca a la syscall exit
Después:

    Mostrar un hex dump de la salida del programa en assembler. Se puede obtener con el comando od:
0000000  48  65  6c  6c  6f  2c  20  77  6f  72  6c  64  21  0a
          H   e   l   l   o   ,       w   o   r   l   d   !  \n
0000016

Cambiar la directiva .ascii por .asciz y mostrar el hex dump resultante con el nuevo código. ¿Qué está ocurriendo?
Hex dump de ./libc_hello (.asciz):
0000000  48  65  6c  6c  6f  2c  20  77  6f  72  6c  64  21  0a  00
          H   e   l   l   o   ,       w   o   r   l   d   !  \n  \0
0000017

Rta: La diferencia radica en que asciz imprime el caracter '\0' al final del mensaje


Ej: x86-call

Usar el comando stepi (step instruction) para avanzar la ejecución hasta la llamada a write. En ese momento, mostrar los primeros cuatro valores de la pila justo antes e inmediatamente después de ejecutar la instrucción call, y explicar cada uno de ellos.

=> 0x56555579 <main+12>:	call   0xf7ebbd80 <write>
(gdb) x/4xw $sp
0xffffcf60:	0x00000001	0x56557008	0x0000000e	0xf7dede81
(gdb) si
0xf7ebbd80 in write () from /lib/i386-linux-gnu/libc.so.6
1: x/i $pc
=> 0xf7ebbd80 <write>:	push   %esi
(gdb) x/4xw $sp
0xffffcf5c:	0x5655557e	0x00000001	0x56557008	0x0000000e

Explicación: Lo que se puede observar es que luego de la llamada a write se cargó el contenido de la dirección de esi en la pila.

Ej: x86-libc

Se pide:

    Compilar y ejecutar el archivo completo int80_hi.S. Mostrar la salida de nm --undefined para este nuevo binario.
Rta: Salida de nm -u int80_hi:
    agus@agus-HP-Pavilion-dv6-Notebook-PC:~/Escritorio/Fiuba/Repos/SistOp/Lab2-Kernel/punto3$ nm --undefined int80_hi
         w __cxa_finalize@@GLIBC_2.1.3
         w __gmon_start__
         w _ITM_deregisterTMCloneTable
         w _ITM_registerTMCloneTable
         U __libc_start_main@@GLIBC_2.0

Escribir una versión modificada llamada int80_strlen.S en la que, de nuevo eliminando la directiva .set len, se calcule la longitud del mensaje (tercer parámetro para write) usando directamente strlen(3) (el código será muy parecido al de ejercicios anteriores). Mostrar la salida de nm --undefined para este nuevo binario.
Rta: Salida de nm -u int80_strlen:
    agus@agus-HP-Pavilion-dv6-Notebook-PC:~/Escritorio/Fiuba/Repos/SistOp/Lab2-Kernel/punto3$ nm --undefined int80_strlen
         w __cxa_finalize@@GLIBC_2.1.3
         w __gmon_start__
         w _ITM_deregisterTMCloneTable
         w _ITM_registerTMCloneTable
         U __libc_start_main@@GLIBC_2.0
         U strlen@@GLIBC_2.0



En la convención de llamadas de GCC, ciertos registros son caller-saved (por ejemplo %ecx) y ciertos otros callee-saved (por ejemplo %ebx). Responder:

    ¿qué significa que un registro sea callee-saved en lugar de caller-saved?
	Rta: La diferencia radica en que callee-saved, a diferencia de caller-saved, implica que la función que utiliza el registro lo guarda. Esto facilita la llamada a otras funciones, ya que no es necesario guardar un registro desde una función que llamará a otra, para luego poder tenerlo disponible.


    en x86 ¿de qué tipo, caller-saved o callee-saved, es cada registro según la convención de llamadas de GCC?
	Rta: - Caller-saved: EAX, ECX y EDX
    	     - Callee-saved: EBP, EBX, EDI y ESI

Ej: x86-ret

Se pide ahora modificar int80_hi.S para que, en lugar de invocar a a _exit(), la ejecución finalice sencillamente con una instrucción ret. ¿Cómo se pasa en este caso el valor de retorno?

Rta: Se pasa a través del registro eax.

Stack frames y calling conventions

Ej: x86-frames

Responder, en términos del frame pointer %ebp de una función f:

    ¿dónde se encuentra (de haberlo) el primer argumento de f?
	Rta: Se encuentra en ebp+8.
    ¿dónde se encuentra la dirección a la que retorna f cuando ejecute ret?
	Rta: Se encuentra en ebp+4.
    ¿dónde se encuentra el valor de %ebp de la función anterior, que invocó a f?
	Rta:Esto dependera de la cantidad de argumentos de la función anterior. Si fuera solo uno, sería ebp+12.
    ¿dónde se encuentra la dirección a la que retornará la función que invocó a f?
	Rta: Suponiendo un argumento, en ebp+16.

Incluir en la entrega:

    el código de la función backtrace.

void backtrace(){
        int *ebp = (int *) __builtin_frame_address(0);
        ebp = (int*) *ebp;
        int numframe = 1;

        while(ebp){
            printf("#%d [0x%x] 0x%x ( 0x%x 0x%x 0x%x )\n", numframe++, ebp, *(ebp + 1), *(ebp + 2), *(ebp + 3), *(ebp + 4));  
            ebp = (int*) *ebp;
        }
}

    una sesión de GDB en la que se muestre la equivalencia entre el comando bt de GDB y el código implementado; en particular, se debe incluir:

    - la salida del comando bt al entrar en la función backtrace

    - la salida del programa al ejecutarse la función backtrace (el número de frames y sus direcciones de retorno deberían coincidir con la salida de bt)

    - usando los comandos de selección de frames, y antes de salir de la función backtrace, el valor de %ebp en cada marco de ejecución detectado por GDB (valores que también deberían coincidir).

Rta:

(gdb) bt
#0  backtrace () at backtrace.c:5
#1  0x0804855d in my_write (fd=2, msg=0x80486bb, count=15) at backtrace.c:17
#2  0x080485a9 in recurse (level=0) at backtrace.c:26
#3  0x080485ba in recurse (level=1) at backtrace.c:24
#4  0x080485ba in recurse (level=2) at backtrace.c:24
#5  0x080485ba in recurse (level=3) at backtrace.c:24
#6  0x080485ba in recurse (level=4) at backtrace.c:24
#7  0x080485ba in recurse (level=5) at backtrace.c:24
#8  0x080485cc in start_call_tree () at backtrace.c:30
#9  0x080485e7 in main () at backtrace.c:34
(gdb) c
Continuando.
#1 [0xffffce18] 0x80485a9 ( 0x2 0x80486bb 0xf )
#2 [0xffffce38] 0x80485ba ( 0x0 0x0 0x0 )
#3 [0xffffce58] 0x80485ba ( 0x1 0xf63d4e2e 0xf7ffdaf8 )
#4 [0xffffce78] 0x80485ba ( 0x2 0x1 0xf7fd0410 )
#5 [0xffffce98] 0x80485ba ( 0x3 0xca0000 0x0 )
#6 [0xffffceb8] 0x80485ba ( 0x4 0xffffd184 0xf7e054a9 )
#7 [0xffffced8] 0x80485cc ( 0x5 0x0 0xffffcfbc )
#8 [0xffffcef8] 0x80485e7 ( 0xf7fe59b0 0xffffcf20 0x0 )
#9 [0xffffcf08] 0xf7dede81 ( 0xf7fad000 0xf7fad000 0x0 )
=> write(2, 0x80486bb, 15)
Hello, world!
[Inferior 1 (process 6914) exited normally]

Según se logra observar, coinciden.

Ahora, muestros los up, con el valor de %ebp en cada marco de ejecución:

(gdb) up
#1  0x0804855d in my_write (fd=2, msg=0x80486bb, count=15) at backtrace.c:17
17	    backtrace();
(gdb) p/x $ebp
$1 = 0xffffce18
(gdb) up
#2  0x080485a9 in recurse (level=0) at backtrace.c:26
26	        my_write(2, "Hello, world!\n", 15);
(gdb) p/x $ebp
$2 = 0xffffce38
(gdb) up
#3  0x080485ba in recurse (level=1) at backtrace.c:24
24	        recurse(level - 1);
(gdb) p/x $ebp
$3 = 0xffffce58
(gdb) up
#4  0x080485ba in recurse (level=2) at backtrace.c:24
24	        recurse(level - 1);
(gdb) p/x $ebp
$4 = 0xffffce78
(gdb) up
#5  0x080485ba in recurse (level=3) at backtrace.c:24
24	        recurse(level - 1);
(gdb) p/x $ebp
$5 = 0xffffce98
(gdb) up
#6  0x080485ba in recurse (level=4) at backtrace.c:24
24	        recurse(level - 1);
(gdb) p/x $ebp
$6 = 0xffffceb8
(gdb) up
#7  0x080485ba in recurse (level=5) at backtrace.c:24
24	        recurse(level - 1);
(gdb) p/x $ebp
$7 = 0xffffced8
(gdb) up
#8  0x080485cc in start_call_tree () at backtrace.c:30
30	    recurse(5);
(gdb) p/x $ebp
$8 = 0xffffcef8
(gdb) up
#9  0x080485e7 in main () at backtrace.c:34
34	    start_call_tree();
(gdb) p/x $ebp
$9 = 0xffffcf08
(gdb) up
Initial frame selected; you cannot go up.

Ej: x86-argv

sys_argv es la versión más sencilla, ya que el layout de los argumentos en memoria es más simple: argc está en (%esp), y el primer argumento directamente en 8(%esp).

Responder: ¿qué hay en 4(%esp)?
Rta: argv[0], el nombre del programa.

libc introduce un nivel de indirección, pues argc está en 4(%esp) pero en 8(%esp) está la dirección del arreglo de argumentos argv.

Responder: ¿qué hay en (%esp)?

Rta: Lo quise terminar pero se me hizo complicado.

para el bucle de libc_argv2, se recomienda acceder a cada argumento con push (%edi,%ebx,X), habiendo guardado en %edi la dirección de argv, y estando en %ebx el índice de argv a acceder.

Responder: ¿cuántas llamadas al sistema se producen realmente? (Se puede comprobar con breakpoint write e ignore, o usando una herramienta como strace(1).) 

Rta: Lo quise terminar pero se me hizo complicado.
