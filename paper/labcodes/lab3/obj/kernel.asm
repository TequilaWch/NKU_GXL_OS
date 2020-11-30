
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 30 12 00       	mov    $0x123000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 30 12 c0       	mov    %eax,0xc0123000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 20 12 c0       	mov    $0xc0122000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 10 61 12 c0       	mov    $0xc0126110,%edx
c0100041:	b8 00 50 12 c0       	mov    $0xc0125000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 50 12 c0 	movl   $0xc0125000,(%esp)
c010005d:	e8 96 8a 00 00       	call   c0108af8 <memset>

    cons_init();                // init the console
c0100062:	e8 de 1d 00 00       	call   c0101e45 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 93 10 c0 	movl   $0xc01093e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 93 10 c0 	movl   $0xc01093fc,(%esp)
c010007c:	e8 2b 02 00 00       	call   c01002ac <cprintf>

    print_kerninfo();
c0100081:	e8 cc 08 00 00       	call   c0100952 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 98 00 00 00       	call   c0100123 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 1e 3d 00 00       	call   c0103dae <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 15 1f 00 00       	call   c0101faa <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 9a 20 00 00       	call   c0102134 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 4f 59 00 00       	call   c01059ee <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 59 0d 00 00       	call   c0100dfd <ide_init>
    swap_init();                // init swap
c01000a4:	e8 44 63 00 00       	call   c01063ed <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 3a 15 00 00       	call   c01015e8 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 31 20 00 00       	call   c01020e4 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	55                   	push   %ebp
c01000b6:	89 e5                	mov    %esp,%ebp
c01000b8:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c2:	00 
c01000c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ca:	00 
c01000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d2:	e8 bb 0c 00 00       	call   c0100d92 <mon_backtrace>
}
c01000d7:	90                   	nop
c01000d8:	c9                   	leave  
c01000d9:	c3                   	ret    

c01000da <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000da:	55                   	push   %ebp
c01000db:	89 e5                	mov    %esp,%ebp
c01000dd:	53                   	push   %ebx
c01000de:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f9:	89 04 24             	mov    %eax,(%esp)
c01000fc:	e8 b4 ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100101:	90                   	nop
c0100102:	83 c4 14             	add    $0x14,%esp
c0100105:	5b                   	pop    %ebx
c0100106:	5d                   	pop    %ebp
c0100107:	c3                   	ret    

c0100108 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100108:	55                   	push   %ebp
c0100109:	89 e5                	mov    %esp,%ebp
c010010b:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100111:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100115:	8b 45 08             	mov    0x8(%ebp),%eax
c0100118:	89 04 24             	mov    %eax,(%esp)
c010011b:	e8 ba ff ff ff       	call   c01000da <grade_backtrace1>
}
c0100120:	90                   	nop
c0100121:	c9                   	leave  
c0100122:	c3                   	ret    

c0100123 <grade_backtrace>:

void
grade_backtrace(void) {
c0100123:	55                   	push   %ebp
c0100124:	89 e5                	mov    %esp,%ebp
c0100126:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100129:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012e:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100135:	ff 
c0100136:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100141:	e8 c2 ff ff ff       	call   c0100108 <grade_backtrace0>
}
c0100146:	90                   	nop
c0100147:	c9                   	leave  
c0100148:	c3                   	ret    

c0100149 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100149:	55                   	push   %ebp
c010014a:	89 e5                	mov    %esp,%ebp
c010014c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100152:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100155:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100158:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010015b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015f:	83 e0 03             	and    $0x3,%eax
c0100162:	89 c2                	mov    %eax,%edx
c0100164:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c0100169:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100171:	c7 04 24 01 94 10 c0 	movl   $0xc0109401,(%esp)
c0100178:	e8 2f 01 00 00       	call   c01002ac <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100181:	89 c2                	mov    %eax,%edx
c0100183:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c0100188:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100190:	c7 04 24 0f 94 10 c0 	movl   $0xc010940f,(%esp)
c0100197:	e8 10 01 00 00       	call   c01002ac <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a0:	89 c2                	mov    %eax,%edx
c01001a2:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c01001a7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001af:	c7 04 24 1d 94 10 c0 	movl   $0xc010941d,(%esp)
c01001b6:	e8 f1 00 00 00       	call   c01002ac <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001bf:	89 c2                	mov    %eax,%edx
c01001c1:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c01001c6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ce:	c7 04 24 2b 94 10 c0 	movl   $0xc010942b,(%esp)
c01001d5:	e8 d2 00 00 00       	call   c01002ac <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001da:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001de:	89 c2                	mov    %eax,%edx
c01001e0:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c01001e5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ed:	c7 04 24 39 94 10 c0 	movl   $0xc0109439,(%esp)
c01001f4:	e8 b3 00 00 00       	call   c01002ac <cprintf>
    round ++;
c01001f9:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c01001fe:	40                   	inc    %eax
c01001ff:	a3 00 50 12 c0       	mov    %eax,0xc0125000
}
c0100204:	90                   	nop
c0100205:	c9                   	leave  
c0100206:	c3                   	ret    

c0100207 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100207:	55                   	push   %ebp
c0100208:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO  
    asm volatile(
c010020a:	83 ec 08             	sub    $0x8,%esp
c010020d:	cd 78                	int    $0x78
c010020f:	89 ec                	mov    %ebp,%esp
        "movl %%ebp, %%esp;"
        :
        : "i"(T_SWITCH_TOU)
    );
    //cprintf("to user finish \n");
}
c0100211:	90                   	nop
c0100212:	5d                   	pop    %ebp
c0100213:	c3                   	ret    

c0100214 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100214:	55                   	push   %ebp
c0100215:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
c0100217:	cd 79                	int    $0x79
c0100219:	89 ec                	mov    %ebp,%esp
	    "movl %%ebp, %%esp;"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
    //cprintf("to kernel finish \n");
}
c010021b:	90                   	nop
c010021c:	5d                   	pop    %ebp
c010021d:	c3                   	ret    

c010021e <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021e:	55                   	push   %ebp
c010021f:	89 e5                	mov    %esp,%ebp
c0100221:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100224:	e8 20 ff ff ff       	call   c0100149 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100229:	c7 04 24 48 94 10 c0 	movl   $0xc0109448,(%esp)
c0100230:	e8 77 00 00 00       	call   c01002ac <cprintf>
    lab1_switch_to_user();
c0100235:	e8 cd ff ff ff       	call   c0100207 <lab1_switch_to_user>
    lab1_print_cur_status();
c010023a:	e8 0a ff ff ff       	call   c0100149 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023f:	c7 04 24 68 94 10 c0 	movl   $0xc0109468,(%esp)
c0100246:	e8 61 00 00 00       	call   c01002ac <cprintf>
    lab1_switch_to_kernel();
c010024b:	e8 c4 ff ff ff       	call   c0100214 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100250:	e8 f4 fe ff ff       	call   c0100149 <lab1_print_cur_status>
}
c0100255:	90                   	nop
c0100256:	c9                   	leave  
c0100257:	c3                   	ret    

c0100258 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100258:	55                   	push   %ebp
c0100259:	89 e5                	mov    %esp,%ebp
c010025b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010025e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100261:	89 04 24             	mov    %eax,(%esp)
c0100264:	e8 09 1c 00 00       	call   c0101e72 <cons_putc>
    (*cnt) ++;
c0100269:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026c:	8b 00                	mov    (%eax),%eax
c010026e:	8d 50 01             	lea    0x1(%eax),%edx
c0100271:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100274:	89 10                	mov    %edx,(%eax)
}
c0100276:	90                   	nop
c0100277:	c9                   	leave  
c0100278:	c3                   	ret    

c0100279 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100279:	55                   	push   %ebp
c010027a:	89 e5                	mov    %esp,%ebp
c010027c:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010027f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100286:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100289:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010028d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100290:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100294:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100297:	89 44 24 04          	mov    %eax,0x4(%esp)
c010029b:	c7 04 24 58 02 10 c0 	movl   $0xc0100258,(%esp)
c01002a2:	e8 a4 8b 00 00       	call   c0108e4b <vprintfmt>
    return cnt;
c01002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002aa:	c9                   	leave  
c01002ab:	c3                   	ret    

c01002ac <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002ac:	55                   	push   %ebp
c01002ad:	89 e5                	mov    %esp,%ebp
c01002af:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002b2:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c2:	89 04 24             	mov    %eax,(%esp)
c01002c5:	e8 af ff ff ff       	call   c0100279 <vcprintf>
c01002ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002d0:	c9                   	leave  
c01002d1:	c3                   	ret    

c01002d2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002d2:	55                   	push   %ebp
c01002d3:	89 e5                	mov    %esp,%ebp
c01002d5:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01002db:	89 04 24             	mov    %eax,(%esp)
c01002de:	e8 8f 1b 00 00       	call   c0101e72 <cons_putc>
}
c01002e3:	90                   	nop
c01002e4:	c9                   	leave  
c01002e5:	c3                   	ret    

c01002e6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002e6:	55                   	push   %ebp
c01002e7:	89 e5                	mov    %esp,%ebp
c01002e9:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002f3:	eb 13                	jmp    c0100308 <cputs+0x22>
        cputch(c, &cnt);
c01002f5:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002f9:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002fc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100300:	89 04 24             	mov    %eax,(%esp)
c0100303:	e8 50 ff ff ff       	call   c0100258 <cputch>
    while ((c = *str ++) != '\0') {
c0100308:	8b 45 08             	mov    0x8(%ebp),%eax
c010030b:	8d 50 01             	lea    0x1(%eax),%edx
c010030e:	89 55 08             	mov    %edx,0x8(%ebp)
c0100311:	0f b6 00             	movzbl (%eax),%eax
c0100314:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100317:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c010031b:	75 d8                	jne    c01002f5 <cputs+0xf>
    }
    cputch('\n', &cnt);
c010031d:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100320:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100324:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c010032b:	e8 28 ff ff ff       	call   c0100258 <cputch>
    return cnt;
c0100330:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100333:	c9                   	leave  
c0100334:	c3                   	ret    

c0100335 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100335:	55                   	push   %ebp
c0100336:	89 e5                	mov    %esp,%ebp
c0100338:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010033b:	e8 6f 1b 00 00       	call   c0101eaf <cons_getc>
c0100340:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100343:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100347:	74 f2                	je     c010033b <getchar+0x6>
        /* do nothing */;
    return c;
c0100349:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010034c:	c9                   	leave  
c010034d:	c3                   	ret    

c010034e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010034e:	55                   	push   %ebp
c010034f:	89 e5                	mov    %esp,%ebp
c0100351:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100354:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100358:	74 13                	je     c010036d <readline+0x1f>
        cprintf("%s", prompt);
c010035a:	8b 45 08             	mov    0x8(%ebp),%eax
c010035d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100361:	c7 04 24 87 94 10 c0 	movl   $0xc0109487,(%esp)
c0100368:	e8 3f ff ff ff       	call   c01002ac <cprintf>
    }
    int i = 0, c;
c010036d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100374:	e8 bc ff ff ff       	call   c0100335 <getchar>
c0100379:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010037c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100380:	79 07                	jns    c0100389 <readline+0x3b>
            return NULL;
c0100382:	b8 00 00 00 00       	mov    $0x0,%eax
c0100387:	eb 78                	jmp    c0100401 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100389:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010038d:	7e 28                	jle    c01003b7 <readline+0x69>
c010038f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100396:	7f 1f                	jg     c01003b7 <readline+0x69>
            cputchar(c);
c0100398:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010039b:	89 04 24             	mov    %eax,(%esp)
c010039e:	e8 2f ff ff ff       	call   c01002d2 <cputchar>
            buf[i ++] = c;
c01003a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003a6:	8d 50 01             	lea    0x1(%eax),%edx
c01003a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003af:	88 90 20 50 12 c0    	mov    %dl,-0x3fedafe0(%eax)
c01003b5:	eb 45                	jmp    c01003fc <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003b7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003bb:	75 16                	jne    c01003d3 <readline+0x85>
c01003bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003c1:	7e 10                	jle    c01003d3 <readline+0x85>
            cputchar(c);
c01003c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c6:	89 04 24             	mov    %eax,(%esp)
c01003c9:	e8 04 ff ff ff       	call   c01002d2 <cputchar>
            i --;
c01003ce:	ff 4d f4             	decl   -0xc(%ebp)
c01003d1:	eb 29                	jmp    c01003fc <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003d3:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003d7:	74 06                	je     c01003df <readline+0x91>
c01003d9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003dd:	75 95                	jne    c0100374 <readline+0x26>
            cputchar(c);
c01003df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003e2:	89 04 24             	mov    %eax,(%esp)
c01003e5:	e8 e8 fe ff ff       	call   c01002d2 <cputchar>
            buf[i] = '\0';
c01003ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ed:	05 20 50 12 c0       	add    $0xc0125020,%eax
c01003f2:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f5:	b8 20 50 12 c0       	mov    $0xc0125020,%eax
c01003fa:	eb 05                	jmp    c0100401 <readline+0xb3>
        c = getchar();
c01003fc:	e9 73 ff ff ff       	jmp    c0100374 <readline+0x26>
        }
    }
}
c0100401:	c9                   	leave  
c0100402:	c3                   	ret    

c0100403 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100403:	55                   	push   %ebp
c0100404:	89 e5                	mov    %esp,%ebp
c0100406:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100409:	a1 20 54 12 c0       	mov    0xc0125420,%eax
c010040e:	85 c0                	test   %eax,%eax
c0100410:	75 5b                	jne    c010046d <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100412:	c7 05 20 54 12 c0 01 	movl   $0x1,0xc0125420
c0100419:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010041c:	8d 45 14             	lea    0x14(%ebp),%eax
c010041f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100422:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100425:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100429:	8b 45 08             	mov    0x8(%ebp),%eax
c010042c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100430:	c7 04 24 8a 94 10 c0 	movl   $0xc010948a,(%esp)
c0100437:	e8 70 fe ff ff       	call   c01002ac <cprintf>
    vcprintf(fmt, ap);
c010043c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010043f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100443:	8b 45 10             	mov    0x10(%ebp),%eax
c0100446:	89 04 24             	mov    %eax,(%esp)
c0100449:	e8 2b fe ff ff       	call   c0100279 <vcprintf>
    cprintf("\n");
c010044e:	c7 04 24 a6 94 10 c0 	movl   $0xc01094a6,(%esp)
c0100455:	e8 52 fe ff ff       	call   c01002ac <cprintf>
    
    cprintf("stack trackback:\n");
c010045a:	c7 04 24 a8 94 10 c0 	movl   $0xc01094a8,(%esp)
c0100461:	e8 46 fe ff ff       	call   c01002ac <cprintf>
    print_stackframe();
c0100466:	e8 32 06 00 00       	call   c0100a9d <print_stackframe>
c010046b:	eb 01                	jmp    c010046e <__panic+0x6b>
        goto panic_dead;
c010046d:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c010046e:	e8 78 1c 00 00       	call   c01020eb <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100473:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010047a:	e8 46 08 00 00       	call   c0100cc5 <kmonitor>
c010047f:	eb f2                	jmp    c0100473 <__panic+0x70>

c0100481 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100481:	55                   	push   %ebp
c0100482:	89 e5                	mov    %esp,%ebp
c0100484:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100487:	8d 45 14             	lea    0x14(%ebp),%eax
c010048a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010048d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100490:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100494:	8b 45 08             	mov    0x8(%ebp),%eax
c0100497:	89 44 24 04          	mov    %eax,0x4(%esp)
c010049b:	c7 04 24 ba 94 10 c0 	movl   $0xc01094ba,(%esp)
c01004a2:	e8 05 fe ff ff       	call   c01002ac <cprintf>
    vcprintf(fmt, ap);
c01004a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004ae:	8b 45 10             	mov    0x10(%ebp),%eax
c01004b1:	89 04 24             	mov    %eax,(%esp)
c01004b4:	e8 c0 fd ff ff       	call   c0100279 <vcprintf>
    cprintf("\n");
c01004b9:	c7 04 24 a6 94 10 c0 	movl   $0xc01094a6,(%esp)
c01004c0:	e8 e7 fd ff ff       	call   c01002ac <cprintf>
    va_end(ap);
}
c01004c5:	90                   	nop
c01004c6:	c9                   	leave  
c01004c7:	c3                   	ret    

c01004c8 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004c8:	55                   	push   %ebp
c01004c9:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004cb:	a1 20 54 12 c0       	mov    0xc0125420,%eax
}
c01004d0:	5d                   	pop    %ebp
c01004d1:	c3                   	ret    

c01004d2 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004d2:	55                   	push   %ebp
c01004d3:	89 e5                	mov    %esp,%ebp
c01004d5:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004db:	8b 00                	mov    (%eax),%eax
c01004dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e3:	8b 00                	mov    (%eax),%eax
c01004e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004ef:	e9 ca 00 00 00       	jmp    c01005be <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004fa:	01 d0                	add    %edx,%eax
c01004fc:	89 c2                	mov    %eax,%edx
c01004fe:	c1 ea 1f             	shr    $0x1f,%edx
c0100501:	01 d0                	add    %edx,%eax
c0100503:	d1 f8                	sar    %eax
c0100505:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100508:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010050b:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010050e:	eb 03                	jmp    c0100513 <stab_binsearch+0x41>
            m --;
c0100510:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100513:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100516:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100519:	7c 1f                	jl     c010053a <stab_binsearch+0x68>
c010051b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051e:	89 d0                	mov    %edx,%eax
c0100520:	01 c0                	add    %eax,%eax
c0100522:	01 d0                	add    %edx,%eax
c0100524:	c1 e0 02             	shl    $0x2,%eax
c0100527:	89 c2                	mov    %eax,%edx
c0100529:	8b 45 08             	mov    0x8(%ebp),%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100532:	0f b6 c0             	movzbl %al,%eax
c0100535:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100538:	75 d6                	jne    c0100510 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c010053a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010053d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100540:	7d 09                	jge    c010054b <stab_binsearch+0x79>
            l = true_m + 1;
c0100542:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100545:	40                   	inc    %eax
c0100546:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100549:	eb 73                	jmp    c01005be <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010054b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100552:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100555:	89 d0                	mov    %edx,%eax
c0100557:	01 c0                	add    %eax,%eax
c0100559:	01 d0                	add    %edx,%eax
c010055b:	c1 e0 02             	shl    $0x2,%eax
c010055e:	89 c2                	mov    %eax,%edx
c0100560:	8b 45 08             	mov    0x8(%ebp),%eax
c0100563:	01 d0                	add    %edx,%eax
c0100565:	8b 40 08             	mov    0x8(%eax),%eax
c0100568:	39 45 18             	cmp    %eax,0x18(%ebp)
c010056b:	76 11                	jbe    c010057e <stab_binsearch+0xac>
            *region_left = m;
c010056d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100570:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100573:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100575:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100578:	40                   	inc    %eax
c0100579:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010057c:	eb 40                	jmp    c01005be <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c010057e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100581:	89 d0                	mov    %edx,%eax
c0100583:	01 c0                	add    %eax,%eax
c0100585:	01 d0                	add    %edx,%eax
c0100587:	c1 e0 02             	shl    $0x2,%eax
c010058a:	89 c2                	mov    %eax,%edx
c010058c:	8b 45 08             	mov    0x8(%ebp),%eax
c010058f:	01 d0                	add    %edx,%eax
c0100591:	8b 40 08             	mov    0x8(%eax),%eax
c0100594:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100597:	73 14                	jae    c01005ad <stab_binsearch+0xdb>
            *region_right = m - 1;
c0100599:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010059f:	8b 45 10             	mov    0x10(%ebp),%eax
c01005a2:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a7:	48                   	dec    %eax
c01005a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005ab:	eb 11                	jmp    c01005be <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b3:	89 10                	mov    %edx,(%eax)
            l = m;
c01005b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005bb:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01005be:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005c1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005c4:	0f 8e 2a ff ff ff    	jle    c01004f4 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005ce:	75 0f                	jne    c01005df <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d3:	8b 00                	mov    (%eax),%eax
c01005d5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005d8:	8b 45 10             	mov    0x10(%ebp),%eax
c01005db:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005dd:	eb 3e                	jmp    c010061d <stab_binsearch+0x14b>
        l = *region_right;
c01005df:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e2:	8b 00                	mov    (%eax),%eax
c01005e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005e7:	eb 03                	jmp    c01005ec <stab_binsearch+0x11a>
c01005e9:	ff 4d fc             	decl   -0x4(%ebp)
c01005ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ef:	8b 00                	mov    (%eax),%eax
c01005f1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01005f4:	7e 1f                	jle    c0100615 <stab_binsearch+0x143>
c01005f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005f9:	89 d0                	mov    %edx,%eax
c01005fb:	01 c0                	add    %eax,%eax
c01005fd:	01 d0                	add    %edx,%eax
c01005ff:	c1 e0 02             	shl    $0x2,%eax
c0100602:	89 c2                	mov    %eax,%edx
c0100604:	8b 45 08             	mov    0x8(%ebp),%eax
c0100607:	01 d0                	add    %edx,%eax
c0100609:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010060d:	0f b6 c0             	movzbl %al,%eax
c0100610:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100613:	75 d4                	jne    c01005e9 <stab_binsearch+0x117>
        *region_left = l;
c0100615:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100618:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010061b:	89 10                	mov    %edx,(%eax)
}
c010061d:	90                   	nop
c010061e:	c9                   	leave  
c010061f:	c3                   	ret    

c0100620 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100620:	55                   	push   %ebp
c0100621:	89 e5                	mov    %esp,%ebp
c0100623:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100626:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100629:	c7 00 d8 94 10 c0    	movl   $0xc01094d8,(%eax)
    info->eip_line = 0;
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100639:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063c:	c7 40 08 d8 94 10 c0 	movl   $0xc01094d8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100643:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100646:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010064d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100650:	8b 55 08             	mov    0x8(%ebp),%edx
c0100653:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100656:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100659:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100660:	c7 45 f4 24 b6 10 c0 	movl   $0xc010b624,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100667:	c7 45 f0 e0 b6 11 c0 	movl   $0xc011b6e0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010066e:	c7 45 ec e1 b6 11 c0 	movl   $0xc011b6e1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100675:	c7 45 e8 b8 f1 11 c0 	movl   $0xc011f1b8,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010067c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100682:	76 0b                	jbe    c010068f <debuginfo_eip+0x6f>
c0100684:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100687:	48                   	dec    %eax
c0100688:	0f b6 00             	movzbl (%eax),%eax
c010068b:	84 c0                	test   %al,%al
c010068d:	74 0a                	je     c0100699 <debuginfo_eip+0x79>
        return -1;
c010068f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100694:	e9 b7 02 00 00       	jmp    c0100950 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100699:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01006a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a6:	29 c2                	sub    %eax,%edx
c01006a8:	89 d0                	mov    %edx,%eax
c01006aa:	c1 f8 02             	sar    $0x2,%eax
c01006ad:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006b3:	48                   	dec    %eax
c01006b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01006ba:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006be:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006c5:	00 
c01006c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006c9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d7:	89 04 24             	mov    %eax,(%esp)
c01006da:	e8 f3 fd ff ff       	call   c01004d2 <stab_binsearch>
    if (lfile == 0)
c01006df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e2:	85 c0                	test   %eax,%eax
c01006e4:	75 0a                	jne    c01006f0 <debuginfo_eip+0xd0>
        return -1;
c01006e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006eb:	e9 60 02 00 00       	jmp    c0100950 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01006ff:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100703:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010070a:	00 
c010070b:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010070e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100712:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100715:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100719:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010071c:	89 04 24             	mov    %eax,(%esp)
c010071f:	e8 ae fd ff ff       	call   c01004d2 <stab_binsearch>

    if (lfun <= rfun) {
c0100724:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100727:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010072a:	39 c2                	cmp    %eax,%edx
c010072c:	7f 7c                	jg     c01007aa <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010072e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100731:	89 c2                	mov    %eax,%edx
c0100733:	89 d0                	mov    %edx,%eax
c0100735:	01 c0                	add    %eax,%eax
c0100737:	01 d0                	add    %edx,%eax
c0100739:	c1 e0 02             	shl    $0x2,%eax
c010073c:	89 c2                	mov    %eax,%edx
c010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100741:	01 d0                	add    %edx,%eax
c0100743:	8b 00                	mov    (%eax),%eax
c0100745:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100748:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010074b:	29 d1                	sub    %edx,%ecx
c010074d:	89 ca                	mov    %ecx,%edx
c010074f:	39 d0                	cmp    %edx,%eax
c0100751:	73 22                	jae    c0100775 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100753:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100756:	89 c2                	mov    %eax,%edx
c0100758:	89 d0                	mov    %edx,%eax
c010075a:	01 c0                	add    %eax,%eax
c010075c:	01 d0                	add    %edx,%eax
c010075e:	c1 e0 02             	shl    $0x2,%eax
c0100761:	89 c2                	mov    %eax,%edx
c0100763:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100766:	01 d0                	add    %edx,%eax
c0100768:	8b 10                	mov    (%eax),%edx
c010076a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010076d:	01 c2                	add    %eax,%edx
c010076f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100772:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100775:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100778:	89 c2                	mov    %eax,%edx
c010077a:	89 d0                	mov    %edx,%eax
c010077c:	01 c0                	add    %eax,%eax
c010077e:	01 d0                	add    %edx,%eax
c0100780:	c1 e0 02             	shl    $0x2,%eax
c0100783:	89 c2                	mov    %eax,%edx
c0100785:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100788:	01 d0                	add    %edx,%eax
c010078a:	8b 50 08             	mov    0x8(%eax),%edx
c010078d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100790:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100793:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100796:	8b 40 10             	mov    0x10(%eax),%eax
c0100799:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010079c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010079f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007a8:	eb 15                	jmp    c01007bf <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ad:	8b 55 08             	mov    0x8(%ebp),%edx
c01007b0:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c2:	8b 40 08             	mov    0x8(%eax),%eax
c01007c5:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007cc:	00 
c01007cd:	89 04 24             	mov    %eax,(%esp)
c01007d0:	e8 9f 81 00 00       	call   c0108974 <strfind>
c01007d5:	89 c2                	mov    %eax,%edx
c01007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007da:	8b 40 08             	mov    0x8(%eax),%eax
c01007dd:	29 c2                	sub    %eax,%edx
c01007df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e2:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01007e8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007ec:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007f3:	00 
c01007f4:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007f7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007fb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100802:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100805:	89 04 24             	mov    %eax,(%esp)
c0100808:	e8 c5 fc ff ff       	call   c01004d2 <stab_binsearch>
    if (lline <= rline) {
c010080d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100810:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100813:	39 c2                	cmp    %eax,%edx
c0100815:	7f 23                	jg     c010083a <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c0100817:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010081a:	89 c2                	mov    %eax,%edx
c010081c:	89 d0                	mov    %edx,%eax
c010081e:	01 c0                	add    %eax,%eax
c0100820:	01 d0                	add    %edx,%eax
c0100822:	c1 e0 02             	shl    $0x2,%eax
c0100825:	89 c2                	mov    %eax,%edx
c0100827:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010082a:	01 d0                	add    %edx,%eax
c010082c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100830:	89 c2                	mov    %eax,%edx
c0100832:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100835:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100838:	eb 11                	jmp    c010084b <debuginfo_eip+0x22b>
        return -1;
c010083a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010083f:	e9 0c 01 00 00       	jmp    c0100950 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100847:	48                   	dec    %eax
c0100848:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c010084b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100851:	39 c2                	cmp    %eax,%edx
c0100853:	7c 56                	jl     c01008ab <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c0100855:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100858:	89 c2                	mov    %eax,%edx
c010085a:	89 d0                	mov    %edx,%eax
c010085c:	01 c0                	add    %eax,%eax
c010085e:	01 d0                	add    %edx,%eax
c0100860:	c1 e0 02             	shl    $0x2,%eax
c0100863:	89 c2                	mov    %eax,%edx
c0100865:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100868:	01 d0                	add    %edx,%eax
c010086a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086e:	3c 84                	cmp    $0x84,%al
c0100870:	74 39                	je     c01008ab <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100872:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100875:	89 c2                	mov    %eax,%edx
c0100877:	89 d0                	mov    %edx,%eax
c0100879:	01 c0                	add    %eax,%eax
c010087b:	01 d0                	add    %edx,%eax
c010087d:	c1 e0 02             	shl    $0x2,%eax
c0100880:	89 c2                	mov    %eax,%edx
c0100882:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100885:	01 d0                	add    %edx,%eax
c0100887:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010088b:	3c 64                	cmp    $0x64,%al
c010088d:	75 b5                	jne    c0100844 <debuginfo_eip+0x224>
c010088f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100892:	89 c2                	mov    %eax,%edx
c0100894:	89 d0                	mov    %edx,%eax
c0100896:	01 c0                	add    %eax,%eax
c0100898:	01 d0                	add    %edx,%eax
c010089a:	c1 e0 02             	shl    $0x2,%eax
c010089d:	89 c2                	mov    %eax,%edx
c010089f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a2:	01 d0                	add    %edx,%eax
c01008a4:	8b 40 08             	mov    0x8(%eax),%eax
c01008a7:	85 c0                	test   %eax,%eax
c01008a9:	74 99                	je     c0100844 <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008b1:	39 c2                	cmp    %eax,%edx
c01008b3:	7c 46                	jl     c01008fb <debuginfo_eip+0x2db>
c01008b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b8:	89 c2                	mov    %eax,%edx
c01008ba:	89 d0                	mov    %edx,%eax
c01008bc:	01 c0                	add    %eax,%eax
c01008be:	01 d0                	add    %edx,%eax
c01008c0:	c1 e0 02             	shl    $0x2,%eax
c01008c3:	89 c2                	mov    %eax,%edx
c01008c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c8:	01 d0                	add    %edx,%eax
c01008ca:	8b 00                	mov    (%eax),%eax
c01008cc:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008d2:	29 d1                	sub    %edx,%ecx
c01008d4:	89 ca                	mov    %ecx,%edx
c01008d6:	39 d0                	cmp    %edx,%eax
c01008d8:	73 21                	jae    c01008fb <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008dd:	89 c2                	mov    %eax,%edx
c01008df:	89 d0                	mov    %edx,%eax
c01008e1:	01 c0                	add    %eax,%eax
c01008e3:	01 d0                	add    %edx,%eax
c01008e5:	c1 e0 02             	shl    $0x2,%eax
c01008e8:	89 c2                	mov    %eax,%edx
c01008ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ed:	01 d0                	add    %edx,%eax
c01008ef:	8b 10                	mov    (%eax),%edx
c01008f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008f4:	01 c2                	add    %eax,%edx
c01008f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100901:	39 c2                	cmp    %eax,%edx
c0100903:	7d 46                	jge    c010094b <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c0100905:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100908:	40                   	inc    %eax
c0100909:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010090c:	eb 16                	jmp    c0100924 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010090e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100911:	8b 40 14             	mov    0x14(%eax),%eax
c0100914:	8d 50 01             	lea    0x1(%eax),%edx
c0100917:	8b 45 0c             	mov    0xc(%ebp),%eax
c010091a:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c010091d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100920:	40                   	inc    %eax
c0100921:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100924:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100927:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c010092a:	39 c2                	cmp    %eax,%edx
c010092c:	7d 1d                	jge    c010094b <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010092e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100931:	89 c2                	mov    %eax,%edx
c0100933:	89 d0                	mov    %edx,%eax
c0100935:	01 c0                	add    %eax,%eax
c0100937:	01 d0                	add    %edx,%eax
c0100939:	c1 e0 02             	shl    $0x2,%eax
c010093c:	89 c2                	mov    %eax,%edx
c010093e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100941:	01 d0                	add    %edx,%eax
c0100943:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100947:	3c a0                	cmp    $0xa0,%al
c0100949:	74 c3                	je     c010090e <debuginfo_eip+0x2ee>
        }
    }
    return 0;
c010094b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100950:	c9                   	leave  
c0100951:	c3                   	ret    

c0100952 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100952:	55                   	push   %ebp
c0100953:	89 e5                	mov    %esp,%ebp
c0100955:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100958:	c7 04 24 e2 94 10 c0 	movl   $0xc01094e2,(%esp)
c010095f:	e8 48 f9 ff ff       	call   c01002ac <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100964:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c010096b:	c0 
c010096c:	c7 04 24 fb 94 10 c0 	movl   $0xc01094fb,(%esp)
c0100973:	e8 34 f9 ff ff       	call   c01002ac <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100978:	c7 44 24 04 cf 93 10 	movl   $0xc01093cf,0x4(%esp)
c010097f:	c0 
c0100980:	c7 04 24 13 95 10 c0 	movl   $0xc0109513,(%esp)
c0100987:	e8 20 f9 ff ff       	call   c01002ac <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c010098c:	c7 44 24 04 00 50 12 	movl   $0xc0125000,0x4(%esp)
c0100993:	c0 
c0100994:	c7 04 24 2b 95 10 c0 	movl   $0xc010952b,(%esp)
c010099b:	e8 0c f9 ff ff       	call   c01002ac <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009a0:	c7 44 24 04 10 61 12 	movl   $0xc0126110,0x4(%esp)
c01009a7:	c0 
c01009a8:	c7 04 24 43 95 10 c0 	movl   $0xc0109543,(%esp)
c01009af:	e8 f8 f8 ff ff       	call   c01002ac <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009b4:	b8 10 61 12 c0       	mov    $0xc0126110,%eax
c01009b9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009bf:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009c4:	29 c2                	sub    %eax,%edx
c01009c6:	89 d0                	mov    %edx,%eax
c01009c8:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009ce:	85 c0                	test   %eax,%eax
c01009d0:	0f 48 c2             	cmovs  %edx,%eax
c01009d3:	c1 f8 0a             	sar    $0xa,%eax
c01009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009da:	c7 04 24 5c 95 10 c0 	movl   $0xc010955c,(%esp)
c01009e1:	e8 c6 f8 ff ff       	call   c01002ac <cprintf>
}
c01009e6:	90                   	nop
c01009e7:	c9                   	leave  
c01009e8:	c3                   	ret    

c01009e9 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009e9:	55                   	push   %ebp
c01009ea:	89 e5                	mov    %esp,%ebp
c01009ec:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009f2:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01009fc:	89 04 24             	mov    %eax,(%esp)
c01009ff:	e8 1c fc ff ff       	call   c0100620 <debuginfo_eip>
c0100a04:	85 c0                	test   %eax,%eax
c0100a06:	74 15                	je     c0100a1d <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a08:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0f:	c7 04 24 86 95 10 c0 	movl   $0xc0109586,(%esp)
c0100a16:	e8 91 f8 ff ff       	call   c01002ac <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a1b:	eb 6c                	jmp    c0100a89 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a24:	eb 1b                	jmp    c0100a41 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a2c:	01 d0                	add    %edx,%eax
c0100a2e:	0f b6 00             	movzbl (%eax),%eax
c0100a31:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a3a:	01 ca                	add    %ecx,%edx
c0100a3c:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a3e:	ff 45 f4             	incl   -0xc(%ebp)
c0100a41:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a44:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a47:	7c dd                	jl     c0100a26 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a49:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a52:	01 d0                	add    %edx,%eax
c0100a54:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a57:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a5a:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a5d:	89 d1                	mov    %edx,%ecx
c0100a5f:	29 c1                	sub    %eax,%ecx
c0100a61:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a64:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a67:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a6b:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a71:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a75:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a7d:	c7 04 24 a2 95 10 c0 	movl   $0xc01095a2,(%esp)
c0100a84:	e8 23 f8 ff ff       	call   c01002ac <cprintf>
}
c0100a89:	90                   	nop
c0100a8a:	c9                   	leave  
c0100a8b:	c3                   	ret    

c0100a8c <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a8c:	55                   	push   %ebp
c0100a8d:	89 e5                	mov    %esp,%ebp
c0100a8f:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a92:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a95:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a98:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a9b:	c9                   	leave  
c0100a9c:	c3                   	ret    

c0100a9d <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a9d:	55                   	push   %ebp
c0100a9e:	89 e5                	mov    %esp,%ebp
c0100aa0:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100aa3:	89 e8                	mov    %ebp,%eax
c0100aa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c0100aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c0100aae:	e8 d9 ff ff ff       	call   c0100a8c <read_eip>
c0100ab3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c0100ab6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100abd:	e9 84 00 00 00       	jmp    c0100b46 <print_stackframe+0xa9>
    	cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c0100ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ac5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100acc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad0:	c7 04 24 b4 95 10 c0 	movl   $0xc01095b4,(%esp)
c0100ad7:	e8 d0 f7 ff ff       	call   c01002ac <cprintf>
    	uint32_t *calling_arguments = (uint32_t *) ebp + 2;
c0100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adf:	83 c0 08             	add    $0x8,%eax
c0100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    	for(int j=0;j<4;j++)
c0100ae5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100aec:	eb 24                	jmp    c0100b12 <print_stackframe+0x75>
    		cprintf(" 0x%08x ", calling_arguments[j]);		
c0100aee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100af1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100af8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100afb:	01 d0                	add    %edx,%eax
c0100afd:	8b 00                	mov    (%eax),%eax
c0100aff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b03:	c7 04 24 d0 95 10 c0 	movl   $0xc01095d0,(%esp)
c0100b0a:	e8 9d f7 ff ff       	call   c01002ac <cprintf>
    	for(int j=0;j<4;j++)
c0100b0f:	ff 45 e8             	incl   -0x18(%ebp)
c0100b12:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b16:	7e d6                	jle    c0100aee <print_stackframe+0x51>
        cprintf("\n");
c0100b18:	c7 04 24 d9 95 10 c0 	movl   $0xc01095d9,(%esp)
c0100b1f:	e8 88 f7 ff ff       	call   c01002ac <cprintf>
		print_debuginfo(eip-1);
c0100b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b27:	48                   	dec    %eax
c0100b28:	89 04 24             	mov    %eax,(%esp)
c0100b2b:	e8 b9 fe ff ff       	call   c01009e9 <print_debuginfo>
    	eip = ((uint32_t *)ebp)[1];
c0100b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b33:	83 c0 04             	add    $0x4,%eax
c0100b36:	8b 00                	mov    (%eax),%eax
c0100b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
    	ebp = ((uint32_t *)ebp)[0];
c0100b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b3e:	8b 00                	mov    (%eax),%eax
c0100b40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c0100b43:	ff 45 ec             	incl   -0x14(%ebp)
c0100b46:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b4a:	7f 0a                	jg     c0100b56 <print_stackframe+0xb9>
c0100b4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b50:	0f 85 6c ff ff ff    	jne    c0100ac2 <print_stackframe+0x25>
	}
}
c0100b56:	90                   	nop
c0100b57:	c9                   	leave  
c0100b58:	c3                   	ret    

c0100b59 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b59:	55                   	push   %ebp
c0100b5a:	89 e5                	mov    %esp,%ebp
c0100b5c:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b66:	eb 0c                	jmp    c0100b74 <parse+0x1b>
            *buf ++ = '\0';
c0100b68:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6b:	8d 50 01             	lea    0x1(%eax),%edx
c0100b6e:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b71:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b74:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b77:	0f b6 00             	movzbl (%eax),%eax
c0100b7a:	84 c0                	test   %al,%al
c0100b7c:	74 1d                	je     c0100b9b <parse+0x42>
c0100b7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b81:	0f b6 00             	movzbl (%eax),%eax
c0100b84:	0f be c0             	movsbl %al,%eax
c0100b87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b8b:	c7 04 24 5c 96 10 c0 	movl   $0xc010965c,(%esp)
c0100b92:	e8 ab 7d 00 00       	call   c0108942 <strchr>
c0100b97:	85 c0                	test   %eax,%eax
c0100b99:	75 cd                	jne    c0100b68 <parse+0xf>
        }
        if (*buf == '\0') {
c0100b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9e:	0f b6 00             	movzbl (%eax),%eax
c0100ba1:	84 c0                	test   %al,%al
c0100ba3:	74 65                	je     c0100c0a <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ba5:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ba9:	75 14                	jne    c0100bbf <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bab:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bb2:	00 
c0100bb3:	c7 04 24 61 96 10 c0 	movl   $0xc0109661,(%esp)
c0100bba:	e8 ed f6 ff ff       	call   c01002ac <cprintf>
        }
        argv[argc ++] = buf;
c0100bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc2:	8d 50 01             	lea    0x1(%eax),%edx
c0100bc5:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bc8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bd2:	01 c2                	add    %eax,%edx
c0100bd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd7:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bd9:	eb 03                	jmp    c0100bde <parse+0x85>
            buf ++;
c0100bdb:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be1:	0f b6 00             	movzbl (%eax),%eax
c0100be4:	84 c0                	test   %al,%al
c0100be6:	74 8c                	je     c0100b74 <parse+0x1b>
c0100be8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100beb:	0f b6 00             	movzbl (%eax),%eax
c0100bee:	0f be c0             	movsbl %al,%eax
c0100bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf5:	c7 04 24 5c 96 10 c0 	movl   $0xc010965c,(%esp)
c0100bfc:	e8 41 7d 00 00       	call   c0108942 <strchr>
c0100c01:	85 c0                	test   %eax,%eax
c0100c03:	74 d6                	je     c0100bdb <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c05:	e9 6a ff ff ff       	jmp    c0100b74 <parse+0x1b>
            break;
c0100c0a:	90                   	nop
        }
    }
    return argc;
c0100c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c0e:	c9                   	leave  
c0100c0f:	c3                   	ret    

c0100c10 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c10:	55                   	push   %ebp
c0100c11:	89 e5                	mov    %esp,%ebp
c0100c13:	53                   	push   %ebx
c0100c14:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c17:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c21:	89 04 24             	mov    %eax,(%esp)
c0100c24:	e8 30 ff ff ff       	call   c0100b59 <parse>
c0100c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c30:	75 0a                	jne    c0100c3c <runcmd+0x2c>
        return 0;
c0100c32:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c37:	e9 83 00 00 00       	jmp    c0100cbf <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c43:	eb 5a                	jmp    c0100c9f <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c45:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c48:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c4b:	89 d0                	mov    %edx,%eax
c0100c4d:	01 c0                	add    %eax,%eax
c0100c4f:	01 d0                	add    %edx,%eax
c0100c51:	c1 e0 02             	shl    $0x2,%eax
c0100c54:	05 00 20 12 c0       	add    $0xc0122000,%eax
c0100c59:	8b 00                	mov    (%eax),%eax
c0100c5b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c5f:	89 04 24             	mov    %eax,(%esp)
c0100c62:	e8 3e 7c 00 00       	call   c01088a5 <strcmp>
c0100c67:	85 c0                	test   %eax,%eax
c0100c69:	75 31                	jne    c0100c9c <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c6e:	89 d0                	mov    %edx,%eax
c0100c70:	01 c0                	add    %eax,%eax
c0100c72:	01 d0                	add    %edx,%eax
c0100c74:	c1 e0 02             	shl    $0x2,%eax
c0100c77:	05 08 20 12 c0       	add    $0xc0122008,%eax
c0100c7c:	8b 10                	mov    (%eax),%edx
c0100c7e:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c81:	83 c0 04             	add    $0x4,%eax
c0100c84:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c87:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c95:	89 1c 24             	mov    %ebx,(%esp)
c0100c98:	ff d2                	call   *%edx
c0100c9a:	eb 23                	jmp    c0100cbf <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9c:	ff 45 f4             	incl   -0xc(%ebp)
c0100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca2:	83 f8 02             	cmp    $0x2,%eax
c0100ca5:	76 9e                	jbe    c0100c45 <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100ca7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100caa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cae:	c7 04 24 7f 96 10 c0 	movl   $0xc010967f,(%esp)
c0100cb5:	e8 f2 f5 ff ff       	call   c01002ac <cprintf>
    return 0;
c0100cba:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbf:	83 c4 64             	add    $0x64,%esp
c0100cc2:	5b                   	pop    %ebx
c0100cc3:	5d                   	pop    %ebp
c0100cc4:	c3                   	ret    

c0100cc5 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cc5:	55                   	push   %ebp
c0100cc6:	89 e5                	mov    %esp,%ebp
c0100cc8:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100ccb:	c7 04 24 98 96 10 c0 	movl   $0xc0109698,(%esp)
c0100cd2:	e8 d5 f5 ff ff       	call   c01002ac <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cd7:	c7 04 24 c0 96 10 c0 	movl   $0xc01096c0,(%esp)
c0100cde:	e8 c9 f5 ff ff       	call   c01002ac <cprintf>

    if (tf != NULL) {
c0100ce3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ce7:	74 0b                	je     c0100cf4 <kmonitor+0x2f>
        print_trapframe(tf);
c0100ce9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cec:	89 04 24             	mov    %eax,(%esp)
c0100cef:	e8 71 16 00 00       	call   c0102365 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cf4:	c7 04 24 e5 96 10 c0 	movl   $0xc01096e5,(%esp)
c0100cfb:	e8 4e f6 ff ff       	call   c010034e <readline>
c0100d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d07:	74 eb                	je     c0100cf4 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d09:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d13:	89 04 24             	mov    %eax,(%esp)
c0100d16:	e8 f5 fe ff ff       	call   c0100c10 <runcmd>
c0100d1b:	85 c0                	test   %eax,%eax
c0100d1d:	78 02                	js     c0100d21 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d1f:	eb d3                	jmp    c0100cf4 <kmonitor+0x2f>
                break;
c0100d21:	90                   	nop
            }
        }
    }
}
c0100d22:	90                   	nop
c0100d23:	c9                   	leave  
c0100d24:	c3                   	ret    

c0100d25 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d25:	55                   	push   %ebp
c0100d26:	89 e5                	mov    %esp,%ebp
c0100d28:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d32:	eb 3d                	jmp    c0100d71 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d37:	89 d0                	mov    %edx,%eax
c0100d39:	01 c0                	add    %eax,%eax
c0100d3b:	01 d0                	add    %edx,%eax
c0100d3d:	c1 e0 02             	shl    $0x2,%eax
c0100d40:	05 04 20 12 c0       	add    $0xc0122004,%eax
c0100d45:	8b 08                	mov    (%eax),%ecx
c0100d47:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d4a:	89 d0                	mov    %edx,%eax
c0100d4c:	01 c0                	add    %eax,%eax
c0100d4e:	01 d0                	add    %edx,%eax
c0100d50:	c1 e0 02             	shl    $0x2,%eax
c0100d53:	05 00 20 12 c0       	add    $0xc0122000,%eax
c0100d58:	8b 00                	mov    (%eax),%eax
c0100d5a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d62:	c7 04 24 e9 96 10 c0 	movl   $0xc01096e9,(%esp)
c0100d69:	e8 3e f5 ff ff       	call   c01002ac <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d6e:	ff 45 f4             	incl   -0xc(%ebp)
c0100d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d74:	83 f8 02             	cmp    $0x2,%eax
c0100d77:	76 bb                	jbe    c0100d34 <mon_help+0xf>
    }
    return 0;
c0100d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d7e:	c9                   	leave  
c0100d7f:	c3                   	ret    

c0100d80 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d80:	55                   	push   %ebp
c0100d81:	89 e5                	mov    %esp,%ebp
c0100d83:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d86:	e8 c7 fb ff ff       	call   c0100952 <print_kerninfo>
    return 0;
c0100d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d90:	c9                   	leave  
c0100d91:	c3                   	ret    

c0100d92 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d92:	55                   	push   %ebp
c0100d93:	89 e5                	mov    %esp,%ebp
c0100d95:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d98:	e8 00 fd ff ff       	call   c0100a9d <print_stackframe>
    return 0;
c0100d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100da2:	c9                   	leave  
c0100da3:	c3                   	ret    

c0100da4 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100da4:	55                   	push   %ebp
c0100da5:	89 e5                	mov    %esp,%ebp
c0100da7:	83 ec 14             	sub    $0x14,%esp
c0100daa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dad:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100db1:	90                   	nop
c0100db2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100db5:	83 c0 07             	add    $0x7,%eax
c0100db8:	0f b7 c0             	movzwl %ax,%eax
c0100dbb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100dbf:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100dc3:	89 c2                	mov    %eax,%edx
c0100dc5:	ec                   	in     (%dx),%al
c0100dc6:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100dc9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100dcd:	0f b6 c0             	movzbl %al,%eax
c0100dd0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100dd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dd6:	25 80 00 00 00       	and    $0x80,%eax
c0100ddb:	85 c0                	test   %eax,%eax
c0100ddd:	75 d3                	jne    c0100db2 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100ddf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100de3:	74 11                	je     c0100df6 <ide_wait_ready+0x52>
c0100de5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100de8:	83 e0 21             	and    $0x21,%eax
c0100deb:	85 c0                	test   %eax,%eax
c0100ded:	74 07                	je     c0100df6 <ide_wait_ready+0x52>
        return -1;
c0100def:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100df4:	eb 05                	jmp    c0100dfb <ide_wait_ready+0x57>
    }
    return 0;
c0100df6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dfb:	c9                   	leave  
c0100dfc:	c3                   	ret    

c0100dfd <ide_init>:

void
ide_init(void) {
c0100dfd:	55                   	push   %ebp
c0100dfe:	89 e5                	mov    %esp,%ebp
c0100e00:	57                   	push   %edi
c0100e01:	53                   	push   %ebx
c0100e02:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e08:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e0e:	e9 ba 02 00 00       	jmp    c01010cd <ide_init+0x2d0>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e13:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e17:	89 d0                	mov    %edx,%eax
c0100e19:	c1 e0 03             	shl    $0x3,%eax
c0100e1c:	29 d0                	sub    %edx,%eax
c0100e1e:	c1 e0 03             	shl    $0x3,%eax
c0100e21:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0100e26:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e29:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e2d:	d1 e8                	shr    %eax
c0100e2f:	0f b7 c0             	movzwl %ax,%eax
c0100e32:	8b 04 85 f4 96 10 c0 	mov    -0x3fef690c(,%eax,4),%eax
c0100e39:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e3d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e48:	00 
c0100e49:	89 04 24             	mov    %eax,(%esp)
c0100e4c:	e8 53 ff ff ff       	call   c0100da4 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e51:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e55:	c1 e0 04             	shl    $0x4,%eax
c0100e58:	24 10                	and    $0x10,%al
c0100e5a:	0c e0                	or     $0xe0,%al
c0100e5c:	0f b6 c0             	movzbl %al,%eax
c0100e5f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e63:	83 c2 06             	add    $0x6,%edx
c0100e66:	0f b7 d2             	movzwl %dx,%edx
c0100e69:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0100e6d:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e70:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100e74:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0100e78:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e79:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e84:	00 
c0100e85:	89 04 24             	mov    %eax,(%esp)
c0100e88:	e8 17 ff ff ff       	call   c0100da4 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e8d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e91:	83 c0 07             	add    $0x7,%eax
c0100e94:	0f b7 c0             	movzwl %ax,%eax
c0100e97:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100e9b:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0100e9f:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100ea3:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100ea7:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100ea8:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100eb3:	00 
c0100eb4:	89 04 24             	mov    %eax,(%esp)
c0100eb7:	e8 e8 fe ff ff       	call   c0100da4 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100ebc:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ec0:	83 c0 07             	add    $0x7,%eax
c0100ec3:	0f b7 c0             	movzwl %ax,%eax
c0100ec6:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100eca:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100ece:	89 c2                	mov    %eax,%edx
c0100ed0:	ec                   	in     (%dx),%al
c0100ed1:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0100ed4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100ed8:	84 c0                	test   %al,%al
c0100eda:	0f 84 e3 01 00 00    	je     c01010c3 <ide_init+0x2c6>
c0100ee0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ee4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100eeb:	00 
c0100eec:	89 04 24             	mov    %eax,(%esp)
c0100eef:	e8 b0 fe ff ff       	call   c0100da4 <ide_wait_ready>
c0100ef4:	85 c0                	test   %eax,%eax
c0100ef6:	0f 85 c7 01 00 00    	jne    c01010c3 <ide_init+0x2c6>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100efc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f00:	89 d0                	mov    %edx,%eax
c0100f02:	c1 e0 03             	shl    $0x3,%eax
c0100f05:	29 d0                	sub    %edx,%eax
c0100f07:	c1 e0 03             	shl    $0x3,%eax
c0100f0a:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0100f0f:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f12:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f16:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0100f19:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f1f:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f22:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0100f29:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0100f2c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f2f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f32:	89 cb                	mov    %ecx,%ebx
c0100f34:	89 df                	mov    %ebx,%edi
c0100f36:	89 c1                	mov    %eax,%ecx
c0100f38:	fc                   	cld    
c0100f39:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f3b:	89 c8                	mov    %ecx,%eax
c0100f3d:	89 fb                	mov    %edi,%ebx
c0100f3f:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f42:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f45:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f51:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f57:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f5d:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f62:	85 c0                	test   %eax,%eax
c0100f64:	74 0e                	je     c0100f74 <ide_init+0x177>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f69:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f72:	eb 09                	jmp    c0100f7d <ide_init+0x180>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f77:	8b 40 78             	mov    0x78(%eax),%eax
c0100f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f7d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f81:	89 d0                	mov    %edx,%eax
c0100f83:	c1 e0 03             	shl    $0x3,%eax
c0100f86:	29 d0                	sub    %edx,%eax
c0100f88:	c1 e0 03             	shl    $0x3,%eax
c0100f8b:	8d 90 44 54 12 c0    	lea    -0x3fedabbc(%eax),%edx
c0100f91:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f94:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100f96:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f9a:	89 d0                	mov    %edx,%eax
c0100f9c:	c1 e0 03             	shl    $0x3,%eax
c0100f9f:	29 d0                	sub    %edx,%eax
c0100fa1:	c1 e0 03             	shl    $0x3,%eax
c0100fa4:	8d 90 48 54 12 c0    	lea    -0x3fedabb8(%eax),%edx
c0100faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100fad:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100faf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fb2:	83 c0 62             	add    $0x62,%eax
c0100fb5:	0f b7 00             	movzwl (%eax),%eax
c0100fb8:	25 00 02 00 00       	and    $0x200,%eax
c0100fbd:	85 c0                	test   %eax,%eax
c0100fbf:	75 24                	jne    c0100fe5 <ide_init+0x1e8>
c0100fc1:	c7 44 24 0c fc 96 10 	movl   $0xc01096fc,0xc(%esp)
c0100fc8:	c0 
c0100fc9:	c7 44 24 08 3f 97 10 	movl   $0xc010973f,0x8(%esp)
c0100fd0:	c0 
c0100fd1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0100fd8:	00 
c0100fd9:	c7 04 24 54 97 10 c0 	movl   $0xc0109754,(%esp)
c0100fe0:	e8 1e f4 ff ff       	call   c0100403 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100fe5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100fe9:	89 d0                	mov    %edx,%eax
c0100feb:	c1 e0 03             	shl    $0x3,%eax
c0100fee:	29 d0                	sub    %edx,%eax
c0100ff0:	c1 e0 03             	shl    $0x3,%eax
c0100ff3:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0100ff8:	83 c0 0c             	add    $0xc,%eax
c0100ffb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100ffe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101001:	83 c0 36             	add    $0x36,%eax
c0101004:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101007:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c010100e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101015:	eb 34                	jmp    c010104b <ide_init+0x24e>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101017:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010101a:	8d 50 01             	lea    0x1(%eax),%edx
c010101d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101020:	01 d0                	add    %edx,%eax
c0101022:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101025:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101028:	01 ca                	add    %ecx,%edx
c010102a:	0f b6 00             	movzbl (%eax),%eax
c010102d:	88 02                	mov    %al,(%edx)
c010102f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101032:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101035:	01 d0                	add    %edx,%eax
c0101037:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010103a:	8d 4a 01             	lea    0x1(%edx),%ecx
c010103d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101040:	01 ca                	add    %ecx,%edx
c0101042:	0f b6 00             	movzbl (%eax),%eax
c0101045:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0101047:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010104b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010104e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101051:	72 c4                	jb     c0101017 <ide_init+0x21a>
        }
        do {
            model[i] = '\0';
c0101053:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101056:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101059:	01 d0                	add    %edx,%eax
c010105b:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010105e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101061:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101064:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101067:	85 c0                	test   %eax,%eax
c0101069:	74 0f                	je     c010107a <ide_init+0x27d>
c010106b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010106e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101071:	01 d0                	add    %edx,%eax
c0101073:	0f b6 00             	movzbl (%eax),%eax
c0101076:	3c 20                	cmp    $0x20,%al
c0101078:	74 d9                	je     c0101053 <ide_init+0x256>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010107a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010107e:	89 d0                	mov    %edx,%eax
c0101080:	c1 e0 03             	shl    $0x3,%eax
c0101083:	29 d0                	sub    %edx,%eax
c0101085:	c1 e0 03             	shl    $0x3,%eax
c0101088:	05 40 54 12 c0       	add    $0xc0125440,%eax
c010108d:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101090:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101094:	89 d0                	mov    %edx,%eax
c0101096:	c1 e0 03             	shl    $0x3,%eax
c0101099:	29 d0                	sub    %edx,%eax
c010109b:	c1 e0 03             	shl    $0x3,%eax
c010109e:	05 48 54 12 c0       	add    $0xc0125448,%eax
c01010a3:	8b 10                	mov    (%eax),%edx
c01010a5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01010ad:	89 54 24 08          	mov    %edx,0x8(%esp)
c01010b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01010b5:	c7 04 24 66 97 10 c0 	movl   $0xc0109766,(%esp)
c01010bc:	e8 eb f1 ff ff       	call   c01002ac <cprintf>
c01010c1:	eb 01                	jmp    c01010c4 <ide_init+0x2c7>
            continue ;
c01010c3:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010c4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010c8:	40                   	inc    %eax
c01010c9:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01010cd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010d1:	83 f8 03             	cmp    $0x3,%eax
c01010d4:	0f 86 39 fd ff ff    	jbe    c0100e13 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01010da:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c01010e1:	e8 91 0e 00 00       	call   c0101f77 <pic_enable>
    pic_enable(IRQ_IDE2);
c01010e6:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c01010ed:	e8 85 0e 00 00       	call   c0101f77 <pic_enable>
}
c01010f2:	90                   	nop
c01010f3:	81 c4 50 02 00 00    	add    $0x250,%esp
c01010f9:	5b                   	pop    %ebx
c01010fa:	5f                   	pop    %edi
c01010fb:	5d                   	pop    %ebp
c01010fc:	c3                   	ret    

c01010fd <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c01010fd:	55                   	push   %ebp
c01010fe:	89 e5                	mov    %esp,%ebp
c0101100:	83 ec 04             	sub    $0x4,%esp
c0101103:	8b 45 08             	mov    0x8(%ebp),%eax
c0101106:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c010110a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010110e:	83 f8 03             	cmp    $0x3,%eax
c0101111:	77 21                	ja     c0101134 <ide_device_valid+0x37>
c0101113:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101117:	89 d0                	mov    %edx,%eax
c0101119:	c1 e0 03             	shl    $0x3,%eax
c010111c:	29 d0                	sub    %edx,%eax
c010111e:	c1 e0 03             	shl    $0x3,%eax
c0101121:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0101126:	0f b6 00             	movzbl (%eax),%eax
c0101129:	84 c0                	test   %al,%al
c010112b:	74 07                	je     c0101134 <ide_device_valid+0x37>
c010112d:	b8 01 00 00 00       	mov    $0x1,%eax
c0101132:	eb 05                	jmp    c0101139 <ide_device_valid+0x3c>
c0101134:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101139:	c9                   	leave  
c010113a:	c3                   	ret    

c010113b <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c010113b:	55                   	push   %ebp
c010113c:	89 e5                	mov    %esp,%ebp
c010113e:	83 ec 08             	sub    $0x8,%esp
c0101141:	8b 45 08             	mov    0x8(%ebp),%eax
c0101144:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101148:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010114c:	89 04 24             	mov    %eax,(%esp)
c010114f:	e8 a9 ff ff ff       	call   c01010fd <ide_device_valid>
c0101154:	85 c0                	test   %eax,%eax
c0101156:	74 17                	je     c010116f <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101158:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c010115c:	89 d0                	mov    %edx,%eax
c010115e:	c1 e0 03             	shl    $0x3,%eax
c0101161:	29 d0                	sub    %edx,%eax
c0101163:	c1 e0 03             	shl    $0x3,%eax
c0101166:	05 48 54 12 c0       	add    $0xc0125448,%eax
c010116b:	8b 00                	mov    (%eax),%eax
c010116d:	eb 05                	jmp    c0101174 <ide_device_size+0x39>
    }
    return 0;
c010116f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101174:	c9                   	leave  
c0101175:	c3                   	ret    

c0101176 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101176:	55                   	push   %ebp
c0101177:	89 e5                	mov    %esp,%ebp
c0101179:	57                   	push   %edi
c010117a:	53                   	push   %ebx
c010117b:	83 ec 50             	sub    $0x50,%esp
c010117e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101181:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101185:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c010118c:	77 23                	ja     c01011b1 <ide_read_secs+0x3b>
c010118e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101192:	83 f8 03             	cmp    $0x3,%eax
c0101195:	77 1a                	ja     c01011b1 <ide_read_secs+0x3b>
c0101197:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c010119b:	89 d0                	mov    %edx,%eax
c010119d:	c1 e0 03             	shl    $0x3,%eax
c01011a0:	29 d0                	sub    %edx,%eax
c01011a2:	c1 e0 03             	shl    $0x3,%eax
c01011a5:	05 40 54 12 c0       	add    $0xc0125440,%eax
c01011aa:	0f b6 00             	movzbl (%eax),%eax
c01011ad:	84 c0                	test   %al,%al
c01011af:	75 24                	jne    c01011d5 <ide_read_secs+0x5f>
c01011b1:	c7 44 24 0c 84 97 10 	movl   $0xc0109784,0xc(%esp)
c01011b8:	c0 
c01011b9:	c7 44 24 08 3f 97 10 	movl   $0xc010973f,0x8(%esp)
c01011c0:	c0 
c01011c1:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01011c8:	00 
c01011c9:	c7 04 24 54 97 10 c0 	movl   $0xc0109754,(%esp)
c01011d0:	e8 2e f2 ff ff       	call   c0100403 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01011d5:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01011dc:	77 0f                	ja     c01011ed <ide_read_secs+0x77>
c01011de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01011e1:	8b 45 14             	mov    0x14(%ebp),%eax
c01011e4:	01 d0                	add    %edx,%eax
c01011e6:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01011eb:	76 24                	jbe    c0101211 <ide_read_secs+0x9b>
c01011ed:	c7 44 24 0c ac 97 10 	movl   $0xc01097ac,0xc(%esp)
c01011f4:	c0 
c01011f5:	c7 44 24 08 3f 97 10 	movl   $0xc010973f,0x8(%esp)
c01011fc:	c0 
c01011fd:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101204:	00 
c0101205:	c7 04 24 54 97 10 c0 	movl   $0xc0109754,(%esp)
c010120c:	e8 f2 f1 ff ff       	call   c0100403 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101211:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101215:	d1 e8                	shr    %eax
c0101217:	0f b7 c0             	movzwl %ax,%eax
c010121a:	8b 04 85 f4 96 10 c0 	mov    -0x3fef690c(,%eax,4),%eax
c0101221:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101225:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101229:	d1 e8                	shr    %eax
c010122b:	0f b7 c0             	movzwl %ax,%eax
c010122e:	0f b7 04 85 f6 96 10 	movzwl -0x3fef690a(,%eax,4),%eax
c0101235:	c0 
c0101236:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010123a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010123e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101245:	00 
c0101246:	89 04 24             	mov    %eax,(%esp)
c0101249:	e8 56 fb ff ff       	call   c0100da4 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010124e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101251:	83 c0 02             	add    $0x2,%eax
c0101254:	0f b7 c0             	movzwl %ax,%eax
c0101257:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010125b:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010125f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101263:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101267:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101268:	8b 45 14             	mov    0x14(%ebp),%eax
c010126b:	0f b6 c0             	movzbl %al,%eax
c010126e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101272:	83 c2 02             	add    $0x2,%edx
c0101275:	0f b7 d2             	movzwl %dx,%edx
c0101278:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c010127c:	88 45 d9             	mov    %al,-0x27(%ebp)
c010127f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101283:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101287:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101288:	8b 45 0c             	mov    0xc(%ebp),%eax
c010128b:	0f b6 c0             	movzbl %al,%eax
c010128e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101292:	83 c2 03             	add    $0x3,%edx
c0101295:	0f b7 d2             	movzwl %dx,%edx
c0101298:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010129c:	88 45 dd             	mov    %al,-0x23(%ebp)
c010129f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01012a3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01012a7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01012a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012ab:	c1 e8 08             	shr    $0x8,%eax
c01012ae:	0f b6 c0             	movzbl %al,%eax
c01012b1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012b5:	83 c2 04             	add    $0x4,%edx
c01012b8:	0f b7 d2             	movzwl %dx,%edx
c01012bb:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01012bf:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01012c2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01012c6:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01012ca:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01012cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012ce:	c1 e8 10             	shr    $0x10,%eax
c01012d1:	0f b6 c0             	movzbl %al,%eax
c01012d4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012d8:	83 c2 05             	add    $0x5,%edx
c01012db:	0f b7 d2             	movzwl %dx,%edx
c01012de:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012e2:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012e5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012e9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ed:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01012ee:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01012f1:	c0 e0 04             	shl    $0x4,%al
c01012f4:	24 10                	and    $0x10,%al
c01012f6:	88 c2                	mov    %al,%dl
c01012f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012fb:	c1 e8 18             	shr    $0x18,%eax
c01012fe:	24 0f                	and    $0xf,%al
c0101300:	08 d0                	or     %dl,%al
c0101302:	0c e0                	or     $0xe0,%al
c0101304:	0f b6 c0             	movzbl %al,%eax
c0101307:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010130b:	83 c2 06             	add    $0x6,%edx
c010130e:	0f b7 d2             	movzwl %dx,%edx
c0101311:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101315:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101318:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010131c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101320:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101321:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101325:	83 c0 07             	add    $0x7,%eax
c0101328:	0f b7 c0             	movzwl %ax,%eax
c010132b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010132f:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
c0101333:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101337:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010133b:	ee                   	out    %al,(%dx)

    int ret = 0;
c010133c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101343:	eb 57                	jmp    c010139c <ide_read_secs+0x226>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101345:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101349:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101350:	00 
c0101351:	89 04 24             	mov    %eax,(%esp)
c0101354:	e8 4b fa ff ff       	call   c0100da4 <ide_wait_ready>
c0101359:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010135c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101360:	75 42                	jne    c01013a4 <ide_read_secs+0x22e>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101362:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101366:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101369:	8b 45 10             	mov    0x10(%ebp),%eax
c010136c:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010136f:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101376:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101379:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010137c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010137f:	89 cb                	mov    %ecx,%ebx
c0101381:	89 df                	mov    %ebx,%edi
c0101383:	89 c1                	mov    %eax,%ecx
c0101385:	fc                   	cld    
c0101386:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101388:	89 c8                	mov    %ecx,%eax
c010138a:	89 fb                	mov    %edi,%ebx
c010138c:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010138f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101392:	ff 4d 14             	decl   0x14(%ebp)
c0101395:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010139c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01013a0:	75 a3                	jne    c0101345 <ide_read_secs+0x1cf>
    }

out:
c01013a2:	eb 01                	jmp    c01013a5 <ide_read_secs+0x22f>
            goto out;
c01013a4:	90                   	nop
    return ret;
c01013a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01013a8:	83 c4 50             	add    $0x50,%esp
c01013ab:	5b                   	pop    %ebx
c01013ac:	5f                   	pop    %edi
c01013ad:	5d                   	pop    %ebp
c01013ae:	c3                   	ret    

c01013af <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01013af:	55                   	push   %ebp
c01013b0:	89 e5                	mov    %esp,%ebp
c01013b2:	56                   	push   %esi
c01013b3:	53                   	push   %ebx
c01013b4:	83 ec 50             	sub    $0x50,%esp
c01013b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01013ba:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01013be:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01013c5:	77 23                	ja     c01013ea <ide_write_secs+0x3b>
c01013c7:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013cb:	83 f8 03             	cmp    $0x3,%eax
c01013ce:	77 1a                	ja     c01013ea <ide_write_secs+0x3b>
c01013d0:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c01013d4:	89 d0                	mov    %edx,%eax
c01013d6:	c1 e0 03             	shl    $0x3,%eax
c01013d9:	29 d0                	sub    %edx,%eax
c01013db:	c1 e0 03             	shl    $0x3,%eax
c01013de:	05 40 54 12 c0       	add    $0xc0125440,%eax
c01013e3:	0f b6 00             	movzbl (%eax),%eax
c01013e6:	84 c0                	test   %al,%al
c01013e8:	75 24                	jne    c010140e <ide_write_secs+0x5f>
c01013ea:	c7 44 24 0c 84 97 10 	movl   $0xc0109784,0xc(%esp)
c01013f1:	c0 
c01013f2:	c7 44 24 08 3f 97 10 	movl   $0xc010973f,0x8(%esp)
c01013f9:	c0 
c01013fa:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101401:	00 
c0101402:	c7 04 24 54 97 10 c0 	movl   $0xc0109754,(%esp)
c0101409:	e8 f5 ef ff ff       	call   c0100403 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010140e:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101415:	77 0f                	ja     c0101426 <ide_write_secs+0x77>
c0101417:	8b 55 0c             	mov    0xc(%ebp),%edx
c010141a:	8b 45 14             	mov    0x14(%ebp),%eax
c010141d:	01 d0                	add    %edx,%eax
c010141f:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101424:	76 24                	jbe    c010144a <ide_write_secs+0x9b>
c0101426:	c7 44 24 0c ac 97 10 	movl   $0xc01097ac,0xc(%esp)
c010142d:	c0 
c010142e:	c7 44 24 08 3f 97 10 	movl   $0xc010973f,0x8(%esp)
c0101435:	c0 
c0101436:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010143d:	00 
c010143e:	c7 04 24 54 97 10 c0 	movl   $0xc0109754,(%esp)
c0101445:	e8 b9 ef ff ff       	call   c0100403 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010144a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010144e:	d1 e8                	shr    %eax
c0101450:	0f b7 c0             	movzwl %ax,%eax
c0101453:	8b 04 85 f4 96 10 c0 	mov    -0x3fef690c(,%eax,4),%eax
c010145a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010145e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101462:	d1 e8                	shr    %eax
c0101464:	0f b7 c0             	movzwl %ax,%eax
c0101467:	0f b7 04 85 f6 96 10 	movzwl -0x3fef690a(,%eax,4),%eax
c010146e:	c0 
c010146f:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101473:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101477:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010147e:	00 
c010147f:	89 04 24             	mov    %eax,(%esp)
c0101482:	e8 1d f9 ff ff       	call   c0100da4 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010148a:	83 c0 02             	add    $0x2,%eax
c010148d:	0f b7 c0             	movzwl %ax,%eax
c0101490:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101494:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101498:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010149c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01014a0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01014a1:	8b 45 14             	mov    0x14(%ebp),%eax
c01014a4:	0f b6 c0             	movzbl %al,%eax
c01014a7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014ab:	83 c2 02             	add    $0x2,%edx
c01014ae:	0f b7 d2             	movzwl %dx,%edx
c01014b1:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01014b5:	88 45 d9             	mov    %al,-0x27(%ebp)
c01014b8:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01014bc:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01014c0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01014c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014c4:	0f b6 c0             	movzbl %al,%eax
c01014c7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014cb:	83 c2 03             	add    $0x3,%edx
c01014ce:	0f b7 d2             	movzwl %dx,%edx
c01014d1:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01014d5:	88 45 dd             	mov    %al,-0x23(%ebp)
c01014d8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01014dc:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01014e0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01014e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014e4:	c1 e8 08             	shr    $0x8,%eax
c01014e7:	0f b6 c0             	movzbl %al,%eax
c01014ea:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014ee:	83 c2 04             	add    $0x4,%edx
c01014f1:	0f b7 d2             	movzwl %dx,%edx
c01014f4:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01014f8:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01014fb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01014ff:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101503:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101504:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101507:	c1 e8 10             	shr    $0x10,%eax
c010150a:	0f b6 c0             	movzbl %al,%eax
c010150d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101511:	83 c2 05             	add    $0x5,%edx
c0101514:	0f b7 d2             	movzwl %dx,%edx
c0101517:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c010151b:	88 45 e5             	mov    %al,-0x1b(%ebp)
c010151e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101522:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101526:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101527:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010152a:	c0 e0 04             	shl    $0x4,%al
c010152d:	24 10                	and    $0x10,%al
c010152f:	88 c2                	mov    %al,%dl
c0101531:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101534:	c1 e8 18             	shr    $0x18,%eax
c0101537:	24 0f                	and    $0xf,%al
c0101539:	08 d0                	or     %dl,%al
c010153b:	0c e0                	or     $0xe0,%al
c010153d:	0f b6 c0             	movzbl %al,%eax
c0101540:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101544:	83 c2 06             	add    $0x6,%edx
c0101547:	0f b7 d2             	movzwl %dx,%edx
c010154a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010154e:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101551:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101555:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101559:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010155a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010155e:	83 c0 07             	add    $0x7,%eax
c0101561:	0f b7 c0             	movzwl %ax,%eax
c0101564:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101568:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
c010156c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101570:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101574:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101575:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010157c:	eb 57                	jmp    c01015d5 <ide_write_secs+0x226>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010157e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101582:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101589:	00 
c010158a:	89 04 24             	mov    %eax,(%esp)
c010158d:	e8 12 f8 ff ff       	call   c0100da4 <ide_wait_ready>
c0101592:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101595:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101599:	75 42                	jne    c01015dd <ide_write_secs+0x22e>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c010159b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010159f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01015a2:	8b 45 10             	mov    0x10(%ebp),%eax
c01015a5:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01015a8:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01015af:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01015b2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01015b5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01015b8:	89 cb                	mov    %ecx,%ebx
c01015ba:	89 de                	mov    %ebx,%esi
c01015bc:	89 c1                	mov    %eax,%ecx
c01015be:	fc                   	cld    
c01015bf:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01015c1:	89 c8                	mov    %ecx,%eax
c01015c3:	89 f3                	mov    %esi,%ebx
c01015c5:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01015c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015cb:	ff 4d 14             	decl   0x14(%ebp)
c01015ce:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01015d5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01015d9:	75 a3                	jne    c010157e <ide_write_secs+0x1cf>
    }

out:
c01015db:	eb 01                	jmp    c01015de <ide_write_secs+0x22f>
            goto out;
c01015dd:	90                   	nop
    return ret;
c01015de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015e1:	83 c4 50             	add    $0x50,%esp
c01015e4:	5b                   	pop    %ebx
c01015e5:	5e                   	pop    %esi
c01015e6:	5d                   	pop    %ebp
c01015e7:	c3                   	ret    

c01015e8 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c01015e8:	55                   	push   %ebp
c01015e9:	89 e5                	mov    %esp,%ebp
c01015eb:	83 ec 28             	sub    $0x28,%esp
c01015ee:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c01015f4:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015f8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01015fc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101600:	ee                   	out    %al,(%dx)
c0101601:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101607:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c010160b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010160f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101613:	ee                   	out    %al,(%dx)
c0101614:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c010161a:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c010161e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101622:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101626:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101627:	c7 05 1c 60 12 c0 00 	movl   $0x0,0xc012601c
c010162e:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0101631:	c7 04 24 e6 97 10 c0 	movl   $0xc01097e6,(%esp)
c0101638:	e8 6f ec ff ff       	call   c01002ac <cprintf>
    pic_enable(IRQ_TIMER);
c010163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101644:	e8 2e 09 00 00       	call   c0101f77 <pic_enable>
}
c0101649:	90                   	nop
c010164a:	c9                   	leave  
c010164b:	c3                   	ret    

c010164c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010164c:	55                   	push   %ebp
c010164d:	89 e5                	mov    %esp,%ebp
c010164f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101652:	9c                   	pushf  
c0101653:	58                   	pop    %eax
c0101654:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0101657:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010165a:	25 00 02 00 00       	and    $0x200,%eax
c010165f:	85 c0                	test   %eax,%eax
c0101661:	74 0c                	je     c010166f <__intr_save+0x23>
        intr_disable();
c0101663:	e8 83 0a 00 00       	call   c01020eb <intr_disable>
        return 1;
c0101668:	b8 01 00 00 00       	mov    $0x1,%eax
c010166d:	eb 05                	jmp    c0101674 <__intr_save+0x28>
    }
    return 0;
c010166f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101674:	c9                   	leave  
c0101675:	c3                   	ret    

c0101676 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0101676:	55                   	push   %ebp
c0101677:	89 e5                	mov    %esp,%ebp
c0101679:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010167c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101680:	74 05                	je     c0101687 <__intr_restore+0x11>
        intr_enable();
c0101682:	e8 5d 0a 00 00       	call   c01020e4 <intr_enable>
    }
}
c0101687:	90                   	nop
c0101688:	c9                   	leave  
c0101689:	c3                   	ret    

c010168a <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c010168a:	55                   	push   %ebp
c010168b:	89 e5                	mov    %esp,%ebp
c010168d:	83 ec 10             	sub    $0x10,%esp
c0101690:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101696:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010169a:	89 c2                	mov    %eax,%edx
c010169c:	ec                   	in     (%dx),%al
c010169d:	88 45 f1             	mov    %al,-0xf(%ebp)
c01016a0:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c01016a6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01016aa:	89 c2                	mov    %eax,%edx
c01016ac:	ec                   	in     (%dx),%al
c01016ad:	88 45 f5             	mov    %al,-0xb(%ebp)
c01016b0:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01016b6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016ba:	89 c2                	mov    %eax,%edx
c01016bc:	ec                   	in     (%dx),%al
c01016bd:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016c0:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c01016c6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016ca:	89 c2                	mov    %eax,%edx
c01016cc:	ec                   	in     (%dx),%al
c01016cd:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01016d0:	90                   	nop
c01016d1:	c9                   	leave  
c01016d2:	c3                   	ret    

c01016d3 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01016d3:	55                   	push   %ebp
c01016d4:	89 e5                	mov    %esp,%ebp
c01016d6:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01016d9:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01016e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016e3:	0f b7 00             	movzwl (%eax),%eax
c01016e6:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c01016ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016ed:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c01016f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016f5:	0f b7 00             	movzwl (%eax),%eax
c01016f8:	0f b7 c0             	movzwl %ax,%eax
c01016fb:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0101700:	74 12                	je     c0101714 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101702:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101709:	66 c7 05 26 55 12 c0 	movw   $0x3b4,0xc0125526
c0101710:	b4 03 
c0101712:	eb 13                	jmp    c0101727 <cga_init+0x54>
    } else {
        *cp = was;
c0101714:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101717:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010171b:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c010171e:	66 c7 05 26 55 12 c0 	movw   $0x3d4,0xc0125526
c0101725:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101727:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c010172e:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101732:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101736:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010173a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010173e:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010173f:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101746:	40                   	inc    %eax
c0101747:	0f b7 c0             	movzwl %ax,%eax
c010174a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010174e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101752:	89 c2                	mov    %eax,%edx
c0101754:	ec                   	in     (%dx),%al
c0101755:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0101758:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010175c:	0f b6 c0             	movzbl %al,%eax
c010175f:	c1 e0 08             	shl    $0x8,%eax
c0101762:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101765:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c010176c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101770:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101774:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101778:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010177c:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c010177d:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101784:	40                   	inc    %eax
c0101785:	0f b7 c0             	movzwl %ax,%eax
c0101788:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010178c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101790:	89 c2                	mov    %eax,%edx
c0101792:	ec                   	in     (%dx),%al
c0101793:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0101796:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010179a:	0f b6 c0             	movzbl %al,%eax
c010179d:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01017a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017a3:	a3 20 55 12 c0       	mov    %eax,0xc0125520
    crt_pos = pos;
c01017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017ab:	0f b7 c0             	movzwl %ax,%eax
c01017ae:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
}
c01017b4:	90                   	nop
c01017b5:	c9                   	leave  
c01017b6:	c3                   	ret    

c01017b7 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01017b7:	55                   	push   %ebp
c01017b8:	89 e5                	mov    %esp,%ebp
c01017ba:	83 ec 48             	sub    $0x48,%esp
c01017bd:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c01017c3:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017c7:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017cb:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017cf:	ee                   	out    %al,(%dx)
c01017d0:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c01017d6:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c01017da:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01017de:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01017e2:	ee                   	out    %al,(%dx)
c01017e3:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c01017e9:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c01017ed:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017f1:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01017f5:	ee                   	out    %al,(%dx)
c01017f6:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01017fc:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0101800:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101804:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101808:	ee                   	out    %al,(%dx)
c0101809:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c010180f:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0101813:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101817:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010181b:	ee                   	out    %al,(%dx)
c010181c:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101822:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0101826:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010182a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010182e:	ee                   	out    %al,(%dx)
c010182f:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101835:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c0101839:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010183d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101841:	ee                   	out    %al,(%dx)
c0101842:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101848:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010184c:	89 c2                	mov    %eax,%edx
c010184e:	ec                   	in     (%dx),%al
c010184f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101852:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101856:	3c ff                	cmp    $0xff,%al
c0101858:	0f 95 c0             	setne  %al
c010185b:	0f b6 c0             	movzbl %al,%eax
c010185e:	a3 28 55 12 c0       	mov    %eax,0xc0125528
c0101863:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101869:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010186d:	89 c2                	mov    %eax,%edx
c010186f:	ec                   	in     (%dx),%al
c0101870:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101873:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101879:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010187d:	89 c2                	mov    %eax,%edx
c010187f:	ec                   	in     (%dx),%al
c0101880:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101883:	a1 28 55 12 c0       	mov    0xc0125528,%eax
c0101888:	85 c0                	test   %eax,%eax
c010188a:	74 0c                	je     c0101898 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010188c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101893:	e8 df 06 00 00       	call   c0101f77 <pic_enable>
    }
}
c0101898:	90                   	nop
c0101899:	c9                   	leave  
c010189a:	c3                   	ret    

c010189b <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010189b:	55                   	push   %ebp
c010189c:	89 e5                	mov    %esp,%ebp
c010189e:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018a8:	eb 08                	jmp    c01018b2 <lpt_putc_sub+0x17>
        delay();
c01018aa:	e8 db fd ff ff       	call   c010168a <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018af:	ff 45 fc             	incl   -0x4(%ebp)
c01018b2:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01018b8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01018bc:	89 c2                	mov    %eax,%edx
c01018be:	ec                   	in     (%dx),%al
c01018bf:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01018c2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01018c6:	84 c0                	test   %al,%al
c01018c8:	78 09                	js     c01018d3 <lpt_putc_sub+0x38>
c01018ca:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01018d1:	7e d7                	jle    c01018aa <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01018d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01018d6:	0f b6 c0             	movzbl %al,%eax
c01018d9:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01018df:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018e6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018ea:	ee                   	out    %al,(%dx)
c01018eb:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01018f1:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01018f5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018f9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018fd:	ee                   	out    %al,(%dx)
c01018fe:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101904:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c0101908:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010190c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101910:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101911:	90                   	nop
c0101912:	c9                   	leave  
c0101913:	c3                   	ret    

c0101914 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101914:	55                   	push   %ebp
c0101915:	89 e5                	mov    %esp,%ebp
c0101917:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010191a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010191e:	74 0d                	je     c010192d <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101920:	8b 45 08             	mov    0x8(%ebp),%eax
c0101923:	89 04 24             	mov    %eax,(%esp)
c0101926:	e8 70 ff ff ff       	call   c010189b <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010192b:	eb 24                	jmp    c0101951 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c010192d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101934:	e8 62 ff ff ff       	call   c010189b <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101939:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101940:	e8 56 ff ff ff       	call   c010189b <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101945:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010194c:	e8 4a ff ff ff       	call   c010189b <lpt_putc_sub>
}
c0101951:	90                   	nop
c0101952:	c9                   	leave  
c0101953:	c3                   	ret    

c0101954 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101954:	55                   	push   %ebp
c0101955:	89 e5                	mov    %esp,%ebp
c0101957:	53                   	push   %ebx
c0101958:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010195b:	8b 45 08             	mov    0x8(%ebp),%eax
c010195e:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101963:	85 c0                	test   %eax,%eax
c0101965:	75 07                	jne    c010196e <cga_putc+0x1a>
        c |= 0x0700;
c0101967:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010196e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101971:	0f b6 c0             	movzbl %al,%eax
c0101974:	83 f8 0a             	cmp    $0xa,%eax
c0101977:	74 55                	je     c01019ce <cga_putc+0x7a>
c0101979:	83 f8 0d             	cmp    $0xd,%eax
c010197c:	74 63                	je     c01019e1 <cga_putc+0x8d>
c010197e:	83 f8 08             	cmp    $0x8,%eax
c0101981:	0f 85 94 00 00 00    	jne    c0101a1b <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c0101987:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c010198e:	85 c0                	test   %eax,%eax
c0101990:	0f 84 af 00 00 00    	je     c0101a45 <cga_putc+0xf1>
            crt_pos --;
c0101996:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c010199d:	48                   	dec    %eax
c010199e:	0f b7 c0             	movzwl %ax,%eax
c01019a1:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01019aa:	98                   	cwtl   
c01019ab:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01019b0:	98                   	cwtl   
c01019b1:	83 c8 20             	or     $0x20,%eax
c01019b4:	98                   	cwtl   
c01019b5:	8b 15 20 55 12 c0    	mov    0xc0125520,%edx
c01019bb:	0f b7 0d 24 55 12 c0 	movzwl 0xc0125524,%ecx
c01019c2:	01 c9                	add    %ecx,%ecx
c01019c4:	01 ca                	add    %ecx,%edx
c01019c6:	0f b7 c0             	movzwl %ax,%eax
c01019c9:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01019cc:	eb 77                	jmp    c0101a45 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c01019ce:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c01019d5:	83 c0 50             	add    $0x50,%eax
c01019d8:	0f b7 c0             	movzwl %ax,%eax
c01019db:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01019e1:	0f b7 1d 24 55 12 c0 	movzwl 0xc0125524,%ebx
c01019e8:	0f b7 0d 24 55 12 c0 	movzwl 0xc0125524,%ecx
c01019ef:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01019f4:	89 c8                	mov    %ecx,%eax
c01019f6:	f7 e2                	mul    %edx
c01019f8:	c1 ea 06             	shr    $0x6,%edx
c01019fb:	89 d0                	mov    %edx,%eax
c01019fd:	c1 e0 02             	shl    $0x2,%eax
c0101a00:	01 d0                	add    %edx,%eax
c0101a02:	c1 e0 04             	shl    $0x4,%eax
c0101a05:	29 c1                	sub    %eax,%ecx
c0101a07:	89 c8                	mov    %ecx,%eax
c0101a09:	0f b7 c0             	movzwl %ax,%eax
c0101a0c:	29 c3                	sub    %eax,%ebx
c0101a0e:	89 d8                	mov    %ebx,%eax
c0101a10:	0f b7 c0             	movzwl %ax,%eax
c0101a13:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
        break;
c0101a19:	eb 2b                	jmp    c0101a46 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a1b:	8b 0d 20 55 12 c0    	mov    0xc0125520,%ecx
c0101a21:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101a28:	8d 50 01             	lea    0x1(%eax),%edx
c0101a2b:	0f b7 d2             	movzwl %dx,%edx
c0101a2e:	66 89 15 24 55 12 c0 	mov    %dx,0xc0125524
c0101a35:	01 c0                	add    %eax,%eax
c0101a37:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3d:	0f b7 c0             	movzwl %ax,%eax
c0101a40:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a43:	eb 01                	jmp    c0101a46 <cga_putc+0xf2>
        break;
c0101a45:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a46:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101a4d:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101a52:	76 5d                	jbe    c0101ab1 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a54:	a1 20 55 12 c0       	mov    0xc0125520,%eax
c0101a59:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a5f:	a1 20 55 12 c0       	mov    0xc0125520,%eax
c0101a64:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101a6b:	00 
c0101a6c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a70:	89 04 24             	mov    %eax,(%esp)
c0101a73:	e8 c0 70 00 00       	call   c0108b38 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a78:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101a7f:	eb 14                	jmp    c0101a95 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101a81:	a1 20 55 12 c0       	mov    0xc0125520,%eax
c0101a86:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101a89:	01 d2                	add    %edx,%edx
c0101a8b:	01 d0                	add    %edx,%eax
c0101a8d:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a92:	ff 45 f4             	incl   -0xc(%ebp)
c0101a95:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101a9c:	7e e3                	jle    c0101a81 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
c0101a9e:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101aa5:	83 e8 50             	sub    $0x50,%eax
c0101aa8:	0f b7 c0             	movzwl %ax,%eax
c0101aab:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101ab1:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101ab8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101abc:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101ac0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101ac4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101ac8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101ac9:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101ad0:	c1 e8 08             	shr    $0x8,%eax
c0101ad3:	0f b7 c0             	movzwl %ax,%eax
c0101ad6:	0f b6 c0             	movzbl %al,%eax
c0101ad9:	0f b7 15 26 55 12 c0 	movzwl 0xc0125526,%edx
c0101ae0:	42                   	inc    %edx
c0101ae1:	0f b7 d2             	movzwl %dx,%edx
c0101ae4:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ae8:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101aeb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101aef:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101af3:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101af4:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101afb:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101aff:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c0101b03:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101b07:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b0b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101b0c:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101b13:	0f b6 c0             	movzbl %al,%eax
c0101b16:	0f b7 15 26 55 12 c0 	movzwl 0xc0125526,%edx
c0101b1d:	42                   	inc    %edx
c0101b1e:	0f b7 d2             	movzwl %dx,%edx
c0101b21:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101b25:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101b28:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101b2c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101b30:	ee                   	out    %al,(%dx)
}
c0101b31:	90                   	nop
c0101b32:	83 c4 34             	add    $0x34,%esp
c0101b35:	5b                   	pop    %ebx
c0101b36:	5d                   	pop    %ebp
c0101b37:	c3                   	ret    

c0101b38 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b38:	55                   	push   %ebp
c0101b39:	89 e5                	mov    %esp,%ebp
c0101b3b:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b3e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b45:	eb 08                	jmp    c0101b4f <serial_putc_sub+0x17>
        delay();
c0101b47:	e8 3e fb ff ff       	call   c010168a <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b4c:	ff 45 fc             	incl   -0x4(%ebp)
c0101b4f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b55:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101b59:	89 c2                	mov    %eax,%edx
c0101b5b:	ec                   	in     (%dx),%al
c0101b5c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101b5f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101b63:	0f b6 c0             	movzbl %al,%eax
c0101b66:	83 e0 20             	and    $0x20,%eax
c0101b69:	85 c0                	test   %eax,%eax
c0101b6b:	75 09                	jne    c0101b76 <serial_putc_sub+0x3e>
c0101b6d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101b74:	7e d1                	jle    c0101b47 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101b76:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b79:	0f b6 c0             	movzbl %al,%eax
c0101b7c:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101b82:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b85:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101b89:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101b8d:	ee                   	out    %al,(%dx)
}
c0101b8e:	90                   	nop
c0101b8f:	c9                   	leave  
c0101b90:	c3                   	ret    

c0101b91 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101b91:	55                   	push   %ebp
c0101b92:	89 e5                	mov    %esp,%ebp
c0101b94:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101b97:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101b9b:	74 0d                	je     c0101baa <serial_putc+0x19>
        serial_putc_sub(c);
c0101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba0:	89 04 24             	mov    %eax,(%esp)
c0101ba3:	e8 90 ff ff ff       	call   c0101b38 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101ba8:	eb 24                	jmp    c0101bce <serial_putc+0x3d>
        serial_putc_sub('\b');
c0101baa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bb1:	e8 82 ff ff ff       	call   c0101b38 <serial_putc_sub>
        serial_putc_sub(' ');
c0101bb6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bbd:	e8 76 ff ff ff       	call   c0101b38 <serial_putc_sub>
        serial_putc_sub('\b');
c0101bc2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bc9:	e8 6a ff ff ff       	call   c0101b38 <serial_putc_sub>
}
c0101bce:	90                   	nop
c0101bcf:	c9                   	leave  
c0101bd0:	c3                   	ret    

c0101bd1 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101bd1:	55                   	push   %ebp
c0101bd2:	89 e5                	mov    %esp,%ebp
c0101bd4:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101bd7:	eb 33                	jmp    c0101c0c <cons_intr+0x3b>
        if (c != 0) {
c0101bd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101bdd:	74 2d                	je     c0101c0c <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101bdf:	a1 44 57 12 c0       	mov    0xc0125744,%eax
c0101be4:	8d 50 01             	lea    0x1(%eax),%edx
c0101be7:	89 15 44 57 12 c0    	mov    %edx,0xc0125744
c0101bed:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101bf0:	88 90 40 55 12 c0    	mov    %dl,-0x3fedaac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101bf6:	a1 44 57 12 c0       	mov    0xc0125744,%eax
c0101bfb:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101c00:	75 0a                	jne    c0101c0c <cons_intr+0x3b>
                cons.wpos = 0;
c0101c02:	c7 05 44 57 12 c0 00 	movl   $0x0,0xc0125744
c0101c09:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0f:	ff d0                	call   *%eax
c0101c11:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c14:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c18:	75 bf                	jne    c0101bd9 <cons_intr+0x8>
            }
        }
    }
}
c0101c1a:	90                   	nop
c0101c1b:	c9                   	leave  
c0101c1c:	c3                   	ret    

c0101c1d <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c1d:	55                   	push   %ebp
c0101c1e:	89 e5                	mov    %esp,%ebp
c0101c20:	83 ec 10             	sub    $0x10,%esp
c0101c23:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c29:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c2d:	89 c2                	mov    %eax,%edx
c0101c2f:	ec                   	in     (%dx),%al
c0101c30:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c33:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c37:	0f b6 c0             	movzbl %al,%eax
c0101c3a:	83 e0 01             	and    $0x1,%eax
c0101c3d:	85 c0                	test   %eax,%eax
c0101c3f:	75 07                	jne    c0101c48 <serial_proc_data+0x2b>
        return -1;
c0101c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c46:	eb 2a                	jmp    c0101c72 <serial_proc_data+0x55>
c0101c48:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c4e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101c52:	89 c2                	mov    %eax,%edx
c0101c54:	ec                   	in     (%dx),%al
c0101c55:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101c58:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c5c:	0f b6 c0             	movzbl %al,%eax
c0101c5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c62:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c66:	75 07                	jne    c0101c6f <serial_proc_data+0x52>
        c = '\b';
c0101c68:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101c72:	c9                   	leave  
c0101c73:	c3                   	ret    

c0101c74 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101c74:	55                   	push   %ebp
c0101c75:	89 e5                	mov    %esp,%ebp
c0101c77:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101c7a:	a1 28 55 12 c0       	mov    0xc0125528,%eax
c0101c7f:	85 c0                	test   %eax,%eax
c0101c81:	74 0c                	je     c0101c8f <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101c83:	c7 04 24 1d 1c 10 c0 	movl   $0xc0101c1d,(%esp)
c0101c8a:	e8 42 ff ff ff       	call   c0101bd1 <cons_intr>
    }
}
c0101c8f:	90                   	nop
c0101c90:	c9                   	leave  
c0101c91:	c3                   	ret    

c0101c92 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101c92:	55                   	push   %ebp
c0101c93:	89 e5                	mov    %esp,%ebp
c0101c95:	83 ec 38             	sub    $0x38,%esp
c0101c98:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101ca1:	89 c2                	mov    %eax,%edx
c0101ca3:	ec                   	in     (%dx),%al
c0101ca4:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101ca7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101cab:	0f b6 c0             	movzbl %al,%eax
c0101cae:	83 e0 01             	and    $0x1,%eax
c0101cb1:	85 c0                	test   %eax,%eax
c0101cb3:	75 0a                	jne    c0101cbf <kbd_proc_data+0x2d>
        return -1;
c0101cb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cba:	e9 55 01 00 00       	jmp    c0101e14 <kbd_proc_data+0x182>
c0101cbf:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101cc8:	89 c2                	mov    %eax,%edx
c0101cca:	ec                   	in     (%dx),%al
c0101ccb:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101cce:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101cd2:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101cd5:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101cd9:	75 17                	jne    c0101cf2 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101cdb:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101ce0:	83 c8 40             	or     $0x40,%eax
c0101ce3:	a3 48 57 12 c0       	mov    %eax,0xc0125748
        return 0;
c0101ce8:	b8 00 00 00 00       	mov    $0x0,%eax
c0101ced:	e9 22 01 00 00       	jmp    c0101e14 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c0101cf2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101cf6:	84 c0                	test   %al,%al
c0101cf8:	79 45                	jns    c0101d3f <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101cfa:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101cff:	83 e0 40             	and    $0x40,%eax
c0101d02:	85 c0                	test   %eax,%eax
c0101d04:	75 08                	jne    c0101d0e <kbd_proc_data+0x7c>
c0101d06:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d0a:	24 7f                	and    $0x7f,%al
c0101d0c:	eb 04                	jmp    c0101d12 <kbd_proc_data+0x80>
c0101d0e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d12:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d15:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d19:	0f b6 80 40 20 12 c0 	movzbl -0x3feddfc0(%eax),%eax
c0101d20:	0c 40                	or     $0x40,%al
c0101d22:	0f b6 c0             	movzbl %al,%eax
c0101d25:	f7 d0                	not    %eax
c0101d27:	89 c2                	mov    %eax,%edx
c0101d29:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d2e:	21 d0                	and    %edx,%eax
c0101d30:	a3 48 57 12 c0       	mov    %eax,0xc0125748
        return 0;
c0101d35:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d3a:	e9 d5 00 00 00       	jmp    c0101e14 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c0101d3f:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d44:	83 e0 40             	and    $0x40,%eax
c0101d47:	85 c0                	test   %eax,%eax
c0101d49:	74 11                	je     c0101d5c <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d4b:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d4f:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d54:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d57:	a3 48 57 12 c0       	mov    %eax,0xc0125748
    }

    shift |= shiftcode[data];
c0101d5c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d60:	0f b6 80 40 20 12 c0 	movzbl -0x3feddfc0(%eax),%eax
c0101d67:	0f b6 d0             	movzbl %al,%edx
c0101d6a:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d6f:	09 d0                	or     %edx,%eax
c0101d71:	a3 48 57 12 c0       	mov    %eax,0xc0125748
    shift ^= togglecode[data];
c0101d76:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d7a:	0f b6 80 40 21 12 c0 	movzbl -0x3feddec0(%eax),%eax
c0101d81:	0f b6 d0             	movzbl %al,%edx
c0101d84:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d89:	31 d0                	xor    %edx,%eax
c0101d8b:	a3 48 57 12 c0       	mov    %eax,0xc0125748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101d90:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d95:	83 e0 03             	and    $0x3,%eax
c0101d98:	8b 14 85 40 25 12 c0 	mov    -0x3feddac0(,%eax,4),%edx
c0101d9f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101da3:	01 d0                	add    %edx,%eax
c0101da5:	0f b6 00             	movzbl (%eax),%eax
c0101da8:	0f b6 c0             	movzbl %al,%eax
c0101dab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101dae:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101db3:	83 e0 08             	and    $0x8,%eax
c0101db6:	85 c0                	test   %eax,%eax
c0101db8:	74 22                	je     c0101ddc <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101dba:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101dbe:	7e 0c                	jle    c0101dcc <kbd_proc_data+0x13a>
c0101dc0:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101dc4:	7f 06                	jg     c0101dcc <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101dc6:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101dca:	eb 10                	jmp    c0101ddc <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101dcc:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101dd0:	7e 0a                	jle    c0101ddc <kbd_proc_data+0x14a>
c0101dd2:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101dd6:	7f 04                	jg     c0101ddc <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101dd8:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101ddc:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101de1:	f7 d0                	not    %eax
c0101de3:	83 e0 06             	and    $0x6,%eax
c0101de6:	85 c0                	test   %eax,%eax
c0101de8:	75 27                	jne    c0101e11 <kbd_proc_data+0x17f>
c0101dea:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101df1:	75 1e                	jne    c0101e11 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c0101df3:	c7 04 24 01 98 10 c0 	movl   $0xc0109801,(%esp)
c0101dfa:	e8 ad e4 ff ff       	call   c01002ac <cprintf>
c0101dff:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101e05:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e09:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101e0d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101e10:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e14:	c9                   	leave  
c0101e15:	c3                   	ret    

c0101e16 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e16:	55                   	push   %ebp
c0101e17:	89 e5                	mov    %esp,%ebp
c0101e19:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e1c:	c7 04 24 92 1c 10 c0 	movl   $0xc0101c92,(%esp)
c0101e23:	e8 a9 fd ff ff       	call   c0101bd1 <cons_intr>
}
c0101e28:	90                   	nop
c0101e29:	c9                   	leave  
c0101e2a:	c3                   	ret    

c0101e2b <kbd_init>:

static void
kbd_init(void) {
c0101e2b:	55                   	push   %ebp
c0101e2c:	89 e5                	mov    %esp,%ebp
c0101e2e:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e31:	e8 e0 ff ff ff       	call   c0101e16 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e3d:	e8 35 01 00 00       	call   c0101f77 <pic_enable>
}
c0101e42:	90                   	nop
c0101e43:	c9                   	leave  
c0101e44:	c3                   	ret    

c0101e45 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e45:	55                   	push   %ebp
c0101e46:	89 e5                	mov    %esp,%ebp
c0101e48:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e4b:	e8 83 f8 ff ff       	call   c01016d3 <cga_init>
    serial_init();
c0101e50:	e8 62 f9 ff ff       	call   c01017b7 <serial_init>
    kbd_init();
c0101e55:	e8 d1 ff ff ff       	call   c0101e2b <kbd_init>
    if (!serial_exists) {
c0101e5a:	a1 28 55 12 c0       	mov    0xc0125528,%eax
c0101e5f:	85 c0                	test   %eax,%eax
c0101e61:	75 0c                	jne    c0101e6f <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101e63:	c7 04 24 0d 98 10 c0 	movl   $0xc010980d,(%esp)
c0101e6a:	e8 3d e4 ff ff       	call   c01002ac <cprintf>
    }
}
c0101e6f:	90                   	nop
c0101e70:	c9                   	leave  
c0101e71:	c3                   	ret    

c0101e72 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101e72:	55                   	push   %ebp
c0101e73:	89 e5                	mov    %esp,%ebp
c0101e75:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e78:	e8 cf f7 ff ff       	call   c010164c <__intr_save>
c0101e7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101e80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e83:	89 04 24             	mov    %eax,(%esp)
c0101e86:	e8 89 fa ff ff       	call   c0101914 <lpt_putc>
        cga_putc(c);
c0101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e8e:	89 04 24             	mov    %eax,(%esp)
c0101e91:	e8 be fa ff ff       	call   c0101954 <cga_putc>
        serial_putc(c);
c0101e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e99:	89 04 24             	mov    %eax,(%esp)
c0101e9c:	e8 f0 fc ff ff       	call   c0101b91 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ea4:	89 04 24             	mov    %eax,(%esp)
c0101ea7:	e8 ca f7 ff ff       	call   c0101676 <__intr_restore>
}
c0101eac:	90                   	nop
c0101ead:	c9                   	leave  
c0101eae:	c3                   	ret    

c0101eaf <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101eaf:	55                   	push   %ebp
c0101eb0:	89 e5                	mov    %esp,%ebp
c0101eb2:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101eb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101ebc:	e8 8b f7 ff ff       	call   c010164c <__intr_save>
c0101ec1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ec4:	e8 ab fd ff ff       	call   c0101c74 <serial_intr>
        kbd_intr();
c0101ec9:	e8 48 ff ff ff       	call   c0101e16 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101ece:	8b 15 40 57 12 c0    	mov    0xc0125740,%edx
c0101ed4:	a1 44 57 12 c0       	mov    0xc0125744,%eax
c0101ed9:	39 c2                	cmp    %eax,%edx
c0101edb:	74 31                	je     c0101f0e <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101edd:	a1 40 57 12 c0       	mov    0xc0125740,%eax
c0101ee2:	8d 50 01             	lea    0x1(%eax),%edx
c0101ee5:	89 15 40 57 12 c0    	mov    %edx,0xc0125740
c0101eeb:	0f b6 80 40 55 12 c0 	movzbl -0x3fedaac0(%eax),%eax
c0101ef2:	0f b6 c0             	movzbl %al,%eax
c0101ef5:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101ef8:	a1 40 57 12 c0       	mov    0xc0125740,%eax
c0101efd:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101f02:	75 0a                	jne    c0101f0e <cons_getc+0x5f>
                cons.rpos = 0;
c0101f04:	c7 05 40 57 12 c0 00 	movl   $0x0,0xc0125740
c0101f0b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f11:	89 04 24             	mov    %eax,(%esp)
c0101f14:	e8 5d f7 ff ff       	call   c0101676 <__intr_restore>
    return c;
c0101f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f1c:	c9                   	leave  
c0101f1d:	c3                   	ret    

c0101f1e <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f1e:	55                   	push   %ebp
c0101f1f:	89 e5                	mov    %esp,%ebp
c0101f21:	83 ec 14             	sub    $0x14,%esp
c0101f24:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f27:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f2e:	66 a3 50 25 12 c0    	mov    %ax,0xc0122550
    if (did_init) {
c0101f34:	a1 4c 57 12 c0       	mov    0xc012574c,%eax
c0101f39:	85 c0                	test   %eax,%eax
c0101f3b:	74 37                	je     c0101f74 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f40:	0f b6 c0             	movzbl %al,%eax
c0101f43:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101f49:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101f4c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101f50:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101f54:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f55:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f59:	c1 e8 08             	shr    $0x8,%eax
c0101f5c:	0f b7 c0             	movzwl %ax,%eax
c0101f5f:	0f b6 c0             	movzbl %al,%eax
c0101f62:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101f68:	88 45 fd             	mov    %al,-0x3(%ebp)
c0101f6b:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f6f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f73:	ee                   	out    %al,(%dx)
    }
}
c0101f74:	90                   	nop
c0101f75:	c9                   	leave  
c0101f76:	c3                   	ret    

c0101f77 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101f77:	55                   	push   %ebp
c0101f78:	89 e5                	mov    %esp,%ebp
c0101f7a:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f80:	ba 01 00 00 00       	mov    $0x1,%edx
c0101f85:	88 c1                	mov    %al,%cl
c0101f87:	d3 e2                	shl    %cl,%edx
c0101f89:	89 d0                	mov    %edx,%eax
c0101f8b:	98                   	cwtl   
c0101f8c:	f7 d0                	not    %eax
c0101f8e:	0f bf d0             	movswl %ax,%edx
c0101f91:	0f b7 05 50 25 12 c0 	movzwl 0xc0122550,%eax
c0101f98:	98                   	cwtl   
c0101f99:	21 d0                	and    %edx,%eax
c0101f9b:	98                   	cwtl   
c0101f9c:	0f b7 c0             	movzwl %ax,%eax
c0101f9f:	89 04 24             	mov    %eax,(%esp)
c0101fa2:	e8 77 ff ff ff       	call   c0101f1e <pic_setmask>
}
c0101fa7:	90                   	nop
c0101fa8:	c9                   	leave  
c0101fa9:	c3                   	ret    

c0101faa <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101faa:	55                   	push   %ebp
c0101fab:	89 e5                	mov    %esp,%ebp
c0101fad:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101fb0:	c7 05 4c 57 12 c0 01 	movl   $0x1,0xc012574c
c0101fb7:	00 00 00 
c0101fba:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101fc0:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0101fc4:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101fc8:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101fcc:	ee                   	out    %al,(%dx)
c0101fcd:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101fd3:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c0101fd7:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101fdb:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101fdf:	ee                   	out    %al,(%dx)
c0101fe0:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101fe6:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c0101fea:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101fee:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101ff2:	ee                   	out    %al,(%dx)
c0101ff3:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101ff9:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101ffd:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102001:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102005:	ee                   	out    %al,(%dx)
c0102006:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c010200c:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c0102010:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102014:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102018:	ee                   	out    %al,(%dx)
c0102019:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010201f:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c0102023:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102027:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010202b:	ee                   	out    %al,(%dx)
c010202c:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0102032:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c0102036:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010203a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010203e:	ee                   	out    %al,(%dx)
c010203f:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102045:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c0102049:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010204d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102051:	ee                   	out    %al,(%dx)
c0102052:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0102058:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c010205c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102060:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102064:	ee                   	out    %al,(%dx)
c0102065:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010206b:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c010206f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102073:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102077:	ee                   	out    %al,(%dx)
c0102078:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c010207e:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0102082:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102086:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010208a:	ee                   	out    %al,(%dx)
c010208b:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102091:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c0102095:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102099:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010209d:	ee                   	out    %al,(%dx)
c010209e:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01020a4:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c01020a8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020ac:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020b0:	ee                   	out    %al,(%dx)
c01020b1:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01020b7:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c01020bb:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020bf:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020c3:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020c4:	0f b7 05 50 25 12 c0 	movzwl 0xc0122550,%eax
c01020cb:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01020d0:	74 0f                	je     c01020e1 <pic_init+0x137>
        pic_setmask(irq_mask);
c01020d2:	0f b7 05 50 25 12 c0 	movzwl 0xc0122550,%eax
c01020d9:	89 04 24             	mov    %eax,(%esp)
c01020dc:	e8 3d fe ff ff       	call   c0101f1e <pic_setmask>
    }
}
c01020e1:	90                   	nop
c01020e2:	c9                   	leave  
c01020e3:	c3                   	ret    

c01020e4 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01020e4:	55                   	push   %ebp
c01020e5:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c01020e7:	fb                   	sti    
    sti();
}
c01020e8:	90                   	nop
c01020e9:	5d                   	pop    %ebp
c01020ea:	c3                   	ret    

c01020eb <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020eb:	55                   	push   %ebp
c01020ec:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01020ee:	fa                   	cli    
    cli();
}
c01020ef:	90                   	nop
c01020f0:	5d                   	pop    %ebp
c01020f1:	c3                   	ret    

c01020f2 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01020f2:	55                   	push   %ebp
c01020f3:	89 e5                	mov    %esp,%ebp
c01020f5:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01020f8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01020ff:	00 
c0102100:	c7 04 24 40 98 10 c0 	movl   $0xc0109840,(%esp)
c0102107:	e8 a0 e1 ff ff       	call   c01002ac <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010210c:	c7 04 24 4a 98 10 c0 	movl   $0xc010984a,(%esp)
c0102113:	e8 94 e1 ff ff       	call   c01002ac <cprintf>
    panic("EOT: kernel seems ok.");
c0102118:	c7 44 24 08 58 98 10 	movl   $0xc0109858,0x8(%esp)
c010211f:	c0 
c0102120:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0102127:	00 
c0102128:	c7 04 24 6e 98 10 c0 	movl   $0xc010986e,(%esp)
c010212f:	e8 cf e2 ff ff       	call   c0100403 <__panic>

c0102134 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102134:	55                   	push   %ebp
c0102135:	89 e5                	mov    %esp,%ebp
c0102137:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) { 
c010213a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102141:	e9 c4 00 00 00       	jmp    c010220a <idt_init+0xd6>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
c0102146:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102149:	8b 04 85 e0 25 12 c0 	mov    -0x3fedda20(,%eax,4),%eax
c0102150:	0f b7 d0             	movzwl %ax,%edx
c0102153:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102156:	66 89 14 c5 60 57 12 	mov    %dx,-0x3feda8a0(,%eax,8)
c010215d:	c0 
c010215e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102161:	66 c7 04 c5 62 57 12 	movw   $0x8,-0x3feda89e(,%eax,8)
c0102168:	c0 08 00 
c010216b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010216e:	0f b6 14 c5 64 57 12 	movzbl -0x3feda89c(,%eax,8),%edx
c0102175:	c0 
c0102176:	80 e2 e0             	and    $0xe0,%dl
c0102179:	88 14 c5 64 57 12 c0 	mov    %dl,-0x3feda89c(,%eax,8)
c0102180:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102183:	0f b6 14 c5 64 57 12 	movzbl -0x3feda89c(,%eax,8),%edx
c010218a:	c0 
c010218b:	80 e2 1f             	and    $0x1f,%dl
c010218e:	88 14 c5 64 57 12 c0 	mov    %dl,-0x3feda89c(,%eax,8)
c0102195:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102198:	0f b6 14 c5 65 57 12 	movzbl -0x3feda89b(,%eax,8),%edx
c010219f:	c0 
c01021a0:	80 e2 f0             	and    $0xf0,%dl
c01021a3:	80 ca 0e             	or     $0xe,%dl
c01021a6:	88 14 c5 65 57 12 c0 	mov    %dl,-0x3feda89b(,%eax,8)
c01021ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021b0:	0f b6 14 c5 65 57 12 	movzbl -0x3feda89b(,%eax,8),%edx
c01021b7:	c0 
c01021b8:	80 e2 ef             	and    $0xef,%dl
c01021bb:	88 14 c5 65 57 12 c0 	mov    %dl,-0x3feda89b(,%eax,8)
c01021c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c5:	0f b6 14 c5 65 57 12 	movzbl -0x3feda89b(,%eax,8),%edx
c01021cc:	c0 
c01021cd:	80 e2 9f             	and    $0x9f,%dl
c01021d0:	88 14 c5 65 57 12 c0 	mov    %dl,-0x3feda89b(,%eax,8)
c01021d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021da:	0f b6 14 c5 65 57 12 	movzbl -0x3feda89b(,%eax,8),%edx
c01021e1:	c0 
c01021e2:	80 ca 80             	or     $0x80,%dl
c01021e5:	88 14 c5 65 57 12 c0 	mov    %dl,-0x3feda89b(,%eax,8)
c01021ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ef:	8b 04 85 e0 25 12 c0 	mov    -0x3fedda20(,%eax,4),%eax
c01021f6:	c1 e8 10             	shr    $0x10,%eax
c01021f9:	0f b7 d0             	movzwl %ax,%edx
c01021fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ff:	66 89 14 c5 66 57 12 	mov    %dx,-0x3feda89a(,%eax,8)
c0102206:	c0 
    for (int i = 0; i < 256; i++) { 
c0102207:	ff 45 fc             	incl   -0x4(%ebp)
c010220a:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0102211:	0f 8e 2f ff ff ff    	jle    c0102146 <idt_init+0x12>
    }
    //referenced: #define SETGATE(gate, istrap, sel, off, dpl)
    //so the 'istrap' below is set as 1;
    //referenced:  KERNEL_CS    ((GD_KTEXT) | DPL_KERNEL)
    SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], DPL_USER);
c0102217:	a1 c4 27 12 c0       	mov    0xc01227c4,%eax
c010221c:	0f b7 c0             	movzwl %ax,%eax
c010221f:	66 a3 28 5b 12 c0    	mov    %ax,0xc0125b28
c0102225:	66 c7 05 2a 5b 12 c0 	movw   $0x8,0xc0125b2a
c010222c:	08 00 
c010222e:	0f b6 05 2c 5b 12 c0 	movzbl 0xc0125b2c,%eax
c0102235:	24 e0                	and    $0xe0,%al
c0102237:	a2 2c 5b 12 c0       	mov    %al,0xc0125b2c
c010223c:	0f b6 05 2c 5b 12 c0 	movzbl 0xc0125b2c,%eax
c0102243:	24 1f                	and    $0x1f,%al
c0102245:	a2 2c 5b 12 c0       	mov    %al,0xc0125b2c
c010224a:	0f b6 05 2d 5b 12 c0 	movzbl 0xc0125b2d,%eax
c0102251:	0c 0f                	or     $0xf,%al
c0102253:	a2 2d 5b 12 c0       	mov    %al,0xc0125b2d
c0102258:	0f b6 05 2d 5b 12 c0 	movzbl 0xc0125b2d,%eax
c010225f:	24 ef                	and    $0xef,%al
c0102261:	a2 2d 5b 12 c0       	mov    %al,0xc0125b2d
c0102266:	0f b6 05 2d 5b 12 c0 	movzbl 0xc0125b2d,%eax
c010226d:	0c 60                	or     $0x60,%al
c010226f:	a2 2d 5b 12 c0       	mov    %al,0xc0125b2d
c0102274:	0f b6 05 2d 5b 12 c0 	movzbl 0xc0125b2d,%eax
c010227b:	0c 80                	or     $0x80,%al
c010227d:	a2 2d 5b 12 c0       	mov    %al,0xc0125b2d
c0102282:	a1 c4 27 12 c0       	mov    0xc01227c4,%eax
c0102287:	c1 e8 10             	shr    $0x10,%eax
c010228a:	0f b7 c0             	movzwl %ax,%eax
c010228d:	66 a3 2e 5b 12 c0    	mov    %ax,0xc0125b2e
    SETGATE(idt[T_SWITCH_TOU], 1, KERNEL_CS, __vectors[T_SWITCH_TOU], DPL_KERNEL);
c0102293:	a1 c0 27 12 c0       	mov    0xc01227c0,%eax
c0102298:	0f b7 c0             	movzwl %ax,%eax
c010229b:	66 a3 20 5b 12 c0    	mov    %ax,0xc0125b20
c01022a1:	66 c7 05 22 5b 12 c0 	movw   $0x8,0xc0125b22
c01022a8:	08 00 
c01022aa:	0f b6 05 24 5b 12 c0 	movzbl 0xc0125b24,%eax
c01022b1:	24 e0                	and    $0xe0,%al
c01022b3:	a2 24 5b 12 c0       	mov    %al,0xc0125b24
c01022b8:	0f b6 05 24 5b 12 c0 	movzbl 0xc0125b24,%eax
c01022bf:	24 1f                	and    $0x1f,%al
c01022c1:	a2 24 5b 12 c0       	mov    %al,0xc0125b24
c01022c6:	0f b6 05 25 5b 12 c0 	movzbl 0xc0125b25,%eax
c01022cd:	0c 0f                	or     $0xf,%al
c01022cf:	a2 25 5b 12 c0       	mov    %al,0xc0125b25
c01022d4:	0f b6 05 25 5b 12 c0 	movzbl 0xc0125b25,%eax
c01022db:	24 ef                	and    $0xef,%al
c01022dd:	a2 25 5b 12 c0       	mov    %al,0xc0125b25
c01022e2:	0f b6 05 25 5b 12 c0 	movzbl 0xc0125b25,%eax
c01022e9:	24 9f                	and    $0x9f,%al
c01022eb:	a2 25 5b 12 c0       	mov    %al,0xc0125b25
c01022f0:	0f b6 05 25 5b 12 c0 	movzbl 0xc0125b25,%eax
c01022f7:	0c 80                	or     $0x80,%al
c01022f9:	a2 25 5b 12 c0       	mov    %al,0xc0125b25
c01022fe:	a1 c0 27 12 c0       	mov    0xc01227c0,%eax
c0102303:	c1 e8 10             	shr    $0x10,%eax
c0102306:	0f b7 c0             	movzwl %ax,%eax
c0102309:	66 a3 26 5b 12 c0    	mov    %ax,0xc0125b26
c010230f:	c7 45 f8 60 25 12 c0 	movl   $0xc0122560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102316:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102319:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c010231c:	90                   	nop
c010231d:	c9                   	leave  
c010231e:	c3                   	ret    

c010231f <trapname>:

static const char *
trapname(int trapno) {
c010231f:	55                   	push   %ebp
c0102320:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102322:	8b 45 08             	mov    0x8(%ebp),%eax
c0102325:	83 f8 13             	cmp    $0x13,%eax
c0102328:	77 0c                	ja     c0102336 <trapname+0x17>
        return excnames[trapno];
c010232a:	8b 45 08             	mov    0x8(%ebp),%eax
c010232d:	8b 04 85 80 9c 10 c0 	mov    -0x3fef6380(,%eax,4),%eax
c0102334:	eb 18                	jmp    c010234e <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0102336:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c010233a:	7e 0d                	jle    c0102349 <trapname+0x2a>
c010233c:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102340:	7f 07                	jg     c0102349 <trapname+0x2a>
        return "Hardware Interrupt";
c0102342:	b8 7f 98 10 c0       	mov    $0xc010987f,%eax
c0102347:	eb 05                	jmp    c010234e <trapname+0x2f>
    }
    return "(unknown trap)";
c0102349:	b8 92 98 10 c0       	mov    $0xc0109892,%eax
}
c010234e:	5d                   	pop    %ebp
c010234f:	c3                   	ret    

c0102350 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102350:	55                   	push   %ebp
c0102351:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0102353:	8b 45 08             	mov    0x8(%ebp),%eax
c0102356:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010235a:	83 f8 08             	cmp    $0x8,%eax
c010235d:	0f 94 c0             	sete   %al
c0102360:	0f b6 c0             	movzbl %al,%eax
}
c0102363:	5d                   	pop    %ebp
c0102364:	c3                   	ret    

c0102365 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102365:	55                   	push   %ebp
c0102366:	89 e5                	mov    %esp,%ebp
c0102368:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c010236b:	8b 45 08             	mov    0x8(%ebp),%eax
c010236e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102372:	c7 04 24 d3 98 10 c0 	movl   $0xc01098d3,(%esp)
c0102379:	e8 2e df ff ff       	call   c01002ac <cprintf>
    print_regs(&tf->tf_regs);
c010237e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102381:	89 04 24             	mov    %eax,(%esp)
c0102384:	e8 8f 01 00 00       	call   c0102518 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102389:	8b 45 08             	mov    0x8(%ebp),%eax
c010238c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102390:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102394:	c7 04 24 e4 98 10 c0 	movl   $0xc01098e4,(%esp)
c010239b:	e8 0c df ff ff       	call   c01002ac <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01023a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a3:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01023a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023ab:	c7 04 24 f7 98 10 c0 	movl   $0xc01098f7,(%esp)
c01023b2:	e8 f5 de ff ff       	call   c01002ac <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01023b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ba:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01023be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023c2:	c7 04 24 0a 99 10 c0 	movl   $0xc010990a,(%esp)
c01023c9:	e8 de de ff ff       	call   c01002ac <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01023ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d1:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01023d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023d9:	c7 04 24 1d 99 10 c0 	movl   $0xc010991d,(%esp)
c01023e0:	e8 c7 de ff ff       	call   c01002ac <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01023e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e8:	8b 40 30             	mov    0x30(%eax),%eax
c01023eb:	89 04 24             	mov    %eax,(%esp)
c01023ee:	e8 2c ff ff ff       	call   c010231f <trapname>
c01023f3:	89 c2                	mov    %eax,%edx
c01023f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f8:	8b 40 30             	mov    0x30(%eax),%eax
c01023fb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01023ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102403:	c7 04 24 30 99 10 c0 	movl   $0xc0109930,(%esp)
c010240a:	e8 9d de ff ff       	call   c01002ac <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c010240f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102412:	8b 40 34             	mov    0x34(%eax),%eax
c0102415:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102419:	c7 04 24 42 99 10 c0 	movl   $0xc0109942,(%esp)
c0102420:	e8 87 de ff ff       	call   c01002ac <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102425:	8b 45 08             	mov    0x8(%ebp),%eax
c0102428:	8b 40 38             	mov    0x38(%eax),%eax
c010242b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010242f:	c7 04 24 51 99 10 c0 	movl   $0xc0109951,(%esp)
c0102436:	e8 71 de ff ff       	call   c01002ac <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c010243b:	8b 45 08             	mov    0x8(%ebp),%eax
c010243e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102442:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102446:	c7 04 24 60 99 10 c0 	movl   $0xc0109960,(%esp)
c010244d:	e8 5a de ff ff       	call   c01002ac <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0102452:	8b 45 08             	mov    0x8(%ebp),%eax
c0102455:	8b 40 40             	mov    0x40(%eax),%eax
c0102458:	89 44 24 04          	mov    %eax,0x4(%esp)
c010245c:	c7 04 24 73 99 10 c0 	movl   $0xc0109973,(%esp)
c0102463:	e8 44 de ff ff       	call   c01002ac <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102468:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010246f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102476:	eb 3d                	jmp    c01024b5 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102478:	8b 45 08             	mov    0x8(%ebp),%eax
c010247b:	8b 50 40             	mov    0x40(%eax),%edx
c010247e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102481:	21 d0                	and    %edx,%eax
c0102483:	85 c0                	test   %eax,%eax
c0102485:	74 28                	je     c01024af <print_trapframe+0x14a>
c0102487:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010248a:	8b 04 85 80 25 12 c0 	mov    -0x3fedda80(,%eax,4),%eax
c0102491:	85 c0                	test   %eax,%eax
c0102493:	74 1a                	je     c01024af <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0102495:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102498:	8b 04 85 80 25 12 c0 	mov    -0x3fedda80(,%eax,4),%eax
c010249f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024a3:	c7 04 24 82 99 10 c0 	movl   $0xc0109982,(%esp)
c01024aa:	e8 fd dd ff ff       	call   c01002ac <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024af:	ff 45 f4             	incl   -0xc(%ebp)
c01024b2:	d1 65 f0             	shll   -0x10(%ebp)
c01024b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024b8:	83 f8 17             	cmp    $0x17,%eax
c01024bb:	76 bb                	jbe    c0102478 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01024bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c0:	8b 40 40             	mov    0x40(%eax),%eax
c01024c3:	c1 e8 0c             	shr    $0xc,%eax
c01024c6:	83 e0 03             	and    $0x3,%eax
c01024c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024cd:	c7 04 24 86 99 10 c0 	movl   $0xc0109986,(%esp)
c01024d4:	e8 d3 dd ff ff       	call   c01002ac <cprintf>

    if (!trap_in_kernel(tf)) {
c01024d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01024dc:	89 04 24             	mov    %eax,(%esp)
c01024df:	e8 6c fe ff ff       	call   c0102350 <trap_in_kernel>
c01024e4:	85 c0                	test   %eax,%eax
c01024e6:	75 2d                	jne    c0102515 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01024e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024eb:	8b 40 44             	mov    0x44(%eax),%eax
c01024ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f2:	c7 04 24 8f 99 10 c0 	movl   $0xc010998f,(%esp)
c01024f9:	e8 ae dd ff ff       	call   c01002ac <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01024fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102501:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102505:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102509:	c7 04 24 9e 99 10 c0 	movl   $0xc010999e,(%esp)
c0102510:	e8 97 dd ff ff       	call   c01002ac <cprintf>
    }
}
c0102515:	90                   	nop
c0102516:	c9                   	leave  
c0102517:	c3                   	ret    

c0102518 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102518:	55                   	push   %ebp
c0102519:	89 e5                	mov    %esp,%ebp
c010251b:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010251e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102521:	8b 00                	mov    (%eax),%eax
c0102523:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102527:	c7 04 24 b1 99 10 c0 	movl   $0xc01099b1,(%esp)
c010252e:	e8 79 dd ff ff       	call   c01002ac <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0102533:	8b 45 08             	mov    0x8(%ebp),%eax
c0102536:	8b 40 04             	mov    0x4(%eax),%eax
c0102539:	89 44 24 04          	mov    %eax,0x4(%esp)
c010253d:	c7 04 24 c0 99 10 c0 	movl   $0xc01099c0,(%esp)
c0102544:	e8 63 dd ff ff       	call   c01002ac <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102549:	8b 45 08             	mov    0x8(%ebp),%eax
c010254c:	8b 40 08             	mov    0x8(%eax),%eax
c010254f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102553:	c7 04 24 cf 99 10 c0 	movl   $0xc01099cf,(%esp)
c010255a:	e8 4d dd ff ff       	call   c01002ac <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010255f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102562:	8b 40 0c             	mov    0xc(%eax),%eax
c0102565:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102569:	c7 04 24 de 99 10 c0 	movl   $0xc01099de,(%esp)
c0102570:	e8 37 dd ff ff       	call   c01002ac <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102575:	8b 45 08             	mov    0x8(%ebp),%eax
c0102578:	8b 40 10             	mov    0x10(%eax),%eax
c010257b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010257f:	c7 04 24 ed 99 10 c0 	movl   $0xc01099ed,(%esp)
c0102586:	e8 21 dd ff ff       	call   c01002ac <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010258b:	8b 45 08             	mov    0x8(%ebp),%eax
c010258e:	8b 40 14             	mov    0x14(%eax),%eax
c0102591:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102595:	c7 04 24 fc 99 10 c0 	movl   $0xc01099fc,(%esp)
c010259c:	e8 0b dd ff ff       	call   c01002ac <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01025a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a4:	8b 40 18             	mov    0x18(%eax),%eax
c01025a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ab:	c7 04 24 0b 9a 10 c0 	movl   $0xc0109a0b,(%esp)
c01025b2:	e8 f5 dc ff ff       	call   c01002ac <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01025b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ba:	8b 40 1c             	mov    0x1c(%eax),%eax
c01025bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c1:	c7 04 24 1a 9a 10 c0 	movl   $0xc0109a1a,(%esp)
c01025c8:	e8 df dc ff ff       	call   c01002ac <cprintf>
}
c01025cd:	90                   	nop
c01025ce:	c9                   	leave  
c01025cf:	c3                   	ret    

c01025d0 <print_pgfault>:
    tf->tf_eflags |= 0x3000;
}
*/

static inline void
print_pgfault(struct trapframe *tf) {
c01025d0:	55                   	push   %ebp
c01025d1:	89 e5                	mov    %esp,%ebp
c01025d3:	53                   	push   %ebx
c01025d4:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c01025d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025da:	8b 40 34             	mov    0x34(%eax),%eax
c01025dd:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025e0:	85 c0                	test   %eax,%eax
c01025e2:	74 07                	je     c01025eb <print_pgfault+0x1b>
c01025e4:	bb 29 9a 10 c0       	mov    $0xc0109a29,%ebx
c01025e9:	eb 05                	jmp    c01025f0 <print_pgfault+0x20>
c01025eb:	bb 3a 9a 10 c0       	mov    $0xc0109a3a,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c01025f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f3:	8b 40 34             	mov    0x34(%eax),%eax
c01025f6:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025f9:	85 c0                	test   %eax,%eax
c01025fb:	74 07                	je     c0102604 <print_pgfault+0x34>
c01025fd:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102602:	eb 05                	jmp    c0102609 <print_pgfault+0x39>
c0102604:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102609:	8b 45 08             	mov    0x8(%ebp),%eax
c010260c:	8b 40 34             	mov    0x34(%eax),%eax
c010260f:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102612:	85 c0                	test   %eax,%eax
c0102614:	74 07                	je     c010261d <print_pgfault+0x4d>
c0102616:	ba 55 00 00 00       	mov    $0x55,%edx
c010261b:	eb 05                	jmp    c0102622 <print_pgfault+0x52>
c010261d:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102622:	0f 20 d0             	mov    %cr2,%eax
c0102625:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102628:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010262b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010262f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102633:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010263b:	c7 04 24 48 9a 10 c0 	movl   $0xc0109a48,(%esp)
c0102642:	e8 65 dc ff ff       	call   c01002ac <cprintf>
}
c0102647:	90                   	nop
c0102648:	83 c4 34             	add    $0x34,%esp
c010264b:	5b                   	pop    %ebx
c010264c:	5d                   	pop    %ebp
c010264d:	c3                   	ret    

c010264e <pgfault_handler>:


static int
pgfault_handler(struct trapframe *tf) {
c010264e:	55                   	push   %ebp
c010264f:	89 e5                	mov    %esp,%ebp
c0102651:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0102654:	8b 45 08             	mov    0x8(%ebp),%eax
c0102657:	89 04 24             	mov    %eax,(%esp)
c010265a:	e8 71 ff ff ff       	call   c01025d0 <print_pgfault>
    if (check_mm_struct != NULL) {
c010265f:	a1 34 60 12 c0       	mov    0xc0126034,%eax
c0102664:	85 c0                	test   %eax,%eax
c0102666:	74 26                	je     c010268e <pgfault_handler+0x40>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102668:	0f 20 d0             	mov    %cr2,%eax
c010266b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010266e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102671:	8b 45 08             	mov    0x8(%ebp),%eax
c0102674:	8b 50 34             	mov    0x34(%eax),%edx
c0102677:	a1 34 60 12 c0       	mov    0xc0126034,%eax
c010267c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102680:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102684:	89 04 24             	mov    %eax,(%esp)
c0102687:	e8 c9 3a 00 00       	call   c0106155 <do_pgfault>
c010268c:	eb 1c                	jmp    c01026aa <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c010268e:	c7 44 24 08 6b 9a 10 	movl   $0xc0109a6b,0x8(%esp)
c0102695:	c0 
c0102696:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c010269d:	00 
c010269e:	c7 04 24 6e 98 10 c0 	movl   $0xc010986e,(%esp)
c01026a5:	e8 59 dd ff ff       	call   c0100403 <__panic>
}
c01026aa:	c9                   	leave  
c01026ab:	c3                   	ret    

c01026ac <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01026ac:	55                   	push   %ebp
c01026ad:	89 e5                	mov    %esp,%ebp
c01026af:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01026b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b5:	8b 40 30             	mov    0x30(%eax),%eax
c01026b8:	83 f8 24             	cmp    $0x24,%eax
c01026bb:	0f 84 da 00 00 00    	je     c010279b <trap_dispatch+0xef>
c01026c1:	83 f8 24             	cmp    $0x24,%eax
c01026c4:	77 1c                	ja     c01026e2 <trap_dispatch+0x36>
c01026c6:	83 f8 20             	cmp    $0x20,%eax
c01026c9:	0f 84 86 00 00 00    	je     c0102755 <trap_dispatch+0xa9>
c01026cf:	83 f8 21             	cmp    $0x21,%eax
c01026d2:	0f 84 ec 00 00 00    	je     c01027c4 <trap_dispatch+0x118>
c01026d8:	83 f8 0e             	cmp    $0xe,%eax
c01026db:	74 32                	je     c010270f <trap_dispatch+0x63>
c01026dd:	e9 86 02 00 00       	jmp    c0102968 <trap_dispatch+0x2bc>
c01026e2:	83 f8 78             	cmp    $0x78,%eax
c01026e5:	0f 84 e9 01 00 00    	je     c01028d4 <trap_dispatch+0x228>
c01026eb:	83 f8 78             	cmp    $0x78,%eax
c01026ee:	77 11                	ja     c0102701 <trap_dispatch+0x55>
c01026f0:	83 e8 2e             	sub    $0x2e,%eax
c01026f3:	83 f8 01             	cmp    $0x1,%eax
c01026f6:	0f 87 6c 02 00 00    	ja     c0102968 <trap_dispatch+0x2bc>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01026fc:	e9 a6 02 00 00       	jmp    c01029a7 <trap_dispatch+0x2fb>
    switch (tf->tf_trapno) {
c0102701:	83 f8 79             	cmp    $0x79,%eax
c0102704:	0f 84 1d 02 00 00    	je     c0102927 <trap_dispatch+0x27b>
c010270a:	e9 59 02 00 00       	jmp    c0102968 <trap_dispatch+0x2bc>
        if ((ret = pgfault_handler(tf)) != 0) {
c010270f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102712:	89 04 24             	mov    %eax,(%esp)
c0102715:	e8 34 ff ff ff       	call   c010264e <pgfault_handler>
c010271a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010271d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102721:	0f 84 76 02 00 00    	je     c010299d <trap_dispatch+0x2f1>
            print_trapframe(tf);
c0102727:	8b 45 08             	mov    0x8(%ebp),%eax
c010272a:	89 04 24             	mov    %eax,(%esp)
c010272d:	e8 33 fc ff ff       	call   c0102365 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102732:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102735:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102739:	c7 44 24 08 82 9a 10 	movl   $0xc0109a82,0x8(%esp)
c0102740:	c0 
c0102741:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0102748:	00 
c0102749:	c7 04 24 6e 98 10 c0 	movl   $0xc010986e,(%esp)
c0102750:	e8 ae dc ff ff       	call   c0100403 <__panic>
        ticks += 1;
c0102755:	a1 1c 60 12 c0       	mov    0xc012601c,%eax
c010275a:	40                   	inc    %eax
c010275b:	a3 1c 60 12 c0       	mov    %eax,0xc012601c
        if (!(ticks % TICK_NUM)) {
c0102760:	8b 0d 1c 60 12 c0    	mov    0xc012601c,%ecx
c0102766:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010276b:	89 c8                	mov    %ecx,%eax
c010276d:	f7 e2                	mul    %edx
c010276f:	c1 ea 05             	shr    $0x5,%edx
c0102772:	89 d0                	mov    %edx,%eax
c0102774:	c1 e0 02             	shl    $0x2,%eax
c0102777:	01 d0                	add    %edx,%eax
c0102779:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0102780:	01 d0                	add    %edx,%eax
c0102782:	c1 e0 02             	shl    $0x2,%eax
c0102785:	29 c1                	sub    %eax,%ecx
c0102787:	89 ca                	mov    %ecx,%edx
c0102789:	85 d2                	test   %edx,%edx
c010278b:	0f 85 0f 02 00 00    	jne    c01029a0 <trap_dispatch+0x2f4>
            print_ticks();
c0102791:	e8 5c f9 ff ff       	call   c01020f2 <print_ticks>
        break;
c0102796:	e9 05 02 00 00       	jmp    c01029a0 <trap_dispatch+0x2f4>
        c = cons_getc();
c010279b:	e8 0f f7 ff ff       	call   c0101eaf <cons_getc>
c01027a0:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01027a3:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027a7:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027ab:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027b3:	c7 04 24 9d 9a 10 c0 	movl   $0xc0109a9d,(%esp)
c01027ba:	e8 ed da ff ff       	call   c01002ac <cprintf>
        break;
c01027bf:	e9 e3 01 00 00       	jmp    c01029a7 <trap_dispatch+0x2fb>
        c = cons_getc();
c01027c4:	e8 e6 f6 ff ff       	call   c0101eaf <cons_getc>
c01027c9:	88 45 f7             	mov    %al,-0x9(%ebp)
        if (c == '3' && (tf->tf_cs & 3) != 3) {
c01027cc:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
c01027d0:	75 6f                	jne    c0102841 <trap_dispatch+0x195>
c01027d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01027d5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01027d9:	83 e0 03             	and    $0x3,%eax
c01027dc:	83 f8 03             	cmp    $0x3,%eax
c01027df:	74 60                	je     c0102841 <trap_dispatch+0x195>
            cprintf("[system] change to user [%03d] %c\n", c, c);
c01027e1:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027e5:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027e9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027ed:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027f1:	c7 04 24 b0 9a 10 c0 	movl   $0xc0109ab0,(%esp)
c01027f8:	e8 af da ff ff       	call   c01002ac <cprintf>
            tf->tf_cs = USER_CS;
c01027fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102800:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = USER_DS;
c0102806:	8b 45 08             	mov    0x8(%ebp),%eax
c0102809:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
c010280f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102812:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
c0102818:	8b 45 08             	mov    0x8(%ebp),%eax
c010281b:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
            tf->tf_eflags |= 0x3000;
c0102821:	8b 45 08             	mov    0x8(%ebp),%eax
c0102824:	8b 40 40             	mov    0x40(%eax),%eax
c0102827:	0d 00 30 00 00       	or     $0x3000,%eax
c010282c:	89 c2                	mov    %eax,%edx
c010282e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102831:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
c0102834:	8b 45 08             	mov    0x8(%ebp),%eax
c0102837:	89 04 24             	mov    %eax,(%esp)
c010283a:	e8 26 fb ff ff       	call   c0102365 <print_trapframe>
c010283f:	eb 72                	jmp    c01028b3 <trap_dispatch+0x207>
        else if (c == '0' && (tf->tf_cs & 3) != 0) {
c0102841:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
c0102845:	75 6c                	jne    c01028b3 <trap_dispatch+0x207>
c0102847:	8b 45 08             	mov    0x8(%ebp),%eax
c010284a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010284e:	83 e0 03             	and    $0x3,%eax
c0102851:	85 c0                	test   %eax,%eax
c0102853:	74 5e                	je     c01028b3 <trap_dispatch+0x207>
            cprintf("[system] change to kernel [%03d] %c\n", c, c);
c0102855:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0102859:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010285d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102861:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102865:	c7 04 24 d4 9a 10 c0 	movl   $0xc0109ad4,(%esp)
c010286c:	e8 3b da ff ff       	call   c01002ac <cprintf>
            tf->tf_cs = KERNEL_CS;
c0102871:	8b 45 08             	mov    0x8(%ebp),%eax
c0102874:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = KERNEL_DS;
c010287a:	8b 45 08             	mov    0x8(%ebp),%eax
c010287d:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
c0102883:	8b 45 08             	mov    0x8(%ebp),%eax
c0102886:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
            tf->tf_ss = KERNEL_DS;
c010288c:	8b 45 08             	mov    0x8(%ebp),%eax
c010288f:	66 c7 40 48 10 00    	movw   $0x10,0x48(%eax)
            tf->tf_eflags &= 0x0fff;
c0102895:	8b 45 08             	mov    0x8(%ebp),%eax
c0102898:	8b 40 40             	mov    0x40(%eax),%eax
c010289b:	25 ff 0f 00 00       	and    $0xfff,%eax
c01028a0:	89 c2                	mov    %eax,%edx
c01028a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01028a5:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
c01028a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01028ab:	89 04 24             	mov    %eax,(%esp)
c01028ae:	e8 b2 fa ff ff       	call   c0102365 <print_trapframe>
        cprintf("kbd [%03d] %c\n", c, c);
c01028b3:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01028b7:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01028bb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01028bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01028c3:	c7 04 24 f9 9a 10 c0 	movl   $0xc0109af9,(%esp)
c01028ca:	e8 dd d9 ff ff       	call   c01002ac <cprintf>
        break;
c01028cf:	e9 d3 00 00 00       	jmp    c01029a7 <trap_dispatch+0x2fb>
        if (tf->tf_cs != USER_CS) 
c01028d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01028d7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01028db:	83 f8 1b             	cmp    $0x1b,%eax
c01028de:	0f 84 bf 00 00 00    	je     c01029a3 <trap_dispatch+0x2f7>
            tf->tf_cs = USER_CS;
c01028e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01028e7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c01028ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01028f0:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c01028f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01028f9:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c01028fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102900:	66 89 50 28          	mov    %dx,0x28(%eax)
c0102904:	8b 45 08             	mov    0x8(%ebp),%eax
c0102907:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010290b:	8b 45 08             	mov    0x8(%ebp),%eax
c010290e:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags |= FL_IOPL_MASK;
c0102912:	8b 45 08             	mov    0x8(%ebp),%eax
c0102915:	8b 40 40             	mov    0x40(%eax),%eax
c0102918:	0d 00 30 00 00       	or     $0x3000,%eax
c010291d:	89 c2                	mov    %eax,%edx
c010291f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102922:	89 50 40             	mov    %edx,0x40(%eax)
        break;
c0102925:	eb 7c                	jmp    c01029a3 <trap_dispatch+0x2f7>
        if (tf->tf_cs != KERNEL_CS) 
c0102927:	8b 45 08             	mov    0x8(%ebp),%eax
c010292a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010292e:	83 f8 08             	cmp    $0x8,%eax
c0102931:	74 73                	je     c01029a6 <trap_dispatch+0x2fa>
            tf->tf_cs = KERNEL_CS;
c0102933:	8b 45 08             	mov    0x8(%ebp),%eax
c0102936:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c010293c:	8b 45 08             	mov    0x8(%ebp),%eax
c010293f:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0102945:	8b 45 08             	mov    0x8(%ebp),%eax
c0102948:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010294c:	8b 45 08             	mov    0x8(%ebp),%eax
c010294f:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0102953:	8b 45 08             	mov    0x8(%ebp),%eax
c0102956:	8b 40 40             	mov    0x40(%eax),%eax
c0102959:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c010295e:	89 c2                	mov    %eax,%edx
c0102960:	8b 45 08             	mov    0x8(%ebp),%eax
c0102963:	89 50 40             	mov    %edx,0x40(%eax)
        break;
c0102966:	eb 3e                	jmp    c01029a6 <trap_dispatch+0x2fa>
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102968:	8b 45 08             	mov    0x8(%ebp),%eax
c010296b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010296f:	83 e0 03             	and    $0x3,%eax
c0102972:	85 c0                	test   %eax,%eax
c0102974:	75 31                	jne    c01029a7 <trap_dispatch+0x2fb>
            print_trapframe(tf);
c0102976:	8b 45 08             	mov    0x8(%ebp),%eax
c0102979:	89 04 24             	mov    %eax,(%esp)
c010297c:	e8 e4 f9 ff ff       	call   c0102365 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102981:	c7 44 24 08 08 9b 10 	movl   $0xc0109b08,0x8(%esp)
c0102988:	c0 
c0102989:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0102990:	00 
c0102991:	c7 04 24 6e 98 10 c0 	movl   $0xc010986e,(%esp)
c0102998:	e8 66 da ff ff       	call   c0100403 <__panic>
        break;
c010299d:	90                   	nop
c010299e:	eb 07                	jmp    c01029a7 <trap_dispatch+0x2fb>
        break;
c01029a0:	90                   	nop
c01029a1:	eb 04                	jmp    c01029a7 <trap_dispatch+0x2fb>
        break;
c01029a3:	90                   	nop
c01029a4:	eb 01                	jmp    c01029a7 <trap_dispatch+0x2fb>
        break;
c01029a6:	90                   	nop
        }
    }
}
c01029a7:	90                   	nop
c01029a8:	c9                   	leave  
c01029a9:	c3                   	ret    

c01029aa <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01029aa:	55                   	push   %ebp
c01029ab:	89 e5                	mov    %esp,%ebp
c01029ad:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01029b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01029b3:	89 04 24             	mov    %eax,(%esp)
c01029b6:	e8 f1 fc ff ff       	call   c01026ac <trap_dispatch>
}
c01029bb:	90                   	nop
c01029bc:	c9                   	leave  
c01029bd:	c3                   	ret    

c01029be <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01029be:	6a 00                	push   $0x0
  pushl $0
c01029c0:	6a 00                	push   $0x0
  jmp __alltraps
c01029c2:	e9 69 0a 00 00       	jmp    c0103430 <__alltraps>

c01029c7 <vector1>:
.globl vector1
vector1:
  pushl $0
c01029c7:	6a 00                	push   $0x0
  pushl $1
c01029c9:	6a 01                	push   $0x1
  jmp __alltraps
c01029cb:	e9 60 0a 00 00       	jmp    c0103430 <__alltraps>

c01029d0 <vector2>:
.globl vector2
vector2:
  pushl $0
c01029d0:	6a 00                	push   $0x0
  pushl $2
c01029d2:	6a 02                	push   $0x2
  jmp __alltraps
c01029d4:	e9 57 0a 00 00       	jmp    c0103430 <__alltraps>

c01029d9 <vector3>:
.globl vector3
vector3:
  pushl $0
c01029d9:	6a 00                	push   $0x0
  pushl $3
c01029db:	6a 03                	push   $0x3
  jmp __alltraps
c01029dd:	e9 4e 0a 00 00       	jmp    c0103430 <__alltraps>

c01029e2 <vector4>:
.globl vector4
vector4:
  pushl $0
c01029e2:	6a 00                	push   $0x0
  pushl $4
c01029e4:	6a 04                	push   $0x4
  jmp __alltraps
c01029e6:	e9 45 0a 00 00       	jmp    c0103430 <__alltraps>

c01029eb <vector5>:
.globl vector5
vector5:
  pushl $0
c01029eb:	6a 00                	push   $0x0
  pushl $5
c01029ed:	6a 05                	push   $0x5
  jmp __alltraps
c01029ef:	e9 3c 0a 00 00       	jmp    c0103430 <__alltraps>

c01029f4 <vector6>:
.globl vector6
vector6:
  pushl $0
c01029f4:	6a 00                	push   $0x0
  pushl $6
c01029f6:	6a 06                	push   $0x6
  jmp __alltraps
c01029f8:	e9 33 0a 00 00       	jmp    c0103430 <__alltraps>

c01029fd <vector7>:
.globl vector7
vector7:
  pushl $0
c01029fd:	6a 00                	push   $0x0
  pushl $7
c01029ff:	6a 07                	push   $0x7
  jmp __alltraps
c0102a01:	e9 2a 0a 00 00       	jmp    c0103430 <__alltraps>

c0102a06 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102a06:	6a 08                	push   $0x8
  jmp __alltraps
c0102a08:	e9 23 0a 00 00       	jmp    c0103430 <__alltraps>

c0102a0d <vector9>:
.globl vector9
vector9:
  pushl $0
c0102a0d:	6a 00                	push   $0x0
  pushl $9
c0102a0f:	6a 09                	push   $0x9
  jmp __alltraps
c0102a11:	e9 1a 0a 00 00       	jmp    c0103430 <__alltraps>

c0102a16 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102a16:	6a 0a                	push   $0xa
  jmp __alltraps
c0102a18:	e9 13 0a 00 00       	jmp    c0103430 <__alltraps>

c0102a1d <vector11>:
.globl vector11
vector11:
  pushl $11
c0102a1d:	6a 0b                	push   $0xb
  jmp __alltraps
c0102a1f:	e9 0c 0a 00 00       	jmp    c0103430 <__alltraps>

c0102a24 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102a24:	6a 0c                	push   $0xc
  jmp __alltraps
c0102a26:	e9 05 0a 00 00       	jmp    c0103430 <__alltraps>

c0102a2b <vector13>:
.globl vector13
vector13:
  pushl $13
c0102a2b:	6a 0d                	push   $0xd
  jmp __alltraps
c0102a2d:	e9 fe 09 00 00       	jmp    c0103430 <__alltraps>

c0102a32 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102a32:	6a 0e                	push   $0xe
  jmp __alltraps
c0102a34:	e9 f7 09 00 00       	jmp    c0103430 <__alltraps>

c0102a39 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102a39:	6a 00                	push   $0x0
  pushl $15
c0102a3b:	6a 0f                	push   $0xf
  jmp __alltraps
c0102a3d:	e9 ee 09 00 00       	jmp    c0103430 <__alltraps>

c0102a42 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $16
c0102a44:	6a 10                	push   $0x10
  jmp __alltraps
c0102a46:	e9 e5 09 00 00       	jmp    c0103430 <__alltraps>

c0102a4b <vector17>:
.globl vector17
vector17:
  pushl $17
c0102a4b:	6a 11                	push   $0x11
  jmp __alltraps
c0102a4d:	e9 de 09 00 00       	jmp    c0103430 <__alltraps>

c0102a52 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102a52:	6a 00                	push   $0x0
  pushl $18
c0102a54:	6a 12                	push   $0x12
  jmp __alltraps
c0102a56:	e9 d5 09 00 00       	jmp    c0103430 <__alltraps>

c0102a5b <vector19>:
.globl vector19
vector19:
  pushl $0
c0102a5b:	6a 00                	push   $0x0
  pushl $19
c0102a5d:	6a 13                	push   $0x13
  jmp __alltraps
c0102a5f:	e9 cc 09 00 00       	jmp    c0103430 <__alltraps>

c0102a64 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102a64:	6a 00                	push   $0x0
  pushl $20
c0102a66:	6a 14                	push   $0x14
  jmp __alltraps
c0102a68:	e9 c3 09 00 00       	jmp    c0103430 <__alltraps>

c0102a6d <vector21>:
.globl vector21
vector21:
  pushl $0
c0102a6d:	6a 00                	push   $0x0
  pushl $21
c0102a6f:	6a 15                	push   $0x15
  jmp __alltraps
c0102a71:	e9 ba 09 00 00       	jmp    c0103430 <__alltraps>

c0102a76 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102a76:	6a 00                	push   $0x0
  pushl $22
c0102a78:	6a 16                	push   $0x16
  jmp __alltraps
c0102a7a:	e9 b1 09 00 00       	jmp    c0103430 <__alltraps>

c0102a7f <vector23>:
.globl vector23
vector23:
  pushl $0
c0102a7f:	6a 00                	push   $0x0
  pushl $23
c0102a81:	6a 17                	push   $0x17
  jmp __alltraps
c0102a83:	e9 a8 09 00 00       	jmp    c0103430 <__alltraps>

c0102a88 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102a88:	6a 00                	push   $0x0
  pushl $24
c0102a8a:	6a 18                	push   $0x18
  jmp __alltraps
c0102a8c:	e9 9f 09 00 00       	jmp    c0103430 <__alltraps>

c0102a91 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102a91:	6a 00                	push   $0x0
  pushl $25
c0102a93:	6a 19                	push   $0x19
  jmp __alltraps
c0102a95:	e9 96 09 00 00       	jmp    c0103430 <__alltraps>

c0102a9a <vector26>:
.globl vector26
vector26:
  pushl $0
c0102a9a:	6a 00                	push   $0x0
  pushl $26
c0102a9c:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102a9e:	e9 8d 09 00 00       	jmp    c0103430 <__alltraps>

c0102aa3 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102aa3:	6a 00                	push   $0x0
  pushl $27
c0102aa5:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102aa7:	e9 84 09 00 00       	jmp    c0103430 <__alltraps>

c0102aac <vector28>:
.globl vector28
vector28:
  pushl $0
c0102aac:	6a 00                	push   $0x0
  pushl $28
c0102aae:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102ab0:	e9 7b 09 00 00       	jmp    c0103430 <__alltraps>

c0102ab5 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102ab5:	6a 00                	push   $0x0
  pushl $29
c0102ab7:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102ab9:	e9 72 09 00 00       	jmp    c0103430 <__alltraps>

c0102abe <vector30>:
.globl vector30
vector30:
  pushl $0
c0102abe:	6a 00                	push   $0x0
  pushl $30
c0102ac0:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102ac2:	e9 69 09 00 00       	jmp    c0103430 <__alltraps>

c0102ac7 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102ac7:	6a 00                	push   $0x0
  pushl $31
c0102ac9:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102acb:	e9 60 09 00 00       	jmp    c0103430 <__alltraps>

c0102ad0 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102ad0:	6a 00                	push   $0x0
  pushl $32
c0102ad2:	6a 20                	push   $0x20
  jmp __alltraps
c0102ad4:	e9 57 09 00 00       	jmp    c0103430 <__alltraps>

c0102ad9 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102ad9:	6a 00                	push   $0x0
  pushl $33
c0102adb:	6a 21                	push   $0x21
  jmp __alltraps
c0102add:	e9 4e 09 00 00       	jmp    c0103430 <__alltraps>

c0102ae2 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102ae2:	6a 00                	push   $0x0
  pushl $34
c0102ae4:	6a 22                	push   $0x22
  jmp __alltraps
c0102ae6:	e9 45 09 00 00       	jmp    c0103430 <__alltraps>

c0102aeb <vector35>:
.globl vector35
vector35:
  pushl $0
c0102aeb:	6a 00                	push   $0x0
  pushl $35
c0102aed:	6a 23                	push   $0x23
  jmp __alltraps
c0102aef:	e9 3c 09 00 00       	jmp    c0103430 <__alltraps>

c0102af4 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102af4:	6a 00                	push   $0x0
  pushl $36
c0102af6:	6a 24                	push   $0x24
  jmp __alltraps
c0102af8:	e9 33 09 00 00       	jmp    c0103430 <__alltraps>

c0102afd <vector37>:
.globl vector37
vector37:
  pushl $0
c0102afd:	6a 00                	push   $0x0
  pushl $37
c0102aff:	6a 25                	push   $0x25
  jmp __alltraps
c0102b01:	e9 2a 09 00 00       	jmp    c0103430 <__alltraps>

c0102b06 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102b06:	6a 00                	push   $0x0
  pushl $38
c0102b08:	6a 26                	push   $0x26
  jmp __alltraps
c0102b0a:	e9 21 09 00 00       	jmp    c0103430 <__alltraps>

c0102b0f <vector39>:
.globl vector39
vector39:
  pushl $0
c0102b0f:	6a 00                	push   $0x0
  pushl $39
c0102b11:	6a 27                	push   $0x27
  jmp __alltraps
c0102b13:	e9 18 09 00 00       	jmp    c0103430 <__alltraps>

c0102b18 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102b18:	6a 00                	push   $0x0
  pushl $40
c0102b1a:	6a 28                	push   $0x28
  jmp __alltraps
c0102b1c:	e9 0f 09 00 00       	jmp    c0103430 <__alltraps>

c0102b21 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102b21:	6a 00                	push   $0x0
  pushl $41
c0102b23:	6a 29                	push   $0x29
  jmp __alltraps
c0102b25:	e9 06 09 00 00       	jmp    c0103430 <__alltraps>

c0102b2a <vector42>:
.globl vector42
vector42:
  pushl $0
c0102b2a:	6a 00                	push   $0x0
  pushl $42
c0102b2c:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102b2e:	e9 fd 08 00 00       	jmp    c0103430 <__alltraps>

c0102b33 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102b33:	6a 00                	push   $0x0
  pushl $43
c0102b35:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102b37:	e9 f4 08 00 00       	jmp    c0103430 <__alltraps>

c0102b3c <vector44>:
.globl vector44
vector44:
  pushl $0
c0102b3c:	6a 00                	push   $0x0
  pushl $44
c0102b3e:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102b40:	e9 eb 08 00 00       	jmp    c0103430 <__alltraps>

c0102b45 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102b45:	6a 00                	push   $0x0
  pushl $45
c0102b47:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102b49:	e9 e2 08 00 00       	jmp    c0103430 <__alltraps>

c0102b4e <vector46>:
.globl vector46
vector46:
  pushl $0
c0102b4e:	6a 00                	push   $0x0
  pushl $46
c0102b50:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102b52:	e9 d9 08 00 00       	jmp    c0103430 <__alltraps>

c0102b57 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102b57:	6a 00                	push   $0x0
  pushl $47
c0102b59:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102b5b:	e9 d0 08 00 00       	jmp    c0103430 <__alltraps>

c0102b60 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102b60:	6a 00                	push   $0x0
  pushl $48
c0102b62:	6a 30                	push   $0x30
  jmp __alltraps
c0102b64:	e9 c7 08 00 00       	jmp    c0103430 <__alltraps>

c0102b69 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102b69:	6a 00                	push   $0x0
  pushl $49
c0102b6b:	6a 31                	push   $0x31
  jmp __alltraps
c0102b6d:	e9 be 08 00 00       	jmp    c0103430 <__alltraps>

c0102b72 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102b72:	6a 00                	push   $0x0
  pushl $50
c0102b74:	6a 32                	push   $0x32
  jmp __alltraps
c0102b76:	e9 b5 08 00 00       	jmp    c0103430 <__alltraps>

c0102b7b <vector51>:
.globl vector51
vector51:
  pushl $0
c0102b7b:	6a 00                	push   $0x0
  pushl $51
c0102b7d:	6a 33                	push   $0x33
  jmp __alltraps
c0102b7f:	e9 ac 08 00 00       	jmp    c0103430 <__alltraps>

c0102b84 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102b84:	6a 00                	push   $0x0
  pushl $52
c0102b86:	6a 34                	push   $0x34
  jmp __alltraps
c0102b88:	e9 a3 08 00 00       	jmp    c0103430 <__alltraps>

c0102b8d <vector53>:
.globl vector53
vector53:
  pushl $0
c0102b8d:	6a 00                	push   $0x0
  pushl $53
c0102b8f:	6a 35                	push   $0x35
  jmp __alltraps
c0102b91:	e9 9a 08 00 00       	jmp    c0103430 <__alltraps>

c0102b96 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102b96:	6a 00                	push   $0x0
  pushl $54
c0102b98:	6a 36                	push   $0x36
  jmp __alltraps
c0102b9a:	e9 91 08 00 00       	jmp    c0103430 <__alltraps>

c0102b9f <vector55>:
.globl vector55
vector55:
  pushl $0
c0102b9f:	6a 00                	push   $0x0
  pushl $55
c0102ba1:	6a 37                	push   $0x37
  jmp __alltraps
c0102ba3:	e9 88 08 00 00       	jmp    c0103430 <__alltraps>

c0102ba8 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102ba8:	6a 00                	push   $0x0
  pushl $56
c0102baa:	6a 38                	push   $0x38
  jmp __alltraps
c0102bac:	e9 7f 08 00 00       	jmp    c0103430 <__alltraps>

c0102bb1 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102bb1:	6a 00                	push   $0x0
  pushl $57
c0102bb3:	6a 39                	push   $0x39
  jmp __alltraps
c0102bb5:	e9 76 08 00 00       	jmp    c0103430 <__alltraps>

c0102bba <vector58>:
.globl vector58
vector58:
  pushl $0
c0102bba:	6a 00                	push   $0x0
  pushl $58
c0102bbc:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102bbe:	e9 6d 08 00 00       	jmp    c0103430 <__alltraps>

c0102bc3 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102bc3:	6a 00                	push   $0x0
  pushl $59
c0102bc5:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102bc7:	e9 64 08 00 00       	jmp    c0103430 <__alltraps>

c0102bcc <vector60>:
.globl vector60
vector60:
  pushl $0
c0102bcc:	6a 00                	push   $0x0
  pushl $60
c0102bce:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102bd0:	e9 5b 08 00 00       	jmp    c0103430 <__alltraps>

c0102bd5 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102bd5:	6a 00                	push   $0x0
  pushl $61
c0102bd7:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102bd9:	e9 52 08 00 00       	jmp    c0103430 <__alltraps>

c0102bde <vector62>:
.globl vector62
vector62:
  pushl $0
c0102bde:	6a 00                	push   $0x0
  pushl $62
c0102be0:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102be2:	e9 49 08 00 00       	jmp    c0103430 <__alltraps>

c0102be7 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102be7:	6a 00                	push   $0x0
  pushl $63
c0102be9:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102beb:	e9 40 08 00 00       	jmp    c0103430 <__alltraps>

c0102bf0 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102bf0:	6a 00                	push   $0x0
  pushl $64
c0102bf2:	6a 40                	push   $0x40
  jmp __alltraps
c0102bf4:	e9 37 08 00 00       	jmp    c0103430 <__alltraps>

c0102bf9 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102bf9:	6a 00                	push   $0x0
  pushl $65
c0102bfb:	6a 41                	push   $0x41
  jmp __alltraps
c0102bfd:	e9 2e 08 00 00       	jmp    c0103430 <__alltraps>

c0102c02 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102c02:	6a 00                	push   $0x0
  pushl $66
c0102c04:	6a 42                	push   $0x42
  jmp __alltraps
c0102c06:	e9 25 08 00 00       	jmp    c0103430 <__alltraps>

c0102c0b <vector67>:
.globl vector67
vector67:
  pushl $0
c0102c0b:	6a 00                	push   $0x0
  pushl $67
c0102c0d:	6a 43                	push   $0x43
  jmp __alltraps
c0102c0f:	e9 1c 08 00 00       	jmp    c0103430 <__alltraps>

c0102c14 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102c14:	6a 00                	push   $0x0
  pushl $68
c0102c16:	6a 44                	push   $0x44
  jmp __alltraps
c0102c18:	e9 13 08 00 00       	jmp    c0103430 <__alltraps>

c0102c1d <vector69>:
.globl vector69
vector69:
  pushl $0
c0102c1d:	6a 00                	push   $0x0
  pushl $69
c0102c1f:	6a 45                	push   $0x45
  jmp __alltraps
c0102c21:	e9 0a 08 00 00       	jmp    c0103430 <__alltraps>

c0102c26 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102c26:	6a 00                	push   $0x0
  pushl $70
c0102c28:	6a 46                	push   $0x46
  jmp __alltraps
c0102c2a:	e9 01 08 00 00       	jmp    c0103430 <__alltraps>

c0102c2f <vector71>:
.globl vector71
vector71:
  pushl $0
c0102c2f:	6a 00                	push   $0x0
  pushl $71
c0102c31:	6a 47                	push   $0x47
  jmp __alltraps
c0102c33:	e9 f8 07 00 00       	jmp    c0103430 <__alltraps>

c0102c38 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102c38:	6a 00                	push   $0x0
  pushl $72
c0102c3a:	6a 48                	push   $0x48
  jmp __alltraps
c0102c3c:	e9 ef 07 00 00       	jmp    c0103430 <__alltraps>

c0102c41 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102c41:	6a 00                	push   $0x0
  pushl $73
c0102c43:	6a 49                	push   $0x49
  jmp __alltraps
c0102c45:	e9 e6 07 00 00       	jmp    c0103430 <__alltraps>

c0102c4a <vector74>:
.globl vector74
vector74:
  pushl $0
c0102c4a:	6a 00                	push   $0x0
  pushl $74
c0102c4c:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102c4e:	e9 dd 07 00 00       	jmp    c0103430 <__alltraps>

c0102c53 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102c53:	6a 00                	push   $0x0
  pushl $75
c0102c55:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102c57:	e9 d4 07 00 00       	jmp    c0103430 <__alltraps>

c0102c5c <vector76>:
.globl vector76
vector76:
  pushl $0
c0102c5c:	6a 00                	push   $0x0
  pushl $76
c0102c5e:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102c60:	e9 cb 07 00 00       	jmp    c0103430 <__alltraps>

c0102c65 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102c65:	6a 00                	push   $0x0
  pushl $77
c0102c67:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102c69:	e9 c2 07 00 00       	jmp    c0103430 <__alltraps>

c0102c6e <vector78>:
.globl vector78
vector78:
  pushl $0
c0102c6e:	6a 00                	push   $0x0
  pushl $78
c0102c70:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102c72:	e9 b9 07 00 00       	jmp    c0103430 <__alltraps>

c0102c77 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102c77:	6a 00                	push   $0x0
  pushl $79
c0102c79:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102c7b:	e9 b0 07 00 00       	jmp    c0103430 <__alltraps>

c0102c80 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102c80:	6a 00                	push   $0x0
  pushl $80
c0102c82:	6a 50                	push   $0x50
  jmp __alltraps
c0102c84:	e9 a7 07 00 00       	jmp    c0103430 <__alltraps>

c0102c89 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102c89:	6a 00                	push   $0x0
  pushl $81
c0102c8b:	6a 51                	push   $0x51
  jmp __alltraps
c0102c8d:	e9 9e 07 00 00       	jmp    c0103430 <__alltraps>

c0102c92 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102c92:	6a 00                	push   $0x0
  pushl $82
c0102c94:	6a 52                	push   $0x52
  jmp __alltraps
c0102c96:	e9 95 07 00 00       	jmp    c0103430 <__alltraps>

c0102c9b <vector83>:
.globl vector83
vector83:
  pushl $0
c0102c9b:	6a 00                	push   $0x0
  pushl $83
c0102c9d:	6a 53                	push   $0x53
  jmp __alltraps
c0102c9f:	e9 8c 07 00 00       	jmp    c0103430 <__alltraps>

c0102ca4 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102ca4:	6a 00                	push   $0x0
  pushl $84
c0102ca6:	6a 54                	push   $0x54
  jmp __alltraps
c0102ca8:	e9 83 07 00 00       	jmp    c0103430 <__alltraps>

c0102cad <vector85>:
.globl vector85
vector85:
  pushl $0
c0102cad:	6a 00                	push   $0x0
  pushl $85
c0102caf:	6a 55                	push   $0x55
  jmp __alltraps
c0102cb1:	e9 7a 07 00 00       	jmp    c0103430 <__alltraps>

c0102cb6 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102cb6:	6a 00                	push   $0x0
  pushl $86
c0102cb8:	6a 56                	push   $0x56
  jmp __alltraps
c0102cba:	e9 71 07 00 00       	jmp    c0103430 <__alltraps>

c0102cbf <vector87>:
.globl vector87
vector87:
  pushl $0
c0102cbf:	6a 00                	push   $0x0
  pushl $87
c0102cc1:	6a 57                	push   $0x57
  jmp __alltraps
c0102cc3:	e9 68 07 00 00       	jmp    c0103430 <__alltraps>

c0102cc8 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102cc8:	6a 00                	push   $0x0
  pushl $88
c0102cca:	6a 58                	push   $0x58
  jmp __alltraps
c0102ccc:	e9 5f 07 00 00       	jmp    c0103430 <__alltraps>

c0102cd1 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102cd1:	6a 00                	push   $0x0
  pushl $89
c0102cd3:	6a 59                	push   $0x59
  jmp __alltraps
c0102cd5:	e9 56 07 00 00       	jmp    c0103430 <__alltraps>

c0102cda <vector90>:
.globl vector90
vector90:
  pushl $0
c0102cda:	6a 00                	push   $0x0
  pushl $90
c0102cdc:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102cde:	e9 4d 07 00 00       	jmp    c0103430 <__alltraps>

c0102ce3 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102ce3:	6a 00                	push   $0x0
  pushl $91
c0102ce5:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102ce7:	e9 44 07 00 00       	jmp    c0103430 <__alltraps>

c0102cec <vector92>:
.globl vector92
vector92:
  pushl $0
c0102cec:	6a 00                	push   $0x0
  pushl $92
c0102cee:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102cf0:	e9 3b 07 00 00       	jmp    c0103430 <__alltraps>

c0102cf5 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102cf5:	6a 00                	push   $0x0
  pushl $93
c0102cf7:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102cf9:	e9 32 07 00 00       	jmp    c0103430 <__alltraps>

c0102cfe <vector94>:
.globl vector94
vector94:
  pushl $0
c0102cfe:	6a 00                	push   $0x0
  pushl $94
c0102d00:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102d02:	e9 29 07 00 00       	jmp    c0103430 <__alltraps>

c0102d07 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102d07:	6a 00                	push   $0x0
  pushl $95
c0102d09:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102d0b:	e9 20 07 00 00       	jmp    c0103430 <__alltraps>

c0102d10 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102d10:	6a 00                	push   $0x0
  pushl $96
c0102d12:	6a 60                	push   $0x60
  jmp __alltraps
c0102d14:	e9 17 07 00 00       	jmp    c0103430 <__alltraps>

c0102d19 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102d19:	6a 00                	push   $0x0
  pushl $97
c0102d1b:	6a 61                	push   $0x61
  jmp __alltraps
c0102d1d:	e9 0e 07 00 00       	jmp    c0103430 <__alltraps>

c0102d22 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102d22:	6a 00                	push   $0x0
  pushl $98
c0102d24:	6a 62                	push   $0x62
  jmp __alltraps
c0102d26:	e9 05 07 00 00       	jmp    c0103430 <__alltraps>

c0102d2b <vector99>:
.globl vector99
vector99:
  pushl $0
c0102d2b:	6a 00                	push   $0x0
  pushl $99
c0102d2d:	6a 63                	push   $0x63
  jmp __alltraps
c0102d2f:	e9 fc 06 00 00       	jmp    c0103430 <__alltraps>

c0102d34 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102d34:	6a 00                	push   $0x0
  pushl $100
c0102d36:	6a 64                	push   $0x64
  jmp __alltraps
c0102d38:	e9 f3 06 00 00       	jmp    c0103430 <__alltraps>

c0102d3d <vector101>:
.globl vector101
vector101:
  pushl $0
c0102d3d:	6a 00                	push   $0x0
  pushl $101
c0102d3f:	6a 65                	push   $0x65
  jmp __alltraps
c0102d41:	e9 ea 06 00 00       	jmp    c0103430 <__alltraps>

c0102d46 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102d46:	6a 00                	push   $0x0
  pushl $102
c0102d48:	6a 66                	push   $0x66
  jmp __alltraps
c0102d4a:	e9 e1 06 00 00       	jmp    c0103430 <__alltraps>

c0102d4f <vector103>:
.globl vector103
vector103:
  pushl $0
c0102d4f:	6a 00                	push   $0x0
  pushl $103
c0102d51:	6a 67                	push   $0x67
  jmp __alltraps
c0102d53:	e9 d8 06 00 00       	jmp    c0103430 <__alltraps>

c0102d58 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102d58:	6a 00                	push   $0x0
  pushl $104
c0102d5a:	6a 68                	push   $0x68
  jmp __alltraps
c0102d5c:	e9 cf 06 00 00       	jmp    c0103430 <__alltraps>

c0102d61 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102d61:	6a 00                	push   $0x0
  pushl $105
c0102d63:	6a 69                	push   $0x69
  jmp __alltraps
c0102d65:	e9 c6 06 00 00       	jmp    c0103430 <__alltraps>

c0102d6a <vector106>:
.globl vector106
vector106:
  pushl $0
c0102d6a:	6a 00                	push   $0x0
  pushl $106
c0102d6c:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102d6e:	e9 bd 06 00 00       	jmp    c0103430 <__alltraps>

c0102d73 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102d73:	6a 00                	push   $0x0
  pushl $107
c0102d75:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102d77:	e9 b4 06 00 00       	jmp    c0103430 <__alltraps>

c0102d7c <vector108>:
.globl vector108
vector108:
  pushl $0
c0102d7c:	6a 00                	push   $0x0
  pushl $108
c0102d7e:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102d80:	e9 ab 06 00 00       	jmp    c0103430 <__alltraps>

c0102d85 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102d85:	6a 00                	push   $0x0
  pushl $109
c0102d87:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102d89:	e9 a2 06 00 00       	jmp    c0103430 <__alltraps>

c0102d8e <vector110>:
.globl vector110
vector110:
  pushl $0
c0102d8e:	6a 00                	push   $0x0
  pushl $110
c0102d90:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102d92:	e9 99 06 00 00       	jmp    c0103430 <__alltraps>

c0102d97 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102d97:	6a 00                	push   $0x0
  pushl $111
c0102d99:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102d9b:	e9 90 06 00 00       	jmp    c0103430 <__alltraps>

c0102da0 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102da0:	6a 00                	push   $0x0
  pushl $112
c0102da2:	6a 70                	push   $0x70
  jmp __alltraps
c0102da4:	e9 87 06 00 00       	jmp    c0103430 <__alltraps>

c0102da9 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102da9:	6a 00                	push   $0x0
  pushl $113
c0102dab:	6a 71                	push   $0x71
  jmp __alltraps
c0102dad:	e9 7e 06 00 00       	jmp    c0103430 <__alltraps>

c0102db2 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102db2:	6a 00                	push   $0x0
  pushl $114
c0102db4:	6a 72                	push   $0x72
  jmp __alltraps
c0102db6:	e9 75 06 00 00       	jmp    c0103430 <__alltraps>

c0102dbb <vector115>:
.globl vector115
vector115:
  pushl $0
c0102dbb:	6a 00                	push   $0x0
  pushl $115
c0102dbd:	6a 73                	push   $0x73
  jmp __alltraps
c0102dbf:	e9 6c 06 00 00       	jmp    c0103430 <__alltraps>

c0102dc4 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102dc4:	6a 00                	push   $0x0
  pushl $116
c0102dc6:	6a 74                	push   $0x74
  jmp __alltraps
c0102dc8:	e9 63 06 00 00       	jmp    c0103430 <__alltraps>

c0102dcd <vector117>:
.globl vector117
vector117:
  pushl $0
c0102dcd:	6a 00                	push   $0x0
  pushl $117
c0102dcf:	6a 75                	push   $0x75
  jmp __alltraps
c0102dd1:	e9 5a 06 00 00       	jmp    c0103430 <__alltraps>

c0102dd6 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102dd6:	6a 00                	push   $0x0
  pushl $118
c0102dd8:	6a 76                	push   $0x76
  jmp __alltraps
c0102dda:	e9 51 06 00 00       	jmp    c0103430 <__alltraps>

c0102ddf <vector119>:
.globl vector119
vector119:
  pushl $0
c0102ddf:	6a 00                	push   $0x0
  pushl $119
c0102de1:	6a 77                	push   $0x77
  jmp __alltraps
c0102de3:	e9 48 06 00 00       	jmp    c0103430 <__alltraps>

c0102de8 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102de8:	6a 00                	push   $0x0
  pushl $120
c0102dea:	6a 78                	push   $0x78
  jmp __alltraps
c0102dec:	e9 3f 06 00 00       	jmp    c0103430 <__alltraps>

c0102df1 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102df1:	6a 00                	push   $0x0
  pushl $121
c0102df3:	6a 79                	push   $0x79
  jmp __alltraps
c0102df5:	e9 36 06 00 00       	jmp    c0103430 <__alltraps>

c0102dfa <vector122>:
.globl vector122
vector122:
  pushl $0
c0102dfa:	6a 00                	push   $0x0
  pushl $122
c0102dfc:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102dfe:	e9 2d 06 00 00       	jmp    c0103430 <__alltraps>

c0102e03 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102e03:	6a 00                	push   $0x0
  pushl $123
c0102e05:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102e07:	e9 24 06 00 00       	jmp    c0103430 <__alltraps>

c0102e0c <vector124>:
.globl vector124
vector124:
  pushl $0
c0102e0c:	6a 00                	push   $0x0
  pushl $124
c0102e0e:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102e10:	e9 1b 06 00 00       	jmp    c0103430 <__alltraps>

c0102e15 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102e15:	6a 00                	push   $0x0
  pushl $125
c0102e17:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102e19:	e9 12 06 00 00       	jmp    c0103430 <__alltraps>

c0102e1e <vector126>:
.globl vector126
vector126:
  pushl $0
c0102e1e:	6a 00                	push   $0x0
  pushl $126
c0102e20:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102e22:	e9 09 06 00 00       	jmp    c0103430 <__alltraps>

c0102e27 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102e27:	6a 00                	push   $0x0
  pushl $127
c0102e29:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102e2b:	e9 00 06 00 00       	jmp    c0103430 <__alltraps>

c0102e30 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102e30:	6a 00                	push   $0x0
  pushl $128
c0102e32:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102e37:	e9 f4 05 00 00       	jmp    c0103430 <__alltraps>

c0102e3c <vector129>:
.globl vector129
vector129:
  pushl $0
c0102e3c:	6a 00                	push   $0x0
  pushl $129
c0102e3e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102e43:	e9 e8 05 00 00       	jmp    c0103430 <__alltraps>

c0102e48 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102e48:	6a 00                	push   $0x0
  pushl $130
c0102e4a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102e4f:	e9 dc 05 00 00       	jmp    c0103430 <__alltraps>

c0102e54 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102e54:	6a 00                	push   $0x0
  pushl $131
c0102e56:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102e5b:	e9 d0 05 00 00       	jmp    c0103430 <__alltraps>

c0102e60 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102e60:	6a 00                	push   $0x0
  pushl $132
c0102e62:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102e67:	e9 c4 05 00 00       	jmp    c0103430 <__alltraps>

c0102e6c <vector133>:
.globl vector133
vector133:
  pushl $0
c0102e6c:	6a 00                	push   $0x0
  pushl $133
c0102e6e:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102e73:	e9 b8 05 00 00       	jmp    c0103430 <__alltraps>

c0102e78 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102e78:	6a 00                	push   $0x0
  pushl $134
c0102e7a:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102e7f:	e9 ac 05 00 00       	jmp    c0103430 <__alltraps>

c0102e84 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102e84:	6a 00                	push   $0x0
  pushl $135
c0102e86:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102e8b:	e9 a0 05 00 00       	jmp    c0103430 <__alltraps>

c0102e90 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102e90:	6a 00                	push   $0x0
  pushl $136
c0102e92:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102e97:	e9 94 05 00 00       	jmp    c0103430 <__alltraps>

c0102e9c <vector137>:
.globl vector137
vector137:
  pushl $0
c0102e9c:	6a 00                	push   $0x0
  pushl $137
c0102e9e:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102ea3:	e9 88 05 00 00       	jmp    c0103430 <__alltraps>

c0102ea8 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102ea8:	6a 00                	push   $0x0
  pushl $138
c0102eaa:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102eaf:	e9 7c 05 00 00       	jmp    c0103430 <__alltraps>

c0102eb4 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102eb4:	6a 00                	push   $0x0
  pushl $139
c0102eb6:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102ebb:	e9 70 05 00 00       	jmp    c0103430 <__alltraps>

c0102ec0 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102ec0:	6a 00                	push   $0x0
  pushl $140
c0102ec2:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102ec7:	e9 64 05 00 00       	jmp    c0103430 <__alltraps>

c0102ecc <vector141>:
.globl vector141
vector141:
  pushl $0
c0102ecc:	6a 00                	push   $0x0
  pushl $141
c0102ece:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102ed3:	e9 58 05 00 00       	jmp    c0103430 <__alltraps>

c0102ed8 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102ed8:	6a 00                	push   $0x0
  pushl $142
c0102eda:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102edf:	e9 4c 05 00 00       	jmp    c0103430 <__alltraps>

c0102ee4 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102ee4:	6a 00                	push   $0x0
  pushl $143
c0102ee6:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102eeb:	e9 40 05 00 00       	jmp    c0103430 <__alltraps>

c0102ef0 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102ef0:	6a 00                	push   $0x0
  pushl $144
c0102ef2:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102ef7:	e9 34 05 00 00       	jmp    c0103430 <__alltraps>

c0102efc <vector145>:
.globl vector145
vector145:
  pushl $0
c0102efc:	6a 00                	push   $0x0
  pushl $145
c0102efe:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102f03:	e9 28 05 00 00       	jmp    c0103430 <__alltraps>

c0102f08 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102f08:	6a 00                	push   $0x0
  pushl $146
c0102f0a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102f0f:	e9 1c 05 00 00       	jmp    c0103430 <__alltraps>

c0102f14 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102f14:	6a 00                	push   $0x0
  pushl $147
c0102f16:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102f1b:	e9 10 05 00 00       	jmp    c0103430 <__alltraps>

c0102f20 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102f20:	6a 00                	push   $0x0
  pushl $148
c0102f22:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102f27:	e9 04 05 00 00       	jmp    c0103430 <__alltraps>

c0102f2c <vector149>:
.globl vector149
vector149:
  pushl $0
c0102f2c:	6a 00                	push   $0x0
  pushl $149
c0102f2e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102f33:	e9 f8 04 00 00       	jmp    c0103430 <__alltraps>

c0102f38 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102f38:	6a 00                	push   $0x0
  pushl $150
c0102f3a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102f3f:	e9 ec 04 00 00       	jmp    c0103430 <__alltraps>

c0102f44 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102f44:	6a 00                	push   $0x0
  pushl $151
c0102f46:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102f4b:	e9 e0 04 00 00       	jmp    c0103430 <__alltraps>

c0102f50 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102f50:	6a 00                	push   $0x0
  pushl $152
c0102f52:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102f57:	e9 d4 04 00 00       	jmp    c0103430 <__alltraps>

c0102f5c <vector153>:
.globl vector153
vector153:
  pushl $0
c0102f5c:	6a 00                	push   $0x0
  pushl $153
c0102f5e:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102f63:	e9 c8 04 00 00       	jmp    c0103430 <__alltraps>

c0102f68 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102f68:	6a 00                	push   $0x0
  pushl $154
c0102f6a:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102f6f:	e9 bc 04 00 00       	jmp    c0103430 <__alltraps>

c0102f74 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102f74:	6a 00                	push   $0x0
  pushl $155
c0102f76:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102f7b:	e9 b0 04 00 00       	jmp    c0103430 <__alltraps>

c0102f80 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102f80:	6a 00                	push   $0x0
  pushl $156
c0102f82:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102f87:	e9 a4 04 00 00       	jmp    c0103430 <__alltraps>

c0102f8c <vector157>:
.globl vector157
vector157:
  pushl $0
c0102f8c:	6a 00                	push   $0x0
  pushl $157
c0102f8e:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102f93:	e9 98 04 00 00       	jmp    c0103430 <__alltraps>

c0102f98 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102f98:	6a 00                	push   $0x0
  pushl $158
c0102f9a:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102f9f:	e9 8c 04 00 00       	jmp    c0103430 <__alltraps>

c0102fa4 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102fa4:	6a 00                	push   $0x0
  pushl $159
c0102fa6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102fab:	e9 80 04 00 00       	jmp    c0103430 <__alltraps>

c0102fb0 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102fb0:	6a 00                	push   $0x0
  pushl $160
c0102fb2:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102fb7:	e9 74 04 00 00       	jmp    c0103430 <__alltraps>

c0102fbc <vector161>:
.globl vector161
vector161:
  pushl $0
c0102fbc:	6a 00                	push   $0x0
  pushl $161
c0102fbe:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102fc3:	e9 68 04 00 00       	jmp    c0103430 <__alltraps>

c0102fc8 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102fc8:	6a 00                	push   $0x0
  pushl $162
c0102fca:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102fcf:	e9 5c 04 00 00       	jmp    c0103430 <__alltraps>

c0102fd4 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102fd4:	6a 00                	push   $0x0
  pushl $163
c0102fd6:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102fdb:	e9 50 04 00 00       	jmp    c0103430 <__alltraps>

c0102fe0 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102fe0:	6a 00                	push   $0x0
  pushl $164
c0102fe2:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102fe7:	e9 44 04 00 00       	jmp    c0103430 <__alltraps>

c0102fec <vector165>:
.globl vector165
vector165:
  pushl $0
c0102fec:	6a 00                	push   $0x0
  pushl $165
c0102fee:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102ff3:	e9 38 04 00 00       	jmp    c0103430 <__alltraps>

c0102ff8 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102ff8:	6a 00                	push   $0x0
  pushl $166
c0102ffa:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102fff:	e9 2c 04 00 00       	jmp    c0103430 <__alltraps>

c0103004 <vector167>:
.globl vector167
vector167:
  pushl $0
c0103004:	6a 00                	push   $0x0
  pushl $167
c0103006:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010300b:	e9 20 04 00 00       	jmp    c0103430 <__alltraps>

c0103010 <vector168>:
.globl vector168
vector168:
  pushl $0
c0103010:	6a 00                	push   $0x0
  pushl $168
c0103012:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0103017:	e9 14 04 00 00       	jmp    c0103430 <__alltraps>

c010301c <vector169>:
.globl vector169
vector169:
  pushl $0
c010301c:	6a 00                	push   $0x0
  pushl $169
c010301e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0103023:	e9 08 04 00 00       	jmp    c0103430 <__alltraps>

c0103028 <vector170>:
.globl vector170
vector170:
  pushl $0
c0103028:	6a 00                	push   $0x0
  pushl $170
c010302a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010302f:	e9 fc 03 00 00       	jmp    c0103430 <__alltraps>

c0103034 <vector171>:
.globl vector171
vector171:
  pushl $0
c0103034:	6a 00                	push   $0x0
  pushl $171
c0103036:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010303b:	e9 f0 03 00 00       	jmp    c0103430 <__alltraps>

c0103040 <vector172>:
.globl vector172
vector172:
  pushl $0
c0103040:	6a 00                	push   $0x0
  pushl $172
c0103042:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0103047:	e9 e4 03 00 00       	jmp    c0103430 <__alltraps>

c010304c <vector173>:
.globl vector173
vector173:
  pushl $0
c010304c:	6a 00                	push   $0x0
  pushl $173
c010304e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0103053:	e9 d8 03 00 00       	jmp    c0103430 <__alltraps>

c0103058 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103058:	6a 00                	push   $0x0
  pushl $174
c010305a:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010305f:	e9 cc 03 00 00       	jmp    c0103430 <__alltraps>

c0103064 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103064:	6a 00                	push   $0x0
  pushl $175
c0103066:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010306b:	e9 c0 03 00 00       	jmp    c0103430 <__alltraps>

c0103070 <vector176>:
.globl vector176
vector176:
  pushl $0
c0103070:	6a 00                	push   $0x0
  pushl $176
c0103072:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103077:	e9 b4 03 00 00       	jmp    c0103430 <__alltraps>

c010307c <vector177>:
.globl vector177
vector177:
  pushl $0
c010307c:	6a 00                	push   $0x0
  pushl $177
c010307e:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103083:	e9 a8 03 00 00       	jmp    c0103430 <__alltraps>

c0103088 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103088:	6a 00                	push   $0x0
  pushl $178
c010308a:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010308f:	e9 9c 03 00 00       	jmp    c0103430 <__alltraps>

c0103094 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103094:	6a 00                	push   $0x0
  pushl $179
c0103096:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010309b:	e9 90 03 00 00       	jmp    c0103430 <__alltraps>

c01030a0 <vector180>:
.globl vector180
vector180:
  pushl $0
c01030a0:	6a 00                	push   $0x0
  pushl $180
c01030a2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01030a7:	e9 84 03 00 00       	jmp    c0103430 <__alltraps>

c01030ac <vector181>:
.globl vector181
vector181:
  pushl $0
c01030ac:	6a 00                	push   $0x0
  pushl $181
c01030ae:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01030b3:	e9 78 03 00 00       	jmp    c0103430 <__alltraps>

c01030b8 <vector182>:
.globl vector182
vector182:
  pushl $0
c01030b8:	6a 00                	push   $0x0
  pushl $182
c01030ba:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01030bf:	e9 6c 03 00 00       	jmp    c0103430 <__alltraps>

c01030c4 <vector183>:
.globl vector183
vector183:
  pushl $0
c01030c4:	6a 00                	push   $0x0
  pushl $183
c01030c6:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01030cb:	e9 60 03 00 00       	jmp    c0103430 <__alltraps>

c01030d0 <vector184>:
.globl vector184
vector184:
  pushl $0
c01030d0:	6a 00                	push   $0x0
  pushl $184
c01030d2:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01030d7:	e9 54 03 00 00       	jmp    c0103430 <__alltraps>

c01030dc <vector185>:
.globl vector185
vector185:
  pushl $0
c01030dc:	6a 00                	push   $0x0
  pushl $185
c01030de:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01030e3:	e9 48 03 00 00       	jmp    c0103430 <__alltraps>

c01030e8 <vector186>:
.globl vector186
vector186:
  pushl $0
c01030e8:	6a 00                	push   $0x0
  pushl $186
c01030ea:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01030ef:	e9 3c 03 00 00       	jmp    c0103430 <__alltraps>

c01030f4 <vector187>:
.globl vector187
vector187:
  pushl $0
c01030f4:	6a 00                	push   $0x0
  pushl $187
c01030f6:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01030fb:	e9 30 03 00 00       	jmp    c0103430 <__alltraps>

c0103100 <vector188>:
.globl vector188
vector188:
  pushl $0
c0103100:	6a 00                	push   $0x0
  pushl $188
c0103102:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0103107:	e9 24 03 00 00       	jmp    c0103430 <__alltraps>

c010310c <vector189>:
.globl vector189
vector189:
  pushl $0
c010310c:	6a 00                	push   $0x0
  pushl $189
c010310e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0103113:	e9 18 03 00 00       	jmp    c0103430 <__alltraps>

c0103118 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103118:	6a 00                	push   $0x0
  pushl $190
c010311a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010311f:	e9 0c 03 00 00       	jmp    c0103430 <__alltraps>

c0103124 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103124:	6a 00                	push   $0x0
  pushl $191
c0103126:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010312b:	e9 00 03 00 00       	jmp    c0103430 <__alltraps>

c0103130 <vector192>:
.globl vector192
vector192:
  pushl $0
c0103130:	6a 00                	push   $0x0
  pushl $192
c0103132:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103137:	e9 f4 02 00 00       	jmp    c0103430 <__alltraps>

c010313c <vector193>:
.globl vector193
vector193:
  pushl $0
c010313c:	6a 00                	push   $0x0
  pushl $193
c010313e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103143:	e9 e8 02 00 00       	jmp    c0103430 <__alltraps>

c0103148 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103148:	6a 00                	push   $0x0
  pushl $194
c010314a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010314f:	e9 dc 02 00 00       	jmp    c0103430 <__alltraps>

c0103154 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103154:	6a 00                	push   $0x0
  pushl $195
c0103156:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010315b:	e9 d0 02 00 00       	jmp    c0103430 <__alltraps>

c0103160 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103160:	6a 00                	push   $0x0
  pushl $196
c0103162:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103167:	e9 c4 02 00 00       	jmp    c0103430 <__alltraps>

c010316c <vector197>:
.globl vector197
vector197:
  pushl $0
c010316c:	6a 00                	push   $0x0
  pushl $197
c010316e:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103173:	e9 b8 02 00 00       	jmp    c0103430 <__alltraps>

c0103178 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103178:	6a 00                	push   $0x0
  pushl $198
c010317a:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010317f:	e9 ac 02 00 00       	jmp    c0103430 <__alltraps>

c0103184 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103184:	6a 00                	push   $0x0
  pushl $199
c0103186:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010318b:	e9 a0 02 00 00       	jmp    c0103430 <__alltraps>

c0103190 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103190:	6a 00                	push   $0x0
  pushl $200
c0103192:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103197:	e9 94 02 00 00       	jmp    c0103430 <__alltraps>

c010319c <vector201>:
.globl vector201
vector201:
  pushl $0
c010319c:	6a 00                	push   $0x0
  pushl $201
c010319e:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01031a3:	e9 88 02 00 00       	jmp    c0103430 <__alltraps>

c01031a8 <vector202>:
.globl vector202
vector202:
  pushl $0
c01031a8:	6a 00                	push   $0x0
  pushl $202
c01031aa:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01031af:	e9 7c 02 00 00       	jmp    c0103430 <__alltraps>

c01031b4 <vector203>:
.globl vector203
vector203:
  pushl $0
c01031b4:	6a 00                	push   $0x0
  pushl $203
c01031b6:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01031bb:	e9 70 02 00 00       	jmp    c0103430 <__alltraps>

c01031c0 <vector204>:
.globl vector204
vector204:
  pushl $0
c01031c0:	6a 00                	push   $0x0
  pushl $204
c01031c2:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01031c7:	e9 64 02 00 00       	jmp    c0103430 <__alltraps>

c01031cc <vector205>:
.globl vector205
vector205:
  pushl $0
c01031cc:	6a 00                	push   $0x0
  pushl $205
c01031ce:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01031d3:	e9 58 02 00 00       	jmp    c0103430 <__alltraps>

c01031d8 <vector206>:
.globl vector206
vector206:
  pushl $0
c01031d8:	6a 00                	push   $0x0
  pushl $206
c01031da:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01031df:	e9 4c 02 00 00       	jmp    c0103430 <__alltraps>

c01031e4 <vector207>:
.globl vector207
vector207:
  pushl $0
c01031e4:	6a 00                	push   $0x0
  pushl $207
c01031e6:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01031eb:	e9 40 02 00 00       	jmp    c0103430 <__alltraps>

c01031f0 <vector208>:
.globl vector208
vector208:
  pushl $0
c01031f0:	6a 00                	push   $0x0
  pushl $208
c01031f2:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01031f7:	e9 34 02 00 00       	jmp    c0103430 <__alltraps>

c01031fc <vector209>:
.globl vector209
vector209:
  pushl $0
c01031fc:	6a 00                	push   $0x0
  pushl $209
c01031fe:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0103203:	e9 28 02 00 00       	jmp    c0103430 <__alltraps>

c0103208 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103208:	6a 00                	push   $0x0
  pushl $210
c010320a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010320f:	e9 1c 02 00 00       	jmp    c0103430 <__alltraps>

c0103214 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103214:	6a 00                	push   $0x0
  pushl $211
c0103216:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010321b:	e9 10 02 00 00       	jmp    c0103430 <__alltraps>

c0103220 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103220:	6a 00                	push   $0x0
  pushl $212
c0103222:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103227:	e9 04 02 00 00       	jmp    c0103430 <__alltraps>

c010322c <vector213>:
.globl vector213
vector213:
  pushl $0
c010322c:	6a 00                	push   $0x0
  pushl $213
c010322e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103233:	e9 f8 01 00 00       	jmp    c0103430 <__alltraps>

c0103238 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103238:	6a 00                	push   $0x0
  pushl $214
c010323a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010323f:	e9 ec 01 00 00       	jmp    c0103430 <__alltraps>

c0103244 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103244:	6a 00                	push   $0x0
  pushl $215
c0103246:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010324b:	e9 e0 01 00 00       	jmp    c0103430 <__alltraps>

c0103250 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103250:	6a 00                	push   $0x0
  pushl $216
c0103252:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103257:	e9 d4 01 00 00       	jmp    c0103430 <__alltraps>

c010325c <vector217>:
.globl vector217
vector217:
  pushl $0
c010325c:	6a 00                	push   $0x0
  pushl $217
c010325e:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103263:	e9 c8 01 00 00       	jmp    c0103430 <__alltraps>

c0103268 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103268:	6a 00                	push   $0x0
  pushl $218
c010326a:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010326f:	e9 bc 01 00 00       	jmp    c0103430 <__alltraps>

c0103274 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103274:	6a 00                	push   $0x0
  pushl $219
c0103276:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010327b:	e9 b0 01 00 00       	jmp    c0103430 <__alltraps>

c0103280 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103280:	6a 00                	push   $0x0
  pushl $220
c0103282:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103287:	e9 a4 01 00 00       	jmp    c0103430 <__alltraps>

c010328c <vector221>:
.globl vector221
vector221:
  pushl $0
c010328c:	6a 00                	push   $0x0
  pushl $221
c010328e:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103293:	e9 98 01 00 00       	jmp    c0103430 <__alltraps>

c0103298 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103298:	6a 00                	push   $0x0
  pushl $222
c010329a:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010329f:	e9 8c 01 00 00       	jmp    c0103430 <__alltraps>

c01032a4 <vector223>:
.globl vector223
vector223:
  pushl $0
c01032a4:	6a 00                	push   $0x0
  pushl $223
c01032a6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01032ab:	e9 80 01 00 00       	jmp    c0103430 <__alltraps>

c01032b0 <vector224>:
.globl vector224
vector224:
  pushl $0
c01032b0:	6a 00                	push   $0x0
  pushl $224
c01032b2:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01032b7:	e9 74 01 00 00       	jmp    c0103430 <__alltraps>

c01032bc <vector225>:
.globl vector225
vector225:
  pushl $0
c01032bc:	6a 00                	push   $0x0
  pushl $225
c01032be:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01032c3:	e9 68 01 00 00       	jmp    c0103430 <__alltraps>

c01032c8 <vector226>:
.globl vector226
vector226:
  pushl $0
c01032c8:	6a 00                	push   $0x0
  pushl $226
c01032ca:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01032cf:	e9 5c 01 00 00       	jmp    c0103430 <__alltraps>

c01032d4 <vector227>:
.globl vector227
vector227:
  pushl $0
c01032d4:	6a 00                	push   $0x0
  pushl $227
c01032d6:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01032db:	e9 50 01 00 00       	jmp    c0103430 <__alltraps>

c01032e0 <vector228>:
.globl vector228
vector228:
  pushl $0
c01032e0:	6a 00                	push   $0x0
  pushl $228
c01032e2:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01032e7:	e9 44 01 00 00       	jmp    c0103430 <__alltraps>

c01032ec <vector229>:
.globl vector229
vector229:
  pushl $0
c01032ec:	6a 00                	push   $0x0
  pushl $229
c01032ee:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01032f3:	e9 38 01 00 00       	jmp    c0103430 <__alltraps>

c01032f8 <vector230>:
.globl vector230
vector230:
  pushl $0
c01032f8:	6a 00                	push   $0x0
  pushl $230
c01032fa:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01032ff:	e9 2c 01 00 00       	jmp    c0103430 <__alltraps>

c0103304 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103304:	6a 00                	push   $0x0
  pushl $231
c0103306:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010330b:	e9 20 01 00 00       	jmp    c0103430 <__alltraps>

c0103310 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103310:	6a 00                	push   $0x0
  pushl $232
c0103312:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103317:	e9 14 01 00 00       	jmp    c0103430 <__alltraps>

c010331c <vector233>:
.globl vector233
vector233:
  pushl $0
c010331c:	6a 00                	push   $0x0
  pushl $233
c010331e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103323:	e9 08 01 00 00       	jmp    c0103430 <__alltraps>

c0103328 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103328:	6a 00                	push   $0x0
  pushl $234
c010332a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010332f:	e9 fc 00 00 00       	jmp    c0103430 <__alltraps>

c0103334 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103334:	6a 00                	push   $0x0
  pushl $235
c0103336:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010333b:	e9 f0 00 00 00       	jmp    c0103430 <__alltraps>

c0103340 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103340:	6a 00                	push   $0x0
  pushl $236
c0103342:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103347:	e9 e4 00 00 00       	jmp    c0103430 <__alltraps>

c010334c <vector237>:
.globl vector237
vector237:
  pushl $0
c010334c:	6a 00                	push   $0x0
  pushl $237
c010334e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103353:	e9 d8 00 00 00       	jmp    c0103430 <__alltraps>

c0103358 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103358:	6a 00                	push   $0x0
  pushl $238
c010335a:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010335f:	e9 cc 00 00 00       	jmp    c0103430 <__alltraps>

c0103364 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103364:	6a 00                	push   $0x0
  pushl $239
c0103366:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010336b:	e9 c0 00 00 00       	jmp    c0103430 <__alltraps>

c0103370 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103370:	6a 00                	push   $0x0
  pushl $240
c0103372:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103377:	e9 b4 00 00 00       	jmp    c0103430 <__alltraps>

c010337c <vector241>:
.globl vector241
vector241:
  pushl $0
c010337c:	6a 00                	push   $0x0
  pushl $241
c010337e:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103383:	e9 a8 00 00 00       	jmp    c0103430 <__alltraps>

c0103388 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103388:	6a 00                	push   $0x0
  pushl $242
c010338a:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010338f:	e9 9c 00 00 00       	jmp    c0103430 <__alltraps>

c0103394 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103394:	6a 00                	push   $0x0
  pushl $243
c0103396:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010339b:	e9 90 00 00 00       	jmp    c0103430 <__alltraps>

c01033a0 <vector244>:
.globl vector244
vector244:
  pushl $0
c01033a0:	6a 00                	push   $0x0
  pushl $244
c01033a2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01033a7:	e9 84 00 00 00       	jmp    c0103430 <__alltraps>

c01033ac <vector245>:
.globl vector245
vector245:
  pushl $0
c01033ac:	6a 00                	push   $0x0
  pushl $245
c01033ae:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01033b3:	e9 78 00 00 00       	jmp    c0103430 <__alltraps>

c01033b8 <vector246>:
.globl vector246
vector246:
  pushl $0
c01033b8:	6a 00                	push   $0x0
  pushl $246
c01033ba:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01033bf:	e9 6c 00 00 00       	jmp    c0103430 <__alltraps>

c01033c4 <vector247>:
.globl vector247
vector247:
  pushl $0
c01033c4:	6a 00                	push   $0x0
  pushl $247
c01033c6:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01033cb:	e9 60 00 00 00       	jmp    c0103430 <__alltraps>

c01033d0 <vector248>:
.globl vector248
vector248:
  pushl $0
c01033d0:	6a 00                	push   $0x0
  pushl $248
c01033d2:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01033d7:	e9 54 00 00 00       	jmp    c0103430 <__alltraps>

c01033dc <vector249>:
.globl vector249
vector249:
  pushl $0
c01033dc:	6a 00                	push   $0x0
  pushl $249
c01033de:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01033e3:	e9 48 00 00 00       	jmp    c0103430 <__alltraps>

c01033e8 <vector250>:
.globl vector250
vector250:
  pushl $0
c01033e8:	6a 00                	push   $0x0
  pushl $250
c01033ea:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01033ef:	e9 3c 00 00 00       	jmp    c0103430 <__alltraps>

c01033f4 <vector251>:
.globl vector251
vector251:
  pushl $0
c01033f4:	6a 00                	push   $0x0
  pushl $251
c01033f6:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01033fb:	e9 30 00 00 00       	jmp    c0103430 <__alltraps>

c0103400 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103400:	6a 00                	push   $0x0
  pushl $252
c0103402:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103407:	e9 24 00 00 00       	jmp    c0103430 <__alltraps>

c010340c <vector253>:
.globl vector253
vector253:
  pushl $0
c010340c:	6a 00                	push   $0x0
  pushl $253
c010340e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103413:	e9 18 00 00 00       	jmp    c0103430 <__alltraps>

c0103418 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103418:	6a 00                	push   $0x0
  pushl $254
c010341a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010341f:	e9 0c 00 00 00       	jmp    c0103430 <__alltraps>

c0103424 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103424:	6a 00                	push   $0x0
  pushl $255
c0103426:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010342b:	e9 00 00 00 00       	jmp    c0103430 <__alltraps>

c0103430 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103430:	1e                   	push   %ds
    pushl %es
c0103431:	06                   	push   %es
    pushl %fs
c0103432:	0f a0                	push   %fs
    pushl %gs
c0103434:	0f a8                	push   %gs
    pushal
c0103436:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103437:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010343c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010343e:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103440:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0103441:	e8 64 f5 ff ff       	call   c01029aa <trap>

    # pop the pushed stack pointer
    popl %esp
c0103446:	5c                   	pop    %esp

c0103447 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103447:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103448:	0f a9                	pop    %gs
    popl %fs
c010344a:	0f a1                	pop    %fs
    popl %es
c010344c:	07                   	pop    %es
    popl %ds
c010344d:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010344e:	83 c4 08             	add    $0x8,%esp
    iret
c0103451:	cf                   	iret   

c0103452 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103452:	55                   	push   %ebp
c0103453:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103455:	8b 45 08             	mov    0x8(%ebp),%eax
c0103458:	8b 15 28 60 12 c0    	mov    0xc0126028,%edx
c010345e:	29 d0                	sub    %edx,%eax
c0103460:	c1 f8 05             	sar    $0x5,%eax
}
c0103463:	5d                   	pop    %ebp
c0103464:	c3                   	ret    

c0103465 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103465:	55                   	push   %ebp
c0103466:	89 e5                	mov    %esp,%ebp
c0103468:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010346b:	8b 45 08             	mov    0x8(%ebp),%eax
c010346e:	89 04 24             	mov    %eax,(%esp)
c0103471:	e8 dc ff ff ff       	call   c0103452 <page2ppn>
c0103476:	c1 e0 0c             	shl    $0xc,%eax
}
c0103479:	c9                   	leave  
c010347a:	c3                   	ret    

c010347b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010347b:	55                   	push   %ebp
c010347c:	89 e5                	mov    %esp,%ebp
c010347e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103481:	8b 45 08             	mov    0x8(%ebp),%eax
c0103484:	c1 e8 0c             	shr    $0xc,%eax
c0103487:	89 c2                	mov    %eax,%edx
c0103489:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c010348e:	39 c2                	cmp    %eax,%edx
c0103490:	72 1c                	jb     c01034ae <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103492:	c7 44 24 08 d0 9c 10 	movl   $0xc0109cd0,0x8(%esp)
c0103499:	c0 
c010349a:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01034a1:	00 
c01034a2:	c7 04 24 ef 9c 10 c0 	movl   $0xc0109cef,(%esp)
c01034a9:	e8 55 cf ff ff       	call   c0100403 <__panic>
    }
    return &pages[PPN(pa)];
c01034ae:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c01034b3:	8b 55 08             	mov    0x8(%ebp),%edx
c01034b6:	c1 ea 0c             	shr    $0xc,%edx
c01034b9:	c1 e2 05             	shl    $0x5,%edx
c01034bc:	01 d0                	add    %edx,%eax
}
c01034be:	c9                   	leave  
c01034bf:	c3                   	ret    

c01034c0 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01034c0:	55                   	push   %ebp
c01034c1:	89 e5                	mov    %esp,%ebp
c01034c3:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01034c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01034c9:	89 04 24             	mov    %eax,(%esp)
c01034cc:	e8 94 ff ff ff       	call   c0103465 <page2pa>
c01034d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01034d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034d7:	c1 e8 0c             	shr    $0xc,%eax
c01034da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034dd:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01034e2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01034e5:	72 23                	jb     c010350a <page2kva+0x4a>
c01034e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01034ee:	c7 44 24 08 00 9d 10 	movl   $0xc0109d00,0x8(%esp)
c01034f5:	c0 
c01034f6:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01034fd:	00 
c01034fe:	c7 04 24 ef 9c 10 c0 	movl   $0xc0109cef,(%esp)
c0103505:	e8 f9 ce ff ff       	call   c0100403 <__panic>
c010350a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010350d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103512:	c9                   	leave  
c0103513:	c3                   	ret    

c0103514 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0103514:	55                   	push   %ebp
c0103515:	89 e5                	mov    %esp,%ebp
c0103517:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010351a:	8b 45 08             	mov    0x8(%ebp),%eax
c010351d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103520:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103527:	77 23                	ja     c010354c <kva2page+0x38>
c0103529:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010352c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103530:	c7 44 24 08 24 9d 10 	movl   $0xc0109d24,0x8(%esp)
c0103537:	c0 
c0103538:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c010353f:	00 
c0103540:	c7 04 24 ef 9c 10 c0 	movl   $0xc0109cef,(%esp)
c0103547:	e8 b7 ce ff ff       	call   c0100403 <__panic>
c010354c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354f:	05 00 00 00 40       	add    $0x40000000,%eax
c0103554:	89 04 24             	mov    %eax,(%esp)
c0103557:	e8 1f ff ff ff       	call   c010347b <pa2page>
}
c010355c:	c9                   	leave  
c010355d:	c3                   	ret    

c010355e <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c010355e:	55                   	push   %ebp
c010355f:	89 e5                	mov    %esp,%ebp
c0103561:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103564:	8b 45 08             	mov    0x8(%ebp),%eax
c0103567:	83 e0 01             	and    $0x1,%eax
c010356a:	85 c0                	test   %eax,%eax
c010356c:	75 1c                	jne    c010358a <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010356e:	c7 44 24 08 48 9d 10 	movl   $0xc0109d48,0x8(%esp)
c0103575:	c0 
c0103576:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010357d:	00 
c010357e:	c7 04 24 ef 9c 10 c0 	movl   $0xc0109cef,(%esp)
c0103585:	e8 79 ce ff ff       	call   c0100403 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c010358a:	8b 45 08             	mov    0x8(%ebp),%eax
c010358d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103592:	89 04 24             	mov    %eax,(%esp)
c0103595:	e8 e1 fe ff ff       	call   c010347b <pa2page>
}
c010359a:	c9                   	leave  
c010359b:	c3                   	ret    

c010359c <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c010359c:	55                   	push   %ebp
c010359d:	89 e5                	mov    %esp,%ebp
c010359f:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01035a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01035a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01035aa:	89 04 24             	mov    %eax,(%esp)
c01035ad:	e8 c9 fe ff ff       	call   c010347b <pa2page>
}
c01035b2:	c9                   	leave  
c01035b3:	c3                   	ret    

c01035b4 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01035b4:	55                   	push   %ebp
c01035b5:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01035b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ba:	8b 00                	mov    (%eax),%eax
}
c01035bc:	5d                   	pop    %ebp
c01035bd:	c3                   	ret    

c01035be <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01035be:	55                   	push   %ebp
c01035bf:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01035c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01035c7:	89 10                	mov    %edx,(%eax)
}
c01035c9:	90                   	nop
c01035ca:	5d                   	pop    %ebp
c01035cb:	c3                   	ret    

c01035cc <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01035cc:	55                   	push   %ebp
c01035cd:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01035cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d2:	8b 00                	mov    (%eax),%eax
c01035d4:	8d 50 01             	lea    0x1(%eax),%edx
c01035d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01035da:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01035dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01035df:	8b 00                	mov    (%eax),%eax
}
c01035e1:	5d                   	pop    %ebp
c01035e2:	c3                   	ret    

c01035e3 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01035e3:	55                   	push   %ebp
c01035e4:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01035e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01035e9:	8b 00                	mov    (%eax),%eax
c01035eb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01035ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01035f1:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01035f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01035f6:	8b 00                	mov    (%eax),%eax
}
c01035f8:	5d                   	pop    %ebp
c01035f9:	c3                   	ret    

c01035fa <__intr_save>:
__intr_save(void) {
c01035fa:	55                   	push   %ebp
c01035fb:	89 e5                	mov    %esp,%ebp
c01035fd:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103600:	9c                   	pushf  
c0103601:	58                   	pop    %eax
c0103602:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103605:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103608:	25 00 02 00 00       	and    $0x200,%eax
c010360d:	85 c0                	test   %eax,%eax
c010360f:	74 0c                	je     c010361d <__intr_save+0x23>
        intr_disable();
c0103611:	e8 d5 ea ff ff       	call   c01020eb <intr_disable>
        return 1;
c0103616:	b8 01 00 00 00       	mov    $0x1,%eax
c010361b:	eb 05                	jmp    c0103622 <__intr_save+0x28>
    return 0;
c010361d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103622:	c9                   	leave  
c0103623:	c3                   	ret    

c0103624 <__intr_restore>:
__intr_restore(bool flag) {
c0103624:	55                   	push   %ebp
c0103625:	89 e5                	mov    %esp,%ebp
c0103627:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010362a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010362e:	74 05                	je     c0103635 <__intr_restore+0x11>
        intr_enable();
c0103630:	e8 af ea ff ff       	call   c01020e4 <intr_enable>
}
c0103635:	90                   	nop
c0103636:	c9                   	leave  
c0103637:	c3                   	ret    

c0103638 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103638:	55                   	push   %ebp
c0103639:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c010363b:	8b 45 08             	mov    0x8(%ebp),%eax
c010363e:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103641:	b8 23 00 00 00       	mov    $0x23,%eax
c0103646:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103648:	b8 23 00 00 00       	mov    $0x23,%eax
c010364d:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010364f:	b8 10 00 00 00       	mov    $0x10,%eax
c0103654:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103656:	b8 10 00 00 00       	mov    $0x10,%eax
c010365b:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c010365d:	b8 10 00 00 00       	mov    $0x10,%eax
c0103662:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103664:	ea 6b 36 10 c0 08 00 	ljmp   $0x8,$0xc010366b
}
c010366b:	90                   	nop
c010366c:	5d                   	pop    %ebp
c010366d:	c3                   	ret    

c010366e <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c010366e:	55                   	push   %ebp
c010366f:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103671:	8b 45 08             	mov    0x8(%ebp),%eax
c0103674:	a3 a4 5f 12 c0       	mov    %eax,0xc0125fa4
}
c0103679:	90                   	nop
c010367a:	5d                   	pop    %ebp
c010367b:	c3                   	ret    

c010367c <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c010367c:	55                   	push   %ebp
c010367d:	89 e5                	mov    %esp,%ebp
c010367f:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103682:	b8 00 20 12 c0       	mov    $0xc0122000,%eax
c0103687:	89 04 24             	mov    %eax,(%esp)
c010368a:	e8 df ff ff ff       	call   c010366e <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c010368f:	66 c7 05 a8 5f 12 c0 	movw   $0x10,0xc0125fa8
c0103696:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103698:	66 c7 05 28 2a 12 c0 	movw   $0x68,0xc0122a28
c010369f:	68 00 
c01036a1:	b8 a0 5f 12 c0       	mov    $0xc0125fa0,%eax
c01036a6:	0f b7 c0             	movzwl %ax,%eax
c01036a9:	66 a3 2a 2a 12 c0    	mov    %ax,0xc0122a2a
c01036af:	b8 a0 5f 12 c0       	mov    $0xc0125fa0,%eax
c01036b4:	c1 e8 10             	shr    $0x10,%eax
c01036b7:	a2 2c 2a 12 c0       	mov    %al,0xc0122a2c
c01036bc:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c01036c3:	24 f0                	and    $0xf0,%al
c01036c5:	0c 09                	or     $0x9,%al
c01036c7:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c01036cc:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c01036d3:	24 ef                	and    $0xef,%al
c01036d5:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c01036da:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c01036e1:	24 9f                	and    $0x9f,%al
c01036e3:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c01036e8:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c01036ef:	0c 80                	or     $0x80,%al
c01036f1:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c01036f6:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c01036fd:	24 f0                	and    $0xf0,%al
c01036ff:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c0103704:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c010370b:	24 ef                	and    $0xef,%al
c010370d:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c0103712:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c0103719:	24 df                	and    $0xdf,%al
c010371b:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c0103720:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c0103727:	0c 40                	or     $0x40,%al
c0103729:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c010372e:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c0103735:	24 7f                	and    $0x7f,%al
c0103737:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c010373c:	b8 a0 5f 12 c0       	mov    $0xc0125fa0,%eax
c0103741:	c1 e8 18             	shr    $0x18,%eax
c0103744:	a2 2f 2a 12 c0       	mov    %al,0xc0122a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103749:	c7 04 24 30 2a 12 c0 	movl   $0xc0122a30,(%esp)
c0103750:	e8 e3 fe ff ff       	call   c0103638 <lgdt>
c0103755:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010375b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c010375f:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103762:	90                   	nop
c0103763:	c9                   	leave  
c0103764:	c3                   	ret    

c0103765 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103765:	55                   	push   %ebp
c0103766:	89 e5                	mov    %esp,%ebp
c0103768:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c010376b:	c7 05 20 60 12 c0 b0 	movl   $0xc010b1b0,0xc0126020
c0103772:	b1 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103775:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c010377a:	8b 00                	mov    (%eax),%eax
c010377c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103780:	c7 04 24 74 9d 10 c0 	movl   $0xc0109d74,(%esp)
c0103787:	e8 20 cb ff ff       	call   c01002ac <cprintf>
    pmm_manager->init();
c010378c:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c0103791:	8b 40 04             	mov    0x4(%eax),%eax
c0103794:	ff d0                	call   *%eax
}
c0103796:	90                   	nop
c0103797:	c9                   	leave  
c0103798:	c3                   	ret    

c0103799 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103799:	55                   	push   %ebp
c010379a:	89 e5                	mov    %esp,%ebp
c010379c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010379f:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c01037a4:	8b 40 08             	mov    0x8(%eax),%eax
c01037a7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01037aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01037ae:	8b 55 08             	mov    0x8(%ebp),%edx
c01037b1:	89 14 24             	mov    %edx,(%esp)
c01037b4:	ff d0                	call   *%eax
}
c01037b6:	90                   	nop
c01037b7:	c9                   	leave  
c01037b8:	c3                   	ret    

c01037b9 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c01037b9:	55                   	push   %ebp
c01037ba:	89 e5                	mov    %esp,%ebp
c01037bc:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c01037bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c01037c6:	e8 2f fe ff ff       	call   c01035fa <__intr_save>
c01037cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01037ce:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c01037d3:	8b 40 0c             	mov    0xc(%eax),%eax
c01037d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01037d9:	89 14 24             	mov    %edx,(%esp)
c01037dc:	ff d0                	call   *%eax
c01037de:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01037e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037e4:	89 04 24             	mov    %eax,(%esp)
c01037e7:	e8 38 fe ff ff       	call   c0103624 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01037ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01037f0:	75 2d                	jne    c010381f <alloc_pages+0x66>
c01037f2:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01037f6:	77 27                	ja     c010381f <alloc_pages+0x66>
c01037f8:	a1 10 60 12 c0       	mov    0xc0126010,%eax
c01037fd:	85 c0                	test   %eax,%eax
c01037ff:	74 1e                	je     c010381f <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0103801:	8b 55 08             	mov    0x8(%ebp),%edx
c0103804:	a1 34 60 12 c0       	mov    0xc0126034,%eax
c0103809:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103810:	00 
c0103811:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103815:	89 04 24             	mov    %eax,(%esp)
c0103818:	e8 dc 2c 00 00       	call   c01064f9 <swap_out>
    {
c010381d:	eb a7                	jmp    c01037c6 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c010381f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103822:	c9                   	leave  
c0103823:	c3                   	ret    

c0103824 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103824:	55                   	push   %ebp
c0103825:	89 e5                	mov    %esp,%ebp
c0103827:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010382a:	e8 cb fd ff ff       	call   c01035fa <__intr_save>
c010382f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103832:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c0103837:	8b 40 10             	mov    0x10(%eax),%eax
c010383a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010383d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103841:	8b 55 08             	mov    0x8(%ebp),%edx
c0103844:	89 14 24             	mov    %edx,(%esp)
c0103847:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103849:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010384c:	89 04 24             	mov    %eax,(%esp)
c010384f:	e8 d0 fd ff ff       	call   c0103624 <__intr_restore>
}
c0103854:	90                   	nop
c0103855:	c9                   	leave  
c0103856:	c3                   	ret    

c0103857 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103857:	55                   	push   %ebp
c0103858:	89 e5                	mov    %esp,%ebp
c010385a:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010385d:	e8 98 fd ff ff       	call   c01035fa <__intr_save>
c0103862:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103865:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c010386a:	8b 40 14             	mov    0x14(%eax),%eax
c010386d:	ff d0                	call   *%eax
c010386f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103875:	89 04 24             	mov    %eax,(%esp)
c0103878:	e8 a7 fd ff ff       	call   c0103624 <__intr_restore>
    return ret;
c010387d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103880:	c9                   	leave  
c0103881:	c3                   	ret    

c0103882 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103882:	55                   	push   %ebp
c0103883:	89 e5                	mov    %esp,%ebp
c0103885:	57                   	push   %edi
c0103886:	56                   	push   %esi
c0103887:	53                   	push   %ebx
c0103888:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010388e:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103895:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010389c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01038a3:	c7 04 24 8b 9d 10 c0 	movl   $0xc0109d8b,(%esp)
c01038aa:	e8 fd c9 ff ff       	call   c01002ac <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01038af:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01038b6:	e9 22 01 00 00       	jmp    c01039dd <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01038bb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01038be:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01038c1:	89 d0                	mov    %edx,%eax
c01038c3:	c1 e0 02             	shl    $0x2,%eax
c01038c6:	01 d0                	add    %edx,%eax
c01038c8:	c1 e0 02             	shl    $0x2,%eax
c01038cb:	01 c8                	add    %ecx,%eax
c01038cd:	8b 50 08             	mov    0x8(%eax),%edx
c01038d0:	8b 40 04             	mov    0x4(%eax),%eax
c01038d3:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01038d6:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01038d9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01038dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01038df:	89 d0                	mov    %edx,%eax
c01038e1:	c1 e0 02             	shl    $0x2,%eax
c01038e4:	01 d0                	add    %edx,%eax
c01038e6:	c1 e0 02             	shl    $0x2,%eax
c01038e9:	01 c8                	add    %ecx,%eax
c01038eb:	8b 48 0c             	mov    0xc(%eax),%ecx
c01038ee:	8b 58 10             	mov    0x10(%eax),%ebx
c01038f1:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01038f4:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01038f7:	01 c8                	add    %ecx,%eax
c01038f9:	11 da                	adc    %ebx,%edx
c01038fb:	89 45 98             	mov    %eax,-0x68(%ebp)
c01038fe:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103901:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103904:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103907:	89 d0                	mov    %edx,%eax
c0103909:	c1 e0 02             	shl    $0x2,%eax
c010390c:	01 d0                	add    %edx,%eax
c010390e:	c1 e0 02             	shl    $0x2,%eax
c0103911:	01 c8                	add    %ecx,%eax
c0103913:	83 c0 14             	add    $0x14,%eax
c0103916:	8b 00                	mov    (%eax),%eax
c0103918:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010391b:	8b 45 98             	mov    -0x68(%ebp),%eax
c010391e:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103921:	83 c0 ff             	add    $0xffffffff,%eax
c0103924:	83 d2 ff             	adc    $0xffffffff,%edx
c0103927:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c010392d:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103933:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103936:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103939:	89 d0                	mov    %edx,%eax
c010393b:	c1 e0 02             	shl    $0x2,%eax
c010393e:	01 d0                	add    %edx,%eax
c0103940:	c1 e0 02             	shl    $0x2,%eax
c0103943:	01 c8                	add    %ecx,%eax
c0103945:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103948:	8b 58 10             	mov    0x10(%eax),%ebx
c010394b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010394e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0103952:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103958:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c010395e:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103962:	89 54 24 18          	mov    %edx,0x18(%esp)
c0103966:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103969:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010396c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103970:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103974:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103978:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010397c:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0103983:	e8 24 c9 ff ff       	call   c01002ac <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103988:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010398b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010398e:	89 d0                	mov    %edx,%eax
c0103990:	c1 e0 02             	shl    $0x2,%eax
c0103993:	01 d0                	add    %edx,%eax
c0103995:	c1 e0 02             	shl    $0x2,%eax
c0103998:	01 c8                	add    %ecx,%eax
c010399a:	83 c0 14             	add    $0x14,%eax
c010399d:	8b 00                	mov    (%eax),%eax
c010399f:	83 f8 01             	cmp    $0x1,%eax
c01039a2:	75 36                	jne    c01039da <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c01039a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01039aa:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c01039ad:	77 2b                	ja     c01039da <page_init+0x158>
c01039af:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c01039b2:	72 05                	jb     c01039b9 <page_init+0x137>
c01039b4:	3b 45 98             	cmp    -0x68(%ebp),%eax
c01039b7:	73 21                	jae    c01039da <page_init+0x158>
c01039b9:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01039bd:	77 1b                	ja     c01039da <page_init+0x158>
c01039bf:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01039c3:	72 09                	jb     c01039ce <page_init+0x14c>
c01039c5:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c01039cc:	77 0c                	ja     c01039da <page_init+0x158>
                maxpa = end;
c01039ce:	8b 45 98             	mov    -0x68(%ebp),%eax
c01039d1:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01039d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01039d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c01039da:	ff 45 dc             	incl   -0x24(%ebp)
c01039dd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01039e0:	8b 00                	mov    (%eax),%eax
c01039e2:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01039e5:	0f 8c d0 fe ff ff    	jl     c01038bb <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01039eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01039ef:	72 1d                	jb     c0103a0e <page_init+0x18c>
c01039f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01039f5:	77 09                	ja     c0103a00 <page_init+0x17e>
c01039f7:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01039fe:	76 0e                	jbe    c0103a0e <page_init+0x18c>
        maxpa = KMEMSIZE;
c0103a00:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103a07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    // 此处定义的全局end数组指针，正好是ucore kernel加载后定义的第二个全局变量(kern_init处第一行定义的)
    // 其上的高位内存空间并没有被使用,因此以end为起点，存放用于管理物理内存页面的数据结构
    extern char end[];

    npage = maxpa / PGSIZE;
c0103a0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103a14:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103a18:	c1 ea 0c             	shr    $0xc,%edx
c0103a1b:	89 c1                	mov    %eax,%ecx
c0103a1d:	89 d3                	mov    %edx,%ebx
c0103a1f:	89 c8                	mov    %ecx,%eax
c0103a21:	a3 80 5f 12 c0       	mov    %eax,0xc0125f80
    //cprintf("***********************************npage is:%d**************************\n",npage);  //result is: 32736;
    // pages指针指向->可用于分配的，物理内存页面Page数组起始地址
    // 因此其恰好位于内核空间之上(通过ROUNDUP PGSIZE取整，保证其位于一个新的物理页中)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103a26:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0103a2d:	b8 10 61 12 c0       	mov    $0xc0126110,%eax
c0103a32:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103a35:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103a38:	01 d0                	add    %edx,%eax
c0103a3a:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0103a3d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103a40:	ba 00 00 00 00       	mov    $0x0,%edx
c0103a45:	f7 75 c0             	divl   -0x40(%ebp)
c0103a48:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103a4b:	29 d0                	sub    %edx,%eax
c0103a4d:	a3 28 60 12 c0       	mov    %eax,0xc0126028

    for (i = 0; i < npage; i ++) {
c0103a52:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103a59:	eb 26                	jmp    c0103a81 <page_init+0x1ff>
        SetPageReserved(pages + i);
c0103a5b:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c0103a60:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103a63:	c1 e2 05             	shl    $0x5,%edx
c0103a66:	01 d0                	add    %edx,%eax
c0103a68:	83 c0 04             	add    $0x4,%eax
c0103a6b:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0103a72:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a75:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103a78:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103a7b:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0103a7e:	ff 45 dc             	incl   -0x24(%ebp)
c0103a81:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103a84:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103a89:	39 c2                	cmp    %eax,%edx
c0103a8b:	72 ce                	jb     c0103a5b <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103a8d:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103a92:	c1 e0 05             	shl    $0x5,%eax
c0103a95:	89 c2                	mov    %eax,%edx
c0103a97:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c0103a9c:	01 d0                	add    %edx,%eax
c0103a9e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103aa1:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0103aa8:	77 23                	ja     c0103acd <page_init+0x24b>
c0103aaa:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103aad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103ab1:	c7 44 24 08 24 9d 10 	movl   $0xc0109d24,0x8(%esp)
c0103ab8:	c0 
c0103ab9:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103ac0:	00 
c0103ac1:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103ac8:	e8 36 c9 ff ff       	call   c0100403 <__panic>
c0103acd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103ad0:	05 00 00 00 40       	add    $0x40000000,%eax
c0103ad5:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103ad8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103adf:	e9 69 01 00 00       	jmp    c0103c4d <page_init+0x3cb>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103ae4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ae7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103aea:	89 d0                	mov    %edx,%eax
c0103aec:	c1 e0 02             	shl    $0x2,%eax
c0103aef:	01 d0                	add    %edx,%eax
c0103af1:	c1 e0 02             	shl    $0x2,%eax
c0103af4:	01 c8                	add    %ecx,%eax
c0103af6:	8b 50 08             	mov    0x8(%eax),%edx
c0103af9:	8b 40 04             	mov    0x4(%eax),%eax
c0103afc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103aff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103b02:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103b05:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103b08:	89 d0                	mov    %edx,%eax
c0103b0a:	c1 e0 02             	shl    $0x2,%eax
c0103b0d:	01 d0                	add    %edx,%eax
c0103b0f:	c1 e0 02             	shl    $0x2,%eax
c0103b12:	01 c8                	add    %ecx,%eax
c0103b14:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103b17:	8b 58 10             	mov    0x10(%eax),%ebx
c0103b1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103b1d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103b20:	01 c8                	add    %ecx,%eax
c0103b22:	11 da                	adc    %ebx,%edx
c0103b24:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103b27:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0103b2a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103b2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103b30:	89 d0                	mov    %edx,%eax
c0103b32:	c1 e0 02             	shl    $0x2,%eax
c0103b35:	01 d0                	add    %edx,%eax
c0103b37:	c1 e0 02             	shl    $0x2,%eax
c0103b3a:	01 c8                	add    %ecx,%eax
c0103b3c:	83 c0 14             	add    $0x14,%eax
c0103b3f:	8b 00                	mov    (%eax),%eax
c0103b41:	83 f8 01             	cmp    $0x1,%eax
c0103b44:	0f 85 00 01 00 00    	jne    c0103c4a <page_init+0x3c8>
            if (begin < freemem) {
c0103b4a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103b4d:	ba 00 00 00 00       	mov    $0x0,%edx
c0103b52:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0103b55:	77 17                	ja     c0103b6e <page_init+0x2ec>
c0103b57:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0103b5a:	72 05                	jb     c0103b61 <page_init+0x2df>
c0103b5c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0103b5f:	73 0d                	jae    c0103b6e <page_init+0x2ec>
                begin = freemem;
c0103b61:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103b64:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103b67:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0103b6e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103b72:	72 1d                	jb     c0103b91 <page_init+0x30f>
c0103b74:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103b78:	77 09                	ja     c0103b83 <page_init+0x301>
c0103b7a:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0103b81:	76 0e                	jbe    c0103b91 <page_init+0x30f>
                end = KMEMSIZE;
c0103b83:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0103b8a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0103b91:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103b94:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103b97:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103b9a:	0f 87 aa 00 00 00    	ja     c0103c4a <page_init+0x3c8>
c0103ba0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103ba3:	72 09                	jb     c0103bae <page_init+0x32c>
c0103ba5:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103ba8:	0f 83 9c 00 00 00    	jae    c0103c4a <page_init+0x3c8>
                begin = ROUNDUP(begin, PGSIZE);
c0103bae:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0103bb5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103bb8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103bbb:	01 d0                	add    %edx,%eax
c0103bbd:	48                   	dec    %eax
c0103bbe:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103bc1:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103bc4:	ba 00 00 00 00       	mov    $0x0,%edx
c0103bc9:	f7 75 b0             	divl   -0x50(%ebp)
c0103bcc:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103bcf:	29 d0                	sub    %edx,%eax
c0103bd1:	ba 00 00 00 00       	mov    $0x0,%edx
c0103bd6:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103bd9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103bdc:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103bdf:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103be2:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103be5:	ba 00 00 00 00       	mov    $0x0,%edx
c0103bea:	89 c3                	mov    %eax,%ebx
c0103bec:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103bf2:	89 de                	mov    %ebx,%esi
c0103bf4:	89 d0                	mov    %edx,%eax
c0103bf6:	83 e0 00             	and    $0x0,%eax
c0103bf9:	89 c7                	mov    %eax,%edi
c0103bfb:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103bfe:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0103c01:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103c04:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103c07:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103c0a:	77 3e                	ja     c0103c4a <page_init+0x3c8>
c0103c0c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103c0f:	72 05                	jb     c0103c16 <page_init+0x394>
c0103c11:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103c14:	73 34                	jae    c0103c4a <page_init+0x3c8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103c16:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103c19:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103c1c:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103c1f:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103c22:	89 c1                	mov    %eax,%ecx
c0103c24:	89 d3                	mov    %edx,%ebx
c0103c26:	89 c8                	mov    %ecx,%eax
c0103c28:	89 da                	mov    %ebx,%edx
c0103c2a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103c2e:	c1 ea 0c             	shr    $0xc,%edx
c0103c31:	89 c3                	mov    %eax,%ebx
c0103c33:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103c36:	89 04 24             	mov    %eax,(%esp)
c0103c39:	e8 3d f8 ff ff       	call   c010347b <pa2page>
c0103c3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103c42:	89 04 24             	mov    %eax,(%esp)
c0103c45:	e8 4f fb ff ff       	call   c0103799 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0103c4a:	ff 45 dc             	incl   -0x24(%ebp)
c0103c4d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103c50:	8b 00                	mov    (%eax),%eax
c0103c52:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103c55:	0f 8c 89 fe ff ff    	jl     c0103ae4 <page_init+0x262>
                }
            }
        }
    }
}
c0103c5b:	90                   	nop
c0103c5c:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103c62:	5b                   	pop    %ebx
c0103c63:	5e                   	pop    %esi
c0103c64:	5f                   	pop    %edi
c0103c65:	5d                   	pop    %ebp
c0103c66:	c3                   	ret    

c0103c67 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0103c67:	55                   	push   %ebp
c0103c68:	89 e5                	mov    %esp,%ebp
c0103c6a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c70:	33 45 14             	xor    0x14(%ebp),%eax
c0103c73:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103c78:	85 c0                	test   %eax,%eax
c0103c7a:	74 24                	je     c0103ca0 <boot_map_segment+0x39>
c0103c7c:	c7 44 24 0c d6 9d 10 	movl   $0xc0109dd6,0xc(%esp)
c0103c83:	c0 
c0103c84:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0103c8b:	c0 
c0103c8c:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0103c93:	00 
c0103c94:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103c9b:	e8 63 c7 ff ff       	call   c0100403 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103ca0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103caa:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103caf:	89 c2                	mov    %eax,%edx
c0103cb1:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cb4:	01 c2                	add    %eax,%edx
c0103cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cb9:	01 d0                	add    %edx,%eax
c0103cbb:	48                   	dec    %eax
c0103cbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cc2:	ba 00 00 00 00       	mov    $0x0,%edx
c0103cc7:	f7 75 f0             	divl   -0x10(%ebp)
c0103cca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ccd:	29 d0                	sub    %edx,%eax
c0103ccf:	c1 e8 0c             	shr    $0xc,%eax
c0103cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103cd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103cdb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103cde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ce3:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103ce6:	8b 45 14             	mov    0x14(%ebp),%eax
c0103ce9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103cef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103cf4:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103cf7:	eb 68                	jmp    c0103d61 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103cf9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103d00:	00 
c0103d01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d08:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d0b:	89 04 24             	mov    %eax,(%esp)
c0103d0e:	e8 81 01 00 00       	call   c0103e94 <get_pte>
c0103d13:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103d16:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103d1a:	75 24                	jne    c0103d40 <boot_map_segment+0xd9>
c0103d1c:	c7 44 24 0c 02 9e 10 	movl   $0xc0109e02,0xc(%esp)
c0103d23:	c0 
c0103d24:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0103d2b:	c0 
c0103d2c:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103d33:	00 
c0103d34:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103d3b:	e8 c3 c6 ff ff       	call   c0100403 <__panic>
        *ptep = pa | PTE_P | perm;
c0103d40:	8b 45 14             	mov    0x14(%ebp),%eax
c0103d43:	0b 45 18             	or     0x18(%ebp),%eax
c0103d46:	83 c8 01             	or     $0x1,%eax
c0103d49:	89 c2                	mov    %eax,%edx
c0103d4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d4e:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103d50:	ff 4d f4             	decl   -0xc(%ebp)
c0103d53:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103d5a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103d61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d65:	75 92                	jne    c0103cf9 <boot_map_segment+0x92>
    }
}
c0103d67:	90                   	nop
c0103d68:	c9                   	leave  
c0103d69:	c3                   	ret    

c0103d6a <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0103d6a:	55                   	push   %ebp
c0103d6b:	89 e5                	mov    %esp,%ebp
c0103d6d:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103d70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d77:	e8 3d fa ff ff       	call   c01037b9 <alloc_pages>
c0103d7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103d7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d83:	75 1c                	jne    c0103da1 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0103d85:	c7 44 24 08 0f 9e 10 	movl   $0xc0109e0f,0x8(%esp)
c0103d8c:	c0 
c0103d8d:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0103d94:	00 
c0103d95:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103d9c:	e8 62 c6 ff ff       	call   c0100403 <__panic>
    }
    return page2kva(p);
c0103da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103da4:	89 04 24             	mov    %eax,(%esp)
c0103da7:	e8 14 f7 ff ff       	call   c01034c0 <page2kva>
}
c0103dac:	c9                   	leave  
c0103dad:	c3                   	ret    

c0103dae <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103dae:	55                   	push   %ebp
c0103daf:	89 e5                	mov    %esp,%ebp
c0103db1:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103db4:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103db9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103dbc:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103dc3:	77 23                	ja     c0103de8 <pmm_init+0x3a>
c0103dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103dcc:	c7 44 24 08 24 9d 10 	movl   $0xc0109d24,0x8(%esp)
c0103dd3:	c0 
c0103dd4:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0103ddb:	00 
c0103ddc:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103de3:	e8 1b c6 ff ff       	call   c0100403 <__panic>
c0103de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103deb:	05 00 00 00 40       	add    $0x40000000,%eax
c0103df0:	a3 24 60 12 c0       	mov    %eax,0xc0126024
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103df5:	e8 6b f9 ff ff       	call   c0103765 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103dfa:	e8 83 fa ff ff       	call   c0103882 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103dff:	e8 a9 04 00 00       	call   c01042ad <check_alloc_page>

    check_pgdir();
c0103e04:	e8 c3 04 00 00       	call   c01042cc <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103e09:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103e11:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103e18:	77 23                	ja     c0103e3d <pmm_init+0x8f>
c0103e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103e21:	c7 44 24 08 24 9d 10 	movl   $0xc0109d24,0x8(%esp)
c0103e28:	c0 
c0103e29:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c0103e30:	00 
c0103e31:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103e38:	e8 c6 c5 ff ff       	call   c0100403 <__panic>
c0103e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e40:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0103e46:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103e4b:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103e50:	83 ca 03             	or     $0x3,%edx
c0103e53:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103e55:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103e5a:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103e61:	00 
c0103e62:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103e69:	00 
c0103e6a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103e71:	38 
c0103e72:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103e79:	c0 
c0103e7a:	89 04 24             	mov    %eax,(%esp)
c0103e7d:	e8 e5 fd ff ff       	call   c0103c67 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103e82:	e8 f5 f7 ff ff       	call   c010367c <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103e87:	e8 dc 0a 00 00       	call   c0104968 <check_boot_pgdir>

    print_pgdir();
c0103e8c:	e8 55 0f 00 00       	call   c0104de6 <print_pgdir>

}
c0103e91:	90                   	nop
c0103e92:	c9                   	leave  
c0103e93:	c3                   	ret    

c0103e94 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103e94:	55                   	push   %ebp
c0103e95:	89 e5                	mov    %esp,%ebp
c0103e97:	83 ec 38             	sub    $0x38,%esp

PTE_U 0x004 表示可以读取对应地址的物理内存页内容
*/
    // PDX(la) 根据la的高10位获得对应的页目录项(一级页表中的某一项)索引(页目录项)
    // &pgdir[PDX(la)] 根据一级页表项索引从一级页表中找到对应的页目录项指针
    pde_t *pdep = &pgdir[PDX(la)];
c0103e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e9d:	c1 e8 16             	shr    $0x16,%eax
c0103ea0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103ea7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eaa:	01 d0                	add    %edx,%eax
c0103eac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0103eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103eb2:	8b 00                	mov    (%eax),%eax
c0103eb4:	83 e0 01             	and    $0x1,%eax
c0103eb7:	85 c0                	test   %eax,%eax
c0103eb9:	0f 85 af 00 00 00    	jne    c0103f6e <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0103ebf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103ec3:	74 15                	je     c0103eda <get_pte+0x46>
c0103ec5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ecc:	e8 e8 f8 ff ff       	call   c01037b9 <alloc_pages>
c0103ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ed4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ed8:	75 0a                	jne    c0103ee4 <get_pte+0x50>
            return NULL;
c0103eda:	b8 00 00 00 00       	mov    $0x0,%eax
c0103edf:	e9 e7 00 00 00       	jmp    c0103fcb <get_pte+0x137>
        }
        // 二级页表所对应的物理页 引用数为1
        set_page_ref(page, 1);
c0103ee4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103eeb:	00 
c0103eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103eef:	89 04 24             	mov    %eax,(%esp)
c0103ef2:	e8 c7 f6 ff ff       	call   c01035be <set_page_ref>
        // 获得page变量的物理地址
        uintptr_t pa = page2pa(page);
c0103ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103efa:	89 04 24             	mov    %eax,(%esp)
c0103efd:	e8 63 f5 ff ff       	call   c0103465 <page2pa>
c0103f02:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 将整个page所在的物理页格式胡，全部填满0
        memset(KADDR(pa), 0, PGSIZE);
c0103f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f08:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103f0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f0e:	c1 e8 0c             	shr    $0xc,%eax
c0103f11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103f14:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103f19:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103f1c:	72 23                	jb     c0103f41 <get_pte+0xad>
c0103f1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f21:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f25:	c7 44 24 08 00 9d 10 	movl   $0xc0109d00,0x8(%esp)
c0103f2c:	c0 
c0103f2d:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
c0103f34:	00 
c0103f35:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103f3c:	e8 c2 c4 ff ff       	call   c0100403 <__panic>
c0103f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f44:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103f49:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103f50:	00 
c0103f51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103f58:	00 
c0103f59:	89 04 24             	mov    %eax,(%esp)
c0103f5c:	e8 97 4b 00 00       	call   c0108af8 <memset>
        // la对应的一级页目录项进行赋值，使其指向新创建的二级页表(页表中的数据被MMU直接处理，为了映射效率存放的都是物理地址)
        // 或PTE_U/PTE_W/PET_P 标识当前页目录项是用户级别的、可写的、已存在的
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0103f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f64:	83 c8 07             	or     $0x7,%eax
c0103f67:	89 c2                	mov    %eax,%edx
c0103f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f6c:	89 10                	mov    %edx,(%eax)
    }
    // 要想通过C语言中的数组来访问对应数据，需要的是数组基址(虚拟地址),而*pdep中页目录表项中存放了对应二级页表的一个物理地址
    // PDE_ADDR将*pdep的低12位抹零对齐(指向二级页表的起始基地址)，再通过KADDR转为内核虚拟地址，进行数组访问
    // PTX(la)获得la线性地址的中间10位部分，即二级页表中对应页表项的索引下标。这样便能得到la对应的二级页表项了
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0103f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f71:	8b 00                	mov    (%eax),%eax
c0103f73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103f78:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f7e:	c1 e8 0c             	shr    $0xc,%eax
c0103f81:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103f84:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103f89:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103f8c:	72 23                	jb     c0103fb1 <get_pte+0x11d>
c0103f8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f91:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f95:	c7 44 24 08 00 9d 10 	movl   $0xc0109d00,0x8(%esp)
c0103f9c:	c0 
c0103f9d:	c7 44 24 04 a3 01 00 	movl   $0x1a3,0x4(%esp)
c0103fa4:	00 
c0103fa5:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0103fac:	e8 52 c4 ff ff       	call   c0100403 <__panic>
c0103fb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fb4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103fb9:	89 c2                	mov    %eax,%edx
c0103fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103fbe:	c1 e8 0c             	shr    $0xc,%eax
c0103fc1:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103fc6:	c1 e0 02             	shl    $0x2,%eax
c0103fc9:	01 d0                	add    %edx,%eax
}
c0103fcb:	c9                   	leave  
c0103fcc:	c3                   	ret    

c0103fcd <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103fcd:	55                   	push   %ebp
c0103fce:	89 e5                	mov    %esp,%ebp
c0103fd0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103fd3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103fda:	00 
c0103fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103fde:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fe2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fe5:	89 04 24             	mov    %eax,(%esp)
c0103fe8:	e8 a7 fe ff ff       	call   c0103e94 <get_pte>
c0103fed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103ff0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103ff4:	74 08                	je     c0103ffe <get_page+0x31>
        *ptep_store = ptep;
c0103ff6:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ff9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ffc:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103ffe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104002:	74 1b                	je     c010401f <get_page+0x52>
c0104004:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104007:	8b 00                	mov    (%eax),%eax
c0104009:	83 e0 01             	and    $0x1,%eax
c010400c:	85 c0                	test   %eax,%eax
c010400e:	74 0f                	je     c010401f <get_page+0x52>
        return pte2page(*ptep);
c0104010:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104013:	8b 00                	mov    (%eax),%eax
c0104015:	89 04 24             	mov    %eax,(%esp)
c0104018:	e8 41 f5 ff ff       	call   c010355e <pte2page>
c010401d:	eb 05                	jmp    c0104024 <get_page+0x57>
    }
    return NULL;
c010401f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104024:	c9                   	leave  
c0104025:	c3                   	ret    

c0104026 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104026:	55                   	push   %ebp
c0104027:	89 e5                	mov    %esp,%ebp
c0104029:	83 ec 28             	sub    $0x28,%esp
                                  //(6) flush tlb
    }
#endif
        // 如果对应的二级页表项存在
        // 获得*ptep对应的Page结构
    if (*ptep & PTE_P) {
c010402c:	8b 45 10             	mov    0x10(%ebp),%eax
c010402f:	8b 00                	mov    (%eax),%eax
c0104031:	83 e0 01             	and    $0x1,%eax
c0104034:	85 c0                	test   %eax,%eax
c0104036:	74 4d                	je     c0104085 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104038:	8b 45 10             	mov    0x10(%ebp),%eax
c010403b:	8b 00                	mov    (%eax),%eax
c010403d:	89 04 24             	mov    %eax,(%esp)
c0104040:	e8 19 f5 ff ff       	call   c010355e <pte2page>
c0104045:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104048:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010404b:	89 04 24             	mov    %eax,(%esp)
c010404e:	e8 90 f5 ff ff       	call   c01035e3 <page_ref_dec>
c0104053:	85 c0                	test   %eax,%eax
c0104055:	75 13                	jne    c010406a <page_remove_pte+0x44>
            // 如果自减1后，引用数为0，需要free释放掉该物理页
            free_page(page);
c0104057:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010405e:	00 
c010405f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104062:	89 04 24             	mov    %eax,(%esp)
c0104065:	e8 ba f7 ff ff       	call   c0103824 <free_pages>
        }
        // 清空当前二级页表项(整体设置为0)
        *ptep = 0;
c010406a:	8b 45 10             	mov    0x10(%ebp),%eax
c010406d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        // 由于页表项发生了改变，需要TLB快表
        tlb_invalidate(pgdir, la);
c0104073:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104076:	89 44 24 04          	mov    %eax,0x4(%esp)
c010407a:	8b 45 08             	mov    0x8(%ebp),%eax
c010407d:	89 04 24             	mov    %eax,(%esp)
c0104080:	e8 01 01 00 00       	call   c0104186 <tlb_invalidate>
    }
}
c0104085:	90                   	nop
c0104086:	c9                   	leave  
c0104087:	c3                   	ret    

c0104088 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104088:	55                   	push   %ebp
c0104089:	89 e5                	mov    %esp,%ebp
c010408b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010408e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104095:	00 
c0104096:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104099:	89 44 24 04          	mov    %eax,0x4(%esp)
c010409d:	8b 45 08             	mov    0x8(%ebp),%eax
c01040a0:	89 04 24             	mov    %eax,(%esp)
c01040a3:	e8 ec fd ff ff       	call   c0103e94 <get_pte>
c01040a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01040ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01040af:	74 19                	je     c01040ca <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01040b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040b4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01040b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01040bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01040bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01040c2:	89 04 24             	mov    %eax,(%esp)
c01040c5:	e8 5c ff ff ff       	call   c0104026 <page_remove_pte>
    }
}
c01040ca:	90                   	nop
c01040cb:	c9                   	leave  
c01040cc:	c3                   	ret    

c01040cd <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01040cd:	55                   	push   %ebp
c01040ce:	89 e5                	mov    %esp,%ebp
c01040d0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01040d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01040da:	00 
c01040db:	8b 45 10             	mov    0x10(%ebp),%eax
c01040de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01040e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01040e5:	89 04 24             	mov    %eax,(%esp)
c01040e8:	e8 a7 fd ff ff       	call   c0103e94 <get_pte>
c01040ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01040f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01040f4:	75 0a                	jne    c0104100 <page_insert+0x33>
        return -E_NO_MEM;
c01040f6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01040fb:	e9 84 00 00 00       	jmp    c0104184 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104100:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104103:	89 04 24             	mov    %eax,(%esp)
c0104106:	e8 c1 f4 ff ff       	call   c01035cc <page_ref_inc>
    if (*ptep & PTE_P) {
c010410b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010410e:	8b 00                	mov    (%eax),%eax
c0104110:	83 e0 01             	and    $0x1,%eax
c0104113:	85 c0                	test   %eax,%eax
c0104115:	74 3e                	je     c0104155 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104117:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010411a:	8b 00                	mov    (%eax),%eax
c010411c:	89 04 24             	mov    %eax,(%esp)
c010411f:	e8 3a f4 ff ff       	call   c010355e <pte2page>
c0104124:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104127:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010412a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010412d:	75 0d                	jne    c010413c <page_insert+0x6f>
            page_ref_dec(page);
c010412f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104132:	89 04 24             	mov    %eax,(%esp)
c0104135:	e8 a9 f4 ff ff       	call   c01035e3 <page_ref_dec>
c010413a:	eb 19                	jmp    c0104155 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010413c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010413f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104143:	8b 45 10             	mov    0x10(%ebp),%eax
c0104146:	89 44 24 04          	mov    %eax,0x4(%esp)
c010414a:	8b 45 08             	mov    0x8(%ebp),%eax
c010414d:	89 04 24             	mov    %eax,(%esp)
c0104150:	e8 d1 fe ff ff       	call   c0104026 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104155:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104158:	89 04 24             	mov    %eax,(%esp)
c010415b:	e8 05 f3 ff ff       	call   c0103465 <page2pa>
c0104160:	0b 45 14             	or     0x14(%ebp),%eax
c0104163:	83 c8 01             	or     $0x1,%eax
c0104166:	89 c2                	mov    %eax,%edx
c0104168:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010416b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010416d:	8b 45 10             	mov    0x10(%ebp),%eax
c0104170:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104174:	8b 45 08             	mov    0x8(%ebp),%eax
c0104177:	89 04 24             	mov    %eax,(%esp)
c010417a:	e8 07 00 00 00       	call   c0104186 <tlb_invalidate>
    return 0;
c010417f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104184:	c9                   	leave  
c0104185:	c3                   	ret    

c0104186 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0104186:	55                   	push   %ebp
c0104187:	89 e5                	mov    %esp,%ebp
c0104189:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010418c:	0f 20 d8             	mov    %cr3,%eax
c010418f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104192:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0104195:	8b 45 08             	mov    0x8(%ebp),%eax
c0104198:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010419b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01041a2:	77 23                	ja     c01041c7 <tlb_invalidate+0x41>
c01041a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01041ab:	c7 44 24 08 24 9d 10 	movl   $0xc0109d24,0x8(%esp)
c01041b2:	c0 
c01041b3:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c01041ba:	00 
c01041bb:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01041c2:	e8 3c c2 ff ff       	call   c0100403 <__panic>
c01041c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041ca:	05 00 00 00 40       	add    $0x40000000,%eax
c01041cf:	39 d0                	cmp    %edx,%eax
c01041d1:	75 0c                	jne    c01041df <tlb_invalidate+0x59>
        invlpg((void *)la);
c01041d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01041d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041dc:	0f 01 38             	invlpg (%eax)
    }
}
c01041df:	90                   	nop
c01041e0:	c9                   	leave  
c01041e1:	c3                   	ret    

c01041e2 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01041e2:	55                   	push   %ebp
c01041e3:	89 e5                	mov    %esp,%ebp
c01041e5:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01041e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01041ef:	e8 c5 f5 ff ff       	call   c01037b9 <alloc_pages>
c01041f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01041f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01041fb:	0f 84 a7 00 00 00    	je     c01042a8 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0104201:	8b 45 10             	mov    0x10(%ebp),%eax
c0104204:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104208:	8b 45 0c             	mov    0xc(%ebp),%eax
c010420b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104212:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104216:	8b 45 08             	mov    0x8(%ebp),%eax
c0104219:	89 04 24             	mov    %eax,(%esp)
c010421c:	e8 ac fe ff ff       	call   c01040cd <page_insert>
c0104221:	85 c0                	test   %eax,%eax
c0104223:	74 1a                	je     c010423f <pgdir_alloc_page+0x5d>
            free_page(page);
c0104225:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010422c:	00 
c010422d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104230:	89 04 24             	mov    %eax,(%esp)
c0104233:	e8 ec f5 ff ff       	call   c0103824 <free_pages>
            return NULL;
c0104238:	b8 00 00 00 00       	mov    $0x0,%eax
c010423d:	eb 6c                	jmp    c01042ab <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c010423f:	a1 10 60 12 c0       	mov    0xc0126010,%eax
c0104244:	85 c0                	test   %eax,%eax
c0104246:	74 60                	je     c01042a8 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0104248:	a1 34 60 12 c0       	mov    0xc0126034,%eax
c010424d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104254:	00 
c0104255:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104258:	89 54 24 08          	mov    %edx,0x8(%esp)
c010425c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010425f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104263:	89 04 24             	mov    %eax,(%esp)
c0104266:	e8 42 22 00 00       	call   c01064ad <swap_map_swappable>
            page->pra_vaddr=la;
c010426b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010426e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104271:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0104274:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104277:	89 04 24             	mov    %eax,(%esp)
c010427a:	e8 35 f3 ff ff       	call   c01035b4 <page_ref>
c010427f:	83 f8 01             	cmp    $0x1,%eax
c0104282:	74 24                	je     c01042a8 <pgdir_alloc_page+0xc6>
c0104284:	c7 44 24 0c 28 9e 10 	movl   $0xc0109e28,0xc(%esp)
c010428b:	c0 
c010428c:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104293:	c0 
c0104294:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010429b:	00 
c010429c:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01042a3:	e8 5b c1 ff ff       	call   c0100403 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c01042a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01042ab:	c9                   	leave  
c01042ac:	c3                   	ret    

c01042ad <check_alloc_page>:

static void
check_alloc_page(void) {
c01042ad:	55                   	push   %ebp
c01042ae:	89 e5                	mov    %esp,%ebp
c01042b0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01042b3:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c01042b8:	8b 40 18             	mov    0x18(%eax),%eax
c01042bb:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01042bd:	c7 04 24 3c 9e 10 c0 	movl   $0xc0109e3c,(%esp)
c01042c4:	e8 e3 bf ff ff       	call   c01002ac <cprintf>
}
c01042c9:	90                   	nop
c01042ca:	c9                   	leave  
c01042cb:	c3                   	ret    

c01042cc <check_pgdir>:

static void
check_pgdir(void) {
c01042cc:	55                   	push   %ebp
c01042cd:	89 e5                	mov    %esp,%ebp
c01042cf:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01042d2:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01042d7:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01042dc:	76 24                	jbe    c0104302 <check_pgdir+0x36>
c01042de:	c7 44 24 0c 5b 9e 10 	movl   $0xc0109e5b,0xc(%esp)
c01042e5:	c0 
c01042e6:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01042ed:	c0 
c01042ee:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c01042f5:	00 
c01042f6:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01042fd:	e8 01 c1 ff ff       	call   c0100403 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104302:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104307:	85 c0                	test   %eax,%eax
c0104309:	74 0e                	je     c0104319 <check_pgdir+0x4d>
c010430b:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104310:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104315:	85 c0                	test   %eax,%eax
c0104317:	74 24                	je     c010433d <check_pgdir+0x71>
c0104319:	c7 44 24 0c 78 9e 10 	movl   $0xc0109e78,0xc(%esp)
c0104320:	c0 
c0104321:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104328:	c0 
c0104329:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0104330:	00 
c0104331:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104338:	e8 c6 c0 ff ff       	call   c0100403 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010433d:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104342:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104349:	00 
c010434a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104351:	00 
c0104352:	89 04 24             	mov    %eax,(%esp)
c0104355:	e8 73 fc ff ff       	call   c0103fcd <get_page>
c010435a:	85 c0                	test   %eax,%eax
c010435c:	74 24                	je     c0104382 <check_pgdir+0xb6>
c010435e:	c7 44 24 0c b0 9e 10 	movl   $0xc0109eb0,0xc(%esp)
c0104365:	c0 
c0104366:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010436d:	c0 
c010436e:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0104375:	00 
c0104376:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010437d:	e8 81 c0 ff ff       	call   c0100403 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104382:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104389:	e8 2b f4 ff ff       	call   c01037b9 <alloc_pages>
c010438e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104391:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104396:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010439d:	00 
c010439e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01043a5:	00 
c01043a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01043a9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01043ad:	89 04 24             	mov    %eax,(%esp)
c01043b0:	e8 18 fd ff ff       	call   c01040cd <page_insert>
c01043b5:	85 c0                	test   %eax,%eax
c01043b7:	74 24                	je     c01043dd <check_pgdir+0x111>
c01043b9:	c7 44 24 0c d8 9e 10 	movl   $0xc0109ed8,0xc(%esp)
c01043c0:	c0 
c01043c1:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01043c8:	c0 
c01043c9:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c01043d0:	00 
c01043d1:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01043d8:	e8 26 c0 ff ff       	call   c0100403 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01043dd:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01043e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01043e9:	00 
c01043ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01043f1:	00 
c01043f2:	89 04 24             	mov    %eax,(%esp)
c01043f5:	e8 9a fa ff ff       	call   c0103e94 <get_pte>
c01043fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104401:	75 24                	jne    c0104427 <check_pgdir+0x15b>
c0104403:	c7 44 24 0c 04 9f 10 	movl   $0xc0109f04,0xc(%esp)
c010440a:	c0 
c010440b:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104412:	c0 
c0104413:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c010441a:	00 
c010441b:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104422:	e8 dc bf ff ff       	call   c0100403 <__panic>
    assert(pte2page(*ptep) == p1);
c0104427:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010442a:	8b 00                	mov    (%eax),%eax
c010442c:	89 04 24             	mov    %eax,(%esp)
c010442f:	e8 2a f1 ff ff       	call   c010355e <pte2page>
c0104434:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104437:	74 24                	je     c010445d <check_pgdir+0x191>
c0104439:	c7 44 24 0c 31 9f 10 	movl   $0xc0109f31,0xc(%esp)
c0104440:	c0 
c0104441:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104448:	c0 
c0104449:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c0104450:	00 
c0104451:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104458:	e8 a6 bf ff ff       	call   c0100403 <__panic>
    assert(page_ref(p1) == 1);
c010445d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104460:	89 04 24             	mov    %eax,(%esp)
c0104463:	e8 4c f1 ff ff       	call   c01035b4 <page_ref>
c0104468:	83 f8 01             	cmp    $0x1,%eax
c010446b:	74 24                	je     c0104491 <check_pgdir+0x1c5>
c010446d:	c7 44 24 0c 47 9f 10 	movl   $0xc0109f47,0xc(%esp)
c0104474:	c0 
c0104475:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010447c:	c0 
c010447d:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c0104484:	00 
c0104485:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010448c:	e8 72 bf ff ff       	call   c0100403 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104491:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104496:	8b 00                	mov    (%eax),%eax
c0104498:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010449d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01044a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044a3:	c1 e8 0c             	shr    $0xc,%eax
c01044a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01044a9:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01044ae:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01044b1:	72 23                	jb     c01044d6 <check_pgdir+0x20a>
c01044b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01044ba:	c7 44 24 08 00 9d 10 	movl   $0xc0109d00,0x8(%esp)
c01044c1:	c0 
c01044c2:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01044c9:	00 
c01044ca:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01044d1:	e8 2d bf ff ff       	call   c0100403 <__panic>
c01044d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044d9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01044de:	83 c0 04             	add    $0x4,%eax
c01044e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01044e4:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01044e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01044f0:	00 
c01044f1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01044f8:	00 
c01044f9:	89 04 24             	mov    %eax,(%esp)
c01044fc:	e8 93 f9 ff ff       	call   c0103e94 <get_pte>
c0104501:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104504:	74 24                	je     c010452a <check_pgdir+0x25e>
c0104506:	c7 44 24 0c 5c 9f 10 	movl   $0xc0109f5c,0xc(%esp)
c010450d:	c0 
c010450e:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104515:	c0 
c0104516:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c010451d:	00 
c010451e:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104525:	e8 d9 be ff ff       	call   c0100403 <__panic>

    p2 = alloc_page();
c010452a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104531:	e8 83 f2 ff ff       	call   c01037b9 <alloc_pages>
c0104536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104539:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c010453e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104545:	00 
c0104546:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010454d:	00 
c010454e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104551:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104555:	89 04 24             	mov    %eax,(%esp)
c0104558:	e8 70 fb ff ff       	call   c01040cd <page_insert>
c010455d:	85 c0                	test   %eax,%eax
c010455f:	74 24                	je     c0104585 <check_pgdir+0x2b9>
c0104561:	c7 44 24 0c 84 9f 10 	movl   $0xc0109f84,0xc(%esp)
c0104568:	c0 
c0104569:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104570:	c0 
c0104571:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0104578:	00 
c0104579:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104580:	e8 7e be ff ff       	call   c0100403 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104585:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c010458a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104591:	00 
c0104592:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104599:	00 
c010459a:	89 04 24             	mov    %eax,(%esp)
c010459d:	e8 f2 f8 ff ff       	call   c0103e94 <get_pte>
c01045a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01045a9:	75 24                	jne    c01045cf <check_pgdir+0x303>
c01045ab:	c7 44 24 0c bc 9f 10 	movl   $0xc0109fbc,0xc(%esp)
c01045b2:	c0 
c01045b3:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01045ba:	c0 
c01045bb:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c01045c2:	00 
c01045c3:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01045ca:	e8 34 be ff ff       	call   c0100403 <__panic>
    assert(*ptep & PTE_U);
c01045cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045d2:	8b 00                	mov    (%eax),%eax
c01045d4:	83 e0 04             	and    $0x4,%eax
c01045d7:	85 c0                	test   %eax,%eax
c01045d9:	75 24                	jne    c01045ff <check_pgdir+0x333>
c01045db:	c7 44 24 0c ec 9f 10 	movl   $0xc0109fec,0xc(%esp)
c01045e2:	c0 
c01045e3:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01045ea:	c0 
c01045eb:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c01045f2:	00 
c01045f3:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01045fa:	e8 04 be ff ff       	call   c0100403 <__panic>
    assert(*ptep & PTE_W);
c01045ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104602:	8b 00                	mov    (%eax),%eax
c0104604:	83 e0 02             	and    $0x2,%eax
c0104607:	85 c0                	test   %eax,%eax
c0104609:	75 24                	jne    c010462f <check_pgdir+0x363>
c010460b:	c7 44 24 0c fa 9f 10 	movl   $0xc0109ffa,0xc(%esp)
c0104612:	c0 
c0104613:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010461a:	c0 
c010461b:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0104622:	00 
c0104623:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010462a:	e8 d4 bd ff ff       	call   c0100403 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010462f:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104634:	8b 00                	mov    (%eax),%eax
c0104636:	83 e0 04             	and    $0x4,%eax
c0104639:	85 c0                	test   %eax,%eax
c010463b:	75 24                	jne    c0104661 <check_pgdir+0x395>
c010463d:	c7 44 24 0c 08 a0 10 	movl   $0xc010a008,0xc(%esp)
c0104644:	c0 
c0104645:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010464c:	c0 
c010464d:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0104654:	00 
c0104655:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010465c:	e8 a2 bd ff ff       	call   c0100403 <__panic>
    assert(page_ref(p2) == 1);
c0104661:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104664:	89 04 24             	mov    %eax,(%esp)
c0104667:	e8 48 ef ff ff       	call   c01035b4 <page_ref>
c010466c:	83 f8 01             	cmp    $0x1,%eax
c010466f:	74 24                	je     c0104695 <check_pgdir+0x3c9>
c0104671:	c7 44 24 0c 1e a0 10 	movl   $0xc010a01e,0xc(%esp)
c0104678:	c0 
c0104679:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104680:	c0 
c0104681:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c0104688:	00 
c0104689:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104690:	e8 6e bd ff ff       	call   c0100403 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104695:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c010469a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01046a1:	00 
c01046a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01046a9:	00 
c01046aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01046ad:	89 54 24 04          	mov    %edx,0x4(%esp)
c01046b1:	89 04 24             	mov    %eax,(%esp)
c01046b4:	e8 14 fa ff ff       	call   c01040cd <page_insert>
c01046b9:	85 c0                	test   %eax,%eax
c01046bb:	74 24                	je     c01046e1 <check_pgdir+0x415>
c01046bd:	c7 44 24 0c 30 a0 10 	movl   $0xc010a030,0xc(%esp)
c01046c4:	c0 
c01046c5:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01046cc:	c0 
c01046cd:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c01046d4:	00 
c01046d5:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01046dc:	e8 22 bd ff ff       	call   c0100403 <__panic>
    assert(page_ref(p1) == 2);
c01046e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e4:	89 04 24             	mov    %eax,(%esp)
c01046e7:	e8 c8 ee ff ff       	call   c01035b4 <page_ref>
c01046ec:	83 f8 02             	cmp    $0x2,%eax
c01046ef:	74 24                	je     c0104715 <check_pgdir+0x449>
c01046f1:	c7 44 24 0c 5c a0 10 	movl   $0xc010a05c,0xc(%esp)
c01046f8:	c0 
c01046f9:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104700:	c0 
c0104701:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c0104708:	00 
c0104709:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104710:	e8 ee bc ff ff       	call   c0100403 <__panic>
    assert(page_ref(p2) == 0);
c0104715:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104718:	89 04 24             	mov    %eax,(%esp)
c010471b:	e8 94 ee ff ff       	call   c01035b4 <page_ref>
c0104720:	85 c0                	test   %eax,%eax
c0104722:	74 24                	je     c0104748 <check_pgdir+0x47c>
c0104724:	c7 44 24 0c 6e a0 10 	movl   $0xc010a06e,0xc(%esp)
c010472b:	c0 
c010472c:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104733:	c0 
c0104734:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c010473b:	00 
c010473c:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104743:	e8 bb bc ff ff       	call   c0100403 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104748:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c010474d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104754:	00 
c0104755:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010475c:	00 
c010475d:	89 04 24             	mov    %eax,(%esp)
c0104760:	e8 2f f7 ff ff       	call   c0103e94 <get_pte>
c0104765:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104768:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010476c:	75 24                	jne    c0104792 <check_pgdir+0x4c6>
c010476e:	c7 44 24 0c bc 9f 10 	movl   $0xc0109fbc,0xc(%esp)
c0104775:	c0 
c0104776:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010477d:	c0 
c010477e:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c0104785:	00 
c0104786:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010478d:	e8 71 bc ff ff       	call   c0100403 <__panic>
    assert(pte2page(*ptep) == p1);
c0104792:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104795:	8b 00                	mov    (%eax),%eax
c0104797:	89 04 24             	mov    %eax,(%esp)
c010479a:	e8 bf ed ff ff       	call   c010355e <pte2page>
c010479f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01047a2:	74 24                	je     c01047c8 <check_pgdir+0x4fc>
c01047a4:	c7 44 24 0c 31 9f 10 	movl   $0xc0109f31,0xc(%esp)
c01047ab:	c0 
c01047ac:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01047b3:	c0 
c01047b4:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c01047bb:	00 
c01047bc:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01047c3:	e8 3b bc ff ff       	call   c0100403 <__panic>
    assert((*ptep & PTE_U) == 0);
c01047c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047cb:	8b 00                	mov    (%eax),%eax
c01047cd:	83 e0 04             	and    $0x4,%eax
c01047d0:	85 c0                	test   %eax,%eax
c01047d2:	74 24                	je     c01047f8 <check_pgdir+0x52c>
c01047d4:	c7 44 24 0c 80 a0 10 	movl   $0xc010a080,0xc(%esp)
c01047db:	c0 
c01047dc:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01047e3:	c0 
c01047e4:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01047eb:	00 
c01047ec:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01047f3:	e8 0b bc ff ff       	call   c0100403 <__panic>

    page_remove(boot_pgdir, 0x0);
c01047f8:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01047fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104804:	00 
c0104805:	89 04 24             	mov    %eax,(%esp)
c0104808:	e8 7b f8 ff ff       	call   c0104088 <page_remove>
    assert(page_ref(p1) == 1);
c010480d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104810:	89 04 24             	mov    %eax,(%esp)
c0104813:	e8 9c ed ff ff       	call   c01035b4 <page_ref>
c0104818:	83 f8 01             	cmp    $0x1,%eax
c010481b:	74 24                	je     c0104841 <check_pgdir+0x575>
c010481d:	c7 44 24 0c 47 9f 10 	movl   $0xc0109f47,0xc(%esp)
c0104824:	c0 
c0104825:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010482c:	c0 
c010482d:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c0104834:	00 
c0104835:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010483c:	e8 c2 bb ff ff       	call   c0100403 <__panic>
    assert(page_ref(p2) == 0);
c0104841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104844:	89 04 24             	mov    %eax,(%esp)
c0104847:	e8 68 ed ff ff       	call   c01035b4 <page_ref>
c010484c:	85 c0                	test   %eax,%eax
c010484e:	74 24                	je     c0104874 <check_pgdir+0x5a8>
c0104850:	c7 44 24 0c 6e a0 10 	movl   $0xc010a06e,0xc(%esp)
c0104857:	c0 
c0104858:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010485f:	c0 
c0104860:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0104867:	00 
c0104868:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010486f:	e8 8f bb ff ff       	call   c0100403 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104874:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104879:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104880:	00 
c0104881:	89 04 24             	mov    %eax,(%esp)
c0104884:	e8 ff f7 ff ff       	call   c0104088 <page_remove>
    assert(page_ref(p1) == 0);
c0104889:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010488c:	89 04 24             	mov    %eax,(%esp)
c010488f:	e8 20 ed ff ff       	call   c01035b4 <page_ref>
c0104894:	85 c0                	test   %eax,%eax
c0104896:	74 24                	je     c01048bc <check_pgdir+0x5f0>
c0104898:	c7 44 24 0c 95 a0 10 	movl   $0xc010a095,0xc(%esp)
c010489f:	c0 
c01048a0:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01048a7:	c0 
c01048a8:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c01048af:	00 
c01048b0:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01048b7:	e8 47 bb ff ff       	call   c0100403 <__panic>
    assert(page_ref(p2) == 0);
c01048bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048bf:	89 04 24             	mov    %eax,(%esp)
c01048c2:	e8 ed ec ff ff       	call   c01035b4 <page_ref>
c01048c7:	85 c0                	test   %eax,%eax
c01048c9:	74 24                	je     c01048ef <check_pgdir+0x623>
c01048cb:	c7 44 24 0c 6e a0 10 	movl   $0xc010a06e,0xc(%esp)
c01048d2:	c0 
c01048d3:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01048da:	c0 
c01048db:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c01048e2:	00 
c01048e3:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01048ea:	e8 14 bb ff ff       	call   c0100403 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01048ef:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01048f4:	8b 00                	mov    (%eax),%eax
c01048f6:	89 04 24             	mov    %eax,(%esp)
c01048f9:	e8 9e ec ff ff       	call   c010359c <pde2page>
c01048fe:	89 04 24             	mov    %eax,(%esp)
c0104901:	e8 ae ec ff ff       	call   c01035b4 <page_ref>
c0104906:	83 f8 01             	cmp    $0x1,%eax
c0104909:	74 24                	je     c010492f <check_pgdir+0x663>
c010490b:	c7 44 24 0c a8 a0 10 	movl   $0xc010a0a8,0xc(%esp)
c0104912:	c0 
c0104913:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c010491a:	c0 
c010491b:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0104922:	00 
c0104923:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c010492a:	e8 d4 ba ff ff       	call   c0100403 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c010492f:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104934:	8b 00                	mov    (%eax),%eax
c0104936:	89 04 24             	mov    %eax,(%esp)
c0104939:	e8 5e ec ff ff       	call   c010359c <pde2page>
c010493e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104945:	00 
c0104946:	89 04 24             	mov    %eax,(%esp)
c0104949:	e8 d6 ee ff ff       	call   c0103824 <free_pages>
    boot_pgdir[0] = 0;
c010494e:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104953:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104959:	c7 04 24 cf a0 10 c0 	movl   $0xc010a0cf,(%esp)
c0104960:	e8 47 b9 ff ff       	call   c01002ac <cprintf>
}
c0104965:	90                   	nop
c0104966:	c9                   	leave  
c0104967:	c3                   	ret    

c0104968 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104968:	55                   	push   %ebp
c0104969:	89 e5                	mov    %esp,%ebp
c010496b:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010496e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104975:	e9 ca 00 00 00       	jmp    c0104a44 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c010497a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010497d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104980:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104983:	c1 e8 0c             	shr    $0xc,%eax
c0104986:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104989:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c010498e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104991:	72 23                	jb     c01049b6 <check_boot_pgdir+0x4e>
c0104993:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104996:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010499a:	c7 44 24 08 00 9d 10 	movl   $0xc0109d00,0x8(%esp)
c01049a1:	c0 
c01049a2:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c01049a9:	00 
c01049aa:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c01049b1:	e8 4d ba ff ff       	call   c0100403 <__panic>
c01049b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049b9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01049be:	89 c2                	mov    %eax,%edx
c01049c0:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01049c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049cc:	00 
c01049cd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049d1:	89 04 24             	mov    %eax,(%esp)
c01049d4:	e8 bb f4 ff ff       	call   c0103e94 <get_pte>
c01049d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01049dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01049e0:	75 24                	jne    c0104a06 <check_boot_pgdir+0x9e>
c01049e2:	c7 44 24 0c ec a0 10 	movl   $0xc010a0ec,0xc(%esp)
c01049e9:	c0 
c01049ea:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c01049f1:	c0 
c01049f2:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c01049f9:	00 
c01049fa:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104a01:	e8 fd b9 ff ff       	call   c0100403 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104a06:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a09:	8b 00                	mov    (%eax),%eax
c0104a0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104a10:	89 c2                	mov    %eax,%edx
c0104a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a15:	39 c2                	cmp    %eax,%edx
c0104a17:	74 24                	je     c0104a3d <check_boot_pgdir+0xd5>
c0104a19:	c7 44 24 0c 29 a1 10 	movl   $0xc010a129,0xc(%esp)
c0104a20:	c0 
c0104a21:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104a28:	c0 
c0104a29:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
c0104a30:	00 
c0104a31:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104a38:	e8 c6 b9 ff ff       	call   c0100403 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0104a3d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104a47:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0104a4c:	39 c2                	cmp    %eax,%edx
c0104a4e:	0f 82 26 ff ff ff    	jb     c010497a <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104a54:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104a59:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104a5e:	8b 00                	mov    (%eax),%eax
c0104a60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104a65:	89 c2                	mov    %eax,%edx
c0104a67:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a6f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104a76:	77 23                	ja     c0104a9b <check_boot_pgdir+0x133>
c0104a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104a7f:	c7 44 24 08 24 9d 10 	movl   $0xc0109d24,0x8(%esp)
c0104a86:	c0 
c0104a87:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0104a8e:	00 
c0104a8f:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104a96:	e8 68 b9 ff ff       	call   c0100403 <__panic>
c0104a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a9e:	05 00 00 00 40       	add    $0x40000000,%eax
c0104aa3:	39 d0                	cmp    %edx,%eax
c0104aa5:	74 24                	je     c0104acb <check_boot_pgdir+0x163>
c0104aa7:	c7 44 24 0c 40 a1 10 	movl   $0xc010a140,0xc(%esp)
c0104aae:	c0 
c0104aaf:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104ab6:	c0 
c0104ab7:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0104abe:	00 
c0104abf:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104ac6:	e8 38 b9 ff ff       	call   c0100403 <__panic>

    assert(boot_pgdir[0] == 0);
c0104acb:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104ad0:	8b 00                	mov    (%eax),%eax
c0104ad2:	85 c0                	test   %eax,%eax
c0104ad4:	74 24                	je     c0104afa <check_boot_pgdir+0x192>
c0104ad6:	c7 44 24 0c 74 a1 10 	movl   $0xc010a174,0xc(%esp)
c0104add:	c0 
c0104ade:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104ae5:	c0 
c0104ae6:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0104aed:	00 
c0104aee:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104af5:	e8 09 b9 ff ff       	call   c0100403 <__panic>

    struct Page *p;
    p = alloc_page();
c0104afa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b01:	e8 b3 ec ff ff       	call   c01037b9 <alloc_pages>
c0104b06:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104b09:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104b0e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104b15:	00 
c0104b16:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104b1d:	00 
c0104b1e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104b21:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b25:	89 04 24             	mov    %eax,(%esp)
c0104b28:	e8 a0 f5 ff ff       	call   c01040cd <page_insert>
c0104b2d:	85 c0                	test   %eax,%eax
c0104b2f:	74 24                	je     c0104b55 <check_boot_pgdir+0x1ed>
c0104b31:	c7 44 24 0c 88 a1 10 	movl   $0xc010a188,0xc(%esp)
c0104b38:	c0 
c0104b39:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104b40:	c0 
c0104b41:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
c0104b48:	00 
c0104b49:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104b50:	e8 ae b8 ff ff       	call   c0100403 <__panic>
    assert(page_ref(p) == 1);
c0104b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b58:	89 04 24             	mov    %eax,(%esp)
c0104b5b:	e8 54 ea ff ff       	call   c01035b4 <page_ref>
c0104b60:	83 f8 01             	cmp    $0x1,%eax
c0104b63:	74 24                	je     c0104b89 <check_boot_pgdir+0x221>
c0104b65:	c7 44 24 0c b6 a1 10 	movl   $0xc010a1b6,0xc(%esp)
c0104b6c:	c0 
c0104b6d:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104b74:	c0 
c0104b75:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c0104b7c:	00 
c0104b7d:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104b84:	e8 7a b8 ff ff       	call   c0100403 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104b89:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104b8e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104b95:	00 
c0104b96:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104b9d:	00 
c0104b9e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104ba1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ba5:	89 04 24             	mov    %eax,(%esp)
c0104ba8:	e8 20 f5 ff ff       	call   c01040cd <page_insert>
c0104bad:	85 c0                	test   %eax,%eax
c0104baf:	74 24                	je     c0104bd5 <check_boot_pgdir+0x26d>
c0104bb1:	c7 44 24 0c c8 a1 10 	movl   $0xc010a1c8,0xc(%esp)
c0104bb8:	c0 
c0104bb9:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104bc0:	c0 
c0104bc1:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c0104bc8:	00 
c0104bc9:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104bd0:	e8 2e b8 ff ff       	call   c0100403 <__panic>
    assert(page_ref(p) == 2);
c0104bd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bd8:	89 04 24             	mov    %eax,(%esp)
c0104bdb:	e8 d4 e9 ff ff       	call   c01035b4 <page_ref>
c0104be0:	83 f8 02             	cmp    $0x2,%eax
c0104be3:	74 24                	je     c0104c09 <check_boot_pgdir+0x2a1>
c0104be5:	c7 44 24 0c ff a1 10 	movl   $0xc010a1ff,0xc(%esp)
c0104bec:	c0 
c0104bed:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104bf4:	c0 
c0104bf5:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c0104bfc:	00 
c0104bfd:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104c04:	e8 fa b7 ff ff       	call   c0100403 <__panic>

    const char *str = "ucore: Hello world!!";
c0104c09:	c7 45 e8 10 a2 10 c0 	movl   $0xc010a210,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0104c10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104c17:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104c1e:	e8 0b 3c 00 00       	call   c010882e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104c23:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0104c2a:	00 
c0104c2b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104c32:	e8 6e 3c 00 00       	call   c01088a5 <strcmp>
c0104c37:	85 c0                	test   %eax,%eax
c0104c39:	74 24                	je     c0104c5f <check_boot_pgdir+0x2f7>
c0104c3b:	c7 44 24 0c 28 a2 10 	movl   $0xc010a228,0xc(%esp)
c0104c42:	c0 
c0104c43:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104c4a:	c0 
c0104c4b:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
c0104c52:	00 
c0104c53:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104c5a:	e8 a4 b7 ff ff       	call   c0100403 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0104c5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c62:	89 04 24             	mov    %eax,(%esp)
c0104c65:	e8 56 e8 ff ff       	call   c01034c0 <page2kva>
c0104c6a:	05 00 01 00 00       	add    $0x100,%eax
c0104c6f:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0104c72:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104c79:	e8 5a 3b 00 00       	call   c01087d8 <strlen>
c0104c7e:	85 c0                	test   %eax,%eax
c0104c80:	74 24                	je     c0104ca6 <check_boot_pgdir+0x33e>
c0104c82:	c7 44 24 0c 60 a2 10 	movl   $0xc010a260,0xc(%esp)
c0104c89:	c0 
c0104c8a:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104c91:	c0 
c0104c92:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0104c99:	00 
c0104c9a:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104ca1:	e8 5d b7 ff ff       	call   c0100403 <__panic>

    free_page(p);
c0104ca6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104cad:	00 
c0104cae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cb1:	89 04 24             	mov    %eax,(%esp)
c0104cb4:	e8 6b eb ff ff       	call   c0103824 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0104cb9:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104cbe:	8b 00                	mov    (%eax),%eax
c0104cc0:	89 04 24             	mov    %eax,(%esp)
c0104cc3:	e8 d4 e8 ff ff       	call   c010359c <pde2page>
c0104cc8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ccf:	00 
c0104cd0:	89 04 24             	mov    %eax,(%esp)
c0104cd3:	e8 4c eb ff ff       	call   c0103824 <free_pages>
    boot_pgdir[0] = 0;
c0104cd8:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104cdd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104ce3:	c7 04 24 84 a2 10 c0 	movl   $0xc010a284,(%esp)
c0104cea:	e8 bd b5 ff ff       	call   c01002ac <cprintf>
}
c0104cef:	90                   	nop
c0104cf0:	c9                   	leave  
c0104cf1:	c3                   	ret    

c0104cf2 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104cf2:	55                   	push   %ebp
c0104cf3:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0104cf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cf8:	83 e0 04             	and    $0x4,%eax
c0104cfb:	85 c0                	test   %eax,%eax
c0104cfd:	74 04                	je     c0104d03 <perm2str+0x11>
c0104cff:	b0 75                	mov    $0x75,%al
c0104d01:	eb 02                	jmp    c0104d05 <perm2str+0x13>
c0104d03:	b0 2d                	mov    $0x2d,%al
c0104d05:	a2 08 60 12 c0       	mov    %al,0xc0126008
    str[1] = 'r';
c0104d0a:	c6 05 09 60 12 c0 72 	movb   $0x72,0xc0126009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104d11:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d14:	83 e0 02             	and    $0x2,%eax
c0104d17:	85 c0                	test   %eax,%eax
c0104d19:	74 04                	je     c0104d1f <perm2str+0x2d>
c0104d1b:	b0 77                	mov    $0x77,%al
c0104d1d:	eb 02                	jmp    c0104d21 <perm2str+0x2f>
c0104d1f:	b0 2d                	mov    $0x2d,%al
c0104d21:	a2 0a 60 12 c0       	mov    %al,0xc012600a
    str[3] = '\0';
c0104d26:	c6 05 0b 60 12 c0 00 	movb   $0x0,0xc012600b
    return str;
c0104d2d:	b8 08 60 12 c0       	mov    $0xc0126008,%eax
}
c0104d32:	5d                   	pop    %ebp
c0104d33:	c3                   	ret    

c0104d34 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0104d34:	55                   	push   %ebp
c0104d35:	89 e5                	mov    %esp,%ebp
c0104d37:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0104d3a:	8b 45 10             	mov    0x10(%ebp),%eax
c0104d3d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104d40:	72 0d                	jb     c0104d4f <get_pgtable_items+0x1b>
        return 0;
c0104d42:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d47:	e9 98 00 00 00       	jmp    c0104de4 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0104d4c:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0104d4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104d52:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104d55:	73 18                	jae    c0104d6f <get_pgtable_items+0x3b>
c0104d57:	8b 45 10             	mov    0x10(%ebp),%eax
c0104d5a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104d61:	8b 45 14             	mov    0x14(%ebp),%eax
c0104d64:	01 d0                	add    %edx,%eax
c0104d66:	8b 00                	mov    (%eax),%eax
c0104d68:	83 e0 01             	and    $0x1,%eax
c0104d6b:	85 c0                	test   %eax,%eax
c0104d6d:	74 dd                	je     c0104d4c <get_pgtable_items+0x18>
    }
    if (start < right) {
c0104d6f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104d72:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104d75:	73 68                	jae    c0104ddf <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0104d77:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104d7b:	74 08                	je     c0104d85 <get_pgtable_items+0x51>
            *left_store = start;
c0104d7d:	8b 45 18             	mov    0x18(%ebp),%eax
c0104d80:	8b 55 10             	mov    0x10(%ebp),%edx
c0104d83:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0104d85:	8b 45 10             	mov    0x10(%ebp),%eax
c0104d88:	8d 50 01             	lea    0x1(%eax),%edx
c0104d8b:	89 55 10             	mov    %edx,0x10(%ebp)
c0104d8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104d95:	8b 45 14             	mov    0x14(%ebp),%eax
c0104d98:	01 d0                	add    %edx,%eax
c0104d9a:	8b 00                	mov    (%eax),%eax
c0104d9c:	83 e0 07             	and    $0x7,%eax
c0104d9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104da2:	eb 03                	jmp    c0104da7 <get_pgtable_items+0x73>
            start ++;
c0104da4:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104da7:	8b 45 10             	mov    0x10(%ebp),%eax
c0104daa:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104dad:	73 1d                	jae    c0104dcc <get_pgtable_items+0x98>
c0104daf:	8b 45 10             	mov    0x10(%ebp),%eax
c0104db2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104db9:	8b 45 14             	mov    0x14(%ebp),%eax
c0104dbc:	01 d0                	add    %edx,%eax
c0104dbe:	8b 00                	mov    (%eax),%eax
c0104dc0:	83 e0 07             	and    $0x7,%eax
c0104dc3:	89 c2                	mov    %eax,%edx
c0104dc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104dc8:	39 c2                	cmp    %eax,%edx
c0104dca:	74 d8                	je     c0104da4 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0104dcc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104dd0:	74 08                	je     c0104dda <get_pgtable_items+0xa6>
            *right_store = start;
c0104dd2:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104dd5:	8b 55 10             	mov    0x10(%ebp),%edx
c0104dd8:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104ddd:	eb 05                	jmp    c0104de4 <get_pgtable_items+0xb0>
    }
    return 0;
c0104ddf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104de4:	c9                   	leave  
c0104de5:	c3                   	ret    

c0104de6 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0104de6:	55                   	push   %ebp
c0104de7:	89 e5                	mov    %esp,%ebp
c0104de9:	57                   	push   %edi
c0104dea:	56                   	push   %esi
c0104deb:	53                   	push   %ebx
c0104dec:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104def:	c7 04 24 a4 a2 10 c0 	movl   $0xc010a2a4,(%esp)
c0104df6:	e8 b1 b4 ff ff       	call   c01002ac <cprintf>
    size_t left, right = 0, perm;
c0104dfb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104e02:	e9 fa 00 00 00       	jmp    c0104f01 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e0a:	89 04 24             	mov    %eax,(%esp)
c0104e0d:	e8 e0 fe ff ff       	call   c0104cf2 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104e12:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104e15:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104e18:	29 d1                	sub    %edx,%ecx
c0104e1a:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104e1c:	89 d6                	mov    %edx,%esi
c0104e1e:	c1 e6 16             	shl    $0x16,%esi
c0104e21:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104e24:	89 d3                	mov    %edx,%ebx
c0104e26:	c1 e3 16             	shl    $0x16,%ebx
c0104e29:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104e2c:	89 d1                	mov    %edx,%ecx
c0104e2e:	c1 e1 16             	shl    $0x16,%ecx
c0104e31:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104e34:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104e37:	29 d7                	sub    %edx,%edi
c0104e39:	89 fa                	mov    %edi,%edx
c0104e3b:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104e3f:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104e43:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104e47:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104e4b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e4f:	c7 04 24 d5 a2 10 c0 	movl   $0xc010a2d5,(%esp)
c0104e56:	e8 51 b4 ff ff       	call   c01002ac <cprintf>
        size_t l, r = left * NPTEENTRY;
c0104e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e5e:	c1 e0 0a             	shl    $0xa,%eax
c0104e61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104e64:	eb 54                	jmp    c0104eba <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e69:	89 04 24             	mov    %eax,(%esp)
c0104e6c:	e8 81 fe ff ff       	call   c0104cf2 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104e71:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104e74:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104e77:	29 d1                	sub    %edx,%ecx
c0104e79:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104e7b:	89 d6                	mov    %edx,%esi
c0104e7d:	c1 e6 0c             	shl    $0xc,%esi
c0104e80:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104e83:	89 d3                	mov    %edx,%ebx
c0104e85:	c1 e3 0c             	shl    $0xc,%ebx
c0104e88:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104e8b:	89 d1                	mov    %edx,%ecx
c0104e8d:	c1 e1 0c             	shl    $0xc,%ecx
c0104e90:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104e93:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104e96:	29 d7                	sub    %edx,%edi
c0104e98:	89 fa                	mov    %edi,%edx
c0104e9a:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104e9e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104ea2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104ea6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104eaa:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104eae:	c7 04 24 f4 a2 10 c0 	movl   $0xc010a2f4,(%esp)
c0104eb5:	e8 f2 b3 ff ff       	call   c01002ac <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104eba:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104ebf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104ec2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ec5:	89 d3                	mov    %edx,%ebx
c0104ec7:	c1 e3 0a             	shl    $0xa,%ebx
c0104eca:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104ecd:	89 d1                	mov    %edx,%ecx
c0104ecf:	c1 e1 0a             	shl    $0xa,%ecx
c0104ed2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104ed5:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104ed9:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104edc:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104ee0:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104ee4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104ee8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104eec:	89 0c 24             	mov    %ecx,(%esp)
c0104eef:	e8 40 fe ff ff       	call   c0104d34 <get_pgtable_items>
c0104ef4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104ef7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104efb:	0f 85 65 ff ff ff    	jne    c0104e66 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104f01:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104f06:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f09:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104f0c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104f10:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104f13:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104f17:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104f1b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104f1f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104f26:	00 
c0104f27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104f2e:	e8 01 fe ff ff       	call   c0104d34 <get_pgtable_items>
c0104f33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104f36:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104f3a:	0f 85 c7 fe ff ff    	jne    c0104e07 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104f40:	c7 04 24 18 a3 10 c0 	movl   $0xc010a318,(%esp)
c0104f47:	e8 60 b3 ff ff       	call   c01002ac <cprintf>
}
c0104f4c:	90                   	nop
c0104f4d:	83 c4 4c             	add    $0x4c,%esp
c0104f50:	5b                   	pop    %ebx
c0104f51:	5e                   	pop    %esi
c0104f52:	5f                   	pop    %edi
c0104f53:	5d                   	pop    %ebp
c0104f54:	c3                   	ret    

c0104f55 <kmalloc>:

void *
kmalloc(size_t n) {
c0104f55:	55                   	push   %ebp
c0104f56:	89 e5                	mov    %esp,%ebp
c0104f58:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0104f5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0104f62:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0104f69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104f6d:	74 09                	je     c0104f78 <kmalloc+0x23>
c0104f6f:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0104f76:	76 24                	jbe    c0104f9c <kmalloc+0x47>
c0104f78:	c7 44 24 0c 49 a3 10 	movl   $0xc010a349,0xc(%esp)
c0104f7f:	c0 
c0104f80:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104f87:	c0 
c0104f88:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
c0104f8f:	00 
c0104f90:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104f97:	e8 67 b4 ff ff       	call   c0100403 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0104f9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f9f:	05 ff 0f 00 00       	add    $0xfff,%eax
c0104fa4:	c1 e8 0c             	shr    $0xc,%eax
c0104fa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0104faa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fad:	89 04 24             	mov    %eax,(%esp)
c0104fb0:	e8 04 e8 ff ff       	call   c01037b9 <alloc_pages>
c0104fb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0104fb8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104fbc:	75 24                	jne    c0104fe2 <kmalloc+0x8d>
c0104fbe:	c7 44 24 0c 60 a3 10 	movl   $0xc010a360,0xc(%esp)
c0104fc5:	c0 
c0104fc6:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0104fcd:	c0 
c0104fce:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
c0104fd5:	00 
c0104fd6:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0104fdd:	e8 21 b4 ff ff       	call   c0100403 <__panic>
    ptr=page2kva(base);
c0104fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fe5:	89 04 24             	mov    %eax,(%esp)
c0104fe8:	e8 d3 e4 ff ff       	call   c01034c0 <page2kva>
c0104fed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0104ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104ff3:	c9                   	leave  
c0104ff4:	c3                   	ret    

c0104ff5 <kfree>:

void 
kfree(void *ptr, size_t n) {
c0104ff5:	55                   	push   %ebp
c0104ff6:	89 e5                	mov    %esp,%ebp
c0104ff8:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0104ffb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104fff:	74 09                	je     c010500a <kfree+0x15>
c0105001:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0105008:	76 24                	jbe    c010502e <kfree+0x39>
c010500a:	c7 44 24 0c 49 a3 10 	movl   $0xc010a349,0xc(%esp)
c0105011:	c0 
c0105012:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0105019:	c0 
c010501a:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
c0105021:	00 
c0105022:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0105029:	e8 d5 b3 ff ff       	call   c0100403 <__panic>
    assert(ptr != NULL);
c010502e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105032:	75 24                	jne    c0105058 <kfree+0x63>
c0105034:	c7 44 24 0c 6d a3 10 	movl   $0xc010a36d,0xc(%esp)
c010503b:	c0 
c010503c:	c7 44 24 08 ed 9d 10 	movl   $0xc0109ded,0x8(%esp)
c0105043:	c0 
c0105044:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
c010504b:	00 
c010504c:	c7 04 24 c8 9d 10 c0 	movl   $0xc0109dc8,(%esp)
c0105053:	e8 ab b3 ff ff       	call   c0100403 <__panic>
    struct Page *base=NULL;
c0105058:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c010505f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105062:	05 ff 0f 00 00       	add    $0xfff,%eax
c0105067:	c1 e8 0c             	shr    $0xc,%eax
c010506a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c010506d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105070:	89 04 24             	mov    %eax,(%esp)
c0105073:	e8 9c e4 ff ff       	call   c0103514 <kva2page>
c0105078:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c010507b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010507e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105082:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105085:	89 04 24             	mov    %eax,(%esp)
c0105088:	e8 97 e7 ff ff       	call   c0103824 <free_pages>
}
c010508d:	90                   	nop
c010508e:	c9                   	leave  
c010508f:	c3                   	ret    

c0105090 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0105090:	55                   	push   %ebp
c0105091:	89 e5                	mov    %esp,%ebp
c0105093:	83 ec 10             	sub    $0x10,%esp
c0105096:	c7 45 fc 2c 60 12 c0 	movl   $0xc012602c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010509d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01050a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01050a3:	89 50 04             	mov    %edx,0x4(%eax)
c01050a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01050a9:	8b 50 04             	mov    0x4(%eax),%edx
c01050ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01050af:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01050b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01050b4:	c7 40 14 2c 60 12 c0 	movl   $0xc012602c,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01050bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01050c0:	c9                   	leave  
c01050c1:	c3                   	ret    

c01050c2 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01050c2:	55                   	push   %ebp
c01050c3:	89 e5                	mov    %esp,%ebp
c01050c5:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01050c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01050cb:	8b 40 14             	mov    0x14(%eax),%eax
c01050ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01050d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01050d4:	83 c0 14             	add    $0x14,%eax
c01050d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c01050da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01050de:	74 06                	je     c01050e6 <_fifo_map_swappable+0x24>
c01050e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050e4:	75 24                	jne    c010510a <_fifo_map_swappable+0x48>
c01050e6:	c7 44 24 0c 7c a3 10 	movl   $0xc010a37c,0xc(%esp)
c01050ed:	c0 
c01050ee:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c01050f5:	c0 
c01050f6:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c01050fd:	00 
c01050fe:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c0105105:	e8 f9 b2 ff ff       	call   c0100403 <__panic>
c010510a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010510d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105110:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105113:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105116:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010511c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010511f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0105122:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105125:	8b 40 04             	mov    0x4(%eax),%eax
c0105128:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010512b:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010512e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105131:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0105134:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105137:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010513a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010513d:	89 10                	mov    %edx,(%eax)
c010513f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105142:	8b 10                	mov    (%eax),%edx
c0105144:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105147:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010514a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010514d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105150:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105153:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105156:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105159:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);//在表头后加入新的page
    return 0;
c010515b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105160:	c9                   	leave  
c0105161:	c3                   	ret    

c0105162 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0105162:	55                   	push   %ebp
c0105163:	89 e5                	mov    %esp,%ebp
c0105165:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0105168:	8b 45 08             	mov    0x8(%ebp),%eax
c010516b:	8b 40 14             	mov    0x14(%eax),%eax
c010516e:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0105171:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105175:	75 24                	jne    c010519b <_fifo_swap_out_victim+0x39>
c0105177:	c7 44 24 0c c3 a3 10 	movl   $0xc010a3c3,0xc(%esp)
c010517e:	c0 
c010517f:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c0105186:	c0 
c0105187:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c010518e:	00 
c010518f:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c0105196:	e8 68 b2 ff ff       	call   c0100403 <__panic>
     assert(in_tick==0);
c010519b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010519f:	74 24                	je     c01051c5 <_fifo_swap_out_victim+0x63>
c01051a1:	c7 44 24 0c d0 a3 10 	movl   $0xc010a3d0,0xc(%esp)
c01051a8:	c0 
c01051a9:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c01051b0:	c0 
c01051b1:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01051b8:	00 
c01051b9:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01051c0:	e8 3e b2 ff ff       	call   c0100403 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *need_to_be_swap = head->prev;
c01051c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051c8:	8b 00                	mov    (%eax),%eax
c01051ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  	//用need_to_be_swap指示需要被换出的页
     assert(head!=need_to_be_swap);
c01051cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051d0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01051d3:	75 24                	jne    c01051f9 <_fifo_swap_out_victim+0x97>
c01051d5:	c7 44 24 0c db a3 10 	movl   $0xc010a3db,0xc(%esp)
c01051dc:	c0 
c01051dd:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c01051e4:	c0 
c01051e5:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c01051ec:	00 
c01051ed:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01051f4:	e8 0a b2 ff ff       	call   c0100403 <__panic>
     struct Page *p = le2page(need_to_be_swap, pra_page_link);
c01051f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051fc:	83 e8 14             	sub    $0x14,%eax
c01051ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105202:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105205:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105208:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010520b:	8b 40 04             	mov    0x4(%eax),%eax
c010520e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105211:	8b 12                	mov    (%edx),%edx
c0105213:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105216:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010521c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010521f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105222:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105225:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105228:	89 10                	mov    %edx,(%eax)
  	//le2page宏可以根据链表元素获得对应的Page指针p  
     list_del(need_to_be_swap); //将进来最早的页面从队列中删除
     assert(p !=NULL);
c010522a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010522e:	75 24                	jne    c0105254 <_fifo_swap_out_victim+0xf2>
c0105230:	c7 44 24 0c f1 a3 10 	movl   $0xc010a3f1,0xc(%esp)
c0105237:	c0 
c0105238:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c010523f:	c0 
c0105240:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
c0105247:	00 
c0105248:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c010524f:	e8 af b1 ff ff       	call   c0100403 <__panic>
     *ptr_page = p; //assign the value of *ptr_page to the addr of this page
c0105254:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105257:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010525a:	89 10                	mov    %edx,(%eax)
     return 0;
c010525c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105261:	c9                   	leave  
c0105262:	c3                   	ret    

c0105263 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0105263:	55                   	push   %ebp
c0105264:	89 e5                	mov    %esp,%ebp
c0105266:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0105269:	c7 04 24 fc a3 10 c0 	movl   $0xc010a3fc,(%esp)
c0105270:	e8 37 b0 ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0105275:	b8 00 30 00 00       	mov    $0x3000,%eax
c010527a:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c010527d:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105282:	83 f8 04             	cmp    $0x4,%eax
c0105285:	74 24                	je     c01052ab <_fifo_check_swap+0x48>
c0105287:	c7 44 24 0c 22 a4 10 	movl   $0xc010a422,0xc(%esp)
c010528e:	c0 
c010528f:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c0105296:	c0 
c0105297:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c010529e:	00 
c010529f:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01052a6:	e8 58 b1 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01052ab:	c7 04 24 34 a4 10 c0 	movl   $0xc010a434,(%esp)
c01052b2:	e8 f5 af ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01052b7:	b8 00 10 00 00       	mov    $0x1000,%eax
c01052bc:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01052bf:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01052c4:	83 f8 04             	cmp    $0x4,%eax
c01052c7:	74 24                	je     c01052ed <_fifo_check_swap+0x8a>
c01052c9:	c7 44 24 0c 22 a4 10 	movl   $0xc010a422,0xc(%esp)
c01052d0:	c0 
c01052d1:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c01052d8:	c0 
c01052d9:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c01052e0:	00 
c01052e1:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01052e8:	e8 16 b1 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01052ed:	c7 04 24 5c a4 10 c0 	movl   $0xc010a45c,(%esp)
c01052f4:	e8 b3 af ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01052f9:	b8 00 40 00 00       	mov    $0x4000,%eax
c01052fe:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0105301:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105306:	83 f8 04             	cmp    $0x4,%eax
c0105309:	74 24                	je     c010532f <_fifo_check_swap+0xcc>
c010530b:	c7 44 24 0c 22 a4 10 	movl   $0xc010a422,0xc(%esp)
c0105312:	c0 
c0105313:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c010531a:	c0 
c010531b:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0105322:	00 
c0105323:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c010532a:	e8 d4 b0 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010532f:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c0105336:	e8 71 af ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010533b:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105340:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0105343:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105348:	83 f8 04             	cmp    $0x4,%eax
c010534b:	74 24                	je     c0105371 <_fifo_check_swap+0x10e>
c010534d:	c7 44 24 0c 22 a4 10 	movl   $0xc010a422,0xc(%esp)
c0105354:	c0 
c0105355:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c010535c:	c0 
c010535d:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0105364:	00 
c0105365:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c010536c:	e8 92 b0 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0105371:	c7 04 24 ac a4 10 c0 	movl   $0xc010a4ac,(%esp)
c0105378:	e8 2f af ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c010537d:	b8 00 50 00 00       	mov    $0x5000,%eax
c0105382:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0105385:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010538a:	83 f8 05             	cmp    $0x5,%eax
c010538d:	74 24                	je     c01053b3 <_fifo_check_swap+0x150>
c010538f:	c7 44 24 0c d2 a4 10 	movl   $0xc010a4d2,0xc(%esp)
c0105396:	c0 
c0105397:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c010539e:	c0 
c010539f:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01053a6:	00 
c01053a7:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01053ae:	e8 50 b0 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01053b3:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c01053ba:	e8 ed ae ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01053bf:	b8 00 20 00 00       	mov    $0x2000,%eax
c01053c4:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01053c7:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01053cc:	83 f8 05             	cmp    $0x5,%eax
c01053cf:	74 24                	je     c01053f5 <_fifo_check_swap+0x192>
c01053d1:	c7 44 24 0c d2 a4 10 	movl   $0xc010a4d2,0xc(%esp)
c01053d8:	c0 
c01053d9:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c01053e0:	c0 
c01053e1:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01053e8:	00 
c01053e9:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01053f0:	e8 0e b0 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01053f5:	c7 04 24 34 a4 10 c0 	movl   $0xc010a434,(%esp)
c01053fc:	e8 ab ae ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0105401:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105406:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0105409:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010540e:	83 f8 06             	cmp    $0x6,%eax
c0105411:	74 24                	je     c0105437 <_fifo_check_swap+0x1d4>
c0105413:	c7 44 24 0c e1 a4 10 	movl   $0xc010a4e1,0xc(%esp)
c010541a:	c0 
c010541b:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c0105422:	c0 
c0105423:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c010542a:	00 
c010542b:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c0105432:	e8 cc af ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105437:	c7 04 24 84 a4 10 c0 	movl   $0xc010a484,(%esp)
c010543e:	e8 69 ae ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0105443:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105448:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c010544b:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105450:	83 f8 07             	cmp    $0x7,%eax
c0105453:	74 24                	je     c0105479 <_fifo_check_swap+0x216>
c0105455:	c7 44 24 0c f0 a4 10 	movl   $0xc010a4f0,0xc(%esp)
c010545c:	c0 
c010545d:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c0105464:	c0 
c0105465:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c010546c:	00 
c010546d:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c0105474:	e8 8a af ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0105479:	c7 04 24 fc a3 10 c0 	movl   $0xc010a3fc,(%esp)
c0105480:	e8 27 ae ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0105485:	b8 00 30 00 00       	mov    $0x3000,%eax
c010548a:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c010548d:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105492:	83 f8 08             	cmp    $0x8,%eax
c0105495:	74 24                	je     c01054bb <_fifo_check_swap+0x258>
c0105497:	c7 44 24 0c ff a4 10 	movl   $0xc010a4ff,0xc(%esp)
c010549e:	c0 
c010549f:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c01054a6:	c0 
c01054a7:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c01054ae:	00 
c01054af:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01054b6:	e8 48 af ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01054bb:	c7 04 24 5c a4 10 c0 	movl   $0xc010a45c,(%esp)
c01054c2:	e8 e5 ad ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01054c7:	b8 00 40 00 00       	mov    $0x4000,%eax
c01054cc:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01054cf:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01054d4:	83 f8 09             	cmp    $0x9,%eax
c01054d7:	74 24                	je     c01054fd <_fifo_check_swap+0x29a>
c01054d9:	c7 44 24 0c 0e a5 10 	movl   $0xc010a50e,0xc(%esp)
c01054e0:	c0 
c01054e1:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c01054e8:	c0 
c01054e9:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01054f0:	00 
c01054f1:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01054f8:	e8 06 af ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01054fd:	c7 04 24 ac a4 10 c0 	movl   $0xc010a4ac,(%esp)
c0105504:	e8 a3 ad ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0105509:	b8 00 50 00 00       	mov    $0x5000,%eax
c010550e:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0105511:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105516:	83 f8 0a             	cmp    $0xa,%eax
c0105519:	74 24                	je     c010553f <_fifo_check_swap+0x2dc>
c010551b:	c7 44 24 0c 1d a5 10 	movl   $0xc010a51d,0xc(%esp)
c0105522:	c0 
c0105523:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c010552a:	c0 
c010552b:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0105532:	00 
c0105533:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c010553a:	e8 c4 ae ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010553f:	c7 04 24 34 a4 10 c0 	movl   $0xc010a434,(%esp)
c0105546:	e8 61 ad ff ff       	call   c01002ac <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c010554b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105550:	0f b6 00             	movzbl (%eax),%eax
c0105553:	3c 0a                	cmp    $0xa,%al
c0105555:	74 24                	je     c010557b <_fifo_check_swap+0x318>
c0105557:	c7 44 24 0c 30 a5 10 	movl   $0xc010a530,0xc(%esp)
c010555e:	c0 
c010555f:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c0105566:	c0 
c0105567:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c010556e:	00 
c010556f:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c0105576:	e8 88 ae ff ff       	call   c0100403 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c010557b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105580:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0105583:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105588:	83 f8 0b             	cmp    $0xb,%eax
c010558b:	74 24                	je     c01055b1 <_fifo_check_swap+0x34e>
c010558d:	c7 44 24 0c 51 a5 10 	movl   $0xc010a551,0xc(%esp)
c0105594:	c0 
c0105595:	c7 44 24 08 9a a3 10 	movl   $0xc010a39a,0x8(%esp)
c010559c:	c0 
c010559d:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c01055a4:	00 
c01055a5:	c7 04 24 af a3 10 c0 	movl   $0xc010a3af,(%esp)
c01055ac:	e8 52 ae ff ff       	call   c0100403 <__panic>
    return 0;
c01055b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01055b6:	c9                   	leave  
c01055b7:	c3                   	ret    

c01055b8 <_fifo_init>:


static int
_fifo_init(void)
{
c01055b8:	55                   	push   %ebp
c01055b9:	89 e5                	mov    %esp,%ebp
    return 0;
c01055bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01055c0:	5d                   	pop    %ebp
c01055c1:	c3                   	ret    

c01055c2 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01055c2:	55                   	push   %ebp
c01055c3:	89 e5                	mov    %esp,%ebp
    return 0;
c01055c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01055ca:	5d                   	pop    %ebp
c01055cb:	c3                   	ret    

c01055cc <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01055cc:	55                   	push   %ebp
c01055cd:	89 e5                	mov    %esp,%ebp
c01055cf:	b8 00 00 00 00       	mov    $0x0,%eax
c01055d4:	5d                   	pop    %ebp
c01055d5:	c3                   	ret    

c01055d6 <pa2page>:
pa2page(uintptr_t pa) {
c01055d6:	55                   	push   %ebp
c01055d7:	89 e5                	mov    %esp,%ebp
c01055d9:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01055dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01055df:	c1 e8 0c             	shr    $0xc,%eax
c01055e2:	89 c2                	mov    %eax,%edx
c01055e4:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01055e9:	39 c2                	cmp    %eax,%edx
c01055eb:	72 1c                	jb     c0105609 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01055ed:	c7 44 24 08 74 a5 10 	movl   $0xc010a574,0x8(%esp)
c01055f4:	c0 
c01055f5:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01055fc:	00 
c01055fd:	c7 04 24 93 a5 10 c0 	movl   $0xc010a593,(%esp)
c0105604:	e8 fa ad ff ff       	call   c0100403 <__panic>
    return &pages[PPN(pa)];
c0105609:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c010560e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105611:	c1 ea 0c             	shr    $0xc,%edx
c0105614:	c1 e2 05             	shl    $0x5,%edx
c0105617:	01 d0                	add    %edx,%eax
}
c0105619:	c9                   	leave  
c010561a:	c3                   	ret    

c010561b <pde2page>:
pde2page(pde_t pde) {
c010561b:	55                   	push   %ebp
c010561c:	89 e5                	mov    %esp,%ebp
c010561e:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0105621:	8b 45 08             	mov    0x8(%ebp),%eax
c0105624:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105629:	89 04 24             	mov    %eax,(%esp)
c010562c:	e8 a5 ff ff ff       	call   c01055d6 <pa2page>
}
c0105631:	c9                   	leave  
c0105632:	c3                   	ret    

c0105633 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0105633:	55                   	push   %ebp
c0105634:	89 e5                	mov    %esp,%ebp
c0105636:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0105639:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0105640:	e8 10 f9 ff ff       	call   c0104f55 <kmalloc>
c0105645:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0105648:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010564c:	74 58                	je     c01056a6 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c010564e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105651:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c0105654:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105657:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010565a:	89 50 04             	mov    %edx,0x4(%eax)
c010565d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105660:	8b 50 04             	mov    0x4(%eax),%edx
c0105663:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105666:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0105668:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010566b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0105672:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105675:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010567f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0105686:	a1 10 60 12 c0       	mov    0xc0126010,%eax
c010568b:	85 c0                	test   %eax,%eax
c010568d:	74 0d                	je     c010569c <mm_create+0x69>
c010568f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105692:	89 04 24             	mov    %eax,(%esp)
c0105695:	e8 e3 0d 00 00       	call   c010647d <swap_init_mm>
c010569a:	eb 0a                	jmp    c01056a6 <mm_create+0x73>
        else mm->sm_priv = NULL;
c010569c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010569f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01056a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01056a9:	c9                   	leave  
c01056aa:	c3                   	ret    

c01056ab <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01056ab:	55                   	push   %ebp
c01056ac:	89 e5                	mov    %esp,%ebp
c01056ae:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01056b1:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01056b8:	e8 98 f8 ff ff       	call   c0104f55 <kmalloc>
c01056bd:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01056c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01056c4:	74 1b                	je     c01056e1 <vma_create+0x36>
        vma->vm_start = vm_start;
c01056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056c9:	8b 55 08             	mov    0x8(%ebp),%edx
c01056cc:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01056cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056d2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01056d5:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01056d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056db:	8b 55 10             	mov    0x10(%ebp),%edx
c01056de:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01056e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01056e4:	c9                   	leave  
c01056e5:	c3                   	ret    

c01056e6 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01056e6:	55                   	push   %ebp
c01056e7:	89 e5                	mov    %esp,%ebp
c01056e9:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01056ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01056f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01056f7:	0f 84 95 00 00 00    	je     c0105792 <find_vma+0xac>
        vma = mm->mmap_cache;
c01056fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105700:	8b 40 08             	mov    0x8(%eax),%eax
c0105703:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0105706:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010570a:	74 16                	je     c0105722 <find_vma+0x3c>
c010570c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010570f:	8b 40 04             	mov    0x4(%eax),%eax
c0105712:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105715:	72 0b                	jb     c0105722 <find_vma+0x3c>
c0105717:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010571a:	8b 40 08             	mov    0x8(%eax),%eax
c010571d:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105720:	72 61                	jb     c0105783 <find_vma+0x9d>
                bool found = 0;
c0105722:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0105729:	8b 45 08             	mov    0x8(%ebp),%eax
c010572c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010572f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105732:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0105735:	eb 28                	jmp    c010575f <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0105737:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010573a:	83 e8 10             	sub    $0x10,%eax
c010573d:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0105740:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105743:	8b 40 04             	mov    0x4(%eax),%eax
c0105746:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105749:	72 14                	jb     c010575f <find_vma+0x79>
c010574b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010574e:	8b 40 08             	mov    0x8(%eax),%eax
c0105751:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105754:	73 09                	jae    c010575f <find_vma+0x79>
                        found = 1;
c0105756:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c010575d:	eb 17                	jmp    c0105776 <find_vma+0x90>
c010575f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105762:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c0105765:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105768:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c010576b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010576e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105771:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105774:	75 c1                	jne    c0105737 <find_vma+0x51>
                    }
                }
                if (!found) {
c0105776:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010577a:	75 07                	jne    c0105783 <find_vma+0x9d>
                    vma = NULL;
c010577c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0105783:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105787:	74 09                	je     c0105792 <find_vma+0xac>
            mm->mmap_cache = vma;
c0105789:	8b 45 08             	mov    0x8(%ebp),%eax
c010578c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010578f:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0105792:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105795:	c9                   	leave  
c0105796:	c3                   	ret    

c0105797 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0105797:	55                   	push   %ebp
c0105798:	89 e5                	mov    %esp,%ebp
c010579a:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c010579d:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a0:	8b 50 04             	mov    0x4(%eax),%edx
c01057a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a6:	8b 40 08             	mov    0x8(%eax),%eax
c01057a9:	39 c2                	cmp    %eax,%edx
c01057ab:	72 24                	jb     c01057d1 <check_vma_overlap+0x3a>
c01057ad:	c7 44 24 0c a1 a5 10 	movl   $0xc010a5a1,0xc(%esp)
c01057b4:	c0 
c01057b5:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c01057bc:	c0 
c01057bd:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01057c4:	00 
c01057c5:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c01057cc:	e8 32 ac ff ff       	call   c0100403 <__panic>
    assert(prev->vm_end <= next->vm_start);
c01057d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d4:	8b 50 08             	mov    0x8(%eax),%edx
c01057d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057da:	8b 40 04             	mov    0x4(%eax),%eax
c01057dd:	39 c2                	cmp    %eax,%edx
c01057df:	76 24                	jbe    c0105805 <check_vma_overlap+0x6e>
c01057e1:	c7 44 24 0c e4 a5 10 	movl   $0xc010a5e4,0xc(%esp)
c01057e8:	c0 
c01057e9:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c01057f0:	c0 
c01057f1:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c01057f8:	00 
c01057f9:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105800:	e8 fe ab ff ff       	call   c0100403 <__panic>
    assert(next->vm_start < next->vm_end);
c0105805:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105808:	8b 50 04             	mov    0x4(%eax),%edx
c010580b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010580e:	8b 40 08             	mov    0x8(%eax),%eax
c0105811:	39 c2                	cmp    %eax,%edx
c0105813:	72 24                	jb     c0105839 <check_vma_overlap+0xa2>
c0105815:	c7 44 24 0c 03 a6 10 	movl   $0xc010a603,0xc(%esp)
c010581c:	c0 
c010581d:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105824:	c0 
c0105825:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c010582c:	00 
c010582d:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105834:	e8 ca ab ff ff       	call   c0100403 <__panic>
}
c0105839:	90                   	nop
c010583a:	c9                   	leave  
c010583b:	c3                   	ret    

c010583c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010583c:	55                   	push   %ebp
c010583d:	89 e5                	mov    %esp,%ebp
c010583f:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0105842:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105845:	8b 50 04             	mov    0x4(%eax),%edx
c0105848:	8b 45 0c             	mov    0xc(%ebp),%eax
c010584b:	8b 40 08             	mov    0x8(%eax),%eax
c010584e:	39 c2                	cmp    %eax,%edx
c0105850:	72 24                	jb     c0105876 <insert_vma_struct+0x3a>
c0105852:	c7 44 24 0c 21 a6 10 	movl   $0xc010a621,0xc(%esp)
c0105859:	c0 
c010585a:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105861:	c0 
c0105862:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0105869:	00 
c010586a:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105871:	e8 8d ab ff ff       	call   c0100403 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0105876:	8b 45 08             	mov    0x8(%ebp),%eax
c0105879:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010587c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010587f:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0105882:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105885:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0105888:	eb 1f                	jmp    c01058a9 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010588a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010588d:	83 e8 10             	sub    $0x10,%eax
c0105890:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0105893:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105896:	8b 50 04             	mov    0x4(%eax),%edx
c0105899:	8b 45 0c             	mov    0xc(%ebp),%eax
c010589c:	8b 40 04             	mov    0x4(%eax),%eax
c010589f:	39 c2                	cmp    %eax,%edx
c01058a1:	77 1f                	ja     c01058c2 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c01058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01058a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01058af:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058b2:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01058b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058bb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01058be:	75 ca                	jne    c010588a <insert_vma_struct+0x4e>
c01058c0:	eb 01                	jmp    c01058c3 <insert_vma_struct+0x87>
                break;
c01058c2:	90                   	nop
c01058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01058c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058cc:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c01058cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058d5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01058d8:	74 15                	je     c01058ef <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01058da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058dd:	8d 50 f0             	lea    -0x10(%eax),%edx
c01058e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e7:	89 14 24             	mov    %edx,(%esp)
c01058ea:	e8 a8 fe ff ff       	call   c0105797 <check_vma_overlap>
    }
    if (le_next != list) {
c01058ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058f2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01058f5:	74 15                	je     c010590c <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01058f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058fa:	83 e8 10             	sub    $0x10,%eax
c01058fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105901:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105904:	89 04 24             	mov    %eax,(%esp)
c0105907:	e8 8b fe ff ff       	call   c0105797 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010590c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010590f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105912:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0105914:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105917:	8d 50 10             	lea    0x10(%eax),%edx
c010591a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010591d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105920:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0105923:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105926:	8b 40 04             	mov    0x4(%eax),%eax
c0105929:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010592c:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010592f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105932:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105935:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0105938:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010593b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010593e:	89 10                	mov    %edx,(%eax)
c0105940:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105943:	8b 10                	mov    (%eax),%edx
c0105945:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105948:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010594b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010594e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105951:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105954:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105957:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010595a:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c010595c:	8b 45 08             	mov    0x8(%ebp),%eax
c010595f:	8b 40 10             	mov    0x10(%eax),%eax
c0105962:	8d 50 01             	lea    0x1(%eax),%edx
c0105965:	8b 45 08             	mov    0x8(%ebp),%eax
c0105968:	89 50 10             	mov    %edx,0x10(%eax)
}
c010596b:	90                   	nop
c010596c:	c9                   	leave  
c010596d:	c3                   	ret    

c010596e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c010596e:	55                   	push   %ebp
c010596f:	89 e5                	mov    %esp,%ebp
c0105971:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0105974:	8b 45 08             	mov    0x8(%ebp),%eax
c0105977:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010597a:	eb 3e                	jmp    c01059ba <mm_destroy+0x4c>
c010597c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010597f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105982:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105985:	8b 40 04             	mov    0x4(%eax),%eax
c0105988:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010598b:	8b 12                	mov    (%edx),%edx
c010598d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105990:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c0105993:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105996:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105999:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010599c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010599f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01059a2:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c01059a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059a7:	83 e8 10             	sub    $0x10,%eax
c01059aa:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01059b1:	00 
c01059b2:	89 04 24             	mov    %eax,(%esp)
c01059b5:	e8 3b f6 ff ff       	call   c0104ff5 <kfree>
c01059ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01059c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059c3:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c01059c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01059cf:	75 ab                	jne    c010597c <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c01059d1:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01059d8:	00 
c01059d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01059dc:	89 04 24             	mov    %eax,(%esp)
c01059df:	e8 11 f6 ff ff       	call   c0104ff5 <kfree>
    mm=NULL;
c01059e4:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01059eb:	90                   	nop
c01059ec:	c9                   	leave  
c01059ed:	c3                   	ret    

c01059ee <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01059ee:	55                   	push   %ebp
c01059ef:	89 e5                	mov    %esp,%ebp
c01059f1:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01059f4:	e8 03 00 00 00       	call   c01059fc <check_vmm>
}
c01059f9:	90                   	nop
c01059fa:	c9                   	leave  
c01059fb:	c3                   	ret    

c01059fc <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01059fc:	55                   	push   %ebp
c01059fd:	89 e5                	mov    %esp,%ebp
c01059ff:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105a02:	e8 50 de ff ff       	call   c0103857 <nr_free_pages>
c0105a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0105a0a:	e8 42 00 00 00       	call   c0105a51 <check_vma_struct>
    check_pgfault();
c0105a0f:	e8 fd 04 00 00       	call   c0105f11 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0105a14:	e8 3e de ff ff       	call   c0103857 <nr_free_pages>
c0105a19:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105a1c:	74 24                	je     c0105a42 <check_vmm+0x46>
c0105a1e:	c7 44 24 0c 40 a6 10 	movl   $0xc010a640,0xc(%esp)
c0105a25:	c0 
c0105a26:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105a2d:	c0 
c0105a2e:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0105a35:	00 
c0105a36:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105a3d:	e8 c1 a9 ff ff       	call   c0100403 <__panic>

    cprintf("check_vmm() succeeded.\n");
c0105a42:	c7 04 24 67 a6 10 c0 	movl   $0xc010a667,(%esp)
c0105a49:	e8 5e a8 ff ff       	call   c01002ac <cprintf>
}
c0105a4e:	90                   	nop
c0105a4f:	c9                   	leave  
c0105a50:	c3                   	ret    

c0105a51 <check_vma_struct>:

static void
check_vma_struct(void) {
c0105a51:	55                   	push   %ebp
c0105a52:	89 e5                	mov    %esp,%ebp
c0105a54:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105a57:	e8 fb dd ff ff       	call   c0103857 <nr_free_pages>
c0105a5c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0105a5f:	e8 cf fb ff ff       	call   c0105633 <mm_create>
c0105a64:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0105a67:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a6b:	75 24                	jne    c0105a91 <check_vma_struct+0x40>
c0105a6d:	c7 44 24 0c 7f a6 10 	movl   $0xc010a67f,0xc(%esp)
c0105a74:	c0 
c0105a75:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105a7c:	c0 
c0105a7d:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c0105a84:	00 
c0105a85:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105a8c:	e8 72 a9 ff ff       	call   c0100403 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0105a91:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0105a98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105a9b:	89 d0                	mov    %edx,%eax
c0105a9d:	c1 e0 02             	shl    $0x2,%eax
c0105aa0:	01 d0                	add    %edx,%eax
c0105aa2:	01 c0                	add    %eax,%eax
c0105aa4:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0105aa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105aad:	eb 6f                	jmp    c0105b1e <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0105aaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ab2:	89 d0                	mov    %edx,%eax
c0105ab4:	c1 e0 02             	shl    $0x2,%eax
c0105ab7:	01 d0                	add    %edx,%eax
c0105ab9:	83 c0 02             	add    $0x2,%eax
c0105abc:	89 c1                	mov    %eax,%ecx
c0105abe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ac1:	89 d0                	mov    %edx,%eax
c0105ac3:	c1 e0 02             	shl    $0x2,%eax
c0105ac6:	01 d0                	add    %edx,%eax
c0105ac8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105acf:	00 
c0105ad0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105ad4:	89 04 24             	mov    %eax,(%esp)
c0105ad7:	e8 cf fb ff ff       	call   c01056ab <vma_create>
c0105adc:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0105adf:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105ae3:	75 24                	jne    c0105b09 <check_vma_struct+0xb8>
c0105ae5:	c7 44 24 0c 8a a6 10 	movl   $0xc010a68a,0xc(%esp)
c0105aec:	c0 
c0105aed:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105af4:	c0 
c0105af5:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0105afc:	00 
c0105afd:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105b04:	e8 fa a8 ff ff       	call   c0100403 <__panic>
        insert_vma_struct(mm, vma);
c0105b09:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b13:	89 04 24             	mov    %eax,(%esp)
c0105b16:	e8 21 fd ff ff       	call   c010583c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0105b1b:	ff 4d f4             	decl   -0xc(%ebp)
c0105b1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105b22:	7f 8b                	jg     c0105aaf <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0105b24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b27:	40                   	inc    %eax
c0105b28:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b2b:	eb 6f                	jmp    c0105b9c <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0105b2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b30:	89 d0                	mov    %edx,%eax
c0105b32:	c1 e0 02             	shl    $0x2,%eax
c0105b35:	01 d0                	add    %edx,%eax
c0105b37:	83 c0 02             	add    $0x2,%eax
c0105b3a:	89 c1                	mov    %eax,%ecx
c0105b3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b3f:	89 d0                	mov    %edx,%eax
c0105b41:	c1 e0 02             	shl    $0x2,%eax
c0105b44:	01 d0                	add    %edx,%eax
c0105b46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b4d:	00 
c0105b4e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105b52:	89 04 24             	mov    %eax,(%esp)
c0105b55:	e8 51 fb ff ff       	call   c01056ab <vma_create>
c0105b5a:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0105b5d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105b61:	75 24                	jne    c0105b87 <check_vma_struct+0x136>
c0105b63:	c7 44 24 0c 8a a6 10 	movl   $0xc010a68a,0xc(%esp)
c0105b6a:	c0 
c0105b6b:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105b72:	c0 
c0105b73:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0105b7a:	00 
c0105b7b:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105b82:	e8 7c a8 ff ff       	call   c0100403 <__panic>
        insert_vma_struct(mm, vma);
c0105b87:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b91:	89 04 24             	mov    %eax,(%esp)
c0105b94:	e8 a3 fc ff ff       	call   c010583c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0105b99:	ff 45 f4             	incl   -0xc(%ebp)
c0105b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b9f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105ba2:	7e 89                	jle    c0105b2d <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0105ba4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ba7:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105baa:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105bad:	8b 40 04             	mov    0x4(%eax),%eax
c0105bb0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0105bb3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0105bba:	e9 96 00 00 00       	jmp    c0105c55 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0105bbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bc2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105bc5:	75 24                	jne    c0105beb <check_vma_struct+0x19a>
c0105bc7:	c7 44 24 0c 96 a6 10 	movl   $0xc010a696,0xc(%esp)
c0105bce:	c0 
c0105bcf:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105bd6:	c0 
c0105bd7:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0105bde:	00 
c0105bdf:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105be6:	e8 18 a8 ff ff       	call   c0100403 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0105beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bee:	83 e8 10             	sub    $0x10,%eax
c0105bf1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0105bf4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105bf7:	8b 48 04             	mov    0x4(%eax),%ecx
c0105bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105bfd:	89 d0                	mov    %edx,%eax
c0105bff:	c1 e0 02             	shl    $0x2,%eax
c0105c02:	01 d0                	add    %edx,%eax
c0105c04:	39 c1                	cmp    %eax,%ecx
c0105c06:	75 17                	jne    c0105c1f <check_vma_struct+0x1ce>
c0105c08:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105c0b:	8b 48 08             	mov    0x8(%eax),%ecx
c0105c0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c11:	89 d0                	mov    %edx,%eax
c0105c13:	c1 e0 02             	shl    $0x2,%eax
c0105c16:	01 d0                	add    %edx,%eax
c0105c18:	83 c0 02             	add    $0x2,%eax
c0105c1b:	39 c1                	cmp    %eax,%ecx
c0105c1d:	74 24                	je     c0105c43 <check_vma_struct+0x1f2>
c0105c1f:	c7 44 24 0c b0 a6 10 	movl   $0xc010a6b0,0xc(%esp)
c0105c26:	c0 
c0105c27:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105c2e:	c0 
c0105c2f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0105c36:	00 
c0105c37:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105c3e:	e8 c0 a7 ff ff       	call   c0100403 <__panic>
c0105c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c46:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0105c49:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105c4c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0105c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0105c52:	ff 45 f4             	incl   -0xc(%ebp)
c0105c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c58:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105c5b:	0f 8e 5e ff ff ff    	jle    c0105bbf <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0105c61:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0105c68:	e9 cb 01 00 00       	jmp    c0105e38 <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0105c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c74:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c77:	89 04 24             	mov    %eax,(%esp)
c0105c7a:	e8 67 fa ff ff       	call   c01056e6 <find_vma>
c0105c7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0105c82:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105c86:	75 24                	jne    c0105cac <check_vma_struct+0x25b>
c0105c88:	c7 44 24 0c e5 a6 10 	movl   $0xc010a6e5,0xc(%esp)
c0105c8f:	c0 
c0105c90:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105c97:	c0 
c0105c98:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0105c9f:	00 
c0105ca0:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105ca7:	e8 57 a7 ff ff       	call   c0100403 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105caf:	40                   	inc    %eax
c0105cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cb7:	89 04 24             	mov    %eax,(%esp)
c0105cba:	e8 27 fa ff ff       	call   c01056e6 <find_vma>
c0105cbf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0105cc2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0105cc6:	75 24                	jne    c0105cec <check_vma_struct+0x29b>
c0105cc8:	c7 44 24 0c f2 a6 10 	movl   $0xc010a6f2,0xc(%esp)
c0105ccf:	c0 
c0105cd0:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105cd7:	c0 
c0105cd8:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0105cdf:	00 
c0105ce0:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105ce7:	e8 17 a7 ff ff       	call   c0100403 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0105cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cef:	83 c0 02             	add    $0x2,%eax
c0105cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cf9:	89 04 24             	mov    %eax,(%esp)
c0105cfc:	e8 e5 f9 ff ff       	call   c01056e6 <find_vma>
c0105d01:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0105d04:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0105d08:	74 24                	je     c0105d2e <check_vma_struct+0x2dd>
c0105d0a:	c7 44 24 0c ff a6 10 	movl   $0xc010a6ff,0xc(%esp)
c0105d11:	c0 
c0105d12:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105d19:	c0 
c0105d1a:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0105d21:	00 
c0105d22:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105d29:	e8 d5 a6 ff ff       	call   c0100403 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0105d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d31:	83 c0 03             	add    $0x3,%eax
c0105d34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d3b:	89 04 24             	mov    %eax,(%esp)
c0105d3e:	e8 a3 f9 ff ff       	call   c01056e6 <find_vma>
c0105d43:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0105d46:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105d4a:	74 24                	je     c0105d70 <check_vma_struct+0x31f>
c0105d4c:	c7 44 24 0c 0c a7 10 	movl   $0xc010a70c,0xc(%esp)
c0105d53:	c0 
c0105d54:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105d5b:	c0 
c0105d5c:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0105d63:	00 
c0105d64:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105d6b:	e8 93 a6 ff ff       	call   c0100403 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0105d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d73:	83 c0 04             	add    $0x4,%eax
c0105d76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d7d:	89 04 24             	mov    %eax,(%esp)
c0105d80:	e8 61 f9 ff ff       	call   c01056e6 <find_vma>
c0105d85:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0105d88:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0105d8c:	74 24                	je     c0105db2 <check_vma_struct+0x361>
c0105d8e:	c7 44 24 0c 19 a7 10 	movl   $0xc010a719,0xc(%esp)
c0105d95:	c0 
c0105d96:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105d9d:	c0 
c0105d9e:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0105da5:	00 
c0105da6:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105dad:	e8 51 a6 ff ff       	call   c0100403 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0105db2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105db5:	8b 50 04             	mov    0x4(%eax),%edx
c0105db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dbb:	39 c2                	cmp    %eax,%edx
c0105dbd:	75 10                	jne    c0105dcf <check_vma_struct+0x37e>
c0105dbf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105dc2:	8b 40 08             	mov    0x8(%eax),%eax
c0105dc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105dc8:	83 c2 02             	add    $0x2,%edx
c0105dcb:	39 d0                	cmp    %edx,%eax
c0105dcd:	74 24                	je     c0105df3 <check_vma_struct+0x3a2>
c0105dcf:	c7 44 24 0c 28 a7 10 	movl   $0xc010a728,0xc(%esp)
c0105dd6:	c0 
c0105dd7:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105dde:	c0 
c0105ddf:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0105de6:	00 
c0105de7:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105dee:	e8 10 a6 ff ff       	call   c0100403 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0105df3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105df6:	8b 50 04             	mov    0x4(%eax),%edx
c0105df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dfc:	39 c2                	cmp    %eax,%edx
c0105dfe:	75 10                	jne    c0105e10 <check_vma_struct+0x3bf>
c0105e00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105e03:	8b 40 08             	mov    0x8(%eax),%eax
c0105e06:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e09:	83 c2 02             	add    $0x2,%edx
c0105e0c:	39 d0                	cmp    %edx,%eax
c0105e0e:	74 24                	je     c0105e34 <check_vma_struct+0x3e3>
c0105e10:	c7 44 24 0c 58 a7 10 	movl   $0xc010a758,0xc(%esp)
c0105e17:	c0 
c0105e18:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105e1f:	c0 
c0105e20:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0105e27:	00 
c0105e28:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105e2f:	e8 cf a5 ff ff       	call   c0100403 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0105e34:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0105e38:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105e3b:	89 d0                	mov    %edx,%eax
c0105e3d:	c1 e0 02             	shl    $0x2,%eax
c0105e40:	01 d0                	add    %edx,%eax
c0105e42:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105e45:	0f 8e 22 fe ff ff    	jle    c0105c6d <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c0105e4b:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0105e52:	eb 6f                	jmp    c0105ec3 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0105e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e5e:	89 04 24             	mov    %eax,(%esp)
c0105e61:	e8 80 f8 ff ff       	call   c01056e6 <find_vma>
c0105e66:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0105e69:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105e6d:	74 27                	je     c0105e96 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0105e6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e72:	8b 50 08             	mov    0x8(%eax),%edx
c0105e75:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e78:	8b 40 04             	mov    0x4(%eax),%eax
c0105e7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105e7f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e8a:	c7 04 24 88 a7 10 c0 	movl   $0xc010a788,(%esp)
c0105e91:	e8 16 a4 ff ff       	call   c01002ac <cprintf>
        }
        assert(vma_below_5 == NULL);
c0105e96:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105e9a:	74 24                	je     c0105ec0 <check_vma_struct+0x46f>
c0105e9c:	c7 44 24 0c ad a7 10 	movl   $0xc010a7ad,0xc(%esp)
c0105ea3:	c0 
c0105ea4:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105eab:	c0 
c0105eac:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0105eb3:	00 
c0105eb4:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105ebb:	e8 43 a5 ff ff       	call   c0100403 <__panic>
    for (i =4; i>=0; i--) {
c0105ec0:	ff 4d f4             	decl   -0xc(%ebp)
c0105ec3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ec7:	79 8b                	jns    c0105e54 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0105ec9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ecc:	89 04 24             	mov    %eax,(%esp)
c0105ecf:	e8 9a fa ff ff       	call   c010596e <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0105ed4:	e8 7e d9 ff ff       	call   c0103857 <nr_free_pages>
c0105ed9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105edc:	74 24                	je     c0105f02 <check_vma_struct+0x4b1>
c0105ede:	c7 44 24 0c 40 a6 10 	movl   $0xc010a640,0xc(%esp)
c0105ee5:	c0 
c0105ee6:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105eed:	c0 
c0105eee:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0105ef5:	00 
c0105ef6:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105efd:	e8 01 a5 ff ff       	call   c0100403 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0105f02:	c7 04 24 c4 a7 10 c0 	movl   $0xc010a7c4,(%esp)
c0105f09:	e8 9e a3 ff ff       	call   c01002ac <cprintf>
}
c0105f0e:	90                   	nop
c0105f0f:	c9                   	leave  
c0105f10:	c3                   	ret    

c0105f11 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0105f11:	55                   	push   %ebp
c0105f12:	89 e5                	mov    %esp,%ebp
c0105f14:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105f17:	e8 3b d9 ff ff       	call   c0103857 <nr_free_pages>
c0105f1c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0105f1f:	e8 0f f7 ff ff       	call   c0105633 <mm_create>
c0105f24:	a3 34 60 12 c0       	mov    %eax,0xc0126034
    assert(check_mm_struct != NULL);
c0105f29:	a1 34 60 12 c0       	mov    0xc0126034,%eax
c0105f2e:	85 c0                	test   %eax,%eax
c0105f30:	75 24                	jne    c0105f56 <check_pgfault+0x45>
c0105f32:	c7 44 24 0c e3 a7 10 	movl   $0xc010a7e3,0xc(%esp)
c0105f39:	c0 
c0105f3a:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105f41:	c0 
c0105f42:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0105f49:	00 
c0105f4a:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105f51:	e8 ad a4 ff ff       	call   c0100403 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0105f56:	a1 34 60 12 c0       	mov    0xc0126034,%eax
c0105f5b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105f5e:	8b 15 e0 29 12 c0    	mov    0xc01229e0,%edx
c0105f64:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f67:	89 50 0c             	mov    %edx,0xc(%eax)
c0105f6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f6d:	8b 40 0c             	mov    0xc(%eax),%eax
c0105f70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0105f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f76:	8b 00                	mov    (%eax),%eax
c0105f78:	85 c0                	test   %eax,%eax
c0105f7a:	74 24                	je     c0105fa0 <check_pgfault+0x8f>
c0105f7c:	c7 44 24 0c fb a7 10 	movl   $0xc010a7fb,0xc(%esp)
c0105f83:	c0 
c0105f84:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105f8b:	c0 
c0105f8c:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0105f93:	00 
c0105f94:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105f9b:	e8 63 a4 ff ff       	call   c0100403 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0105fa0:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0105fa7:	00 
c0105fa8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0105faf:	00 
c0105fb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105fb7:	e8 ef f6 ff ff       	call   c01056ab <vma_create>
c0105fbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0105fbf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105fc3:	75 24                	jne    c0105fe9 <check_pgfault+0xd8>
c0105fc5:	c7 44 24 0c 8a a6 10 	movl   $0xc010a68a,0xc(%esp)
c0105fcc:	c0 
c0105fcd:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0105fd4:	c0 
c0105fd5:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105fdc:	00 
c0105fdd:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0105fe4:	e8 1a a4 ff ff       	call   c0100403 <__panic>

    insert_vma_struct(mm, vma);
c0105fe9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105fec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ff0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ff3:	89 04 24             	mov    %eax,(%esp)
c0105ff6:	e8 41 f8 ff ff       	call   c010583c <insert_vma_struct>

    uintptr_t addr = 0x100;
c0105ffb:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0106002:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106005:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106009:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010600c:	89 04 24             	mov    %eax,(%esp)
c010600f:	e8 d2 f6 ff ff       	call   c01056e6 <find_vma>
c0106014:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0106017:	74 24                	je     c010603d <check_pgfault+0x12c>
c0106019:	c7 44 24 0c 09 a8 10 	movl   $0xc010a809,0xc(%esp)
c0106020:	c0 
c0106021:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0106028:	c0 
c0106029:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0106030:	00 
c0106031:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0106038:	e8 c6 a3 ff ff       	call   c0100403 <__panic>

    int i, sum = 0;
c010603d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0106044:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010604b:	eb 16                	jmp    c0106063 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c010604d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106050:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106053:	01 d0                	add    %edx,%eax
c0106055:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106058:	88 10                	mov    %dl,(%eax)
        sum += i;
c010605a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010605d:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0106060:	ff 45 f4             	incl   -0xc(%ebp)
c0106063:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0106067:	7e e4                	jle    c010604d <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0106069:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106070:	eb 14                	jmp    c0106086 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0106072:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106075:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106078:	01 d0                	add    %edx,%eax
c010607a:	0f b6 00             	movzbl (%eax),%eax
c010607d:	0f be c0             	movsbl %al,%eax
c0106080:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0106083:	ff 45 f4             	incl   -0xc(%ebp)
c0106086:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010608a:	7e e6                	jle    c0106072 <check_pgfault+0x161>
    }
    assert(sum == 0);
c010608c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106090:	74 24                	je     c01060b6 <check_pgfault+0x1a5>
c0106092:	c7 44 24 0c 23 a8 10 	movl   $0xc010a823,0xc(%esp)
c0106099:	c0 
c010609a:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c01060a1:	c0 
c01060a2:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01060a9:	00 
c01060aa:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c01060b1:	e8 4d a3 ff ff       	call   c0100403 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01060b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01060b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01060bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01060bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01060c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060cb:	89 04 24             	mov    %eax,(%esp)
c01060ce:	e8 b5 df ff ff       	call   c0104088 <page_remove>
    free_page(pde2page(pgdir[0]));
c01060d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060d6:	8b 00                	mov    (%eax),%eax
c01060d8:	89 04 24             	mov    %eax,(%esp)
c01060db:	e8 3b f5 ff ff       	call   c010561b <pde2page>
c01060e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01060e7:	00 
c01060e8:	89 04 24             	mov    %eax,(%esp)
c01060eb:	e8 34 d7 ff ff       	call   c0103824 <free_pages>
    pgdir[0] = 0;
c01060f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c01060f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060fc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0106103:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106106:	89 04 24             	mov    %eax,(%esp)
c0106109:	e8 60 f8 ff ff       	call   c010596e <mm_destroy>
    check_mm_struct = NULL;
c010610e:	c7 05 34 60 12 c0 00 	movl   $0x0,0xc0126034
c0106115:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0106118:	e8 3a d7 ff ff       	call   c0103857 <nr_free_pages>
c010611d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106120:	74 24                	je     c0106146 <check_pgfault+0x235>
c0106122:	c7 44 24 0c 40 a6 10 	movl   $0xc010a640,0xc(%esp)
c0106129:	c0 
c010612a:	c7 44 24 08 bf a5 10 	movl   $0xc010a5bf,0x8(%esp)
c0106131:	c0 
c0106132:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0106139:	00 
c010613a:	c7 04 24 d4 a5 10 c0 	movl   $0xc010a5d4,(%esp)
c0106141:	e8 bd a2 ff ff       	call   c0100403 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0106146:	c7 04 24 2c a8 10 c0 	movl   $0xc010a82c,(%esp)
c010614d:	e8 5a a1 ff ff       	call   c01002ac <cprintf>
}
c0106152:	90                   	nop
c0106153:	c9                   	leave  
c0106154:	c3                   	ret    

c0106155 <do_pgfault>:
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */

int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0106155:	55                   	push   %ebp
c0106156:	89 e5                	mov    %esp,%ebp
c0106158:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c010615b:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    // 试图从mm关联的vma链表块中查询，是否存在当前addr线性地址匹配的vma块
    struct vma_struct *vma = find_vma(mm, addr);
c0106162:	8b 45 10             	mov    0x10(%ebp),%eax
c0106165:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106169:	8b 45 08             	mov    0x8(%ebp),%eax
c010616c:	89 04 24             	mov    %eax,(%esp)
c010616f:	e8 72 f5 ff ff       	call   c01056e6 <find_vma>
c0106174:	89 45 ec             	mov    %eax,-0x14(%ebp)

    // 全局页异常处理数自增1
    pgfault_num++;
c0106177:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010617c:	40                   	inc    %eax
c010617d:	a3 0c 60 12 c0       	mov    %eax,0xc012600c
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0106182:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106186:	74 0b                	je     c0106193 <do_pgfault+0x3e>
c0106188:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010618b:	8b 40 04             	mov    0x4(%eax),%eax
c010618e:	39 45 10             	cmp    %eax,0x10(%ebp)
c0106191:	73 18                	jae    c01061ab <do_pgfault+0x56>
        // 如果没有匹配到vma
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0106193:	8b 45 10             	mov    0x10(%ebp),%eax
c0106196:	89 44 24 04          	mov    %eax,0x4(%esp)
c010619a:	c7 04 24 48 a8 10 c0 	movl   $0xc010a848,(%esp)
c01061a1:	e8 06 a1 ff ff       	call   c01002ac <cprintf>
        goto failed;
c01061a6:	e9 ba 01 00 00       	jmp    c0106365 <do_pgfault+0x210>
    }
    //check the error_code
    // 页访问异常错误码有32位。位0为1 表示对应物理页不存在；位1为1 表示写异常(比如写了只读页)；位2为1 表示访问权限异常（比如用户态程序访问内核空间的数据）
    // 对3求模，主要判断bit0、bit1的值
    switch (error_code & 3) {
c01061ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061ae:	83 e0 03             	and    $0x3,%eax
c01061b1:	85 c0                	test   %eax,%eax
c01061b3:	74 34                	je     c01061e9 <do_pgfault+0x94>
c01061b5:	83 f8 01             	cmp    $0x1,%eax
c01061b8:	74 1e                	je     c01061d8 <do_pgfault+0x83>
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
        // bit0，bit1都为1，访问的映射页表项存在，且发生的是写异常
        // 说明发生了缺页异常
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        // bit0为0，bit1为1，访问的映射页表项不存在、且发生的是写异常
        if (!(vma->vm_flags & VM_WRITE)) {
c01061ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061bd:	8b 40 0c             	mov    0xc(%eax),%eax
c01061c0:	83 e0 02             	and    $0x2,%eax
c01061c3:	85 c0                	test   %eax,%eax
c01061c5:	75 40                	jne    c0106207 <do_pgfault+0xb2>
            // 对应的vma块映射的虚拟内存空间是不可写的,权限校验失败
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01061c7:	c7 04 24 78 a8 10 c0 	movl   $0xc010a878,(%esp)
c01061ce:	e8 d9 a0 ff ff       	call   c01002ac <cprintf>
            // 跳转failed直接返回
            goto failed;
c01061d3:	e9 8d 01 00 00       	jmp    c0106365 <do_pgfault+0x210>
        }
        // 校验通过，则说明发生了缺页异常
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        // bit0为1，bit1为0，访问的映射页表项存在，且发生的是读异常(可能是访问权限异常)
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c01061d8:	c7 04 24 d8 a8 10 c0 	movl   $0xc010a8d8,(%esp)
c01061df:	e8 c8 a0 ff ff       	call   c01002ac <cprintf>
        // 跳转failed直接返回
        goto failed;
c01061e4:	e9 7c 01 00 00       	jmp    c0106365 <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        // bit0为0，bit1为0，访问的映射页表项不存在，且发生的是读异常
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c01061e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061ec:	8b 40 0c             	mov    0xc(%eax),%eax
c01061ef:	83 e0 05             	and    $0x5,%eax
c01061f2:	85 c0                	test   %eax,%eax
c01061f4:	75 12                	jne    c0106208 <do_pgfault+0xb3>
            // 对应的vma映射的虚拟内存空间是不可读且不可执行的
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c01061f6:	c7 04 24 10 a9 10 c0 	movl   $0xc010a910,(%esp)
c01061fd:	e8 aa a0 ff ff       	call   c01002ac <cprintf>
            goto failed;
c0106202:	e9 5e 01 00 00       	jmp    c0106365 <do_pgfault+0x210>
        break;
c0106207:	90                   	nop
     * THEN
     *    continue process
     */

    // 构造需要设置的缺页页表项的perm权限
    uint32_t perm = PTE_U;
c0106208:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c010620f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106212:	8b 40 0c             	mov    0xc(%eax),%eax
c0106215:	83 e0 02             	and    $0x2,%eax
c0106218:	85 c0                	test   %eax,%eax
c010621a:	74 04                	je     c0106220 <do_pgfault+0xcb>
        perm |= PTE_W;
c010621c:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    // 构造需要设置的缺页页表项的线性地址(按照PGSIZE向下取整，进行页面对齐)
    addr = ROUNDDOWN(addr, PGSIZE);
c0106220:	8b 45 10             	mov    0x10(%ebp),%eax
c0106223:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106226:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106229:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010622e:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0106231:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    // 用于映射的页表项指针（page table entry, pte）
    pte_t *ptep=NULL;
c0106238:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    // 获取addr线性地址在mm所关联页表中的页表项
    // 第三个参数=1 表示如果对应页表项不存在，则需要新创建这个页表项
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c010623f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106242:	8b 40 0c             	mov    0xc(%eax),%eax
c0106245:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010624c:	00 
c010624d:	8b 55 10             	mov    0x10(%ebp),%edx
c0106250:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106254:	89 04 24             	mov    %eax,(%esp)
c0106257:	e8 38 dc ff ff       	call   c0103e94 <get_pte>
c010625c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010625f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106263:	75 11                	jne    c0106276 <do_pgfault+0x121>
        cprintf("do_pgfault: get_pte failed\n");
c0106265:	c7 04 24 73 a9 10 c0 	movl   $0xc010a973,(%esp)
c010626c:	e8 3b a0 ff ff       	call   c01002ac <cprintf>
        goto failed;
c0106271:	e9 ef 00 00 00       	jmp    c0106365 <do_pgfault+0x210>
    }
    
    // 如果对应页表项的内容每一位都全为0，说明之前并不存在，需要设置对应的数据，进行线性地址与物理地址的映射
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0106276:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106279:	8b 00                	mov    (%eax),%eax
c010627b:	85 c0                	test   %eax,%eax
c010627d:	75 35                	jne    c01062b4 <do_pgfault+0x15f>
        // 令pgdir指向的页表中，la线性地址对应的二级页表项与一个新分配的物理页Page进行虚实地址的映射
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c010627f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106282:	8b 40 0c             	mov    0xc(%eax),%eax
c0106285:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106288:	89 54 24 08          	mov    %edx,0x8(%esp)
c010628c:	8b 55 10             	mov    0x10(%ebp),%edx
c010628f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106293:	89 04 24             	mov    %eax,(%esp)
c0106296:	e8 47 df ff ff       	call   c01041e2 <pgdir_alloc_page>
c010629b:	85 c0                	test   %eax,%eax
c010629d:	0f 85 bb 00 00 00    	jne    c010635e <do_pgfault+0x209>
            cprintf("do_pgfault: pgdir_alloc_page failed\n");
c01062a3:	c7 04 24 90 a9 10 c0 	movl   $0xc010a990,(%esp)
c01062aa:	e8 fd 9f ff ff       	call   c01002ac <cprintf>
            goto failed;
c01062af:	e9 b1 00 00 00       	jmp    c0106365 <do_pgfault+0x210>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        // 如果不是全为0，说明可能是之前被交换到了swap磁盘中
        if(swap_init_ok) {
c01062b4:	a1 10 60 12 c0       	mov    0xc0126010,%eax
c01062b9:	85 c0                	test   %eax,%eax
c01062bb:	0f 84 86 00 00 00    	je     c0106347 <do_pgfault+0x1f2>
            // 如果开启了swap磁盘虚拟内存交换机制
            struct Page *page=NULL;
c01062c1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            // 将addr线性地址对应的物理页数据从磁盘交换到物理内存中(令Page指针指向交换成功后的物理页)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01062c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01062cb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01062cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01062d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01062d9:	89 04 24             	mov    %eax,(%esp)
c01062dc:	e8 8e 03 00 00       	call   c010666f <swap_in>
c01062e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01062e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01062e8:	74 0e                	je     c01062f8 <do_pgfault+0x1a3>
                // swap_in返回值不为0，表示换入失败
                cprintf("swap_in in do_pgfault failed\n");
c01062ea:	c7 04 24 b5 a9 10 c0 	movl   $0xc010a9b5,(%esp)
c01062f1:	e8 b6 9f ff ff       	call   c01002ac <cprintf>
c01062f6:	eb 6d                	jmp    c0106365 <do_pgfault+0x210>
                goto failed;
            }    
            // 将交换进来的page页与mm->padir页表中对应addr的二级页表项建立映射关系(perm标识这个二级页表的各个权限位)
            page_insert(mm->pgdir, page, addr, perm);
c01062f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01062fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01062fe:	8b 40 0c             	mov    0xc(%eax),%eax
c0106301:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106304:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0106308:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010630b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010630f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106313:	89 04 24             	mov    %eax,(%esp)
c0106316:	e8 b2 dd ff ff       	call   c01040cd <page_insert>
            // 当前page是为可交换的，将其加入全局虚拟内存交换管理器的管理
            swap_map_swappable(mm, addr, page, 1);
c010631b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010631e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0106325:	00 
c0106326:	89 44 24 08          	mov    %eax,0x8(%esp)
c010632a:	8b 45 10             	mov    0x10(%ebp),%eax
c010632d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106331:	8b 45 08             	mov    0x8(%ebp),%eax
c0106334:	89 04 24             	mov    %eax,(%esp)
c0106337:	e8 71 01 00 00       	call   c01064ad <swap_map_swappable>
            page->pra_vaddr = addr;
c010633c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010633f:	8b 55 10             	mov    0x10(%ebp),%edx
c0106342:	89 50 1c             	mov    %edx,0x1c(%eax)
c0106345:	eb 17                	jmp    c010635e <do_pgfault+0x209>
        }
        else {
            // 如果没有开启swap磁盘虚拟内存交换机制，但是却执行至此，则出现了问题
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0106347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010634a:	8b 00                	mov    (%eax),%eax
c010634c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106350:	c7 04 24 d4 a9 10 c0 	movl   $0xc010a9d4,(%esp)
c0106357:	e8 50 9f ff ff       	call   c01002ac <cprintf>
            goto failed;
c010635c:	eb 07                	jmp    c0106365 <do_pgfault+0x210>
        }
   }
   // 返回0代表缺页异常处理成功
   ret = 0;
c010635e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106368:	c9                   	leave  
c0106369:	c3                   	ret    

c010636a <pa2page>:
pa2page(uintptr_t pa) {
c010636a:	55                   	push   %ebp
c010636b:	89 e5                	mov    %esp,%ebp
c010636d:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106370:	8b 45 08             	mov    0x8(%ebp),%eax
c0106373:	c1 e8 0c             	shr    $0xc,%eax
c0106376:	89 c2                	mov    %eax,%edx
c0106378:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c010637d:	39 c2                	cmp    %eax,%edx
c010637f:	72 1c                	jb     c010639d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106381:	c7 44 24 08 fc a9 10 	movl   $0xc010a9fc,0x8(%esp)
c0106388:	c0 
c0106389:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0106390:	00 
c0106391:	c7 04 24 1b aa 10 c0 	movl   $0xc010aa1b,(%esp)
c0106398:	e8 66 a0 ff ff       	call   c0100403 <__panic>
    return &pages[PPN(pa)];
c010639d:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c01063a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01063a5:	c1 ea 0c             	shr    $0xc,%edx
c01063a8:	c1 e2 05             	shl    $0x5,%edx
c01063ab:	01 d0                	add    %edx,%eax
}
c01063ad:	c9                   	leave  
c01063ae:	c3                   	ret    

c01063af <pte2page>:
pte2page(pte_t pte) {
c01063af:	55                   	push   %ebp
c01063b0:	89 e5                	mov    %esp,%ebp
c01063b2:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01063b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01063b8:	83 e0 01             	and    $0x1,%eax
c01063bb:	85 c0                	test   %eax,%eax
c01063bd:	75 1c                	jne    c01063db <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01063bf:	c7 44 24 08 2c aa 10 	movl   $0xc010aa2c,0x8(%esp)
c01063c6:	c0 
c01063c7:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01063ce:	00 
c01063cf:	c7 04 24 1b aa 10 c0 	movl   $0xc010aa1b,(%esp)
c01063d6:	e8 28 a0 ff ff       	call   c0100403 <__panic>
    return pa2page(PTE_ADDR(pte));
c01063db:	8b 45 08             	mov    0x8(%ebp),%eax
c01063de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01063e3:	89 04 24             	mov    %eax,(%esp)
c01063e6:	e8 7f ff ff ff       	call   c010636a <pa2page>
}
c01063eb:	c9                   	leave  
c01063ec:	c3                   	ret    

c01063ed <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01063ed:	55                   	push   %ebp
c01063ee:	89 e5                	mov    %esp,%ebp
c01063f0:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01063f3:	e8 b3 22 00 00       	call   c01086ab <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01063f8:	a1 dc 60 12 c0       	mov    0xc01260dc,%eax
c01063fd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106402:	76 0c                	jbe    c0106410 <swap_init+0x23>
c0106404:	a1 dc 60 12 c0       	mov    0xc01260dc,%eax
c0106409:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c010640e:	76 25                	jbe    c0106435 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106410:	a1 dc 60 12 c0       	mov    0xc01260dc,%eax
c0106415:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106419:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0106420:	c0 
c0106421:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
c0106428:	00 
c0106429:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106430:	e8 ce 9f ff ff       	call   c0100403 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106435:	c7 05 18 60 12 c0 40 	movl   $0xc0122a40,0xc0126018
c010643c:	2a 12 c0 
     //sm = &swap_manager_clock;
     int r = sm->init();
c010643f:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0106444:	8b 40 04             	mov    0x4(%eax),%eax
c0106447:	ff d0                	call   *%eax
c0106449:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c010644c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106450:	75 26                	jne    c0106478 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106452:	c7 05 10 60 12 c0 01 	movl   $0x1,0xc0126010
c0106459:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c010645c:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0106461:	8b 00                	mov    (%eax),%eax
c0106463:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106467:	c7 04 24 77 aa 10 c0 	movl   $0xc010aa77,(%esp)
c010646e:	e8 39 9e ff ff       	call   c01002ac <cprintf>
          check_swap();
c0106473:	e8 9e 04 00 00       	call   c0106916 <check_swap>
     }

     return r;
c0106478:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010647b:	c9                   	leave  
c010647c:	c3                   	ret    

c010647d <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c010647d:	55                   	push   %ebp
c010647e:	89 e5                	mov    %esp,%ebp
c0106480:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106483:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0106488:	8b 40 08             	mov    0x8(%eax),%eax
c010648b:	8b 55 08             	mov    0x8(%ebp),%edx
c010648e:	89 14 24             	mov    %edx,(%esp)
c0106491:	ff d0                	call   *%eax
}
c0106493:	c9                   	leave  
c0106494:	c3                   	ret    

c0106495 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106495:	55                   	push   %ebp
c0106496:	89 e5                	mov    %esp,%ebp
c0106498:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c010649b:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c01064a0:	8b 40 0c             	mov    0xc(%eax),%eax
c01064a3:	8b 55 08             	mov    0x8(%ebp),%edx
c01064a6:	89 14 24             	mov    %edx,(%esp)
c01064a9:	ff d0                	call   *%eax
}
c01064ab:	c9                   	leave  
c01064ac:	c3                   	ret    

c01064ad <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01064ad:	55                   	push   %ebp
c01064ae:	89 e5                	mov    %esp,%ebp
c01064b0:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01064b3:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c01064b8:	8b 40 10             	mov    0x10(%eax),%eax
c01064bb:	8b 55 14             	mov    0x14(%ebp),%edx
c01064be:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01064c2:	8b 55 10             	mov    0x10(%ebp),%edx
c01064c5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01064c9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01064cc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01064d3:	89 14 24             	mov    %edx,(%esp)
c01064d6:	ff d0                	call   *%eax
}
c01064d8:	c9                   	leave  
c01064d9:	c3                   	ret    

c01064da <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01064da:	55                   	push   %ebp
c01064db:	89 e5                	mov    %esp,%ebp
c01064dd:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01064e0:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c01064e5:	8b 40 14             	mov    0x14(%eax),%eax
c01064e8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01064eb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064ef:	8b 55 08             	mov    0x8(%ebp),%edx
c01064f2:	89 14 24             	mov    %edx,(%esp)
c01064f5:	ff d0                	call   *%eax
}
c01064f7:	c9                   	leave  
c01064f8:	c3                   	ret    

c01064f9 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01064f9:	55                   	push   %ebp
c01064fa:	89 e5                	mov    %esp,%ebp
c01064fc:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01064ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106506:	e9 53 01 00 00       	jmp    c010665e <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c010650b:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0106510:	8b 40 18             	mov    0x18(%eax),%eax
c0106513:	8b 55 10             	mov    0x10(%ebp),%edx
c0106516:	89 54 24 08          	mov    %edx,0x8(%esp)
c010651a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c010651d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106521:	8b 55 08             	mov    0x8(%ebp),%edx
c0106524:	89 14 24             	mov    %edx,(%esp)
c0106527:	ff d0                	call   *%eax
c0106529:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c010652c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106530:	74 18                	je     c010654a <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106532:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106535:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106539:	c7 04 24 8c aa 10 c0 	movl   $0xc010aa8c,(%esp)
c0106540:	e8 67 9d ff ff       	call   c01002ac <cprintf>
c0106545:	e9 20 01 00 00       	jmp    c010666a <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c010654a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010654d:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106550:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106553:	8b 45 08             	mov    0x8(%ebp),%eax
c0106556:	8b 40 0c             	mov    0xc(%eax),%eax
c0106559:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106560:	00 
c0106561:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106564:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106568:	89 04 24             	mov    %eax,(%esp)
c010656b:	e8 24 d9 ff ff       	call   c0103e94 <get_pte>
c0106570:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106573:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106576:	8b 00                	mov    (%eax),%eax
c0106578:	83 e0 01             	and    $0x1,%eax
c010657b:	85 c0                	test   %eax,%eax
c010657d:	75 24                	jne    c01065a3 <swap_out+0xaa>
c010657f:	c7 44 24 0c b9 aa 10 	movl   $0xc010aab9,0xc(%esp)
c0106586:	c0 
c0106587:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c010658e:	c0 
c010658f:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106596:	00 
c0106597:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c010659e:	e8 60 9e ff ff       	call   c0100403 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01065a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01065a9:	8b 52 1c             	mov    0x1c(%edx),%edx
c01065ac:	c1 ea 0c             	shr    $0xc,%edx
c01065af:	42                   	inc    %edx
c01065b0:	c1 e2 08             	shl    $0x8,%edx
c01065b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065b7:	89 14 24             	mov    %edx,(%esp)
c01065ba:	e8 a7 21 00 00       	call   c0108766 <swapfs_write>
c01065bf:	85 c0                	test   %eax,%eax
c01065c1:	74 34                	je     c01065f7 <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c01065c3:	c7 04 24 e3 aa 10 c0 	movl   $0xc010aae3,(%esp)
c01065ca:	e8 dd 9c ff ff       	call   c01002ac <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01065cf:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c01065d4:	8b 40 10             	mov    0x10(%eax),%eax
c01065d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01065da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01065e1:	00 
c01065e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01065e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01065e9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065ed:	8b 55 08             	mov    0x8(%ebp),%edx
c01065f0:	89 14 24             	mov    %edx,(%esp)
c01065f3:	ff d0                	call   *%eax
c01065f5:	eb 64                	jmp    c010665b <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01065f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065fa:	8b 40 1c             	mov    0x1c(%eax),%eax
c01065fd:	c1 e8 0c             	shr    $0xc,%eax
c0106600:	40                   	inc    %eax
c0106601:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106605:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106608:	89 44 24 08          	mov    %eax,0x8(%esp)
c010660c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010660f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106613:	c7 04 24 fc aa 10 c0 	movl   $0xc010aafc,(%esp)
c010661a:	e8 8d 9c ff ff       	call   c01002ac <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010661f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106622:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106625:	c1 e8 0c             	shr    $0xc,%eax
c0106628:	40                   	inc    %eax
c0106629:	c1 e0 08             	shl    $0x8,%eax
c010662c:	89 c2                	mov    %eax,%edx
c010662e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106631:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106636:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010663d:	00 
c010663e:	89 04 24             	mov    %eax,(%esp)
c0106641:	e8 de d1 ff ff       	call   c0103824 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106646:	8b 45 08             	mov    0x8(%ebp),%eax
c0106649:	8b 40 0c             	mov    0xc(%eax),%eax
c010664c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010664f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106653:	89 04 24             	mov    %eax,(%esp)
c0106656:	e8 2b db ff ff       	call   c0104186 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c010665b:	ff 45 f4             	incl   -0xc(%ebp)
c010665e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106661:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106664:	0f 85 a1 fe ff ff    	jne    c010650b <swap_out+0x12>
     }
     return i;
c010666a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010666d:	c9                   	leave  
c010666e:	c3                   	ret    

c010666f <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c010666f:	55                   	push   %ebp
c0106670:	89 e5                	mov    %esp,%ebp
c0106672:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106675:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010667c:	e8 38 d1 ff ff       	call   c01037b9 <alloc_pages>
c0106681:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106688:	75 24                	jne    c01066ae <swap_in+0x3f>
c010668a:	c7 44 24 0c 3c ab 10 	movl   $0xc010ab3c,0xc(%esp)
c0106691:	c0 
c0106692:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106699:	c0 
c010669a:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01066a1:	00 
c01066a2:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c01066a9:	e8 55 9d ff ff       	call   c0100403 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01066ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01066b1:	8b 40 0c             	mov    0xc(%eax),%eax
c01066b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01066bb:	00 
c01066bc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01066bf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01066c3:	89 04 24             	mov    %eax,(%esp)
c01066c6:	e8 c9 d7 ff ff       	call   c0103e94 <get_pte>
c01066cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01066ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066d1:	8b 00                	mov    (%eax),%eax
c01066d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01066d6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01066da:	89 04 24             	mov    %eax,(%esp)
c01066dd:	e8 12 20 00 00       	call   c01086f4 <swapfs_read>
c01066e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01066e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01066e9:	74 2a                	je     c0106715 <swap_in+0xa6>
     {
        assert(r!=0);
c01066eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01066ef:	75 24                	jne    c0106715 <swap_in+0xa6>
c01066f1:	c7 44 24 0c 49 ab 10 	movl   $0xc010ab49,0xc(%esp)
c01066f8:	c0 
c01066f9:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106700:	c0 
c0106701:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0106708:	00 
c0106709:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106710:	e8 ee 9c ff ff       	call   c0100403 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106715:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106718:	8b 00                	mov    (%eax),%eax
c010671a:	c1 e8 08             	shr    $0x8,%eax
c010671d:	89 c2                	mov    %eax,%edx
c010671f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106722:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106726:	89 54 24 04          	mov    %edx,0x4(%esp)
c010672a:	c7 04 24 50 ab 10 c0 	movl   $0xc010ab50,(%esp)
c0106731:	e8 76 9b ff ff       	call   c01002ac <cprintf>
     *ptr_result=result;
c0106736:	8b 45 10             	mov    0x10(%ebp),%eax
c0106739:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010673c:	89 10                	mov    %edx,(%eax)
     return 0;
c010673e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106743:	c9                   	leave  
c0106744:	c3                   	ret    

c0106745 <check_content_set>:



static inline void
check_content_set(void)
{
c0106745:	55                   	push   %ebp
c0106746:	89 e5                	mov    %esp,%ebp
c0106748:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010674b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106750:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106753:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106758:	83 f8 01             	cmp    $0x1,%eax
c010675b:	74 24                	je     c0106781 <check_content_set+0x3c>
c010675d:	c7 44 24 0c 8e ab 10 	movl   $0xc010ab8e,0xc(%esp)
c0106764:	c0 
c0106765:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c010676c:	c0 
c010676d:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0106774:	00 
c0106775:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c010677c:	e8 82 9c ff ff       	call   c0100403 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106781:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106786:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106789:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010678e:	83 f8 01             	cmp    $0x1,%eax
c0106791:	74 24                	je     c01067b7 <check_content_set+0x72>
c0106793:	c7 44 24 0c 8e ab 10 	movl   $0xc010ab8e,0xc(%esp)
c010679a:	c0 
c010679b:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c01067a2:	c0 
c01067a3:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01067aa:	00 
c01067ab:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c01067b2:	e8 4c 9c ff ff       	call   c0100403 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01067b7:	b8 00 20 00 00       	mov    $0x2000,%eax
c01067bc:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01067bf:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01067c4:	83 f8 02             	cmp    $0x2,%eax
c01067c7:	74 24                	je     c01067ed <check_content_set+0xa8>
c01067c9:	c7 44 24 0c 9d ab 10 	movl   $0xc010ab9d,0xc(%esp)
c01067d0:	c0 
c01067d1:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c01067d8:	c0 
c01067d9:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c01067e0:	00 
c01067e1:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c01067e8:	e8 16 9c ff ff       	call   c0100403 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01067ed:	b8 10 20 00 00       	mov    $0x2010,%eax
c01067f2:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01067f5:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01067fa:	83 f8 02             	cmp    $0x2,%eax
c01067fd:	74 24                	je     c0106823 <check_content_set+0xde>
c01067ff:	c7 44 24 0c 9d ab 10 	movl   $0xc010ab9d,0xc(%esp)
c0106806:	c0 
c0106807:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c010680e:	c0 
c010680f:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106816:	00 
c0106817:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c010681e:	e8 e0 9b ff ff       	call   c0100403 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106823:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106828:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010682b:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106830:	83 f8 03             	cmp    $0x3,%eax
c0106833:	74 24                	je     c0106859 <check_content_set+0x114>
c0106835:	c7 44 24 0c ac ab 10 	movl   $0xc010abac,0xc(%esp)
c010683c:	c0 
c010683d:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106844:	c0 
c0106845:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c010684c:	00 
c010684d:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106854:	e8 aa 9b ff ff       	call   c0100403 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106859:	b8 10 30 00 00       	mov    $0x3010,%eax
c010685e:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106861:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106866:	83 f8 03             	cmp    $0x3,%eax
c0106869:	74 24                	je     c010688f <check_content_set+0x14a>
c010686b:	c7 44 24 0c ac ab 10 	movl   $0xc010abac,0xc(%esp)
c0106872:	c0 
c0106873:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c010687a:	c0 
c010687b:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0106882:	00 
c0106883:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c010688a:	e8 74 9b ff ff       	call   c0100403 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c010688f:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106894:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106897:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010689c:	83 f8 04             	cmp    $0x4,%eax
c010689f:	74 24                	je     c01068c5 <check_content_set+0x180>
c01068a1:	c7 44 24 0c bb ab 10 	movl   $0xc010abbb,0xc(%esp)
c01068a8:	c0 
c01068a9:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c01068b0:	c0 
c01068b1:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01068b8:	00 
c01068b9:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c01068c0:	e8 3e 9b ff ff       	call   c0100403 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01068c5:	b8 10 40 00 00       	mov    $0x4010,%eax
c01068ca:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01068cd:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01068d2:	83 f8 04             	cmp    $0x4,%eax
c01068d5:	74 24                	je     c01068fb <check_content_set+0x1b6>
c01068d7:	c7 44 24 0c bb ab 10 	movl   $0xc010abbb,0xc(%esp)
c01068de:	c0 
c01068df:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c01068e6:	c0 
c01068e7:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01068ee:	00 
c01068ef:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c01068f6:	e8 08 9b ff ff       	call   c0100403 <__panic>
}
c01068fb:	90                   	nop
c01068fc:	c9                   	leave  
c01068fd:	c3                   	ret    

c01068fe <check_content_access>:

static inline int
check_content_access(void)
{
c01068fe:	55                   	push   %ebp
c01068ff:	89 e5                	mov    %esp,%ebp
c0106901:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106904:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0106909:	8b 40 1c             	mov    0x1c(%eax),%eax
c010690c:	ff d0                	call   *%eax
c010690e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106911:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106914:	c9                   	leave  
c0106915:	c3                   	ret    

c0106916 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106916:	55                   	push   %ebp
c0106917:	89 e5                	mov    %esp,%ebp
c0106919:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010691c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106923:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010692a:	c7 45 e8 04 61 12 c0 	movl   $0xc0126104,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106931:	eb 6a                	jmp    c010699d <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0106933:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106936:	83 e8 0c             	sub    $0xc,%eax
c0106939:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c010693c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010693f:	83 c0 04             	add    $0x4,%eax
c0106942:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106949:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010694c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010694f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106952:	0f a3 10             	bt     %edx,(%eax)
c0106955:	19 c0                	sbb    %eax,%eax
c0106957:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c010695a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010695e:	0f 95 c0             	setne  %al
c0106961:	0f b6 c0             	movzbl %al,%eax
c0106964:	85 c0                	test   %eax,%eax
c0106966:	75 24                	jne    c010698c <check_swap+0x76>
c0106968:	c7 44 24 0c ca ab 10 	movl   $0xc010abca,0xc(%esp)
c010696f:	c0 
c0106970:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106977:	c0 
c0106978:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c010697f:	00 
c0106980:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106987:	e8 77 9a ff ff       	call   c0100403 <__panic>
        count ++, total += p->property;
c010698c:	ff 45 f4             	incl   -0xc(%ebp)
c010698f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106992:	8b 50 08             	mov    0x8(%eax),%edx
c0106995:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106998:	01 d0                	add    %edx,%eax
c010699a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010699d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069a0:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01069a3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01069a6:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01069a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01069ac:	81 7d e8 04 61 12 c0 	cmpl   $0xc0126104,-0x18(%ebp)
c01069b3:	0f 85 7a ff ff ff    	jne    c0106933 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c01069b9:	e8 99 ce ff ff       	call   c0103857 <nr_free_pages>
c01069be:	89 c2                	mov    %eax,%edx
c01069c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069c3:	39 c2                	cmp    %eax,%edx
c01069c5:	74 24                	je     c01069eb <check_swap+0xd5>
c01069c7:	c7 44 24 0c da ab 10 	movl   $0xc010abda,0xc(%esp)
c01069ce:	c0 
c01069cf:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c01069d6:	c0 
c01069d7:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c01069de:	00 
c01069df:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c01069e6:	e8 18 9a ff ff       	call   c0100403 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01069eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01069f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069f9:	c7 04 24 f4 ab 10 c0 	movl   $0xc010abf4,(%esp)
c0106a00:	e8 a7 98 ff ff       	call   c01002ac <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106a05:	e8 29 ec ff ff       	call   c0105633 <mm_create>
c0106a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106a0d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106a11:	75 24                	jne    c0106a37 <check_swap+0x121>
c0106a13:	c7 44 24 0c 1a ac 10 	movl   $0xc010ac1a,0xc(%esp)
c0106a1a:	c0 
c0106a1b:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106a22:	c0 
c0106a23:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0106a2a:	00 
c0106a2b:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106a32:	e8 cc 99 ff ff       	call   c0100403 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106a37:	a1 34 60 12 c0       	mov    0xc0126034,%eax
c0106a3c:	85 c0                	test   %eax,%eax
c0106a3e:	74 24                	je     c0106a64 <check_swap+0x14e>
c0106a40:	c7 44 24 0c 25 ac 10 	movl   $0xc010ac25,0xc(%esp)
c0106a47:	c0 
c0106a48:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106a4f:	c0 
c0106a50:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0106a57:	00 
c0106a58:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106a5f:	e8 9f 99 ff ff       	call   c0100403 <__panic>

     check_mm_struct = mm;
c0106a64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a67:	a3 34 60 12 c0       	mov    %eax,0xc0126034

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106a6c:	8b 15 e0 29 12 c0    	mov    0xc01229e0,%edx
c0106a72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a75:	89 50 0c             	mov    %edx,0xc(%eax)
c0106a78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a7b:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a84:	8b 00                	mov    (%eax),%eax
c0106a86:	85 c0                	test   %eax,%eax
c0106a88:	74 24                	je     c0106aae <check_swap+0x198>
c0106a8a:	c7 44 24 0c 3d ac 10 	movl   $0xc010ac3d,0xc(%esp)
c0106a91:	c0 
c0106a92:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106a99:	c0 
c0106a9a:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0106aa1:	00 
c0106aa2:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106aa9:	e8 55 99 ff ff       	call   c0100403 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106aae:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106ab5:	00 
c0106ab6:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106abd:	00 
c0106abe:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0106ac5:	e8 e1 eb ff ff       	call   c01056ab <vma_create>
c0106aca:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106acd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106ad1:	75 24                	jne    c0106af7 <check_swap+0x1e1>
c0106ad3:	c7 44 24 0c 4b ac 10 	movl   $0xc010ac4b,0xc(%esp)
c0106ada:	c0 
c0106adb:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106ae2:	c0 
c0106ae3:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0106aea:	00 
c0106aeb:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106af2:	e8 0c 99 ff ff       	call   c0100403 <__panic>

     insert_vma_struct(mm, vma);
c0106af7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106afa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106afe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b01:	89 04 24             	mov    %eax,(%esp)
c0106b04:	e8 33 ed ff ff       	call   c010583c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106b09:	c7 04 24 58 ac 10 c0 	movl   $0xc010ac58,(%esp)
c0106b10:	e8 97 97 ff ff       	call   c01002ac <cprintf>
     pte_t *temp_ptep=NULL;
c0106b15:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b1f:	8b 40 0c             	mov    0xc(%eax),%eax
c0106b22:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106b29:	00 
c0106b2a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106b31:	00 
c0106b32:	89 04 24             	mov    %eax,(%esp)
c0106b35:	e8 5a d3 ff ff       	call   c0103e94 <get_pte>
c0106b3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106b3d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106b41:	75 24                	jne    c0106b67 <check_swap+0x251>
c0106b43:	c7 44 24 0c 8c ac 10 	movl   $0xc010ac8c,0xc(%esp)
c0106b4a:	c0 
c0106b4b:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106b52:	c0 
c0106b53:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0106b5a:	00 
c0106b5b:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106b62:	e8 9c 98 ff ff       	call   c0100403 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106b67:	c7 04 24 a0 ac 10 c0 	movl   $0xc010aca0,(%esp)
c0106b6e:	e8 39 97 ff ff       	call   c01002ac <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106b73:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106b7a:	e9 a4 00 00 00       	jmp    c0106c23 <check_swap+0x30d>
          check_rp[i] = alloc_page();
c0106b7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106b86:	e8 2e cc ff ff       	call   c01037b9 <alloc_pages>
c0106b8b:	89 c2                	mov    %eax,%edx
c0106b8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b90:	89 14 85 40 60 12 c0 	mov    %edx,-0x3fed9fc0(,%eax,4)
          assert(check_rp[i] != NULL );
c0106b97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b9a:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106ba1:	85 c0                	test   %eax,%eax
c0106ba3:	75 24                	jne    c0106bc9 <check_swap+0x2b3>
c0106ba5:	c7 44 24 0c c4 ac 10 	movl   $0xc010acc4,0xc(%esp)
c0106bac:	c0 
c0106bad:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106bb4:	c0 
c0106bb5:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0106bbc:	00 
c0106bbd:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106bc4:	e8 3a 98 ff ff       	call   c0100403 <__panic>
          assert(!PageProperty(check_rp[i]));
c0106bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bcc:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106bd3:	83 c0 04             	add    $0x4,%eax
c0106bd6:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106bdd:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106be0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106be3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106be6:	0f a3 10             	bt     %edx,(%eax)
c0106be9:	19 c0                	sbb    %eax,%eax
c0106beb:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106bee:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106bf2:	0f 95 c0             	setne  %al
c0106bf5:	0f b6 c0             	movzbl %al,%eax
c0106bf8:	85 c0                	test   %eax,%eax
c0106bfa:	74 24                	je     c0106c20 <check_swap+0x30a>
c0106bfc:	c7 44 24 0c d8 ac 10 	movl   $0xc010acd8,0xc(%esp)
c0106c03:	c0 
c0106c04:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106c0b:	c0 
c0106c0c:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0106c13:	00 
c0106c14:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106c1b:	e8 e3 97 ff ff       	call   c0100403 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106c20:	ff 45 ec             	incl   -0x14(%ebp)
c0106c23:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106c27:	0f 8e 52 ff ff ff    	jle    c0106b7f <check_swap+0x269>
     }
     list_entry_t free_list_store = free_list;
c0106c2d:	a1 04 61 12 c0       	mov    0xc0126104,%eax
c0106c32:	8b 15 08 61 12 c0    	mov    0xc0126108,%edx
c0106c38:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106c3b:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106c3e:	c7 45 a4 04 61 12 c0 	movl   $0xc0126104,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106c45:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106c48:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106c4b:	89 50 04             	mov    %edx,0x4(%eax)
c0106c4e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106c51:	8b 50 04             	mov    0x4(%eax),%edx
c0106c54:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106c57:	89 10                	mov    %edx,(%eax)
c0106c59:	c7 45 a8 04 61 12 c0 	movl   $0xc0126104,-0x58(%ebp)
    return list->next == list;
c0106c60:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106c63:	8b 40 04             	mov    0x4(%eax),%eax
c0106c66:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0106c69:	0f 94 c0             	sete   %al
c0106c6c:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106c6f:	85 c0                	test   %eax,%eax
c0106c71:	75 24                	jne    c0106c97 <check_swap+0x381>
c0106c73:	c7 44 24 0c f3 ac 10 	movl   $0xc010acf3,0xc(%esp)
c0106c7a:	c0 
c0106c7b:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106c82:	c0 
c0106c83:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0106c8a:	00 
c0106c8b:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106c92:	e8 6c 97 ff ff       	call   c0100403 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106c97:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0106c9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0106c9f:	c7 05 0c 61 12 c0 00 	movl   $0x0,0xc012610c
c0106ca6:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ca9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106cb0:	eb 1d                	jmp    c0106ccf <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0106cb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cb5:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106cbc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106cc3:	00 
c0106cc4:	89 04 24             	mov    %eax,(%esp)
c0106cc7:	e8 58 cb ff ff       	call   c0103824 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ccc:	ff 45 ec             	incl   -0x14(%ebp)
c0106ccf:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106cd3:	7e dd                	jle    c0106cb2 <check_swap+0x39c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0106cd5:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0106cda:	83 f8 04             	cmp    $0x4,%eax
c0106cdd:	74 24                	je     c0106d03 <check_swap+0x3ed>
c0106cdf:	c7 44 24 0c 0c ad 10 	movl   $0xc010ad0c,0xc(%esp)
c0106ce6:	c0 
c0106ce7:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106cee:	c0 
c0106cef:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0106cf6:	00 
c0106cf7:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106cfe:	e8 00 97 ff ff       	call   c0100403 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106d03:	c7 04 24 30 ad 10 c0 	movl   $0xc010ad30,(%esp)
c0106d0a:	e8 9d 95 ff ff       	call   c01002ac <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106d0f:	c7 05 0c 60 12 c0 00 	movl   $0x0,0xc012600c
c0106d16:	00 00 00 
     
     check_content_set();
c0106d19:	e8 27 fa ff ff       	call   c0106745 <check_content_set>
     assert( nr_free == 0);         
c0106d1e:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0106d23:	85 c0                	test   %eax,%eax
c0106d25:	74 24                	je     c0106d4b <check_swap+0x435>
c0106d27:	c7 44 24 0c 57 ad 10 	movl   $0xc010ad57,0xc(%esp)
c0106d2e:	c0 
c0106d2f:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106d36:	c0 
c0106d37:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0106d3e:	00 
c0106d3f:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106d46:	e8 b8 96 ff ff       	call   c0100403 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106d4b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106d52:	eb 25                	jmp    c0106d79 <check_swap+0x463>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106d54:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d57:	c7 04 85 60 60 12 c0 	movl   $0xffffffff,-0x3fed9fa0(,%eax,4)
c0106d5e:	ff ff ff ff 
c0106d62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d65:	8b 14 85 60 60 12 c0 	mov    -0x3fed9fa0(,%eax,4),%edx
c0106d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d6f:	89 14 85 a0 60 12 c0 	mov    %edx,-0x3fed9f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106d76:	ff 45 ec             	incl   -0x14(%ebp)
c0106d79:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106d7d:	7e d5                	jle    c0106d54 <check_swap+0x43e>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106d7f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106d86:	e9 ec 00 00 00       	jmp    c0106e77 <check_swap+0x561>
         check_ptep[i]=0;
c0106d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d8e:	c7 04 85 f4 60 12 c0 	movl   $0x0,-0x3fed9f0c(,%eax,4)
c0106d95:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106d99:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d9c:	40                   	inc    %eax
c0106d9d:	c1 e0 0c             	shl    $0xc,%eax
c0106da0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106da7:	00 
c0106da8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106dac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106daf:	89 04 24             	mov    %eax,(%esp)
c0106db2:	e8 dd d0 ff ff       	call   c0103e94 <get_pte>
c0106db7:	89 c2                	mov    %eax,%edx
c0106db9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106dbc:	89 14 85 f4 60 12 c0 	mov    %edx,-0x3fed9f0c(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106dc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106dc6:	8b 04 85 f4 60 12 c0 	mov    -0x3fed9f0c(,%eax,4),%eax
c0106dcd:	85 c0                	test   %eax,%eax
c0106dcf:	75 24                	jne    c0106df5 <check_swap+0x4df>
c0106dd1:	c7 44 24 0c 64 ad 10 	movl   $0xc010ad64,0xc(%esp)
c0106dd8:	c0 
c0106dd9:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106de0:	c0 
c0106de1:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106de8:	00 
c0106de9:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106df0:	e8 0e 96 ff ff       	call   c0100403 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106df5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106df8:	8b 04 85 f4 60 12 c0 	mov    -0x3fed9f0c(,%eax,4),%eax
c0106dff:	8b 00                	mov    (%eax),%eax
c0106e01:	89 04 24             	mov    %eax,(%esp)
c0106e04:	e8 a6 f5 ff ff       	call   c01063af <pte2page>
c0106e09:	89 c2                	mov    %eax,%edx
c0106e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e0e:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106e15:	39 c2                	cmp    %eax,%edx
c0106e17:	74 24                	je     c0106e3d <check_swap+0x527>
c0106e19:	c7 44 24 0c 7c ad 10 	movl   $0xc010ad7c,0xc(%esp)
c0106e20:	c0 
c0106e21:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106e28:	c0 
c0106e29:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0106e30:	00 
c0106e31:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106e38:	e8 c6 95 ff ff       	call   c0100403 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106e3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e40:	8b 04 85 f4 60 12 c0 	mov    -0x3fed9f0c(,%eax,4),%eax
c0106e47:	8b 00                	mov    (%eax),%eax
c0106e49:	83 e0 01             	and    $0x1,%eax
c0106e4c:	85 c0                	test   %eax,%eax
c0106e4e:	75 24                	jne    c0106e74 <check_swap+0x55e>
c0106e50:	c7 44 24 0c a4 ad 10 	movl   $0xc010ada4,0xc(%esp)
c0106e57:	c0 
c0106e58:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106e5f:	c0 
c0106e60:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0106e67:	00 
c0106e68:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106e6f:	e8 8f 95 ff ff       	call   c0100403 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106e74:	ff 45 ec             	incl   -0x14(%ebp)
c0106e77:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106e7b:	0f 8e 0a ff ff ff    	jle    c0106d8b <check_swap+0x475>
     }
     cprintf("set up init env for check_swap over!\n");
c0106e81:	c7 04 24 c0 ad 10 c0 	movl   $0xc010adc0,(%esp)
c0106e88:	e8 1f 94 ff ff       	call   c01002ac <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106e8d:	e8 6c fa ff ff       	call   c01068fe <check_content_access>
c0106e92:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0106e95:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0106e99:	74 24                	je     c0106ebf <check_swap+0x5a9>
c0106e9b:	c7 44 24 0c e6 ad 10 	movl   $0xc010ade6,0xc(%esp)
c0106ea2:	c0 
c0106ea3:	c7 44 24 08 ce aa 10 	movl   $0xc010aace,0x8(%esp)
c0106eaa:	c0 
c0106eab:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0106eb2:	00 
c0106eb3:	c7 04 24 68 aa 10 c0 	movl   $0xc010aa68,(%esp)
c0106eba:	e8 44 95 ff ff       	call   c0100403 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ebf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ec6:	eb 1d                	jmp    c0106ee5 <check_swap+0x5cf>
         free_pages(check_rp[i],1);
c0106ec8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ecb:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106ed2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ed9:	00 
c0106eda:	89 04 24             	mov    %eax,(%esp)
c0106edd:	e8 42 c9 ff ff       	call   c0103824 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ee2:	ff 45 ec             	incl   -0x14(%ebp)
c0106ee5:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106ee9:	7e dd                	jle    c0106ec8 <check_swap+0x5b2>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0106eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106eee:	89 04 24             	mov    %eax,(%esp)
c0106ef1:	e8 78 ea ff ff       	call   c010596e <mm_destroy>
         
     nr_free = nr_free_store;
c0106ef6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106ef9:	a3 0c 61 12 c0       	mov    %eax,0xc012610c
     free_list = free_list_store;
c0106efe:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106f01:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106f04:	a3 04 61 12 c0       	mov    %eax,0xc0126104
c0106f09:	89 15 08 61 12 c0    	mov    %edx,0xc0126108

     
     le = &free_list;
c0106f0f:	c7 45 e8 04 61 12 c0 	movl   $0xc0126104,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106f16:	eb 1c                	jmp    c0106f34 <check_swap+0x61e>
         struct Page *p = le2page(le, page_link);
c0106f18:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f1b:	83 e8 0c             	sub    $0xc,%eax
c0106f1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0106f21:	ff 4d f4             	decl   -0xc(%ebp)
c0106f24:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106f27:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106f2a:	8b 40 08             	mov    0x8(%eax),%eax
c0106f2d:	29 c2                	sub    %eax,%edx
c0106f2f:	89 d0                	mov    %edx,%eax
c0106f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f37:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0106f3a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106f3d:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106f40:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106f43:	81 7d e8 04 61 12 c0 	cmpl   $0xc0126104,-0x18(%ebp)
c0106f4a:	75 cc                	jne    c0106f18 <check_swap+0x602>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f4f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f5a:	c7 04 24 ed ad 10 c0 	movl   $0xc010aded,(%esp)
c0106f61:	e8 46 93 ff ff       	call   c01002ac <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106f66:	c7 04 24 07 ae 10 c0 	movl   $0xc010ae07,(%esp)
c0106f6d:	e8 3a 93 ff ff       	call   c01002ac <cprintf>
}
c0106f72:	90                   	nop
c0106f73:	c9                   	leave  
c0106f74:	c3                   	ret    

c0106f75 <page2ppn>:
page2ppn(struct Page *page) {
c0106f75:	55                   	push   %ebp
c0106f76:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106f78:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f7b:	8b 15 28 60 12 c0    	mov    0xc0126028,%edx
c0106f81:	29 d0                	sub    %edx,%eax
c0106f83:	c1 f8 05             	sar    $0x5,%eax
}
c0106f86:	5d                   	pop    %ebp
c0106f87:	c3                   	ret    

c0106f88 <page2pa>:
page2pa(struct Page *page) {
c0106f88:	55                   	push   %ebp
c0106f89:	89 e5                	mov    %esp,%ebp
c0106f8b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0106f8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f91:	89 04 24             	mov    %eax,(%esp)
c0106f94:	e8 dc ff ff ff       	call   c0106f75 <page2ppn>
c0106f99:	c1 e0 0c             	shl    $0xc,%eax
}
c0106f9c:	c9                   	leave  
c0106f9d:	c3                   	ret    

c0106f9e <page_ref>:
page_ref(struct Page *page) {
c0106f9e:	55                   	push   %ebp
c0106f9f:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106fa1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fa4:	8b 00                	mov    (%eax),%eax
}
c0106fa6:	5d                   	pop    %ebp
c0106fa7:	c3                   	ret    

c0106fa8 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0106fa8:	55                   	push   %ebp
c0106fa9:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106fab:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fae:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106fb1:	89 10                	mov    %edx,(%eax)
}
c0106fb3:	90                   	nop
c0106fb4:	5d                   	pop    %ebp
c0106fb5:	c3                   	ret    

c0106fb6 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0106fb6:	55                   	push   %ebp
c0106fb7:	89 e5                	mov    %esp,%ebp
c0106fb9:	83 ec 10             	sub    $0x10,%esp
c0106fbc:	c7 45 fc 04 61 12 c0 	movl   $0xc0126104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0106fc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106fc6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106fc9:	89 50 04             	mov    %edx,0x4(%eax)
c0106fcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106fcf:	8b 50 04             	mov    0x4(%eax),%edx
c0106fd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106fd5:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0106fd7:	c7 05 0c 61 12 c0 00 	movl   $0x0,0xc012610c
c0106fde:	00 00 00 
}
c0106fe1:	90                   	nop
c0106fe2:	c9                   	leave  
c0106fe3:	c3                   	ret    

c0106fe4 <default_init_memmap>:
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}*/

static void
default_init_memmap(struct Page *base, size_t n) {
c0106fe4:	55                   	push   %ebp
c0106fe5:	89 e5                	mov    %esp,%ebp
c0106fe7:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);   //使用assert宏，当为假时中止程序
c0106fea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106fee:	75 24                	jne    c0107014 <default_init_memmap+0x30>
c0106ff0:	c7 44 24 0c 20 ae 10 	movl   $0xc010ae20,0xc(%esp)
c0106ff7:	c0 
c0106ff8:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0106fff:	c0 
c0107000:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0107007:	00 
c0107008:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c010700f:	e8 ef 93 ff ff       	call   c0100403 <__panic>
    struct Page *p = base;//声明一个base的Page，随后生成起始地址为base的n个连续页
c0107014:	8b 45 08             	mov    0x8(%ebp),%eax
c0107017:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) { //初始化n块物理页
c010701a:	e9 de 00 00 00       	jmp    c01070fd <default_init_memmap+0x119>
        assert(PageReserved(p)); //确保此页不是保留页，如果是，中止程序
c010701f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107022:	83 c0 04             	add    $0x4,%eax
c0107025:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010702c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010702f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107032:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107035:	0f a3 10             	bt     %edx,(%eax)
c0107038:	19 c0                	sbb    %eax,%eax
c010703a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010703d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107041:	0f 95 c0             	setne  %al
c0107044:	0f b6 c0             	movzbl %al,%eax
c0107047:	85 c0                	test   %eax,%eax
c0107049:	75 24                	jne    c010706f <default_init_memmap+0x8b>
c010704b:	c7 44 24 0c 51 ae 10 	movl   $0xc010ae51,0xc(%esp)
c0107052:	c0 
c0107053:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010705a:	c0 
c010705b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c0107062:	00 
c0107063:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c010706a:	e8 94 93 ff ff       	call   c0100403 <__panic>
        p->flags = p->property= 0; //标志位置为0
c010706f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107072:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0107079:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010707c:	8b 50 08             	mov    0x8(%eax),%edx
c010707f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107082:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(p);       //设置为保留页
c0107085:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107088:	83 c0 04             	add    $0x4,%eax
c010708b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0107092:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107095:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107098:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010709b:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);  
c010709e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01070a5:	00 
c01070a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070a9:	89 04 24             	mov    %eax,(%esp)
c01070ac:	e8 f7 fe ff ff       	call   c0106fa8 <set_page_ref>
        list_add_before(&free_list, &(p->page_link)); //加入空闲链表
c01070b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070b4:	83 c0 0c             	add    $0xc,%eax
c01070b7:	c7 45 e4 04 61 12 c0 	movl   $0xc0126104,-0x1c(%ebp)
c01070be:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01070c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070c4:	8b 00                	mov    (%eax),%eax
c01070c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01070c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01070cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01070cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c01070d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01070d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01070db:	89 10                	mov    %edx,(%eax)
c01070dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01070e0:	8b 10                	mov    (%eax),%edx
c01070e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01070e5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01070e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01070eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01070ee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01070f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01070f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01070f7:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) { //初始化n块物理页
c01070f9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01070fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107100:	c1 e0 05             	shl    $0x5,%eax
c0107103:	89 c2                	mov    %eax,%edx
c0107105:	8b 45 08             	mov    0x8(%ebp),%eax
c0107108:	01 d0                	add    %edx,%eax
c010710a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010710d:	0f 85 0c ff ff ff    	jne    c010701f <default_init_memmap+0x3b>
    }
    nr_free += n;  //空闲页总数置为n
c0107113:	8b 15 0c 61 12 c0    	mov    0xc012610c,%edx
c0107119:	8b 45 0c             	mov    0xc(%ebp),%eax
c010711c:	01 d0                	add    %edx,%eax
c010711e:	a3 0c 61 12 c0       	mov    %eax,0xc012610c
    base->property = n; //修改base的连续空页值为n
c0107123:	8b 45 08             	mov    0x8(%ebp),%eax
c0107126:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107129:	89 50 08             	mov    %edx,0x8(%eax)
}
c010712c:	90                   	nop
c010712d:	c9                   	leave  
c010712e:	c3                   	ret    

c010712f <default_alloc_pages>:
    }
    return page;
}*/

static struct Page *
default_alloc_pages(size_t n) {
c010712f:	55                   	push   %ebp
c0107130:	89 e5                	mov    %esp,%ebp
c0107132:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0); 
c0107135:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107139:	75 24                	jne    c010715f <default_alloc_pages+0x30>
c010713b:	c7 44 24 0c 20 ae 10 	movl   $0xc010ae20,0xc(%esp)
c0107142:	c0 
c0107143:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010714a:	c0 
c010714b:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0107152:	00 
c0107153:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c010715a:	e8 a4 92 ff ff       	call   c0100403 <__panic>
    if (n > nr_free) { //如果需要分配的页少于空闲页的总数,返回NULL
c010715f:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0107164:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107167:	76 0a                	jbe    c0107173 <default_alloc_pages+0x44>
        return NULL;
c0107169:	b8 00 00 00 00       	mov    $0x0,%eax
c010716e:	e9 36 01 00 00       	jmp    c01072a9 <default_alloc_pages+0x17a>
    }
    list_entry_t *le, *len; //声明一个空闲链表的头部和长度
    le = &free_list;  //空闲链表的头部
c0107173:	c7 45 f4 04 61 12 c0 	movl   $0xc0126104,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {//遍历整个链表
c010717a:	e9 09 01 00 00       	jmp    c0107288 <default_alloc_pages+0x159>
      struct Page *p = le2page(le, page_link); //转换为页
c010717f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107182:	83 e8 0c             	sub    $0xc,%eax
c0107185:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){//找到页(whose first `n` pages can be malloced)
c0107188:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010718b:	8b 40 08             	mov    0x8(%eax),%eax
c010718e:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107191:	0f 87 f1 00 00 00    	ja     c0107288 <default_alloc_pages+0x159>
        int i;
        for(i=0;i<n;i++){//对前n页进行操作
c0107197:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010719e:	eb 7b                	jmp    c010721b <default_alloc_pages+0xec>
c01071a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071a3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01071a6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01071a9:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le); 
c01071ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link); //转换为页
c01071af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071b2:	83 e8 0c             	sub    $0xc,%eax
c01071b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp); //PG_reserved = '1'
c01071b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071bb:	83 c0 04             	add    $0x4,%eax
c01071be:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c01071c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01071c8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01071cb:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01071ce:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);//PG_property = '0'
c01071d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071d4:	83 c0 04             	add    $0x4,%eax
c01071d7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01071de:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01071e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01071e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01071e7:	0f b3 10             	btr    %edx,(%eax)
c01071ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c01071f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01071f3:	8b 40 04             	mov    0x4(%eax),%eax
c01071f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01071f9:	8b 12                	mov    (%edx),%edx
c01071fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01071fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
    prev->next = next;
c0107201:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107204:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107207:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010720a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010720d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107210:	89 10                	mov    %edx,(%eax)
          list_del(le); //将此页从free_list中清除
          le = len;
c0107212:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107215:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){//对前n页进行操作
c0107218:	ff 45 f0             	incl   -0x10(%ebp)
c010721b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010721e:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107221:	0f 87 79 ff ff ff    	ja     c01071a0 <default_alloc_pages+0x71>
        }
        if(p->property>n){ //如果页块大小大于所需大小，分割页块
c0107227:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010722a:	8b 40 08             	mov    0x8(%eax),%eax
c010722d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107230:	73 12                	jae    c0107244 <default_alloc_pages+0x115>
          (le2page(le,page_link))->property = p->property-n;
c0107232:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107235:	8b 40 08             	mov    0x8(%eax),%eax
c0107238:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010723b:	83 ea 0c             	sub    $0xc,%edx
c010723e:	2b 45 08             	sub    0x8(%ebp),%eax
c0107241:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c0107244:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107247:	83 c0 04             	add    $0x4,%eax
c010724a:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0107251:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107254:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107257:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010725a:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c010725d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107260:	83 c0 04             	add    $0x4,%eax
c0107263:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c010726a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010726d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107270:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107273:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n; //减去已经分配的页块大小
c0107276:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c010727b:	2b 45 08             	sub    0x8(%ebp),%eax
c010727e:	a3 0c 61 12 c0       	mov    %eax,0xc012610c
        return p;
c0107283:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107286:	eb 21                	jmp    c01072a9 <default_alloc_pages+0x17a>
c0107288:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010728b:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
c010728e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107291:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {//遍历整个链表
c0107294:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107297:	81 7d f4 04 61 12 c0 	cmpl   $0xc0126104,-0xc(%ebp)
c010729e:	0f 85 db fe ff ff    	jne    c010717f <default_alloc_pages+0x50>
      }
    }
    return NULL;
c01072a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01072a9:	c9                   	leave  
c01072aa:	c3                   	ret    

c01072ab <default_free_pages>:
    list_add_before(le, &(base->page_link));
}*/


static void
default_free_pages(struct Page *base, size_t n) {
c01072ab:	55                   	push   %ebp
c01072ac:	89 e5                	mov    %esp,%ebp
c01072ae:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);  
c01072b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01072b5:	75 24                	jne    c01072db <default_free_pages+0x30>
c01072b7:	c7 44 24 0c 20 ae 10 	movl   $0xc010ae20,0xc(%esp)
c01072be:	c0 
c01072bf:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01072c6:	c0 
c01072c7:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01072ce:	00 
c01072cf:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01072d6:	e8 28 91 ff ff       	call   c0100403 <__panic>
    assert(PageReserved(base));    //检查需要释放的页块是否已经被分配
c01072db:	8b 45 08             	mov    0x8(%ebp),%eax
c01072de:	83 c0 04             	add    $0x4,%eax
c01072e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01072e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01072eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01072ee:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01072f1:	0f a3 10             	bt     %edx,(%eax)
c01072f4:	19 c0                	sbb    %eax,%eax
c01072f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01072f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01072fd:	0f 95 c0             	setne  %al
c0107300:	0f b6 c0             	movzbl %al,%eax
c0107303:	85 c0                	test   %eax,%eax
c0107305:	75 24                	jne    c010732b <default_free_pages+0x80>
c0107307:	c7 44 24 0c 61 ae 10 	movl   $0xc010ae61,0xc(%esp)
c010730e:	c0 
c010730f:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107316:	c0 
c0107317:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c010731e:	00 
c010731f:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107326:	e8 d8 90 ff ff       	call   c0100403 <__panic>
    list_entry_t *le = &free_list; 
c010732b:	c7 45 f4 04 61 12 c0 	movl   $0xc0126104,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {//找到释放的位置
c0107332:	eb 11                	jmp    c0107345 <default_free_pages+0x9a>
      p = le2page(le, page_link);
c0107334:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107337:	83 e8 0c             	sub    $0xc,%eax
c010733a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){    
c010733d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107340:	3b 45 08             	cmp    0x8(%ebp),%eax
c0107343:	77 1a                	ja     c010735f <default_free_pages+0xb4>
c0107345:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107348:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010734b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010734e:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {//找到释放的位置
c0107351:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107354:	81 7d f4 04 61 12 c0 	cmpl   $0xc0126104,-0xc(%ebp)
c010735b:	75 d7                	jne    c0107334 <default_free_pages+0x89>
c010735d:	eb 01                	jmp    c0107360 <default_free_pages+0xb5>
        break;
c010735f:	90                   	nop
      }
    }
    for(p=base;p<base+n;p++){              
c0107360:	8b 45 08             	mov    0x8(%ebp),%eax
c0107363:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107366:	eb 4b                	jmp    c01073b3 <default_free_pages+0x108>
      list_add_before(le, &(p->page_link)); //在这个位置开始，插入释放数量的空页
c0107368:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010736b:	8d 50 0c             	lea    0xc(%eax),%edx
c010736e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107371:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107374:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0107377:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010737a:	8b 00                	mov    (%eax),%eax
c010737c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010737f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107382:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107385:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107388:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c010738b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010738e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107391:	89 10                	mov    %edx,(%eax)
c0107393:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107396:	8b 10                	mov    (%eax),%edx
c0107398:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010739b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010739e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01073a1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01073a4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01073a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01073aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01073ad:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){              
c01073af:	83 45 f0 20          	addl   $0x20,-0x10(%ebp)
c01073b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01073b6:	c1 e0 05             	shl    $0x5,%eax
c01073b9:	89 c2                	mov    %eax,%edx
c01073bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01073be:	01 d0                	add    %edx,%eax
c01073c0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01073c3:	72 a3                	jb     c0107368 <default_free_pages+0xbd>
    }
    base->flags = 0;         //修改标志位
c01073c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01073c8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);   //修改引用次数为0 
c01073cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01073d6:	00 
c01073d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01073da:	89 04 24             	mov    %eax,(%esp)
c01073dd:	e8 c6 fb ff ff       	call   c0106fa8 <set_page_ref>
    ClearPageProperty(base);
c01073e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01073e5:	83 c0 04             	add    $0x4,%eax
c01073e8:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01073ef:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01073f2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01073f5:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01073f8:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c01073fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01073fe:	83 c0 04             	add    $0x4,%eax
c0107401:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0107408:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010740b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010740e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107411:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;      //设置连续大小为n
c0107414:	8b 45 08             	mov    0x8(%ebp),%eax
c0107417:	8b 55 0c             	mov    0xc(%ebp),%edx
c010741a:	89 50 08             	mov    %edx,0x8(%eax)
    //如果是高位，则向高地址合并
    p = le2page(le,page_link) ;
c010741d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107420:	83 e8 0c             	sub    $0xc,%eax
c0107423:	89 45 f0             	mov    %eax,-0x10(%ebp)
  //满足base+n==p，因此，尝试向后合并空闲页。
  //如果能合并，那么base的连续空闲页加上p的连续空闲页，且p的连续空闲页置为0；
  //如果之后的页不能合并，那么p->property一直为0，下面的代码不会对它产生影响。
    if( base+n == p ){
c0107426:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107429:	c1 e0 05             	shl    $0x5,%eax
c010742c:	89 c2                	mov    %eax,%edx
c010742e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107431:	01 d0                	add    %edx,%eax
c0107433:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107436:	75 1e                	jne    c0107456 <default_free_pages+0x1ab>
      base->property += p->property;
c0107438:	8b 45 08             	mov    0x8(%ebp),%eax
c010743b:	8b 50 08             	mov    0x8(%eax),%edx
c010743e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107441:	8b 40 08             	mov    0x8(%eax),%eax
c0107444:	01 c2                	add    %eax,%edx
c0107446:	8b 45 08             	mov    0x8(%ebp),%eax
c0107449:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c010744c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010744f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
     //如果是低位且在范围内，则向低地址合并
     //获取基地址页的前一个页，如果为空，那么循环查找之前所有为空，能够合并的页
    le = list_prev(&(base->page_link));
c0107456:	8b 45 08             	mov    0x8(%ebp),%eax
c0107459:	83 c0 0c             	add    $0xc,%eax
c010745c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c010745f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107462:	8b 00                	mov    (%eax),%eax
c0107464:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0107467:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010746a:	83 e8 0c             	sub    $0xc,%eax
c010746d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){ //满足条件，未分配则合并
c0107470:	81 7d f4 04 61 12 c0 	cmpl   $0xc0126104,-0xc(%ebp)
c0107477:	74 57                	je     c01074d0 <default_free_pages+0x225>
c0107479:	8b 45 08             	mov    0x8(%ebp),%eax
c010747c:	83 e8 20             	sub    $0x20,%eax
c010747f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107482:	75 4c                	jne    c01074d0 <default_free_pages+0x225>
      while(le!=&free_list){
c0107484:	eb 41                	jmp    c01074c7 <default_free_pages+0x21c>
        if(p->property){ //连续
c0107486:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107489:	8b 40 08             	mov    0x8(%eax),%eax
c010748c:	85 c0                	test   %eax,%eax
c010748e:	74 20                	je     c01074b0 <default_free_pages+0x205>
          p->property += base->property;
c0107490:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107493:	8b 50 08             	mov    0x8(%eax),%edx
c0107496:	8b 45 08             	mov    0x8(%ebp),%eax
c0107499:	8b 40 08             	mov    0x8(%eax),%eax
c010749c:	01 c2                	add    %eax,%edx
c010749e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074a1:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c01074a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01074a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          //不断更新前一个页p的property值，并将base->property置为0
          break;
c01074ae:	eb 20                	jmp    c01074d0 <default_free_pages+0x225>
c01074b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074b3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01074b6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01074b9:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c01074bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c01074be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074c1:	83 e8 0c             	sub    $0xc,%eax
c01074c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c01074c7:	81 7d f4 04 61 12 c0 	cmpl   $0xc0126104,-0xc(%ebp)
c01074ce:	75 b6                	jne    c0107486 <default_free_pages+0x1db>
      }
    }

    nr_free += n;//空闲页数量加n
c01074d0:	8b 15 0c 61 12 c0    	mov    0xc012610c,%edx
c01074d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074d9:	01 d0                	add    %edx,%eax
c01074db:	a3 0c 61 12 c0       	mov    %eax,0xc012610c
    return ;
c01074e0:	90                   	nop
} 
c01074e1:	c9                   	leave  
c01074e2:	c3                   	ret    

c01074e3 <default_nr_free_pages>:


static size_t
default_nr_free_pages(void) {
c01074e3:	55                   	push   %ebp
c01074e4:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01074e6:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
}
c01074eb:	5d                   	pop    %ebp
c01074ec:	c3                   	ret    

c01074ed <basic_check>:

static void
basic_check(void) {
c01074ed:	55                   	push   %ebp
c01074ee:	89 e5                	mov    %esp,%ebp
c01074f0:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01074f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01074fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107500:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107503:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0107506:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010750d:	e8 a7 c2 ff ff       	call   c01037b9 <alloc_pages>
c0107512:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107515:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107519:	75 24                	jne    c010753f <basic_check+0x52>
c010751b:	c7 44 24 0c 74 ae 10 	movl   $0xc010ae74,0xc(%esp)
c0107522:	c0 
c0107523:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010752a:	c0 
c010752b:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c0107532:	00 
c0107533:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c010753a:	e8 c4 8e ff ff       	call   c0100403 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010753f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107546:	e8 6e c2 ff ff       	call   c01037b9 <alloc_pages>
c010754b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010754e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107552:	75 24                	jne    c0107578 <basic_check+0x8b>
c0107554:	c7 44 24 0c 90 ae 10 	movl   $0xc010ae90,0xc(%esp)
c010755b:	c0 
c010755c:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107563:	c0 
c0107564:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c010756b:	00 
c010756c:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107573:	e8 8b 8e ff ff       	call   c0100403 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0107578:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010757f:	e8 35 c2 ff ff       	call   c01037b9 <alloc_pages>
c0107584:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107587:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010758b:	75 24                	jne    c01075b1 <basic_check+0xc4>
c010758d:	c7 44 24 0c ac ae 10 	movl   $0xc010aeac,0xc(%esp)
c0107594:	c0 
c0107595:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010759c:	c0 
c010759d:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c01075a4:	00 
c01075a5:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01075ac:	e8 52 8e ff ff       	call   c0100403 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01075b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01075b4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01075b7:	74 10                	je     c01075c9 <basic_check+0xdc>
c01075b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01075bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01075bf:	74 08                	je     c01075c9 <basic_check+0xdc>
c01075c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075c4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01075c7:	75 24                	jne    c01075ed <basic_check+0x100>
c01075c9:	c7 44 24 0c c8 ae 10 	movl   $0xc010aec8,0xc(%esp)
c01075d0:	c0 
c01075d1:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01075d8:	c0 
c01075d9:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
c01075e0:	00 
c01075e1:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01075e8:	e8 16 8e ff ff       	call   c0100403 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01075ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01075f0:	89 04 24             	mov    %eax,(%esp)
c01075f3:	e8 a6 f9 ff ff       	call   c0106f9e <page_ref>
c01075f8:	85 c0                	test   %eax,%eax
c01075fa:	75 1e                	jne    c010761a <basic_check+0x12d>
c01075fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075ff:	89 04 24             	mov    %eax,(%esp)
c0107602:	e8 97 f9 ff ff       	call   c0106f9e <page_ref>
c0107607:	85 c0                	test   %eax,%eax
c0107609:	75 0f                	jne    c010761a <basic_check+0x12d>
c010760b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010760e:	89 04 24             	mov    %eax,(%esp)
c0107611:	e8 88 f9 ff ff       	call   c0106f9e <page_ref>
c0107616:	85 c0                	test   %eax,%eax
c0107618:	74 24                	je     c010763e <basic_check+0x151>
c010761a:	c7 44 24 0c ec ae 10 	movl   $0xc010aeec,0xc(%esp)
c0107621:	c0 
c0107622:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107629:	c0 
c010762a:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c0107631:	00 
c0107632:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107639:	e8 c5 8d ff ff       	call   c0100403 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010763e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107641:	89 04 24             	mov    %eax,(%esp)
c0107644:	e8 3f f9 ff ff       	call   c0106f88 <page2pa>
c0107649:	8b 15 80 5f 12 c0    	mov    0xc0125f80,%edx
c010764f:	c1 e2 0c             	shl    $0xc,%edx
c0107652:	39 d0                	cmp    %edx,%eax
c0107654:	72 24                	jb     c010767a <basic_check+0x18d>
c0107656:	c7 44 24 0c 28 af 10 	movl   $0xc010af28,0xc(%esp)
c010765d:	c0 
c010765e:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107665:	c0 
c0107666:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
c010766d:	00 
c010766e:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107675:	e8 89 8d ff ff       	call   c0100403 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010767a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010767d:	89 04 24             	mov    %eax,(%esp)
c0107680:	e8 03 f9 ff ff       	call   c0106f88 <page2pa>
c0107685:	8b 15 80 5f 12 c0    	mov    0xc0125f80,%edx
c010768b:	c1 e2 0c             	shl    $0xc,%edx
c010768e:	39 d0                	cmp    %edx,%eax
c0107690:	72 24                	jb     c01076b6 <basic_check+0x1c9>
c0107692:	c7 44 24 0c 45 af 10 	movl   $0xc010af45,0xc(%esp)
c0107699:	c0 
c010769a:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01076a1:	c0 
c01076a2:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c01076a9:	00 
c01076aa:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01076b1:	e8 4d 8d ff ff       	call   c0100403 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01076b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076b9:	89 04 24             	mov    %eax,(%esp)
c01076bc:	e8 c7 f8 ff ff       	call   c0106f88 <page2pa>
c01076c1:	8b 15 80 5f 12 c0    	mov    0xc0125f80,%edx
c01076c7:	c1 e2 0c             	shl    $0xc,%edx
c01076ca:	39 d0                	cmp    %edx,%eax
c01076cc:	72 24                	jb     c01076f2 <basic_check+0x205>
c01076ce:	c7 44 24 0c 62 af 10 	movl   $0xc010af62,0xc(%esp)
c01076d5:	c0 
c01076d6:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01076dd:	c0 
c01076de:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
c01076e5:	00 
c01076e6:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01076ed:	e8 11 8d ff ff       	call   c0100403 <__panic>

    list_entry_t free_list_store = free_list;
c01076f2:	a1 04 61 12 c0       	mov    0xc0126104,%eax
c01076f7:	8b 15 08 61 12 c0    	mov    0xc0126108,%edx
c01076fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107700:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107703:	c7 45 dc 04 61 12 c0 	movl   $0xc0126104,-0x24(%ebp)
    elm->prev = elm->next = elm;
c010770a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010770d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107710:	89 50 04             	mov    %edx,0x4(%eax)
c0107713:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107716:	8b 50 04             	mov    0x4(%eax),%edx
c0107719:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010771c:	89 10                	mov    %edx,(%eax)
c010771e:	c7 45 e0 04 61 12 c0 	movl   $0xc0126104,-0x20(%ebp)
    return list->next == list;
c0107725:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107728:	8b 40 04             	mov    0x4(%eax),%eax
c010772b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010772e:	0f 94 c0             	sete   %al
c0107731:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107734:	85 c0                	test   %eax,%eax
c0107736:	75 24                	jne    c010775c <basic_check+0x26f>
c0107738:	c7 44 24 0c 7f af 10 	movl   $0xc010af7f,0xc(%esp)
c010773f:	c0 
c0107740:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107747:	c0 
c0107748:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
c010774f:	00 
c0107750:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107757:	e8 a7 8c ff ff       	call   c0100403 <__panic>

    unsigned int nr_free_store = nr_free;
c010775c:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0107761:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0107764:	c7 05 0c 61 12 c0 00 	movl   $0x0,0xc012610c
c010776b:	00 00 00 

    assert(alloc_page() == NULL);
c010776e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107775:	e8 3f c0 ff ff       	call   c01037b9 <alloc_pages>
c010777a:	85 c0                	test   %eax,%eax
c010777c:	74 24                	je     c01077a2 <basic_check+0x2b5>
c010777e:	c7 44 24 0c 96 af 10 	movl   $0xc010af96,0xc(%esp)
c0107785:	c0 
c0107786:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010778d:	c0 
c010778e:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
c0107795:	00 
c0107796:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c010779d:	e8 61 8c ff ff       	call   c0100403 <__panic>

    free_page(p0);
c01077a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01077a9:	00 
c01077aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077ad:	89 04 24             	mov    %eax,(%esp)
c01077b0:	e8 6f c0 ff ff       	call   c0103824 <free_pages>
    free_page(p1);
c01077b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01077bc:	00 
c01077bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077c0:	89 04 24             	mov    %eax,(%esp)
c01077c3:	e8 5c c0 ff ff       	call   c0103824 <free_pages>
    free_page(p2);
c01077c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01077cf:	00 
c01077d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077d3:	89 04 24             	mov    %eax,(%esp)
c01077d6:	e8 49 c0 ff ff       	call   c0103824 <free_pages>
    assert(nr_free == 3);
c01077db:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c01077e0:	83 f8 03             	cmp    $0x3,%eax
c01077e3:	74 24                	je     c0107809 <basic_check+0x31c>
c01077e5:	c7 44 24 0c ab af 10 	movl   $0xc010afab,0xc(%esp)
c01077ec:	c0 
c01077ed:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01077f4:	c0 
c01077f5:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
c01077fc:	00 
c01077fd:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107804:	e8 fa 8b ff ff       	call   c0100403 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0107809:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107810:	e8 a4 bf ff ff       	call   c01037b9 <alloc_pages>
c0107815:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107818:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010781c:	75 24                	jne    c0107842 <basic_check+0x355>
c010781e:	c7 44 24 0c 74 ae 10 	movl   $0xc010ae74,0xc(%esp)
c0107825:	c0 
c0107826:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010782d:	c0 
c010782e:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0107835:	00 
c0107836:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c010783d:	e8 c1 8b ff ff       	call   c0100403 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0107842:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107849:	e8 6b bf ff ff       	call   c01037b9 <alloc_pages>
c010784e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107851:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107855:	75 24                	jne    c010787b <basic_check+0x38e>
c0107857:	c7 44 24 0c 90 ae 10 	movl   $0xc010ae90,0xc(%esp)
c010785e:	c0 
c010785f:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107866:	c0 
c0107867:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
c010786e:	00 
c010786f:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107876:	e8 88 8b ff ff       	call   c0100403 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010787b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107882:	e8 32 bf ff ff       	call   c01037b9 <alloc_pages>
c0107887:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010788a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010788e:	75 24                	jne    c01078b4 <basic_check+0x3c7>
c0107890:	c7 44 24 0c ac ae 10 	movl   $0xc010aeac,0xc(%esp)
c0107897:	c0 
c0107898:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010789f:	c0 
c01078a0:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c01078a7:	00 
c01078a8:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01078af:	e8 4f 8b ff ff       	call   c0100403 <__panic>

    assert(alloc_page() == NULL);
c01078b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01078bb:	e8 f9 be ff ff       	call   c01037b9 <alloc_pages>
c01078c0:	85 c0                	test   %eax,%eax
c01078c2:	74 24                	je     c01078e8 <basic_check+0x3fb>
c01078c4:	c7 44 24 0c 96 af 10 	movl   $0xc010af96,0xc(%esp)
c01078cb:	c0 
c01078cc:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01078d3:	c0 
c01078d4:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c01078db:	00 
c01078dc:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01078e3:	e8 1b 8b ff ff       	call   c0100403 <__panic>

    free_page(p0);
c01078e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01078ef:	00 
c01078f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078f3:	89 04 24             	mov    %eax,(%esp)
c01078f6:	e8 29 bf ff ff       	call   c0103824 <free_pages>
c01078fb:	c7 45 d8 04 61 12 c0 	movl   $0xc0126104,-0x28(%ebp)
c0107902:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107905:	8b 40 04             	mov    0x4(%eax),%eax
c0107908:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010790b:	0f 94 c0             	sete   %al
c010790e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0107911:	85 c0                	test   %eax,%eax
c0107913:	74 24                	je     c0107939 <basic_check+0x44c>
c0107915:	c7 44 24 0c b8 af 10 	movl   $0xc010afb8,0xc(%esp)
c010791c:	c0 
c010791d:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107924:	c0 
c0107925:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c010792c:	00 
c010792d:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107934:	e8 ca 8a ff ff       	call   c0100403 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0107939:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107940:	e8 74 be ff ff       	call   c01037b9 <alloc_pages>
c0107945:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107948:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010794b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010794e:	74 24                	je     c0107974 <basic_check+0x487>
c0107950:	c7 44 24 0c d0 af 10 	movl   $0xc010afd0,0xc(%esp)
c0107957:	c0 
c0107958:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c010795f:	c0 
c0107960:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c0107967:	00 
c0107968:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c010796f:	e8 8f 8a ff ff       	call   c0100403 <__panic>
    assert(alloc_page() == NULL);
c0107974:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010797b:	e8 39 be ff ff       	call   c01037b9 <alloc_pages>
c0107980:	85 c0                	test   %eax,%eax
c0107982:	74 24                	je     c01079a8 <basic_check+0x4bb>
c0107984:	c7 44 24 0c 96 af 10 	movl   $0xc010af96,0xc(%esp)
c010798b:	c0 
c010798c:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107993:	c0 
c0107994:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c010799b:	00 
c010799c:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01079a3:	e8 5b 8a ff ff       	call   c0100403 <__panic>

    assert(nr_free == 0);
c01079a8:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c01079ad:	85 c0                	test   %eax,%eax
c01079af:	74 24                	je     c01079d5 <basic_check+0x4e8>
c01079b1:	c7 44 24 0c e9 af 10 	movl   $0xc010afe9,0xc(%esp)
c01079b8:	c0 
c01079b9:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01079c0:	c0 
c01079c1:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
c01079c8:	00 
c01079c9:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01079d0:	e8 2e 8a ff ff       	call   c0100403 <__panic>
    free_list = free_list_store;
c01079d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01079d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01079db:	a3 04 61 12 c0       	mov    %eax,0xc0126104
c01079e0:	89 15 08 61 12 c0    	mov    %edx,0xc0126108
    nr_free = nr_free_store;
c01079e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079e9:	a3 0c 61 12 c0       	mov    %eax,0xc012610c

    free_page(p);
c01079ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01079f5:	00 
c01079f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079f9:	89 04 24             	mov    %eax,(%esp)
c01079fc:	e8 23 be ff ff       	call   c0103824 <free_pages>
    free_page(p1);
c0107a01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a08:	00 
c0107a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a0c:	89 04 24             	mov    %eax,(%esp)
c0107a0f:	e8 10 be ff ff       	call   c0103824 <free_pages>
    free_page(p2);
c0107a14:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a1b:	00 
c0107a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a1f:	89 04 24             	mov    %eax,(%esp)
c0107a22:	e8 fd bd ff ff       	call   c0103824 <free_pages>
}
c0107a27:	90                   	nop
c0107a28:	c9                   	leave  
c0107a29:	c3                   	ret    

c0107a2a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0107a2a:	55                   	push   %ebp
c0107a2b:	89 e5                	mov    %esp,%ebp
c0107a2d:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0107a33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107a3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0107a41:	c7 45 ec 04 61 12 c0 	movl   $0xc0126104,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107a48:	eb 6a                	jmp    c0107ab4 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0107a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a4d:	83 e8 0c             	sub    $0xc,%eax
c0107a50:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0107a53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107a56:	83 c0 04             	add    $0x4,%eax
c0107a59:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0107a60:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107a63:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107a66:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107a69:	0f a3 10             	bt     %edx,(%eax)
c0107a6c:	19 c0                	sbb    %eax,%eax
c0107a6e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0107a71:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107a75:	0f 95 c0             	setne  %al
c0107a78:	0f b6 c0             	movzbl %al,%eax
c0107a7b:	85 c0                	test   %eax,%eax
c0107a7d:	75 24                	jne    c0107aa3 <default_check+0x79>
c0107a7f:	c7 44 24 0c f6 af 10 	movl   $0xc010aff6,0xc(%esp)
c0107a86:	c0 
c0107a87:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107a8e:	c0 
c0107a8f:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
c0107a96:	00 
c0107a97:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107a9e:	e8 60 89 ff ff       	call   c0100403 <__panic>
        count ++, total += p->property;
c0107aa3:	ff 45 f4             	incl   -0xc(%ebp)
c0107aa6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107aa9:	8b 50 08             	mov    0x8(%eax),%edx
c0107aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107aaf:	01 d0                	add    %edx,%eax
c0107ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107ab7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0107aba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107abd:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0107ac0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107ac3:	81 7d ec 04 61 12 c0 	cmpl   $0xc0126104,-0x14(%ebp)
c0107aca:	0f 85 7a ff ff ff    	jne    c0107a4a <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0107ad0:	e8 82 bd ff ff       	call   c0103857 <nr_free_pages>
c0107ad5:	89 c2                	mov    %eax,%edx
c0107ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ada:	39 c2                	cmp    %eax,%edx
c0107adc:	74 24                	je     c0107b02 <default_check+0xd8>
c0107ade:	c7 44 24 0c 06 b0 10 	movl   $0xc010b006,0xc(%esp)
c0107ae5:	c0 
c0107ae6:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107aed:	c0 
c0107aee:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
c0107af5:	00 
c0107af6:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107afd:	e8 01 89 ff ff       	call   c0100403 <__panic>

    basic_check();
c0107b02:	e8 e6 f9 ff ff       	call   c01074ed <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0107b07:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107b0e:	e8 a6 bc ff ff       	call   c01037b9 <alloc_pages>
c0107b13:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0107b16:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107b1a:	75 24                	jne    c0107b40 <default_check+0x116>
c0107b1c:	c7 44 24 0c 1f b0 10 	movl   $0xc010b01f,0xc(%esp)
c0107b23:	c0 
c0107b24:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107b2b:	c0 
c0107b2c:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
c0107b33:	00 
c0107b34:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107b3b:	e8 c3 88 ff ff       	call   c0100403 <__panic>
    assert(!PageProperty(p0));
c0107b40:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b43:	83 c0 04             	add    $0x4,%eax
c0107b46:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0107b4d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107b50:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107b53:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107b56:	0f a3 10             	bt     %edx,(%eax)
c0107b59:	19 c0                	sbb    %eax,%eax
c0107b5b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0107b5e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0107b62:	0f 95 c0             	setne  %al
c0107b65:	0f b6 c0             	movzbl %al,%eax
c0107b68:	85 c0                	test   %eax,%eax
c0107b6a:	74 24                	je     c0107b90 <default_check+0x166>
c0107b6c:	c7 44 24 0c 2a b0 10 	movl   $0xc010b02a,0xc(%esp)
c0107b73:	c0 
c0107b74:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107b7b:	c0 
c0107b7c:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
c0107b83:	00 
c0107b84:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107b8b:	e8 73 88 ff ff       	call   c0100403 <__panic>

    list_entry_t free_list_store = free_list;
c0107b90:	a1 04 61 12 c0       	mov    0xc0126104,%eax
c0107b95:	8b 15 08 61 12 c0    	mov    0xc0126108,%edx
c0107b9b:	89 45 80             	mov    %eax,-0x80(%ebp)
c0107b9e:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0107ba1:	c7 45 b0 04 61 12 c0 	movl   $0xc0126104,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0107ba8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107bab:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0107bae:	89 50 04             	mov    %edx,0x4(%eax)
c0107bb1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107bb4:	8b 50 04             	mov    0x4(%eax),%edx
c0107bb7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107bba:	89 10                	mov    %edx,(%eax)
c0107bbc:	c7 45 b4 04 61 12 c0 	movl   $0xc0126104,-0x4c(%ebp)
    return list->next == list;
c0107bc3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107bc6:	8b 40 04             	mov    0x4(%eax),%eax
c0107bc9:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0107bcc:	0f 94 c0             	sete   %al
c0107bcf:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107bd2:	85 c0                	test   %eax,%eax
c0107bd4:	75 24                	jne    c0107bfa <default_check+0x1d0>
c0107bd6:	c7 44 24 0c 7f af 10 	movl   $0xc010af7f,0xc(%esp)
c0107bdd:	c0 
c0107bde:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107be5:	c0 
c0107be6:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
c0107bed:	00 
c0107bee:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107bf5:	e8 09 88 ff ff       	call   c0100403 <__panic>
    assert(alloc_page() == NULL);
c0107bfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107c01:	e8 b3 bb ff ff       	call   c01037b9 <alloc_pages>
c0107c06:	85 c0                	test   %eax,%eax
c0107c08:	74 24                	je     c0107c2e <default_check+0x204>
c0107c0a:	c7 44 24 0c 96 af 10 	movl   $0xc010af96,0xc(%esp)
c0107c11:	c0 
c0107c12:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107c19:	c0 
c0107c1a:	c7 44 24 04 af 01 00 	movl   $0x1af,0x4(%esp)
c0107c21:	00 
c0107c22:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107c29:	e8 d5 87 ff ff       	call   c0100403 <__panic>

    unsigned int nr_free_store = nr_free;
c0107c2e:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0107c33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0107c36:	c7 05 0c 61 12 c0 00 	movl   $0x0,0xc012610c
c0107c3d:	00 00 00 

    free_pages(p0 + 2, 3);
c0107c40:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c43:	83 c0 40             	add    $0x40,%eax
c0107c46:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0107c4d:	00 
c0107c4e:	89 04 24             	mov    %eax,(%esp)
c0107c51:	e8 ce bb ff ff       	call   c0103824 <free_pages>
    assert(alloc_pages(4) == NULL);
c0107c56:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0107c5d:	e8 57 bb ff ff       	call   c01037b9 <alloc_pages>
c0107c62:	85 c0                	test   %eax,%eax
c0107c64:	74 24                	je     c0107c8a <default_check+0x260>
c0107c66:	c7 44 24 0c 3c b0 10 	movl   $0xc010b03c,0xc(%esp)
c0107c6d:	c0 
c0107c6e:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107c75:	c0 
c0107c76:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
c0107c7d:	00 
c0107c7e:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107c85:	e8 79 87 ff ff       	call   c0100403 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0107c8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c8d:	83 c0 40             	add    $0x40,%eax
c0107c90:	83 c0 04             	add    $0x4,%eax
c0107c93:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0107c9a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107c9d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107ca0:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0107ca3:	0f a3 10             	bt     %edx,(%eax)
c0107ca6:	19 c0                	sbb    %eax,%eax
c0107ca8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0107cab:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0107caf:	0f 95 c0             	setne  %al
c0107cb2:	0f b6 c0             	movzbl %al,%eax
c0107cb5:	85 c0                	test   %eax,%eax
c0107cb7:	74 0e                	je     c0107cc7 <default_check+0x29d>
c0107cb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cbc:	83 c0 40             	add    $0x40,%eax
c0107cbf:	8b 40 08             	mov    0x8(%eax),%eax
c0107cc2:	83 f8 03             	cmp    $0x3,%eax
c0107cc5:	74 24                	je     c0107ceb <default_check+0x2c1>
c0107cc7:	c7 44 24 0c 54 b0 10 	movl   $0xc010b054,0xc(%esp)
c0107cce:	c0 
c0107ccf:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107cd6:	c0 
c0107cd7:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c0107cde:	00 
c0107cdf:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107ce6:	e8 18 87 ff ff       	call   c0100403 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0107ceb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0107cf2:	e8 c2 ba ff ff       	call   c01037b9 <alloc_pages>
c0107cf7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107cfa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107cfe:	75 24                	jne    c0107d24 <default_check+0x2fa>
c0107d00:	c7 44 24 0c 80 b0 10 	movl   $0xc010b080,0xc(%esp)
c0107d07:	c0 
c0107d08:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107d0f:	c0 
c0107d10:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c0107d17:	00 
c0107d18:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107d1f:	e8 df 86 ff ff       	call   c0100403 <__panic>
    assert(alloc_page() == NULL);
c0107d24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107d2b:	e8 89 ba ff ff       	call   c01037b9 <alloc_pages>
c0107d30:	85 c0                	test   %eax,%eax
c0107d32:	74 24                	je     c0107d58 <default_check+0x32e>
c0107d34:	c7 44 24 0c 96 af 10 	movl   $0xc010af96,0xc(%esp)
c0107d3b:	c0 
c0107d3c:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107d43:	c0 
c0107d44:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
c0107d4b:	00 
c0107d4c:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107d53:	e8 ab 86 ff ff       	call   c0100403 <__panic>
    assert(p0 + 2 == p1);
c0107d58:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d5b:	83 c0 40             	add    $0x40,%eax
c0107d5e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107d61:	74 24                	je     c0107d87 <default_check+0x35d>
c0107d63:	c7 44 24 0c 9e b0 10 	movl   $0xc010b09e,0xc(%esp)
c0107d6a:	c0 
c0107d6b:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107d72:	c0 
c0107d73:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
c0107d7a:	00 
c0107d7b:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107d82:	e8 7c 86 ff ff       	call   c0100403 <__panic>

    p2 = p0 + 1;
c0107d87:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d8a:	83 c0 20             	add    $0x20,%eax
c0107d8d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0107d90:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107d97:	00 
c0107d98:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d9b:	89 04 24             	mov    %eax,(%esp)
c0107d9e:	e8 81 ba ff ff       	call   c0103824 <free_pages>
    free_pages(p1, 3);
c0107da3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0107daa:	00 
c0107dab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107dae:	89 04 24             	mov    %eax,(%esp)
c0107db1:	e8 6e ba ff ff       	call   c0103824 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0107db6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107db9:	83 c0 04             	add    $0x4,%eax
c0107dbc:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0107dc3:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107dc6:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107dc9:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0107dcc:	0f a3 10             	bt     %edx,(%eax)
c0107dcf:	19 c0                	sbb    %eax,%eax
c0107dd1:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0107dd4:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0107dd8:	0f 95 c0             	setne  %al
c0107ddb:	0f b6 c0             	movzbl %al,%eax
c0107dde:	85 c0                	test   %eax,%eax
c0107de0:	74 0b                	je     c0107ded <default_check+0x3c3>
c0107de2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107de5:	8b 40 08             	mov    0x8(%eax),%eax
c0107de8:	83 f8 01             	cmp    $0x1,%eax
c0107deb:	74 24                	je     c0107e11 <default_check+0x3e7>
c0107ded:	c7 44 24 0c ac b0 10 	movl   $0xc010b0ac,0xc(%esp)
c0107df4:	c0 
c0107df5:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107dfc:	c0 
c0107dfd:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
c0107e04:	00 
c0107e05:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107e0c:	e8 f2 85 ff ff       	call   c0100403 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0107e11:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107e14:	83 c0 04             	add    $0x4,%eax
c0107e17:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0107e1e:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107e21:	8b 45 90             	mov    -0x70(%ebp),%eax
c0107e24:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0107e27:	0f a3 10             	bt     %edx,(%eax)
c0107e2a:	19 c0                	sbb    %eax,%eax
c0107e2c:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0107e2f:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0107e33:	0f 95 c0             	setne  %al
c0107e36:	0f b6 c0             	movzbl %al,%eax
c0107e39:	85 c0                	test   %eax,%eax
c0107e3b:	74 0b                	je     c0107e48 <default_check+0x41e>
c0107e3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107e40:	8b 40 08             	mov    0x8(%eax),%eax
c0107e43:	83 f8 03             	cmp    $0x3,%eax
c0107e46:	74 24                	je     c0107e6c <default_check+0x442>
c0107e48:	c7 44 24 0c d4 b0 10 	movl   $0xc010b0d4,0xc(%esp)
c0107e4f:	c0 
c0107e50:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107e57:	c0 
c0107e58:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
c0107e5f:	00 
c0107e60:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107e67:	e8 97 85 ff ff       	call   c0100403 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0107e6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107e73:	e8 41 b9 ff ff       	call   c01037b9 <alloc_pages>
c0107e78:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107e7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e7e:	83 e8 20             	sub    $0x20,%eax
c0107e81:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107e84:	74 24                	je     c0107eaa <default_check+0x480>
c0107e86:	c7 44 24 0c fa b0 10 	movl   $0xc010b0fa,0xc(%esp)
c0107e8d:	c0 
c0107e8e:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107e95:	c0 
c0107e96:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
c0107e9d:	00 
c0107e9e:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107ea5:	e8 59 85 ff ff       	call   c0100403 <__panic>
    free_page(p0);
c0107eaa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107eb1:	00 
c0107eb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107eb5:	89 04 24             	mov    %eax,(%esp)
c0107eb8:	e8 67 b9 ff ff       	call   c0103824 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0107ebd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0107ec4:	e8 f0 b8 ff ff       	call   c01037b9 <alloc_pages>
c0107ec9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107ecc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ecf:	83 c0 20             	add    $0x20,%eax
c0107ed2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107ed5:	74 24                	je     c0107efb <default_check+0x4d1>
c0107ed7:	c7 44 24 0c 18 b1 10 	movl   $0xc010b118,0xc(%esp)
c0107ede:	c0 
c0107edf:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107ee6:	c0 
c0107ee7:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c0107eee:	00 
c0107eef:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107ef6:	e8 08 85 ff ff       	call   c0100403 <__panic>

    free_pages(p0, 2);
c0107efb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0107f02:	00 
c0107f03:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f06:	89 04 24             	mov    %eax,(%esp)
c0107f09:	e8 16 b9 ff ff       	call   c0103824 <free_pages>
    free_page(p2);
c0107f0e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107f15:	00 
c0107f16:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107f19:	89 04 24             	mov    %eax,(%esp)
c0107f1c:	e8 03 b9 ff ff       	call   c0103824 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0107f21:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107f28:	e8 8c b8 ff ff       	call   c01037b9 <alloc_pages>
c0107f2d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107f30:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107f34:	75 24                	jne    c0107f5a <default_check+0x530>
c0107f36:	c7 44 24 0c 38 b1 10 	movl   $0xc010b138,0xc(%esp)
c0107f3d:	c0 
c0107f3e:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107f45:	c0 
c0107f46:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
c0107f4d:	00 
c0107f4e:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107f55:	e8 a9 84 ff ff       	call   c0100403 <__panic>
    assert(alloc_page() == NULL);
c0107f5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107f61:	e8 53 b8 ff ff       	call   c01037b9 <alloc_pages>
c0107f66:	85 c0                	test   %eax,%eax
c0107f68:	74 24                	je     c0107f8e <default_check+0x564>
c0107f6a:	c7 44 24 0c 96 af 10 	movl   $0xc010af96,0xc(%esp)
c0107f71:	c0 
c0107f72:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107f79:	c0 
c0107f7a:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
c0107f81:	00 
c0107f82:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107f89:	e8 75 84 ff ff       	call   c0100403 <__panic>

    assert(nr_free == 0);
c0107f8e:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0107f93:	85 c0                	test   %eax,%eax
c0107f95:	74 24                	je     c0107fbb <default_check+0x591>
c0107f97:	c7 44 24 0c e9 af 10 	movl   $0xc010afe9,0xc(%esp)
c0107f9e:	c0 
c0107f9f:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0107fa6:	c0 
c0107fa7:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
c0107fae:	00 
c0107faf:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0107fb6:	e8 48 84 ff ff       	call   c0100403 <__panic>
    nr_free = nr_free_store;
c0107fbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107fbe:	a3 0c 61 12 c0       	mov    %eax,0xc012610c

    free_list = free_list_store;
c0107fc3:	8b 45 80             	mov    -0x80(%ebp),%eax
c0107fc6:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0107fc9:	a3 04 61 12 c0       	mov    %eax,0xc0126104
c0107fce:	89 15 08 61 12 c0    	mov    %edx,0xc0126108
    free_pages(p0, 5);
c0107fd4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0107fdb:	00 
c0107fdc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fdf:	89 04 24             	mov    %eax,(%esp)
c0107fe2:	e8 3d b8 ff ff       	call   c0103824 <free_pages>

    le = &free_list;
c0107fe7:	c7 45 ec 04 61 12 c0 	movl   $0xc0126104,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107fee:	eb 5a                	jmp    c010804a <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c0107ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107ff3:	8b 40 04             	mov    0x4(%eax),%eax
c0107ff6:	8b 00                	mov    (%eax),%eax
c0107ff8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107ffb:	75 0d                	jne    c010800a <default_check+0x5e0>
c0107ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108000:	8b 00                	mov    (%eax),%eax
c0108002:	8b 40 04             	mov    0x4(%eax),%eax
c0108005:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108008:	74 24                	je     c010802e <default_check+0x604>
c010800a:	c7 44 24 0c 58 b1 10 	movl   $0xc010b158,0xc(%esp)
c0108011:	c0 
c0108012:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0108019:	c0 
c010801a:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c0108021:	00 
c0108022:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0108029:	e8 d5 83 ff ff       	call   c0100403 <__panic>
        struct Page *p = le2page(le, page_link);
c010802e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108031:	83 e8 0c             	sub    $0xc,%eax
c0108034:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0108037:	ff 4d f4             	decl   -0xc(%ebp)
c010803a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010803d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108040:	8b 40 08             	mov    0x8(%eax),%eax
c0108043:	29 c2                	sub    %eax,%edx
c0108045:	89 d0                	mov    %edx,%eax
c0108047:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010804a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010804d:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0108050:	8b 45 88             	mov    -0x78(%ebp),%eax
c0108053:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0108056:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108059:	81 7d ec 04 61 12 c0 	cmpl   $0xc0126104,-0x14(%ebp)
c0108060:	75 8e                	jne    c0107ff0 <default_check+0x5c6>
    }
    assert(count == 0);
c0108062:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108066:	74 24                	je     c010808c <default_check+0x662>
c0108068:	c7 44 24 0c 85 b1 10 	movl   $0xc010b185,0xc(%esp)
c010806f:	c0 
c0108070:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c0108077:	c0 
c0108078:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c010807f:	00 
c0108080:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c0108087:	e8 77 83 ff ff       	call   c0100403 <__panic>
    assert(total == 0);
c010808c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108090:	74 24                	je     c01080b6 <default_check+0x68c>
c0108092:	c7 44 24 0c 90 b1 10 	movl   $0xc010b190,0xc(%esp)
c0108099:	c0 
c010809a:	c7 44 24 08 26 ae 10 	movl   $0xc010ae26,0x8(%esp)
c01080a1:	c0 
c01080a2:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c01080a9:	00 
c01080aa:	c7 04 24 3b ae 10 c0 	movl   $0xc010ae3b,(%esp)
c01080b1:	e8 4d 83 ff ff       	call   c0100403 <__panic>
}
c01080b6:	90                   	nop
c01080b7:	c9                   	leave  
c01080b8:	c3                   	ret    

c01080b9 <_clock_init_mm>:

list_entry_t pra_list_head;

static int
_clock_init_mm(struct mm_struct *mm)
{     
c01080b9:	55                   	push   %ebp
c01080ba:	89 e5                	mov    %esp,%ebp
c01080bc:	83 ec 10             	sub    $0x10,%esp
c01080bf:	c7 45 fc 2c 60 12 c0 	movl   $0xc012602c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01080c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01080c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01080cc:	89 50 04             	mov    %edx,0x4(%eax)
c01080cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01080d2:	8b 50 04             	mov    0x4(%eax),%edx
c01080d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01080d8:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01080da:	8b 45 08             	mov    0x8(%ebp),%eax
c01080dd:	c7 40 14 2c 60 12 c0 	movl   $0xc012602c,0x14(%eax)
     return 0;
c01080e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01080e9:	c9                   	leave  
c01080ea:	c3                   	ret    

c01080eb <_clock_map_swappable>:
//此处和FIFO的初始化方法相同

static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01080eb:	55                   	push   %ebp
c01080ec:	89 e5                	mov    %esp,%ebp
c01080ee:	83 ec 48             	sub    $0x48,%esp
    //换入页的在链表中的位置并不影响，因此将其插入到链表最末端。
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01080f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01080f4:	8b 40 14             	mov    0x14(%eax),%eax
c01080f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01080fa:	8b 45 10             	mov    0x10(%ebp),%eax
c01080fd:	83 c0 14             	add    $0x14,%eax
c0108100:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert(entry != NULL && head != NULL);// 将新页插入到链表最后
c0108103:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108107:	74 06                	je     c010810f <_clock_map_swappable+0x24>
c0108109:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010810d:	75 24                	jne    c0108133 <_clock_map_swappable+0x48>
c010810f:	c7 44 24 0c cc b1 10 	movl   $0xc010b1cc,0xc(%esp)
c0108116:	c0 
c0108117:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c010811e:	c0 
c010811f:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
c0108126:	00 
c0108127:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c010812e:	e8 d0 82 ff ff       	call   c0100403 <__panic>
    list_add(head -> prev, entry);// 新插入的页dirty bit标记为0.
c0108133:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108136:	8b 00                	mov    (%eax),%eax
c0108138:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010813b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010813e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108144:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108147:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010814a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm, listelm->next);
c010814d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108150:	8b 40 04             	mov    0x4(%eax),%eax
c0108153:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108156:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108159:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010815c:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010815f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c0108162:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108165:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108168:	89 10                	mov    %edx,(%eax)
c010816a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010816d:	8b 10                	mov    (%eax),%edx
c010816f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108172:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108175:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108178:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010817b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010817e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108181:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108184:	89 10                	mov    %edx,(%eax)
    struct Page *ptr = le2page(entry, pra_page_link);
c0108186:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108189:	83 e8 14             	sub    $0x14,%eax
c010818c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
c010818f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108192:	8b 50 1c             	mov    0x1c(%eax),%edx
c0108195:	8b 45 08             	mov    0x8(%ebp),%eax
c0108198:	8b 40 0c             	mov    0xc(%eax),%eax
c010819b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01081a2:	00 
c01081a3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01081a7:	89 04 24             	mov    %eax,(%esp)
c01081aa:	e8 e5 bc ff ff       	call   c0103e94 <get_pte>
c01081af:	89 45 e8             	mov    %eax,-0x18(%ebp)
    *pte &= ~PTE_D;
c01081b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081b5:	8b 00                	mov    (%eax),%eax
c01081b7:	83 e0 bf             	and    $0xffffffbf,%eax
c01081ba:	89 c2                	mov    %eax,%edx
c01081bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081bf:	89 10                	mov    %edx,(%eax)
    return 0;
c01081c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081c6:	c9                   	leave  
c01081c7:	c3                   	ret    

c01081c8 <_clock_swap_out_victim>:


static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c01081c8:	55                   	push   %ebp
c01081c9:	89 e5                	mov    %esp,%ebp
c01081cb:	83 ec 48             	sub    $0x48,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01081ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01081d1:	8b 40 14             	mov    0x14(%eax),%eax
c01081d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head != NULL);
c01081d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01081db:	75 24                	jne    c0108201 <_clock_swap_out_victim+0x39>
c01081dd:	c7 44 24 0c 14 b2 10 	movl   $0xc010b214,0xc(%esp)
c01081e4:	c0 
c01081e5:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01081ec:	c0 
c01081ed:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
c01081f4:	00 
c01081f5:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c01081fc:	e8 02 82 ff ff       	call   c0100403 <__panic>
     assert(in_tick==0);
c0108201:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108205:	74 24                	je     c010822b <_clock_swap_out_victim+0x63>
c0108207:	c7 44 24 0c 21 b2 10 	movl   $0xc010b221,0xc(%esp)
c010820e:	c0 
c010820f:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c0108216:	c0 
c0108217:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
c010821e:	00 
c010821f:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108226:	e8 d8 81 ff ff       	call   c0100403 <__panic>

     list_entry_t *p = head;
c010822b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010822e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108231:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108234:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0108237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010823a:	8b 40 04             	mov    0x4(%eax),%eax
     while (1) {
         p = list_next(p);
c010823d:	89 45 f4             	mov    %eax,-0xc(%ebp)
         if (p == head) {
c0108240:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108243:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108246:	75 0f                	jne    c0108257 <_clock_swap_out_victim+0x8f>
c0108248:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010824b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010824e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108251:	8b 40 04             	mov    0x4(%eax),%eax
             p = list_next(p);
c0108254:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         struct Page *ptr = le2page(p, pra_page_link);
c0108257:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010825a:	83 e8 14             	sub    $0x14,%eax
c010825d:	89 45 ec             	mov    %eax,-0x14(%ebp)
         pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
c0108260:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108263:	8b 50 1c             	mov    0x1c(%eax),%edx
c0108266:	8b 45 08             	mov    0x8(%ebp),%eax
c0108269:	8b 40 0c             	mov    0xc(%eax),%eax
c010826c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108273:	00 
c0108274:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108278:	89 04 24             	mov    %eax,(%esp)
c010827b:	e8 14 bc ff ff       	call   c0103e94 <get_pte>
c0108280:	89 45 e8             	mov    %eax,-0x18(%ebp)
         if ((*pte & PTE_D) == 1) {// 如果dirty bit为1，改为0
             *pte &= ~PTE_D;
         } 
         else 
         {// 如果dirty bit为0，则标记为换出页
             *ptr_page = ptr;
c0108283:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108286:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108289:	89 10                	mov    %edx,(%eax)
c010828b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010828e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_del(listelm->prev, listelm->next);
c0108291:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108294:	8b 40 04             	mov    0x4(%eax),%eax
c0108297:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010829a:	8b 12                	mov    (%edx),%edx
c010829c:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010829f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next;
c01082a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01082a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01082a8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01082ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01082ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01082b1:	89 10                	mov    %edx,(%eax)
             list_del(p);
             break;
c01082b3:	90                   	nop
         }
     }
     return 0;
c01082b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01082b9:	c9                   	leave  
c01082ba:	c3                   	ret    

c01082bb <_clock_check_swap>:


static int
_clock_check_swap(void) {
c01082bb:	55                   	push   %ebp
c01082bc:	89 e5                	mov    %esp,%ebp
c01082be:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in clock_check_swap\n");
c01082c1:	c7 04 24 2c b2 10 c0 	movl   $0xc010b22c,(%esp)
c01082c8:	e8 df 7f ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01082cd:	b8 00 30 00 00       	mov    $0x3000,%eax
c01082d2:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01082d5:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01082da:	83 f8 04             	cmp    $0x4,%eax
c01082dd:	74 24                	je     c0108303 <_clock_check_swap+0x48>
c01082df:	c7 44 24 0c 53 b2 10 	movl   $0xc010b253,0xc(%esp)
c01082e6:	c0 
c01082e7:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01082ee:	c0 
c01082ef:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
c01082f6:	00 
c01082f7:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c01082fe:	e8 00 81 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page a in clock_check_swap\n");
c0108303:	c7 04 24 64 b2 10 c0 	movl   $0xc010b264,(%esp)
c010830a:	e8 9d 7f ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010830f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108314:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0108317:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010831c:	83 f8 04             	cmp    $0x4,%eax
c010831f:	74 24                	je     c0108345 <_clock_check_swap+0x8a>
c0108321:	c7 44 24 0c 53 b2 10 	movl   $0xc010b253,0xc(%esp)
c0108328:	c0 
c0108329:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c0108330:	c0 
c0108331:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
c0108338:	00 
c0108339:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108340:	e8 be 80 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page d in clock_check_swap\n");
c0108345:	c7 04 24 8c b2 10 c0 	movl   $0xc010b28c,(%esp)
c010834c:	e8 5b 7f ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0108351:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108356:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0108359:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010835e:	83 f8 04             	cmp    $0x4,%eax
c0108361:	74 24                	je     c0108387 <_clock_check_swap+0xcc>
c0108363:	c7 44 24 0c 53 b2 10 	movl   $0xc010b253,0xc(%esp)
c010836a:	c0 
c010836b:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c0108372:	c0 
c0108373:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
c010837a:	00 
c010837b:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108382:	e8 7c 80 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page b in clock_check_swap\n");
c0108387:	c7 04 24 b4 b2 10 c0 	movl   $0xc010b2b4,(%esp)
c010838e:	e8 19 7f ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0108393:	b8 00 20 00 00       	mov    $0x2000,%eax
c0108398:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010839b:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01083a0:	83 f8 04             	cmp    $0x4,%eax
c01083a3:	74 24                	je     c01083c9 <_clock_check_swap+0x10e>
c01083a5:	c7 44 24 0c 53 b2 10 	movl   $0xc010b253,0xc(%esp)
c01083ac:	c0 
c01083ad:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01083b4:	c0 
c01083b5:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
c01083bc:	00 
c01083bd:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c01083c4:	e8 3a 80 ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page e in clock_check_swap\n");
c01083c9:	c7 04 24 dc b2 10 c0 	movl   $0xc010b2dc,(%esp)
c01083d0:	e8 d7 7e ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01083d5:	b8 00 50 00 00       	mov    $0x5000,%eax
c01083da:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01083dd:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01083e2:	83 f8 05             	cmp    $0x5,%eax
c01083e5:	74 24                	je     c010840b <_clock_check_swap+0x150>
c01083e7:	c7 44 24 0c 03 b3 10 	movl   $0xc010b303,0xc(%esp)
c01083ee:	c0 
c01083ef:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01083f6:	c0 
c01083f7:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
c01083fe:	00 
c01083ff:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108406:	e8 f8 7f ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page b in clock_check_swap\n");
c010840b:	c7 04 24 b4 b2 10 c0 	movl   $0xc010b2b4,(%esp)
c0108412:	e8 95 7e ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0108417:	b8 00 20 00 00       	mov    $0x2000,%eax
c010841c:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c010841f:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0108424:	83 f8 05             	cmp    $0x5,%eax
c0108427:	74 24                	je     c010844d <_clock_check_swap+0x192>
c0108429:	c7 44 24 0c 03 b3 10 	movl   $0xc010b303,0xc(%esp)
c0108430:	c0 
c0108431:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c0108438:	c0 
c0108439:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c0108440:	00 
c0108441:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108448:	e8 b6 7f ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page a in clock_check_swap\n");
c010844d:	c7 04 24 64 b2 10 c0 	movl   $0xc010b264,(%esp)
c0108454:	e8 53 7e ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0108459:	b8 00 10 00 00       	mov    $0x1000,%eax
c010845e:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0108461:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0108466:	83 f8 06             	cmp    $0x6,%eax
c0108469:	74 24                	je     c010848f <_clock_check_swap+0x1d4>
c010846b:	c7 44 24 0c 12 b3 10 	movl   $0xc010b312,0xc(%esp)
c0108472:	c0 
c0108473:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c010847a:	c0 
c010847b:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c0108482:	00 
c0108483:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c010848a:	e8 74 7f ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page b in clock_check_swap\n");
c010848f:	c7 04 24 b4 b2 10 c0 	movl   $0xc010b2b4,(%esp)
c0108496:	e8 11 7e ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010849b:	b8 00 20 00 00       	mov    $0x2000,%eax
c01084a0:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c01084a3:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01084a8:	83 f8 07             	cmp    $0x7,%eax
c01084ab:	74 24                	je     c01084d1 <_clock_check_swap+0x216>
c01084ad:	c7 44 24 0c 21 b3 10 	movl   $0xc010b321,0xc(%esp)
c01084b4:	c0 
c01084b5:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01084bc:	c0 
c01084bd:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c01084c4:	00 
c01084c5:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c01084cc:	e8 32 7f ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page c in clock_check_swap\n");
c01084d1:	c7 04 24 2c b2 10 c0 	movl   $0xc010b22c,(%esp)
c01084d8:	e8 cf 7d ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01084dd:	b8 00 30 00 00       	mov    $0x3000,%eax
c01084e2:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01084e5:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01084ea:	83 f8 08             	cmp    $0x8,%eax
c01084ed:	74 24                	je     c0108513 <_clock_check_swap+0x258>
c01084ef:	c7 44 24 0c 30 b3 10 	movl   $0xc010b330,0xc(%esp)
c01084f6:	c0 
c01084f7:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01084fe:	c0 
c01084ff:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0108506:	00 
c0108507:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c010850e:	e8 f0 7e ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page d in clock_check_swap\n");
c0108513:	c7 04 24 8c b2 10 c0 	movl   $0xc010b28c,(%esp)
c010851a:	e8 8d 7d ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010851f:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108524:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0108527:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010852c:	83 f8 09             	cmp    $0x9,%eax
c010852f:	74 24                	je     c0108555 <_clock_check_swap+0x29a>
c0108531:	c7 44 24 0c 3f b3 10 	movl   $0xc010b33f,0xc(%esp)
c0108538:	c0 
c0108539:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c0108540:	c0 
c0108541:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0108548:	00 
c0108549:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108550:	e8 ae 7e ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page e in clock_check_swap\n");
c0108555:	c7 04 24 dc b2 10 c0 	movl   $0xc010b2dc,(%esp)
c010855c:	e8 4b 7d ff ff       	call   c01002ac <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0108561:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108566:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0108569:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010856e:	83 f8 0a             	cmp    $0xa,%eax
c0108571:	74 24                	je     c0108597 <_clock_check_swap+0x2dc>
c0108573:	c7 44 24 0c 4e b3 10 	movl   $0xc010b34e,0xc(%esp)
c010857a:	c0 
c010857b:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c0108582:	c0 
c0108583:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010858a:	00 
c010858b:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108592:	e8 6c 7e ff ff       	call   c0100403 <__panic>
    cprintf("write Virt Page a in clock_check_swap\n");
c0108597:	c7 04 24 64 b2 10 c0 	movl   $0xc010b264,(%esp)
c010859e:	e8 09 7d ff ff       	call   c01002ac <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01085a3:	b8 00 10 00 00       	mov    $0x1000,%eax
c01085a8:	0f b6 00             	movzbl (%eax),%eax
c01085ab:	3c 0a                	cmp    $0xa,%al
c01085ad:	74 24                	je     c01085d3 <_clock_check_swap+0x318>
c01085af:	c7 44 24 0c 60 b3 10 	movl   $0xc010b360,0xc(%esp)
c01085b6:	c0 
c01085b7:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01085be:	c0 
c01085bf:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01085c6:	00 
c01085c7:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c01085ce:	e8 30 7e ff ff       	call   c0100403 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01085d3:	b8 00 10 00 00       	mov    $0x1000,%eax
c01085d8:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01085db:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01085e0:	83 f8 0b             	cmp    $0xb,%eax
c01085e3:	74 24                	je     c0108609 <_clock_check_swap+0x34e>
c01085e5:	c7 44 24 0c 81 b3 10 	movl   $0xc010b381,0xc(%esp)
c01085ec:	c0 
c01085ed:	c7 44 24 08 ea b1 10 	movl   $0xc010b1ea,0x8(%esp)
c01085f4:	c0 
c01085f5:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01085fc:	00 
c01085fd:	c7 04 24 ff b1 10 c0 	movl   $0xc010b1ff,(%esp)
c0108604:	e8 fa 7d ff ff       	call   c0100403 <__panic>
    return 0;
c0108609:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010860e:	c9                   	leave  
c010860f:	c3                   	ret    

c0108610 <_clock_init>:


static int
_clock_init(void)
{
c0108610:	55                   	push   %ebp
c0108611:	89 e5                	mov    %esp,%ebp
    return 0;
c0108613:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108618:	5d                   	pop    %ebp
c0108619:	c3                   	ret    

c010861a <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010861a:	55                   	push   %ebp
c010861b:	89 e5                	mov    %esp,%ebp
    return 0;
c010861d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108622:	5d                   	pop    %ebp
c0108623:	c3                   	ret    

c0108624 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
c0108624:	55                   	push   %ebp
c0108625:	89 e5                	mov    %esp,%ebp
c0108627:	b8 00 00 00 00       	mov    $0x0,%eax
c010862c:	5d                   	pop    %ebp
c010862d:	c3                   	ret    

c010862e <page2ppn>:
page2ppn(struct Page *page) {
c010862e:	55                   	push   %ebp
c010862f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108631:	8b 45 08             	mov    0x8(%ebp),%eax
c0108634:	8b 15 28 60 12 c0    	mov    0xc0126028,%edx
c010863a:	29 d0                	sub    %edx,%eax
c010863c:	c1 f8 05             	sar    $0x5,%eax
}
c010863f:	5d                   	pop    %ebp
c0108640:	c3                   	ret    

c0108641 <page2pa>:
page2pa(struct Page *page) {
c0108641:	55                   	push   %ebp
c0108642:	89 e5                	mov    %esp,%ebp
c0108644:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0108647:	8b 45 08             	mov    0x8(%ebp),%eax
c010864a:	89 04 24             	mov    %eax,(%esp)
c010864d:	e8 dc ff ff ff       	call   c010862e <page2ppn>
c0108652:	c1 e0 0c             	shl    $0xc,%eax
}
c0108655:	c9                   	leave  
c0108656:	c3                   	ret    

c0108657 <page2kva>:
page2kva(struct Page *page) {
c0108657:	55                   	push   %ebp
c0108658:	89 e5                	mov    %esp,%ebp
c010865a:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010865d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108660:	89 04 24             	mov    %eax,(%esp)
c0108663:	e8 d9 ff ff ff       	call   c0108641 <page2pa>
c0108668:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010866b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010866e:	c1 e8 0c             	shr    $0xc,%eax
c0108671:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108674:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0108679:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010867c:	72 23                	jb     c01086a1 <page2kva+0x4a>
c010867e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108681:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108685:	c7 44 24 08 ac b3 10 	movl   $0xc010b3ac,0x8(%esp)
c010868c:	c0 
c010868d:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0108694:	00 
c0108695:	c7 04 24 cf b3 10 c0 	movl   $0xc010b3cf,(%esp)
c010869c:	e8 62 7d ff ff       	call   c0100403 <__panic>
c01086a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086a4:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01086a9:	c9                   	leave  
c01086aa:	c3                   	ret    

c01086ab <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01086ab:	55                   	push   %ebp
c01086ac:	89 e5                	mov    %esp,%ebp
c01086ae:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01086b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01086b8:	e8 40 8a ff ff       	call   c01010fd <ide_device_valid>
c01086bd:	85 c0                	test   %eax,%eax
c01086bf:	75 1c                	jne    c01086dd <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01086c1:	c7 44 24 08 dd b3 10 	movl   $0xc010b3dd,0x8(%esp)
c01086c8:	c0 
c01086c9:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01086d0:	00 
c01086d1:	c7 04 24 f7 b3 10 c0 	movl   $0xc010b3f7,(%esp)
c01086d8:	e8 26 7d ff ff       	call   c0100403 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01086dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01086e4:	e8 52 8a ff ff       	call   c010113b <ide_device_size>
c01086e9:	c1 e8 03             	shr    $0x3,%eax
c01086ec:	a3 dc 60 12 c0       	mov    %eax,0xc01260dc
}
c01086f1:	90                   	nop
c01086f2:	c9                   	leave  
c01086f3:	c3                   	ret    

c01086f4 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01086f4:	55                   	push   %ebp
c01086f5:	89 e5                	mov    %esp,%ebp
c01086f7:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01086fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086fd:	89 04 24             	mov    %eax,(%esp)
c0108700:	e8 52 ff ff ff       	call   c0108657 <page2kva>
c0108705:	8b 55 08             	mov    0x8(%ebp),%edx
c0108708:	c1 ea 08             	shr    $0x8,%edx
c010870b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010870e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108712:	74 0b                	je     c010871f <swapfs_read+0x2b>
c0108714:	8b 15 dc 60 12 c0    	mov    0xc01260dc,%edx
c010871a:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010871d:	72 23                	jb     c0108742 <swapfs_read+0x4e>
c010871f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108722:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108726:	c7 44 24 08 08 b4 10 	movl   $0xc010b408,0x8(%esp)
c010872d:	c0 
c010872e:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0108735:	00 
c0108736:	c7 04 24 f7 b3 10 c0 	movl   $0xc010b3f7,(%esp)
c010873d:	e8 c1 7c ff ff       	call   c0100403 <__panic>
c0108742:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108745:	c1 e2 03             	shl    $0x3,%edx
c0108748:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010874f:	00 
c0108750:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108754:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108758:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010875f:	e8 12 8a ff ff       	call   c0101176 <ide_read_secs>
}
c0108764:	c9                   	leave  
c0108765:	c3                   	ret    

c0108766 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0108766:	55                   	push   %ebp
c0108767:	89 e5                	mov    %esp,%ebp
c0108769:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010876c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010876f:	89 04 24             	mov    %eax,(%esp)
c0108772:	e8 e0 fe ff ff       	call   c0108657 <page2kva>
c0108777:	8b 55 08             	mov    0x8(%ebp),%edx
c010877a:	c1 ea 08             	shr    $0x8,%edx
c010877d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108780:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108784:	74 0b                	je     c0108791 <swapfs_write+0x2b>
c0108786:	8b 15 dc 60 12 c0    	mov    0xc01260dc,%edx
c010878c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010878f:	72 23                	jb     c01087b4 <swapfs_write+0x4e>
c0108791:	8b 45 08             	mov    0x8(%ebp),%eax
c0108794:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108798:	c7 44 24 08 08 b4 10 	movl   $0xc010b408,0x8(%esp)
c010879f:	c0 
c01087a0:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c01087a7:	00 
c01087a8:	c7 04 24 f7 b3 10 c0 	movl   $0xc010b3f7,(%esp)
c01087af:	e8 4f 7c ff ff       	call   c0100403 <__panic>
c01087b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087b7:	c1 e2 03             	shl    $0x3,%edx
c01087ba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01087c1:	00 
c01087c2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01087c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01087ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01087d1:	e8 d9 8b ff ff       	call   c01013af <ide_write_secs>
}
c01087d6:	c9                   	leave  
c01087d7:	c3                   	ret    

c01087d8 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01087d8:	55                   	push   %ebp
c01087d9:	89 e5                	mov    %esp,%ebp
c01087db:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01087de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01087e5:	eb 03                	jmp    c01087ea <strlen+0x12>
        cnt ++;
c01087e7:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c01087ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01087ed:	8d 50 01             	lea    0x1(%eax),%edx
c01087f0:	89 55 08             	mov    %edx,0x8(%ebp)
c01087f3:	0f b6 00             	movzbl (%eax),%eax
c01087f6:	84 c0                	test   %al,%al
c01087f8:	75 ed                	jne    c01087e7 <strlen+0xf>
    }
    return cnt;
c01087fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01087fd:	c9                   	leave  
c01087fe:	c3                   	ret    

c01087ff <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01087ff:	55                   	push   %ebp
c0108800:	89 e5                	mov    %esp,%ebp
c0108802:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108805:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010880c:	eb 03                	jmp    c0108811 <strnlen+0x12>
        cnt ++;
c010880e:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108811:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108814:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108817:	73 10                	jae    c0108829 <strnlen+0x2a>
c0108819:	8b 45 08             	mov    0x8(%ebp),%eax
c010881c:	8d 50 01             	lea    0x1(%eax),%edx
c010881f:	89 55 08             	mov    %edx,0x8(%ebp)
c0108822:	0f b6 00             	movzbl (%eax),%eax
c0108825:	84 c0                	test   %al,%al
c0108827:	75 e5                	jne    c010880e <strnlen+0xf>
    }
    return cnt;
c0108829:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010882c:	c9                   	leave  
c010882d:	c3                   	ret    

c010882e <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010882e:	55                   	push   %ebp
c010882f:	89 e5                	mov    %esp,%ebp
c0108831:	57                   	push   %edi
c0108832:	56                   	push   %esi
c0108833:	83 ec 20             	sub    $0x20,%esp
c0108836:	8b 45 08             	mov    0x8(%ebp),%eax
c0108839:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010883c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010883f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108842:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108845:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108848:	89 d1                	mov    %edx,%ecx
c010884a:	89 c2                	mov    %eax,%edx
c010884c:	89 ce                	mov    %ecx,%esi
c010884e:	89 d7                	mov    %edx,%edi
c0108850:	ac                   	lods   %ds:(%esi),%al
c0108851:	aa                   	stos   %al,%es:(%edi)
c0108852:	84 c0                	test   %al,%al
c0108854:	75 fa                	jne    c0108850 <strcpy+0x22>
c0108856:	89 fa                	mov    %edi,%edx
c0108858:	89 f1                	mov    %esi,%ecx
c010885a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010885d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108860:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108863:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0108866:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108867:	83 c4 20             	add    $0x20,%esp
c010886a:	5e                   	pop    %esi
c010886b:	5f                   	pop    %edi
c010886c:	5d                   	pop    %ebp
c010886d:	c3                   	ret    

c010886e <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010886e:	55                   	push   %ebp
c010886f:	89 e5                	mov    %esp,%ebp
c0108871:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108874:	8b 45 08             	mov    0x8(%ebp),%eax
c0108877:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010887a:	eb 1e                	jmp    c010889a <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010887c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010887f:	0f b6 10             	movzbl (%eax),%edx
c0108882:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108885:	88 10                	mov    %dl,(%eax)
c0108887:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010888a:	0f b6 00             	movzbl (%eax),%eax
c010888d:	84 c0                	test   %al,%al
c010888f:	74 03                	je     c0108894 <strncpy+0x26>
            src ++;
c0108891:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0108894:	ff 45 fc             	incl   -0x4(%ebp)
c0108897:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010889a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010889e:	75 dc                	jne    c010887c <strncpy+0xe>
    }
    return dst;
c01088a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01088a3:	c9                   	leave  
c01088a4:	c3                   	ret    

c01088a5 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01088a5:	55                   	push   %ebp
c01088a6:	89 e5                	mov    %esp,%ebp
c01088a8:	57                   	push   %edi
c01088a9:	56                   	push   %esi
c01088aa:	83 ec 20             	sub    $0x20,%esp
c01088ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01088b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01088b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088bf:	89 d1                	mov    %edx,%ecx
c01088c1:	89 c2                	mov    %eax,%edx
c01088c3:	89 ce                	mov    %ecx,%esi
c01088c5:	89 d7                	mov    %edx,%edi
c01088c7:	ac                   	lods   %ds:(%esi),%al
c01088c8:	ae                   	scas   %es:(%edi),%al
c01088c9:	75 08                	jne    c01088d3 <strcmp+0x2e>
c01088cb:	84 c0                	test   %al,%al
c01088cd:	75 f8                	jne    c01088c7 <strcmp+0x22>
c01088cf:	31 c0                	xor    %eax,%eax
c01088d1:	eb 04                	jmp    c01088d7 <strcmp+0x32>
c01088d3:	19 c0                	sbb    %eax,%eax
c01088d5:	0c 01                	or     $0x1,%al
c01088d7:	89 fa                	mov    %edi,%edx
c01088d9:	89 f1                	mov    %esi,%ecx
c01088db:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01088de:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01088e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01088e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01088e7:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01088e8:	83 c4 20             	add    $0x20,%esp
c01088eb:	5e                   	pop    %esi
c01088ec:	5f                   	pop    %edi
c01088ed:	5d                   	pop    %ebp
c01088ee:	c3                   	ret    

c01088ef <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01088ef:	55                   	push   %ebp
c01088f0:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01088f2:	eb 09                	jmp    c01088fd <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01088f4:	ff 4d 10             	decl   0x10(%ebp)
c01088f7:	ff 45 08             	incl   0x8(%ebp)
c01088fa:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01088fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108901:	74 1a                	je     c010891d <strncmp+0x2e>
c0108903:	8b 45 08             	mov    0x8(%ebp),%eax
c0108906:	0f b6 00             	movzbl (%eax),%eax
c0108909:	84 c0                	test   %al,%al
c010890b:	74 10                	je     c010891d <strncmp+0x2e>
c010890d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108910:	0f b6 10             	movzbl (%eax),%edx
c0108913:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108916:	0f b6 00             	movzbl (%eax),%eax
c0108919:	38 c2                	cmp    %al,%dl
c010891b:	74 d7                	je     c01088f4 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010891d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108921:	74 18                	je     c010893b <strncmp+0x4c>
c0108923:	8b 45 08             	mov    0x8(%ebp),%eax
c0108926:	0f b6 00             	movzbl (%eax),%eax
c0108929:	0f b6 d0             	movzbl %al,%edx
c010892c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010892f:	0f b6 00             	movzbl (%eax),%eax
c0108932:	0f b6 c0             	movzbl %al,%eax
c0108935:	29 c2                	sub    %eax,%edx
c0108937:	89 d0                	mov    %edx,%eax
c0108939:	eb 05                	jmp    c0108940 <strncmp+0x51>
c010893b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108940:	5d                   	pop    %ebp
c0108941:	c3                   	ret    

c0108942 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108942:	55                   	push   %ebp
c0108943:	89 e5                	mov    %esp,%ebp
c0108945:	83 ec 04             	sub    $0x4,%esp
c0108948:	8b 45 0c             	mov    0xc(%ebp),%eax
c010894b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010894e:	eb 13                	jmp    c0108963 <strchr+0x21>
        if (*s == c) {
c0108950:	8b 45 08             	mov    0x8(%ebp),%eax
c0108953:	0f b6 00             	movzbl (%eax),%eax
c0108956:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108959:	75 05                	jne    c0108960 <strchr+0x1e>
            return (char *)s;
c010895b:	8b 45 08             	mov    0x8(%ebp),%eax
c010895e:	eb 12                	jmp    c0108972 <strchr+0x30>
        }
        s ++;
c0108960:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108963:	8b 45 08             	mov    0x8(%ebp),%eax
c0108966:	0f b6 00             	movzbl (%eax),%eax
c0108969:	84 c0                	test   %al,%al
c010896b:	75 e3                	jne    c0108950 <strchr+0xe>
    }
    return NULL;
c010896d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108972:	c9                   	leave  
c0108973:	c3                   	ret    

c0108974 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108974:	55                   	push   %ebp
c0108975:	89 e5                	mov    %esp,%ebp
c0108977:	83 ec 04             	sub    $0x4,%esp
c010897a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010897d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108980:	eb 0e                	jmp    c0108990 <strfind+0x1c>
        if (*s == c) {
c0108982:	8b 45 08             	mov    0x8(%ebp),%eax
c0108985:	0f b6 00             	movzbl (%eax),%eax
c0108988:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010898b:	74 0f                	je     c010899c <strfind+0x28>
            break;
        }
        s ++;
c010898d:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108990:	8b 45 08             	mov    0x8(%ebp),%eax
c0108993:	0f b6 00             	movzbl (%eax),%eax
c0108996:	84 c0                	test   %al,%al
c0108998:	75 e8                	jne    c0108982 <strfind+0xe>
c010899a:	eb 01                	jmp    c010899d <strfind+0x29>
            break;
c010899c:	90                   	nop
    }
    return (char *)s;
c010899d:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01089a0:	c9                   	leave  
c01089a1:	c3                   	ret    

c01089a2 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01089a2:	55                   	push   %ebp
c01089a3:	89 e5                	mov    %esp,%ebp
c01089a5:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01089a8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01089af:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01089b6:	eb 03                	jmp    c01089bb <strtol+0x19>
        s ++;
c01089b8:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c01089bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01089be:	0f b6 00             	movzbl (%eax),%eax
c01089c1:	3c 20                	cmp    $0x20,%al
c01089c3:	74 f3                	je     c01089b8 <strtol+0x16>
c01089c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01089c8:	0f b6 00             	movzbl (%eax),%eax
c01089cb:	3c 09                	cmp    $0x9,%al
c01089cd:	74 e9                	je     c01089b8 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01089cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01089d2:	0f b6 00             	movzbl (%eax),%eax
c01089d5:	3c 2b                	cmp    $0x2b,%al
c01089d7:	75 05                	jne    c01089de <strtol+0x3c>
        s ++;
c01089d9:	ff 45 08             	incl   0x8(%ebp)
c01089dc:	eb 14                	jmp    c01089f2 <strtol+0x50>
    }
    else if (*s == '-') {
c01089de:	8b 45 08             	mov    0x8(%ebp),%eax
c01089e1:	0f b6 00             	movzbl (%eax),%eax
c01089e4:	3c 2d                	cmp    $0x2d,%al
c01089e6:	75 0a                	jne    c01089f2 <strtol+0x50>
        s ++, neg = 1;
c01089e8:	ff 45 08             	incl   0x8(%ebp)
c01089eb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01089f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01089f6:	74 06                	je     c01089fe <strtol+0x5c>
c01089f8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01089fc:	75 22                	jne    c0108a20 <strtol+0x7e>
c01089fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a01:	0f b6 00             	movzbl (%eax),%eax
c0108a04:	3c 30                	cmp    $0x30,%al
c0108a06:	75 18                	jne    c0108a20 <strtol+0x7e>
c0108a08:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a0b:	40                   	inc    %eax
c0108a0c:	0f b6 00             	movzbl (%eax),%eax
c0108a0f:	3c 78                	cmp    $0x78,%al
c0108a11:	75 0d                	jne    c0108a20 <strtol+0x7e>
        s += 2, base = 16;
c0108a13:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108a17:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108a1e:	eb 29                	jmp    c0108a49 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0108a20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108a24:	75 16                	jne    c0108a3c <strtol+0x9a>
c0108a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a29:	0f b6 00             	movzbl (%eax),%eax
c0108a2c:	3c 30                	cmp    $0x30,%al
c0108a2e:	75 0c                	jne    c0108a3c <strtol+0x9a>
        s ++, base = 8;
c0108a30:	ff 45 08             	incl   0x8(%ebp)
c0108a33:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108a3a:	eb 0d                	jmp    c0108a49 <strtol+0xa7>
    }
    else if (base == 0) {
c0108a3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108a40:	75 07                	jne    c0108a49 <strtol+0xa7>
        base = 10;
c0108a42:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108a49:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a4c:	0f b6 00             	movzbl (%eax),%eax
c0108a4f:	3c 2f                	cmp    $0x2f,%al
c0108a51:	7e 1b                	jle    c0108a6e <strtol+0xcc>
c0108a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a56:	0f b6 00             	movzbl (%eax),%eax
c0108a59:	3c 39                	cmp    $0x39,%al
c0108a5b:	7f 11                	jg     c0108a6e <strtol+0xcc>
            dig = *s - '0';
c0108a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a60:	0f b6 00             	movzbl (%eax),%eax
c0108a63:	0f be c0             	movsbl %al,%eax
c0108a66:	83 e8 30             	sub    $0x30,%eax
c0108a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a6c:	eb 48                	jmp    c0108ab6 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108a6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a71:	0f b6 00             	movzbl (%eax),%eax
c0108a74:	3c 60                	cmp    $0x60,%al
c0108a76:	7e 1b                	jle    c0108a93 <strtol+0xf1>
c0108a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a7b:	0f b6 00             	movzbl (%eax),%eax
c0108a7e:	3c 7a                	cmp    $0x7a,%al
c0108a80:	7f 11                	jg     c0108a93 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a85:	0f b6 00             	movzbl (%eax),%eax
c0108a88:	0f be c0             	movsbl %al,%eax
c0108a8b:	83 e8 57             	sub    $0x57,%eax
c0108a8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a91:	eb 23                	jmp    c0108ab6 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108a93:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a96:	0f b6 00             	movzbl (%eax),%eax
c0108a99:	3c 40                	cmp    $0x40,%al
c0108a9b:	7e 3b                	jle    c0108ad8 <strtol+0x136>
c0108a9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aa0:	0f b6 00             	movzbl (%eax),%eax
c0108aa3:	3c 5a                	cmp    $0x5a,%al
c0108aa5:	7f 31                	jg     c0108ad8 <strtol+0x136>
            dig = *s - 'A' + 10;
c0108aa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aaa:	0f b6 00             	movzbl (%eax),%eax
c0108aad:	0f be c0             	movsbl %al,%eax
c0108ab0:	83 e8 37             	sub    $0x37,%eax
c0108ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ab9:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108abc:	7d 19                	jge    c0108ad7 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0108abe:	ff 45 08             	incl   0x8(%ebp)
c0108ac1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108ac4:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108ac8:	89 c2                	mov    %eax,%edx
c0108aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108acd:	01 d0                	add    %edx,%eax
c0108acf:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0108ad2:	e9 72 ff ff ff       	jmp    c0108a49 <strtol+0xa7>
            break;
c0108ad7:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0108ad8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108adc:	74 08                	je     c0108ae6 <strtol+0x144>
        *endptr = (char *) s;
c0108ade:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ae1:	8b 55 08             	mov    0x8(%ebp),%edx
c0108ae4:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108ae6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108aea:	74 07                	je     c0108af3 <strtol+0x151>
c0108aec:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108aef:	f7 d8                	neg    %eax
c0108af1:	eb 03                	jmp    c0108af6 <strtol+0x154>
c0108af3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108af6:	c9                   	leave  
c0108af7:	c3                   	ret    

c0108af8 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108af8:	55                   	push   %ebp
c0108af9:	89 e5                	mov    %esp,%ebp
c0108afb:	57                   	push   %edi
c0108afc:	83 ec 24             	sub    $0x24,%esp
c0108aff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b02:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108b05:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0108b09:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b0c:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108b0f:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108b12:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108b18:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108b1b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108b1f:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108b22:	89 d7                	mov    %edx,%edi
c0108b24:	f3 aa                	rep stos %al,%es:(%edi)
c0108b26:	89 fa                	mov    %edi,%edx
c0108b28:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108b2b:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0108b2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108b31:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108b32:	83 c4 24             	add    $0x24,%esp
c0108b35:	5f                   	pop    %edi
c0108b36:	5d                   	pop    %ebp
c0108b37:	c3                   	ret    

c0108b38 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0108b38:	55                   	push   %ebp
c0108b39:	89 e5                	mov    %esp,%ebp
c0108b3b:	57                   	push   %edi
c0108b3c:	56                   	push   %esi
c0108b3d:	53                   	push   %ebx
c0108b3e:	83 ec 30             	sub    $0x30,%esp
c0108b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b47:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b4d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b50:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b56:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108b59:	73 42                	jae    c0108b9d <memmove+0x65>
c0108b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108b61:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b64:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108b67:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b6a:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108b6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108b70:	c1 e8 02             	shr    $0x2,%eax
c0108b73:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0108b75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108b78:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108b7b:	89 d7                	mov    %edx,%edi
c0108b7d:	89 c6                	mov    %eax,%esi
c0108b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108b81:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108b84:	83 e1 03             	and    $0x3,%ecx
c0108b87:	74 02                	je     c0108b8b <memmove+0x53>
c0108b89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108b8b:	89 f0                	mov    %esi,%eax
c0108b8d:	89 fa                	mov    %edi,%edx
c0108b8f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108b92:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108b95:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0108b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0108b9b:	eb 36                	jmp    c0108bd3 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108b9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ba0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108ba6:	01 c2                	add    %eax,%edx
c0108ba8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bab:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108bb1:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0108bb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bb7:	89 c1                	mov    %eax,%ecx
c0108bb9:	89 d8                	mov    %ebx,%eax
c0108bbb:	89 d6                	mov    %edx,%esi
c0108bbd:	89 c7                	mov    %eax,%edi
c0108bbf:	fd                   	std    
c0108bc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108bc2:	fc                   	cld    
c0108bc3:	89 f8                	mov    %edi,%eax
c0108bc5:	89 f2                	mov    %esi,%edx
c0108bc7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0108bca:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108bcd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0108bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108bd3:	83 c4 30             	add    $0x30,%esp
c0108bd6:	5b                   	pop    %ebx
c0108bd7:	5e                   	pop    %esi
c0108bd8:	5f                   	pop    %edi
c0108bd9:	5d                   	pop    %ebp
c0108bda:	c3                   	ret    

c0108bdb <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0108bdb:	55                   	push   %ebp
c0108bdc:	89 e5                	mov    %esp,%ebp
c0108bde:	57                   	push   %edi
c0108bdf:	56                   	push   %esi
c0108be0:	83 ec 20             	sub    $0x20,%esp
c0108be3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108be6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108be9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108bec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108bef:	8b 45 10             	mov    0x10(%ebp),%eax
c0108bf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bf8:	c1 e8 02             	shr    $0x2,%eax
c0108bfb:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0108bfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c03:	89 d7                	mov    %edx,%edi
c0108c05:	89 c6                	mov    %eax,%esi
c0108c07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108c09:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0108c0c:	83 e1 03             	and    $0x3,%ecx
c0108c0f:	74 02                	je     c0108c13 <memcpy+0x38>
c0108c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108c13:	89 f0                	mov    %esi,%eax
c0108c15:	89 fa                	mov    %edi,%edx
c0108c17:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108c1a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108c1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0108c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0108c23:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108c24:	83 c4 20             	add    $0x20,%esp
c0108c27:	5e                   	pop    %esi
c0108c28:	5f                   	pop    %edi
c0108c29:	5d                   	pop    %ebp
c0108c2a:	c3                   	ret    

c0108c2b <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108c2b:	55                   	push   %ebp
c0108c2c:	89 e5                	mov    %esp,%ebp
c0108c2e:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0108c31:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c34:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108c37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c3a:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108c3d:	eb 2e                	jmp    c0108c6d <memcmp+0x42>
        if (*s1 != *s2) {
c0108c3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c42:	0f b6 10             	movzbl (%eax),%edx
c0108c45:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108c48:	0f b6 00             	movzbl (%eax),%eax
c0108c4b:	38 c2                	cmp    %al,%dl
c0108c4d:	74 18                	je     c0108c67 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c52:	0f b6 00             	movzbl (%eax),%eax
c0108c55:	0f b6 d0             	movzbl %al,%edx
c0108c58:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108c5b:	0f b6 00             	movzbl (%eax),%eax
c0108c5e:	0f b6 c0             	movzbl %al,%eax
c0108c61:	29 c2                	sub    %eax,%edx
c0108c63:	89 d0                	mov    %edx,%eax
c0108c65:	eb 18                	jmp    c0108c7f <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0108c67:	ff 45 fc             	incl   -0x4(%ebp)
c0108c6a:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0108c6d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c70:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108c73:	89 55 10             	mov    %edx,0x10(%ebp)
c0108c76:	85 c0                	test   %eax,%eax
c0108c78:	75 c5                	jne    c0108c3f <memcmp+0x14>
    }
    return 0;
c0108c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c7f:	c9                   	leave  
c0108c80:	c3                   	ret    

c0108c81 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0108c81:	55                   	push   %ebp
c0108c82:	89 e5                	mov    %esp,%ebp
c0108c84:	83 ec 58             	sub    $0x58,%esp
c0108c87:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c8a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108c8d:	8b 45 14             	mov    0x14(%ebp),%eax
c0108c90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108c93:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108c96:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108c99:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108c9c:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108c9f:	8b 45 18             	mov    0x18(%ebp),%eax
c0108ca2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ca8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108cab:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108cae:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108cb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108cbb:	74 1c                	je     c0108cd9 <printnum+0x58>
c0108cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108cc0:	ba 00 00 00 00       	mov    $0x0,%edx
c0108cc5:	f7 75 e4             	divl   -0x1c(%ebp)
c0108cc8:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108cce:	ba 00 00 00 00       	mov    $0x0,%edx
c0108cd3:	f7 75 e4             	divl   -0x1c(%ebp)
c0108cd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108cdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108cdf:	f7 75 e4             	divl   -0x1c(%ebp)
c0108ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108ce5:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108ce8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108ceb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108cee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108cf1:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108cf4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108cf7:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0108cfa:	8b 45 18             	mov    0x18(%ebp),%eax
c0108cfd:	ba 00 00 00 00       	mov    $0x0,%edx
c0108d02:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0108d05:	72 56                	jb     c0108d5d <printnum+0xdc>
c0108d07:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0108d0a:	77 05                	ja     c0108d11 <printnum+0x90>
c0108d0c:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0108d0f:	72 4c                	jb     c0108d5d <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0108d11:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108d14:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108d17:	8b 45 20             	mov    0x20(%ebp),%eax
c0108d1a:	89 44 24 18          	mov    %eax,0x18(%esp)
c0108d1e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108d22:	8b 45 18             	mov    0x18(%ebp),%eax
c0108d25:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d2c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108d2f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108d33:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108d37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d41:	89 04 24             	mov    %eax,(%esp)
c0108d44:	e8 38 ff ff ff       	call   c0108c81 <printnum>
c0108d49:	eb 1b                	jmp    c0108d66 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d52:	8b 45 20             	mov    0x20(%ebp),%eax
c0108d55:	89 04 24             	mov    %eax,(%esp)
c0108d58:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d5b:	ff d0                	call   *%eax
        while (-- width > 0)
c0108d5d:	ff 4d 1c             	decl   0x1c(%ebp)
c0108d60:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108d64:	7f e5                	jg     c0108d4b <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0108d66:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d69:	05 a8 b4 10 c0       	add    $0xc010b4a8,%eax
c0108d6e:	0f b6 00             	movzbl (%eax),%eax
c0108d71:	0f be c0             	movsbl %al,%eax
c0108d74:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108d77:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108d7b:	89 04 24             	mov    %eax,(%esp)
c0108d7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d81:	ff d0                	call   *%eax
}
c0108d83:	90                   	nop
c0108d84:	c9                   	leave  
c0108d85:	c3                   	ret    

c0108d86 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0108d86:	55                   	push   %ebp
c0108d87:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108d89:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108d8d:	7e 14                	jle    c0108da3 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108d8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d92:	8b 00                	mov    (%eax),%eax
c0108d94:	8d 48 08             	lea    0x8(%eax),%ecx
c0108d97:	8b 55 08             	mov    0x8(%ebp),%edx
c0108d9a:	89 0a                	mov    %ecx,(%edx)
c0108d9c:	8b 50 04             	mov    0x4(%eax),%edx
c0108d9f:	8b 00                	mov    (%eax),%eax
c0108da1:	eb 30                	jmp    c0108dd3 <getuint+0x4d>
    }
    else if (lflag) {
c0108da3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108da7:	74 16                	je     c0108dbf <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0108da9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dac:	8b 00                	mov    (%eax),%eax
c0108dae:	8d 48 04             	lea    0x4(%eax),%ecx
c0108db1:	8b 55 08             	mov    0x8(%ebp),%edx
c0108db4:	89 0a                	mov    %ecx,(%edx)
c0108db6:	8b 00                	mov    (%eax),%eax
c0108db8:	ba 00 00 00 00       	mov    $0x0,%edx
c0108dbd:	eb 14                	jmp    c0108dd3 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108dbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dc2:	8b 00                	mov    (%eax),%eax
c0108dc4:	8d 48 04             	lea    0x4(%eax),%ecx
c0108dc7:	8b 55 08             	mov    0x8(%ebp),%edx
c0108dca:	89 0a                	mov    %ecx,(%edx)
c0108dcc:	8b 00                	mov    (%eax),%eax
c0108dce:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0108dd3:	5d                   	pop    %ebp
c0108dd4:	c3                   	ret    

c0108dd5 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0108dd5:	55                   	push   %ebp
c0108dd6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108dd8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108ddc:	7e 14                	jle    c0108df2 <getint+0x1d>
        return va_arg(*ap, long long);
c0108dde:	8b 45 08             	mov    0x8(%ebp),%eax
c0108de1:	8b 00                	mov    (%eax),%eax
c0108de3:	8d 48 08             	lea    0x8(%eax),%ecx
c0108de6:	8b 55 08             	mov    0x8(%ebp),%edx
c0108de9:	89 0a                	mov    %ecx,(%edx)
c0108deb:	8b 50 04             	mov    0x4(%eax),%edx
c0108dee:	8b 00                	mov    (%eax),%eax
c0108df0:	eb 28                	jmp    c0108e1a <getint+0x45>
    }
    else if (lflag) {
c0108df2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108df6:	74 12                	je     c0108e0a <getint+0x35>
        return va_arg(*ap, long);
c0108df8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dfb:	8b 00                	mov    (%eax),%eax
c0108dfd:	8d 48 04             	lea    0x4(%eax),%ecx
c0108e00:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e03:	89 0a                	mov    %ecx,(%edx)
c0108e05:	8b 00                	mov    (%eax),%eax
c0108e07:	99                   	cltd   
c0108e08:	eb 10                	jmp    c0108e1a <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0108e0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e0d:	8b 00                	mov    (%eax),%eax
c0108e0f:	8d 48 04             	lea    0x4(%eax),%ecx
c0108e12:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e15:	89 0a                	mov    %ecx,(%edx)
c0108e17:	8b 00                	mov    (%eax),%eax
c0108e19:	99                   	cltd   
    }
}
c0108e1a:	5d                   	pop    %ebp
c0108e1b:	c3                   	ret    

c0108e1c <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0108e1c:	55                   	push   %ebp
c0108e1d:	89 e5                	mov    %esp,%ebp
c0108e1f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0108e22:	8d 45 14             	lea    0x14(%ebp),%eax
c0108e25:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108e2f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e32:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108e36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e40:	89 04 24             	mov    %eax,(%esp)
c0108e43:	e8 03 00 00 00       	call   c0108e4b <vprintfmt>
    va_end(ap);
}
c0108e48:	90                   	nop
c0108e49:	c9                   	leave  
c0108e4a:	c3                   	ret    

c0108e4b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108e4b:	55                   	push   %ebp
c0108e4c:	89 e5                	mov    %esp,%ebp
c0108e4e:	56                   	push   %esi
c0108e4f:	53                   	push   %ebx
c0108e50:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108e53:	eb 17                	jmp    c0108e6c <vprintfmt+0x21>
            if (ch == '\0') {
c0108e55:	85 db                	test   %ebx,%ebx
c0108e57:	0f 84 bf 03 00 00    	je     c010921c <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0108e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e64:	89 1c 24             	mov    %ebx,(%esp)
c0108e67:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e6a:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108e6c:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e6f:	8d 50 01             	lea    0x1(%eax),%edx
c0108e72:	89 55 10             	mov    %edx,0x10(%ebp)
c0108e75:	0f b6 00             	movzbl (%eax),%eax
c0108e78:	0f b6 d8             	movzbl %al,%ebx
c0108e7b:	83 fb 25             	cmp    $0x25,%ebx
c0108e7e:	75 d5                	jne    c0108e55 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108e80:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108e84:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0108e91:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108e98:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e9b:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108e9e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ea1:	8d 50 01             	lea    0x1(%eax),%edx
c0108ea4:	89 55 10             	mov    %edx,0x10(%ebp)
c0108ea7:	0f b6 00             	movzbl (%eax),%eax
c0108eaa:	0f b6 d8             	movzbl %al,%ebx
c0108ead:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108eb0:	83 f8 55             	cmp    $0x55,%eax
c0108eb3:	0f 87 37 03 00 00    	ja     c01091f0 <vprintfmt+0x3a5>
c0108eb9:	8b 04 85 cc b4 10 c0 	mov    -0x3fef4b34(,%eax,4),%eax
c0108ec0:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0108ec2:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0108ec6:	eb d6                	jmp    c0108e9e <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0108ec8:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0108ecc:	eb d0                	jmp    c0108e9e <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108ece:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0108ed5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108ed8:	89 d0                	mov    %edx,%eax
c0108eda:	c1 e0 02             	shl    $0x2,%eax
c0108edd:	01 d0                	add    %edx,%eax
c0108edf:	01 c0                	add    %eax,%eax
c0108ee1:	01 d8                	add    %ebx,%eax
c0108ee3:	83 e8 30             	sub    $0x30,%eax
c0108ee6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0108ee9:	8b 45 10             	mov    0x10(%ebp),%eax
c0108eec:	0f b6 00             	movzbl (%eax),%eax
c0108eef:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0108ef2:	83 fb 2f             	cmp    $0x2f,%ebx
c0108ef5:	7e 38                	jle    c0108f2f <vprintfmt+0xe4>
c0108ef7:	83 fb 39             	cmp    $0x39,%ebx
c0108efa:	7f 33                	jg     c0108f2f <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0108efc:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0108eff:	eb d4                	jmp    c0108ed5 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0108f01:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f04:	8d 50 04             	lea    0x4(%eax),%edx
c0108f07:	89 55 14             	mov    %edx,0x14(%ebp)
c0108f0a:	8b 00                	mov    (%eax),%eax
c0108f0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0108f0f:	eb 1f                	jmp    c0108f30 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0108f11:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108f15:	79 87                	jns    c0108e9e <vprintfmt+0x53>
                width = 0;
c0108f17:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0108f1e:	e9 7b ff ff ff       	jmp    c0108e9e <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0108f23:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108f2a:	e9 6f ff ff ff       	jmp    c0108e9e <vprintfmt+0x53>
            goto process_precision;
c0108f2f:	90                   	nop

        process_precision:
            if (width < 0)
c0108f30:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108f34:	0f 89 64 ff ff ff    	jns    c0108e9e <vprintfmt+0x53>
                width = precision, precision = -1;
c0108f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108f40:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108f47:	e9 52 ff ff ff       	jmp    c0108e9e <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108f4c:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0108f4f:	e9 4a ff ff ff       	jmp    c0108e9e <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108f54:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f57:	8d 50 04             	lea    0x4(%eax),%edx
c0108f5a:	89 55 14             	mov    %edx,0x14(%ebp)
c0108f5d:	8b 00                	mov    (%eax),%eax
c0108f5f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108f62:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108f66:	89 04 24             	mov    %eax,(%esp)
c0108f69:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f6c:	ff d0                	call   *%eax
            break;
c0108f6e:	e9 a4 02 00 00       	jmp    c0109217 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108f73:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f76:	8d 50 04             	lea    0x4(%eax),%edx
c0108f79:	89 55 14             	mov    %edx,0x14(%ebp)
c0108f7c:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0108f7e:	85 db                	test   %ebx,%ebx
c0108f80:	79 02                	jns    c0108f84 <vprintfmt+0x139>
                err = -err;
c0108f82:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108f84:	83 fb 06             	cmp    $0x6,%ebx
c0108f87:	7f 0b                	jg     c0108f94 <vprintfmt+0x149>
c0108f89:	8b 34 9d 8c b4 10 c0 	mov    -0x3fef4b74(,%ebx,4),%esi
c0108f90:	85 f6                	test   %esi,%esi
c0108f92:	75 23                	jne    c0108fb7 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0108f94:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108f98:	c7 44 24 08 b9 b4 10 	movl   $0xc010b4b9,0x8(%esp)
c0108f9f:	c0 
c0108fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108faa:	89 04 24             	mov    %eax,(%esp)
c0108fad:	e8 6a fe ff ff       	call   c0108e1c <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0108fb2:	e9 60 02 00 00       	jmp    c0109217 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0108fb7:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108fbb:	c7 44 24 08 c2 b4 10 	movl   $0xc010b4c2,0x8(%esp)
c0108fc2:	c0 
c0108fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fca:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fcd:	89 04 24             	mov    %eax,(%esp)
c0108fd0:	e8 47 fe ff ff       	call   c0108e1c <printfmt>
            break;
c0108fd5:	e9 3d 02 00 00       	jmp    c0109217 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0108fda:	8b 45 14             	mov    0x14(%ebp),%eax
c0108fdd:	8d 50 04             	lea    0x4(%eax),%edx
c0108fe0:	89 55 14             	mov    %edx,0x14(%ebp)
c0108fe3:	8b 30                	mov    (%eax),%esi
c0108fe5:	85 f6                	test   %esi,%esi
c0108fe7:	75 05                	jne    c0108fee <vprintfmt+0x1a3>
                p = "(null)";
c0108fe9:	be c5 b4 10 c0       	mov    $0xc010b4c5,%esi
            }
            if (width > 0 && padc != '-') {
c0108fee:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108ff2:	7e 76                	jle    c010906a <vprintfmt+0x21f>
c0108ff4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0108ff8:	74 70                	je     c010906a <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108ffa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109001:	89 34 24             	mov    %esi,(%esp)
c0109004:	e8 f6 f7 ff ff       	call   c01087ff <strnlen>
c0109009:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010900c:	29 c2                	sub    %eax,%edx
c010900e:	89 d0                	mov    %edx,%eax
c0109010:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109013:	eb 16                	jmp    c010902b <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0109015:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0109019:	8b 55 0c             	mov    0xc(%ebp),%edx
c010901c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109020:	89 04 24             	mov    %eax,(%esp)
c0109023:	8b 45 08             	mov    0x8(%ebp),%eax
c0109026:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109028:	ff 4d e8             	decl   -0x18(%ebp)
c010902b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010902f:	7f e4                	jg     c0109015 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109031:	eb 37                	jmp    c010906a <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0109033:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109037:	74 1f                	je     c0109058 <vprintfmt+0x20d>
c0109039:	83 fb 1f             	cmp    $0x1f,%ebx
c010903c:	7e 05                	jle    c0109043 <vprintfmt+0x1f8>
c010903e:	83 fb 7e             	cmp    $0x7e,%ebx
c0109041:	7e 15                	jle    c0109058 <vprintfmt+0x20d>
                    putch('?', putdat);
c0109043:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109046:	89 44 24 04          	mov    %eax,0x4(%esp)
c010904a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0109051:	8b 45 08             	mov    0x8(%ebp),%eax
c0109054:	ff d0                	call   *%eax
c0109056:	eb 0f                	jmp    c0109067 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0109058:	8b 45 0c             	mov    0xc(%ebp),%eax
c010905b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010905f:	89 1c 24             	mov    %ebx,(%esp)
c0109062:	8b 45 08             	mov    0x8(%ebp),%eax
c0109065:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109067:	ff 4d e8             	decl   -0x18(%ebp)
c010906a:	89 f0                	mov    %esi,%eax
c010906c:	8d 70 01             	lea    0x1(%eax),%esi
c010906f:	0f b6 00             	movzbl (%eax),%eax
c0109072:	0f be d8             	movsbl %al,%ebx
c0109075:	85 db                	test   %ebx,%ebx
c0109077:	74 27                	je     c01090a0 <vprintfmt+0x255>
c0109079:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010907d:	78 b4                	js     c0109033 <vprintfmt+0x1e8>
c010907f:	ff 4d e4             	decl   -0x1c(%ebp)
c0109082:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109086:	79 ab                	jns    c0109033 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0109088:	eb 16                	jmp    c01090a0 <vprintfmt+0x255>
                putch(' ', putdat);
c010908a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010908d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109091:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0109098:	8b 45 08             	mov    0x8(%ebp),%eax
c010909b:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010909d:	ff 4d e8             	decl   -0x18(%ebp)
c01090a0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01090a4:	7f e4                	jg     c010908a <vprintfmt+0x23f>
            }
            break;
c01090a6:	e9 6c 01 00 00       	jmp    c0109217 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01090ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01090ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090b2:	8d 45 14             	lea    0x14(%ebp),%eax
c01090b5:	89 04 24             	mov    %eax,(%esp)
c01090b8:	e8 18 fd ff ff       	call   c0108dd5 <getint>
c01090bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01090c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01090c9:	85 d2                	test   %edx,%edx
c01090cb:	79 26                	jns    c01090f3 <vprintfmt+0x2a8>
                putch('-', putdat);
c01090cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01090d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01090db:	8b 45 08             	mov    0x8(%ebp),%eax
c01090de:	ff d0                	call   *%eax
                num = -(long long)num;
c01090e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01090e6:	f7 d8                	neg    %eax
c01090e8:	83 d2 00             	adc    $0x0,%edx
c01090eb:	f7 da                	neg    %edx
c01090ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01090f3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01090fa:	e9 a8 00 00 00       	jmp    c01091a7 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01090ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109106:	8d 45 14             	lea    0x14(%ebp),%eax
c0109109:	89 04 24             	mov    %eax,(%esp)
c010910c:	e8 75 fc ff ff       	call   c0108d86 <getuint>
c0109111:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109114:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0109117:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010911e:	e9 84 00 00 00       	jmp    c01091a7 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0109123:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109126:	89 44 24 04          	mov    %eax,0x4(%esp)
c010912a:	8d 45 14             	lea    0x14(%ebp),%eax
c010912d:	89 04 24             	mov    %eax,(%esp)
c0109130:	e8 51 fc ff ff       	call   c0108d86 <getuint>
c0109135:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109138:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010913b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0109142:	eb 63                	jmp    c01091a7 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0109144:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109147:	89 44 24 04          	mov    %eax,0x4(%esp)
c010914b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0109152:	8b 45 08             	mov    0x8(%ebp),%eax
c0109155:	ff d0                	call   *%eax
            putch('x', putdat);
c0109157:	8b 45 0c             	mov    0xc(%ebp),%eax
c010915a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010915e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0109165:	8b 45 08             	mov    0x8(%ebp),%eax
c0109168:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010916a:	8b 45 14             	mov    0x14(%ebp),%eax
c010916d:	8d 50 04             	lea    0x4(%eax),%edx
c0109170:	89 55 14             	mov    %edx,0x14(%ebp)
c0109173:	8b 00                	mov    (%eax),%eax
c0109175:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109178:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010917f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0109186:	eb 1f                	jmp    c01091a7 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0109188:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010918b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010918f:	8d 45 14             	lea    0x14(%ebp),%eax
c0109192:	89 04 24             	mov    %eax,(%esp)
c0109195:	e8 ec fb ff ff       	call   c0108d86 <getuint>
c010919a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010919d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01091a0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01091a7:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01091ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01091ae:	89 54 24 18          	mov    %edx,0x18(%esp)
c01091b2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01091b5:	89 54 24 14          	mov    %edx,0x14(%esp)
c01091b9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01091bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01091c3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01091c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01091cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01091d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01091d5:	89 04 24             	mov    %eax,(%esp)
c01091d8:	e8 a4 fa ff ff       	call   c0108c81 <printnum>
            break;
c01091dd:	eb 38                	jmp    c0109217 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01091df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01091e6:	89 1c 24             	mov    %ebx,(%esp)
c01091e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01091ec:	ff d0                	call   *%eax
            break;
c01091ee:	eb 27                	jmp    c0109217 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01091f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01091f7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01091fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109201:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109203:	ff 4d 10             	decl   0x10(%ebp)
c0109206:	eb 03                	jmp    c010920b <vprintfmt+0x3c0>
c0109208:	ff 4d 10             	decl   0x10(%ebp)
c010920b:	8b 45 10             	mov    0x10(%ebp),%eax
c010920e:	48                   	dec    %eax
c010920f:	0f b6 00             	movzbl (%eax),%eax
c0109212:	3c 25                	cmp    $0x25,%al
c0109214:	75 f2                	jne    c0109208 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0109216:	90                   	nop
    while (1) {
c0109217:	e9 37 fc ff ff       	jmp    c0108e53 <vprintfmt+0x8>
                return;
c010921c:	90                   	nop
        }
    }
}
c010921d:	83 c4 40             	add    $0x40,%esp
c0109220:	5b                   	pop    %ebx
c0109221:	5e                   	pop    %esi
c0109222:	5d                   	pop    %ebp
c0109223:	c3                   	ret    

c0109224 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109224:	55                   	push   %ebp
c0109225:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0109227:	8b 45 0c             	mov    0xc(%ebp),%eax
c010922a:	8b 40 08             	mov    0x8(%eax),%eax
c010922d:	8d 50 01             	lea    0x1(%eax),%edx
c0109230:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109233:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0109236:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109239:	8b 10                	mov    (%eax),%edx
c010923b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010923e:	8b 40 04             	mov    0x4(%eax),%eax
c0109241:	39 c2                	cmp    %eax,%edx
c0109243:	73 12                	jae    c0109257 <sprintputch+0x33>
        *b->buf ++ = ch;
c0109245:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109248:	8b 00                	mov    (%eax),%eax
c010924a:	8d 48 01             	lea    0x1(%eax),%ecx
c010924d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109250:	89 0a                	mov    %ecx,(%edx)
c0109252:	8b 55 08             	mov    0x8(%ebp),%edx
c0109255:	88 10                	mov    %dl,(%eax)
    }
}
c0109257:	90                   	nop
c0109258:	5d                   	pop    %ebp
c0109259:	c3                   	ret    

c010925a <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010925a:	55                   	push   %ebp
c010925b:	89 e5                	mov    %esp,%ebp
c010925d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109260:	8d 45 14             	lea    0x14(%ebp),%eax
c0109263:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109266:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109269:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010926d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109270:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109274:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109277:	89 44 24 04          	mov    %eax,0x4(%esp)
c010927b:	8b 45 08             	mov    0x8(%ebp),%eax
c010927e:	89 04 24             	mov    %eax,(%esp)
c0109281:	e8 08 00 00 00       	call   c010928e <vsnprintf>
c0109286:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0109289:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010928c:	c9                   	leave  
c010928d:	c3                   	ret    

c010928e <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010928e:	55                   	push   %ebp
c010928f:	89 e5                	mov    %esp,%ebp
c0109291:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109294:	8b 45 08             	mov    0x8(%ebp),%eax
c0109297:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010929a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010929d:	8d 50 ff             	lea    -0x1(%eax),%edx
c01092a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01092a3:	01 d0                	add    %edx,%eax
c01092a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01092a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01092af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01092b3:	74 0a                	je     c01092bf <vsnprintf+0x31>
c01092b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01092b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01092bb:	39 c2                	cmp    %eax,%edx
c01092bd:	76 07                	jbe    c01092c6 <vsnprintf+0x38>
        return -E_INVAL;
c01092bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01092c4:	eb 2a                	jmp    c01092f0 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01092c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01092c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01092cd:	8b 45 10             	mov    0x10(%ebp),%eax
c01092d0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01092d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01092d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01092db:	c7 04 24 24 92 10 c0 	movl   $0xc0109224,(%esp)
c01092e2:	e8 64 fb ff ff       	call   c0108e4b <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01092e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01092ea:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01092ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01092f0:	c9                   	leave  
c01092f1:	c3                   	ret    

c01092f2 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c01092f2:	55                   	push   %ebp
c01092f3:	89 e5                	mov    %esp,%ebp
c01092f5:	57                   	push   %edi
c01092f6:	56                   	push   %esi
c01092f7:	53                   	push   %ebx
c01092f8:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c01092fb:	a1 80 2a 12 c0       	mov    0xc0122a80,%eax
c0109300:	8b 15 84 2a 12 c0    	mov    0xc0122a84,%edx
c0109306:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010930c:	6b f0 05             	imul   $0x5,%eax,%esi
c010930f:	01 fe                	add    %edi,%esi
c0109311:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0109316:	f7 e7                	mul    %edi
c0109318:	01 d6                	add    %edx,%esi
c010931a:	89 f2                	mov    %esi,%edx
c010931c:	83 c0 0b             	add    $0xb,%eax
c010931f:	83 d2 00             	adc    $0x0,%edx
c0109322:	89 c7                	mov    %eax,%edi
c0109324:	83 e7 ff             	and    $0xffffffff,%edi
c0109327:	89 f9                	mov    %edi,%ecx
c0109329:	0f b7 da             	movzwl %dx,%ebx
c010932c:	89 0d 80 2a 12 c0    	mov    %ecx,0xc0122a80
c0109332:	89 1d 84 2a 12 c0    	mov    %ebx,0xc0122a84
    unsigned long long result = (next >> 12);
c0109338:	8b 1d 80 2a 12 c0    	mov    0xc0122a80,%ebx
c010933e:	8b 35 84 2a 12 c0    	mov    0xc0122a84,%esi
c0109344:	89 d8                	mov    %ebx,%eax
c0109346:	89 f2                	mov    %esi,%edx
c0109348:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010934c:	c1 ea 0c             	shr    $0xc,%edx
c010934f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109352:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109355:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010935c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010935f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109362:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109365:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109368:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010936b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010936e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109372:	74 1c                	je     c0109390 <rand+0x9e>
c0109374:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109377:	ba 00 00 00 00       	mov    $0x0,%edx
c010937c:	f7 75 dc             	divl   -0x24(%ebp)
c010937f:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109382:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109385:	ba 00 00 00 00       	mov    $0x0,%edx
c010938a:	f7 75 dc             	divl   -0x24(%ebp)
c010938d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109390:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109393:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109396:	f7 75 dc             	divl   -0x24(%ebp)
c0109399:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010939c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010939f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01093a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01093a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01093a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01093ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c01093ae:	83 c4 24             	add    $0x24,%esp
c01093b1:	5b                   	pop    %ebx
c01093b2:	5e                   	pop    %esi
c01093b3:	5f                   	pop    %edi
c01093b4:	5d                   	pop    %ebp
c01093b5:	c3                   	ret    

c01093b6 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c01093b6:	55                   	push   %ebp
c01093b7:	89 e5                	mov    %esp,%ebp
    next = seed;
c01093b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01093bc:	ba 00 00 00 00       	mov    $0x0,%edx
c01093c1:	a3 80 2a 12 c0       	mov    %eax,0xc0122a80
c01093c6:	89 15 84 2a 12 c0    	mov    %edx,0xc0122a84
}
c01093cc:	90                   	nop
c01093cd:	5d                   	pop    %ebp
c01093ce:	c3                   	ret    
