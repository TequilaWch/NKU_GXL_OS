
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 b0 11 00       	mov    $0x11b000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    # 将cr0修改完成后的值，重新送至cr0中(此时第0位PE位已经为1，页机制已经开启，当前页表地址为刚刚构造的__boot_pgdir)
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
c0100020:	a3 00 b0 11 c0       	mov    %eax,0xc011b000

    # 设置C的内核栈
    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 a0 11 c0       	mov    $0xc011a000,%esp
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
c010003c:	ba 60 14 1e c0       	mov    $0xc01e1460,%edx
c0100041:	b8 00 d0 11 c0       	mov    $0xc011d000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 d0 11 c0 	movl   $0xc011d000,(%esp)
c010005d:	e8 b5 63 00 00       	call   c0106417 <memset>

    cons_init();                // init the console
c0100062:	e8 90 15 00 00       	call   c01015f7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 20 6c 10 c0 	movl   $0xc0106c20,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 3c 6c 10 c0 	movl   $0xc0106c3c,(%esp)
c010007c:	e8 21 02 00 00       	call   c01002a2 <cprintf>

    print_kerninfo();
c0100081:	e8 c2 08 00 00       	call   c0100948 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 8e 00 00 00       	call   c0100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 12 33 00 00       	call   c01033a2 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 c7 16 00 00       	call   c010175c <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 27 18 00 00       	call   c01018c1 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 fb 0c 00 00       	call   c0100d9a <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 f2 17 00 00       	call   c0101896 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
c01000a4:	e8 6b 01 00 00       	call   c0100214 <lab1_switch_test>

    /* do nothing */
    while (1);
c01000a9:	eb fe                	jmp    c01000a9 <kern_init+0x73>

c01000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000ab:	55                   	push   %ebp
c01000ac:	89 e5                	mov    %esp,%ebp
c01000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b8:	00 
c01000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c0:	00 
c01000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c8:	e8 bb 0c 00 00       	call   c0100d88 <mon_backtrace>
}
c01000cd:	90                   	nop
c01000ce:	c9                   	leave  
c01000cf:	c3                   	ret    

c01000d0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d0:	55                   	push   %ebp
c01000d1:	89 e5                	mov    %esp,%ebp
c01000d3:	53                   	push   %ebx
c01000d4:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d7:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000da:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000dd:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ef:	89 04 24             	mov    %eax,(%esp)
c01000f2:	e8 b4 ff ff ff       	call   c01000ab <grade_backtrace2>
}
c01000f7:	90                   	nop
c01000f8:	83 c4 14             	add    $0x14,%esp
c01000fb:	5b                   	pop    %ebx
c01000fc:	5d                   	pop    %ebp
c01000fd:	c3                   	ret    

c01000fe <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fe:	55                   	push   %ebp
c01000ff:	89 e5                	mov    %esp,%ebp
c0100101:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100104:	8b 45 10             	mov    0x10(%ebp),%eax
c0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
c010010b:	8b 45 08             	mov    0x8(%ebp),%eax
c010010e:	89 04 24             	mov    %eax,(%esp)
c0100111:	e8 ba ff ff ff       	call   c01000d0 <grade_backtrace1>
}
c0100116:	90                   	nop
c0100117:	c9                   	leave  
c0100118:	c3                   	ret    

c0100119 <grade_backtrace>:

void
grade_backtrace(void) {
c0100119:	55                   	push   %ebp
c010011a:	89 e5                	mov    %esp,%ebp
c010011c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011f:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100124:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010012b:	ff 
c010012c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100137:	e8 c2 ff ff ff       	call   c01000fe <grade_backtrace0>
}
c010013c:	90                   	nop
c010013d:	c9                   	leave  
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 41 6c 10 c0 	movl   $0xc0106c41,(%esp)
c010016e:	e8 2f 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 4f 6c 10 c0 	movl   $0xc0106c4f,(%esp)
c010018d:	e8 10 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 5d 6c 10 c0 	movl   $0xc0106c5d,(%esp)
c01001ac:	e8 f1 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 6b 6c 10 c0 	movl   $0xc0106c6b,(%esp)
c01001cb:	e8 d2 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 79 6c 10 c0 	movl   $0xc0106c79,(%esp)
c01001ea:	e8 b3 00 00 00       	call   c01002a2 <cprintf>
    round ++;
c01001ef:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 d0 11 c0       	mov    %eax,0xc011d000
}
c01001fa:	90                   	nop
c01001fb:	c9                   	leave  
c01001fc:	c3                   	ret    

c01001fd <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fd:	55                   	push   %ebp
c01001fe:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO  
    asm volatile(
c0100200:	83 ec 08             	sub    $0x8,%esp
c0100203:	cd 78                	int    $0x78
c0100205:	89 ec                	mov    %ebp,%esp
        "movl %%ebp, %%esp;"
        :
        : "i"(T_SWITCH_TOU)
    );
    //cprintf("to user finish \n");
}
c0100207:	90                   	nop
c0100208:	5d                   	pop    %ebp
c0100209:	c3                   	ret    

c010020a <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020a:	55                   	push   %ebp
c010020b:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
c010020d:	cd 79                	int    $0x79
c010020f:	89 ec                	mov    %ebp,%esp
	    "movl %%ebp, %%esp;"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
    //cprintf("to kernel finish \n");
}
c0100211:	90                   	nop
c0100212:	5d                   	pop    %ebp
c0100213:	c3                   	ret    

c0100214 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100214:	55                   	push   %ebp
c0100215:	89 e5                	mov    %esp,%ebp
c0100217:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021a:	e8 20 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021f:	c7 04 24 88 6c 10 c0 	movl   $0xc0106c88,(%esp)
c0100226:	e8 77 00 00 00       	call   c01002a2 <cprintf>
    lab1_switch_to_user();
c010022b:	e8 cd ff ff ff       	call   c01001fd <lab1_switch_to_user>
    lab1_print_cur_status();
c0100230:	e8 0a ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100235:	c7 04 24 a8 6c 10 c0 	movl   $0xc0106ca8,(%esp)
c010023c:	e8 61 00 00 00       	call   c01002a2 <cprintf>
    lab1_switch_to_kernel();
c0100241:	e8 c4 ff ff ff       	call   c010020a <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100246:	e8 f4 fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c010024b:	90                   	nop
c010024c:	c9                   	leave  
c010024d:	c3                   	ret    

c010024e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010024e:	55                   	push   %ebp
c010024f:	89 e5                	mov    %esp,%ebp
c0100251:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100254:	8b 45 08             	mov    0x8(%ebp),%eax
c0100257:	89 04 24             	mov    %eax,(%esp)
c010025a:	e8 c5 13 00 00       	call   c0101624 <cons_putc>
    (*cnt) ++;
c010025f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100262:	8b 00                	mov    (%eax),%eax
c0100264:	8d 50 01             	lea    0x1(%eax),%edx
c0100267:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026a:	89 10                	mov    %edx,(%eax)
}
c010026c:	90                   	nop
c010026d:	c9                   	leave  
c010026e:	c3                   	ret    

c010026f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010026f:	55                   	push   %ebp
c0100270:	89 e5                	mov    %esp,%ebp
c0100272:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010027c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010027f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100283:	8b 45 08             	mov    0x8(%ebp),%eax
c0100286:	89 44 24 08          	mov    %eax,0x8(%esp)
c010028a:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010028d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100291:	c7 04 24 4e 02 10 c0 	movl   $0xc010024e,(%esp)
c0100298:	e8 cd 64 00 00       	call   c010676a <vprintfmt>
    return cnt;
c010029d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a0:	c9                   	leave  
c01002a1:	c3                   	ret    

c01002a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a2:	55                   	push   %ebp
c01002a3:	89 e5                	mov    %esp,%ebp
c01002a5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002a8:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b8:	89 04 24             	mov    %eax,(%esp)
c01002bb:	e8 af ff ff ff       	call   c010026f <vcprintf>
c01002c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c6:	c9                   	leave  
c01002c7:	c3                   	ret    

c01002c8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002c8:	55                   	push   %ebp
c01002c9:	89 e5                	mov    %esp,%ebp
c01002cb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d1:	89 04 24             	mov    %eax,(%esp)
c01002d4:	e8 4b 13 00 00       	call   c0101624 <cons_putc>
}
c01002d9:	90                   	nop
c01002da:	c9                   	leave  
c01002db:	c3                   	ret    

c01002dc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002dc:	55                   	push   %ebp
c01002dd:	89 e5                	mov    %esp,%ebp
c01002df:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002e9:	eb 13                	jmp    c01002fe <cputs+0x22>
        cputch(c, &cnt);
c01002eb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002ef:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002f6:	89 04 24             	mov    %eax,(%esp)
c01002f9:	e8 50 ff ff ff       	call   c010024e <cputch>
    while ((c = *str ++) != '\0') {
c01002fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100301:	8d 50 01             	lea    0x1(%eax),%edx
c0100304:	89 55 08             	mov    %edx,0x8(%ebp)
c0100307:	0f b6 00             	movzbl (%eax),%eax
c010030a:	88 45 f7             	mov    %al,-0x9(%ebp)
c010030d:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100311:	75 d8                	jne    c01002eb <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100313:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100316:	89 44 24 04          	mov    %eax,0x4(%esp)
c010031a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100321:	e8 28 ff ff ff       	call   c010024e <cputch>
    return cnt;
c0100326:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100329:	c9                   	leave  
c010032a:	c3                   	ret    

c010032b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010032b:	55                   	push   %ebp
c010032c:	89 e5                	mov    %esp,%ebp
c010032e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100331:	e8 2b 13 00 00       	call   c0101661 <cons_getc>
c0100336:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010033d:	74 f2                	je     c0100331 <getchar+0x6>
        /* do nothing */;
    return c;
c010033f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100342:	c9                   	leave  
c0100343:	c3                   	ret    

c0100344 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100344:	55                   	push   %ebp
c0100345:	89 e5                	mov    %esp,%ebp
c0100347:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010034a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010034e:	74 13                	je     c0100363 <readline+0x1f>
        cprintf("%s", prompt);
c0100350:	8b 45 08             	mov    0x8(%ebp),%eax
c0100353:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100357:	c7 04 24 c7 6c 10 c0 	movl   $0xc0106cc7,(%esp)
c010035e:	e8 3f ff ff ff       	call   c01002a2 <cprintf>
    }
    int i = 0, c;
c0100363:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010036a:	e8 bc ff ff ff       	call   c010032b <getchar>
c010036f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100372:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100376:	79 07                	jns    c010037f <readline+0x3b>
            return NULL;
c0100378:	b8 00 00 00 00       	mov    $0x0,%eax
c010037d:	eb 78                	jmp    c01003f7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010037f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100383:	7e 28                	jle    c01003ad <readline+0x69>
c0100385:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010038c:	7f 1f                	jg     c01003ad <readline+0x69>
            cputchar(c);
c010038e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100391:	89 04 24             	mov    %eax,(%esp)
c0100394:	e8 2f ff ff ff       	call   c01002c8 <cputchar>
            buf[i ++] = c;
c0100399:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010039c:	8d 50 01             	lea    0x1(%eax),%edx
c010039f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003a5:	88 90 20 d0 11 c0    	mov    %dl,-0x3fee2fe0(%eax)
c01003ab:	eb 45                	jmp    c01003f2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003ad:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003b1:	75 16                	jne    c01003c9 <readline+0x85>
c01003b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003b7:	7e 10                	jle    c01003c9 <readline+0x85>
            cputchar(c);
c01003b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003bc:	89 04 24             	mov    %eax,(%esp)
c01003bf:	e8 04 ff ff ff       	call   c01002c8 <cputchar>
            i --;
c01003c4:	ff 4d f4             	decl   -0xc(%ebp)
c01003c7:	eb 29                	jmp    c01003f2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003c9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003cd:	74 06                	je     c01003d5 <readline+0x91>
c01003cf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003d3:	75 95                	jne    c010036a <readline+0x26>
            cputchar(c);
c01003d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d8:	89 04 24             	mov    %eax,(%esp)
c01003db:	e8 e8 fe ff ff       	call   c01002c8 <cputchar>
            buf[i] = '\0';
c01003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e3:	05 20 d0 11 c0       	add    $0xc011d020,%eax
c01003e8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003eb:	b8 20 d0 11 c0       	mov    $0xc011d020,%eax
c01003f0:	eb 05                	jmp    c01003f7 <readline+0xb3>
        c = getchar();
c01003f2:	e9 73 ff ff ff       	jmp    c010036a <readline+0x26>
        }
    }
}
c01003f7:	c9                   	leave  
c01003f8:	c3                   	ret    

c01003f9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003f9:	55                   	push   %ebp
c01003fa:	89 e5                	mov    %esp,%ebp
c01003fc:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003ff:	a1 20 d4 11 c0       	mov    0xc011d420,%eax
c0100404:	85 c0                	test   %eax,%eax
c0100406:	75 5b                	jne    c0100463 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100408:	c7 05 20 d4 11 c0 01 	movl   $0x1,0xc011d420
c010040f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100412:	8d 45 14             	lea    0x14(%ebp),%eax
c0100415:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100418:	8b 45 0c             	mov    0xc(%ebp),%eax
c010041b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010041f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100422:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100426:	c7 04 24 ca 6c 10 c0 	movl   $0xc0106cca,(%esp)
c010042d:	e8 70 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c0100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100435:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100439:	8b 45 10             	mov    0x10(%ebp),%eax
c010043c:	89 04 24             	mov    %eax,(%esp)
c010043f:	e8 2b fe ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c0100444:	c7 04 24 e6 6c 10 c0 	movl   $0xc0106ce6,(%esp)
c010044b:	e8 52 fe ff ff       	call   c01002a2 <cprintf>
    
    cprintf("stack trackback:\n");
c0100450:	c7 04 24 e8 6c 10 c0 	movl   $0xc0106ce8,(%esp)
c0100457:	e8 46 fe ff ff       	call   c01002a2 <cprintf>
    print_stackframe();
c010045c:	e8 32 06 00 00       	call   c0100a93 <print_stackframe>
c0100461:	eb 01                	jmp    c0100464 <__panic+0x6b>
        goto panic_dead;
c0100463:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100464:	e8 34 14 00 00       	call   c010189d <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100469:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100470:	e8 46 08 00 00       	call   c0100cbb <kmonitor>
c0100475:	eb f2                	jmp    c0100469 <__panic+0x70>

c0100477 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100477:	55                   	push   %ebp
c0100478:	89 e5                	mov    %esp,%ebp
c010047a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010047d:	8d 45 14             	lea    0x14(%ebp),%eax
c0100480:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100483:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100486:	89 44 24 08          	mov    %eax,0x8(%esp)
c010048a:	8b 45 08             	mov    0x8(%ebp),%eax
c010048d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100491:	c7 04 24 fa 6c 10 c0 	movl   $0xc0106cfa,(%esp)
c0100498:	e8 05 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c010049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a7:	89 04 24             	mov    %eax,(%esp)
c01004aa:	e8 c0 fd ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c01004af:	c7 04 24 e6 6c 10 c0 	movl   $0xc0106ce6,(%esp)
c01004b6:	e8 e7 fd ff ff       	call   c01002a2 <cprintf>
    va_end(ap);
}
c01004bb:	90                   	nop
c01004bc:	c9                   	leave  
c01004bd:	c3                   	ret    

c01004be <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004be:	55                   	push   %ebp
c01004bf:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004c1:	a1 20 d4 11 c0       	mov    0xc011d420,%eax
}
c01004c6:	5d                   	pop    %ebp
c01004c7:	c3                   	ret    

c01004c8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004c8:	55                   	push   %ebp
c01004c9:	89 e5                	mov    %esp,%ebp
c01004cb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d1:	8b 00                	mov    (%eax),%eax
c01004d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d9:	8b 00                	mov    (%eax),%eax
c01004db:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004e5:	e9 ca 00 00 00       	jmp    c01005b4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004f0:	01 d0                	add    %edx,%eax
c01004f2:	89 c2                	mov    %eax,%edx
c01004f4:	c1 ea 1f             	shr    $0x1f,%edx
c01004f7:	01 d0                	add    %edx,%eax
c01004f9:	d1 f8                	sar    %eax
c01004fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100501:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100504:	eb 03                	jmp    c0100509 <stab_binsearch+0x41>
            m --;
c0100506:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100509:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010050c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010050f:	7c 1f                	jl     c0100530 <stab_binsearch+0x68>
c0100511:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100514:	89 d0                	mov    %edx,%eax
c0100516:	01 c0                	add    %eax,%eax
c0100518:	01 d0                	add    %edx,%eax
c010051a:	c1 e0 02             	shl    $0x2,%eax
c010051d:	89 c2                	mov    %eax,%edx
c010051f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100522:	01 d0                	add    %edx,%eax
c0100524:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100528:	0f b6 c0             	movzbl %al,%eax
c010052b:	39 45 14             	cmp    %eax,0x14(%ebp)
c010052e:	75 d6                	jne    c0100506 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100530:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100533:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100536:	7d 09                	jge    c0100541 <stab_binsearch+0x79>
            l = true_m + 1;
c0100538:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010053b:	40                   	inc    %eax
c010053c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010053f:	eb 73                	jmp    c01005b4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100541:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100548:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010054b:	89 d0                	mov    %edx,%eax
c010054d:	01 c0                	add    %eax,%eax
c010054f:	01 d0                	add    %edx,%eax
c0100551:	c1 e0 02             	shl    $0x2,%eax
c0100554:	89 c2                	mov    %eax,%edx
c0100556:	8b 45 08             	mov    0x8(%ebp),%eax
c0100559:	01 d0                	add    %edx,%eax
c010055b:	8b 40 08             	mov    0x8(%eax),%eax
c010055e:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100561:	76 11                	jbe    c0100574 <stab_binsearch+0xac>
            *region_left = m;
c0100563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100566:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100569:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010056b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010056e:	40                   	inc    %eax
c010056f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100572:	eb 40                	jmp    c01005b4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100574:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100577:	89 d0                	mov    %edx,%eax
c0100579:	01 c0                	add    %eax,%eax
c010057b:	01 d0                	add    %edx,%eax
c010057d:	c1 e0 02             	shl    $0x2,%eax
c0100580:	89 c2                	mov    %eax,%edx
c0100582:	8b 45 08             	mov    0x8(%ebp),%eax
c0100585:	01 d0                	add    %edx,%eax
c0100587:	8b 40 08             	mov    0x8(%eax),%eax
c010058a:	39 45 18             	cmp    %eax,0x18(%ebp)
c010058d:	73 14                	jae    c01005a3 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010058f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100592:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100595:	8b 45 10             	mov    0x10(%ebp),%eax
c0100598:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010059a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059d:	48                   	dec    %eax
c010059e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a1:	eb 11                	jmp    c01005b4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005a9:	89 10                	mov    %edx,(%eax)
            l = m;
c01005ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01005b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005ba:	0f 8e 2a ff ff ff    	jle    c01004ea <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c4:	75 0f                	jne    c01005d5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c9:	8b 00                	mov    (%eax),%eax
c01005cb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005d3:	eb 3e                	jmp    c0100613 <stab_binsearch+0x14b>
        l = *region_right;
c01005d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d8:	8b 00                	mov    (%eax),%eax
c01005da:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005dd:	eb 03                	jmp    c01005e2 <stab_binsearch+0x11a>
c01005df:	ff 4d fc             	decl   -0x4(%ebp)
c01005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e5:	8b 00                	mov    (%eax),%eax
c01005e7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01005ea:	7e 1f                	jle    c010060b <stab_binsearch+0x143>
c01005ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ef:	89 d0                	mov    %edx,%eax
c01005f1:	01 c0                	add    %eax,%eax
c01005f3:	01 d0                	add    %edx,%eax
c01005f5:	c1 e0 02             	shl    $0x2,%eax
c01005f8:	89 c2                	mov    %eax,%edx
c01005fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fd:	01 d0                	add    %edx,%eax
c01005ff:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100603:	0f b6 c0             	movzbl %al,%eax
c0100606:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100609:	75 d4                	jne    c01005df <stab_binsearch+0x117>
        *region_left = l;
c010060b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100611:	89 10                	mov    %edx,(%eax)
}
c0100613:	90                   	nop
c0100614:	c9                   	leave  
c0100615:	c3                   	ret    

c0100616 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100616:	55                   	push   %ebp
c0100617:	89 e5                	mov    %esp,%ebp
c0100619:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010061c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061f:	c7 00 18 6d 10 c0    	movl   $0xc0106d18,(%eax)
    info->eip_line = 0;
c0100625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	c7 40 08 18 6d 10 c0 	movl   $0xc0106d18,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100639:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100643:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100646:	8b 55 08             	mov    0x8(%ebp),%edx
c0100649:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010064c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100656:	c7 45 f4 48 81 10 c0 	movl   $0xc0108148,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065d:	c7 45 f0 00 44 11 c0 	movl   $0xc0114400,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100664:	c7 45 ec 01 44 11 c0 	movl   $0xc0114401,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010066b:	c7 45 e8 cf 71 11 c0 	movl   $0xc01171cf,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100675:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100678:	76 0b                	jbe    c0100685 <debuginfo_eip+0x6f>
c010067a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067d:	48                   	dec    %eax
c010067e:	0f b6 00             	movzbl (%eax),%eax
c0100681:	84 c0                	test   %al,%al
c0100683:	74 0a                	je     c010068f <debuginfo_eip+0x79>
        return -1;
c0100685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010068a:	e9 b7 02 00 00       	jmp    c0100946 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100696:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100699:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069c:	29 c2                	sub    %eax,%edx
c010069e:	89 d0                	mov    %edx,%eax
c01006a0:	c1 f8 02             	sar    $0x2,%eax
c01006a3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a9:	48                   	dec    %eax
c01006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01006b0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006b4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006bb:	00 
c01006bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006cd:	89 04 24             	mov    %eax,(%esp)
c01006d0:	e8 f3 fd ff ff       	call   c01004c8 <stab_binsearch>
    if (lfile == 0)
c01006d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d8:	85 c0                	test   %eax,%eax
c01006da:	75 0a                	jne    c01006e6 <debuginfo_eip+0xd0>
        return -1;
c01006dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e1:	e9 60 02 00 00       	jmp    c0100946 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100700:	00 
c0100701:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100704:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100708:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010070b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100712:	89 04 24             	mov    %eax,(%esp)
c0100715:	e8 ae fd ff ff       	call   c01004c8 <stab_binsearch>

    if (lfun <= rfun) {
c010071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010071d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100720:	39 c2                	cmp    %eax,%edx
c0100722:	7f 7c                	jg     c01007a0 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100724:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100727:	89 c2                	mov    %eax,%edx
c0100729:	89 d0                	mov    %edx,%eax
c010072b:	01 c0                	add    %eax,%eax
c010072d:	01 d0                	add    %edx,%eax
c010072f:	c1 e0 02             	shl    $0x2,%eax
c0100732:	89 c2                	mov    %eax,%edx
c0100734:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100737:	01 d0                	add    %edx,%eax
c0100739:	8b 00                	mov    (%eax),%eax
c010073b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010073e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100741:	29 d1                	sub    %edx,%ecx
c0100743:	89 ca                	mov    %ecx,%edx
c0100745:	39 d0                	cmp    %edx,%eax
c0100747:	73 22                	jae    c010076b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100749:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010074c:	89 c2                	mov    %eax,%edx
c010074e:	89 d0                	mov    %edx,%eax
c0100750:	01 c0                	add    %eax,%eax
c0100752:	01 d0                	add    %edx,%eax
c0100754:	c1 e0 02             	shl    $0x2,%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	01 d0                	add    %edx,%eax
c010075e:	8b 10                	mov    (%eax),%edx
c0100760:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100763:	01 c2                	add    %eax,%edx
c0100765:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100768:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010076b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010076e:	89 c2                	mov    %eax,%edx
c0100770:	89 d0                	mov    %edx,%eax
c0100772:	01 c0                	add    %eax,%eax
c0100774:	01 d0                	add    %edx,%eax
c0100776:	c1 e0 02             	shl    $0x2,%eax
c0100779:	89 c2                	mov    %eax,%edx
c010077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077e:	01 d0                	add    %edx,%eax
c0100780:	8b 50 08             	mov    0x8(%eax),%edx
c0100783:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100786:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100789:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078c:	8b 40 10             	mov    0x10(%eax),%eax
c010078f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100792:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100795:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100798:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010079b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010079e:	eb 15                	jmp    c01007b5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a3:	8b 55 08             	mov    0x8(%ebp),%edx
c01007a6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007af:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b8:	8b 40 08             	mov    0x8(%eax),%eax
c01007bb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007c2:	00 
c01007c3:	89 04 24             	mov    %eax,(%esp)
c01007c6:	e8 c8 5a 00 00       	call   c0106293 <strfind>
c01007cb:	89 c2                	mov    %eax,%edx
c01007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d0:	8b 40 08             	mov    0x8(%eax),%eax
c01007d3:	29 c2                	sub    %eax,%edx
c01007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007db:	8b 45 08             	mov    0x8(%ebp),%eax
c01007de:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007e2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007e9:	00 
c01007ea:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007f1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fb:	89 04 24             	mov    %eax,(%esp)
c01007fe:	e8 c5 fc ff ff       	call   c01004c8 <stab_binsearch>
    if (lline <= rline) {
c0100803:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100806:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100809:	39 c2                	cmp    %eax,%edx
c010080b:	7f 23                	jg     c0100830 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c010080d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100810:	89 c2                	mov    %eax,%edx
c0100812:	89 d0                	mov    %edx,%eax
c0100814:	01 c0                	add    %eax,%eax
c0100816:	01 d0                	add    %edx,%eax
c0100818:	c1 e0 02             	shl    $0x2,%eax
c010081b:	89 c2                	mov    %eax,%edx
c010081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100820:	01 d0                	add    %edx,%eax
c0100822:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100826:	89 c2                	mov    %eax,%edx
c0100828:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010082e:	eb 11                	jmp    c0100841 <debuginfo_eip+0x22b>
        return -1;
c0100830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100835:	e9 0c 01 00 00       	jmp    c0100946 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010083a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083d:	48                   	dec    %eax
c010083e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100841:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100847:	39 c2                	cmp    %eax,%edx
c0100849:	7c 56                	jl     c01008a1 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084e:	89 c2                	mov    %eax,%edx
c0100850:	89 d0                	mov    %edx,%eax
c0100852:	01 c0                	add    %eax,%eax
c0100854:	01 d0                	add    %edx,%eax
c0100856:	c1 e0 02             	shl    $0x2,%eax
c0100859:	89 c2                	mov    %eax,%edx
c010085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085e:	01 d0                	add    %edx,%eax
c0100860:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100864:	3c 84                	cmp    $0x84,%al
c0100866:	74 39                	je     c01008a1 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100868:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086b:	89 c2                	mov    %eax,%edx
c010086d:	89 d0                	mov    %edx,%eax
c010086f:	01 c0                	add    %eax,%eax
c0100871:	01 d0                	add    %edx,%eax
c0100873:	c1 e0 02             	shl    $0x2,%eax
c0100876:	89 c2                	mov    %eax,%edx
c0100878:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087b:	01 d0                	add    %edx,%eax
c010087d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100881:	3c 64                	cmp    $0x64,%al
c0100883:	75 b5                	jne    c010083a <debuginfo_eip+0x224>
c0100885:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100888:	89 c2                	mov    %eax,%edx
c010088a:	89 d0                	mov    %edx,%eax
c010088c:	01 c0                	add    %eax,%eax
c010088e:	01 d0                	add    %edx,%eax
c0100890:	c1 e0 02             	shl    $0x2,%eax
c0100893:	89 c2                	mov    %eax,%edx
c0100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100898:	01 d0                	add    %edx,%eax
c010089a:	8b 40 08             	mov    0x8(%eax),%eax
c010089d:	85 c0                	test   %eax,%eax
c010089f:	74 99                	je     c010083a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008a7:	39 c2                	cmp    %eax,%edx
c01008a9:	7c 46                	jl     c01008f1 <debuginfo_eip+0x2db>
c01008ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ae:	89 c2                	mov    %eax,%edx
c01008b0:	89 d0                	mov    %edx,%eax
c01008b2:	01 c0                	add    %eax,%eax
c01008b4:	01 d0                	add    %edx,%eax
c01008b6:	c1 e0 02             	shl    $0x2,%eax
c01008b9:	89 c2                	mov    %eax,%edx
c01008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008be:	01 d0                	add    %edx,%eax
c01008c0:	8b 00                	mov    (%eax),%eax
c01008c2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008c8:	29 d1                	sub    %edx,%ecx
c01008ca:	89 ca                	mov    %ecx,%edx
c01008cc:	39 d0                	cmp    %edx,%eax
c01008ce:	73 21                	jae    c01008f1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d3:	89 c2                	mov    %eax,%edx
c01008d5:	89 d0                	mov    %edx,%eax
c01008d7:	01 c0                	add    %eax,%eax
c01008d9:	01 d0                	add    %edx,%eax
c01008db:	c1 e0 02             	shl    $0x2,%eax
c01008de:	89 c2                	mov    %eax,%edx
c01008e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e3:	01 d0                	add    %edx,%eax
c01008e5:	8b 10                	mov    (%eax),%edx
c01008e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008ea:	01 c2                	add    %eax,%edx
c01008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ef:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008f7:	39 c2                	cmp    %eax,%edx
c01008f9:	7d 46                	jge    c0100941 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008fe:	40                   	inc    %eax
c01008ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100902:	eb 16                	jmp    c010091a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100904:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100907:	8b 40 14             	mov    0x14(%eax),%eax
c010090a:	8d 50 01             	lea    0x1(%eax),%edx
c010090d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100910:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100913:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100916:	40                   	inc    %eax
c0100917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010091a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010091d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100920:	39 c2                	cmp    %eax,%edx
c0100922:	7d 1d                	jge    c0100941 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100924:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100927:	89 c2                	mov    %eax,%edx
c0100929:	89 d0                	mov    %edx,%eax
c010092b:	01 c0                	add    %eax,%eax
c010092d:	01 d0                	add    %edx,%eax
c010092f:	c1 e0 02             	shl    $0x2,%eax
c0100932:	89 c2                	mov    %eax,%edx
c0100934:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100937:	01 d0                	add    %edx,%eax
c0100939:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010093d:	3c a0                	cmp    $0xa0,%al
c010093f:	74 c3                	je     c0100904 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
c0100941:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100946:	c9                   	leave  
c0100947:	c3                   	ret    

c0100948 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100948:	55                   	push   %ebp
c0100949:	89 e5                	mov    %esp,%ebp
c010094b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010094e:	c7 04 24 22 6d 10 c0 	movl   $0xc0106d22,(%esp)
c0100955:	e8 48 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010095a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100961:	c0 
c0100962:	c7 04 24 3b 6d 10 c0 	movl   $0xc0106d3b,(%esp)
c0100969:	e8 34 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010096e:	c7 44 24 04 11 6c 10 	movl   $0xc0106c11,0x4(%esp)
c0100975:	c0 
c0100976:	c7 04 24 53 6d 10 c0 	movl   $0xc0106d53,(%esp)
c010097d:	e8 20 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100982:	c7 44 24 04 00 d0 11 	movl   $0xc011d000,0x4(%esp)
c0100989:	c0 
c010098a:	c7 04 24 6b 6d 10 c0 	movl   $0xc0106d6b,(%esp)
c0100991:	e8 0c f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100996:	c7 44 24 04 60 14 1e 	movl   $0xc01e1460,0x4(%esp)
c010099d:	c0 
c010099e:	c7 04 24 83 6d 10 c0 	movl   $0xc0106d83,(%esp)
c01009a5:	e8 f8 f8 ff ff       	call   c01002a2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009aa:	b8 60 14 1e c0       	mov    $0xc01e1460,%eax
c01009af:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009ba:	29 c2                	sub    %eax,%edx
c01009bc:	89 d0                	mov    %edx,%eax
c01009be:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009c4:	85 c0                	test   %eax,%eax
c01009c6:	0f 48 c2             	cmovs  %edx,%eax
c01009c9:	c1 f8 0a             	sar    $0xa,%eax
c01009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d0:	c7 04 24 9c 6d 10 c0 	movl   $0xc0106d9c,(%esp)
c01009d7:	e8 c6 f8 ff ff       	call   c01002a2 <cprintf>
}
c01009dc:	90                   	nop
c01009dd:	c9                   	leave  
c01009de:	c3                   	ret    

c01009df <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009df:	55                   	push   %ebp
c01009e0:	89 e5                	mov    %esp,%ebp
c01009e2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f2:	89 04 24             	mov    %eax,(%esp)
c01009f5:	e8 1c fc ff ff       	call   c0100616 <debuginfo_eip>
c01009fa:	85 c0                	test   %eax,%eax
c01009fc:	74 15                	je     c0100a13 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a05:	c7 04 24 c6 6d 10 c0 	movl   $0xc0106dc6,(%esp)
c0100a0c:	e8 91 f8 ff ff       	call   c01002a2 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a11:	eb 6c                	jmp    c0100a7f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a1a:	eb 1b                	jmp    c0100a37 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a22:	01 d0                	add    %edx,%eax
c0100a24:	0f b6 00             	movzbl (%eax),%eax
c0100a27:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a30:	01 ca                	add    %ecx,%edx
c0100a32:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a34:	ff 45 f4             	incl   -0xc(%ebp)
c0100a37:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a3a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a3d:	7c dd                	jl     c0100a1c <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a3f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a48:	01 d0                	add    %edx,%eax
c0100a4a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a50:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a53:	89 d1                	mov    %edx,%ecx
c0100a55:	29 c1                	sub    %eax,%ecx
c0100a57:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a5d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a61:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a67:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a6b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a73:	c7 04 24 e2 6d 10 c0 	movl   $0xc0106de2,(%esp)
c0100a7a:	e8 23 f8 ff ff       	call   c01002a2 <cprintf>
}
c0100a7f:	90                   	nop
c0100a80:	c9                   	leave  
c0100a81:	c3                   	ret    

c0100a82 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a82:	55                   	push   %ebp
c0100a83:	89 e5                	mov    %esp,%ebp
c0100a85:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a88:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a91:	c9                   	leave  
c0100a92:	c3                   	ret    

c0100a93 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a93:	55                   	push   %ebp
c0100a94:	89 e5                	mov    %esp,%ebp
c0100a96:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a99:	89 e8                	mov    %ebp,%eax
c0100a9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c0100aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c0100aa4:	e8 d9 ff ff ff       	call   c0100a82 <read_eip>
c0100aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c0100aac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ab3:	e9 84 00 00 00       	jmp    c0100b3c <print_stackframe+0xa9>
    	cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c0100ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100abb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac6:	c7 04 24 f4 6d 10 c0 	movl   $0xc0106df4,(%esp)
c0100acd:	e8 d0 f7 ff ff       	call   c01002a2 <cprintf>
    	uint32_t *calling_arguments = (uint32_t *) ebp + 2;
c0100ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ad5:	83 c0 08             	add    $0x8,%eax
c0100ad8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    	for(int j=0;j<4;j++)
c0100adb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ae2:	eb 24                	jmp    c0100b08 <print_stackframe+0x75>
    		cprintf(" 0x%08x ", calling_arguments[j]);		
c0100ae4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ae7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100af1:	01 d0                	add    %edx,%eax
c0100af3:	8b 00                	mov    (%eax),%eax
c0100af5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100af9:	c7 04 24 10 6e 10 c0 	movl   $0xc0106e10,(%esp)
c0100b00:	e8 9d f7 ff ff       	call   c01002a2 <cprintf>
    	for(int j=0;j<4;j++)
c0100b05:	ff 45 e8             	incl   -0x18(%ebp)
c0100b08:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b0c:	7e d6                	jle    c0100ae4 <print_stackframe+0x51>
        cprintf("\n");
c0100b0e:	c7 04 24 19 6e 10 c0 	movl   $0xc0106e19,(%esp)
c0100b15:	e8 88 f7 ff ff       	call   c01002a2 <cprintf>
		print_debuginfo(eip-1);
c0100b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b1d:	48                   	dec    %eax
c0100b1e:	89 04 24             	mov    %eax,(%esp)
c0100b21:	e8 b9 fe ff ff       	call   c01009df <print_debuginfo>
    	eip = ((uint32_t *)ebp)[1];
c0100b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b29:	83 c0 04             	add    $0x4,%eax
c0100b2c:	8b 00                	mov    (%eax),%eax
c0100b2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    	ebp = ((uint32_t *)ebp)[0];
c0100b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b34:	8b 00                	mov    (%eax),%eax
c0100b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c0100b39:	ff 45 ec             	incl   -0x14(%ebp)
c0100b3c:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b40:	7f 0a                	jg     c0100b4c <print_stackframe+0xb9>
c0100b42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b46:	0f 85 6c ff ff ff    	jne    c0100ab8 <print_stackframe+0x25>
	}
}
c0100b4c:	90                   	nop
c0100b4d:	c9                   	leave  
c0100b4e:	c3                   	ret    

c0100b4f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b4f:	55                   	push   %ebp
c0100b50:	89 e5                	mov    %esp,%ebp
c0100b52:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5c:	eb 0c                	jmp    c0100b6a <parse+0x1b>
            *buf ++ = '\0';
c0100b5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b61:	8d 50 01             	lea    0x1(%eax),%edx
c0100b64:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b67:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6d:	0f b6 00             	movzbl (%eax),%eax
c0100b70:	84 c0                	test   %al,%al
c0100b72:	74 1d                	je     c0100b91 <parse+0x42>
c0100b74:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b77:	0f b6 00             	movzbl (%eax),%eax
c0100b7a:	0f be c0             	movsbl %al,%eax
c0100b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b81:	c7 04 24 9c 6e 10 c0 	movl   $0xc0106e9c,(%esp)
c0100b88:	e8 d4 56 00 00       	call   c0106261 <strchr>
c0100b8d:	85 c0                	test   %eax,%eax
c0100b8f:	75 cd                	jne    c0100b5e <parse+0xf>
        }
        if (*buf == '\0') {
c0100b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b94:	0f b6 00             	movzbl (%eax),%eax
c0100b97:	84 c0                	test   %al,%al
c0100b99:	74 65                	je     c0100c00 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b9b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b9f:	75 14                	jne    c0100bb5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ba1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ba8:	00 
c0100ba9:	c7 04 24 a1 6e 10 c0 	movl   $0xc0106ea1,(%esp)
c0100bb0:	e8 ed f6 ff ff       	call   c01002a2 <cprintf>
        }
        argv[argc ++] = buf;
c0100bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bb8:	8d 50 01             	lea    0x1(%eax),%edx
c0100bbb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bc8:	01 c2                	add    %eax,%edx
c0100bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bcf:	eb 03                	jmp    c0100bd4 <parse+0x85>
            buf ++;
c0100bd1:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd7:	0f b6 00             	movzbl (%eax),%eax
c0100bda:	84 c0                	test   %al,%al
c0100bdc:	74 8c                	je     c0100b6a <parse+0x1b>
c0100bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be1:	0f b6 00             	movzbl (%eax),%eax
c0100be4:	0f be c0             	movsbl %al,%eax
c0100be7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100beb:	c7 04 24 9c 6e 10 c0 	movl   $0xc0106e9c,(%esp)
c0100bf2:	e8 6a 56 00 00       	call   c0106261 <strchr>
c0100bf7:	85 c0                	test   %eax,%eax
c0100bf9:	74 d6                	je     c0100bd1 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bfb:	e9 6a ff ff ff       	jmp    c0100b6a <parse+0x1b>
            break;
c0100c00:	90                   	nop
        }
    }
    return argc;
c0100c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c04:	c9                   	leave  
c0100c05:	c3                   	ret    

c0100c06 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c06:	55                   	push   %ebp
c0100c07:	89 e5                	mov    %esp,%ebp
c0100c09:	53                   	push   %ebx
c0100c0a:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c0d:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c14:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c17:	89 04 24             	mov    %eax,(%esp)
c0100c1a:	e8 30 ff ff ff       	call   c0100b4f <parse>
c0100c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c26:	75 0a                	jne    c0100c32 <runcmd+0x2c>
        return 0;
c0100c28:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c2d:	e9 83 00 00 00       	jmp    c0100cb5 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c39:	eb 5a                	jmp    c0100c95 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c3b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c41:	89 d0                	mov    %edx,%eax
c0100c43:	01 c0                	add    %eax,%eax
c0100c45:	01 d0                	add    %edx,%eax
c0100c47:	c1 e0 02             	shl    $0x2,%eax
c0100c4a:	05 00 a0 11 c0       	add    $0xc011a000,%eax
c0100c4f:	8b 00                	mov    (%eax),%eax
c0100c51:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c55:	89 04 24             	mov    %eax,(%esp)
c0100c58:	e8 67 55 00 00       	call   c01061c4 <strcmp>
c0100c5d:	85 c0                	test   %eax,%eax
c0100c5f:	75 31                	jne    c0100c92 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c64:	89 d0                	mov    %edx,%eax
c0100c66:	01 c0                	add    %eax,%eax
c0100c68:	01 d0                	add    %edx,%eax
c0100c6a:	c1 e0 02             	shl    $0x2,%eax
c0100c6d:	05 08 a0 11 c0       	add    $0xc011a008,%eax
c0100c72:	8b 10                	mov    (%eax),%edx
c0100c74:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c77:	83 c0 04             	add    $0x4,%eax
c0100c7a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c7d:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8b:	89 1c 24             	mov    %ebx,(%esp)
c0100c8e:	ff d2                	call   *%edx
c0100c90:	eb 23                	jmp    c0100cb5 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c92:	ff 45 f4             	incl   -0xc(%ebp)
c0100c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c98:	83 f8 02             	cmp    $0x2,%eax
c0100c9b:	76 9e                	jbe    c0100c3b <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c9d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca4:	c7 04 24 bf 6e 10 c0 	movl   $0xc0106ebf,(%esp)
c0100cab:	e8 f2 f5 ff ff       	call   c01002a2 <cprintf>
    return 0;
c0100cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cb5:	83 c4 64             	add    $0x64,%esp
c0100cb8:	5b                   	pop    %ebx
c0100cb9:	5d                   	pop    %ebp
c0100cba:	c3                   	ret    

c0100cbb <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cbb:	55                   	push   %ebp
c0100cbc:	89 e5                	mov    %esp,%ebp
c0100cbe:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cc1:	c7 04 24 d8 6e 10 c0 	movl   $0xc0106ed8,(%esp)
c0100cc8:	e8 d5 f5 ff ff       	call   c01002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100ccd:	c7 04 24 00 6f 10 c0 	movl   $0xc0106f00,(%esp)
c0100cd4:	e8 c9 f5 ff ff       	call   c01002a2 <cprintf>

    if (tf != NULL) {
c0100cd9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cdd:	74 0b                	je     c0100cea <kmonitor+0x2f>
        print_trapframe(tf);
c0100cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce2:	89 04 24             	mov    %eax,(%esp)
c0100ce5:	e8 08 0e 00 00       	call   c0101af2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cea:	c7 04 24 25 6f 10 c0 	movl   $0xc0106f25,(%esp)
c0100cf1:	e8 4e f6 ff ff       	call   c0100344 <readline>
c0100cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cf9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100cfd:	74 eb                	je     c0100cea <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100cff:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d09:	89 04 24             	mov    %eax,(%esp)
c0100d0c:	e8 f5 fe ff ff       	call   c0100c06 <runcmd>
c0100d11:	85 c0                	test   %eax,%eax
c0100d13:	78 02                	js     c0100d17 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d15:	eb d3                	jmp    c0100cea <kmonitor+0x2f>
                break;
c0100d17:	90                   	nop
            }
        }
    }
}
c0100d18:	90                   	nop
c0100d19:	c9                   	leave  
c0100d1a:	c3                   	ret    

c0100d1b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d1b:	55                   	push   %ebp
c0100d1c:	89 e5                	mov    %esp,%ebp
c0100d1e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d28:	eb 3d                	jmp    c0100d67 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d2d:	89 d0                	mov    %edx,%eax
c0100d2f:	01 c0                	add    %eax,%eax
c0100d31:	01 d0                	add    %edx,%eax
c0100d33:	c1 e0 02             	shl    $0x2,%eax
c0100d36:	05 04 a0 11 c0       	add    $0xc011a004,%eax
c0100d3b:	8b 08                	mov    (%eax),%ecx
c0100d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d40:	89 d0                	mov    %edx,%eax
c0100d42:	01 c0                	add    %eax,%eax
c0100d44:	01 d0                	add    %edx,%eax
c0100d46:	c1 e0 02             	shl    $0x2,%eax
c0100d49:	05 00 a0 11 c0       	add    $0xc011a000,%eax
c0100d4e:	8b 00                	mov    (%eax),%eax
c0100d50:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d54:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d58:	c7 04 24 29 6f 10 c0 	movl   $0xc0106f29,(%esp)
c0100d5f:	e8 3e f5 ff ff       	call   c01002a2 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d64:	ff 45 f4             	incl   -0xc(%ebp)
c0100d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d6a:	83 f8 02             	cmp    $0x2,%eax
c0100d6d:	76 bb                	jbe    c0100d2a <mon_help+0xf>
    }
    return 0;
c0100d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d74:	c9                   	leave  
c0100d75:	c3                   	ret    

c0100d76 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d76:	55                   	push   %ebp
c0100d77:	89 e5                	mov    %esp,%ebp
c0100d79:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d7c:	e8 c7 fb ff ff       	call   c0100948 <print_kerninfo>
    return 0;
c0100d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d86:	c9                   	leave  
c0100d87:	c3                   	ret    

c0100d88 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d88:	55                   	push   %ebp
c0100d89:	89 e5                	mov    %esp,%ebp
c0100d8b:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d8e:	e8 00 fd ff ff       	call   c0100a93 <print_stackframe>
    return 0;
c0100d93:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d98:	c9                   	leave  
c0100d99:	c3                   	ret    

c0100d9a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d9a:	55                   	push   %ebp
c0100d9b:	89 e5                	mov    %esp,%ebp
c0100d9d:	83 ec 28             	sub    $0x28,%esp
c0100da0:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100da6:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100daa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dae:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100db2:	ee                   	out    %al,(%dx)
c0100db3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100db9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dbd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dc5:	ee                   	out    %al,(%dx)
c0100dc6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100dcc:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c0100dd0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dd4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dd8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dd9:	c7 05 0c df 11 c0 00 	movl   $0x0,0xc011df0c
c0100de0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100de3:	c7 04 24 32 6f 10 c0 	movl   $0xc0106f32,(%esp)
c0100dea:	e8 b3 f4 ff ff       	call   c01002a2 <cprintf>
    pic_enable(IRQ_TIMER);
c0100def:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100df6:	e8 2e 09 00 00       	call   c0101729 <pic_enable>
}
c0100dfb:	90                   	nop
c0100dfc:	c9                   	leave  
c0100dfd:	c3                   	ret    

c0100dfe <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100dfe:	55                   	push   %ebp
c0100dff:	89 e5                	mov    %esp,%ebp
c0100e01:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e04:	9c                   	pushf  
c0100e05:	58                   	pop    %eax
c0100e06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e0c:	25 00 02 00 00       	and    $0x200,%eax
c0100e11:	85 c0                	test   %eax,%eax
c0100e13:	74 0c                	je     c0100e21 <__intr_save+0x23>
        intr_disable();
c0100e15:	e8 83 0a 00 00       	call   c010189d <intr_disable>
        return 1;
c0100e1a:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e1f:	eb 05                	jmp    c0100e26 <__intr_save+0x28>
    }
    return 0;
c0100e21:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e26:	c9                   	leave  
c0100e27:	c3                   	ret    

c0100e28 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e28:	55                   	push   %ebp
c0100e29:	89 e5                	mov    %esp,%ebp
c0100e2b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e2e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e32:	74 05                	je     c0100e39 <__intr_restore+0x11>
        intr_enable();
c0100e34:	e8 5d 0a 00 00       	call   c0101896 <intr_enable>
    }
}
c0100e39:	90                   	nop
c0100e3a:	c9                   	leave  
c0100e3b:	c3                   	ret    

c0100e3c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e3c:	55                   	push   %ebp
c0100e3d:	89 e5                	mov    %esp,%ebp
c0100e3f:	83 ec 10             	sub    $0x10,%esp
c0100e42:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e48:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e4c:	89 c2                	mov    %eax,%edx
c0100e4e:	ec                   	in     (%dx),%al
c0100e4f:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e52:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e58:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e5c:	89 c2                	mov    %eax,%edx
c0100e5e:	ec                   	in     (%dx),%al
c0100e5f:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e62:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e68:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e6c:	89 c2                	mov    %eax,%edx
c0100e6e:	ec                   	in     (%dx),%al
c0100e6f:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e72:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e78:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e7c:	89 c2                	mov    %eax,%edx
c0100e7e:	ec                   	in     (%dx),%al
c0100e7f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e82:	90                   	nop
c0100e83:	c9                   	leave  
c0100e84:	c3                   	ret    

c0100e85 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e85:	55                   	push   %ebp
c0100e86:	89 e5                	mov    %esp,%ebp
c0100e88:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e8b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e95:	0f b7 00             	movzwl (%eax),%eax
c0100e98:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e9f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea7:	0f b7 00             	movzwl (%eax),%eax
c0100eaa:	0f b7 c0             	movzwl %ax,%eax
c0100ead:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100eb2:	74 12                	je     c0100ec6 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100eb4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ebb:	66 c7 05 46 d4 11 c0 	movw   $0x3b4,0xc011d446
c0100ec2:	b4 03 
c0100ec4:	eb 13                	jmp    c0100ed9 <cga_init+0x54>
    } else {
        *cp = was;
c0100ec6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ecd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ed0:	66 c7 05 46 d4 11 c0 	movw   $0x3d4,0xc011d446
c0100ed7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ed9:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100ee0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100ee4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100eec:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100ef0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ef1:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100ef8:	40                   	inc    %eax
c0100ef9:	0f b7 c0             	movzwl %ax,%eax
c0100efc:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f00:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f04:	89 c2                	mov    %eax,%edx
c0100f06:	ec                   	in     (%dx),%al
c0100f07:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f0a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f0e:	0f b6 c0             	movzbl %al,%eax
c0100f11:	c1 e0 08             	shl    $0x8,%eax
c0100f14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f17:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100f1e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f22:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f26:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f2a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f2e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f2f:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100f36:	40                   	inc    %eax
c0100f37:	0f b7 c0             	movzwl %ax,%eax
c0100f3a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f3e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f42:	89 c2                	mov    %eax,%edx
c0100f44:	ec                   	in     (%dx),%al
c0100f45:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f48:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f4c:	0f b6 c0             	movzbl %al,%eax
c0100f4f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f52:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f55:	a3 40 d4 11 c0       	mov    %eax,0xc011d440
    crt_pos = pos;
c0100f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f5d:	0f b7 c0             	movzwl %ax,%eax
c0100f60:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
}
c0100f66:	90                   	nop
c0100f67:	c9                   	leave  
c0100f68:	c3                   	ret    

c0100f69 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f69:	55                   	push   %ebp
c0100f6a:	89 e5                	mov    %esp,%ebp
c0100f6c:	83 ec 48             	sub    $0x48,%esp
c0100f6f:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100f75:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f79:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f7d:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100f81:	ee                   	out    %al,(%dx)
c0100f82:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100f88:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c0100f8c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100f90:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100f94:	ee                   	out    %al,(%dx)
c0100f95:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100f9b:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c0100f9f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fa3:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fa7:	ee                   	out    %al,(%dx)
c0100fa8:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fae:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fb2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fb6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fba:	ee                   	out    %al,(%dx)
c0100fbb:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100fc1:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0100fc5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fc9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fcd:	ee                   	out    %al,(%dx)
c0100fce:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0100fd4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0100fd8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fdc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fe0:	ee                   	out    %al,(%dx)
c0100fe1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fe7:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c0100feb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fef:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100ff3:	ee                   	out    %al,(%dx)
c0100ff4:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ffa:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100ffe:	89 c2                	mov    %eax,%edx
c0101000:	ec                   	in     (%dx),%al
c0101001:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101004:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101008:	3c ff                	cmp    $0xff,%al
c010100a:	0f 95 c0             	setne  %al
c010100d:	0f b6 c0             	movzbl %al,%eax
c0101010:	a3 48 d4 11 c0       	mov    %eax,0xc011d448
c0101015:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010101f:	89 c2                	mov    %eax,%edx
c0101021:	ec                   	in     (%dx),%al
c0101022:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101025:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010102b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010102f:	89 c2                	mov    %eax,%edx
c0101031:	ec                   	in     (%dx),%al
c0101032:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101035:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c010103a:	85 c0                	test   %eax,%eax
c010103c:	74 0c                	je     c010104a <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010103e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101045:	e8 df 06 00 00       	call   c0101729 <pic_enable>
    }
}
c010104a:	90                   	nop
c010104b:	c9                   	leave  
c010104c:	c3                   	ret    

c010104d <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010104d:	55                   	push   %ebp
c010104e:	89 e5                	mov    %esp,%ebp
c0101050:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101053:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010105a:	eb 08                	jmp    c0101064 <lpt_putc_sub+0x17>
        delay();
c010105c:	e8 db fd ff ff       	call   c0100e3c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101061:	ff 45 fc             	incl   -0x4(%ebp)
c0101064:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010106a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010106e:	89 c2                	mov    %eax,%edx
c0101070:	ec                   	in     (%dx),%al
c0101071:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101074:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101078:	84 c0                	test   %al,%al
c010107a:	78 09                	js     c0101085 <lpt_putc_sub+0x38>
c010107c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101083:	7e d7                	jle    c010105c <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101085:	8b 45 08             	mov    0x8(%ebp),%eax
c0101088:	0f b6 c0             	movzbl %al,%eax
c010108b:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101091:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101094:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101098:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010109c:	ee                   	out    %al,(%dx)
c010109d:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010a3:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010a7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010ab:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010af:	ee                   	out    %al,(%dx)
c01010b0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010b6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c01010ba:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010be:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010c2:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010c3:	90                   	nop
c01010c4:	c9                   	leave  
c01010c5:	c3                   	ret    

c01010c6 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010c6:	55                   	push   %ebp
c01010c7:	89 e5                	mov    %esp,%ebp
c01010c9:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010cc:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010d0:	74 0d                	je     c01010df <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01010d5:	89 04 24             	mov    %eax,(%esp)
c01010d8:	e8 70 ff ff ff       	call   c010104d <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010dd:	eb 24                	jmp    c0101103 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c01010df:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e6:	e8 62 ff ff ff       	call   c010104d <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010f2:	e8 56 ff ff ff       	call   c010104d <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010f7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010fe:	e8 4a ff ff ff       	call   c010104d <lpt_putc_sub>
}
c0101103:	90                   	nop
c0101104:	c9                   	leave  
c0101105:	c3                   	ret    

c0101106 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101106:	55                   	push   %ebp
c0101107:	89 e5                	mov    %esp,%ebp
c0101109:	53                   	push   %ebx
c010110a:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010110d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101110:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101115:	85 c0                	test   %eax,%eax
c0101117:	75 07                	jne    c0101120 <cga_putc+0x1a>
        c |= 0x0700;
c0101119:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101120:	8b 45 08             	mov    0x8(%ebp),%eax
c0101123:	0f b6 c0             	movzbl %al,%eax
c0101126:	83 f8 0a             	cmp    $0xa,%eax
c0101129:	74 55                	je     c0101180 <cga_putc+0x7a>
c010112b:	83 f8 0d             	cmp    $0xd,%eax
c010112e:	74 63                	je     c0101193 <cga_putc+0x8d>
c0101130:	83 f8 08             	cmp    $0x8,%eax
c0101133:	0f 85 94 00 00 00    	jne    c01011cd <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c0101139:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101140:	85 c0                	test   %eax,%eax
c0101142:	0f 84 af 00 00 00    	je     c01011f7 <cga_putc+0xf1>
            crt_pos --;
c0101148:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c010114f:	48                   	dec    %eax
c0101150:	0f b7 c0             	movzwl %ax,%eax
c0101153:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101159:	8b 45 08             	mov    0x8(%ebp),%eax
c010115c:	98                   	cwtl   
c010115d:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101162:	98                   	cwtl   
c0101163:	83 c8 20             	or     $0x20,%eax
c0101166:	98                   	cwtl   
c0101167:	8b 15 40 d4 11 c0    	mov    0xc011d440,%edx
c010116d:	0f b7 0d 44 d4 11 c0 	movzwl 0xc011d444,%ecx
c0101174:	01 c9                	add    %ecx,%ecx
c0101176:	01 ca                	add    %ecx,%edx
c0101178:	0f b7 c0             	movzwl %ax,%eax
c010117b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010117e:	eb 77                	jmp    c01011f7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c0101180:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101187:	83 c0 50             	add    $0x50,%eax
c010118a:	0f b7 c0             	movzwl %ax,%eax
c010118d:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101193:	0f b7 1d 44 d4 11 c0 	movzwl 0xc011d444,%ebx
c010119a:	0f b7 0d 44 d4 11 c0 	movzwl 0xc011d444,%ecx
c01011a1:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011a6:	89 c8                	mov    %ecx,%eax
c01011a8:	f7 e2                	mul    %edx
c01011aa:	c1 ea 06             	shr    $0x6,%edx
c01011ad:	89 d0                	mov    %edx,%eax
c01011af:	c1 e0 02             	shl    $0x2,%eax
c01011b2:	01 d0                	add    %edx,%eax
c01011b4:	c1 e0 04             	shl    $0x4,%eax
c01011b7:	29 c1                	sub    %eax,%ecx
c01011b9:	89 c8                	mov    %ecx,%eax
c01011bb:	0f b7 c0             	movzwl %ax,%eax
c01011be:	29 c3                	sub    %eax,%ebx
c01011c0:	89 d8                	mov    %ebx,%eax
c01011c2:	0f b7 c0             	movzwl %ax,%eax
c01011c5:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
        break;
c01011cb:	eb 2b                	jmp    c01011f8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011cd:	8b 0d 40 d4 11 c0    	mov    0xc011d440,%ecx
c01011d3:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01011da:	8d 50 01             	lea    0x1(%eax),%edx
c01011dd:	0f b7 d2             	movzwl %dx,%edx
c01011e0:	66 89 15 44 d4 11 c0 	mov    %dx,0xc011d444
c01011e7:	01 c0                	add    %eax,%eax
c01011e9:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01011ef:	0f b7 c0             	movzwl %ax,%eax
c01011f2:	66 89 02             	mov    %ax,(%edx)
        break;
c01011f5:	eb 01                	jmp    c01011f8 <cga_putc+0xf2>
        break;
c01011f7:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011f8:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01011ff:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101204:	76 5d                	jbe    c0101263 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101206:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c010120b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101211:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c0101216:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010121d:	00 
c010121e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101222:	89 04 24             	mov    %eax,(%esp)
c0101225:	e8 2d 52 00 00       	call   c0106457 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010122a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101231:	eb 14                	jmp    c0101247 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101233:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c0101238:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010123b:	01 d2                	add    %edx,%edx
c010123d:	01 d0                	add    %edx,%eax
c010123f:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101244:	ff 45 f4             	incl   -0xc(%ebp)
c0101247:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010124e:	7e e3                	jle    c0101233 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
c0101250:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101257:	83 e8 50             	sub    $0x50,%eax
c010125a:	0f b7 c0             	movzwl %ax,%eax
c010125d:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101263:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c010126a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010126e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101272:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101276:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010127a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010127b:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101282:	c1 e8 08             	shr    $0x8,%eax
c0101285:	0f b7 c0             	movzwl %ax,%eax
c0101288:	0f b6 c0             	movzbl %al,%eax
c010128b:	0f b7 15 46 d4 11 c0 	movzwl 0xc011d446,%edx
c0101292:	42                   	inc    %edx
c0101293:	0f b7 d2             	movzwl %dx,%edx
c0101296:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010129a:	88 45 e9             	mov    %al,-0x17(%ebp)
c010129d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012a1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012a5:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012a6:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c01012ad:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012b1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c01012b5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012b9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012bd:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012be:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01012c5:	0f b6 c0             	movzbl %al,%eax
c01012c8:	0f b7 15 46 d4 11 c0 	movzwl 0xc011d446,%edx
c01012cf:	42                   	inc    %edx
c01012d0:	0f b7 d2             	movzwl %dx,%edx
c01012d3:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c01012d7:	88 45 f1             	mov    %al,-0xf(%ebp)
c01012da:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01012de:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012e2:	ee                   	out    %al,(%dx)
}
c01012e3:	90                   	nop
c01012e4:	83 c4 34             	add    $0x34,%esp
c01012e7:	5b                   	pop    %ebx
c01012e8:	5d                   	pop    %ebp
c01012e9:	c3                   	ret    

c01012ea <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012ea:	55                   	push   %ebp
c01012eb:	89 e5                	mov    %esp,%ebp
c01012ed:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012f7:	eb 08                	jmp    c0101301 <serial_putc_sub+0x17>
        delay();
c01012f9:	e8 3e fb ff ff       	call   c0100e3c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012fe:	ff 45 fc             	incl   -0x4(%ebp)
c0101301:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101307:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010130b:	89 c2                	mov    %eax,%edx
c010130d:	ec                   	in     (%dx),%al
c010130e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101311:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101315:	0f b6 c0             	movzbl %al,%eax
c0101318:	83 e0 20             	and    $0x20,%eax
c010131b:	85 c0                	test   %eax,%eax
c010131d:	75 09                	jne    c0101328 <serial_putc_sub+0x3e>
c010131f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101326:	7e d1                	jle    c01012f9 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101328:	8b 45 08             	mov    0x8(%ebp),%eax
c010132b:	0f b6 c0             	movzbl %al,%eax
c010132e:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101334:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101337:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010133b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010133f:	ee                   	out    %al,(%dx)
}
c0101340:	90                   	nop
c0101341:	c9                   	leave  
c0101342:	c3                   	ret    

c0101343 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101343:	55                   	push   %ebp
c0101344:	89 e5                	mov    %esp,%ebp
c0101346:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101349:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010134d:	74 0d                	je     c010135c <serial_putc+0x19>
        serial_putc_sub(c);
c010134f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101352:	89 04 24             	mov    %eax,(%esp)
c0101355:	e8 90 ff ff ff       	call   c01012ea <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010135a:	eb 24                	jmp    c0101380 <serial_putc+0x3d>
        serial_putc_sub('\b');
c010135c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101363:	e8 82 ff ff ff       	call   c01012ea <serial_putc_sub>
        serial_putc_sub(' ');
c0101368:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010136f:	e8 76 ff ff ff       	call   c01012ea <serial_putc_sub>
        serial_putc_sub('\b');
c0101374:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010137b:	e8 6a ff ff ff       	call   c01012ea <serial_putc_sub>
}
c0101380:	90                   	nop
c0101381:	c9                   	leave  
c0101382:	c3                   	ret    

c0101383 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101383:	55                   	push   %ebp
c0101384:	89 e5                	mov    %esp,%ebp
c0101386:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101389:	eb 33                	jmp    c01013be <cons_intr+0x3b>
        if (c != 0) {
c010138b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010138f:	74 2d                	je     c01013be <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101391:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c0101396:	8d 50 01             	lea    0x1(%eax),%edx
c0101399:	89 15 64 d6 11 c0    	mov    %edx,0xc011d664
c010139f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013a2:	88 90 60 d4 11 c0    	mov    %dl,-0x3fee2ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013a8:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c01013ad:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013b2:	75 0a                	jne    c01013be <cons_intr+0x3b>
                cons.wpos = 0;
c01013b4:	c7 05 64 d6 11 c0 00 	movl   $0x0,0xc011d664
c01013bb:	00 00 00 
    while ((c = (*proc)()) != -1) {
c01013be:	8b 45 08             	mov    0x8(%ebp),%eax
c01013c1:	ff d0                	call   *%eax
c01013c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013c6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013ca:	75 bf                	jne    c010138b <cons_intr+0x8>
            }
        }
    }
}
c01013cc:	90                   	nop
c01013cd:	c9                   	leave  
c01013ce:	c3                   	ret    

c01013cf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013cf:	55                   	push   %ebp
c01013d0:	89 e5                	mov    %esp,%ebp
c01013d2:	83 ec 10             	sub    $0x10,%esp
c01013d5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013db:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013df:	89 c2                	mov    %eax,%edx
c01013e1:	ec                   	in     (%dx),%al
c01013e2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013e5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013e9:	0f b6 c0             	movzbl %al,%eax
c01013ec:	83 e0 01             	and    $0x1,%eax
c01013ef:	85 c0                	test   %eax,%eax
c01013f1:	75 07                	jne    c01013fa <serial_proc_data+0x2b>
        return -1;
c01013f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013f8:	eb 2a                	jmp    c0101424 <serial_proc_data+0x55>
c01013fa:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101400:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101404:	89 c2                	mov    %eax,%edx
c0101406:	ec                   	in     (%dx),%al
c0101407:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010140a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010140e:	0f b6 c0             	movzbl %al,%eax
c0101411:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101414:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101418:	75 07                	jne    c0101421 <serial_proc_data+0x52>
        c = '\b';
c010141a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101421:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101424:	c9                   	leave  
c0101425:	c3                   	ret    

c0101426 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101426:	55                   	push   %ebp
c0101427:	89 e5                	mov    %esp,%ebp
c0101429:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010142c:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c0101431:	85 c0                	test   %eax,%eax
c0101433:	74 0c                	je     c0101441 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101435:	c7 04 24 cf 13 10 c0 	movl   $0xc01013cf,(%esp)
c010143c:	e8 42 ff ff ff       	call   c0101383 <cons_intr>
    }
}
c0101441:	90                   	nop
c0101442:	c9                   	leave  
c0101443:	c3                   	ret    

c0101444 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101444:	55                   	push   %ebp
c0101445:	89 e5                	mov    %esp,%ebp
c0101447:	83 ec 38             	sub    $0x38,%esp
c010144a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101450:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101453:	89 c2                	mov    %eax,%edx
c0101455:	ec                   	in     (%dx),%al
c0101456:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101459:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010145d:	0f b6 c0             	movzbl %al,%eax
c0101460:	83 e0 01             	and    $0x1,%eax
c0101463:	85 c0                	test   %eax,%eax
c0101465:	75 0a                	jne    c0101471 <kbd_proc_data+0x2d>
        return -1;
c0101467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010146c:	e9 55 01 00 00       	jmp    c01015c6 <kbd_proc_data+0x182>
c0101471:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101477:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010147a:	89 c2                	mov    %eax,%edx
c010147c:	ec                   	in     (%dx),%al
c010147d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101480:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101484:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101487:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010148b:	75 17                	jne    c01014a4 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c010148d:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101492:	83 c8 40             	or     $0x40,%eax
c0101495:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
        return 0;
c010149a:	b8 00 00 00 00       	mov    $0x0,%eax
c010149f:	e9 22 01 00 00       	jmp    c01015c6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c01014a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a8:	84 c0                	test   %al,%al
c01014aa:	79 45                	jns    c01014f1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014ac:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01014b1:	83 e0 40             	and    $0x40,%eax
c01014b4:	85 c0                	test   %eax,%eax
c01014b6:	75 08                	jne    c01014c0 <kbd_proc_data+0x7c>
c01014b8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bc:	24 7f                	and    $0x7f,%al
c01014be:	eb 04                	jmp    c01014c4 <kbd_proc_data+0x80>
c01014c0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014cb:	0f b6 80 40 a0 11 c0 	movzbl -0x3fee5fc0(%eax),%eax
c01014d2:	0c 40                	or     $0x40,%al
c01014d4:	0f b6 c0             	movzbl %al,%eax
c01014d7:	f7 d0                	not    %eax
c01014d9:	89 c2                	mov    %eax,%edx
c01014db:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01014e0:	21 d0                	and    %edx,%eax
c01014e2:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
        return 0;
c01014e7:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ec:	e9 d5 00 00 00       	jmp    c01015c6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c01014f1:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01014f6:	83 e0 40             	and    $0x40,%eax
c01014f9:	85 c0                	test   %eax,%eax
c01014fb:	74 11                	je     c010150e <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014fd:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101501:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101506:	83 e0 bf             	and    $0xffffffbf,%eax
c0101509:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
    }

    shift |= shiftcode[data];
c010150e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101512:	0f b6 80 40 a0 11 c0 	movzbl -0x3fee5fc0(%eax),%eax
c0101519:	0f b6 d0             	movzbl %al,%edx
c010151c:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101521:	09 d0                	or     %edx,%eax
c0101523:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
    shift ^= togglecode[data];
c0101528:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010152c:	0f b6 80 40 a1 11 c0 	movzbl -0x3fee5ec0(%eax),%eax
c0101533:	0f b6 d0             	movzbl %al,%edx
c0101536:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c010153b:	31 d0                	xor    %edx,%eax
c010153d:	a3 68 d6 11 c0       	mov    %eax,0xc011d668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101542:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101547:	83 e0 03             	and    $0x3,%eax
c010154a:	8b 14 85 40 a5 11 c0 	mov    -0x3fee5ac0(,%eax,4),%edx
c0101551:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101555:	01 d0                	add    %edx,%eax
c0101557:	0f b6 00             	movzbl (%eax),%eax
c010155a:	0f b6 c0             	movzbl %al,%eax
c010155d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101560:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101565:	83 e0 08             	and    $0x8,%eax
c0101568:	85 c0                	test   %eax,%eax
c010156a:	74 22                	je     c010158e <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c010156c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101570:	7e 0c                	jle    c010157e <kbd_proc_data+0x13a>
c0101572:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101576:	7f 06                	jg     c010157e <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101578:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010157c:	eb 10                	jmp    c010158e <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c010157e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101582:	7e 0a                	jle    c010158e <kbd_proc_data+0x14a>
c0101584:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101588:	7f 04                	jg     c010158e <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010158a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010158e:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101593:	f7 d0                	not    %eax
c0101595:	83 e0 06             	and    $0x6,%eax
c0101598:	85 c0                	test   %eax,%eax
c010159a:	75 27                	jne    c01015c3 <kbd_proc_data+0x17f>
c010159c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015a3:	75 1e                	jne    c01015c3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c01015a5:	c7 04 24 4d 6f 10 c0 	movl   $0xc0106f4d,(%esp)
c01015ac:	e8 f1 ec ff ff       	call   c01002a2 <cprintf>
c01015b1:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015b7:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015bb:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015bf:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01015c2:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015c6:	c9                   	leave  
c01015c7:	c3                   	ret    

c01015c8 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015c8:	55                   	push   %ebp
c01015c9:	89 e5                	mov    %esp,%ebp
c01015cb:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015ce:	c7 04 24 44 14 10 c0 	movl   $0xc0101444,(%esp)
c01015d5:	e8 a9 fd ff ff       	call   c0101383 <cons_intr>
}
c01015da:	90                   	nop
c01015db:	c9                   	leave  
c01015dc:	c3                   	ret    

c01015dd <kbd_init>:

static void
kbd_init(void) {
c01015dd:	55                   	push   %ebp
c01015de:	89 e5                	mov    %esp,%ebp
c01015e0:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015e3:	e8 e0 ff ff ff       	call   c01015c8 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015ef:	e8 35 01 00 00       	call   c0101729 <pic_enable>
}
c01015f4:	90                   	nop
c01015f5:	c9                   	leave  
c01015f6:	c3                   	ret    

c01015f7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015f7:	55                   	push   %ebp
c01015f8:	89 e5                	mov    %esp,%ebp
c01015fa:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015fd:	e8 83 f8 ff ff       	call   c0100e85 <cga_init>
    serial_init();
c0101602:	e8 62 f9 ff ff       	call   c0100f69 <serial_init>
    kbd_init();
c0101607:	e8 d1 ff ff ff       	call   c01015dd <kbd_init>
    if (!serial_exists) {
c010160c:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c0101611:	85 c0                	test   %eax,%eax
c0101613:	75 0c                	jne    c0101621 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101615:	c7 04 24 59 6f 10 c0 	movl   $0xc0106f59,(%esp)
c010161c:	e8 81 ec ff ff       	call   c01002a2 <cprintf>
    }
}
c0101621:	90                   	nop
c0101622:	c9                   	leave  
c0101623:	c3                   	ret    

c0101624 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101624:	55                   	push   %ebp
c0101625:	89 e5                	mov    %esp,%ebp
c0101627:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010162a:	e8 cf f7 ff ff       	call   c0100dfe <__intr_save>
c010162f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101632:	8b 45 08             	mov    0x8(%ebp),%eax
c0101635:	89 04 24             	mov    %eax,(%esp)
c0101638:	e8 89 fa ff ff       	call   c01010c6 <lpt_putc>
        cga_putc(c);
c010163d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101640:	89 04 24             	mov    %eax,(%esp)
c0101643:	e8 be fa ff ff       	call   c0101106 <cga_putc>
        serial_putc(c);
c0101648:	8b 45 08             	mov    0x8(%ebp),%eax
c010164b:	89 04 24             	mov    %eax,(%esp)
c010164e:	e8 f0 fc ff ff       	call   c0101343 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101653:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101656:	89 04 24             	mov    %eax,(%esp)
c0101659:	e8 ca f7 ff ff       	call   c0100e28 <__intr_restore>
}
c010165e:	90                   	nop
c010165f:	c9                   	leave  
c0101660:	c3                   	ret    

c0101661 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101661:	55                   	push   %ebp
c0101662:	89 e5                	mov    %esp,%ebp
c0101664:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101667:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010166e:	e8 8b f7 ff ff       	call   c0100dfe <__intr_save>
c0101673:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101676:	e8 ab fd ff ff       	call   c0101426 <serial_intr>
        kbd_intr();
c010167b:	e8 48 ff ff ff       	call   c01015c8 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101680:	8b 15 60 d6 11 c0    	mov    0xc011d660,%edx
c0101686:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c010168b:	39 c2                	cmp    %eax,%edx
c010168d:	74 31                	je     c01016c0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010168f:	a1 60 d6 11 c0       	mov    0xc011d660,%eax
c0101694:	8d 50 01             	lea    0x1(%eax),%edx
c0101697:	89 15 60 d6 11 c0    	mov    %edx,0xc011d660
c010169d:	0f b6 80 60 d4 11 c0 	movzbl -0x3fee2ba0(%eax),%eax
c01016a4:	0f b6 c0             	movzbl %al,%eax
c01016a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016aa:	a1 60 d6 11 c0       	mov    0xc011d660,%eax
c01016af:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016b4:	75 0a                	jne    c01016c0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016b6:	c7 05 60 d6 11 c0 00 	movl   $0x0,0xc011d660
c01016bd:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016c3:	89 04 24             	mov    %eax,(%esp)
c01016c6:	e8 5d f7 ff ff       	call   c0100e28 <__intr_restore>
    return c;
c01016cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016ce:	c9                   	leave  
c01016cf:	c3                   	ret    

c01016d0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016d0:	55                   	push   %ebp
c01016d1:	89 e5                	mov    %esp,%ebp
c01016d3:	83 ec 14             	sub    $0x14,%esp
c01016d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016e0:	66 a3 50 a5 11 c0    	mov    %ax,0xc011a550
    if (did_init) {
c01016e6:	a1 6c d6 11 c0       	mov    0xc011d66c,%eax
c01016eb:	85 c0                	test   %eax,%eax
c01016ed:	74 37                	je     c0101726 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016f2:	0f b6 c0             	movzbl %al,%eax
c01016f5:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01016fb:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016fe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101702:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101706:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101707:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010170b:	c1 e8 08             	shr    $0x8,%eax
c010170e:	0f b7 c0             	movzwl %ax,%eax
c0101711:	0f b6 c0             	movzbl %al,%eax
c0101714:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010171a:	88 45 fd             	mov    %al,-0x3(%ebp)
c010171d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101721:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101725:	ee                   	out    %al,(%dx)
    }
}
c0101726:	90                   	nop
c0101727:	c9                   	leave  
c0101728:	c3                   	ret    

c0101729 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101729:	55                   	push   %ebp
c010172a:	89 e5                	mov    %esp,%ebp
c010172c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010172f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101732:	ba 01 00 00 00       	mov    $0x1,%edx
c0101737:	88 c1                	mov    %al,%cl
c0101739:	d3 e2                	shl    %cl,%edx
c010173b:	89 d0                	mov    %edx,%eax
c010173d:	98                   	cwtl   
c010173e:	f7 d0                	not    %eax
c0101740:	0f bf d0             	movswl %ax,%edx
c0101743:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c010174a:	98                   	cwtl   
c010174b:	21 d0                	and    %edx,%eax
c010174d:	98                   	cwtl   
c010174e:	0f b7 c0             	movzwl %ax,%eax
c0101751:	89 04 24             	mov    %eax,(%esp)
c0101754:	e8 77 ff ff ff       	call   c01016d0 <pic_setmask>
}
c0101759:	90                   	nop
c010175a:	c9                   	leave  
c010175b:	c3                   	ret    

c010175c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010175c:	55                   	push   %ebp
c010175d:	89 e5                	mov    %esp,%ebp
c010175f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101762:	c7 05 6c d6 11 c0 01 	movl   $0x1,0xc011d66c
c0101769:	00 00 00 
c010176c:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101772:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0101776:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010177a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010177e:	ee                   	out    %al,(%dx)
c010177f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101785:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c0101789:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010178d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101791:	ee                   	out    %al,(%dx)
c0101792:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101798:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c010179c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017a0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017a4:	ee                   	out    %al,(%dx)
c01017a5:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01017ab:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c01017af:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01017b3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01017b7:	ee                   	out    %al,(%dx)
c01017b8:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01017be:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c01017c2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017c6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01017ca:	ee                   	out    %al,(%dx)
c01017cb:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01017d1:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c01017d5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017d9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017dd:	ee                   	out    %al,(%dx)
c01017de:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01017e4:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c01017e8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017ec:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017f0:	ee                   	out    %al,(%dx)
c01017f1:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01017f7:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c01017fb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017ff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101803:	ee                   	out    %al,(%dx)
c0101804:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c010180a:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c010180e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101812:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101816:	ee                   	out    %al,(%dx)
c0101817:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010181d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c0101821:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101825:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101829:	ee                   	out    %al,(%dx)
c010182a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0101830:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0101834:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101838:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010183c:	ee                   	out    %al,(%dx)
c010183d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101843:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c0101847:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010184b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010184f:	ee                   	out    %al,(%dx)
c0101850:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101856:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c010185a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010185e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101862:	ee                   	out    %al,(%dx)
c0101863:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0101869:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c010186d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101871:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101875:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101876:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c010187d:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101882:	74 0f                	je     c0101893 <pic_init+0x137>
        pic_setmask(irq_mask);
c0101884:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c010188b:	89 04 24             	mov    %eax,(%esp)
c010188e:	e8 3d fe ff ff       	call   c01016d0 <pic_setmask>
    }
}
c0101893:	90                   	nop
c0101894:	c9                   	leave  
c0101895:	c3                   	ret    

c0101896 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101896:	55                   	push   %ebp
c0101897:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101899:	fb                   	sti    
    sti();
}
c010189a:	90                   	nop
c010189b:	5d                   	pop    %ebp
c010189c:	c3                   	ret    

c010189d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010189d:	55                   	push   %ebp
c010189e:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01018a0:	fa                   	cli    
    cli();
}
c01018a1:	90                   	nop
c01018a2:	5d                   	pop    %ebp
c01018a3:	c3                   	ret    

c01018a4 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01018a4:	55                   	push   %ebp
c01018a5:	89 e5                	mov    %esp,%ebp
c01018a7:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01018aa:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018b1:	00 
c01018b2:	c7 04 24 80 6f 10 c0 	movl   $0xc0106f80,(%esp)
c01018b9:	e8 e4 e9 ff ff       	call   c01002a2 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018be:	90                   	nop
c01018bf:	c9                   	leave  
c01018c0:	c3                   	ret    

c01018c1 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018c1:	55                   	push   %ebp
c01018c2:	89 e5                	mov    %esp,%ebp
c01018c4:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) { 
c01018c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018ce:	e9 c4 00 00 00       	jmp    c0101997 <idt_init+0xd6>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
c01018d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d6:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c01018dd:	0f b7 d0             	movzwl %ax,%edx
c01018e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e3:	66 89 14 c5 80 d6 11 	mov    %dx,-0x3fee2980(,%eax,8)
c01018ea:	c0 
c01018eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ee:	66 c7 04 c5 82 d6 11 	movw   $0x8,-0x3fee297e(,%eax,8)
c01018f5:	c0 08 00 
c01018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fb:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c0101902:	c0 
c0101903:	80 e2 e0             	and    $0xe0,%dl
c0101906:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c010190d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101910:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c0101917:	c0 
c0101918:	80 e2 1f             	and    $0x1f,%dl
c010191b:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c0101922:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101925:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c010192c:	c0 
c010192d:	80 e2 f0             	and    $0xf0,%dl
c0101930:	80 ca 0e             	or     $0xe,%dl
c0101933:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c010193a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193d:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101944:	c0 
c0101945:	80 e2 ef             	and    $0xef,%dl
c0101948:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c010194f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101952:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101959:	c0 
c010195a:	80 e2 9f             	and    $0x9f,%dl
c010195d:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101964:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101967:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c010196e:	c0 
c010196f:	80 ca 80             	or     $0x80,%dl
c0101972:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c0101983:	c1 e8 10             	shr    $0x10,%eax
c0101986:	0f b7 d0             	movzwl %ax,%edx
c0101989:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010198c:	66 89 14 c5 86 d6 11 	mov    %dx,-0x3fee297a(,%eax,8)
c0101993:	c0 
    for (int i = 0; i < 256; i++) { 
c0101994:	ff 45 fc             	incl   -0x4(%ebp)
c0101997:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c010199e:	0f 8e 2f ff ff ff    	jle    c01018d3 <idt_init+0x12>
    }
    //referenced: #define SETGATE(gate, istrap, sel, off, dpl)
    //so the 'istrap' below is set as 1;
    //referenced:  KERNEL_CS    ((GD_KTEXT) | DPL_KERNEL)
    SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], DPL_USER);
c01019a4:	a1 c4 a7 11 c0       	mov    0xc011a7c4,%eax
c01019a9:	0f b7 c0             	movzwl %ax,%eax
c01019ac:	66 a3 48 da 11 c0    	mov    %ax,0xc011da48
c01019b2:	66 c7 05 4a da 11 c0 	movw   $0x8,0xc011da4a
c01019b9:	08 00 
c01019bb:	0f b6 05 4c da 11 c0 	movzbl 0xc011da4c,%eax
c01019c2:	24 e0                	and    $0xe0,%al
c01019c4:	a2 4c da 11 c0       	mov    %al,0xc011da4c
c01019c9:	0f b6 05 4c da 11 c0 	movzbl 0xc011da4c,%eax
c01019d0:	24 1f                	and    $0x1f,%al
c01019d2:	a2 4c da 11 c0       	mov    %al,0xc011da4c
c01019d7:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c01019de:	0c 0f                	or     $0xf,%al
c01019e0:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c01019e5:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c01019ec:	24 ef                	and    $0xef,%al
c01019ee:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c01019f3:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c01019fa:	0c 60                	or     $0x60,%al
c01019fc:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c0101a01:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c0101a08:	0c 80                	or     $0x80,%al
c0101a0a:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c0101a0f:	a1 c4 a7 11 c0       	mov    0xc011a7c4,%eax
c0101a14:	c1 e8 10             	shr    $0x10,%eax
c0101a17:	0f b7 c0             	movzwl %ax,%eax
c0101a1a:	66 a3 4e da 11 c0    	mov    %ax,0xc011da4e
    SETGATE(idt[T_SWITCH_TOU], 1, KERNEL_CS, __vectors[T_SWITCH_TOU], DPL_KERNEL);
c0101a20:	a1 c0 a7 11 c0       	mov    0xc011a7c0,%eax
c0101a25:	0f b7 c0             	movzwl %ax,%eax
c0101a28:	66 a3 40 da 11 c0    	mov    %ax,0xc011da40
c0101a2e:	66 c7 05 42 da 11 c0 	movw   $0x8,0xc011da42
c0101a35:	08 00 
c0101a37:	0f b6 05 44 da 11 c0 	movzbl 0xc011da44,%eax
c0101a3e:	24 e0                	and    $0xe0,%al
c0101a40:	a2 44 da 11 c0       	mov    %al,0xc011da44
c0101a45:	0f b6 05 44 da 11 c0 	movzbl 0xc011da44,%eax
c0101a4c:	24 1f                	and    $0x1f,%al
c0101a4e:	a2 44 da 11 c0       	mov    %al,0xc011da44
c0101a53:	0f b6 05 45 da 11 c0 	movzbl 0xc011da45,%eax
c0101a5a:	0c 0f                	or     $0xf,%al
c0101a5c:	a2 45 da 11 c0       	mov    %al,0xc011da45
c0101a61:	0f b6 05 45 da 11 c0 	movzbl 0xc011da45,%eax
c0101a68:	24 ef                	and    $0xef,%al
c0101a6a:	a2 45 da 11 c0       	mov    %al,0xc011da45
c0101a6f:	0f b6 05 45 da 11 c0 	movzbl 0xc011da45,%eax
c0101a76:	24 9f                	and    $0x9f,%al
c0101a78:	a2 45 da 11 c0       	mov    %al,0xc011da45
c0101a7d:	0f b6 05 45 da 11 c0 	movzbl 0xc011da45,%eax
c0101a84:	0c 80                	or     $0x80,%al
c0101a86:	a2 45 da 11 c0       	mov    %al,0xc011da45
c0101a8b:	a1 c0 a7 11 c0       	mov    0xc011a7c0,%eax
c0101a90:	c1 e8 10             	shr    $0x10,%eax
c0101a93:	0f b7 c0             	movzwl %ax,%eax
c0101a96:	66 a3 46 da 11 c0    	mov    %ax,0xc011da46
c0101a9c:	c7 45 f8 60 a5 11 c0 	movl   $0xc011a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101aa3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101aa6:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c0101aa9:	90                   	nop
c0101aaa:	c9                   	leave  
c0101aab:	c3                   	ret    

c0101aac <trapname>:

static const char *
trapname(int trapno) {
c0101aac:	55                   	push   %ebp
c0101aad:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab2:	83 f8 13             	cmp    $0x13,%eax
c0101ab5:	77 0c                	ja     c0101ac3 <trapname+0x17>
        return excnames[trapno];
c0101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aba:	8b 04 85 20 73 10 c0 	mov    -0x3fef8ce0(,%eax,4),%eax
c0101ac1:	eb 18                	jmp    c0101adb <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101ac3:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101ac7:	7e 0d                	jle    c0101ad6 <trapname+0x2a>
c0101ac9:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101acd:	7f 07                	jg     c0101ad6 <trapname+0x2a>
        return "Hardware Interrupt";
c0101acf:	b8 8a 6f 10 c0       	mov    $0xc0106f8a,%eax
c0101ad4:	eb 05                	jmp    c0101adb <trapname+0x2f>
    }
    return "(unknown trap)";
c0101ad6:	b8 9d 6f 10 c0       	mov    $0xc0106f9d,%eax
}
c0101adb:	5d                   	pop    %ebp
c0101adc:	c3                   	ret    

c0101add <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101add:	55                   	push   %ebp
c0101ade:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101ae0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ae7:	83 f8 08             	cmp    $0x8,%eax
c0101aea:	0f 94 c0             	sete   %al
c0101aed:	0f b6 c0             	movzbl %al,%eax
}
c0101af0:	5d                   	pop    %ebp
c0101af1:	c3                   	ret    

c0101af2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101af2:	55                   	push   %ebp
c0101af3:	89 e5                	mov    %esp,%ebp
c0101af5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101af8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101afb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aff:	c7 04 24 de 6f 10 c0 	movl   $0xc0106fde,(%esp)
c0101b06:	e8 97 e7 ff ff       	call   c01002a2 <cprintf>
    print_regs(&tf->tf_regs);
c0101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b0e:	89 04 24             	mov    %eax,(%esp)
c0101b11:	e8 8f 01 00 00       	call   c0101ca5 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101b16:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b19:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b21:	c7 04 24 ef 6f 10 c0 	movl   $0xc0106fef,(%esp)
c0101b28:	e8 75 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b30:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101b34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b38:	c7 04 24 02 70 10 c0 	movl   $0xc0107002,(%esp)
c0101b3f:	e8 5e e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101b44:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b47:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4f:	c7 04 24 15 70 10 c0 	movl   $0xc0107015,(%esp)
c0101b56:	e8 47 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b66:	c7 04 24 28 70 10 c0 	movl   $0xc0107028,(%esp)
c0101b6d:	e8 30 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b75:	8b 40 30             	mov    0x30(%eax),%eax
c0101b78:	89 04 24             	mov    %eax,(%esp)
c0101b7b:	e8 2c ff ff ff       	call   c0101aac <trapname>
c0101b80:	89 c2                	mov    %eax,%edx
c0101b82:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b85:	8b 40 30             	mov    0x30(%eax),%eax
c0101b88:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b90:	c7 04 24 3b 70 10 c0 	movl   $0xc010703b,(%esp)
c0101b97:	e8 06 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9f:	8b 40 34             	mov    0x34(%eax),%eax
c0101ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba6:	c7 04 24 4d 70 10 c0 	movl   $0xc010704d,(%esp)
c0101bad:	e8 f0 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb5:	8b 40 38             	mov    0x38(%eax),%eax
c0101bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bbc:	c7 04 24 5c 70 10 c0 	movl   $0xc010705c,(%esp)
c0101bc3:	e8 da e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bcb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd3:	c7 04 24 6b 70 10 c0 	movl   $0xc010706b,(%esp)
c0101bda:	e8 c3 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be2:	8b 40 40             	mov    0x40(%eax),%eax
c0101be5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be9:	c7 04 24 7e 70 10 c0 	movl   $0xc010707e,(%esp)
c0101bf0:	e8 ad e6 ff ff       	call   c01002a2 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101bfc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101c03:	eb 3d                	jmp    c0101c42 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101c05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c08:	8b 50 40             	mov    0x40(%eax),%edx
c0101c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c0e:	21 d0                	and    %edx,%eax
c0101c10:	85 c0                	test   %eax,%eax
c0101c12:	74 28                	je     c0101c3c <print_trapframe+0x14a>
c0101c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c17:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101c1e:	85 c0                	test   %eax,%eax
c0101c20:	74 1a                	je     c0101c3c <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c25:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c30:	c7 04 24 8d 70 10 c0 	movl   $0xc010708d,(%esp)
c0101c37:	e8 66 e6 ff ff       	call   c01002a2 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c3c:	ff 45 f4             	incl   -0xc(%ebp)
c0101c3f:	d1 65 f0             	shll   -0x10(%ebp)
c0101c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c45:	83 f8 17             	cmp    $0x17,%eax
c0101c48:	76 bb                	jbe    c0101c05 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c4d:	8b 40 40             	mov    0x40(%eax),%eax
c0101c50:	c1 e8 0c             	shr    $0xc,%eax
c0101c53:	83 e0 03             	and    $0x3,%eax
c0101c56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5a:	c7 04 24 91 70 10 c0 	movl   $0xc0107091,(%esp)
c0101c61:	e8 3c e6 ff ff       	call   c01002a2 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c66:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c69:	89 04 24             	mov    %eax,(%esp)
c0101c6c:	e8 6c fe ff ff       	call   c0101add <trap_in_kernel>
c0101c71:	85 c0                	test   %eax,%eax
c0101c73:	75 2d                	jne    c0101ca2 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c78:	8b 40 44             	mov    0x44(%eax),%eax
c0101c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7f:	c7 04 24 9a 70 10 c0 	movl   $0xc010709a,(%esp)
c0101c86:	e8 17 e6 ff ff       	call   c01002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c96:	c7 04 24 a9 70 10 c0 	movl   $0xc01070a9,(%esp)
c0101c9d:	e8 00 e6 ff ff       	call   c01002a2 <cprintf>
    }
}
c0101ca2:	90                   	nop
c0101ca3:	c9                   	leave  
c0101ca4:	c3                   	ret    

c0101ca5 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101ca5:	55                   	push   %ebp
c0101ca6:	89 e5                	mov    %esp,%ebp
c0101ca8:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101cab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cae:	8b 00                	mov    (%eax),%eax
c0101cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb4:	c7 04 24 bc 70 10 c0 	movl   $0xc01070bc,(%esp)
c0101cbb:	e8 e2 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101cc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc3:	8b 40 04             	mov    0x4(%eax),%eax
c0101cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cca:	c7 04 24 cb 70 10 c0 	movl   $0xc01070cb,(%esp)
c0101cd1:	e8 cc e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd9:	8b 40 08             	mov    0x8(%eax),%eax
c0101cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce0:	c7 04 24 da 70 10 c0 	movl   $0xc01070da,(%esp)
c0101ce7:	e8 b6 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101cec:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cef:	8b 40 0c             	mov    0xc(%eax),%eax
c0101cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf6:	c7 04 24 e9 70 10 c0 	movl   $0xc01070e9,(%esp)
c0101cfd:	e8 a0 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101d02:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d05:	8b 40 10             	mov    0x10(%eax),%eax
c0101d08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0c:	c7 04 24 f8 70 10 c0 	movl   $0xc01070f8,(%esp)
c0101d13:	e8 8a e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101d18:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d1b:	8b 40 14             	mov    0x14(%eax),%eax
c0101d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d22:	c7 04 24 07 71 10 c0 	movl   $0xc0107107,(%esp)
c0101d29:	e8 74 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101d2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d31:	8b 40 18             	mov    0x18(%eax),%eax
c0101d34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d38:	c7 04 24 16 71 10 c0 	movl   $0xc0107116,(%esp)
c0101d3f:	e8 5e e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101d44:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d47:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d4e:	c7 04 24 25 71 10 c0 	movl   $0xc0107125,(%esp)
c0101d55:	e8 48 e5 ff ff       	call   c01002a2 <cprintf>
}
c0101d5a:	90                   	nop
c0101d5b:	c9                   	leave  
c0101d5c:	c3                   	ret    

c0101d5d <trap_dispatch>:
}
*/

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d5d:	55                   	push   %ebp
c0101d5e:	89 e5                	mov    %esp,%ebp
c0101d60:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d66:	8b 40 30             	mov    0x30(%eax),%eax
c0101d69:	83 f8 2f             	cmp    $0x2f,%eax
c0101d6c:	77 21                	ja     c0101d8f <trap_dispatch+0x32>
c0101d6e:	83 f8 2e             	cmp    $0x2e,%eax
c0101d71:	0f 83 77 02 00 00    	jae    c0101fee <trap_dispatch+0x291>
c0101d77:	83 f8 21             	cmp    $0x21,%eax
c0101d7a:	0f 84 95 00 00 00    	je     c0101e15 <trap_dispatch+0xb8>
c0101d80:	83 f8 24             	cmp    $0x24,%eax
c0101d83:	74 67                	je     c0101dec <trap_dispatch+0x8f>
c0101d85:	83 f8 20             	cmp    $0x20,%eax
c0101d88:	74 1c                	je     c0101da6 <trap_dispatch+0x49>
c0101d8a:	e9 2a 02 00 00       	jmp    c0101fb9 <trap_dispatch+0x25c>
c0101d8f:	83 f8 78             	cmp    $0x78,%eax
c0101d92:	0f 84 8d 01 00 00    	je     c0101f25 <trap_dispatch+0x1c8>
c0101d98:	83 f8 79             	cmp    $0x79,%eax
c0101d9b:	0f 84 d7 01 00 00    	je     c0101f78 <trap_dispatch+0x21b>
c0101da1:	e9 13 02 00 00       	jmp    c0101fb9 <trap_dispatch+0x25c>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks += 1;
c0101da6:	a1 0c df 11 c0       	mov    0xc011df0c,%eax
c0101dab:	40                   	inc    %eax
c0101dac:	a3 0c df 11 c0       	mov    %eax,0xc011df0c
        if (!(ticks % TICK_NUM)) {
c0101db1:	8b 0d 0c df 11 c0    	mov    0xc011df0c,%ecx
c0101db7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101dbc:	89 c8                	mov    %ecx,%eax
c0101dbe:	f7 e2                	mul    %edx
c0101dc0:	c1 ea 05             	shr    $0x5,%edx
c0101dc3:	89 d0                	mov    %edx,%eax
c0101dc5:	c1 e0 02             	shl    $0x2,%eax
c0101dc8:	01 d0                	add    %edx,%eax
c0101dca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101dd1:	01 d0                	add    %edx,%eax
c0101dd3:	c1 e0 02             	shl    $0x2,%eax
c0101dd6:	29 c1                	sub    %eax,%ecx
c0101dd8:	89 ca                	mov    %ecx,%edx
c0101dda:	85 d2                	test   %edx,%edx
c0101ddc:	0f 85 0f 02 00 00    	jne    c0101ff1 <trap_dispatch+0x294>
            print_ticks();
c0101de2:	e8 bd fa ff ff       	call   c01018a4 <print_ticks>
        }
        break;
c0101de7:	e9 05 02 00 00       	jmp    c0101ff1 <trap_dispatch+0x294>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101dec:	e8 70 f8 ff ff       	call   c0101661 <cons_getc>
c0101df1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101df4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101df8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101dfc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e04:	c7 04 24 34 71 10 c0 	movl   $0xc0107134,(%esp)
c0101e0b:	e8 92 e4 ff ff       	call   c01002a2 <cprintf>
        break;
c0101e10:	e9 e3 01 00 00       	jmp    c0101ff8 <trap_dispatch+0x29b>
    // LAB1 : Challenge 2
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101e15:	e8 47 f8 ff ff       	call   c0101661 <cons_getc>
c0101e1a:	88 45 f7             	mov    %al,-0x9(%ebp)
        if (c == '3' && (tf->tf_cs & 3) != 3) {
c0101e1d:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
c0101e21:	75 6f                	jne    c0101e92 <trap_dispatch+0x135>
c0101e23:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e26:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e2a:	83 e0 03             	and    $0x3,%eax
c0101e2d:	83 f8 03             	cmp    $0x3,%eax
c0101e30:	74 60                	je     c0101e92 <trap_dispatch+0x135>
            cprintf("[system] change to user [%03d] %c\n", c, c);
c0101e32:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e36:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e3a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e42:	c7 04 24 48 71 10 c0 	movl   $0xc0107148,(%esp)
c0101e49:	e8 54 e4 ff ff       	call   c01002a2 <cprintf>
            tf->tf_cs = USER_CS;
c0101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e51:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = USER_DS;
c0101e57:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e5a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
c0101e60:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e63:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
c0101e69:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e6c:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
            tf->tf_eflags |= 0x3000;
c0101e72:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e75:	8b 40 40             	mov    0x40(%eax),%eax
c0101e78:	0d 00 30 00 00       	or     $0x3000,%eax
c0101e7d:	89 c2                	mov    %eax,%edx
c0101e7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e82:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
c0101e85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e88:	89 04 24             	mov    %eax,(%esp)
c0101e8b:	e8 62 fc ff ff       	call   c0101af2 <print_trapframe>
c0101e90:	eb 72                	jmp    c0101f04 <trap_dispatch+0x1a7>
        }
        else if (c == '0' && (tf->tf_cs & 3) != 0) {
c0101e92:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
c0101e96:	75 6c                	jne    c0101f04 <trap_dispatch+0x1a7>
c0101e98:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e9b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e9f:	83 e0 03             	and    $0x3,%eax
c0101ea2:	85 c0                	test   %eax,%eax
c0101ea4:	74 5e                	je     c0101f04 <trap_dispatch+0x1a7>
            cprintf("[system] change to kernel [%03d] %c\n", c, c);
c0101ea6:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101eaa:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101eae:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101eb6:	c7 04 24 6c 71 10 c0 	movl   $0xc010716c,(%esp)
c0101ebd:	e8 e0 e3 ff ff       	call   c01002a2 <cprintf>
            tf->tf_cs = KERNEL_CS;
c0101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec5:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = KERNEL_DS;
c0101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ece:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
c0101ed4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed7:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
            tf->tf_ss = KERNEL_DS;
c0101edd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee0:	66 c7 40 48 10 00    	movw   $0x10,0x48(%eax)
            tf->tf_eflags &= 0x0fff;
c0101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee9:	8b 40 40             	mov    0x40(%eax),%eax
c0101eec:	25 ff 0f 00 00       	and    $0xfff,%eax
c0101ef1:	89 c2                	mov    %eax,%edx
c0101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef6:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
c0101ef9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101efc:	89 04 24             	mov    %eax,(%esp)
c0101eff:	e8 ee fb ff ff       	call   c0101af2 <print_trapframe>
        }
        cprintf("kbd [%03d] %c\n", c, c);
c0101f04:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101f08:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101f0c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f14:	c7 04 24 91 71 10 c0 	movl   $0xc0107191,(%esp)
c0101f1b:	e8 82 e3 ff ff       	call   c01002a2 <cprintf>
        break;
c0101f20:	e9 d3 00 00 00       	jmp    c0101ff8 <trap_dispatch+0x29b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) 
c0101f25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f28:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f2c:	83 f8 1b             	cmp    $0x1b,%eax
c0101f2f:	0f 84 bf 00 00 00    	je     c0101ff4 <trap_dispatch+0x297>
        {
            tf->tf_cs = USER_CS;
c0101f35:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f38:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c0101f3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f41:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c0101f47:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f4a:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c0101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f51:	66 89 50 28          	mov    %dx,0x28(%eax)
c0101f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f58:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f5f:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags |= FL_IOPL_MASK;
c0101f63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f66:	8b 40 40             	mov    0x40(%eax),%eax
c0101f69:	0d 00 30 00 00       	or     $0x3000,%eax
c0101f6e:	89 c2                	mov    %eax,%edx
c0101f70:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f73:	89 50 40             	mov    %edx,0x40(%eax)
            // then iret will jump to the right stack

            //tf->tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
            //*((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
        }
        break;
c0101f76:	eb 7c                	jmp    c0101ff4 <trap_dispatch+0x297>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) 
c0101f78:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f7b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f7f:	83 f8 08             	cmp    $0x8,%eax
c0101f82:	74 73                	je     c0101ff7 <trap_dispatch+0x29a>
        {
            tf->tf_cs = KERNEL_CS;
c0101f84:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f87:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f90:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101f96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f99:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fa0:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0101fa4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fa7:	8b 40 40             	mov    0x40(%eax),%eax
c0101faa:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0101faf:	89 c2                	mov    %eax,%edx
c0101fb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fb4:	89 50 40             	mov    %edx,0x40(%eax)
            //switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
            //memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
            //*((uint32_t *)tf - 1) = (uint32_t)switchu2k;
        }
        break;
c0101fb7:	eb 3e                	jmp    c0101ff7 <trap_dispatch+0x29a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101fb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fbc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101fc0:	83 e0 03             	and    $0x3,%eax
c0101fc3:	85 c0                	test   %eax,%eax
c0101fc5:	75 31                	jne    c0101ff8 <trap_dispatch+0x29b>
            print_trapframe(tf);
c0101fc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fca:	89 04 24             	mov    %eax,(%esp)
c0101fcd:	e8 20 fb ff ff       	call   c0101af2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101fd2:	c7 44 24 08 a0 71 10 	movl   $0xc01071a0,0x8(%esp)
c0101fd9:	c0 
c0101fda:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0101fe1:	00 
c0101fe2:	c7 04 24 bc 71 10 c0 	movl   $0xc01071bc,(%esp)
c0101fe9:	e8 0b e4 ff ff       	call   c01003f9 <__panic>
        break;
c0101fee:	90                   	nop
c0101fef:	eb 07                	jmp    c0101ff8 <trap_dispatch+0x29b>
        break;
c0101ff1:	90                   	nop
c0101ff2:	eb 04                	jmp    c0101ff8 <trap_dispatch+0x29b>
        break;
c0101ff4:	90                   	nop
c0101ff5:	eb 01                	jmp    c0101ff8 <trap_dispatch+0x29b>
        break;
c0101ff7:	90                   	nop
        }
    }
}
c0101ff8:	90                   	nop
c0101ff9:	c9                   	leave  
c0101ffa:	c3                   	ret    

c0101ffb <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101ffb:	55                   	push   %ebp
c0101ffc:	89 e5                	mov    %esp,%ebp
c0101ffe:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102001:	8b 45 08             	mov    0x8(%ebp),%eax
c0102004:	89 04 24             	mov    %eax,(%esp)
c0102007:	e8 51 fd ff ff       	call   c0101d5d <trap_dispatch>
}
c010200c:	90                   	nop
c010200d:	c9                   	leave  
c010200e:	c3                   	ret    

c010200f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010200f:	6a 00                	push   $0x0
  pushl $0
c0102011:	6a 00                	push   $0x0
  jmp __alltraps
c0102013:	e9 69 0a 00 00       	jmp    c0102a81 <__alltraps>

c0102018 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102018:	6a 00                	push   $0x0
  pushl $1
c010201a:	6a 01                	push   $0x1
  jmp __alltraps
c010201c:	e9 60 0a 00 00       	jmp    c0102a81 <__alltraps>

c0102021 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102021:	6a 00                	push   $0x0
  pushl $2
c0102023:	6a 02                	push   $0x2
  jmp __alltraps
c0102025:	e9 57 0a 00 00       	jmp    c0102a81 <__alltraps>

c010202a <vector3>:
.globl vector3
vector3:
  pushl $0
c010202a:	6a 00                	push   $0x0
  pushl $3
c010202c:	6a 03                	push   $0x3
  jmp __alltraps
c010202e:	e9 4e 0a 00 00       	jmp    c0102a81 <__alltraps>

c0102033 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102033:	6a 00                	push   $0x0
  pushl $4
c0102035:	6a 04                	push   $0x4
  jmp __alltraps
c0102037:	e9 45 0a 00 00       	jmp    c0102a81 <__alltraps>

c010203c <vector5>:
.globl vector5
vector5:
  pushl $0
c010203c:	6a 00                	push   $0x0
  pushl $5
c010203e:	6a 05                	push   $0x5
  jmp __alltraps
c0102040:	e9 3c 0a 00 00       	jmp    c0102a81 <__alltraps>

c0102045 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102045:	6a 00                	push   $0x0
  pushl $6
c0102047:	6a 06                	push   $0x6
  jmp __alltraps
c0102049:	e9 33 0a 00 00       	jmp    c0102a81 <__alltraps>

c010204e <vector7>:
.globl vector7
vector7:
  pushl $0
c010204e:	6a 00                	push   $0x0
  pushl $7
c0102050:	6a 07                	push   $0x7
  jmp __alltraps
c0102052:	e9 2a 0a 00 00       	jmp    c0102a81 <__alltraps>

c0102057 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102057:	6a 08                	push   $0x8
  jmp __alltraps
c0102059:	e9 23 0a 00 00       	jmp    c0102a81 <__alltraps>

c010205e <vector9>:
.globl vector9
vector9:
  pushl $0
c010205e:	6a 00                	push   $0x0
  pushl $9
c0102060:	6a 09                	push   $0x9
  jmp __alltraps
c0102062:	e9 1a 0a 00 00       	jmp    c0102a81 <__alltraps>

c0102067 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102067:	6a 0a                	push   $0xa
  jmp __alltraps
c0102069:	e9 13 0a 00 00       	jmp    c0102a81 <__alltraps>

c010206e <vector11>:
.globl vector11
vector11:
  pushl $11
c010206e:	6a 0b                	push   $0xb
  jmp __alltraps
c0102070:	e9 0c 0a 00 00       	jmp    c0102a81 <__alltraps>

c0102075 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102075:	6a 0c                	push   $0xc
  jmp __alltraps
c0102077:	e9 05 0a 00 00       	jmp    c0102a81 <__alltraps>

c010207c <vector13>:
.globl vector13
vector13:
  pushl $13
c010207c:	6a 0d                	push   $0xd
  jmp __alltraps
c010207e:	e9 fe 09 00 00       	jmp    c0102a81 <__alltraps>

c0102083 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102083:	6a 0e                	push   $0xe
  jmp __alltraps
c0102085:	e9 f7 09 00 00       	jmp    c0102a81 <__alltraps>

c010208a <vector15>:
.globl vector15
vector15:
  pushl $0
c010208a:	6a 00                	push   $0x0
  pushl $15
c010208c:	6a 0f                	push   $0xf
  jmp __alltraps
c010208e:	e9 ee 09 00 00       	jmp    c0102a81 <__alltraps>

c0102093 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102093:	6a 00                	push   $0x0
  pushl $16
c0102095:	6a 10                	push   $0x10
  jmp __alltraps
c0102097:	e9 e5 09 00 00       	jmp    c0102a81 <__alltraps>

c010209c <vector17>:
.globl vector17
vector17:
  pushl $17
c010209c:	6a 11                	push   $0x11
  jmp __alltraps
c010209e:	e9 de 09 00 00       	jmp    c0102a81 <__alltraps>

c01020a3 <vector18>:
.globl vector18
vector18:
  pushl $0
c01020a3:	6a 00                	push   $0x0
  pushl $18
c01020a5:	6a 12                	push   $0x12
  jmp __alltraps
c01020a7:	e9 d5 09 00 00       	jmp    c0102a81 <__alltraps>

c01020ac <vector19>:
.globl vector19
vector19:
  pushl $0
c01020ac:	6a 00                	push   $0x0
  pushl $19
c01020ae:	6a 13                	push   $0x13
  jmp __alltraps
c01020b0:	e9 cc 09 00 00       	jmp    c0102a81 <__alltraps>

c01020b5 <vector20>:
.globl vector20
vector20:
  pushl $0
c01020b5:	6a 00                	push   $0x0
  pushl $20
c01020b7:	6a 14                	push   $0x14
  jmp __alltraps
c01020b9:	e9 c3 09 00 00       	jmp    c0102a81 <__alltraps>

c01020be <vector21>:
.globl vector21
vector21:
  pushl $0
c01020be:	6a 00                	push   $0x0
  pushl $21
c01020c0:	6a 15                	push   $0x15
  jmp __alltraps
c01020c2:	e9 ba 09 00 00       	jmp    c0102a81 <__alltraps>

c01020c7 <vector22>:
.globl vector22
vector22:
  pushl $0
c01020c7:	6a 00                	push   $0x0
  pushl $22
c01020c9:	6a 16                	push   $0x16
  jmp __alltraps
c01020cb:	e9 b1 09 00 00       	jmp    c0102a81 <__alltraps>

c01020d0 <vector23>:
.globl vector23
vector23:
  pushl $0
c01020d0:	6a 00                	push   $0x0
  pushl $23
c01020d2:	6a 17                	push   $0x17
  jmp __alltraps
c01020d4:	e9 a8 09 00 00       	jmp    c0102a81 <__alltraps>

c01020d9 <vector24>:
.globl vector24
vector24:
  pushl $0
c01020d9:	6a 00                	push   $0x0
  pushl $24
c01020db:	6a 18                	push   $0x18
  jmp __alltraps
c01020dd:	e9 9f 09 00 00       	jmp    c0102a81 <__alltraps>

c01020e2 <vector25>:
.globl vector25
vector25:
  pushl $0
c01020e2:	6a 00                	push   $0x0
  pushl $25
c01020e4:	6a 19                	push   $0x19
  jmp __alltraps
c01020e6:	e9 96 09 00 00       	jmp    c0102a81 <__alltraps>

c01020eb <vector26>:
.globl vector26
vector26:
  pushl $0
c01020eb:	6a 00                	push   $0x0
  pushl $26
c01020ed:	6a 1a                	push   $0x1a
  jmp __alltraps
c01020ef:	e9 8d 09 00 00       	jmp    c0102a81 <__alltraps>

c01020f4 <vector27>:
.globl vector27
vector27:
  pushl $0
c01020f4:	6a 00                	push   $0x0
  pushl $27
c01020f6:	6a 1b                	push   $0x1b
  jmp __alltraps
c01020f8:	e9 84 09 00 00       	jmp    c0102a81 <__alltraps>

c01020fd <vector28>:
.globl vector28
vector28:
  pushl $0
c01020fd:	6a 00                	push   $0x0
  pushl $28
c01020ff:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102101:	e9 7b 09 00 00       	jmp    c0102a81 <__alltraps>

c0102106 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102106:	6a 00                	push   $0x0
  pushl $29
c0102108:	6a 1d                	push   $0x1d
  jmp __alltraps
c010210a:	e9 72 09 00 00       	jmp    c0102a81 <__alltraps>

c010210f <vector30>:
.globl vector30
vector30:
  pushl $0
c010210f:	6a 00                	push   $0x0
  pushl $30
c0102111:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102113:	e9 69 09 00 00       	jmp    c0102a81 <__alltraps>

c0102118 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102118:	6a 00                	push   $0x0
  pushl $31
c010211a:	6a 1f                	push   $0x1f
  jmp __alltraps
c010211c:	e9 60 09 00 00       	jmp    c0102a81 <__alltraps>

c0102121 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102121:	6a 00                	push   $0x0
  pushl $32
c0102123:	6a 20                	push   $0x20
  jmp __alltraps
c0102125:	e9 57 09 00 00       	jmp    c0102a81 <__alltraps>

c010212a <vector33>:
.globl vector33
vector33:
  pushl $0
c010212a:	6a 00                	push   $0x0
  pushl $33
c010212c:	6a 21                	push   $0x21
  jmp __alltraps
c010212e:	e9 4e 09 00 00       	jmp    c0102a81 <__alltraps>

c0102133 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102133:	6a 00                	push   $0x0
  pushl $34
c0102135:	6a 22                	push   $0x22
  jmp __alltraps
c0102137:	e9 45 09 00 00       	jmp    c0102a81 <__alltraps>

c010213c <vector35>:
.globl vector35
vector35:
  pushl $0
c010213c:	6a 00                	push   $0x0
  pushl $35
c010213e:	6a 23                	push   $0x23
  jmp __alltraps
c0102140:	e9 3c 09 00 00       	jmp    c0102a81 <__alltraps>

c0102145 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102145:	6a 00                	push   $0x0
  pushl $36
c0102147:	6a 24                	push   $0x24
  jmp __alltraps
c0102149:	e9 33 09 00 00       	jmp    c0102a81 <__alltraps>

c010214e <vector37>:
.globl vector37
vector37:
  pushl $0
c010214e:	6a 00                	push   $0x0
  pushl $37
c0102150:	6a 25                	push   $0x25
  jmp __alltraps
c0102152:	e9 2a 09 00 00       	jmp    c0102a81 <__alltraps>

c0102157 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102157:	6a 00                	push   $0x0
  pushl $38
c0102159:	6a 26                	push   $0x26
  jmp __alltraps
c010215b:	e9 21 09 00 00       	jmp    c0102a81 <__alltraps>

c0102160 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102160:	6a 00                	push   $0x0
  pushl $39
c0102162:	6a 27                	push   $0x27
  jmp __alltraps
c0102164:	e9 18 09 00 00       	jmp    c0102a81 <__alltraps>

c0102169 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102169:	6a 00                	push   $0x0
  pushl $40
c010216b:	6a 28                	push   $0x28
  jmp __alltraps
c010216d:	e9 0f 09 00 00       	jmp    c0102a81 <__alltraps>

c0102172 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102172:	6a 00                	push   $0x0
  pushl $41
c0102174:	6a 29                	push   $0x29
  jmp __alltraps
c0102176:	e9 06 09 00 00       	jmp    c0102a81 <__alltraps>

c010217b <vector42>:
.globl vector42
vector42:
  pushl $0
c010217b:	6a 00                	push   $0x0
  pushl $42
c010217d:	6a 2a                	push   $0x2a
  jmp __alltraps
c010217f:	e9 fd 08 00 00       	jmp    c0102a81 <__alltraps>

c0102184 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102184:	6a 00                	push   $0x0
  pushl $43
c0102186:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102188:	e9 f4 08 00 00       	jmp    c0102a81 <__alltraps>

c010218d <vector44>:
.globl vector44
vector44:
  pushl $0
c010218d:	6a 00                	push   $0x0
  pushl $44
c010218f:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102191:	e9 eb 08 00 00       	jmp    c0102a81 <__alltraps>

c0102196 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102196:	6a 00                	push   $0x0
  pushl $45
c0102198:	6a 2d                	push   $0x2d
  jmp __alltraps
c010219a:	e9 e2 08 00 00       	jmp    c0102a81 <__alltraps>

c010219f <vector46>:
.globl vector46
vector46:
  pushl $0
c010219f:	6a 00                	push   $0x0
  pushl $46
c01021a1:	6a 2e                	push   $0x2e
  jmp __alltraps
c01021a3:	e9 d9 08 00 00       	jmp    c0102a81 <__alltraps>

c01021a8 <vector47>:
.globl vector47
vector47:
  pushl $0
c01021a8:	6a 00                	push   $0x0
  pushl $47
c01021aa:	6a 2f                	push   $0x2f
  jmp __alltraps
c01021ac:	e9 d0 08 00 00       	jmp    c0102a81 <__alltraps>

c01021b1 <vector48>:
.globl vector48
vector48:
  pushl $0
c01021b1:	6a 00                	push   $0x0
  pushl $48
c01021b3:	6a 30                	push   $0x30
  jmp __alltraps
c01021b5:	e9 c7 08 00 00       	jmp    c0102a81 <__alltraps>

c01021ba <vector49>:
.globl vector49
vector49:
  pushl $0
c01021ba:	6a 00                	push   $0x0
  pushl $49
c01021bc:	6a 31                	push   $0x31
  jmp __alltraps
c01021be:	e9 be 08 00 00       	jmp    c0102a81 <__alltraps>

c01021c3 <vector50>:
.globl vector50
vector50:
  pushl $0
c01021c3:	6a 00                	push   $0x0
  pushl $50
c01021c5:	6a 32                	push   $0x32
  jmp __alltraps
c01021c7:	e9 b5 08 00 00       	jmp    c0102a81 <__alltraps>

c01021cc <vector51>:
.globl vector51
vector51:
  pushl $0
c01021cc:	6a 00                	push   $0x0
  pushl $51
c01021ce:	6a 33                	push   $0x33
  jmp __alltraps
c01021d0:	e9 ac 08 00 00       	jmp    c0102a81 <__alltraps>

c01021d5 <vector52>:
.globl vector52
vector52:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $52
c01021d7:	6a 34                	push   $0x34
  jmp __alltraps
c01021d9:	e9 a3 08 00 00       	jmp    c0102a81 <__alltraps>

c01021de <vector53>:
.globl vector53
vector53:
  pushl $0
c01021de:	6a 00                	push   $0x0
  pushl $53
c01021e0:	6a 35                	push   $0x35
  jmp __alltraps
c01021e2:	e9 9a 08 00 00       	jmp    c0102a81 <__alltraps>

c01021e7 <vector54>:
.globl vector54
vector54:
  pushl $0
c01021e7:	6a 00                	push   $0x0
  pushl $54
c01021e9:	6a 36                	push   $0x36
  jmp __alltraps
c01021eb:	e9 91 08 00 00       	jmp    c0102a81 <__alltraps>

c01021f0 <vector55>:
.globl vector55
vector55:
  pushl $0
c01021f0:	6a 00                	push   $0x0
  pushl $55
c01021f2:	6a 37                	push   $0x37
  jmp __alltraps
c01021f4:	e9 88 08 00 00       	jmp    c0102a81 <__alltraps>

c01021f9 <vector56>:
.globl vector56
vector56:
  pushl $0
c01021f9:	6a 00                	push   $0x0
  pushl $56
c01021fb:	6a 38                	push   $0x38
  jmp __alltraps
c01021fd:	e9 7f 08 00 00       	jmp    c0102a81 <__alltraps>

c0102202 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102202:	6a 00                	push   $0x0
  pushl $57
c0102204:	6a 39                	push   $0x39
  jmp __alltraps
c0102206:	e9 76 08 00 00       	jmp    c0102a81 <__alltraps>

c010220b <vector58>:
.globl vector58
vector58:
  pushl $0
c010220b:	6a 00                	push   $0x0
  pushl $58
c010220d:	6a 3a                	push   $0x3a
  jmp __alltraps
c010220f:	e9 6d 08 00 00       	jmp    c0102a81 <__alltraps>

c0102214 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102214:	6a 00                	push   $0x0
  pushl $59
c0102216:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102218:	e9 64 08 00 00       	jmp    c0102a81 <__alltraps>

c010221d <vector60>:
.globl vector60
vector60:
  pushl $0
c010221d:	6a 00                	push   $0x0
  pushl $60
c010221f:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102221:	e9 5b 08 00 00       	jmp    c0102a81 <__alltraps>

c0102226 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102226:	6a 00                	push   $0x0
  pushl $61
c0102228:	6a 3d                	push   $0x3d
  jmp __alltraps
c010222a:	e9 52 08 00 00       	jmp    c0102a81 <__alltraps>

c010222f <vector62>:
.globl vector62
vector62:
  pushl $0
c010222f:	6a 00                	push   $0x0
  pushl $62
c0102231:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102233:	e9 49 08 00 00       	jmp    c0102a81 <__alltraps>

c0102238 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102238:	6a 00                	push   $0x0
  pushl $63
c010223a:	6a 3f                	push   $0x3f
  jmp __alltraps
c010223c:	e9 40 08 00 00       	jmp    c0102a81 <__alltraps>

c0102241 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102241:	6a 00                	push   $0x0
  pushl $64
c0102243:	6a 40                	push   $0x40
  jmp __alltraps
c0102245:	e9 37 08 00 00       	jmp    c0102a81 <__alltraps>

c010224a <vector65>:
.globl vector65
vector65:
  pushl $0
c010224a:	6a 00                	push   $0x0
  pushl $65
c010224c:	6a 41                	push   $0x41
  jmp __alltraps
c010224e:	e9 2e 08 00 00       	jmp    c0102a81 <__alltraps>

c0102253 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102253:	6a 00                	push   $0x0
  pushl $66
c0102255:	6a 42                	push   $0x42
  jmp __alltraps
c0102257:	e9 25 08 00 00       	jmp    c0102a81 <__alltraps>

c010225c <vector67>:
.globl vector67
vector67:
  pushl $0
c010225c:	6a 00                	push   $0x0
  pushl $67
c010225e:	6a 43                	push   $0x43
  jmp __alltraps
c0102260:	e9 1c 08 00 00       	jmp    c0102a81 <__alltraps>

c0102265 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102265:	6a 00                	push   $0x0
  pushl $68
c0102267:	6a 44                	push   $0x44
  jmp __alltraps
c0102269:	e9 13 08 00 00       	jmp    c0102a81 <__alltraps>

c010226e <vector69>:
.globl vector69
vector69:
  pushl $0
c010226e:	6a 00                	push   $0x0
  pushl $69
c0102270:	6a 45                	push   $0x45
  jmp __alltraps
c0102272:	e9 0a 08 00 00       	jmp    c0102a81 <__alltraps>

c0102277 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102277:	6a 00                	push   $0x0
  pushl $70
c0102279:	6a 46                	push   $0x46
  jmp __alltraps
c010227b:	e9 01 08 00 00       	jmp    c0102a81 <__alltraps>

c0102280 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102280:	6a 00                	push   $0x0
  pushl $71
c0102282:	6a 47                	push   $0x47
  jmp __alltraps
c0102284:	e9 f8 07 00 00       	jmp    c0102a81 <__alltraps>

c0102289 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102289:	6a 00                	push   $0x0
  pushl $72
c010228b:	6a 48                	push   $0x48
  jmp __alltraps
c010228d:	e9 ef 07 00 00       	jmp    c0102a81 <__alltraps>

c0102292 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102292:	6a 00                	push   $0x0
  pushl $73
c0102294:	6a 49                	push   $0x49
  jmp __alltraps
c0102296:	e9 e6 07 00 00       	jmp    c0102a81 <__alltraps>

c010229b <vector74>:
.globl vector74
vector74:
  pushl $0
c010229b:	6a 00                	push   $0x0
  pushl $74
c010229d:	6a 4a                	push   $0x4a
  jmp __alltraps
c010229f:	e9 dd 07 00 00       	jmp    c0102a81 <__alltraps>

c01022a4 <vector75>:
.globl vector75
vector75:
  pushl $0
c01022a4:	6a 00                	push   $0x0
  pushl $75
c01022a6:	6a 4b                	push   $0x4b
  jmp __alltraps
c01022a8:	e9 d4 07 00 00       	jmp    c0102a81 <__alltraps>

c01022ad <vector76>:
.globl vector76
vector76:
  pushl $0
c01022ad:	6a 00                	push   $0x0
  pushl $76
c01022af:	6a 4c                	push   $0x4c
  jmp __alltraps
c01022b1:	e9 cb 07 00 00       	jmp    c0102a81 <__alltraps>

c01022b6 <vector77>:
.globl vector77
vector77:
  pushl $0
c01022b6:	6a 00                	push   $0x0
  pushl $77
c01022b8:	6a 4d                	push   $0x4d
  jmp __alltraps
c01022ba:	e9 c2 07 00 00       	jmp    c0102a81 <__alltraps>

c01022bf <vector78>:
.globl vector78
vector78:
  pushl $0
c01022bf:	6a 00                	push   $0x0
  pushl $78
c01022c1:	6a 4e                	push   $0x4e
  jmp __alltraps
c01022c3:	e9 b9 07 00 00       	jmp    c0102a81 <__alltraps>

c01022c8 <vector79>:
.globl vector79
vector79:
  pushl $0
c01022c8:	6a 00                	push   $0x0
  pushl $79
c01022ca:	6a 4f                	push   $0x4f
  jmp __alltraps
c01022cc:	e9 b0 07 00 00       	jmp    c0102a81 <__alltraps>

c01022d1 <vector80>:
.globl vector80
vector80:
  pushl $0
c01022d1:	6a 00                	push   $0x0
  pushl $80
c01022d3:	6a 50                	push   $0x50
  jmp __alltraps
c01022d5:	e9 a7 07 00 00       	jmp    c0102a81 <__alltraps>

c01022da <vector81>:
.globl vector81
vector81:
  pushl $0
c01022da:	6a 00                	push   $0x0
  pushl $81
c01022dc:	6a 51                	push   $0x51
  jmp __alltraps
c01022de:	e9 9e 07 00 00       	jmp    c0102a81 <__alltraps>

c01022e3 <vector82>:
.globl vector82
vector82:
  pushl $0
c01022e3:	6a 00                	push   $0x0
  pushl $82
c01022e5:	6a 52                	push   $0x52
  jmp __alltraps
c01022e7:	e9 95 07 00 00       	jmp    c0102a81 <__alltraps>

c01022ec <vector83>:
.globl vector83
vector83:
  pushl $0
c01022ec:	6a 00                	push   $0x0
  pushl $83
c01022ee:	6a 53                	push   $0x53
  jmp __alltraps
c01022f0:	e9 8c 07 00 00       	jmp    c0102a81 <__alltraps>

c01022f5 <vector84>:
.globl vector84
vector84:
  pushl $0
c01022f5:	6a 00                	push   $0x0
  pushl $84
c01022f7:	6a 54                	push   $0x54
  jmp __alltraps
c01022f9:	e9 83 07 00 00       	jmp    c0102a81 <__alltraps>

c01022fe <vector85>:
.globl vector85
vector85:
  pushl $0
c01022fe:	6a 00                	push   $0x0
  pushl $85
c0102300:	6a 55                	push   $0x55
  jmp __alltraps
c0102302:	e9 7a 07 00 00       	jmp    c0102a81 <__alltraps>

c0102307 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102307:	6a 00                	push   $0x0
  pushl $86
c0102309:	6a 56                	push   $0x56
  jmp __alltraps
c010230b:	e9 71 07 00 00       	jmp    c0102a81 <__alltraps>

c0102310 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102310:	6a 00                	push   $0x0
  pushl $87
c0102312:	6a 57                	push   $0x57
  jmp __alltraps
c0102314:	e9 68 07 00 00       	jmp    c0102a81 <__alltraps>

c0102319 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102319:	6a 00                	push   $0x0
  pushl $88
c010231b:	6a 58                	push   $0x58
  jmp __alltraps
c010231d:	e9 5f 07 00 00       	jmp    c0102a81 <__alltraps>

c0102322 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102322:	6a 00                	push   $0x0
  pushl $89
c0102324:	6a 59                	push   $0x59
  jmp __alltraps
c0102326:	e9 56 07 00 00       	jmp    c0102a81 <__alltraps>

c010232b <vector90>:
.globl vector90
vector90:
  pushl $0
c010232b:	6a 00                	push   $0x0
  pushl $90
c010232d:	6a 5a                	push   $0x5a
  jmp __alltraps
c010232f:	e9 4d 07 00 00       	jmp    c0102a81 <__alltraps>

c0102334 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102334:	6a 00                	push   $0x0
  pushl $91
c0102336:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102338:	e9 44 07 00 00       	jmp    c0102a81 <__alltraps>

c010233d <vector92>:
.globl vector92
vector92:
  pushl $0
c010233d:	6a 00                	push   $0x0
  pushl $92
c010233f:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102341:	e9 3b 07 00 00       	jmp    c0102a81 <__alltraps>

c0102346 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102346:	6a 00                	push   $0x0
  pushl $93
c0102348:	6a 5d                	push   $0x5d
  jmp __alltraps
c010234a:	e9 32 07 00 00       	jmp    c0102a81 <__alltraps>

c010234f <vector94>:
.globl vector94
vector94:
  pushl $0
c010234f:	6a 00                	push   $0x0
  pushl $94
c0102351:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102353:	e9 29 07 00 00       	jmp    c0102a81 <__alltraps>

c0102358 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102358:	6a 00                	push   $0x0
  pushl $95
c010235a:	6a 5f                	push   $0x5f
  jmp __alltraps
c010235c:	e9 20 07 00 00       	jmp    c0102a81 <__alltraps>

c0102361 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102361:	6a 00                	push   $0x0
  pushl $96
c0102363:	6a 60                	push   $0x60
  jmp __alltraps
c0102365:	e9 17 07 00 00       	jmp    c0102a81 <__alltraps>

c010236a <vector97>:
.globl vector97
vector97:
  pushl $0
c010236a:	6a 00                	push   $0x0
  pushl $97
c010236c:	6a 61                	push   $0x61
  jmp __alltraps
c010236e:	e9 0e 07 00 00       	jmp    c0102a81 <__alltraps>

c0102373 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102373:	6a 00                	push   $0x0
  pushl $98
c0102375:	6a 62                	push   $0x62
  jmp __alltraps
c0102377:	e9 05 07 00 00       	jmp    c0102a81 <__alltraps>

c010237c <vector99>:
.globl vector99
vector99:
  pushl $0
c010237c:	6a 00                	push   $0x0
  pushl $99
c010237e:	6a 63                	push   $0x63
  jmp __alltraps
c0102380:	e9 fc 06 00 00       	jmp    c0102a81 <__alltraps>

c0102385 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102385:	6a 00                	push   $0x0
  pushl $100
c0102387:	6a 64                	push   $0x64
  jmp __alltraps
c0102389:	e9 f3 06 00 00       	jmp    c0102a81 <__alltraps>

c010238e <vector101>:
.globl vector101
vector101:
  pushl $0
c010238e:	6a 00                	push   $0x0
  pushl $101
c0102390:	6a 65                	push   $0x65
  jmp __alltraps
c0102392:	e9 ea 06 00 00       	jmp    c0102a81 <__alltraps>

c0102397 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102397:	6a 00                	push   $0x0
  pushl $102
c0102399:	6a 66                	push   $0x66
  jmp __alltraps
c010239b:	e9 e1 06 00 00       	jmp    c0102a81 <__alltraps>

c01023a0 <vector103>:
.globl vector103
vector103:
  pushl $0
c01023a0:	6a 00                	push   $0x0
  pushl $103
c01023a2:	6a 67                	push   $0x67
  jmp __alltraps
c01023a4:	e9 d8 06 00 00       	jmp    c0102a81 <__alltraps>

c01023a9 <vector104>:
.globl vector104
vector104:
  pushl $0
c01023a9:	6a 00                	push   $0x0
  pushl $104
c01023ab:	6a 68                	push   $0x68
  jmp __alltraps
c01023ad:	e9 cf 06 00 00       	jmp    c0102a81 <__alltraps>

c01023b2 <vector105>:
.globl vector105
vector105:
  pushl $0
c01023b2:	6a 00                	push   $0x0
  pushl $105
c01023b4:	6a 69                	push   $0x69
  jmp __alltraps
c01023b6:	e9 c6 06 00 00       	jmp    c0102a81 <__alltraps>

c01023bb <vector106>:
.globl vector106
vector106:
  pushl $0
c01023bb:	6a 00                	push   $0x0
  pushl $106
c01023bd:	6a 6a                	push   $0x6a
  jmp __alltraps
c01023bf:	e9 bd 06 00 00       	jmp    c0102a81 <__alltraps>

c01023c4 <vector107>:
.globl vector107
vector107:
  pushl $0
c01023c4:	6a 00                	push   $0x0
  pushl $107
c01023c6:	6a 6b                	push   $0x6b
  jmp __alltraps
c01023c8:	e9 b4 06 00 00       	jmp    c0102a81 <__alltraps>

c01023cd <vector108>:
.globl vector108
vector108:
  pushl $0
c01023cd:	6a 00                	push   $0x0
  pushl $108
c01023cf:	6a 6c                	push   $0x6c
  jmp __alltraps
c01023d1:	e9 ab 06 00 00       	jmp    c0102a81 <__alltraps>

c01023d6 <vector109>:
.globl vector109
vector109:
  pushl $0
c01023d6:	6a 00                	push   $0x0
  pushl $109
c01023d8:	6a 6d                	push   $0x6d
  jmp __alltraps
c01023da:	e9 a2 06 00 00       	jmp    c0102a81 <__alltraps>

c01023df <vector110>:
.globl vector110
vector110:
  pushl $0
c01023df:	6a 00                	push   $0x0
  pushl $110
c01023e1:	6a 6e                	push   $0x6e
  jmp __alltraps
c01023e3:	e9 99 06 00 00       	jmp    c0102a81 <__alltraps>

c01023e8 <vector111>:
.globl vector111
vector111:
  pushl $0
c01023e8:	6a 00                	push   $0x0
  pushl $111
c01023ea:	6a 6f                	push   $0x6f
  jmp __alltraps
c01023ec:	e9 90 06 00 00       	jmp    c0102a81 <__alltraps>

c01023f1 <vector112>:
.globl vector112
vector112:
  pushl $0
c01023f1:	6a 00                	push   $0x0
  pushl $112
c01023f3:	6a 70                	push   $0x70
  jmp __alltraps
c01023f5:	e9 87 06 00 00       	jmp    c0102a81 <__alltraps>

c01023fa <vector113>:
.globl vector113
vector113:
  pushl $0
c01023fa:	6a 00                	push   $0x0
  pushl $113
c01023fc:	6a 71                	push   $0x71
  jmp __alltraps
c01023fe:	e9 7e 06 00 00       	jmp    c0102a81 <__alltraps>

c0102403 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102403:	6a 00                	push   $0x0
  pushl $114
c0102405:	6a 72                	push   $0x72
  jmp __alltraps
c0102407:	e9 75 06 00 00       	jmp    c0102a81 <__alltraps>

c010240c <vector115>:
.globl vector115
vector115:
  pushl $0
c010240c:	6a 00                	push   $0x0
  pushl $115
c010240e:	6a 73                	push   $0x73
  jmp __alltraps
c0102410:	e9 6c 06 00 00       	jmp    c0102a81 <__alltraps>

c0102415 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102415:	6a 00                	push   $0x0
  pushl $116
c0102417:	6a 74                	push   $0x74
  jmp __alltraps
c0102419:	e9 63 06 00 00       	jmp    c0102a81 <__alltraps>

c010241e <vector117>:
.globl vector117
vector117:
  pushl $0
c010241e:	6a 00                	push   $0x0
  pushl $117
c0102420:	6a 75                	push   $0x75
  jmp __alltraps
c0102422:	e9 5a 06 00 00       	jmp    c0102a81 <__alltraps>

c0102427 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102427:	6a 00                	push   $0x0
  pushl $118
c0102429:	6a 76                	push   $0x76
  jmp __alltraps
c010242b:	e9 51 06 00 00       	jmp    c0102a81 <__alltraps>

c0102430 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102430:	6a 00                	push   $0x0
  pushl $119
c0102432:	6a 77                	push   $0x77
  jmp __alltraps
c0102434:	e9 48 06 00 00       	jmp    c0102a81 <__alltraps>

c0102439 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102439:	6a 00                	push   $0x0
  pushl $120
c010243b:	6a 78                	push   $0x78
  jmp __alltraps
c010243d:	e9 3f 06 00 00       	jmp    c0102a81 <__alltraps>

c0102442 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102442:	6a 00                	push   $0x0
  pushl $121
c0102444:	6a 79                	push   $0x79
  jmp __alltraps
c0102446:	e9 36 06 00 00       	jmp    c0102a81 <__alltraps>

c010244b <vector122>:
.globl vector122
vector122:
  pushl $0
c010244b:	6a 00                	push   $0x0
  pushl $122
c010244d:	6a 7a                	push   $0x7a
  jmp __alltraps
c010244f:	e9 2d 06 00 00       	jmp    c0102a81 <__alltraps>

c0102454 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102454:	6a 00                	push   $0x0
  pushl $123
c0102456:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102458:	e9 24 06 00 00       	jmp    c0102a81 <__alltraps>

c010245d <vector124>:
.globl vector124
vector124:
  pushl $0
c010245d:	6a 00                	push   $0x0
  pushl $124
c010245f:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102461:	e9 1b 06 00 00       	jmp    c0102a81 <__alltraps>

c0102466 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102466:	6a 00                	push   $0x0
  pushl $125
c0102468:	6a 7d                	push   $0x7d
  jmp __alltraps
c010246a:	e9 12 06 00 00       	jmp    c0102a81 <__alltraps>

c010246f <vector126>:
.globl vector126
vector126:
  pushl $0
c010246f:	6a 00                	push   $0x0
  pushl $126
c0102471:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102473:	e9 09 06 00 00       	jmp    c0102a81 <__alltraps>

c0102478 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102478:	6a 00                	push   $0x0
  pushl $127
c010247a:	6a 7f                	push   $0x7f
  jmp __alltraps
c010247c:	e9 00 06 00 00       	jmp    c0102a81 <__alltraps>

c0102481 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102481:	6a 00                	push   $0x0
  pushl $128
c0102483:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102488:	e9 f4 05 00 00       	jmp    c0102a81 <__alltraps>

c010248d <vector129>:
.globl vector129
vector129:
  pushl $0
c010248d:	6a 00                	push   $0x0
  pushl $129
c010248f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102494:	e9 e8 05 00 00       	jmp    c0102a81 <__alltraps>

c0102499 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102499:	6a 00                	push   $0x0
  pushl $130
c010249b:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01024a0:	e9 dc 05 00 00       	jmp    c0102a81 <__alltraps>

c01024a5 <vector131>:
.globl vector131
vector131:
  pushl $0
c01024a5:	6a 00                	push   $0x0
  pushl $131
c01024a7:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01024ac:	e9 d0 05 00 00       	jmp    c0102a81 <__alltraps>

c01024b1 <vector132>:
.globl vector132
vector132:
  pushl $0
c01024b1:	6a 00                	push   $0x0
  pushl $132
c01024b3:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01024b8:	e9 c4 05 00 00       	jmp    c0102a81 <__alltraps>

c01024bd <vector133>:
.globl vector133
vector133:
  pushl $0
c01024bd:	6a 00                	push   $0x0
  pushl $133
c01024bf:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01024c4:	e9 b8 05 00 00       	jmp    c0102a81 <__alltraps>

c01024c9 <vector134>:
.globl vector134
vector134:
  pushl $0
c01024c9:	6a 00                	push   $0x0
  pushl $134
c01024cb:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01024d0:	e9 ac 05 00 00       	jmp    c0102a81 <__alltraps>

c01024d5 <vector135>:
.globl vector135
vector135:
  pushl $0
c01024d5:	6a 00                	push   $0x0
  pushl $135
c01024d7:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01024dc:	e9 a0 05 00 00       	jmp    c0102a81 <__alltraps>

c01024e1 <vector136>:
.globl vector136
vector136:
  pushl $0
c01024e1:	6a 00                	push   $0x0
  pushl $136
c01024e3:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01024e8:	e9 94 05 00 00       	jmp    c0102a81 <__alltraps>

c01024ed <vector137>:
.globl vector137
vector137:
  pushl $0
c01024ed:	6a 00                	push   $0x0
  pushl $137
c01024ef:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01024f4:	e9 88 05 00 00       	jmp    c0102a81 <__alltraps>

c01024f9 <vector138>:
.globl vector138
vector138:
  pushl $0
c01024f9:	6a 00                	push   $0x0
  pushl $138
c01024fb:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102500:	e9 7c 05 00 00       	jmp    c0102a81 <__alltraps>

c0102505 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102505:	6a 00                	push   $0x0
  pushl $139
c0102507:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010250c:	e9 70 05 00 00       	jmp    c0102a81 <__alltraps>

c0102511 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102511:	6a 00                	push   $0x0
  pushl $140
c0102513:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102518:	e9 64 05 00 00       	jmp    c0102a81 <__alltraps>

c010251d <vector141>:
.globl vector141
vector141:
  pushl $0
c010251d:	6a 00                	push   $0x0
  pushl $141
c010251f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102524:	e9 58 05 00 00       	jmp    c0102a81 <__alltraps>

c0102529 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102529:	6a 00                	push   $0x0
  pushl $142
c010252b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102530:	e9 4c 05 00 00       	jmp    c0102a81 <__alltraps>

c0102535 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102535:	6a 00                	push   $0x0
  pushl $143
c0102537:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010253c:	e9 40 05 00 00       	jmp    c0102a81 <__alltraps>

c0102541 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102541:	6a 00                	push   $0x0
  pushl $144
c0102543:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102548:	e9 34 05 00 00       	jmp    c0102a81 <__alltraps>

c010254d <vector145>:
.globl vector145
vector145:
  pushl $0
c010254d:	6a 00                	push   $0x0
  pushl $145
c010254f:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102554:	e9 28 05 00 00       	jmp    c0102a81 <__alltraps>

c0102559 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102559:	6a 00                	push   $0x0
  pushl $146
c010255b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102560:	e9 1c 05 00 00       	jmp    c0102a81 <__alltraps>

c0102565 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102565:	6a 00                	push   $0x0
  pushl $147
c0102567:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010256c:	e9 10 05 00 00       	jmp    c0102a81 <__alltraps>

c0102571 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102571:	6a 00                	push   $0x0
  pushl $148
c0102573:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102578:	e9 04 05 00 00       	jmp    c0102a81 <__alltraps>

c010257d <vector149>:
.globl vector149
vector149:
  pushl $0
c010257d:	6a 00                	push   $0x0
  pushl $149
c010257f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102584:	e9 f8 04 00 00       	jmp    c0102a81 <__alltraps>

c0102589 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102589:	6a 00                	push   $0x0
  pushl $150
c010258b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102590:	e9 ec 04 00 00       	jmp    c0102a81 <__alltraps>

c0102595 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102595:	6a 00                	push   $0x0
  pushl $151
c0102597:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010259c:	e9 e0 04 00 00       	jmp    c0102a81 <__alltraps>

c01025a1 <vector152>:
.globl vector152
vector152:
  pushl $0
c01025a1:	6a 00                	push   $0x0
  pushl $152
c01025a3:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01025a8:	e9 d4 04 00 00       	jmp    c0102a81 <__alltraps>

c01025ad <vector153>:
.globl vector153
vector153:
  pushl $0
c01025ad:	6a 00                	push   $0x0
  pushl $153
c01025af:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01025b4:	e9 c8 04 00 00       	jmp    c0102a81 <__alltraps>

c01025b9 <vector154>:
.globl vector154
vector154:
  pushl $0
c01025b9:	6a 00                	push   $0x0
  pushl $154
c01025bb:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01025c0:	e9 bc 04 00 00       	jmp    c0102a81 <__alltraps>

c01025c5 <vector155>:
.globl vector155
vector155:
  pushl $0
c01025c5:	6a 00                	push   $0x0
  pushl $155
c01025c7:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01025cc:	e9 b0 04 00 00       	jmp    c0102a81 <__alltraps>

c01025d1 <vector156>:
.globl vector156
vector156:
  pushl $0
c01025d1:	6a 00                	push   $0x0
  pushl $156
c01025d3:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01025d8:	e9 a4 04 00 00       	jmp    c0102a81 <__alltraps>

c01025dd <vector157>:
.globl vector157
vector157:
  pushl $0
c01025dd:	6a 00                	push   $0x0
  pushl $157
c01025df:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01025e4:	e9 98 04 00 00       	jmp    c0102a81 <__alltraps>

c01025e9 <vector158>:
.globl vector158
vector158:
  pushl $0
c01025e9:	6a 00                	push   $0x0
  pushl $158
c01025eb:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01025f0:	e9 8c 04 00 00       	jmp    c0102a81 <__alltraps>

c01025f5 <vector159>:
.globl vector159
vector159:
  pushl $0
c01025f5:	6a 00                	push   $0x0
  pushl $159
c01025f7:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01025fc:	e9 80 04 00 00       	jmp    c0102a81 <__alltraps>

c0102601 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102601:	6a 00                	push   $0x0
  pushl $160
c0102603:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102608:	e9 74 04 00 00       	jmp    c0102a81 <__alltraps>

c010260d <vector161>:
.globl vector161
vector161:
  pushl $0
c010260d:	6a 00                	push   $0x0
  pushl $161
c010260f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102614:	e9 68 04 00 00       	jmp    c0102a81 <__alltraps>

c0102619 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102619:	6a 00                	push   $0x0
  pushl $162
c010261b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102620:	e9 5c 04 00 00       	jmp    c0102a81 <__alltraps>

c0102625 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102625:	6a 00                	push   $0x0
  pushl $163
c0102627:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010262c:	e9 50 04 00 00       	jmp    c0102a81 <__alltraps>

c0102631 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102631:	6a 00                	push   $0x0
  pushl $164
c0102633:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102638:	e9 44 04 00 00       	jmp    c0102a81 <__alltraps>

c010263d <vector165>:
.globl vector165
vector165:
  pushl $0
c010263d:	6a 00                	push   $0x0
  pushl $165
c010263f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102644:	e9 38 04 00 00       	jmp    c0102a81 <__alltraps>

c0102649 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102649:	6a 00                	push   $0x0
  pushl $166
c010264b:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102650:	e9 2c 04 00 00       	jmp    c0102a81 <__alltraps>

c0102655 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102655:	6a 00                	push   $0x0
  pushl $167
c0102657:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010265c:	e9 20 04 00 00       	jmp    c0102a81 <__alltraps>

c0102661 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102661:	6a 00                	push   $0x0
  pushl $168
c0102663:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102668:	e9 14 04 00 00       	jmp    c0102a81 <__alltraps>

c010266d <vector169>:
.globl vector169
vector169:
  pushl $0
c010266d:	6a 00                	push   $0x0
  pushl $169
c010266f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102674:	e9 08 04 00 00       	jmp    c0102a81 <__alltraps>

c0102679 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102679:	6a 00                	push   $0x0
  pushl $170
c010267b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102680:	e9 fc 03 00 00       	jmp    c0102a81 <__alltraps>

c0102685 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102685:	6a 00                	push   $0x0
  pushl $171
c0102687:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010268c:	e9 f0 03 00 00       	jmp    c0102a81 <__alltraps>

c0102691 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102691:	6a 00                	push   $0x0
  pushl $172
c0102693:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102698:	e9 e4 03 00 00       	jmp    c0102a81 <__alltraps>

c010269d <vector173>:
.globl vector173
vector173:
  pushl $0
c010269d:	6a 00                	push   $0x0
  pushl $173
c010269f:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01026a4:	e9 d8 03 00 00       	jmp    c0102a81 <__alltraps>

c01026a9 <vector174>:
.globl vector174
vector174:
  pushl $0
c01026a9:	6a 00                	push   $0x0
  pushl $174
c01026ab:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01026b0:	e9 cc 03 00 00       	jmp    c0102a81 <__alltraps>

c01026b5 <vector175>:
.globl vector175
vector175:
  pushl $0
c01026b5:	6a 00                	push   $0x0
  pushl $175
c01026b7:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01026bc:	e9 c0 03 00 00       	jmp    c0102a81 <__alltraps>

c01026c1 <vector176>:
.globl vector176
vector176:
  pushl $0
c01026c1:	6a 00                	push   $0x0
  pushl $176
c01026c3:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01026c8:	e9 b4 03 00 00       	jmp    c0102a81 <__alltraps>

c01026cd <vector177>:
.globl vector177
vector177:
  pushl $0
c01026cd:	6a 00                	push   $0x0
  pushl $177
c01026cf:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01026d4:	e9 a8 03 00 00       	jmp    c0102a81 <__alltraps>

c01026d9 <vector178>:
.globl vector178
vector178:
  pushl $0
c01026d9:	6a 00                	push   $0x0
  pushl $178
c01026db:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01026e0:	e9 9c 03 00 00       	jmp    c0102a81 <__alltraps>

c01026e5 <vector179>:
.globl vector179
vector179:
  pushl $0
c01026e5:	6a 00                	push   $0x0
  pushl $179
c01026e7:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01026ec:	e9 90 03 00 00       	jmp    c0102a81 <__alltraps>

c01026f1 <vector180>:
.globl vector180
vector180:
  pushl $0
c01026f1:	6a 00                	push   $0x0
  pushl $180
c01026f3:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01026f8:	e9 84 03 00 00       	jmp    c0102a81 <__alltraps>

c01026fd <vector181>:
.globl vector181
vector181:
  pushl $0
c01026fd:	6a 00                	push   $0x0
  pushl $181
c01026ff:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102704:	e9 78 03 00 00       	jmp    c0102a81 <__alltraps>

c0102709 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102709:	6a 00                	push   $0x0
  pushl $182
c010270b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102710:	e9 6c 03 00 00       	jmp    c0102a81 <__alltraps>

c0102715 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102715:	6a 00                	push   $0x0
  pushl $183
c0102717:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010271c:	e9 60 03 00 00       	jmp    c0102a81 <__alltraps>

c0102721 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102721:	6a 00                	push   $0x0
  pushl $184
c0102723:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102728:	e9 54 03 00 00       	jmp    c0102a81 <__alltraps>

c010272d <vector185>:
.globl vector185
vector185:
  pushl $0
c010272d:	6a 00                	push   $0x0
  pushl $185
c010272f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102734:	e9 48 03 00 00       	jmp    c0102a81 <__alltraps>

c0102739 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102739:	6a 00                	push   $0x0
  pushl $186
c010273b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102740:	e9 3c 03 00 00       	jmp    c0102a81 <__alltraps>

c0102745 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102745:	6a 00                	push   $0x0
  pushl $187
c0102747:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010274c:	e9 30 03 00 00       	jmp    c0102a81 <__alltraps>

c0102751 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102751:	6a 00                	push   $0x0
  pushl $188
c0102753:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102758:	e9 24 03 00 00       	jmp    c0102a81 <__alltraps>

c010275d <vector189>:
.globl vector189
vector189:
  pushl $0
c010275d:	6a 00                	push   $0x0
  pushl $189
c010275f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102764:	e9 18 03 00 00       	jmp    c0102a81 <__alltraps>

c0102769 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102769:	6a 00                	push   $0x0
  pushl $190
c010276b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102770:	e9 0c 03 00 00       	jmp    c0102a81 <__alltraps>

c0102775 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102775:	6a 00                	push   $0x0
  pushl $191
c0102777:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010277c:	e9 00 03 00 00       	jmp    c0102a81 <__alltraps>

c0102781 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102781:	6a 00                	push   $0x0
  pushl $192
c0102783:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102788:	e9 f4 02 00 00       	jmp    c0102a81 <__alltraps>

c010278d <vector193>:
.globl vector193
vector193:
  pushl $0
c010278d:	6a 00                	push   $0x0
  pushl $193
c010278f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102794:	e9 e8 02 00 00       	jmp    c0102a81 <__alltraps>

c0102799 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102799:	6a 00                	push   $0x0
  pushl $194
c010279b:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01027a0:	e9 dc 02 00 00       	jmp    c0102a81 <__alltraps>

c01027a5 <vector195>:
.globl vector195
vector195:
  pushl $0
c01027a5:	6a 00                	push   $0x0
  pushl $195
c01027a7:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01027ac:	e9 d0 02 00 00       	jmp    c0102a81 <__alltraps>

c01027b1 <vector196>:
.globl vector196
vector196:
  pushl $0
c01027b1:	6a 00                	push   $0x0
  pushl $196
c01027b3:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01027b8:	e9 c4 02 00 00       	jmp    c0102a81 <__alltraps>

c01027bd <vector197>:
.globl vector197
vector197:
  pushl $0
c01027bd:	6a 00                	push   $0x0
  pushl $197
c01027bf:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01027c4:	e9 b8 02 00 00       	jmp    c0102a81 <__alltraps>

c01027c9 <vector198>:
.globl vector198
vector198:
  pushl $0
c01027c9:	6a 00                	push   $0x0
  pushl $198
c01027cb:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01027d0:	e9 ac 02 00 00       	jmp    c0102a81 <__alltraps>

c01027d5 <vector199>:
.globl vector199
vector199:
  pushl $0
c01027d5:	6a 00                	push   $0x0
  pushl $199
c01027d7:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01027dc:	e9 a0 02 00 00       	jmp    c0102a81 <__alltraps>

c01027e1 <vector200>:
.globl vector200
vector200:
  pushl $0
c01027e1:	6a 00                	push   $0x0
  pushl $200
c01027e3:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01027e8:	e9 94 02 00 00       	jmp    c0102a81 <__alltraps>

c01027ed <vector201>:
.globl vector201
vector201:
  pushl $0
c01027ed:	6a 00                	push   $0x0
  pushl $201
c01027ef:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01027f4:	e9 88 02 00 00       	jmp    c0102a81 <__alltraps>

c01027f9 <vector202>:
.globl vector202
vector202:
  pushl $0
c01027f9:	6a 00                	push   $0x0
  pushl $202
c01027fb:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102800:	e9 7c 02 00 00       	jmp    c0102a81 <__alltraps>

c0102805 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102805:	6a 00                	push   $0x0
  pushl $203
c0102807:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010280c:	e9 70 02 00 00       	jmp    c0102a81 <__alltraps>

c0102811 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102811:	6a 00                	push   $0x0
  pushl $204
c0102813:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102818:	e9 64 02 00 00       	jmp    c0102a81 <__alltraps>

c010281d <vector205>:
.globl vector205
vector205:
  pushl $0
c010281d:	6a 00                	push   $0x0
  pushl $205
c010281f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102824:	e9 58 02 00 00       	jmp    c0102a81 <__alltraps>

c0102829 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102829:	6a 00                	push   $0x0
  pushl $206
c010282b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102830:	e9 4c 02 00 00       	jmp    c0102a81 <__alltraps>

c0102835 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102835:	6a 00                	push   $0x0
  pushl $207
c0102837:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010283c:	e9 40 02 00 00       	jmp    c0102a81 <__alltraps>

c0102841 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102841:	6a 00                	push   $0x0
  pushl $208
c0102843:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102848:	e9 34 02 00 00       	jmp    c0102a81 <__alltraps>

c010284d <vector209>:
.globl vector209
vector209:
  pushl $0
c010284d:	6a 00                	push   $0x0
  pushl $209
c010284f:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102854:	e9 28 02 00 00       	jmp    c0102a81 <__alltraps>

c0102859 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102859:	6a 00                	push   $0x0
  pushl $210
c010285b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102860:	e9 1c 02 00 00       	jmp    c0102a81 <__alltraps>

c0102865 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $211
c0102867:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010286c:	e9 10 02 00 00       	jmp    c0102a81 <__alltraps>

c0102871 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102871:	6a 00                	push   $0x0
  pushl $212
c0102873:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102878:	e9 04 02 00 00       	jmp    c0102a81 <__alltraps>

c010287d <vector213>:
.globl vector213
vector213:
  pushl $0
c010287d:	6a 00                	push   $0x0
  pushl $213
c010287f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102884:	e9 f8 01 00 00       	jmp    c0102a81 <__alltraps>

c0102889 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $214
c010288b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102890:	e9 ec 01 00 00       	jmp    c0102a81 <__alltraps>

c0102895 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102895:	6a 00                	push   $0x0
  pushl $215
c0102897:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010289c:	e9 e0 01 00 00       	jmp    c0102a81 <__alltraps>

c01028a1 <vector216>:
.globl vector216
vector216:
  pushl $0
c01028a1:	6a 00                	push   $0x0
  pushl $216
c01028a3:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01028a8:	e9 d4 01 00 00       	jmp    c0102a81 <__alltraps>

c01028ad <vector217>:
.globl vector217
vector217:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $217
c01028af:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01028b4:	e9 c8 01 00 00       	jmp    c0102a81 <__alltraps>

c01028b9 <vector218>:
.globl vector218
vector218:
  pushl $0
c01028b9:	6a 00                	push   $0x0
  pushl $218
c01028bb:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01028c0:	e9 bc 01 00 00       	jmp    c0102a81 <__alltraps>

c01028c5 <vector219>:
.globl vector219
vector219:
  pushl $0
c01028c5:	6a 00                	push   $0x0
  pushl $219
c01028c7:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01028cc:	e9 b0 01 00 00       	jmp    c0102a81 <__alltraps>

c01028d1 <vector220>:
.globl vector220
vector220:
  pushl $0
c01028d1:	6a 00                	push   $0x0
  pushl $220
c01028d3:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01028d8:	e9 a4 01 00 00       	jmp    c0102a81 <__alltraps>

c01028dd <vector221>:
.globl vector221
vector221:
  pushl $0
c01028dd:	6a 00                	push   $0x0
  pushl $221
c01028df:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01028e4:	e9 98 01 00 00       	jmp    c0102a81 <__alltraps>

c01028e9 <vector222>:
.globl vector222
vector222:
  pushl $0
c01028e9:	6a 00                	push   $0x0
  pushl $222
c01028eb:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01028f0:	e9 8c 01 00 00       	jmp    c0102a81 <__alltraps>

c01028f5 <vector223>:
.globl vector223
vector223:
  pushl $0
c01028f5:	6a 00                	push   $0x0
  pushl $223
c01028f7:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01028fc:	e9 80 01 00 00       	jmp    c0102a81 <__alltraps>

c0102901 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102901:	6a 00                	push   $0x0
  pushl $224
c0102903:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102908:	e9 74 01 00 00       	jmp    c0102a81 <__alltraps>

c010290d <vector225>:
.globl vector225
vector225:
  pushl $0
c010290d:	6a 00                	push   $0x0
  pushl $225
c010290f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102914:	e9 68 01 00 00       	jmp    c0102a81 <__alltraps>

c0102919 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $226
c010291b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102920:	e9 5c 01 00 00       	jmp    c0102a81 <__alltraps>

c0102925 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102925:	6a 00                	push   $0x0
  pushl $227
c0102927:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010292c:	e9 50 01 00 00       	jmp    c0102a81 <__alltraps>

c0102931 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102931:	6a 00                	push   $0x0
  pushl $228
c0102933:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102938:	e9 44 01 00 00       	jmp    c0102a81 <__alltraps>

c010293d <vector229>:
.globl vector229
vector229:
  pushl $0
c010293d:	6a 00                	push   $0x0
  pushl $229
c010293f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102944:	e9 38 01 00 00       	jmp    c0102a81 <__alltraps>

c0102949 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102949:	6a 00                	push   $0x0
  pushl $230
c010294b:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102950:	e9 2c 01 00 00       	jmp    c0102a81 <__alltraps>

c0102955 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102955:	6a 00                	push   $0x0
  pushl $231
c0102957:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010295c:	e9 20 01 00 00       	jmp    c0102a81 <__alltraps>

c0102961 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102961:	6a 00                	push   $0x0
  pushl $232
c0102963:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102968:	e9 14 01 00 00       	jmp    c0102a81 <__alltraps>

c010296d <vector233>:
.globl vector233
vector233:
  pushl $0
c010296d:	6a 00                	push   $0x0
  pushl $233
c010296f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102974:	e9 08 01 00 00       	jmp    c0102a81 <__alltraps>

c0102979 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102979:	6a 00                	push   $0x0
  pushl $234
c010297b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102980:	e9 fc 00 00 00       	jmp    c0102a81 <__alltraps>

c0102985 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102985:	6a 00                	push   $0x0
  pushl $235
c0102987:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010298c:	e9 f0 00 00 00       	jmp    c0102a81 <__alltraps>

c0102991 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102991:	6a 00                	push   $0x0
  pushl $236
c0102993:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102998:	e9 e4 00 00 00       	jmp    c0102a81 <__alltraps>

c010299d <vector237>:
.globl vector237
vector237:
  pushl $0
c010299d:	6a 00                	push   $0x0
  pushl $237
c010299f:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01029a4:	e9 d8 00 00 00       	jmp    c0102a81 <__alltraps>

c01029a9 <vector238>:
.globl vector238
vector238:
  pushl $0
c01029a9:	6a 00                	push   $0x0
  pushl $238
c01029ab:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01029b0:	e9 cc 00 00 00       	jmp    c0102a81 <__alltraps>

c01029b5 <vector239>:
.globl vector239
vector239:
  pushl $0
c01029b5:	6a 00                	push   $0x0
  pushl $239
c01029b7:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01029bc:	e9 c0 00 00 00       	jmp    c0102a81 <__alltraps>

c01029c1 <vector240>:
.globl vector240
vector240:
  pushl $0
c01029c1:	6a 00                	push   $0x0
  pushl $240
c01029c3:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01029c8:	e9 b4 00 00 00       	jmp    c0102a81 <__alltraps>

c01029cd <vector241>:
.globl vector241
vector241:
  pushl $0
c01029cd:	6a 00                	push   $0x0
  pushl $241
c01029cf:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01029d4:	e9 a8 00 00 00       	jmp    c0102a81 <__alltraps>

c01029d9 <vector242>:
.globl vector242
vector242:
  pushl $0
c01029d9:	6a 00                	push   $0x0
  pushl $242
c01029db:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01029e0:	e9 9c 00 00 00       	jmp    c0102a81 <__alltraps>

c01029e5 <vector243>:
.globl vector243
vector243:
  pushl $0
c01029e5:	6a 00                	push   $0x0
  pushl $243
c01029e7:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01029ec:	e9 90 00 00 00       	jmp    c0102a81 <__alltraps>

c01029f1 <vector244>:
.globl vector244
vector244:
  pushl $0
c01029f1:	6a 00                	push   $0x0
  pushl $244
c01029f3:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01029f8:	e9 84 00 00 00       	jmp    c0102a81 <__alltraps>

c01029fd <vector245>:
.globl vector245
vector245:
  pushl $0
c01029fd:	6a 00                	push   $0x0
  pushl $245
c01029ff:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102a04:	e9 78 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a09 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102a09:	6a 00                	push   $0x0
  pushl $246
c0102a0b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102a10:	e9 6c 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a15 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102a15:	6a 00                	push   $0x0
  pushl $247
c0102a17:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102a1c:	e9 60 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a21 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102a21:	6a 00                	push   $0x0
  pushl $248
c0102a23:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102a28:	e9 54 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a2d <vector249>:
.globl vector249
vector249:
  pushl $0
c0102a2d:	6a 00                	push   $0x0
  pushl $249
c0102a2f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102a34:	e9 48 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a39 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102a39:	6a 00                	push   $0x0
  pushl $250
c0102a3b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102a40:	e9 3c 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a45 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102a45:	6a 00                	push   $0x0
  pushl $251
c0102a47:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102a4c:	e9 30 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a51 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102a51:	6a 00                	push   $0x0
  pushl $252
c0102a53:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102a58:	e9 24 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a5d <vector253>:
.globl vector253
vector253:
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  pushl $253
c0102a5f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102a64:	e9 18 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a69 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102a69:	6a 00                	push   $0x0
  pushl $254
c0102a6b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102a70:	e9 0c 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a75 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102a75:	6a 00                	push   $0x0
  pushl $255
c0102a77:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102a7c:	e9 00 00 00 00       	jmp    c0102a81 <__alltraps>

c0102a81 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102a81:	1e                   	push   %ds
    pushl %es
c0102a82:	06                   	push   %es
    pushl %fs
c0102a83:	0f a0                	push   %fs
    pushl %gs
c0102a85:	0f a8                	push   %gs
    pushal
c0102a87:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102a88:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102a8d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102a8f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102a91:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102a92:	e8 64 f5 ff ff       	call   c0101ffb <trap>

    # pop the pushed stack pointer
    popl %esp
c0102a97:	5c                   	pop    %esp

c0102a98 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102a98:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102a99:	0f a9                	pop    %gs
    popl %fs
c0102a9b:	0f a1                	pop    %fs
    popl %es
c0102a9d:	07                   	pop    %es
    popl %ds
c0102a9e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a9f:	83 c4 08             	add    $0x8,%esp
    iret
c0102aa2:	cf                   	iret   

c0102aa3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102aa3:	55                   	push   %ebp
c0102aa4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102aa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aa9:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0102aaf:	29 d0                	sub    %edx,%eax
c0102ab1:	c1 f8 02             	sar    $0x2,%eax
c0102ab4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102aba:	5d                   	pop    %ebp
c0102abb:	c3                   	ret    

c0102abc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102abc:	55                   	push   %ebp
c0102abd:	89 e5                	mov    %esp,%ebp
c0102abf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102ac2:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ac5:	89 04 24             	mov    %eax,(%esp)
c0102ac8:	e8 d6 ff ff ff       	call   c0102aa3 <page2ppn>
c0102acd:	c1 e0 0c             	shl    $0xc,%eax
}
c0102ad0:	c9                   	leave  
c0102ad1:	c3                   	ret    

c0102ad2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102ad2:	55                   	push   %ebp
c0102ad3:	89 e5                	mov    %esp,%ebp
c0102ad5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102ad8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102adb:	c1 e8 0c             	shr    $0xc,%eax
c0102ade:	89 c2                	mov    %eax,%edx
c0102ae0:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102ae5:	39 c2                	cmp    %eax,%edx
c0102ae7:	72 1c                	jb     c0102b05 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102ae9:	c7 44 24 08 70 73 10 	movl   $0xc0107370,0x8(%esp)
c0102af0:	c0 
c0102af1:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0102af8:	00 
c0102af9:	c7 04 24 8f 73 10 c0 	movl   $0xc010738f,(%esp)
c0102b00:	e8 f4 d8 ff ff       	call   c01003f9 <__panic>
    }
    return &pages[PPN(pa)];
c0102b05:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c0102b0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b0e:	c1 e8 0c             	shr    $0xc,%eax
c0102b11:	89 c2                	mov    %eax,%edx
c0102b13:	89 d0                	mov    %edx,%eax
c0102b15:	c1 e0 02             	shl    $0x2,%eax
c0102b18:	01 d0                	add    %edx,%eax
c0102b1a:	c1 e0 02             	shl    $0x2,%eax
c0102b1d:	01 c8                	add    %ecx,%eax
}
c0102b1f:	c9                   	leave  
c0102b20:	c3                   	ret    

c0102b21 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102b21:	55                   	push   %ebp
c0102b22:	89 e5                	mov    %esp,%ebp
c0102b24:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102b27:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b2a:	89 04 24             	mov    %eax,(%esp)
c0102b2d:	e8 8a ff ff ff       	call   c0102abc <page2pa>
c0102b32:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b38:	c1 e8 0c             	shr    $0xc,%eax
c0102b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102b3e:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102b43:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102b46:	72 23                	jb     c0102b6b <page2kva+0x4a>
c0102b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102b4f:	c7 44 24 08 a0 73 10 	movl   $0xc01073a0,0x8(%esp)
c0102b56:	c0 
c0102b57:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0102b5e:	00 
c0102b5f:	c7 04 24 8f 73 10 c0 	movl   $0xc010738f,(%esp)
c0102b66:	e8 8e d8 ff ff       	call   c01003f9 <__panic>
c0102b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b6e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102b73:	c9                   	leave  
c0102b74:	c3                   	ret    

c0102b75 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102b75:	55                   	push   %ebp
c0102b76:	89 e5                	mov    %esp,%ebp
c0102b78:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102b7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b7e:	83 e0 01             	and    $0x1,%eax
c0102b81:	85 c0                	test   %eax,%eax
c0102b83:	75 1c                	jne    c0102ba1 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102b85:	c7 44 24 08 c4 73 10 	movl   $0xc01073c4,0x8(%esp)
c0102b8c:	c0 
c0102b8d:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0102b94:	00 
c0102b95:	c7 04 24 8f 73 10 c0 	movl   $0xc010738f,(%esp)
c0102b9c:	e8 58 d8 ff ff       	call   c01003f9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102ba1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ba4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102ba9:	89 04 24             	mov    %eax,(%esp)
c0102bac:	e8 21 ff ff ff       	call   c0102ad2 <pa2page>
}
c0102bb1:	c9                   	leave  
c0102bb2:	c3                   	ret    

c0102bb3 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102bb3:	55                   	push   %ebp
c0102bb4:	89 e5                	mov    %esp,%ebp
c0102bb6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102bc1:	89 04 24             	mov    %eax,(%esp)
c0102bc4:	e8 09 ff ff ff       	call   c0102ad2 <pa2page>
}
c0102bc9:	c9                   	leave  
c0102bca:	c3                   	ret    

c0102bcb <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102bcb:	55                   	push   %ebp
c0102bcc:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bd1:	8b 00                	mov    (%eax),%eax
}
c0102bd3:	5d                   	pop    %ebp
c0102bd4:	c3                   	ret    

c0102bd5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102bd5:	55                   	push   %ebp
c0102bd6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102bd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bde:	89 10                	mov    %edx,(%eax)
}
c0102be0:	90                   	nop
c0102be1:	5d                   	pop    %ebp
c0102be2:	c3                   	ret    

c0102be3 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102be3:	55                   	push   %ebp
c0102be4:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102be6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102be9:	8b 00                	mov    (%eax),%eax
c0102beb:	8d 50 01             	lea    0x1(%eax),%edx
c0102bee:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bf1:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bf6:	8b 00                	mov    (%eax),%eax
}
c0102bf8:	5d                   	pop    %ebp
c0102bf9:	c3                   	ret    

c0102bfa <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102bfa:	55                   	push   %ebp
c0102bfb:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102bfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c00:	8b 00                	mov    (%eax),%eax
c0102c02:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102c05:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c08:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c0d:	8b 00                	mov    (%eax),%eax
}
c0102c0f:	5d                   	pop    %ebp
c0102c10:	c3                   	ret    

c0102c11 <__intr_save>:
__intr_save(void) {
c0102c11:	55                   	push   %ebp
c0102c12:	89 e5                	mov    %esp,%ebp
c0102c14:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102c17:	9c                   	pushf  
c0102c18:	58                   	pop    %eax
c0102c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102c1f:	25 00 02 00 00       	and    $0x200,%eax
c0102c24:	85 c0                	test   %eax,%eax
c0102c26:	74 0c                	je     c0102c34 <__intr_save+0x23>
        intr_disable();
c0102c28:	e8 70 ec ff ff       	call   c010189d <intr_disable>
        return 1;
c0102c2d:	b8 01 00 00 00       	mov    $0x1,%eax
c0102c32:	eb 05                	jmp    c0102c39 <__intr_save+0x28>
    return 0;
c0102c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102c39:	c9                   	leave  
c0102c3a:	c3                   	ret    

c0102c3b <__intr_restore>:
__intr_restore(bool flag) {
c0102c3b:	55                   	push   %ebp
c0102c3c:	89 e5                	mov    %esp,%ebp
c0102c3e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102c41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102c45:	74 05                	je     c0102c4c <__intr_restore+0x11>
        intr_enable();
c0102c47:	e8 4a ec ff ff       	call   c0101896 <intr_enable>
}
c0102c4c:	90                   	nop
c0102c4d:	c9                   	leave  
c0102c4e:	c3                   	ret    

c0102c4f <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102c4f:	55                   	push   %ebp
c0102c50:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102c52:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c55:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102c58:	b8 23 00 00 00       	mov    $0x23,%eax
c0102c5d:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102c5f:	b8 23 00 00 00       	mov    $0x23,%eax
c0102c64:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102c66:	b8 10 00 00 00       	mov    $0x10,%eax
c0102c6b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102c6d:	b8 10 00 00 00       	mov    $0x10,%eax
c0102c72:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102c74:	b8 10 00 00 00       	mov    $0x10,%eax
c0102c79:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102c7b:	ea 82 2c 10 c0 08 00 	ljmp   $0x8,$0xc0102c82
}
c0102c82:	90                   	nop
c0102c83:	5d                   	pop    %ebp
c0102c84:	c3                   	ret    

c0102c85 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102c85:	55                   	push   %ebp
c0102c86:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c8b:	a3 a4 de 11 c0       	mov    %eax,0xc011dea4
}
c0102c90:	90                   	nop
c0102c91:	5d                   	pop    %ebp
c0102c92:	c3                   	ret    

c0102c93 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102c93:	55                   	push   %ebp
c0102c94:	89 e5                	mov    %esp,%ebp
c0102c96:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102c99:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0102c9e:	89 04 24             	mov    %eax,(%esp)
c0102ca1:	e8 df ff ff ff       	call   c0102c85 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102ca6:	66 c7 05 a8 de 11 c0 	movw   $0x10,0xc011dea8
c0102cad:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102caf:	66 c7 05 28 aa 11 c0 	movw   $0x68,0xc011aa28
c0102cb6:	68 00 
c0102cb8:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102cbd:	0f b7 c0             	movzwl %ax,%eax
c0102cc0:	66 a3 2a aa 11 c0    	mov    %ax,0xc011aa2a
c0102cc6:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102ccb:	c1 e8 10             	shr    $0x10,%eax
c0102cce:	a2 2c aa 11 c0       	mov    %al,0xc011aa2c
c0102cd3:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102cda:	24 f0                	and    $0xf0,%al
c0102cdc:	0c 09                	or     $0x9,%al
c0102cde:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102ce3:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102cea:	24 ef                	and    $0xef,%al
c0102cec:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102cf1:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102cf8:	24 9f                	and    $0x9f,%al
c0102cfa:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102cff:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102d06:	0c 80                	or     $0x80,%al
c0102d08:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102d0d:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102d14:	24 f0                	and    $0xf0,%al
c0102d16:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102d1b:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102d22:	24 ef                	and    $0xef,%al
c0102d24:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102d29:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102d30:	24 df                	and    $0xdf,%al
c0102d32:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102d37:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102d3e:	0c 40                	or     $0x40,%al
c0102d40:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102d45:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102d4c:	24 7f                	and    $0x7f,%al
c0102d4e:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102d53:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102d58:	c1 e8 18             	shr    $0x18,%eax
c0102d5b:	a2 2f aa 11 c0       	mov    %al,0xc011aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102d60:	c7 04 24 30 aa 11 c0 	movl   $0xc011aa30,(%esp)
c0102d67:	e8 e3 fe ff ff       	call   c0102c4f <lgdt>
c0102d6c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102d72:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102d76:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102d79:	90                   	nop
c0102d7a:	c9                   	leave  
c0102d7b:	c3                   	ret    

c0102d7c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102d7c:	55                   	push   %ebp
c0102d7d:	89 e5                	mov    %esp,%ebp
c0102d7f:	83 ec 18             	sub    $0x18,%esp
    //pmm_manager = &default_pmm_manager;
    pmm_manager = &buddy_pmm_manager;
c0102d82:	c7 05 10 df 11 c0 84 	movl   $0xc0107b84,0xc011df10
c0102d89:	7b 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102d8c:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102d91:	8b 00                	mov    (%eax),%eax
c0102d93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102d97:	c7 04 24 f0 73 10 c0 	movl   $0xc01073f0,(%esp)
c0102d9e:	e8 ff d4 ff ff       	call   c01002a2 <cprintf>
    pmm_manager->init();
c0102da3:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102da8:	8b 40 04             	mov    0x4(%eax),%eax
c0102dab:	ff d0                	call   *%eax
}
c0102dad:	90                   	nop
c0102dae:	c9                   	leave  
c0102daf:	c3                   	ret    

c0102db0 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102db0:	55                   	push   %ebp
c0102db1:	89 e5                	mov    %esp,%ebp
c0102db3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102db6:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102dbb:	8b 40 08             	mov    0x8(%eax),%eax
c0102dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102dc5:	8b 55 08             	mov    0x8(%ebp),%edx
c0102dc8:	89 14 24             	mov    %edx,(%esp)
c0102dcb:	ff d0                	call   *%eax
}
c0102dcd:	90                   	nop
c0102dce:	c9                   	leave  
c0102dcf:	c3                   	ret    

c0102dd0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102dd0:	55                   	push   %ebp
c0102dd1:	89 e5                	mov    %esp,%ebp
c0102dd3:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102dd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102ddd:	e8 2f fe ff ff       	call   c0102c11 <__intr_save>
c0102de2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102de5:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102dea:	8b 40 0c             	mov    0xc(%eax),%eax
c0102ded:	8b 55 08             	mov    0x8(%ebp),%edx
c0102df0:	89 14 24             	mov    %edx,(%esp)
c0102df3:	ff d0                	call   *%eax
c0102df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102dfb:	89 04 24             	mov    %eax,(%esp)
c0102dfe:	e8 38 fe ff ff       	call   c0102c3b <__intr_restore>
    //cprintf("here3\n");
    return page;
c0102e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102e06:	c9                   	leave  
c0102e07:	c3                   	ret    

c0102e08 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102e08:	55                   	push   %ebp
c0102e09:	89 e5                	mov    %esp,%ebp
c0102e0b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102e0e:	e8 fe fd ff ff       	call   c0102c11 <__intr_save>
c0102e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102e16:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102e1b:	8b 40 10             	mov    0x10(%eax),%eax
c0102e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102e21:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102e25:	8b 55 08             	mov    0x8(%ebp),%edx
c0102e28:	89 14 24             	mov    %edx,(%esp)
c0102e2b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e30:	89 04 24             	mov    %eax,(%esp)
c0102e33:	e8 03 fe ff ff       	call   c0102c3b <__intr_restore>
}
c0102e38:	90                   	nop
c0102e39:	c9                   	leave  
c0102e3a:	c3                   	ret    

c0102e3b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102e3b:	55                   	push   %ebp
c0102e3c:	89 e5                	mov    %esp,%ebp
c0102e3e:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102e41:	e8 cb fd ff ff       	call   c0102c11 <__intr_save>
c0102e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102e49:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c0102e4e:	8b 40 14             	mov    0x14(%eax),%eax
c0102e51:	ff d0                	call   *%eax
c0102e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e59:	89 04 24             	mov    %eax,(%esp)
c0102e5c:	e8 da fd ff ff       	call   c0102c3b <__intr_restore>
    return ret;
c0102e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102e64:	c9                   	leave  
c0102e65:	c3                   	ret    

c0102e66 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102e66:	55                   	push   %ebp
c0102e67:	89 e5                	mov    %esp,%ebp
c0102e69:	57                   	push   %edi
c0102e6a:	56                   	push   %esi
c0102e6b:	53                   	push   %ebx
c0102e6c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102e72:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102e79:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102e80:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102e87:	c7 04 24 07 74 10 c0 	movl   $0xc0107407,(%esp)
c0102e8e:	e8 0f d4 ff ff       	call   c01002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102e93:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e9a:	e9 22 01 00 00       	jmp    c0102fc1 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ea2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ea5:	89 d0                	mov    %edx,%eax
c0102ea7:	c1 e0 02             	shl    $0x2,%eax
c0102eaa:	01 d0                	add    %edx,%eax
c0102eac:	c1 e0 02             	shl    $0x2,%eax
c0102eaf:	01 c8                	add    %ecx,%eax
c0102eb1:	8b 50 08             	mov    0x8(%eax),%edx
c0102eb4:	8b 40 04             	mov    0x4(%eax),%eax
c0102eb7:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102eba:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102ebd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ec0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ec3:	89 d0                	mov    %edx,%eax
c0102ec5:	c1 e0 02             	shl    $0x2,%eax
c0102ec8:	01 d0                	add    %edx,%eax
c0102eca:	c1 e0 02             	shl    $0x2,%eax
c0102ecd:	01 c8                	add    %ecx,%eax
c0102ecf:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ed2:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ed5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ed8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102edb:	01 c8                	add    %ecx,%eax
c0102edd:	11 da                	adc    %ebx,%edx
c0102edf:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102ee2:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102ee5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102eeb:	89 d0                	mov    %edx,%eax
c0102eed:	c1 e0 02             	shl    $0x2,%eax
c0102ef0:	01 d0                	add    %edx,%eax
c0102ef2:	c1 e0 02             	shl    $0x2,%eax
c0102ef5:	01 c8                	add    %ecx,%eax
c0102ef7:	83 c0 14             	add    $0x14,%eax
c0102efa:	8b 00                	mov    (%eax),%eax
c0102efc:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102eff:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f02:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102f05:	83 c0 ff             	add    $0xffffffff,%eax
c0102f08:	83 d2 ff             	adc    $0xffffffff,%edx
c0102f0b:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102f11:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102f17:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f1d:	89 d0                	mov    %edx,%eax
c0102f1f:	c1 e0 02             	shl    $0x2,%eax
c0102f22:	01 d0                	add    %edx,%eax
c0102f24:	c1 e0 02             	shl    $0x2,%eax
c0102f27:	01 c8                	add    %ecx,%eax
c0102f29:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102f2c:	8b 58 10             	mov    0x10(%eax),%ebx
c0102f2f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102f32:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102f36:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102f3c:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102f42:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102f46:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102f4a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f4d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102f50:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102f54:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102f58:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102f5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102f60:	c7 04 24 14 74 10 c0 	movl   $0xc0107414,(%esp)
c0102f67:	e8 36 d3 ff ff       	call   c01002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102f6c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f72:	89 d0                	mov    %edx,%eax
c0102f74:	c1 e0 02             	shl    $0x2,%eax
c0102f77:	01 d0                	add    %edx,%eax
c0102f79:	c1 e0 02             	shl    $0x2,%eax
c0102f7c:	01 c8                	add    %ecx,%eax
c0102f7e:	83 c0 14             	add    $0x14,%eax
c0102f81:	8b 00                	mov    (%eax),%eax
c0102f83:	83 f8 01             	cmp    $0x1,%eax
c0102f86:	75 36                	jne    c0102fbe <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f8e:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102f91:	77 2b                	ja     c0102fbe <page_init+0x158>
c0102f93:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102f96:	72 05                	jb     c0102f9d <page_init+0x137>
c0102f98:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102f9b:	73 21                	jae    c0102fbe <page_init+0x158>
c0102f9d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102fa1:	77 1b                	ja     c0102fbe <page_init+0x158>
c0102fa3:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102fa7:	72 09                	jb     c0102fb2 <page_init+0x14c>
c0102fa9:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102fb0:	77 0c                	ja     c0102fbe <page_init+0x158>
                maxpa = end;
c0102fb2:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102fb5:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102fbb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102fbe:	ff 45 dc             	incl   -0x24(%ebp)
c0102fc1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102fc4:	8b 00                	mov    (%eax),%eax
c0102fc6:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102fc9:	0f 8c d0 fe ff ff    	jl     c0102e9f <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102fcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102fd3:	72 1d                	jb     c0102ff2 <page_init+0x18c>
c0102fd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102fd9:	77 09                	ja     c0102fe4 <page_init+0x17e>
c0102fdb:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102fe2:	76 0e                	jbe    c0102ff2 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102fe4:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102feb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    // 此处定义的全局end数组指针，正好是ucore kernel加载后定义的第二个全局变量(kern_init处第一行定义的)
    // 其上的高位内存空间并没有被使用,因此以end为起点，存放用于管理物理内存页面的数据结构
    extern char end[];

    npage = maxpa / PGSIZE;
c0102ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ff5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102ff8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102ffc:	c1 ea 0c             	shr    $0xc,%edx
c0102fff:	89 c1                	mov    %eax,%ecx
c0103001:	89 d3                	mov    %edx,%ebx
c0103003:	89 c8                	mov    %ecx,%eax
c0103005:	a3 80 de 11 c0       	mov    %eax,0xc011de80
    //cprintf("***********************************npage is:%d**************************\n",npage);  //result is: 32736;
    // pages指针指向->可用于分配的，物理内存页面Page数组起始地址
    // 因此其恰好位于内核空间之上(通过ROUNDUP PGSIZE取整，保证其位于一个新的物理页中)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010300a:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0103011:	b8 60 14 1e c0       	mov    $0xc01e1460,%eax
c0103016:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103019:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010301c:	01 d0                	add    %edx,%eax
c010301e:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0103021:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103024:	ba 00 00 00 00       	mov    $0x0,%edx
c0103029:	f7 75 c0             	divl   -0x40(%ebp)
c010302c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010302f:	29 d0                	sub    %edx,%eax
c0103031:	a3 18 df 11 c0       	mov    %eax,0xc011df18

    for (i = 0; i < npage; i ++) {
c0103036:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010303d:	eb 2e                	jmp    c010306d <page_init+0x207>
        SetPageReserved(pages + i);
c010303f:	8b 0d 18 df 11 c0    	mov    0xc011df18,%ecx
c0103045:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103048:	89 d0                	mov    %edx,%eax
c010304a:	c1 e0 02             	shl    $0x2,%eax
c010304d:	01 d0                	add    %edx,%eax
c010304f:	c1 e0 02             	shl    $0x2,%eax
c0103052:	01 c8                	add    %ecx,%eax
c0103054:	83 c0 04             	add    $0x4,%eax
c0103057:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c010305e:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103061:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103064:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103067:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c010306a:	ff 45 dc             	incl   -0x24(%ebp)
c010306d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103070:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103075:	39 c2                	cmp    %eax,%edx
c0103077:	72 c6                	jb     c010303f <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103079:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c010307f:	89 d0                	mov    %edx,%eax
c0103081:	c1 e0 02             	shl    $0x2,%eax
c0103084:	01 d0                	add    %edx,%eax
c0103086:	c1 e0 02             	shl    $0x2,%eax
c0103089:	89 c2                	mov    %eax,%edx
c010308b:	a1 18 df 11 c0       	mov    0xc011df18,%eax
c0103090:	01 d0                	add    %edx,%eax
c0103092:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103095:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010309c:	77 23                	ja     c01030c1 <page_init+0x25b>
c010309e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01030a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01030a5:	c7 44 24 08 44 74 10 	movl   $0xc0107444,0x8(%esp)
c01030ac:	c0 
c01030ad:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01030b4:	00 
c01030b5:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01030bc:	e8 38 d3 ff ff       	call   c01003f9 <__panic>
c01030c1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01030c4:	05 00 00 00 40       	add    $0x40000000,%eax
c01030c9:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01030cc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01030d3:	e9 69 01 00 00       	jmp    c0103241 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01030d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01030db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01030de:	89 d0                	mov    %edx,%eax
c01030e0:	c1 e0 02             	shl    $0x2,%eax
c01030e3:	01 d0                	add    %edx,%eax
c01030e5:	c1 e0 02             	shl    $0x2,%eax
c01030e8:	01 c8                	add    %ecx,%eax
c01030ea:	8b 50 08             	mov    0x8(%eax),%edx
c01030ed:	8b 40 04             	mov    0x4(%eax),%eax
c01030f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030f3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01030f6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01030f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01030fc:	89 d0                	mov    %edx,%eax
c01030fe:	c1 e0 02             	shl    $0x2,%eax
c0103101:	01 d0                	add    %edx,%eax
c0103103:	c1 e0 02             	shl    $0x2,%eax
c0103106:	01 c8                	add    %ecx,%eax
c0103108:	8b 48 0c             	mov    0xc(%eax),%ecx
c010310b:	8b 58 10             	mov    0x10(%eax),%ebx
c010310e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103111:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103114:	01 c8                	add    %ecx,%eax
c0103116:	11 da                	adc    %ebx,%edx
c0103118:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010311b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010311e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103121:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103124:	89 d0                	mov    %edx,%eax
c0103126:	c1 e0 02             	shl    $0x2,%eax
c0103129:	01 d0                	add    %edx,%eax
c010312b:	c1 e0 02             	shl    $0x2,%eax
c010312e:	01 c8                	add    %ecx,%eax
c0103130:	83 c0 14             	add    $0x14,%eax
c0103133:	8b 00                	mov    (%eax),%eax
c0103135:	83 f8 01             	cmp    $0x1,%eax
c0103138:	0f 85 00 01 00 00    	jne    c010323e <page_init+0x3d8>
            if (begin < freemem) {
c010313e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103141:	ba 00 00 00 00       	mov    $0x0,%edx
c0103146:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0103149:	77 17                	ja     c0103162 <page_init+0x2fc>
c010314b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010314e:	72 05                	jb     c0103155 <page_init+0x2ef>
c0103150:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0103153:	73 0d                	jae    c0103162 <page_init+0x2fc>
                begin = freemem;
c0103155:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103158:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010315b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0103162:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103166:	72 1d                	jb     c0103185 <page_init+0x31f>
c0103168:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010316c:	77 09                	ja     c0103177 <page_init+0x311>
c010316e:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0103175:	76 0e                	jbe    c0103185 <page_init+0x31f>
                end = KMEMSIZE;
c0103177:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010317e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0103185:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103188:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010318b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010318e:	0f 87 aa 00 00 00    	ja     c010323e <page_init+0x3d8>
c0103194:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103197:	72 09                	jb     c01031a2 <page_init+0x33c>
c0103199:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010319c:	0f 83 9c 00 00 00    	jae    c010323e <page_init+0x3d8>
                // begin起始地址以PGSIZE为单位，向高位取整
                begin = ROUNDUP(begin, PGSIZE);
c01031a2:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c01031a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01031ac:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01031af:	01 d0                	add    %edx,%eax
c01031b1:	48                   	dec    %eax
c01031b2:	89 45 ac             	mov    %eax,-0x54(%ebp)
c01031b5:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01031b8:	ba 00 00 00 00       	mov    $0x0,%edx
c01031bd:	f7 75 b0             	divl   -0x50(%ebp)
c01031c0:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01031c3:	29 d0                	sub    %edx,%eax
c01031c5:	ba 00 00 00 00       	mov    $0x0,%edx
c01031ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01031cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                // end截止地址以PGSIZE为单位，向低位取整
                end = ROUNDDOWN(end, PGSIZE);
c01031d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01031d3:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01031d6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01031d9:	ba 00 00 00 00       	mov    $0x0,%edx
c01031de:	89 c3                	mov    %eax,%ebx
c01031e0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c01031e6:	89 de                	mov    %ebx,%esi
c01031e8:	89 d0                	mov    %edx,%eax
c01031ea:	83 e0 00             	and    $0x0,%eax
c01031ed:	89 c7                	mov    %eax,%edi
c01031ef:	89 75 c8             	mov    %esi,-0x38(%ebp)
c01031f2:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c01031f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01031f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01031fb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01031fe:	77 3e                	ja     c010323e <page_init+0x3d8>
c0103200:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103203:	72 05                	jb     c010320a <page_init+0x3a4>
c0103205:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103208:	73 34                	jae    c010323e <page_init+0x3d8>
                    // 进行空闲内存块的映射，将其纳入物理内存管理器中管理，用于后续的物理内存分配
                    // 这里的begin、end都是探测出来的物理地址
                    // 第一个参数：起始Page结构的虚拟地址base = pa2page(begin)
                    // 第二个参数：空闲页的个数 = (end - begin) / PGSIZE
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010320a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010320d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103210:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103213:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103216:	89 c1                	mov    %eax,%ecx
c0103218:	89 d3                	mov    %edx,%ebx
c010321a:	89 c8                	mov    %ecx,%eax
c010321c:	89 da                	mov    %ebx,%edx
c010321e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103222:	c1 ea 0c             	shr    $0xc,%edx
c0103225:	89 c3                	mov    %eax,%ebx
c0103227:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010322a:	89 04 24             	mov    %eax,(%esp)
c010322d:	e8 a0 f8 ff ff       	call   c0102ad2 <pa2page>
c0103232:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103236:	89 04 24             	mov    %eax,(%esp)
c0103239:	e8 72 fb ff ff       	call   c0102db0 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010323e:	ff 45 dc             	incl   -0x24(%ebp)
c0103241:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103244:	8b 00                	mov    (%eax),%eax
c0103246:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103249:	0f 8c 89 fe ff ff    	jl     c01030d8 <page_init+0x272>
                }
            }
        }
    }
}
c010324f:	90                   	nop
c0103250:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103256:	5b                   	pop    %ebx
c0103257:	5e                   	pop    %esi
c0103258:	5f                   	pop    %edi
c0103259:	5d                   	pop    %ebp
c010325a:	c3                   	ret    

c010325b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010325b:	55                   	push   %ebp
c010325c:	89 e5                	mov    %esp,%ebp
c010325e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103261:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103264:	33 45 14             	xor    0x14(%ebp),%eax
c0103267:	25 ff 0f 00 00       	and    $0xfff,%eax
c010326c:	85 c0                	test   %eax,%eax
c010326e:	74 24                	je     c0103294 <boot_map_segment+0x39>
c0103270:	c7 44 24 0c 76 74 10 	movl   $0xc0107476,0xc(%esp)
c0103277:	c0 
c0103278:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c010327f:	c0 
c0103280:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0103287:	00 
c0103288:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c010328f:	e8 65 d1 ff ff       	call   c01003f9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103294:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010329b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010329e:	25 ff 0f 00 00       	and    $0xfff,%eax
c01032a3:	89 c2                	mov    %eax,%edx
c01032a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01032a8:	01 c2                	add    %eax,%edx
c01032aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032ad:	01 d0                	add    %edx,%eax
c01032af:	48                   	dec    %eax
c01032b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01032b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032b6:	ba 00 00 00 00       	mov    $0x0,%edx
c01032bb:	f7 75 f0             	divl   -0x10(%ebp)
c01032be:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032c1:	29 d0                	sub    %edx,%eax
c01032c3:	c1 e8 0c             	shr    $0xc,%eax
c01032c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01032c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01032cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032d7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01032da:	8b 45 14             	mov    0x14(%ebp),%eax
c01032dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01032e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01032e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032e8:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01032eb:	eb 68                	jmp    c0103355 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01032ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01032f4:	00 
c01032f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01032fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ff:	89 04 24             	mov    %eax,(%esp)
c0103302:	e8 81 01 00 00       	call   c0103488 <get_pte>
c0103307:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010330a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010330e:	75 24                	jne    c0103334 <boot_map_segment+0xd9>
c0103310:	c7 44 24 0c a2 74 10 	movl   $0xc01074a2,0xc(%esp)
c0103317:	c0 
c0103318:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c010331f:	c0 
c0103320:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0103327:	00 
c0103328:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c010332f:	e8 c5 d0 ff ff       	call   c01003f9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103334:	8b 45 14             	mov    0x14(%ebp),%eax
c0103337:	0b 45 18             	or     0x18(%ebp),%eax
c010333a:	83 c8 01             	or     $0x1,%eax
c010333d:	89 c2                	mov    %eax,%edx
c010333f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103342:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103344:	ff 4d f4             	decl   -0xc(%ebp)
c0103347:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010334e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103355:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103359:	75 92                	jne    c01032ed <boot_map_segment+0x92>
    }
}
c010335b:	90                   	nop
c010335c:	c9                   	leave  
c010335d:	c3                   	ret    

c010335e <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010335e:	55                   	push   %ebp
c010335f:	89 e5                	mov    %esp,%ebp
c0103361:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103364:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010336b:	e8 60 fa ff ff       	call   c0102dd0 <alloc_pages>
c0103370:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103377:	75 1c                	jne    c0103395 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0103379:	c7 44 24 08 af 74 10 	movl   $0xc01074af,0x8(%esp)
c0103380:	c0 
c0103381:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103388:	00 
c0103389:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103390:	e8 64 d0 ff ff       	call   c01003f9 <__panic>
    }
    return page2kva(p);
c0103395:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103398:	89 04 24             	mov    %eax,(%esp)
c010339b:	e8 81 f7 ff ff       	call   c0102b21 <page2kva>
}
c01033a0:	c9                   	leave  
c01033a1:	c3                   	ret    

c01033a2 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01033a2:	55                   	push   %ebp
c01033a3:	89 e5                	mov    %esp,%ebp
c01033a5:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01033a8:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01033ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033b0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01033b7:	77 23                	ja     c01033dc <pmm_init+0x3a>
c01033b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01033c0:	c7 44 24 08 44 74 10 	movl   $0xc0107444,0x8(%esp)
c01033c7:	c0 
c01033c8:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c01033cf:	00 
c01033d0:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01033d7:	e8 1d d0 ff ff       	call   c01003f9 <__panic>
c01033dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033df:	05 00 00 00 40       	add    $0x40000000,%eax
c01033e4:	a3 14 df 11 c0       	mov    %eax,0xc011df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01033e9:	e8 8e f9 ff ff       	call   c0102d7c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01033ee:	e8 73 fa ff ff       	call   c0102e66 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01033f3:	e8 de 03 00 00       	call   c01037d6 <check_alloc_page>

    check_pgdir();
c01033f8:	e8 f8 03 00 00       	call   c01037f5 <check_pgdir>
    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    // 将当前内核页表的物理地址设置进对应的页目录项中(内核页表的自映射)
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01033fd:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103402:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103405:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010340c:	77 23                	ja     c0103431 <pmm_init+0x8f>
c010340e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103411:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103415:	c7 44 24 08 44 74 10 	movl   $0xc0107444,0x8(%esp)
c010341c:	c0 
c010341d:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0103424:	00 
c0103425:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c010342c:	e8 c8 cf ff ff       	call   c01003f9 <__panic>
c0103431:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103434:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010343a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010343f:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103444:	83 ca 03             	or     $0x3,%edx
c0103447:	89 10                	mov    %edx,(%eax)
    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    // 将内核所占用的物理内存，进行页表<->物理页的映射
    // 令处于高位虚拟内存空间的内核，正确的映射到低位的物理内存空间
    // (映射关系(虚实映射): 内核起始虚拟地址(KERNBASE)~内核截止虚拟地址(KERNBASE+KMEMSIZE) =  内核起始物理地址(0)~内核截止物理地址(KMEMSIZE))
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103449:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010344e:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103455:	00 
c0103456:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010345d:	00 
c010345e:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103465:	38 
c0103466:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010346d:	c0 
c010346e:	89 04 24             	mov    %eax,(%esp)
c0103471:	e8 e5 fd ff ff       	call   c010325b <boot_map_segment>
    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    // 重新设置GDT
    gdt_init();
c0103476:	e8 18 f8 ff ff       	call   c0102c93 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010347b:	e8 29 0a 00 00       	call   c0103ea9 <check_boot_pgdir>

    print_pgdir();
c0103480:	e8 a2 0e 00 00       	call   c0104327 <print_pgdir>

}
c0103485:	90                   	nop
c0103486:	c9                   	leave  
c0103487:	c3                   	ret    

c0103488 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103488:	55                   	push   %ebp
c0103489:	89 e5                	mov    %esp,%ebp
c010348b:	83 ec 38             	sub    $0x38,%esp

PTE_U 0x004 表示可以读取对应地址的物理内存页内容
*/
    // PDX(la) 根据la的高10位获得对应的页目录项(一级页表中的某一项)索引(页目录项)
    // &pgdir[PDX(la)] 根据一级页表项索引从一级页表中找到对应的页目录项指针
    pde_t *pdep = &pgdir[PDX(la)];
c010348e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103491:	c1 e8 16             	shr    $0x16,%eax
c0103494:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010349b:	8b 45 08             	mov    0x8(%ebp),%eax
c010349e:	01 d0                	add    %edx,%eax
c01034a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01034a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034a6:	8b 00                	mov    (%eax),%eax
c01034a8:	83 e0 01             	and    $0x1,%eax
c01034ab:	85 c0                	test   %eax,%eax
c01034ad:	0f 85 af 00 00 00    	jne    c0103562 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01034b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01034b7:	74 15                	je     c01034ce <get_pte+0x46>
c01034b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034c0:	e8 0b f9 ff ff       	call   c0102dd0 <alloc_pages>
c01034c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01034cc:	75 0a                	jne    c01034d8 <get_pte+0x50>
            return NULL;
c01034ce:	b8 00 00 00 00       	mov    $0x0,%eax
c01034d3:	e9 e7 00 00 00       	jmp    c01035bf <get_pte+0x137>
        }
        // 二级页表所对应的物理页 引用数为1
        set_page_ref(page, 1);
c01034d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01034df:	00 
c01034e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034e3:	89 04 24             	mov    %eax,(%esp)
c01034e6:	e8 ea f6 ff ff       	call   c0102bd5 <set_page_ref>
        // 获得page变量的物理地址
        uintptr_t pa = page2pa(page);
c01034eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034ee:	89 04 24             	mov    %eax,(%esp)
c01034f1:	e8 c6 f5 ff ff       	call   c0102abc <page2pa>
c01034f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 将整个page所在的物理页格式胡，全部填满0
        memset(KADDR(pa), 0, PGSIZE);
c01034f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01034ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103502:	c1 e8 0c             	shr    $0xc,%eax
c0103505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103508:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010350d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103510:	72 23                	jb     c0103535 <get_pte+0xad>
c0103512:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103515:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103519:	c7 44 24 08 a0 73 10 	movl   $0xc01073a0,0x8(%esp)
c0103520:	c0 
c0103521:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
c0103528:	00 
c0103529:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103530:	e8 c4 ce ff ff       	call   c01003f9 <__panic>
c0103535:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103538:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010353d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103544:	00 
c0103545:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010354c:	00 
c010354d:	89 04 24             	mov    %eax,(%esp)
c0103550:	e8 c2 2e 00 00       	call   c0106417 <memset>
        // la对应的一级页目录项进行赋值，使其指向新创建的二级页表(页表中的数据被MMU直接处理，为了映射效率存放的都是物理地址)
        // 或PTE_U/PTE_W/PET_P 标识当前页目录项是用户级别的、可写的、已存在的
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0103555:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103558:	83 c8 07             	or     $0x7,%eax
c010355b:	89 c2                	mov    %eax,%edx
c010355d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103560:	89 10                	mov    %edx,(%eax)
    }
    // 要想通过C语言中的数组来访问对应数据，需要的是数组基址(虚拟地址),而*pdep中页目录表项中存放了对应二级页表的一个物理地址
    // PDE_ADDR将*pdep的低12位抹零对齐(指向二级页表的起始基地址)，再通过KADDR转为内核虚拟地址，进行数组访问
    // PTX(la)获得la线性地址的中间10位部分，即二级页表中对应页表项的索引下标。这样便能得到la对应的二级页表项了
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0103562:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103565:	8b 00                	mov    (%eax),%eax
c0103567:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010356c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010356f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103572:	c1 e8 0c             	shr    $0xc,%eax
c0103575:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103578:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010357d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103580:	72 23                	jb     c01035a5 <get_pte+0x11d>
c0103582:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103585:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103589:	c7 44 24 08 a0 73 10 	movl   $0xc01073a0,0x8(%esp)
c0103590:	c0 
c0103591:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
c0103598:	00 
c0103599:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01035a0:	e8 54 ce ff ff       	call   c01003f9 <__panic>
c01035a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01035a8:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01035ad:	89 c2                	mov    %eax,%edx
c01035af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035b2:	c1 e8 0c             	shr    $0xc,%eax
c01035b5:	25 ff 03 00 00       	and    $0x3ff,%eax
c01035ba:	c1 e0 02             	shl    $0x2,%eax
c01035bd:	01 d0                	add    %edx,%eax
}
c01035bf:	c9                   	leave  
c01035c0:	c3                   	ret    

c01035c1 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01035c1:	55                   	push   %ebp
c01035c2:	89 e5                	mov    %esp,%ebp
c01035c4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01035c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035ce:	00 
c01035cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d9:	89 04 24             	mov    %eax,(%esp)
c01035dc:	e8 a7 fe ff ff       	call   c0103488 <get_pte>
c01035e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01035e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01035e8:	74 08                	je     c01035f2 <get_page+0x31>
        *ptep_store = ptep;
c01035ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01035ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035f0:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01035f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035f6:	74 1b                	je     c0103613 <get_page+0x52>
c01035f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035fb:	8b 00                	mov    (%eax),%eax
c01035fd:	83 e0 01             	and    $0x1,%eax
c0103600:	85 c0                	test   %eax,%eax
c0103602:	74 0f                	je     c0103613 <get_page+0x52>
        return pte2page(*ptep);
c0103604:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103607:	8b 00                	mov    (%eax),%eax
c0103609:	89 04 24             	mov    %eax,(%esp)
c010360c:	e8 64 f5 ff ff       	call   c0102b75 <pte2page>
c0103611:	eb 05                	jmp    c0103618 <get_page+0x57>
    }
    return NULL;
c0103613:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103618:	c9                   	leave  
c0103619:	c3                   	ret    

c010361a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010361a:	55                   	push   %ebp
c010361b:	89 e5                	mov    %esp,%ebp
c010361d:	83 ec 28             	sub    $0x28,%esp
                                  //(6) flush tlb
    }
#endif
        // 如果对应的二级页表项存在
        // 获得*ptep对应的Page结构
    if (*ptep & PTE_P) {
c0103620:	8b 45 10             	mov    0x10(%ebp),%eax
c0103623:	8b 00                	mov    (%eax),%eax
c0103625:	83 e0 01             	and    $0x1,%eax
c0103628:	85 c0                	test   %eax,%eax
c010362a:	74 4d                	je     c0103679 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c010362c:	8b 45 10             	mov    0x10(%ebp),%eax
c010362f:	8b 00                	mov    (%eax),%eax
c0103631:	89 04 24             	mov    %eax,(%esp)
c0103634:	e8 3c f5 ff ff       	call   c0102b75 <pte2page>
c0103639:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363f:	89 04 24             	mov    %eax,(%esp)
c0103642:	e8 b3 f5 ff ff       	call   c0102bfa <page_ref_dec>
c0103647:	85 c0                	test   %eax,%eax
c0103649:	75 13                	jne    c010365e <page_remove_pte+0x44>
            // 如果自减1后，引用数为0，需要free释放掉该物理页
            free_page(page);
c010364b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103652:	00 
c0103653:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103656:	89 04 24             	mov    %eax,(%esp)
c0103659:	e8 aa f7 ff ff       	call   c0102e08 <free_pages>
        }
        // 清空当前二级页表项(整体设置为0)
        *ptep = 0;
c010365e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103661:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        // 由于页表项发生了改变，需要TLB快表
        tlb_invalidate(pgdir, la);
c0103667:	8b 45 0c             	mov    0xc(%ebp),%eax
c010366a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010366e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103671:	89 04 24             	mov    %eax,(%esp)
c0103674:	e8 01 01 00 00       	call   c010377a <tlb_invalidate>
    }
}
c0103679:	90                   	nop
c010367a:	c9                   	leave  
c010367b:	c3                   	ret    

c010367c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010367c:	55                   	push   %ebp
c010367d:	89 e5                	mov    %esp,%ebp
c010367f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103682:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103689:	00 
c010368a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010368d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103691:	8b 45 08             	mov    0x8(%ebp),%eax
c0103694:	89 04 24             	mov    %eax,(%esp)
c0103697:	e8 ec fd ff ff       	call   c0103488 <get_pte>
c010369c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010369f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01036a3:	74 19                	je     c01036be <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01036a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01036ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01036b6:	89 04 24             	mov    %eax,(%esp)
c01036b9:	e8 5c ff ff ff       	call   c010361a <page_remove_pte>
    }
}
c01036be:	90                   	nop
c01036bf:	c9                   	leave  
c01036c0:	c3                   	ret    

c01036c1 <page_insert>:
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
//指定一个新的page结构，来对应到这个页表；函数传入的page是想要映射的page结构，而函数中的p，则是这个页表现有的对应的page结构，
//所以函数中有一个判断p==page的语句
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01036c1:	55                   	push   %ebp
c01036c2:	89 e5                	mov    %esp,%ebp
c01036c4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01036c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01036ce:	00 
c01036cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01036d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d9:	89 04 24             	mov    %eax,(%esp)
c01036dc:	e8 a7 fd ff ff       	call   c0103488 <get_pte>
c01036e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01036e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01036e8:	75 0a                	jne    c01036f4 <page_insert+0x33>
        return -E_NO_MEM;
c01036ea:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01036ef:	e9 84 00 00 00       	jmp    c0103778 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01036f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036f7:	89 04 24             	mov    %eax,(%esp)
c01036fa:	e8 e4 f4 ff ff       	call   c0102be3 <page_ref_inc>
    if (*ptep & PTE_P) {
c01036ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103702:	8b 00                	mov    (%eax),%eax
c0103704:	83 e0 01             	and    $0x1,%eax
c0103707:	85 c0                	test   %eax,%eax
c0103709:	74 3e                	je     c0103749 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010370b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010370e:	8b 00                	mov    (%eax),%eax
c0103710:	89 04 24             	mov    %eax,(%esp)
c0103713:	e8 5d f4 ff ff       	call   c0102b75 <pte2page>
c0103718:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010371b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010371e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103721:	75 0d                	jne    c0103730 <page_insert+0x6f>
            page_ref_dec(page);
c0103723:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103726:	89 04 24             	mov    %eax,(%esp)
c0103729:	e8 cc f4 ff ff       	call   c0102bfa <page_ref_dec>
c010372e:	eb 19                	jmp    c0103749 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103730:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103733:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103737:	8b 45 10             	mov    0x10(%ebp),%eax
c010373a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010373e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103741:	89 04 24             	mov    %eax,(%esp)
c0103744:	e8 d1 fe ff ff       	call   c010361a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103749:	8b 45 0c             	mov    0xc(%ebp),%eax
c010374c:	89 04 24             	mov    %eax,(%esp)
c010374f:	e8 68 f3 ff ff       	call   c0102abc <page2pa>
c0103754:	0b 45 14             	or     0x14(%ebp),%eax
c0103757:	83 c8 01             	or     $0x1,%eax
c010375a:	89 c2                	mov    %eax,%edx
c010375c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010375f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103761:	8b 45 10             	mov    0x10(%ebp),%eax
c0103764:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103768:	8b 45 08             	mov    0x8(%ebp),%eax
c010376b:	89 04 24             	mov    %eax,(%esp)
c010376e:	e8 07 00 00 00       	call   c010377a <tlb_invalidate>
    return 0;
c0103773:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103778:	c9                   	leave  
c0103779:	c3                   	ret    

c010377a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010377a:	55                   	push   %ebp
c010377b:	89 e5                	mov    %esp,%ebp
c010377d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103780:	0f 20 d8             	mov    %cr3,%eax
c0103783:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103786:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103789:	8b 45 08             	mov    0x8(%ebp),%eax
c010378c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010378f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103796:	77 23                	ja     c01037bb <tlb_invalidate+0x41>
c0103798:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010379b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010379f:	c7 44 24 08 44 74 10 	movl   $0xc0107444,0x8(%esp)
c01037a6:	c0 
c01037a7:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c01037ae:	00 
c01037af:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01037b6:	e8 3e cc ff ff       	call   c01003f9 <__panic>
c01037bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037be:	05 00 00 00 40       	add    $0x40000000,%eax
c01037c3:	39 d0                	cmp    %edx,%eax
c01037c5:	75 0c                	jne    c01037d3 <tlb_invalidate+0x59>
        invlpg((void *)la);
c01037c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01037cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037d0:	0f 01 38             	invlpg (%eax)
    }
}
c01037d3:	90                   	nop
c01037d4:	c9                   	leave  
c01037d5:	c3                   	ret    

c01037d6 <check_alloc_page>:

static void
check_alloc_page(void) {
c01037d6:	55                   	push   %ebp
c01037d7:	89 e5                	mov    %esp,%ebp
c01037d9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01037dc:	a1 10 df 11 c0       	mov    0xc011df10,%eax
c01037e1:	8b 40 18             	mov    0x18(%eax),%eax
c01037e4:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01037e6:	c7 04 24 c8 74 10 c0 	movl   $0xc01074c8,(%esp)
c01037ed:	e8 b0 ca ff ff       	call   c01002a2 <cprintf>
}
c01037f2:	90                   	nop
c01037f3:	c9                   	leave  
c01037f4:	c3                   	ret    

c01037f5 <check_pgdir>:

static void
check_pgdir(void) {
c01037f5:	55                   	push   %ebp
c01037f6:	89 e5                	mov    %esp,%ebp
c01037f8:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01037fb:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103800:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103805:	76 24                	jbe    c010382b <check_pgdir+0x36>
c0103807:	c7 44 24 0c e7 74 10 	movl   $0xc01074e7,0xc(%esp)
c010380e:	c0 
c010380f:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103816:	c0 
c0103817:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c010381e:	00 
c010381f:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103826:	e8 ce cb ff ff       	call   c01003f9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010382b:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103830:	85 c0                	test   %eax,%eax
c0103832:	74 0e                	je     c0103842 <check_pgdir+0x4d>
c0103834:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103839:	25 ff 0f 00 00       	and    $0xfff,%eax
c010383e:	85 c0                	test   %eax,%eax
c0103840:	74 24                	je     c0103866 <check_pgdir+0x71>
c0103842:	c7 44 24 0c 04 75 10 	movl   $0xc0107504,0xc(%esp)
c0103849:	c0 
c010384a:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103851:	c0 
c0103852:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0103859:	00 
c010385a:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103861:	e8 93 cb ff ff       	call   c01003f9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103866:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010386b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103872:	00 
c0103873:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010387a:	00 
c010387b:	89 04 24             	mov    %eax,(%esp)
c010387e:	e8 3e fd ff ff       	call   c01035c1 <get_page>
c0103883:	85 c0                	test   %eax,%eax
c0103885:	74 24                	je     c01038ab <check_pgdir+0xb6>
c0103887:	c7 44 24 0c 3c 75 10 	movl   $0xc010753c,0xc(%esp)
c010388e:	c0 
c010388f:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103896:	c0 
c0103897:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c010389e:	00 
c010389f:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01038a6:	e8 4e cb ff ff       	call   c01003f9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01038ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038b2:	e8 19 f5 ff ff       	call   c0102dd0 <alloc_pages>
c01038b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("allocate p1 succeed!\n");
c01038ba:	c7 04 24 64 75 10 c0 	movl   $0xc0107564,(%esp)
c01038c1:	e8 dc c9 ff ff       	call   c01002a2 <cprintf>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01038c6:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01038cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01038d2:	00 
c01038d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038da:	00 
c01038db:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038de:	89 54 24 04          	mov    %edx,0x4(%esp)
c01038e2:	89 04 24             	mov    %eax,(%esp)
c01038e5:	e8 d7 fd ff ff       	call   c01036c1 <page_insert>
c01038ea:	85 c0                	test   %eax,%eax
c01038ec:	74 24                	je     c0103912 <check_pgdir+0x11d>
c01038ee:	c7 44 24 0c 7c 75 10 	movl   $0xc010757c,0xc(%esp)
c01038f5:	c0 
c01038f6:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c01038fd:	c0 
c01038fe:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0103905:	00 
c0103906:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c010390d:	e8 e7 ca ff ff       	call   c01003f9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103912:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103917:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010391e:	00 
c010391f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103926:	00 
c0103927:	89 04 24             	mov    %eax,(%esp)
c010392a:	e8 59 fb ff ff       	call   c0103488 <get_pte>
c010392f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103936:	75 24                	jne    c010395c <check_pgdir+0x167>
c0103938:	c7 44 24 0c a8 75 10 	movl   $0xc01075a8,0xc(%esp)
c010393f:	c0 
c0103940:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103947:	c0 
c0103948:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c010394f:	00 
c0103950:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103957:	e8 9d ca ff ff       	call   c01003f9 <__panic>
    assert(pte2page(*ptep) == p1);
c010395c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010395f:	8b 00                	mov    (%eax),%eax
c0103961:	89 04 24             	mov    %eax,(%esp)
c0103964:	e8 0c f2 ff ff       	call   c0102b75 <pte2page>
c0103969:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010396c:	74 24                	je     c0103992 <check_pgdir+0x19d>
c010396e:	c7 44 24 0c d5 75 10 	movl   $0xc01075d5,0xc(%esp)
c0103975:	c0 
c0103976:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c010397d:	c0 
c010397e:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103985:	00 
c0103986:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c010398d:	e8 67 ca ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p1) == 1);
c0103992:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103995:	89 04 24             	mov    %eax,(%esp)
c0103998:	e8 2e f2 ff ff       	call   c0102bcb <page_ref>
c010399d:	83 f8 01             	cmp    $0x1,%eax
c01039a0:	74 24                	je     c01039c6 <check_pgdir+0x1d1>
c01039a2:	c7 44 24 0c eb 75 10 	movl   $0xc01075eb,0xc(%esp)
c01039a9:	c0 
c01039aa:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c01039b1:	c0 
c01039b2:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c01039b9:	00 
c01039ba:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01039c1:	e8 33 ca ff ff       	call   c01003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01039c6:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01039cb:	8b 00                	mov    (%eax),%eax
c01039cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01039d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039d8:	c1 e8 0c             	shr    $0xc,%eax
c01039db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01039de:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01039e3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01039e6:	72 23                	jb     c0103a0b <check_pgdir+0x216>
c01039e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01039ef:	c7 44 24 08 a0 73 10 	movl   $0xc01073a0,0x8(%esp)
c01039f6:	c0 
c01039f7:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c01039fe:	00 
c01039ff:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103a06:	e8 ee c9 ff ff       	call   c01003f9 <__panic>
c0103a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103a13:	83 c0 04             	add    $0x4,%eax
c0103a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103a19:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a25:	00 
c0103a26:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a2d:	00 
c0103a2e:	89 04 24             	mov    %eax,(%esp)
c0103a31:	e8 52 fa ff ff       	call   c0103488 <get_pte>
c0103a36:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103a39:	74 24                	je     c0103a5f <check_pgdir+0x26a>
c0103a3b:	c7 44 24 0c 00 76 10 	movl   $0xc0107600,0xc(%esp)
c0103a42:	c0 
c0103a43:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103a4a:	c0 
c0103a4b:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0103a52:	00 
c0103a53:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103a5a:	e8 9a c9 ff ff       	call   c01003f9 <__panic>

    p2 = alloc_page();
c0103a5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a66:	e8 65 f3 ff ff       	call   c0102dd0 <alloc_pages>
c0103a6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("allocate p2 succeed!\n");
c0103a6e:	c7 04 24 27 76 10 c0 	movl   $0xc0107627,(%esp)
c0103a75:	e8 28 c8 ff ff       	call   c01002a2 <cprintf>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103a7a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a7f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103a86:	00 
c0103a87:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103a8e:	00 
c0103a8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103a92:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a96:	89 04 24             	mov    %eax,(%esp)
c0103a99:	e8 23 fc ff ff       	call   c01036c1 <page_insert>
c0103a9e:	85 c0                	test   %eax,%eax
c0103aa0:	74 24                	je     c0103ac6 <check_pgdir+0x2d1>
c0103aa2:	c7 44 24 0c 40 76 10 	movl   $0xc0107640,0xc(%esp)
c0103aa9:	c0 
c0103aaa:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103ab1:	c0 
c0103ab2:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0103ab9:	00 
c0103aba:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103ac1:	e8 33 c9 ff ff       	call   c01003f9 <__panic>
    
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103ac6:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103acb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103ad2:	00 
c0103ad3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103ada:	00 
c0103adb:	89 04 24             	mov    %eax,(%esp)
c0103ade:	e8 a5 f9 ff ff       	call   c0103488 <get_pte>
c0103ae3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ae6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103aea:	75 24                	jne    c0103b10 <check_pgdir+0x31b>
c0103aec:	c7 44 24 0c 78 76 10 	movl   $0xc0107678,0xc(%esp)
c0103af3:	c0 
c0103af4:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103afb:	c0 
c0103afc:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0103b03:	00 
c0103b04:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103b0b:	e8 e9 c8 ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_U);
c0103b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b13:	8b 00                	mov    (%eax),%eax
c0103b15:	83 e0 04             	and    $0x4,%eax
c0103b18:	85 c0                	test   %eax,%eax
c0103b1a:	75 24                	jne    c0103b40 <check_pgdir+0x34b>
c0103b1c:	c7 44 24 0c a8 76 10 	movl   $0xc01076a8,0xc(%esp)
c0103b23:	c0 
c0103b24:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103b2b:	c0 
c0103b2c:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0103b33:	00 
c0103b34:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103b3b:	e8 b9 c8 ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_W);
c0103b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b43:	8b 00                	mov    (%eax),%eax
c0103b45:	83 e0 02             	and    $0x2,%eax
c0103b48:	85 c0                	test   %eax,%eax
c0103b4a:	75 24                	jne    c0103b70 <check_pgdir+0x37b>
c0103b4c:	c7 44 24 0c b6 76 10 	movl   $0xc01076b6,0xc(%esp)
c0103b53:	c0 
c0103b54:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103b5b:	c0 
c0103b5c:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0103b63:	00 
c0103b64:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103b6b:	e8 89 c8 ff ff       	call   c01003f9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103b70:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b75:	8b 00                	mov    (%eax),%eax
c0103b77:	83 e0 04             	and    $0x4,%eax
c0103b7a:	85 c0                	test   %eax,%eax
c0103b7c:	75 24                	jne    c0103ba2 <check_pgdir+0x3ad>
c0103b7e:	c7 44 24 0c c4 76 10 	movl   $0xc01076c4,0xc(%esp)
c0103b85:	c0 
c0103b86:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103b8d:	c0 
c0103b8e:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c0103b95:	00 
c0103b96:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103b9d:	e8 57 c8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 1);
c0103ba2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ba5:	89 04 24             	mov    %eax,(%esp)
c0103ba8:	e8 1e f0 ff ff       	call   c0102bcb <page_ref>
c0103bad:	83 f8 01             	cmp    $0x1,%eax
c0103bb0:	74 24                	je     c0103bd6 <check_pgdir+0x3e1>
c0103bb2:	c7 44 24 0c da 76 10 	movl   $0xc01076da,0xc(%esp)
c0103bb9:	c0 
c0103bba:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103bc1:	c0 
c0103bc2:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c0103bc9:	00 
c0103bca:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103bd1:	e8 23 c8 ff ff       	call   c01003f9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103bd6:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103bdb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103be2:	00 
c0103be3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103bea:	00 
c0103beb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103bee:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103bf2:	89 04 24             	mov    %eax,(%esp)
c0103bf5:	e8 c7 fa ff ff       	call   c01036c1 <page_insert>
c0103bfa:	85 c0                	test   %eax,%eax
c0103bfc:	74 24                	je     c0103c22 <check_pgdir+0x42d>
c0103bfe:	c7 44 24 0c ec 76 10 	movl   $0xc01076ec,0xc(%esp)
c0103c05:	c0 
c0103c06:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103c0d:	c0 
c0103c0e:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c0103c15:	00 
c0103c16:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103c1d:	e8 d7 c7 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p1) == 2);
c0103c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c25:	89 04 24             	mov    %eax,(%esp)
c0103c28:	e8 9e ef ff ff       	call   c0102bcb <page_ref>
c0103c2d:	83 f8 02             	cmp    $0x2,%eax
c0103c30:	74 24                	je     c0103c56 <check_pgdir+0x461>
c0103c32:	c7 44 24 0c 18 77 10 	movl   $0xc0107718,0xc(%esp)
c0103c39:	c0 
c0103c3a:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103c41:	c0 
c0103c42:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c0103c49:	00 
c0103c4a:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103c51:	e8 a3 c7 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c59:	89 04 24             	mov    %eax,(%esp)
c0103c5c:	e8 6a ef ff ff       	call   c0102bcb <page_ref>
c0103c61:	85 c0                	test   %eax,%eax
c0103c63:	74 24                	je     c0103c89 <check_pgdir+0x494>
c0103c65:	c7 44 24 0c 2a 77 10 	movl   $0xc010772a,0xc(%esp)
c0103c6c:	c0 
c0103c6d:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103c74:	c0 
c0103c75:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c0103c7c:	00 
c0103c7d:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103c84:	e8 70 c7 ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103c89:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103c8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c95:	00 
c0103c96:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103c9d:	00 
c0103c9e:	89 04 24             	mov    %eax,(%esp)
c0103ca1:	e8 e2 f7 ff ff       	call   c0103488 <get_pte>
c0103ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ca9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103cad:	75 24                	jne    c0103cd3 <check_pgdir+0x4de>
c0103caf:	c7 44 24 0c 78 76 10 	movl   $0xc0107678,0xc(%esp)
c0103cb6:	c0 
c0103cb7:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103cbe:	c0 
c0103cbf:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c0103cc6:	00 
c0103cc7:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103cce:	e8 26 c7 ff ff       	call   c01003f9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cd6:	8b 00                	mov    (%eax),%eax
c0103cd8:	89 04 24             	mov    %eax,(%esp)
c0103cdb:	e8 95 ee ff ff       	call   c0102b75 <pte2page>
c0103ce0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103ce3:	74 24                	je     c0103d09 <check_pgdir+0x514>
c0103ce5:	c7 44 24 0c d5 75 10 	movl   $0xc01075d5,0xc(%esp)
c0103cec:	c0 
c0103ced:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103cf4:	c0 
c0103cf5:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c0103cfc:	00 
c0103cfd:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103d04:	e8 f0 c6 ff ff       	call   c01003f9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d0c:	8b 00                	mov    (%eax),%eax
c0103d0e:	83 e0 04             	and    $0x4,%eax
c0103d11:	85 c0                	test   %eax,%eax
c0103d13:	74 24                	je     c0103d39 <check_pgdir+0x544>
c0103d15:	c7 44 24 0c 3c 77 10 	movl   $0xc010773c,0xc(%esp)
c0103d1c:	c0 
c0103d1d:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103d24:	c0 
c0103d25:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
c0103d2c:	00 
c0103d2d:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103d34:	e8 c0 c6 ff ff       	call   c01003f9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103d39:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103d3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103d45:	00 
c0103d46:	89 04 24             	mov    %eax,(%esp)
c0103d49:	e8 2e f9 ff ff       	call   c010367c <page_remove>
    assert(page_ref(p1) == 1);
c0103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d51:	89 04 24             	mov    %eax,(%esp)
c0103d54:	e8 72 ee ff ff       	call   c0102bcb <page_ref>
c0103d59:	83 f8 01             	cmp    $0x1,%eax
c0103d5c:	74 24                	je     c0103d82 <check_pgdir+0x58d>
c0103d5e:	c7 44 24 0c eb 75 10 	movl   $0xc01075eb,0xc(%esp)
c0103d65:	c0 
c0103d66:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103d6d:	c0 
c0103d6e:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c0103d75:	00 
c0103d76:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103d7d:	e8 77 c6 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d85:	89 04 24             	mov    %eax,(%esp)
c0103d88:	e8 3e ee ff ff       	call   c0102bcb <page_ref>
c0103d8d:	85 c0                	test   %eax,%eax
c0103d8f:	74 24                	je     c0103db5 <check_pgdir+0x5c0>
c0103d91:	c7 44 24 0c 2a 77 10 	movl   $0xc010772a,0xc(%esp)
c0103d98:	c0 
c0103d99:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103da0:	c0 
c0103da1:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c0103da8:	00 
c0103da9:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103db0:	e8 44 c6 ff ff       	call   c01003f9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103db5:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103dba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103dc1:	00 
c0103dc2:	89 04 24             	mov    %eax,(%esp)
c0103dc5:	e8 b2 f8 ff ff       	call   c010367c <page_remove>
    assert(page_ref(p1) == 0);
c0103dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dcd:	89 04 24             	mov    %eax,(%esp)
c0103dd0:	e8 f6 ed ff ff       	call   c0102bcb <page_ref>
c0103dd5:	85 c0                	test   %eax,%eax
c0103dd7:	74 24                	je     c0103dfd <check_pgdir+0x608>
c0103dd9:	c7 44 24 0c 51 77 10 	movl   $0xc0107751,0xc(%esp)
c0103de0:	c0 
c0103de1:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103de8:	c0 
c0103de9:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0103df0:	00 
c0103df1:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103df8:	e8 fc c5 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103dfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e00:	89 04 24             	mov    %eax,(%esp)
c0103e03:	e8 c3 ed ff ff       	call   c0102bcb <page_ref>
c0103e08:	85 c0                	test   %eax,%eax
c0103e0a:	74 24                	je     c0103e30 <check_pgdir+0x63b>
c0103e0c:	c7 44 24 0c 2a 77 10 	movl   $0xc010772a,0xc(%esp)
c0103e13:	c0 
c0103e14:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103e1b:	c0 
c0103e1c:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0103e23:	00 
c0103e24:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103e2b:	e8 c9 c5 ff ff       	call   c01003f9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103e30:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e35:	8b 00                	mov    (%eax),%eax
c0103e37:	89 04 24             	mov    %eax,(%esp)
c0103e3a:	e8 74 ed ff ff       	call   c0102bb3 <pde2page>
c0103e3f:	89 04 24             	mov    %eax,(%esp)
c0103e42:	e8 84 ed ff ff       	call   c0102bcb <page_ref>
c0103e47:	83 f8 01             	cmp    $0x1,%eax
c0103e4a:	74 24                	je     c0103e70 <check_pgdir+0x67b>
c0103e4c:	c7 44 24 0c 64 77 10 	movl   $0xc0107764,0xc(%esp)
c0103e53:	c0 
c0103e54:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103e5b:	c0 
c0103e5c:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c0103e63:	00 
c0103e64:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103e6b:	e8 89 c5 ff ff       	call   c01003f9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103e70:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e75:	8b 00                	mov    (%eax),%eax
c0103e77:	89 04 24             	mov    %eax,(%esp)
c0103e7a:	e8 34 ed ff ff       	call   c0102bb3 <pde2page>
c0103e7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e86:	00 
c0103e87:	89 04 24             	mov    %eax,(%esp)
c0103e8a:	e8 79 ef ff ff       	call   c0102e08 <free_pages>
    boot_pgdir[0] = 0;
c0103e8f:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103e9a:	c7 04 24 8b 77 10 c0 	movl   $0xc010778b,(%esp)
c0103ea1:	e8 fc c3 ff ff       	call   c01002a2 <cprintf>
}
c0103ea6:	90                   	nop
c0103ea7:	c9                   	leave  
c0103ea8:	c3                   	ret    

c0103ea9 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103ea9:	55                   	push   %ebp
c0103eaa:	89 e5                	mov    %esp,%ebp
c0103eac:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103eaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103eb6:	e9 ca 00 00 00       	jmp    c0103f85 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ebe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ec1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ec4:	c1 e8 0c             	shr    $0xc,%eax
c0103ec7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103eca:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103ecf:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103ed2:	72 23                	jb     c0103ef7 <check_boot_pgdir+0x4e>
c0103ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103edb:	c7 44 24 08 a0 73 10 	movl   $0xc01073a0,0x8(%esp)
c0103ee2:	c0 
c0103ee3:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c0103eea:	00 
c0103eeb:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103ef2:	e8 02 c5 ff ff       	call   c01003f9 <__panic>
c0103ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103efa:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103eff:	89 c2                	mov    %eax,%edx
c0103f01:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103f06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103f0d:	00 
c0103f0e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f12:	89 04 24             	mov    %eax,(%esp)
c0103f15:	e8 6e f5 ff ff       	call   c0103488 <get_pte>
c0103f1a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103f1d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103f21:	75 24                	jne    c0103f47 <check_boot_pgdir+0x9e>
c0103f23:	c7 44 24 0c a8 77 10 	movl   $0xc01077a8,0xc(%esp)
c0103f2a:	c0 
c0103f2b:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103f32:	c0 
c0103f33:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c0103f3a:	00 
c0103f3b:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103f42:	e8 b2 c4 ff ff       	call   c01003f9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103f47:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103f4a:	8b 00                	mov    (%eax),%eax
c0103f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103f51:	89 c2                	mov    %eax,%edx
c0103f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f56:	39 c2                	cmp    %eax,%edx
c0103f58:	74 24                	je     c0103f7e <check_boot_pgdir+0xd5>
c0103f5a:	c7 44 24 0c e5 77 10 	movl   $0xc01077e5,0xc(%esp)
c0103f61:	c0 
c0103f62:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103f69:	c0 
c0103f6a:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
c0103f71:	00 
c0103f72:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103f79:	e8 7b c4 ff ff       	call   c01003f9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103f7e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103f85:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f88:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103f8d:	39 c2                	cmp    %eax,%edx
c0103f8f:	0f 82 26 ff ff ff    	jb     c0103ebb <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103f95:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103f9a:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103f9f:	8b 00                	mov    (%eax),%eax
c0103fa1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103fa6:	89 c2                	mov    %eax,%edx
c0103fa8:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103fad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fb0:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103fb7:	77 23                	ja     c0103fdc <check_boot_pgdir+0x133>
c0103fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103fc0:	c7 44 24 08 44 74 10 	movl   $0xc0107444,0x8(%esp)
c0103fc7:	c0 
c0103fc8:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
c0103fcf:	00 
c0103fd0:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0103fd7:	e8 1d c4 ff ff       	call   c01003f9 <__panic>
c0103fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fdf:	05 00 00 00 40       	add    $0x40000000,%eax
c0103fe4:	39 d0                	cmp    %edx,%eax
c0103fe6:	74 24                	je     c010400c <check_boot_pgdir+0x163>
c0103fe8:	c7 44 24 0c fc 77 10 	movl   $0xc01077fc,0xc(%esp)
c0103fef:	c0 
c0103ff0:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0103ff7:	c0 
c0103ff8:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
c0103fff:	00 
c0104000:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0104007:	e8 ed c3 ff ff       	call   c01003f9 <__panic>

    assert(boot_pgdir[0] == 0);
c010400c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0104011:	8b 00                	mov    (%eax),%eax
c0104013:	85 c0                	test   %eax,%eax
c0104015:	74 24                	je     c010403b <check_boot_pgdir+0x192>
c0104017:	c7 44 24 0c 30 78 10 	movl   $0xc0107830,0xc(%esp)
c010401e:	c0 
c010401f:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0104026:	c0 
c0104027:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
c010402e:	00 
c010402f:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0104036:	e8 be c3 ff ff       	call   c01003f9 <__panic>

    struct Page *p;
    p = alloc_page();
c010403b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104042:	e8 89 ed ff ff       	call   c0102dd0 <alloc_pages>
c0104047:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010404a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010404f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104056:	00 
c0104057:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010405e:	00 
c010405f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104062:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104066:	89 04 24             	mov    %eax,(%esp)
c0104069:	e8 53 f6 ff ff       	call   c01036c1 <page_insert>
c010406e:	85 c0                	test   %eax,%eax
c0104070:	74 24                	je     c0104096 <check_boot_pgdir+0x1ed>
c0104072:	c7 44 24 0c 44 78 10 	movl   $0xc0107844,0xc(%esp)
c0104079:	c0 
c010407a:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0104081:	c0 
c0104082:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
c0104089:	00 
c010408a:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0104091:	e8 63 c3 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p) == 1);
c0104096:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104099:	89 04 24             	mov    %eax,(%esp)
c010409c:	e8 2a eb ff ff       	call   c0102bcb <page_ref>
c01040a1:	83 f8 01             	cmp    $0x1,%eax
c01040a4:	74 24                	je     c01040ca <check_boot_pgdir+0x221>
c01040a6:	c7 44 24 0c 72 78 10 	movl   $0xc0107872,0xc(%esp)
c01040ad:	c0 
c01040ae:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c01040b5:	c0 
c01040b6:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
c01040bd:	00 
c01040be:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01040c5:	e8 2f c3 ff ff       	call   c01003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01040ca:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01040cf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01040d6:	00 
c01040d7:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01040de:	00 
c01040df:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01040e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01040e6:	89 04 24             	mov    %eax,(%esp)
c01040e9:	e8 d3 f5 ff ff       	call   c01036c1 <page_insert>
c01040ee:	85 c0                	test   %eax,%eax
c01040f0:	74 24                	je     c0104116 <check_boot_pgdir+0x26d>
c01040f2:	c7 44 24 0c 84 78 10 	movl   $0xc0107884,0xc(%esp)
c01040f9:	c0 
c01040fa:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0104101:	c0 
c0104102:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
c0104109:	00 
c010410a:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0104111:	e8 e3 c2 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p) == 2);
c0104116:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104119:	89 04 24             	mov    %eax,(%esp)
c010411c:	e8 aa ea ff ff       	call   c0102bcb <page_ref>
c0104121:	83 f8 02             	cmp    $0x2,%eax
c0104124:	74 24                	je     c010414a <check_boot_pgdir+0x2a1>
c0104126:	c7 44 24 0c bb 78 10 	movl   $0xc01078bb,0xc(%esp)
c010412d:	c0 
c010412e:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c0104135:	c0 
c0104136:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
c010413d:	00 
c010413e:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c0104145:	e8 af c2 ff ff       	call   c01003f9 <__panic>

    const char *str = "ucore: Hello world!!";
c010414a:	c7 45 e8 cc 78 10 c0 	movl   $0xc01078cc,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0104151:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104154:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104158:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010415f:	e8 e9 1f 00 00       	call   c010614d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104164:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010416b:	00 
c010416c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104173:	e8 4c 20 00 00       	call   c01061c4 <strcmp>
c0104178:	85 c0                	test   %eax,%eax
c010417a:	74 24                	je     c01041a0 <check_boot_pgdir+0x2f7>
c010417c:	c7 44 24 0c e4 78 10 	movl   $0xc01078e4,0xc(%esp)
c0104183:	c0 
c0104184:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c010418b:	c0 
c010418c:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c0104193:	00 
c0104194:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c010419b:	e8 59 c2 ff ff       	call   c01003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01041a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041a3:	89 04 24             	mov    %eax,(%esp)
c01041a6:	e8 76 e9 ff ff       	call   c0102b21 <page2kva>
c01041ab:	05 00 01 00 00       	add    $0x100,%eax
c01041b0:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01041b3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01041ba:	e8 38 1f 00 00       	call   c01060f7 <strlen>
c01041bf:	85 c0                	test   %eax,%eax
c01041c1:	74 24                	je     c01041e7 <check_boot_pgdir+0x33e>
c01041c3:	c7 44 24 0c 1c 79 10 	movl   $0xc010791c,0xc(%esp)
c01041ca:	c0 
c01041cb:	c7 44 24 08 8d 74 10 	movl   $0xc010748d,0x8(%esp)
c01041d2:	c0 
c01041d3:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
c01041da:	00 
c01041db:	c7 04 24 68 74 10 c0 	movl   $0xc0107468,(%esp)
c01041e2:	e8 12 c2 ff ff       	call   c01003f9 <__panic>

    free_page(p);
c01041e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041ee:	00 
c01041ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041f2:	89 04 24             	mov    %eax,(%esp)
c01041f5:	e8 0e ec ff ff       	call   c0102e08 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01041fa:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01041ff:	8b 00                	mov    (%eax),%eax
c0104201:	89 04 24             	mov    %eax,(%esp)
c0104204:	e8 aa e9 ff ff       	call   c0102bb3 <pde2page>
c0104209:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104210:	00 
c0104211:	89 04 24             	mov    %eax,(%esp)
c0104214:	e8 ef eb ff ff       	call   c0102e08 <free_pages>
    boot_pgdir[0] = 0;
c0104219:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010421e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104224:	c7 04 24 40 79 10 c0 	movl   $0xc0107940,(%esp)
c010422b:	e8 72 c0 ff ff       	call   c01002a2 <cprintf>
}
c0104230:	90                   	nop
c0104231:	c9                   	leave  
c0104232:	c3                   	ret    

c0104233 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104233:	55                   	push   %ebp
c0104234:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0104236:	8b 45 08             	mov    0x8(%ebp),%eax
c0104239:	83 e0 04             	and    $0x4,%eax
c010423c:	85 c0                	test   %eax,%eax
c010423e:	74 04                	je     c0104244 <perm2str+0x11>
c0104240:	b0 75                	mov    $0x75,%al
c0104242:	eb 02                	jmp    c0104246 <perm2str+0x13>
c0104244:	b0 2d                	mov    $0x2d,%al
c0104246:	a2 08 df 11 c0       	mov    %al,0xc011df08
    str[1] = 'r';
c010424b:	c6 05 09 df 11 c0 72 	movb   $0x72,0xc011df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104252:	8b 45 08             	mov    0x8(%ebp),%eax
c0104255:	83 e0 02             	and    $0x2,%eax
c0104258:	85 c0                	test   %eax,%eax
c010425a:	74 04                	je     c0104260 <perm2str+0x2d>
c010425c:	b0 77                	mov    $0x77,%al
c010425e:	eb 02                	jmp    c0104262 <perm2str+0x2f>
c0104260:	b0 2d                	mov    $0x2d,%al
c0104262:	a2 0a df 11 c0       	mov    %al,0xc011df0a
    str[3] = '\0';
c0104267:	c6 05 0b df 11 c0 00 	movb   $0x0,0xc011df0b
    return str;
c010426e:	b8 08 df 11 c0       	mov    $0xc011df08,%eax
}
c0104273:	5d                   	pop    %ebp
c0104274:	c3                   	ret    

c0104275 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0104275:	55                   	push   %ebp
c0104276:	89 e5                	mov    %esp,%ebp
c0104278:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010427b:	8b 45 10             	mov    0x10(%ebp),%eax
c010427e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104281:	72 0d                	jb     c0104290 <get_pgtable_items+0x1b>
        return 0;
c0104283:	b8 00 00 00 00       	mov    $0x0,%eax
c0104288:	e9 98 00 00 00       	jmp    c0104325 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c010428d:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0104290:	8b 45 10             	mov    0x10(%ebp),%eax
c0104293:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104296:	73 18                	jae    c01042b0 <get_pgtable_items+0x3b>
c0104298:	8b 45 10             	mov    0x10(%ebp),%eax
c010429b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01042a2:	8b 45 14             	mov    0x14(%ebp),%eax
c01042a5:	01 d0                	add    %edx,%eax
c01042a7:	8b 00                	mov    (%eax),%eax
c01042a9:	83 e0 01             	and    $0x1,%eax
c01042ac:	85 c0                	test   %eax,%eax
c01042ae:	74 dd                	je     c010428d <get_pgtable_items+0x18>
    }
    if (start < right) {
c01042b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01042b3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01042b6:	73 68                	jae    c0104320 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01042b8:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01042bc:	74 08                	je     c01042c6 <get_pgtable_items+0x51>
            *left_store = start;
c01042be:	8b 45 18             	mov    0x18(%ebp),%eax
c01042c1:	8b 55 10             	mov    0x10(%ebp),%edx
c01042c4:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01042c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01042c9:	8d 50 01             	lea    0x1(%eax),%edx
c01042cc:	89 55 10             	mov    %edx,0x10(%ebp)
c01042cf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01042d6:	8b 45 14             	mov    0x14(%ebp),%eax
c01042d9:	01 d0                	add    %edx,%eax
c01042db:	8b 00                	mov    (%eax),%eax
c01042dd:	83 e0 07             	and    $0x7,%eax
c01042e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01042e3:	eb 03                	jmp    c01042e8 <get_pgtable_items+0x73>
            start ++;
c01042e5:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01042e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01042eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01042ee:	73 1d                	jae    c010430d <get_pgtable_items+0x98>
c01042f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01042f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01042fa:	8b 45 14             	mov    0x14(%ebp),%eax
c01042fd:	01 d0                	add    %edx,%eax
c01042ff:	8b 00                	mov    (%eax),%eax
c0104301:	83 e0 07             	and    $0x7,%eax
c0104304:	89 c2                	mov    %eax,%edx
c0104306:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104309:	39 c2                	cmp    %eax,%edx
c010430b:	74 d8                	je     c01042e5 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c010430d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104311:	74 08                	je     c010431b <get_pgtable_items+0xa6>
            *right_store = start;
c0104313:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104316:	8b 55 10             	mov    0x10(%ebp),%edx
c0104319:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010431b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010431e:	eb 05                	jmp    c0104325 <get_pgtable_items+0xb0>
    }
    return 0;
c0104320:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104325:	c9                   	leave  
c0104326:	c3                   	ret    

c0104327 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0104327:	55                   	push   %ebp
c0104328:	89 e5                	mov    %esp,%ebp
c010432a:	57                   	push   %edi
c010432b:	56                   	push   %esi
c010432c:	53                   	push   %ebx
c010432d:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104330:	c7 04 24 60 79 10 c0 	movl   $0xc0107960,(%esp)
c0104337:	e8 66 bf ff ff       	call   c01002a2 <cprintf>
    size_t left, right = 0, perm;
c010433c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104343:	e9 fa 00 00 00       	jmp    c0104442 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010434b:	89 04 24             	mov    %eax,(%esp)
c010434e:	e8 e0 fe ff ff       	call   c0104233 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104353:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104356:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104359:	29 d1                	sub    %edx,%ecx
c010435b:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010435d:	89 d6                	mov    %edx,%esi
c010435f:	c1 e6 16             	shl    $0x16,%esi
c0104362:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104365:	89 d3                	mov    %edx,%ebx
c0104367:	c1 e3 16             	shl    $0x16,%ebx
c010436a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010436d:	89 d1                	mov    %edx,%ecx
c010436f:	c1 e1 16             	shl    $0x16,%ecx
c0104372:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104375:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104378:	29 d7                	sub    %edx,%edi
c010437a:	89 fa                	mov    %edi,%edx
c010437c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104380:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104384:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010438c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104390:	c7 04 24 91 79 10 c0 	movl   $0xc0107991,(%esp)
c0104397:	e8 06 bf ff ff       	call   c01002a2 <cprintf>
        size_t l, r = left * NPTEENTRY;
c010439c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010439f:	c1 e0 0a             	shl    $0xa,%eax
c01043a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01043a5:	eb 54                	jmp    c01043fb <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01043a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043aa:	89 04 24             	mov    %eax,(%esp)
c01043ad:	e8 81 fe ff ff       	call   c0104233 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01043b2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01043b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043b8:	29 d1                	sub    %edx,%ecx
c01043ba:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01043bc:	89 d6                	mov    %edx,%esi
c01043be:	c1 e6 0c             	shl    $0xc,%esi
c01043c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043c4:	89 d3                	mov    %edx,%ebx
c01043c6:	c1 e3 0c             	shl    $0xc,%ebx
c01043c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043cc:	89 d1                	mov    %edx,%ecx
c01043ce:	c1 e1 0c             	shl    $0xc,%ecx
c01043d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01043d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043d7:	29 d7                	sub    %edx,%edi
c01043d9:	89 fa                	mov    %edi,%edx
c01043db:	89 44 24 14          	mov    %eax,0x14(%esp)
c01043df:	89 74 24 10          	mov    %esi,0x10(%esp)
c01043e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01043e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01043eb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01043ef:	c7 04 24 b0 79 10 c0 	movl   $0xc01079b0,(%esp)
c01043f6:	e8 a7 be ff ff       	call   c01002a2 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01043fb:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104400:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104403:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104406:	89 d3                	mov    %edx,%ebx
c0104408:	c1 e3 0a             	shl    $0xa,%ebx
c010440b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010440e:	89 d1                	mov    %edx,%ecx
c0104410:	c1 e1 0a             	shl    $0xa,%ecx
c0104413:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104416:	89 54 24 14          	mov    %edx,0x14(%esp)
c010441a:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010441d:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104421:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104425:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104429:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010442d:	89 0c 24             	mov    %ecx,(%esp)
c0104430:	e8 40 fe ff ff       	call   c0104275 <get_pgtable_items>
c0104435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104438:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010443c:	0f 85 65 ff ff ff    	jne    c01043a7 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104442:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104447:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010444a:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010444d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104451:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104454:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104458:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010445c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104460:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104467:	00 
c0104468:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010446f:	e8 01 fe ff ff       	call   c0104275 <get_pgtable_items>
c0104474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104477:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010447b:	0f 85 c7 fe ff ff    	jne    c0104348 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104481:	c7 04 24 d4 79 10 c0 	movl   $0xc01079d4,(%esp)
c0104488:	e8 15 be ff ff       	call   c01002a2 <cprintf>
}
c010448d:	90                   	nop
c010448e:	83 c4 4c             	add    $0x4c,%esp
c0104491:	5b                   	pop    %ebx
c0104492:	5e                   	pop    %esi
c0104493:	5f                   	pop    %edi
c0104494:	5d                   	pop    %ebp
c0104495:	c3                   	ret    

c0104496 <page_ref>:
page_ref(struct Page *page) {
c0104496:	55                   	push   %ebp
c0104497:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104499:	8b 45 08             	mov    0x8(%ebp),%eax
c010449c:	8b 00                	mov    (%eax),%eax
}
c010449e:	5d                   	pop    %ebp
c010449f:	c3                   	ret    

c01044a0 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01044a0:	55                   	push   %ebp
c01044a1:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01044a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01044a6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044a9:	89 10                	mov    %edx,(%eax)
}
c01044ab:	90                   	nop
c01044ac:	5d                   	pop    %ebp
c01044ad:	c3                   	ret    

c01044ae <fixsize>:
#define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//大于a的一个最小的2^k
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))//小于a的最大的2^k

static unsigned fixsize(unsigned size) {
c01044ae:	55                   	push   %ebp
c01044af:	89 e5                	mov    %esp,%ebp
  size |= size >> 1;
c01044b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01044b4:	d1 e8                	shr    %eax
c01044b6:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 2;
c01044b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01044bc:	c1 e8 02             	shr    $0x2,%eax
c01044bf:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 4;
c01044c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01044c5:	c1 e8 04             	shr    $0x4,%eax
c01044c8:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 8;
c01044cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01044ce:	c1 e8 08             	shr    $0x8,%eax
c01044d1:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 16;
c01044d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01044d7:	c1 e8 10             	shr    $0x10,%eax
c01044da:	09 45 08             	or     %eax,0x8(%ebp)
  return size+1;
c01044dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01044e0:	40                   	inc    %eax
}
c01044e1:	5d                   	pop    %ebp
c01044e2:	c3                   	ret    

c01044e3 <buddy_init>:

struct allocRecord rec[40000];//存放偏移量的数组
int nr_block;//已分配的块数

static void buddy_init()
{
c01044e3:	55                   	push   %ebp
c01044e4:	89 e5                	mov    %esp,%ebp
c01044e6:	83 ec 10             	sub    $0x10,%esp
c01044e9:	c7 45 fc 40 c1 16 c0 	movl   $0xc016c140,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01044f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01044f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01044f6:	89 50 04             	mov    %edx,0x4(%eax)
c01044f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01044fc:	8b 50 04             	mov    0x4(%eax),%edx
c01044ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104502:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free=0;
c0104504:	c7 05 48 c1 16 c0 00 	movl   $0x0,0xc016c148
c010450b:	00 00 00 
}
c010450e:	90                   	nop
c010450f:	c9                   	leave  
c0104510:	c3                   	ret    

c0104511 <buddy2_new>:

//初始化二叉树上的节点
void buddy2_new( int size ) {
c0104511:	55                   	push   %ebp
c0104512:	89 e5                	mov    %esp,%ebp
c0104514:	83 ec 10             	sub    $0x10,%esp
  unsigned node_size;
  int i;
  nr_block=0;
c0104517:	c7 05 20 df 11 c0 00 	movl   $0x0,0xc011df20
c010451e:	00 00 00 
  if (size < 1 || !IS_POWER_OF_2(size))
c0104521:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104525:	7e 55                	jle    c010457c <buddy2_new+0x6b>
c0104527:	8b 45 08             	mov    0x8(%ebp),%eax
c010452a:	48                   	dec    %eax
c010452b:	23 45 08             	and    0x8(%ebp),%eax
c010452e:	85 c0                	test   %eax,%eax
c0104530:	75 4a                	jne    c010457c <buddy2_new+0x6b>
    return;

  root[0].size = size;
c0104532:	8b 45 08             	mov    0x8(%ebp),%eax
c0104535:	a3 40 df 11 c0       	mov    %eax,0xc011df40
  node_size = size * 2;
c010453a:	8b 45 08             	mov    0x8(%ebp),%eax
c010453d:	01 c0                	add    %eax,%eax
c010453f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  for (i = 0; i < 2 * size - 1; ++i) {
c0104542:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
c0104549:	eb 23                	jmp    c010456e <buddy2_new+0x5d>
    if (IS_POWER_OF_2(i+1))
c010454b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010454e:	40                   	inc    %eax
c010454f:	23 45 f8             	and    -0x8(%ebp),%eax
c0104552:	85 c0                	test   %eax,%eax
c0104554:	75 08                	jne    c010455e <buddy2_new+0x4d>
      node_size /= 2;
c0104556:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104559:	d1 e8                	shr    %eax
c010455b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    root[i].longest = node_size;
c010455e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104561:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104564:	89 14 c5 44 df 11 c0 	mov    %edx,-0x3fee20bc(,%eax,8)
  for (i = 0; i < 2 * size - 1; ++i) {
c010456b:	ff 45 f8             	incl   -0x8(%ebp)
c010456e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104571:	01 c0                	add    %eax,%eax
c0104573:	48                   	dec    %eax
c0104574:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c0104577:	7c d2                	jl     c010454b <buddy2_new+0x3a>
  }
  return;
c0104579:	90                   	nop
c010457a:	eb 01                	jmp    c010457d <buddy2_new+0x6c>
    return;
c010457c:	90                   	nop
}
c010457d:	c9                   	leave  
c010457e:	c3                   	ret    

c010457f <buddy_init_memmap>:

//初始化内存映射关系
static void
buddy_init_memmap(struct Page *base, size_t n)
{
c010457f:	55                   	push   %ebp
c0104580:	89 e5                	mov    %esp,%ebp
c0104582:	56                   	push   %esi
c0104583:	53                   	push   %ebx
c0104584:	83 ec 40             	sub    $0x40,%esp
    assert(n>0);
c0104587:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010458b:	75 24                	jne    c01045b1 <buddy_init_memmap+0x32>
c010458d:	c7 44 24 0c 08 7a 10 	movl   $0xc0107a08,0xc(%esp)
c0104594:	c0 
c0104595:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c010459c:	c0 
c010459d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
c01045a4:	00 
c01045a5:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c01045ac:	e8 48 be ff ff       	call   c01003f9 <__panic>
    struct Page* p=base;
c01045b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(;p!=base + n;p++)
c01045b7:	e9 dc 00 00 00       	jmp    c0104698 <buddy_init_memmap+0x119>
    {
        assert(PageReserved(p));
c01045bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045bf:	83 c0 04             	add    $0x4,%eax
c01045c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01045c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01045d2:	0f a3 10             	bt     %edx,(%eax)
c01045d5:	19 c0                	sbb    %eax,%eax
c01045d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01045da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01045de:	0f 95 c0             	setne  %al
c01045e1:	0f b6 c0             	movzbl %al,%eax
c01045e4:	85 c0                	test   %eax,%eax
c01045e6:	75 24                	jne    c010460c <buddy_init_memmap+0x8d>
c01045e8:	c7 44 24 0c 31 7a 10 	movl   $0xc0107a31,0xc(%esp)
c01045ef:	c0 
c01045f0:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c01045f7:	c0 
c01045f8:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c01045ff:	00 
c0104600:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0104607:	e8 ed bd ff ff       	call   c01003f9 <__panic>
        p->flags = 0;
c010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010460f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        p->property = 1;
c0104616:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104619:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
        set_page_ref(p, 0);   
c0104620:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104627:	00 
c0104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462b:	89 04 24             	mov    %eax,(%esp)
c010462e:	e8 6d fe ff ff       	call   c01044a0 <set_page_ref>
        SetPageProperty(p);
c0104633:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104636:	83 c0 04             	add    $0x4,%eax
c0104639:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0104640:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104643:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104646:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104649:	0f ab 10             	bts    %edx,(%eax)
        list_add_before(&free_list,&(p->page_link));     
c010464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464f:	83 c0 0c             	add    $0xc,%eax
c0104652:	c7 45 e0 40 c1 16 c0 	movl   $0xc016c140,-0x20(%ebp)
c0104659:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010465c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010465f:	8b 00                	mov    (%eax),%eax
c0104661:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104664:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104667:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010466a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010466d:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104670:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104673:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104676:	89 10                	mov    %edx,(%eax)
c0104678:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010467b:	8b 10                	mov    (%eax),%edx
c010467d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104680:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104683:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104686:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104689:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010468c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010468f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104692:	89 10                	mov    %edx,(%eax)
    for(;p!=base + n;p++)
c0104694:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104698:	8b 55 0c             	mov    0xc(%ebp),%edx
c010469b:	89 d0                	mov    %edx,%eax
c010469d:	c1 e0 02             	shl    $0x2,%eax
c01046a0:	01 d0                	add    %edx,%eax
c01046a2:	c1 e0 02             	shl    $0x2,%eax
c01046a5:	89 c2                	mov    %eax,%edx
c01046a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01046aa:	01 d0                	add    %edx,%eax
c01046ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01046af:	0f 85 07 ff ff ff    	jne    c01045bc <buddy_init_memmap+0x3d>
    }
    nr_free += n;
c01046b5:	8b 15 48 c1 16 c0    	mov    0xc016c148,%edx
c01046bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046be:	01 d0                	add    %edx,%eax
c01046c0:	a3 48 c1 16 c0       	mov    %eax,0xc016c148
    int allocpages=UINT32_ROUND_DOWN(n);
c01046c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046c8:	d1 e8                	shr    %eax
c01046ca:	0b 45 0c             	or     0xc(%ebp),%eax
c01046cd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046d0:	d1 ea                	shr    %edx
c01046d2:	0b 55 0c             	or     0xc(%ebp),%edx
c01046d5:	c1 ea 02             	shr    $0x2,%edx
c01046d8:	09 d0                	or     %edx,%eax
c01046da:	89 c1                	mov    %eax,%ecx
c01046dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046df:	d1 e8                	shr    %eax
c01046e1:	0b 45 0c             	or     0xc(%ebp),%eax
c01046e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046e7:	d1 ea                	shr    %edx
c01046e9:	0b 55 0c             	or     0xc(%ebp),%edx
c01046ec:	c1 ea 02             	shr    $0x2,%edx
c01046ef:	09 d0                	or     %edx,%eax
c01046f1:	c1 e8 04             	shr    $0x4,%eax
c01046f4:	09 c1                	or     %eax,%ecx
c01046f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046f9:	d1 e8                	shr    %eax
c01046fb:	0b 45 0c             	or     0xc(%ebp),%eax
c01046fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104701:	d1 ea                	shr    %edx
c0104703:	0b 55 0c             	or     0xc(%ebp),%edx
c0104706:	c1 ea 02             	shr    $0x2,%edx
c0104709:	09 d0                	or     %edx,%eax
c010470b:	89 c3                	mov    %eax,%ebx
c010470d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104710:	d1 e8                	shr    %eax
c0104712:	0b 45 0c             	or     0xc(%ebp),%eax
c0104715:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104718:	d1 ea                	shr    %edx
c010471a:	0b 55 0c             	or     0xc(%ebp),%edx
c010471d:	c1 ea 02             	shr    $0x2,%edx
c0104720:	09 d0                	or     %edx,%eax
c0104722:	c1 e8 04             	shr    $0x4,%eax
c0104725:	09 d8                	or     %ebx,%eax
c0104727:	c1 e8 08             	shr    $0x8,%eax
c010472a:	09 c1                	or     %eax,%ecx
c010472c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010472f:	d1 e8                	shr    %eax
c0104731:	0b 45 0c             	or     0xc(%ebp),%eax
c0104734:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104737:	d1 ea                	shr    %edx
c0104739:	0b 55 0c             	or     0xc(%ebp),%edx
c010473c:	c1 ea 02             	shr    $0x2,%edx
c010473f:	09 d0                	or     %edx,%eax
c0104741:	89 c3                	mov    %eax,%ebx
c0104743:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104746:	d1 e8                	shr    %eax
c0104748:	0b 45 0c             	or     0xc(%ebp),%eax
c010474b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010474e:	d1 ea                	shr    %edx
c0104750:	0b 55 0c             	or     0xc(%ebp),%edx
c0104753:	c1 ea 02             	shr    $0x2,%edx
c0104756:	09 d0                	or     %edx,%eax
c0104758:	c1 e8 04             	shr    $0x4,%eax
c010475b:	09 c3                	or     %eax,%ebx
c010475d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104760:	d1 e8                	shr    %eax
c0104762:	0b 45 0c             	or     0xc(%ebp),%eax
c0104765:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104768:	d1 ea                	shr    %edx
c010476a:	0b 55 0c             	or     0xc(%ebp),%edx
c010476d:	c1 ea 02             	shr    $0x2,%edx
c0104770:	09 d0                	or     %edx,%eax
c0104772:	89 c6                	mov    %eax,%esi
c0104774:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104777:	d1 e8                	shr    %eax
c0104779:	0b 45 0c             	or     0xc(%ebp),%eax
c010477c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010477f:	d1 ea                	shr    %edx
c0104781:	0b 55 0c             	or     0xc(%ebp),%edx
c0104784:	c1 ea 02             	shr    $0x2,%edx
c0104787:	09 d0                	or     %edx,%eax
c0104789:	c1 e8 04             	shr    $0x4,%eax
c010478c:	09 f0                	or     %esi,%eax
c010478e:	c1 e8 08             	shr    $0x8,%eax
c0104791:	09 d8                	or     %ebx,%eax
c0104793:	c1 e8 10             	shr    $0x10,%eax
c0104796:	09 c8                	or     %ecx,%eax
c0104798:	d1 e8                	shr    %eax
c010479a:	23 45 0c             	and    0xc(%ebp),%eax
c010479d:	85 c0                	test   %eax,%eax
c010479f:	0f 84 dc 00 00 00    	je     c0104881 <buddy_init_memmap+0x302>
c01047a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047a8:	d1 e8                	shr    %eax
c01047aa:	0b 45 0c             	or     0xc(%ebp),%eax
c01047ad:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047b0:	d1 ea                	shr    %edx
c01047b2:	0b 55 0c             	or     0xc(%ebp),%edx
c01047b5:	c1 ea 02             	shr    $0x2,%edx
c01047b8:	09 d0                	or     %edx,%eax
c01047ba:	89 c1                	mov    %eax,%ecx
c01047bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047bf:	d1 e8                	shr    %eax
c01047c1:	0b 45 0c             	or     0xc(%ebp),%eax
c01047c4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047c7:	d1 ea                	shr    %edx
c01047c9:	0b 55 0c             	or     0xc(%ebp),%edx
c01047cc:	c1 ea 02             	shr    $0x2,%edx
c01047cf:	09 d0                	or     %edx,%eax
c01047d1:	c1 e8 04             	shr    $0x4,%eax
c01047d4:	09 c1                	or     %eax,%ecx
c01047d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047d9:	d1 e8                	shr    %eax
c01047db:	0b 45 0c             	or     0xc(%ebp),%eax
c01047de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047e1:	d1 ea                	shr    %edx
c01047e3:	0b 55 0c             	or     0xc(%ebp),%edx
c01047e6:	c1 ea 02             	shr    $0x2,%edx
c01047e9:	09 d0                	or     %edx,%eax
c01047eb:	89 c3                	mov    %eax,%ebx
c01047ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047f0:	d1 e8                	shr    %eax
c01047f2:	0b 45 0c             	or     0xc(%ebp),%eax
c01047f5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047f8:	d1 ea                	shr    %edx
c01047fa:	0b 55 0c             	or     0xc(%ebp),%edx
c01047fd:	c1 ea 02             	shr    $0x2,%edx
c0104800:	09 d0                	or     %edx,%eax
c0104802:	c1 e8 04             	shr    $0x4,%eax
c0104805:	09 d8                	or     %ebx,%eax
c0104807:	c1 e8 08             	shr    $0x8,%eax
c010480a:	09 c1                	or     %eax,%ecx
c010480c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010480f:	d1 e8                	shr    %eax
c0104811:	0b 45 0c             	or     0xc(%ebp),%eax
c0104814:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104817:	d1 ea                	shr    %edx
c0104819:	0b 55 0c             	or     0xc(%ebp),%edx
c010481c:	c1 ea 02             	shr    $0x2,%edx
c010481f:	09 d0                	or     %edx,%eax
c0104821:	89 c3                	mov    %eax,%ebx
c0104823:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104826:	d1 e8                	shr    %eax
c0104828:	0b 45 0c             	or     0xc(%ebp),%eax
c010482b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010482e:	d1 ea                	shr    %edx
c0104830:	0b 55 0c             	or     0xc(%ebp),%edx
c0104833:	c1 ea 02             	shr    $0x2,%edx
c0104836:	09 d0                	or     %edx,%eax
c0104838:	c1 e8 04             	shr    $0x4,%eax
c010483b:	09 c3                	or     %eax,%ebx
c010483d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104840:	d1 e8                	shr    %eax
c0104842:	0b 45 0c             	or     0xc(%ebp),%eax
c0104845:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104848:	d1 ea                	shr    %edx
c010484a:	0b 55 0c             	or     0xc(%ebp),%edx
c010484d:	c1 ea 02             	shr    $0x2,%edx
c0104850:	09 d0                	or     %edx,%eax
c0104852:	89 c6                	mov    %eax,%esi
c0104854:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104857:	d1 e8                	shr    %eax
c0104859:	0b 45 0c             	or     0xc(%ebp),%eax
c010485c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010485f:	d1 ea                	shr    %edx
c0104861:	0b 55 0c             	or     0xc(%ebp),%edx
c0104864:	c1 ea 02             	shr    $0x2,%edx
c0104867:	09 d0                	or     %edx,%eax
c0104869:	c1 e8 04             	shr    $0x4,%eax
c010486c:	09 f0                	or     %esi,%eax
c010486e:	c1 e8 08             	shr    $0x8,%eax
c0104871:	09 d8                	or     %ebx,%eax
c0104873:	c1 e8 10             	shr    $0x10,%eax
c0104876:	09 c8                	or     %ecx,%eax
c0104878:	d1 e8                	shr    %eax
c010487a:	f7 d0                	not    %eax
c010487c:	23 45 0c             	and    0xc(%ebp),%eax
c010487f:	eb 03                	jmp    c0104884 <buddy_init_memmap+0x305>
c0104881:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104884:	89 45 f0             	mov    %eax,-0x10(%ebp)
    buddy2_new(allocpages);
c0104887:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010488a:	89 04 24             	mov    %eax,(%esp)
c010488d:	e8 7f fc ff ff       	call   c0104511 <buddy2_new>
}
c0104892:	90                   	nop
c0104893:	83 c4 40             	add    $0x40,%esp
c0104896:	5b                   	pop    %ebx
c0104897:	5e                   	pop    %esi
c0104898:	5d                   	pop    %ebp
c0104899:	c3                   	ret    

c010489a <buddy2_alloc>:

//内存分配
int buddy2_alloc(struct buddy2* self, int size) {
c010489a:	55                   	push   %ebp
c010489b:	89 e5                	mov    %esp,%ebp
c010489d:	53                   	push   %ebx
c010489e:	83 ec 14             	sub    $0x14,%esp
  unsigned index = 0;//节点的标号
c01048a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  unsigned node_size;
  unsigned offset = 0;
c01048a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  if (self==NULL)//无法分配
c01048af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01048b3:	75 0a                	jne    c01048bf <buddy2_alloc+0x25>
    return -1;
c01048b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01048ba:	e9 63 01 00 00       	jmp    c0104a22 <buddy2_alloc+0x188>

  if (size <= 0)//分配不合理
c01048bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01048c3:	7f 09                	jg     c01048ce <buddy2_alloc+0x34>
    size = 1;
c01048c5:	c7 45 0c 01 00 00 00 	movl   $0x1,0xc(%ebp)
c01048cc:	eb 19                	jmp    c01048e7 <buddy2_alloc+0x4d>
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
c01048ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048d1:	48                   	dec    %eax
c01048d2:	23 45 0c             	and    0xc(%ebp),%eax
c01048d5:	85 c0                	test   %eax,%eax
c01048d7:	74 0e                	je     c01048e7 <buddy2_alloc+0x4d>
    size = fixsize(size);
c01048d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048dc:	89 04 24             	mov    %eax,(%esp)
c01048df:	e8 ca fb ff ff       	call   c01044ae <fixsize>
c01048e4:	89 45 0c             	mov    %eax,0xc(%ebp)

  if (self[index].longest < size)//可分配内存不足
c01048e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01048ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01048f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01048f4:	01 d0                	add    %edx,%eax
c01048f6:	8b 50 04             	mov    0x4(%eax),%edx
c01048f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048fc:	39 c2                	cmp    %eax,%edx
c01048fe:	73 0a                	jae    c010490a <buddy2_alloc+0x70>
    return -1;
c0104900:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0104905:	e9 18 01 00 00       	jmp    c0104a22 <buddy2_alloc+0x188>

  //cprintf("size is:%d\n",size);

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
c010490a:	8b 45 08             	mov    0x8(%ebp),%eax
c010490d:	8b 00                	mov    (%eax),%eax
c010490f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104912:	e9 85 00 00 00       	jmp    c010499c <buddy2_alloc+0x102>

    //cprintf("self[index].longest is: %d\n",self[index].longest);
    //cprintf("node_size is:%d\n",node_size);

    if (self[LEFT_LEAF(index)].longest >= size)
c0104917:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010491a:	c1 e0 04             	shl    $0x4,%eax
c010491d:	8d 50 08             	lea    0x8(%eax),%edx
c0104920:	8b 45 08             	mov    0x8(%ebp),%eax
c0104923:	01 d0                	add    %edx,%eax
c0104925:	8b 50 04             	mov    0x4(%eax),%edx
c0104928:	8b 45 0c             	mov    0xc(%ebp),%eax
c010492b:	39 c2                	cmp    %eax,%edx
c010492d:	72 5c                	jb     c010498b <buddy2_alloc+0xf1>
    {
      //cprintf("left.longest is:%d\n",self[LEFT_LEAF(index)].longest);
       if(self[RIGHT_LEAF(index)].longest>=size)
c010492f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104932:	40                   	inc    %eax
c0104933:	c1 e0 04             	shl    $0x4,%eax
c0104936:	89 c2                	mov    %eax,%edx
c0104938:	8b 45 08             	mov    0x8(%ebp),%eax
c010493b:	01 d0                	add    %edx,%eax
c010493d:	8b 50 04             	mov    0x4(%eax),%edx
c0104940:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104943:	39 c2                	cmp    %eax,%edx
c0104945:	72 39                	jb     c0104980 <buddy2_alloc+0xe6>
        {
           //cprintf("right.longest is:%d\n",self[RIGHT_LEAF(index)].longest);
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
c0104947:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010494a:	c1 e0 04             	shl    $0x4,%eax
c010494d:	8d 50 08             	lea    0x8(%eax),%edx
c0104950:	8b 45 08             	mov    0x8(%ebp),%eax
c0104953:	01 d0                	add    %edx,%eax
c0104955:	8b 50 04             	mov    0x4(%eax),%edx
c0104958:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010495b:	40                   	inc    %eax
c010495c:	c1 e0 04             	shl    $0x4,%eax
c010495f:	89 c1                	mov    %eax,%ecx
c0104961:	8b 45 08             	mov    0x8(%ebp),%eax
c0104964:	01 c8                	add    %ecx,%eax
c0104966:	8b 40 04             	mov    0x4(%eax),%eax
c0104969:	39 c2                	cmp    %eax,%edx
c010496b:	77 08                	ja     c0104975 <buddy2_alloc+0xdb>
c010496d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104970:	01 c0                	add    %eax,%eax
c0104972:	40                   	inc    %eax
c0104973:	eb 06                	jmp    c010497b <buddy2_alloc+0xe1>
c0104975:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104978:	40                   	inc    %eax
c0104979:	01 c0                	add    %eax,%eax
c010497b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010497e:	eb 14                	jmp    c0104994 <buddy2_alloc+0xfa>
        }
       else
       {
         //cprintf("left_index is:%d\n",LEFT_LEAF(index));

         index=LEFT_LEAF(index);
c0104980:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104983:	01 c0                	add    %eax,%eax
c0104985:	40                   	inc    %eax
c0104986:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0104989:	eb 09                	jmp    c0104994 <buddy2_alloc+0xfa>
    else
    { 
      
      //cprintf("right_index is:%d\n",RIGHT_LEAF(index));

      index = RIGHT_LEAF(index);
c010498b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010498e:	40                   	inc    %eax
c010498f:	01 c0                	add    %eax,%eax
c0104991:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(node_size = self->size; node_size != size; node_size /= 2 ) {
c0104994:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104997:	d1 e8                	shr    %eax
c0104999:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010499c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010499f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01049a2:	0f 85 6f ff ff ff    	jne    c0104917 <buddy2_alloc+0x7d>

    }
     
  }

  self[index].longest = 0;//标记节点为已使用
c01049a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01049ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01049b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01049b5:	01 d0                	add    %edx,%eax
c01049b7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  offset = (index + 1) * node_size - self->size;
c01049be:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01049c1:	40                   	inc    %eax
c01049c2:	0f af 45 f4          	imul   -0xc(%ebp),%eax
c01049c6:	89 c2                	mov    %eax,%edx
c01049c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01049cb:	8b 00                	mov    (%eax),%eax
c01049cd:	29 c2                	sub    %eax,%edx
c01049cf:	89 d0                	mov    %edx,%eax
c01049d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  //cprintf("index is:%d\n",index);
  while (index) {
c01049d4:	eb 43                	jmp    c0104a19 <buddy2_alloc+0x17f>
    index = PARENT(index);
c01049d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01049d9:	40                   	inc    %eax
c01049da:	d1 e8                	shr    %eax
c01049dc:	48                   	dec    %eax
c01049dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
    self[index].longest = 
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
c01049e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01049e3:	40                   	inc    %eax
c01049e4:	c1 e0 04             	shl    $0x4,%eax
c01049e7:	89 c2                	mov    %eax,%edx
c01049e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01049ec:	01 d0                	add    %edx,%eax
c01049ee:	8b 50 04             	mov    0x4(%eax),%edx
c01049f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01049f4:	c1 e0 04             	shl    $0x4,%eax
c01049f7:	8d 48 08             	lea    0x8(%eax),%ecx
c01049fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01049fd:	01 c8                	add    %ecx,%eax
c01049ff:	8b 40 04             	mov    0x4(%eax),%eax
    self[index].longest = 
c0104a02:	8b 4d f8             	mov    -0x8(%ebp),%ecx
c0104a05:	8d 1c cd 00 00 00 00 	lea    0x0(,%ecx,8),%ebx
c0104a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0104a0f:	01 d9                	add    %ebx,%ecx
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
c0104a11:	39 c2                	cmp    %eax,%edx
c0104a13:	0f 43 c2             	cmovae %edx,%eax
    self[index].longest = 
c0104a16:	89 41 04             	mov    %eax,0x4(%ecx)
  while (index) {
c0104a19:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0104a1d:	75 b7                	jne    c01049d6 <buddy2_alloc+0x13c>
  }
//向上刷新，修改先祖结点的数值

  //cprintf("offset id:%d\n",offset);
  return offset;
c0104a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104a22:	83 c4 14             	add    $0x14,%esp
c0104a25:	5b                   	pop    %ebx
c0104a26:	5d                   	pop    %ebp
c0104a27:	c3                   	ret    

c0104a28 <buddy_alloc_pages>:

static struct Page*
buddy_alloc_pages(size_t n){
c0104a28:	55                   	push   %ebp
c0104a29:	89 e5                	mov    %esp,%ebp
c0104a2b:	53                   	push   %ebx
c0104a2c:	83 ec 44             	sub    $0x44,%esp
  assert(n>0);
c0104a2f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104a33:	75 24                	jne    c0104a59 <buddy_alloc_pages+0x31>
c0104a35:	c7 44 24 0c 08 7a 10 	movl   $0xc0107a08,0xc(%esp)
c0104a3c:	c0 
c0104a3d:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c0104a44:	c0 
c0104a45:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c0104a4c:	00 
c0104a4d:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0104a54:	e8 a0 b9 ff ff       	call   c01003f9 <__panic>
  if(n>nr_free)
c0104a59:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c0104a5e:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104a61:	76 0a                	jbe    c0104a6d <buddy_alloc_pages+0x45>
   return NULL;
c0104a63:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a68:	e9 41 01 00 00       	jmp    c0104bae <buddy_alloc_pages+0x186>
  struct Page* page=NULL;
c0104a6d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  struct Page* p;
  list_entry_t *le=&free_list,*len;
c0104a74:	c7 45 f4 40 c1 16 c0 	movl   $0xc016c140,-0xc(%ebp)
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
c0104a7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a7e:	8b 1d 20 df 11 c0    	mov    0xc011df20,%ebx
c0104a84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104a88:	c7 04 24 40 df 11 c0 	movl   $0xc011df40,(%esp)
c0104a8f:	e8 06 fe ff ff       	call   c010489a <buddy2_alloc>
c0104a94:	89 c2                	mov    %eax,%edx
c0104a96:	89 d8                	mov    %ebx,%eax
c0104a98:	01 c0                	add    %eax,%eax
c0104a9a:	01 d8                	add    %ebx,%eax
c0104a9c:	c1 e0 02             	shl    $0x2,%eax
c0104a9f:	05 64 c1 16 c0       	add    $0xc016c164,%eax
c0104aa4:	89 10                	mov    %edx,(%eax)
  int i;
  for(i=0;i<rec[nr_block].offset+1;i++)
c0104aa6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104aad:	eb 12                	jmp    c0104ac1 <buddy_alloc_pages+0x99>
c0104aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ab2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return listelm->next;
c0104ab5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104ab8:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(le);
c0104abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(i=0;i<rec[nr_block].offset+1;i++)
c0104abe:	ff 45 f0             	incl   -0x10(%ebp)
c0104ac1:	8b 15 20 df 11 c0    	mov    0xc011df20,%edx
c0104ac7:	89 d0                	mov    %edx,%eax
c0104ac9:	01 c0                	add    %eax,%eax
c0104acb:	01 d0                	add    %edx,%eax
c0104acd:	c1 e0 02             	shl    $0x2,%eax
c0104ad0:	05 64 c1 16 c0       	add    $0xc016c164,%eax
c0104ad5:	8b 00                	mov    (%eax),%eax
c0104ad7:	40                   	inc    %eax
c0104ad8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104adb:	7c d2                	jl     c0104aaf <buddy_alloc_pages+0x87>
  page=le2page(le,page_link);
c0104add:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ae0:	83 e8 0c             	sub    $0xc,%eax
c0104ae3:	89 45 e8             	mov    %eax,-0x18(%ebp)

  //cprintf("here1\n");


  int allocpages;
  if(!IS_POWER_OF_2(n))
c0104ae6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ae9:	48                   	dec    %eax
c0104aea:	23 45 08             	and    0x8(%ebp),%eax
c0104aed:	85 c0                	test   %eax,%eax
c0104aef:	74 10                	je     c0104b01 <buddy_alloc_pages+0xd9>
   allocpages=fixsize(n);
c0104af1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104af4:	89 04 24             	mov    %eax,(%esp)
c0104af7:	e8 b2 f9 ff ff       	call   c01044ae <fixsize>
c0104afc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104aff:	eb 06                	jmp    c0104b07 <buddy_alloc_pages+0xdf>
  else
  {
     allocpages=n;
c0104b01:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b04:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }
  //根据需求n得到块大小
  rec[nr_block].base=page;//记录分配块首页
c0104b07:	8b 15 20 df 11 c0    	mov    0xc011df20,%edx
c0104b0d:	89 d0                	mov    %edx,%eax
c0104b0f:	01 c0                	add    %eax,%eax
c0104b11:	01 d0                	add    %edx,%eax
c0104b13:	c1 e0 02             	shl    $0x2,%eax
c0104b16:	8d 90 60 c1 16 c0    	lea    -0x3fe93ea0(%eax),%edx
c0104b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b1f:	89 02                	mov    %eax,(%edx)
  rec[nr_block].nr=allocpages;//记录分配的页数
c0104b21:	8b 15 20 df 11 c0    	mov    0xc011df20,%edx
c0104b27:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0104b2a:	89 d0                	mov    %edx,%eax
c0104b2c:	01 c0                	add    %eax,%eax
c0104b2e:	01 d0                	add    %edx,%eax
c0104b30:	c1 e0 02             	shl    $0x2,%eax
c0104b33:	05 68 c1 16 c0       	add    $0xc016c168,%eax
c0104b38:	89 08                	mov    %ecx,(%eax)
  nr_block++;
c0104b3a:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104b3f:	40                   	inc    %eax
c0104b40:	a3 20 df 11 c0       	mov    %eax,0xc011df20
  for(i=0;i<allocpages;i++)
c0104b45:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104b4c:	eb 3a                	jmp    c0104b88 <buddy_alloc_pages+0x160>
c0104b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b51:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104b54:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b57:	8b 40 04             	mov    0x4(%eax),%eax
  {
    len=list_next(le);
c0104b5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    p=le2page(le,page_link);
c0104b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b60:	83 e8 0c             	sub    $0xc,%eax
c0104b63:	89 45 e0             	mov    %eax,-0x20(%ebp)
    ClearPageProperty(p);
c0104b66:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b69:	83 c0 04             	add    $0x4,%eax
c0104b6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c0104b73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104b79:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104b7c:	0f b3 10             	btr    %edx,(%eax)
    le=len;
c0104b7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(i=0;i<allocpages;i++)
c0104b85:	ff 45 f0             	incl   -0x10(%ebp)
c0104b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104b8e:	7c be                	jl     c0104b4e <buddy_alloc_pages+0x126>
  }//修改每一页的状态
  nr_free-=allocpages;//减去已被分配的页数
c0104b90:	8b 15 48 c1 16 c0    	mov    0xc016c148,%edx
c0104b96:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b99:	29 c2                	sub    %eax,%edx
c0104b9b:	89 d0                	mov    %edx,%eax
c0104b9d:	a3 48 c1 16 c0       	mov    %eax,0xc016c148
  
  //cprintf("here2\n");

  page->property=n;
c0104ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ba5:	8b 55 08             	mov    0x8(%ebp),%edx
c0104ba8:	89 50 08             	mov    %edx,0x8(%eax)
  return page;   
c0104bab:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0104bae:	83 c4 44             	add    $0x44,%esp
c0104bb1:	5b                   	pop    %ebx
c0104bb2:	5d                   	pop    %ebp
c0104bb3:	c3                   	ret    

c0104bb4 <buddy_free_pages>:

void buddy_free_pages(struct Page* base, size_t n) {
c0104bb4:	55                   	push   %ebp
c0104bb5:	89 e5                	mov    %esp,%ebp
c0104bb7:	83 ec 58             	sub    $0x58,%esp
  unsigned node_size, index = 0;
c0104bba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  unsigned left_longest, right_longest;
  struct buddy2* self=root;
c0104bc1:	c7 45 e0 40 df 11 c0 	movl   $0xc011df40,-0x20(%ebp)
c0104bc8:	c7 45 c8 40 c1 16 c0 	movl   $0xc016c140,-0x38(%ebp)
c0104bcf:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104bd2:	8b 40 04             	mov    0x4(%eax),%eax
  
  list_entry_t *le=list_next(&free_list);
c0104bd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i=0;
c0104bd8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  for(i=0;i<nr_block;i++)//找到块
c0104bdf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104be6:	eb 1b                	jmp    c0104c03 <buddy_free_pages+0x4f>
  {
    if(rec[i].base==base)
c0104be8:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104beb:	89 d0                	mov    %edx,%eax
c0104bed:	01 c0                	add    %eax,%eax
c0104bef:	01 d0                	add    %edx,%eax
c0104bf1:	c1 e0 02             	shl    $0x2,%eax
c0104bf4:	05 60 c1 16 c0       	add    $0xc016c160,%eax
c0104bf9:	8b 00                	mov    (%eax),%eax
c0104bfb:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104bfe:	74 0f                	je     c0104c0f <buddy_free_pages+0x5b>
  for(i=0;i<nr_block;i++)//找到块
c0104c00:	ff 45 e8             	incl   -0x18(%ebp)
c0104c03:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104c08:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104c0b:	7c db                	jl     c0104be8 <buddy_free_pages+0x34>
c0104c0d:	eb 01                	jmp    c0104c10 <buddy_free_pages+0x5c>
     break;
c0104c0f:	90                   	nop
  }
  int offset=rec[i].offset;
c0104c10:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104c13:	89 d0                	mov    %edx,%eax
c0104c15:	01 c0                	add    %eax,%eax
c0104c17:	01 d0                	add    %edx,%eax
c0104c19:	c1 e0 02             	shl    $0x2,%eax
c0104c1c:	05 64 c1 16 c0       	add    $0xc016c164,%eax
c0104c21:	8b 00                	mov    (%eax),%eax
c0104c23:	89 45 dc             	mov    %eax,-0x24(%ebp)
  int pos=i;//暂存i
c0104c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c29:	89 45 d8             	mov    %eax,-0x28(%ebp)
  i=0;
c0104c2c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  while(i<offset)
c0104c33:	eb 12                	jmp    c0104c47 <buddy_free_pages+0x93>
c0104c35:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0104c3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104c3e:	8b 40 04             	mov    0x4(%eax),%eax
  {
    le=list_next(le);
c0104c41:	89 45 ec             	mov    %eax,-0x14(%ebp)
    i++;
c0104c44:	ff 45 e8             	incl   -0x18(%ebp)
  while(i<offset)
c0104c47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c4a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104c4d:	7c e6                	jl     c0104c35 <buddy_free_pages+0x81>
  }
  int allocpages;
  if(!IS_POWER_OF_2(n))
c0104c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c52:	48                   	dec    %eax
c0104c53:	23 45 0c             	and    0xc(%ebp),%eax
c0104c56:	85 c0                	test   %eax,%eax
c0104c58:	74 10                	je     c0104c6a <buddy_free_pages+0xb6>
   allocpages=fixsize(n);
c0104c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c5d:	89 04 24             	mov    %eax,(%esp)
c0104c60:	e8 49 f8 ff ff       	call   c01044ae <fixsize>
c0104c65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104c68:	eb 06                	jmp    c0104c70 <buddy_free_pages+0xbc>
  else
  {
     allocpages=n;
c0104c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  }
  assert(self && offset >= 0 && offset < self->size);//是否合法
c0104c70:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104c74:	74 12                	je     c0104c88 <buddy_free_pages+0xd4>
c0104c76:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104c7a:	78 0c                	js     c0104c88 <buddy_free_pages+0xd4>
c0104c7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c7f:	8b 10                	mov    (%eax),%edx
c0104c81:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c84:	39 c2                	cmp    %eax,%edx
c0104c86:	77 24                	ja     c0104cac <buddy_free_pages+0xf8>
c0104c88:	c7 44 24 0c 44 7a 10 	movl   $0xc0107a44,0xc(%esp)
c0104c8f:	c0 
c0104c90:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c0104c97:	c0 
c0104c98:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104c9f:	00 
c0104ca0:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0104ca7:	e8 4d b7 ff ff       	call   c01003f9 <__panic>
  node_size = 1;
c0104cac:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  index = offset + self->size - 1;
c0104cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104cb6:	8b 10                	mov    (%eax),%edx
c0104cb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104cbb:	01 d0                	add    %edx,%eax
c0104cbd:	48                   	dec    %eax
c0104cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nr_free+=allocpages;//更新空闲页的数量
c0104cc1:	8b 15 48 c1 16 c0    	mov    0xc016c148,%edx
c0104cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cca:	01 d0                	add    %edx,%eax
c0104ccc:	a3 48 c1 16 c0       	mov    %eax,0xc016c148
  struct Page* p;
  //self[index].longest = allocpages;
  self[index].longest=node_size;
c0104cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cd4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104cdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104cde:	01 c2                	add    %eax,%edx
c0104ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ce3:	89 42 04             	mov    %eax,0x4(%edx)
  for(i=0;i<allocpages;i++)//回收已分配的页
c0104ce6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104ced:	eb 48                	jmp    c0104d37 <buddy_free_pages+0x183>
  {
     p=le2page(le,page_link);
c0104cef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cf2:	83 e8 0c             	sub    $0xc,%eax
c0104cf5:	89 45 cc             	mov    %eax,-0x34(%ebp)
     p->flags=0;
c0104cf8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104cfb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
     p->property=1;
c0104d02:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104d05:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
     SetPageProperty(p);
c0104d0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104d0f:	83 c0 04             	add    $0x4,%eax
c0104d12:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0104d19:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104d1c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104d1f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104d22:	0f ab 10             	bts    %edx,(%eax)
c0104d25:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d28:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0104d2b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104d2e:	8b 40 04             	mov    0x4(%eax),%eax
     le=list_next(le);
c0104d31:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(i=0;i<allocpages;i++)//回收已分配的页
c0104d34:	ff 45 e8             	incl   -0x18(%ebp)
c0104d37:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d3a:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c0104d3d:	7c b0                	jl     c0104cef <buddy_free_pages+0x13b>
  }
  while (index) {//向上合并，修改先祖节点的记录值
c0104d3f:	eb 75                	jmp    c0104db6 <buddy_free_pages+0x202>
    index = PARENT(index);
c0104d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d44:	40                   	inc    %eax
c0104d45:	d1 e8                	shr    %eax
c0104d47:	48                   	dec    %eax
c0104d48:	89 45 f0             	mov    %eax,-0x10(%ebp)
    node_size *= 2;
c0104d4b:	d1 65 f4             	shll   -0xc(%ebp)

    left_longest = self[LEFT_LEAF(index)].longest;
c0104d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d51:	c1 e0 04             	shl    $0x4,%eax
c0104d54:	8d 50 08             	lea    0x8(%eax),%edx
c0104d57:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d5a:	01 d0                	add    %edx,%eax
c0104d5c:	8b 40 04             	mov    0x4(%eax),%eax
c0104d5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    right_longest = self[RIGHT_LEAF(index)].longest;
c0104d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d65:	40                   	inc    %eax
c0104d66:	c1 e0 04             	shl    $0x4,%eax
c0104d69:	89 c2                	mov    %eax,%edx
c0104d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d6e:	01 d0                	add    %edx,%eax
c0104d70:	8b 40 04             	mov    0x4(%eax),%eax
c0104d73:	89 45 d0             	mov    %eax,-0x30(%ebp)
    
    if (left_longest + right_longest == node_size) 
c0104d76:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d79:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d7c:	01 d0                	add    %edx,%eax
c0104d7e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104d81:	75 17                	jne    c0104d9a <buddy_free_pages+0x1e6>
      self[index].longest = node_size;
c0104d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d86:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d90:	01 c2                	add    %eax,%edx
c0104d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d95:	89 42 04             	mov    %eax,0x4(%edx)
c0104d98:	eb 1c                	jmp    c0104db6 <buddy_free_pages+0x202>
    else
      self[index].longest = MAX(left_longest, right_longest);
c0104d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d9d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104da4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104da7:	01 c2                	add    %eax,%edx
c0104da9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104dac:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0104daf:	0f 43 45 d0          	cmovae -0x30(%ebp),%eax
c0104db3:	89 42 04             	mov    %eax,0x4(%edx)
  while (index) {//向上合并，修改先祖节点的记录值
c0104db6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104dba:	75 85                	jne    c0104d41 <buddy_free_pages+0x18d>
  }
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
c0104dbc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104dbf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104dc2:	eb 39                	jmp    c0104dfd <buddy_free_pages+0x249>
  {
    rec[i]=rec[i+1];
c0104dc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104dc7:	8d 48 01             	lea    0x1(%eax),%ecx
c0104dca:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104dcd:	89 d0                	mov    %edx,%eax
c0104dcf:	01 c0                	add    %eax,%eax
c0104dd1:	01 d0                	add    %edx,%eax
c0104dd3:	c1 e0 02             	shl    $0x2,%eax
c0104dd6:	8d 90 60 c1 16 c0    	lea    -0x3fe93ea0(%eax),%edx
c0104ddc:	89 c8                	mov    %ecx,%eax
c0104dde:	01 c0                	add    %eax,%eax
c0104de0:	01 c8                	add    %ecx,%eax
c0104de2:	c1 e0 02             	shl    $0x2,%eax
c0104de5:	05 60 c1 16 c0       	add    $0xc016c160,%eax
c0104dea:	8b 08                	mov    (%eax),%ecx
c0104dec:	89 0a                	mov    %ecx,(%edx)
c0104dee:	8b 48 04             	mov    0x4(%eax),%ecx
c0104df1:	89 4a 04             	mov    %ecx,0x4(%edx)
c0104df4:	8b 40 08             	mov    0x8(%eax),%eax
c0104df7:	89 42 08             	mov    %eax,0x8(%edx)
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
c0104dfa:	ff 45 e8             	incl   -0x18(%ebp)
c0104dfd:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104e02:	48                   	dec    %eax
c0104e03:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104e06:	7c bc                	jl     c0104dc4 <buddy_free_pages+0x210>
  }
  nr_block--;//更新分配块数的值
c0104e08:	a1 20 df 11 c0       	mov    0xc011df20,%eax
c0104e0d:	48                   	dec    %eax
c0104e0e:	a3 20 df 11 c0       	mov    %eax,0xc011df20
}
c0104e13:	90                   	nop
c0104e14:	c9                   	leave  
c0104e15:	c3                   	ret    

c0104e16 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
c0104e16:	55                   	push   %ebp
c0104e17:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104e19:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
}
c0104e1e:	5d                   	pop    %ebp
c0104e1f:	c3                   	ret    

c0104e20 <buddy_check>:

static void
buddy_check(void) {
c0104e20:	55                   	push   %ebp
c0104e21:	89 e5                	mov    %esp,%ebp
c0104e23:	83 ec 28             	sub    $0x28,%esp
  
    struct Page  *A, *B;
    A = B  =NULL;
c0104e26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e30:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert((A = alloc_page()) != NULL);
c0104e33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e3a:	e8 91 df ff ff       	call   c0102dd0 <alloc_pages>
c0104e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104e46:	75 24                	jne    c0104e6c <buddy_check+0x4c>
c0104e48:	c7 44 24 0c 6f 7a 10 	movl   $0xc0107a6f,0xc(%esp)
c0104e4f:	c0 
c0104e50:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c0104e57:	c0 
c0104e58:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104e5f:	00 
c0104e60:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0104e67:	e8 8d b5 ff ff       	call   c01003f9 <__panic>
    assert((B = alloc_page()) != NULL);
c0104e6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e73:	e8 58 df ff ff       	call   c0102dd0 <alloc_pages>
c0104e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e7f:	75 24                	jne    c0104ea5 <buddy_check+0x85>
c0104e81:	c7 44 24 0c 8a 7a 10 	movl   $0xc0107a8a,0xc(%esp)
c0104e88:	c0 
c0104e89:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c0104e90:	c0 
c0104e91:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0104e98:	00 
c0104e99:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0104ea0:	e8 54 b5 ff ff       	call   c01003f9 <__panic>

    assert( A != B);
c0104ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ea8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104eab:	75 24                	jne    c0104ed1 <buddy_check+0xb1>
c0104ead:	c7 44 24 0c a5 7a 10 	movl   $0xc0107aa5,0xc(%esp)
c0104eb4:	c0 
c0104eb5:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c0104ebc:	c0 
c0104ebd:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104ec4:	00 
c0104ec5:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0104ecc:	e8 28 b5 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(A) == 0 && page_ref(B) == 0);
c0104ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ed4:	89 04 24             	mov    %eax,(%esp)
c0104ed7:	e8 ba f5 ff ff       	call   c0104496 <page_ref>
c0104edc:	85 c0                	test   %eax,%eax
c0104ede:	75 0f                	jne    c0104eef <buddy_check+0xcf>
c0104ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ee3:	89 04 24             	mov    %eax,(%esp)
c0104ee6:	e8 ab f5 ff ff       	call   c0104496 <page_ref>
c0104eeb:	85 c0                	test   %eax,%eax
c0104eed:	74 24                	je     c0104f13 <buddy_check+0xf3>
c0104eef:	c7 44 24 0c ac 7a 10 	movl   $0xc0107aac,0xc(%esp)
c0104ef6:	c0 
c0104ef7:	c7 44 24 08 0c 7a 10 	movl   $0xc0107a0c,0x8(%esp)
c0104efe:	c0 
c0104eff:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0104f06:	00 
c0104f07:	c7 04 24 21 7a 10 c0 	movl   $0xc0107a21,(%esp)
c0104f0e:	e8 e6 b4 ff ff       	call   c01003f9 <__panic>
    //free page就是free pages(A,1)
    free_page(A);
c0104f13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f1a:	00 
c0104f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f1e:	89 04 24             	mov    %eax,(%esp)
c0104f21:	e8 e2 de ff ff       	call   c0102e08 <free_pages>
    free_page(B);
c0104f26:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f2d:	00 
c0104f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f31:	89 04 24             	mov    %eax,(%esp)
c0104f34:	e8 cf de ff ff       	call   c0102e08 <free_pages>
    
    
    cprintf("*******************************Check begin***************************\n");
c0104f39:	c7 04 24 d4 7a 10 c0 	movl   $0xc0107ad4,(%esp)
c0104f40:	e8 5d b3 ff ff       	call   c01002a2 <cprintf>
    //A=alloc_pages(500);     //alloc_pages返回的是开始分配的那一页的地址
    A=alloc_pages(70);
c0104f45:	c7 04 24 46 00 00 00 	movl   $0x46,(%esp)
c0104f4c:	e8 7f de ff ff       	call   c0102dd0 <alloc_pages>
c0104f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //B=alloc_pages(500);
    B=alloc_pages(35);
c0104f54:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
c0104f5b:	e8 70 de ff ff       	call   c0102dd0 <alloc_pages>
c0104f60:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("A %p\n",A);
c0104f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f6a:	c7 04 24 1b 7b 10 c0 	movl   $0xc0107b1b,(%esp)
c0104f71:	e8 2c b3 ff ff       	call   c01002a2 <cprintf>
    cprintf("B %p\n",B);
c0104f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f7d:	c7 04 24 21 7b 10 c0 	movl   $0xc0107b21,(%esp)
c0104f84:	e8 19 b3 ff ff       	call   c01002a2 <cprintf>
    cprintf("********************************Check End****************************\n");
c0104f89:	c7 04 24 28 7b 10 c0 	movl   $0xc0107b28,(%esp)
c0104f90:	e8 0d b3 ff ff       	call   c01002a2 <cprintf>
    cprintf("D %p\n",D);
    free_pages(D,60);
    cprintf("C %p\n",C);
    free_pages(C,80);
    free_pages(p0,1000);//全部释放*/
}
c0104f95:	90                   	nop
c0104f96:	c9                   	leave  
c0104f97:	c3                   	ret    

c0104f98 <page2ppn>:
page2ppn(struct Page *page) {
c0104f98:	55                   	push   %ebp
c0104f99:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104f9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f9e:	8b 15 18 df 11 c0    	mov    0xc011df18,%edx
c0104fa4:	29 d0                	sub    %edx,%eax
c0104fa6:	c1 f8 02             	sar    $0x2,%eax
c0104fa9:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104faf:	5d                   	pop    %ebp
c0104fb0:	c3                   	ret    

c0104fb1 <page2pa>:
page2pa(struct Page *page) {
c0104fb1:	55                   	push   %ebp
c0104fb2:	89 e5                	mov    %esp,%ebp
c0104fb4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104fb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fba:	89 04 24             	mov    %eax,(%esp)
c0104fbd:	e8 d6 ff ff ff       	call   c0104f98 <page2ppn>
c0104fc2:	c1 e0 0c             	shl    $0xc,%eax
}
c0104fc5:	c9                   	leave  
c0104fc6:	c3                   	ret    

c0104fc7 <page_ref>:
page_ref(struct Page *page) {
c0104fc7:	55                   	push   %ebp
c0104fc8:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104fca:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fcd:	8b 00                	mov    (%eax),%eax
}
c0104fcf:	5d                   	pop    %ebp
c0104fd0:	c3                   	ret    

c0104fd1 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104fd1:	55                   	push   %ebp
c0104fd2:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104fd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104fda:	89 10                	mov    %edx,(%eax)
}
c0104fdc:	90                   	nop
c0104fdd:	5d                   	pop    %ebp
c0104fde:	c3                   	ret    

c0104fdf <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104fdf:	55                   	push   %ebp
c0104fe0:	89 e5                	mov    %esp,%ebp
c0104fe2:	83 ec 10             	sub    $0x10,%esp
c0104fe5:	c7 45 fc 40 c1 16 c0 	movl   $0xc016c140,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0104fec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104fef:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104ff2:	89 50 04             	mov    %edx,0x4(%eax)
c0104ff5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104ff8:	8b 50 04             	mov    0x4(%eax),%edx
c0104ffb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104ffe:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0105000:	c7 05 48 c1 16 c0 00 	movl   $0x0,0xc016c148
c0105007:	00 00 00 
}
c010500a:	90                   	nop
c010500b:	c9                   	leave  
c010500c:	c3                   	ret    

c010500d <default_init_memmap>:
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}*/

static void
default_init_memmap(struct Page *base, size_t n) {
c010500d:	55                   	push   %ebp
c010500e:	89 e5                	mov    %esp,%ebp
c0105010:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);   //使用assert宏，当为假时中止程序
c0105013:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105017:	75 24                	jne    c010503d <default_init_memmap+0x30>
c0105019:	c7 44 24 0c a0 7b 10 	movl   $0xc0107ba0,0xc(%esp)
c0105020:	c0 
c0105021:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105028:	c0 
c0105029:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0105030:	00 
c0105031:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105038:	e8 bc b3 ff ff       	call   c01003f9 <__panic>
    struct Page *p = base;//声明一个base的Page，随后生成起始地址为base的n个连续页
c010503d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105040:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) { //初始化n块物理页
c0105043:	e9 de 00 00 00       	jmp    c0105126 <default_init_memmap+0x119>
        assert(PageReserved(p)); //确保此页不是保留页，如果是，中止程序
c0105048:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010504b:	83 c0 04             	add    $0x4,%eax
c010504e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0105055:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105058:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010505b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010505e:	0f a3 10             	bt     %edx,(%eax)
c0105061:	19 c0                	sbb    %eax,%eax
c0105063:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0105066:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010506a:	0f 95 c0             	setne  %al
c010506d:	0f b6 c0             	movzbl %al,%eax
c0105070:	85 c0                	test   %eax,%eax
c0105072:	75 24                	jne    c0105098 <default_init_memmap+0x8b>
c0105074:	c7 44 24 0c d1 7b 10 	movl   $0xc0107bd1,0xc(%esp)
c010507b:	c0 
c010507c:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105083:	c0 
c0105084:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c010508b:	00 
c010508c:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105093:	e8 61 b3 ff ff       	call   c01003f9 <__panic>
        p->flags = p->property= 0; //标志位置为0
c0105098:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010509b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01050a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050a5:	8b 50 08             	mov    0x8(%eax),%edx
c01050a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050ab:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(p);       //设置为保留页
c01050ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050b1:	83 c0 04             	add    $0x4,%eax
c01050b4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01050bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01050be:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01050c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01050c4:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);  
c01050c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01050ce:	00 
c01050cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050d2:	89 04 24             	mov    %eax,(%esp)
c01050d5:	e8 f7 fe ff ff       	call   c0104fd1 <set_page_ref>
        list_add_before(&free_list, &(p->page_link)); //加入空闲链表
c01050da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050dd:	83 c0 0c             	add    $0xc,%eax
c01050e0:	c7 45 e4 40 c1 16 c0 	movl   $0xc016c140,-0x1c(%ebp)
c01050e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01050ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050ed:	8b 00                	mov    (%eax),%eax
c01050ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01050f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01050f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01050f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c01050fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105101:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105104:	89 10                	mov    %edx,(%eax)
c0105106:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105109:	8b 10                	mov    (%eax),%edx
c010510b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010510e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105111:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105114:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105117:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010511a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010511d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105120:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) { //初始化n块物理页
c0105122:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105126:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105129:	89 d0                	mov    %edx,%eax
c010512b:	c1 e0 02             	shl    $0x2,%eax
c010512e:	01 d0                	add    %edx,%eax
c0105130:	c1 e0 02             	shl    $0x2,%eax
c0105133:	89 c2                	mov    %eax,%edx
c0105135:	8b 45 08             	mov    0x8(%ebp),%eax
c0105138:	01 d0                	add    %edx,%eax
c010513a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010513d:	0f 85 05 ff ff ff    	jne    c0105048 <default_init_memmap+0x3b>
    }
    nr_free += n;  //空闲页总数置为n
c0105143:	8b 15 48 c1 16 c0    	mov    0xc016c148,%edx
c0105149:	8b 45 0c             	mov    0xc(%ebp),%eax
c010514c:	01 d0                	add    %edx,%eax
c010514e:	a3 48 c1 16 c0       	mov    %eax,0xc016c148
    base->property = n; //修改base的连续空页值为n
c0105153:	8b 45 08             	mov    0x8(%ebp),%eax
c0105156:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105159:	89 50 08             	mov    %edx,0x8(%eax)
}
c010515c:	90                   	nop
c010515d:	c9                   	leave  
c010515e:	c3                   	ret    

c010515f <default_alloc_pages>:
    }
    return page;
}*/

static struct Page *
default_alloc_pages(size_t n) {
c010515f:	55                   	push   %ebp
c0105160:	89 e5                	mov    %esp,%ebp
c0105162:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0); 
c0105165:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105169:	75 24                	jne    c010518f <default_alloc_pages+0x30>
c010516b:	c7 44 24 0c a0 7b 10 	movl   $0xc0107ba0,0xc(%esp)
c0105172:	c0 
c0105173:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c010517a:	c0 
c010517b:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0105182:	00 
c0105183:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c010518a:	e8 6a b2 ff ff       	call   c01003f9 <__panic>
    if (n > nr_free) { //如果需要分配的页少于空闲页的总数,返回NULL
c010518f:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c0105194:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105197:	76 0a                	jbe    c01051a3 <default_alloc_pages+0x44>
        return NULL;
c0105199:	b8 00 00 00 00       	mov    $0x0,%eax
c010519e:	e9 36 01 00 00       	jmp    c01052d9 <default_alloc_pages+0x17a>
    }
    list_entry_t *le, *len; //声明一个空闲链表的头部和长度
    le = &free_list;  //空闲链表的头部
c01051a3:	c7 45 f4 40 c1 16 c0 	movl   $0xc016c140,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {//遍历整个链表
c01051aa:	e9 09 01 00 00       	jmp    c01052b8 <default_alloc_pages+0x159>
      struct Page *p = le2page(le, page_link); //转换为页
c01051af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051b2:	83 e8 0c             	sub    $0xc,%eax
c01051b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){//找到页(whose first `n` pages can be malloced)
c01051b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051bb:	8b 40 08             	mov    0x8(%eax),%eax
c01051be:	39 45 08             	cmp    %eax,0x8(%ebp)
c01051c1:	0f 87 f1 00 00 00    	ja     c01052b8 <default_alloc_pages+0x159>
        int i;
        for(i=0;i<n;i++){//对前n页进行操作
c01051c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01051ce:	eb 7b                	jmp    c010524b <default_alloc_pages+0xec>
c01051d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051d3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01051d6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01051d9:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le); 
c01051dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link); //转换为页
c01051df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051e2:	83 e8 0c             	sub    $0xc,%eax
c01051e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp); //PG_reserved = '1'
c01051e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051eb:	83 c0 04             	add    $0x4,%eax
c01051ee:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c01051f5:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01051f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01051fb:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01051fe:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);//PG_property = '0'
c0105201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105204:	83 c0 04             	add    $0x4,%eax
c0105207:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c010520e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105211:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105214:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105217:	0f b3 10             	btr    %edx,(%eax)
c010521a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010521d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105220:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105223:	8b 40 04             	mov    0x4(%eax),%eax
c0105226:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105229:	8b 12                	mov    (%edx),%edx
c010522b:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010522e:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105231:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105234:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105237:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010523a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010523d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105240:	89 10                	mov    %edx,(%eax)
          list_del(le); //将此页从free_list中清除
          le = len;
c0105242:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105245:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){//对前n页进行操作
c0105248:	ff 45 f0             	incl   -0x10(%ebp)
c010524b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010524e:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105251:	0f 87 79 ff ff ff    	ja     c01051d0 <default_alloc_pages+0x71>
        }
        if(p->property>n){ //如果页块大小大于所需大小，分割页块
c0105257:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010525a:	8b 40 08             	mov    0x8(%eax),%eax
c010525d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0105260:	73 12                	jae    c0105274 <default_alloc_pages+0x115>
          (le2page(le,page_link))->property = p->property-n;
c0105262:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105265:	8b 40 08             	mov    0x8(%eax),%eax
c0105268:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010526b:	83 ea 0c             	sub    $0xc,%edx
c010526e:	2b 45 08             	sub    0x8(%ebp),%eax
c0105271:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c0105274:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105277:	83 c0 04             	add    $0x4,%eax
c010527a:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0105281:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0105284:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105287:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010528a:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c010528d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105290:	83 c0 04             	add    $0x4,%eax
c0105293:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c010529a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010529d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01052a0:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01052a3:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n; //减去已经分配的页块大小
c01052a6:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c01052ab:	2b 45 08             	sub    0x8(%ebp),%eax
c01052ae:	a3 48 c1 16 c0       	mov    %eax,0xc016c148
        return p;
c01052b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052b6:	eb 21                	jmp    c01052d9 <default_alloc_pages+0x17a>
c01052b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052bb:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
c01052be:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01052c1:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {//遍历整个链表
c01052c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01052c7:	81 7d f4 40 c1 16 c0 	cmpl   $0xc016c140,-0xc(%ebp)
c01052ce:	0f 85 db fe ff ff    	jne    c01051af <default_alloc_pages+0x50>
      }
    }
    return NULL;
c01052d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052d9:	c9                   	leave  
c01052da:	c3                   	ret    

c01052db <default_free_pages>:
    list_add_before(le, &(base->page_link));
}*/


static void
default_free_pages(struct Page *base, size_t n) {
c01052db:	55                   	push   %ebp
c01052dc:	89 e5                	mov    %esp,%ebp
c01052de:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);  
c01052e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01052e5:	75 24                	jne    c010530b <default_free_pages+0x30>
c01052e7:	c7 44 24 0c a0 7b 10 	movl   $0xc0107ba0,0xc(%esp)
c01052ee:	c0 
c01052ef:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01052f6:	c0 
c01052f7:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01052fe:	00 
c01052ff:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105306:	e8 ee b0 ff ff       	call   c01003f9 <__panic>
    assert(PageReserved(base));    //检查需要释放的页块是否已经被分配
c010530b:	8b 45 08             	mov    0x8(%ebp),%eax
c010530e:	83 c0 04             	add    $0x4,%eax
c0105311:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105318:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010531b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010531e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105321:	0f a3 10             	bt     %edx,(%eax)
c0105324:	19 c0                	sbb    %eax,%eax
c0105326:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0105329:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010532d:	0f 95 c0             	setne  %al
c0105330:	0f b6 c0             	movzbl %al,%eax
c0105333:	85 c0                	test   %eax,%eax
c0105335:	75 24                	jne    c010535b <default_free_pages+0x80>
c0105337:	c7 44 24 0c e1 7b 10 	movl   $0xc0107be1,0xc(%esp)
c010533e:	c0 
c010533f:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105346:	c0 
c0105347:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c010534e:	00 
c010534f:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105356:	e8 9e b0 ff ff       	call   c01003f9 <__panic>
    list_entry_t *le = &free_list; 
c010535b:	c7 45 f4 40 c1 16 c0 	movl   $0xc016c140,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {//找到释放的位置
c0105362:	eb 11                	jmp    c0105375 <default_free_pages+0x9a>
      p = le2page(le, page_link);
c0105364:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105367:	83 e8 0c             	sub    $0xc,%eax
c010536a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){    
c010536d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105370:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105373:	77 1a                	ja     c010538f <default_free_pages+0xb4>
c0105375:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105378:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010537b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010537e:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {//找到释放的位置
c0105381:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105384:	81 7d f4 40 c1 16 c0 	cmpl   $0xc016c140,-0xc(%ebp)
c010538b:	75 d7                	jne    c0105364 <default_free_pages+0x89>
c010538d:	eb 01                	jmp    c0105390 <default_free_pages+0xb5>
        break;
c010538f:	90                   	nop
      }
    }
    for(p=base;p<base+n;p++){              
c0105390:	8b 45 08             	mov    0x8(%ebp),%eax
c0105393:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105396:	eb 4b                	jmp    c01053e3 <default_free_pages+0x108>
      list_add_before(le, &(p->page_link)); //在这个位置开始，插入释放数量的空页
c0105398:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010539b:	8d 50 0c             	lea    0xc(%eax),%edx
c010539e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01053a4:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01053a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053aa:	8b 00                	mov    (%eax),%eax
c01053ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01053b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01053b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c01053bb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01053be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053c1:	89 10                	mov    %edx,(%eax)
c01053c3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01053c6:	8b 10                	mov    (%eax),%edx
c01053c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053cb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01053ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01053d1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01053d4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01053d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01053da:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01053dd:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){              
c01053df:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
c01053e3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01053e6:	89 d0                	mov    %edx,%eax
c01053e8:	c1 e0 02             	shl    $0x2,%eax
c01053eb:	01 d0                	add    %edx,%eax
c01053ed:	c1 e0 02             	shl    $0x2,%eax
c01053f0:	89 c2                	mov    %eax,%edx
c01053f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f5:	01 d0                	add    %edx,%eax
c01053f7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01053fa:	72 9c                	jb     c0105398 <default_free_pages+0xbd>
    }
    base->flags = 0;         //修改标志位
c01053fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01053ff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);   //修改引用次数为0 
c0105406:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010540d:	00 
c010540e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105411:	89 04 24             	mov    %eax,(%esp)
c0105414:	e8 b8 fb ff ff       	call   c0104fd1 <set_page_ref>
    ClearPageProperty(base);
c0105419:	8b 45 08             	mov    0x8(%ebp),%eax
c010541c:	83 c0 04             	add    $0x4,%eax
c010541f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105426:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105429:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010542c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010542f:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0105432:	8b 45 08             	mov    0x8(%ebp),%eax
c0105435:	83 c0 04             	add    $0x4,%eax
c0105438:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c010543f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105442:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105445:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105448:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;      //设置连续大小为n
c010544b:	8b 45 08             	mov    0x8(%ebp),%eax
c010544e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105451:	89 50 08             	mov    %edx,0x8(%eax)
    //如果是高位，则向高地址合并
    p = le2page(le,page_link) ;
c0105454:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105457:	83 e8 0c             	sub    $0xc,%eax
c010545a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  //满足base+n==p，因此，尝试向后合并空闲页。
  //如果能合并，那么base的连续空闲页加上p的连续空闲页，且p的连续空闲页置为0；
  //如果之后的页不能合并，那么p->property一直为0，下面的代码不会对它产生影响。
    if( base+n == p ){
c010545d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105460:	89 d0                	mov    %edx,%eax
c0105462:	c1 e0 02             	shl    $0x2,%eax
c0105465:	01 d0                	add    %edx,%eax
c0105467:	c1 e0 02             	shl    $0x2,%eax
c010546a:	89 c2                	mov    %eax,%edx
c010546c:	8b 45 08             	mov    0x8(%ebp),%eax
c010546f:	01 d0                	add    %edx,%eax
c0105471:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105474:	75 1e                	jne    c0105494 <default_free_pages+0x1b9>
      base->property += p->property;
c0105476:	8b 45 08             	mov    0x8(%ebp),%eax
c0105479:	8b 50 08             	mov    0x8(%eax),%edx
c010547c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010547f:	8b 40 08             	mov    0x8(%eax),%eax
c0105482:	01 c2                	add    %eax,%edx
c0105484:	8b 45 08             	mov    0x8(%ebp),%eax
c0105487:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c010548a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010548d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
     //如果是低位且在范围内，则向低地址合并
     //获取基地址页的前一个页，如果为空，那么循环查找之前所有为空，能够合并的页
    le = list_prev(&(base->page_link));
c0105494:	8b 45 08             	mov    0x8(%ebp),%eax
c0105497:	83 c0 0c             	add    $0xc,%eax
c010549a:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
c010549d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01054a0:	8b 00                	mov    (%eax),%eax
c01054a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c01054a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054a8:	83 e8 0c             	sub    $0xc,%eax
c01054ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){ //满足条件，未分配则合并
c01054ae:	81 7d f4 40 c1 16 c0 	cmpl   $0xc016c140,-0xc(%ebp)
c01054b5:	74 57                	je     c010550e <default_free_pages+0x233>
c01054b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01054ba:	83 e8 14             	sub    $0x14,%eax
c01054bd:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01054c0:	75 4c                	jne    c010550e <default_free_pages+0x233>
      while(le!=&free_list){
c01054c2:	eb 41                	jmp    c0105505 <default_free_pages+0x22a>
        if(p->property){ //连续
c01054c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054c7:	8b 40 08             	mov    0x8(%eax),%eax
c01054ca:	85 c0                	test   %eax,%eax
c01054cc:	74 20                	je     c01054ee <default_free_pages+0x213>
          p->property += base->property;
c01054ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054d1:	8b 50 08             	mov    0x8(%eax),%edx
c01054d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01054d7:	8b 40 08             	mov    0x8(%eax),%eax
c01054da:	01 c2                	add    %eax,%edx
c01054dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054df:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c01054e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01054e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          //不断更新前一个页p的property值，并将base->property置为0
          break;
c01054ec:	eb 20                	jmp    c010550e <default_free_pages+0x233>
c01054ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054f1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01054f4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01054f7:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c01054f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c01054fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054ff:	83 e8 0c             	sub    $0xc,%eax
c0105502:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
c0105505:	81 7d f4 40 c1 16 c0 	cmpl   $0xc016c140,-0xc(%ebp)
c010550c:	75 b6                	jne    c01054c4 <default_free_pages+0x1e9>
      }
    }

    nr_free += n;//空闲页数量加n
c010550e:	8b 15 48 c1 16 c0    	mov    0xc016c148,%edx
c0105514:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105517:	01 d0                	add    %edx,%eax
c0105519:	a3 48 c1 16 c0       	mov    %eax,0xc016c148
    return ;
c010551e:	90                   	nop
} 
c010551f:	c9                   	leave  
c0105520:	c3                   	ret    

c0105521 <default_nr_free_pages>:


static size_t
default_nr_free_pages(void) {
c0105521:	55                   	push   %ebp
c0105522:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0105524:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
}
c0105529:	5d                   	pop    %ebp
c010552a:	c3                   	ret    

c010552b <basic_check>:

static void
basic_check(void) {
c010552b:	55                   	push   %ebp
c010552c:	89 e5                	mov    %esp,%ebp
c010552e:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105531:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105538:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010553b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010553e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105541:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105544:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010554b:	e8 80 d8 ff ff       	call   c0102dd0 <alloc_pages>
c0105550:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105553:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105557:	75 24                	jne    c010557d <basic_check+0x52>
c0105559:	c7 44 24 0c f4 7b 10 	movl   $0xc0107bf4,0xc(%esp)
c0105560:	c0 
c0105561:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105568:	c0 
c0105569:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c0105570:	00 
c0105571:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105578:	e8 7c ae ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010557d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105584:	e8 47 d8 ff ff       	call   c0102dd0 <alloc_pages>
c0105589:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010558c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105590:	75 24                	jne    c01055b6 <basic_check+0x8b>
c0105592:	c7 44 24 0c 10 7c 10 	movl   $0xc0107c10,0xc(%esp)
c0105599:	c0 
c010559a:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01055a1:	c0 
c01055a2:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c01055a9:	00 
c01055aa:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01055b1:	e8 43 ae ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01055b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01055bd:	e8 0e d8 ff ff       	call   c0102dd0 <alloc_pages>
c01055c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01055c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01055c9:	75 24                	jne    c01055ef <basic_check+0xc4>
c01055cb:	c7 44 24 0c 2c 7c 10 	movl   $0xc0107c2c,0xc(%esp)
c01055d2:	c0 
c01055d3:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01055da:	c0 
c01055db:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c01055e2:	00 
c01055e3:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01055ea:	e8 0a ae ff ff       	call   c01003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01055ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055f2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01055f5:	74 10                	je     c0105607 <basic_check+0xdc>
c01055f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01055fd:	74 08                	je     c0105607 <basic_check+0xdc>
c01055ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105602:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105605:	75 24                	jne    c010562b <basic_check+0x100>
c0105607:	c7 44 24 0c 48 7c 10 	movl   $0xc0107c48,0xc(%esp)
c010560e:	c0 
c010560f:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105616:	c0 
c0105617:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
c010561e:	00 
c010561f:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105626:	e8 ce ad ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010562b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010562e:	89 04 24             	mov    %eax,(%esp)
c0105631:	e8 91 f9 ff ff       	call   c0104fc7 <page_ref>
c0105636:	85 c0                	test   %eax,%eax
c0105638:	75 1e                	jne    c0105658 <basic_check+0x12d>
c010563a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010563d:	89 04 24             	mov    %eax,(%esp)
c0105640:	e8 82 f9 ff ff       	call   c0104fc7 <page_ref>
c0105645:	85 c0                	test   %eax,%eax
c0105647:	75 0f                	jne    c0105658 <basic_check+0x12d>
c0105649:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010564c:	89 04 24             	mov    %eax,(%esp)
c010564f:	e8 73 f9 ff ff       	call   c0104fc7 <page_ref>
c0105654:	85 c0                	test   %eax,%eax
c0105656:	74 24                	je     c010567c <basic_check+0x151>
c0105658:	c7 44 24 0c 6c 7c 10 	movl   $0xc0107c6c,0xc(%esp)
c010565f:	c0 
c0105660:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105667:	c0 
c0105668:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c010566f:	00 
c0105670:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105677:	e8 7d ad ff ff       	call   c01003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010567c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010567f:	89 04 24             	mov    %eax,(%esp)
c0105682:	e8 2a f9 ff ff       	call   c0104fb1 <page2pa>
c0105687:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c010568d:	c1 e2 0c             	shl    $0xc,%edx
c0105690:	39 d0                	cmp    %edx,%eax
c0105692:	72 24                	jb     c01056b8 <basic_check+0x18d>
c0105694:	c7 44 24 0c a8 7c 10 	movl   $0xc0107ca8,0xc(%esp)
c010569b:	c0 
c010569c:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01056a3:	c0 
c01056a4:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
c01056ab:	00 
c01056ac:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01056b3:	e8 41 ad ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01056b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056bb:	89 04 24             	mov    %eax,(%esp)
c01056be:	e8 ee f8 ff ff       	call   c0104fb1 <page2pa>
c01056c3:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c01056c9:	c1 e2 0c             	shl    $0xc,%edx
c01056cc:	39 d0                	cmp    %edx,%eax
c01056ce:	72 24                	jb     c01056f4 <basic_check+0x1c9>
c01056d0:	c7 44 24 0c c5 7c 10 	movl   $0xc0107cc5,0xc(%esp)
c01056d7:	c0 
c01056d8:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01056df:	c0 
c01056e0:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c01056e7:	00 
c01056e8:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01056ef:	e8 05 ad ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01056f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056f7:	89 04 24             	mov    %eax,(%esp)
c01056fa:	e8 b2 f8 ff ff       	call   c0104fb1 <page2pa>
c01056ff:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0105705:	c1 e2 0c             	shl    $0xc,%edx
c0105708:	39 d0                	cmp    %edx,%eax
c010570a:	72 24                	jb     c0105730 <basic_check+0x205>
c010570c:	c7 44 24 0c e2 7c 10 	movl   $0xc0107ce2,0xc(%esp)
c0105713:	c0 
c0105714:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c010571b:	c0 
c010571c:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
c0105723:	00 
c0105724:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c010572b:	e8 c9 ac ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c0105730:	a1 40 c1 16 c0       	mov    0xc016c140,%eax
c0105735:	8b 15 44 c1 16 c0    	mov    0xc016c144,%edx
c010573b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010573e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105741:	c7 45 dc 40 c1 16 c0 	movl   $0xc016c140,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0105748:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010574b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010574e:	89 50 04             	mov    %edx,0x4(%eax)
c0105751:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105754:	8b 50 04             	mov    0x4(%eax),%edx
c0105757:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010575a:	89 10                	mov    %edx,(%eax)
c010575c:	c7 45 e0 40 c1 16 c0 	movl   $0xc016c140,-0x20(%ebp)
    return list->next == list;
c0105763:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105766:	8b 40 04             	mov    0x4(%eax),%eax
c0105769:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010576c:	0f 94 c0             	sete   %al
c010576f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105772:	85 c0                	test   %eax,%eax
c0105774:	75 24                	jne    c010579a <basic_check+0x26f>
c0105776:	c7 44 24 0c ff 7c 10 	movl   $0xc0107cff,0xc(%esp)
c010577d:	c0 
c010577e:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105785:	c0 
c0105786:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
c010578d:	00 
c010578e:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105795:	e8 5f ac ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c010579a:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c010579f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01057a2:	c7 05 48 c1 16 c0 00 	movl   $0x0,0xc016c148
c01057a9:	00 00 00 

    assert(alloc_page() == NULL);
c01057ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01057b3:	e8 18 d6 ff ff       	call   c0102dd0 <alloc_pages>
c01057b8:	85 c0                	test   %eax,%eax
c01057ba:	74 24                	je     c01057e0 <basic_check+0x2b5>
c01057bc:	c7 44 24 0c 16 7d 10 	movl   $0xc0107d16,0xc(%esp)
c01057c3:	c0 
c01057c4:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01057cb:	c0 
c01057cc:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
c01057d3:	00 
c01057d4:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01057db:	e8 19 ac ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c01057e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01057e7:	00 
c01057e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057eb:	89 04 24             	mov    %eax,(%esp)
c01057ee:	e8 15 d6 ff ff       	call   c0102e08 <free_pages>
    free_page(p1);
c01057f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01057fa:	00 
c01057fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057fe:	89 04 24             	mov    %eax,(%esp)
c0105801:	e8 02 d6 ff ff       	call   c0102e08 <free_pages>
    free_page(p2);
c0105806:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010580d:	00 
c010580e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105811:	89 04 24             	mov    %eax,(%esp)
c0105814:	e8 ef d5 ff ff       	call   c0102e08 <free_pages>
    assert(nr_free == 3);
c0105819:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c010581e:	83 f8 03             	cmp    $0x3,%eax
c0105821:	74 24                	je     c0105847 <basic_check+0x31c>
c0105823:	c7 44 24 0c 2b 7d 10 	movl   $0xc0107d2b,0xc(%esp)
c010582a:	c0 
c010582b:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105832:	c0 
c0105833:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
c010583a:	00 
c010583b:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105842:	e8 b2 ab ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0105847:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010584e:	e8 7d d5 ff ff       	call   c0102dd0 <alloc_pages>
c0105853:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105856:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010585a:	75 24                	jne    c0105880 <basic_check+0x355>
c010585c:	c7 44 24 0c f4 7b 10 	movl   $0xc0107bf4,0xc(%esp)
c0105863:	c0 
c0105864:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c010586b:	c0 
c010586c:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0105873:	00 
c0105874:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c010587b:	e8 79 ab ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105880:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105887:	e8 44 d5 ff ff       	call   c0102dd0 <alloc_pages>
c010588c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010588f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105893:	75 24                	jne    c01058b9 <basic_check+0x38e>
c0105895:	c7 44 24 0c 10 7c 10 	movl   $0xc0107c10,0xc(%esp)
c010589c:	c0 
c010589d:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01058a4:	c0 
c01058a5:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
c01058ac:	00 
c01058ad:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01058b4:	e8 40 ab ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01058b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01058c0:	e8 0b d5 ff ff       	call   c0102dd0 <alloc_pages>
c01058c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01058c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058cc:	75 24                	jne    c01058f2 <basic_check+0x3c7>
c01058ce:	c7 44 24 0c 2c 7c 10 	movl   $0xc0107c2c,0xc(%esp)
c01058d5:	c0 
c01058d6:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01058dd:	c0 
c01058de:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c01058e5:	00 
c01058e6:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01058ed:	e8 07 ab ff ff       	call   c01003f9 <__panic>

    assert(alloc_page() == NULL);
c01058f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01058f9:	e8 d2 d4 ff ff       	call   c0102dd0 <alloc_pages>
c01058fe:	85 c0                	test   %eax,%eax
c0105900:	74 24                	je     c0105926 <basic_check+0x3fb>
c0105902:	c7 44 24 0c 16 7d 10 	movl   $0xc0107d16,0xc(%esp)
c0105909:	c0 
c010590a:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105911:	c0 
c0105912:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0105919:	00 
c010591a:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105921:	e8 d3 aa ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c0105926:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010592d:	00 
c010592e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105931:	89 04 24             	mov    %eax,(%esp)
c0105934:	e8 cf d4 ff ff       	call   c0102e08 <free_pages>
c0105939:	c7 45 d8 40 c1 16 c0 	movl   $0xc016c140,-0x28(%ebp)
c0105940:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105943:	8b 40 04             	mov    0x4(%eax),%eax
c0105946:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105949:	0f 94 c0             	sete   %al
c010594c:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010594f:	85 c0                	test   %eax,%eax
c0105951:	74 24                	je     c0105977 <basic_check+0x44c>
c0105953:	c7 44 24 0c 38 7d 10 	movl   $0xc0107d38,0xc(%esp)
c010595a:	c0 
c010595b:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105962:	c0 
c0105963:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c010596a:	00 
c010596b:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105972:	e8 82 aa ff ff       	call   c01003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105977:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010597e:	e8 4d d4 ff ff       	call   c0102dd0 <alloc_pages>
c0105983:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105986:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105989:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010598c:	74 24                	je     c01059b2 <basic_check+0x487>
c010598e:	c7 44 24 0c 50 7d 10 	movl   $0xc0107d50,0xc(%esp)
c0105995:	c0 
c0105996:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c010599d:	c0 
c010599e:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c01059a5:	00 
c01059a6:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01059ad:	e8 47 aa ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c01059b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01059b9:	e8 12 d4 ff ff       	call   c0102dd0 <alloc_pages>
c01059be:	85 c0                	test   %eax,%eax
c01059c0:	74 24                	je     c01059e6 <basic_check+0x4bb>
c01059c2:	c7 44 24 0c 16 7d 10 	movl   $0xc0107d16,0xc(%esp)
c01059c9:	c0 
c01059ca:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01059d1:	c0 
c01059d2:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c01059d9:	00 
c01059da:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01059e1:	e8 13 aa ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c01059e6:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c01059eb:	85 c0                	test   %eax,%eax
c01059ed:	74 24                	je     c0105a13 <basic_check+0x4e8>
c01059ef:	c7 44 24 0c 69 7d 10 	movl   $0xc0107d69,0xc(%esp)
c01059f6:	c0 
c01059f7:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01059fe:	c0 
c01059ff:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
c0105a06:	00 
c0105a07:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105a0e:	e8 e6 a9 ff ff       	call   c01003f9 <__panic>
    free_list = free_list_store;
c0105a13:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105a16:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105a19:	a3 40 c1 16 c0       	mov    %eax,0xc016c140
c0105a1e:	89 15 44 c1 16 c0    	mov    %edx,0xc016c144
    nr_free = nr_free_store;
c0105a24:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a27:	a3 48 c1 16 c0       	mov    %eax,0xc016c148

    free_page(p);
c0105a2c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a33:	00 
c0105a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a37:	89 04 24             	mov    %eax,(%esp)
c0105a3a:	e8 c9 d3 ff ff       	call   c0102e08 <free_pages>
    free_page(p1);
c0105a3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a46:	00 
c0105a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a4a:	89 04 24             	mov    %eax,(%esp)
c0105a4d:	e8 b6 d3 ff ff       	call   c0102e08 <free_pages>
    free_page(p2);
c0105a52:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a59:	00 
c0105a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a5d:	89 04 24             	mov    %eax,(%esp)
c0105a60:	e8 a3 d3 ff ff       	call   c0102e08 <free_pages>
}
c0105a65:	90                   	nop
c0105a66:	c9                   	leave  
c0105a67:	c3                   	ret    

c0105a68 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105a68:	55                   	push   %ebp
c0105a69:	89 e5                	mov    %esp,%ebp
c0105a6b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0105a71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105a78:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105a7f:	c7 45 ec 40 c1 16 c0 	movl   $0xc016c140,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105a86:	eb 6a                	jmp    c0105af2 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0105a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a8b:	83 e8 0c             	sub    $0xc,%eax
c0105a8e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0105a91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105a94:	83 c0 04             	add    $0x4,%eax
c0105a97:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0105a9e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105aa1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105aa4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105aa7:	0f a3 10             	bt     %edx,(%eax)
c0105aaa:	19 c0                	sbb    %eax,%eax
c0105aac:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0105aaf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0105ab3:	0f 95 c0             	setne  %al
c0105ab6:	0f b6 c0             	movzbl %al,%eax
c0105ab9:	85 c0                	test   %eax,%eax
c0105abb:	75 24                	jne    c0105ae1 <default_check+0x79>
c0105abd:	c7 44 24 0c 76 7d 10 	movl   $0xc0107d76,0xc(%esp)
c0105ac4:	c0 
c0105ac5:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105acc:	c0 
c0105acd:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
c0105ad4:	00 
c0105ad5:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105adc:	e8 18 a9 ff ff       	call   c01003f9 <__panic>
        count ++, total += p->property;
c0105ae1:	ff 45 f4             	incl   -0xc(%ebp)
c0105ae4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105ae7:	8b 50 08             	mov    0x8(%eax),%edx
c0105aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aed:	01 d0                	add    %edx,%eax
c0105aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105af5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0105af8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105afb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105afe:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105b01:	81 7d ec 40 c1 16 c0 	cmpl   $0xc016c140,-0x14(%ebp)
c0105b08:	0f 85 7a ff ff ff    	jne    c0105a88 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0105b0e:	e8 28 d3 ff ff       	call   c0102e3b <nr_free_pages>
c0105b13:	89 c2                	mov    %eax,%edx
c0105b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b18:	39 c2                	cmp    %eax,%edx
c0105b1a:	74 24                	je     c0105b40 <default_check+0xd8>
c0105b1c:	c7 44 24 0c 86 7d 10 	movl   $0xc0107d86,0xc(%esp)
c0105b23:	c0 
c0105b24:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105b2b:	c0 
c0105b2c:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
c0105b33:	00 
c0105b34:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105b3b:	e8 b9 a8 ff ff       	call   c01003f9 <__panic>

    basic_check();
c0105b40:	e8 e6 f9 ff ff       	call   c010552b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105b45:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105b4c:	e8 7f d2 ff ff       	call   c0102dd0 <alloc_pages>
c0105b51:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0105b54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b58:	75 24                	jne    c0105b7e <default_check+0x116>
c0105b5a:	c7 44 24 0c 9f 7d 10 	movl   $0xc0107d9f,0xc(%esp)
c0105b61:	c0 
c0105b62:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105b69:	c0 
c0105b6a:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
c0105b71:	00 
c0105b72:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105b79:	e8 7b a8 ff ff       	call   c01003f9 <__panic>
    assert(!PageProperty(p0));
c0105b7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b81:	83 c0 04             	add    $0x4,%eax
c0105b84:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105b8b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105b8e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105b91:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105b94:	0f a3 10             	bt     %edx,(%eax)
c0105b97:	19 c0                	sbb    %eax,%eax
c0105b99:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0105b9c:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105ba0:	0f 95 c0             	setne  %al
c0105ba3:	0f b6 c0             	movzbl %al,%eax
c0105ba6:	85 c0                	test   %eax,%eax
c0105ba8:	74 24                	je     c0105bce <default_check+0x166>
c0105baa:	c7 44 24 0c aa 7d 10 	movl   $0xc0107daa,0xc(%esp)
c0105bb1:	c0 
c0105bb2:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105bb9:	c0 
c0105bba:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
c0105bc1:	00 
c0105bc2:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105bc9:	e8 2b a8 ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c0105bce:	a1 40 c1 16 c0       	mov    0xc016c140,%eax
c0105bd3:	8b 15 44 c1 16 c0    	mov    0xc016c144,%edx
c0105bd9:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105bdc:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105bdf:	c7 45 b0 40 c1 16 c0 	movl   $0xc016c140,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0105be6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105be9:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105bec:	89 50 04             	mov    %edx,0x4(%eax)
c0105bef:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105bf2:	8b 50 04             	mov    0x4(%eax),%edx
c0105bf5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105bf8:	89 10                	mov    %edx,(%eax)
c0105bfa:	c7 45 b4 40 c1 16 c0 	movl   $0xc016c140,-0x4c(%ebp)
    return list->next == list;
c0105c01:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105c04:	8b 40 04             	mov    0x4(%eax),%eax
c0105c07:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0105c0a:	0f 94 c0             	sete   %al
c0105c0d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105c10:	85 c0                	test   %eax,%eax
c0105c12:	75 24                	jne    c0105c38 <default_check+0x1d0>
c0105c14:	c7 44 24 0c ff 7c 10 	movl   $0xc0107cff,0xc(%esp)
c0105c1b:	c0 
c0105c1c:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105c23:	c0 
c0105c24:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
c0105c2b:	00 
c0105c2c:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105c33:	e8 c1 a7 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0105c38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105c3f:	e8 8c d1 ff ff       	call   c0102dd0 <alloc_pages>
c0105c44:	85 c0                	test   %eax,%eax
c0105c46:	74 24                	je     c0105c6c <default_check+0x204>
c0105c48:	c7 44 24 0c 16 7d 10 	movl   $0xc0107d16,0xc(%esp)
c0105c4f:	c0 
c0105c50:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105c57:	c0 
c0105c58:	c7 44 24 04 af 01 00 	movl   $0x1af,0x4(%esp)
c0105c5f:	00 
c0105c60:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105c67:	e8 8d a7 ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c0105c6c:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c0105c71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0105c74:	c7 05 48 c1 16 c0 00 	movl   $0x0,0xc016c148
c0105c7b:	00 00 00 

    free_pages(p0 + 2, 3);
c0105c7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c81:	83 c0 28             	add    $0x28,%eax
c0105c84:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105c8b:	00 
c0105c8c:	89 04 24             	mov    %eax,(%esp)
c0105c8f:	e8 74 d1 ff ff       	call   c0102e08 <free_pages>
    assert(alloc_pages(4) == NULL);
c0105c94:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0105c9b:	e8 30 d1 ff ff       	call   c0102dd0 <alloc_pages>
c0105ca0:	85 c0                	test   %eax,%eax
c0105ca2:	74 24                	je     c0105cc8 <default_check+0x260>
c0105ca4:	c7 44 24 0c bc 7d 10 	movl   $0xc0107dbc,0xc(%esp)
c0105cab:	c0 
c0105cac:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105cb3:	c0 
c0105cb4:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
c0105cbb:	00 
c0105cbc:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105cc3:	e8 31 a7 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0105cc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ccb:	83 c0 28             	add    $0x28,%eax
c0105cce:	83 c0 04             	add    $0x4,%eax
c0105cd1:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0105cd8:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105cdb:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105cde:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105ce1:	0f a3 10             	bt     %edx,(%eax)
c0105ce4:	19 c0                	sbb    %eax,%eax
c0105ce6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0105ce9:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0105ced:	0f 95 c0             	setne  %al
c0105cf0:	0f b6 c0             	movzbl %al,%eax
c0105cf3:	85 c0                	test   %eax,%eax
c0105cf5:	74 0e                	je     c0105d05 <default_check+0x29d>
c0105cf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cfa:	83 c0 28             	add    $0x28,%eax
c0105cfd:	8b 40 08             	mov    0x8(%eax),%eax
c0105d00:	83 f8 03             	cmp    $0x3,%eax
c0105d03:	74 24                	je     c0105d29 <default_check+0x2c1>
c0105d05:	c7 44 24 0c d4 7d 10 	movl   $0xc0107dd4,0xc(%esp)
c0105d0c:	c0 
c0105d0d:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105d14:	c0 
c0105d15:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c0105d1c:	00 
c0105d1d:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105d24:	e8 d0 a6 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105d29:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105d30:	e8 9b d0 ff ff       	call   c0102dd0 <alloc_pages>
c0105d35:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105d38:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105d3c:	75 24                	jne    c0105d62 <default_check+0x2fa>
c0105d3e:	c7 44 24 0c 00 7e 10 	movl   $0xc0107e00,0xc(%esp)
c0105d45:	c0 
c0105d46:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105d4d:	c0 
c0105d4e:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c0105d55:	00 
c0105d56:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105d5d:	e8 97 a6 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0105d62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105d69:	e8 62 d0 ff ff       	call   c0102dd0 <alloc_pages>
c0105d6e:	85 c0                	test   %eax,%eax
c0105d70:	74 24                	je     c0105d96 <default_check+0x32e>
c0105d72:	c7 44 24 0c 16 7d 10 	movl   $0xc0107d16,0xc(%esp)
c0105d79:	c0 
c0105d7a:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105d81:	c0 
c0105d82:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
c0105d89:	00 
c0105d8a:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105d91:	e8 63 a6 ff ff       	call   c01003f9 <__panic>
    assert(p0 + 2 == p1);
c0105d96:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d99:	83 c0 28             	add    $0x28,%eax
c0105d9c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105d9f:	74 24                	je     c0105dc5 <default_check+0x35d>
c0105da1:	c7 44 24 0c 1e 7e 10 	movl   $0xc0107e1e,0xc(%esp)
c0105da8:	c0 
c0105da9:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105db0:	c0 
c0105db1:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
c0105db8:	00 
c0105db9:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105dc0:	e8 34 a6 ff ff       	call   c01003f9 <__panic>

    p2 = p0 + 1;
c0105dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dc8:	83 c0 14             	add    $0x14,%eax
c0105dcb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0105dce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105dd5:	00 
c0105dd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dd9:	89 04 24             	mov    %eax,(%esp)
c0105ddc:	e8 27 d0 ff ff       	call   c0102e08 <free_pages>
    free_pages(p1, 3);
c0105de1:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105de8:	00 
c0105de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105dec:	89 04 24             	mov    %eax,(%esp)
c0105def:	e8 14 d0 ff ff       	call   c0102e08 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105df4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105df7:	83 c0 04             	add    $0x4,%eax
c0105dfa:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105e01:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105e04:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105e07:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0105e0a:	0f a3 10             	bt     %edx,(%eax)
c0105e0d:	19 c0                	sbb    %eax,%eax
c0105e0f:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105e12:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105e16:	0f 95 c0             	setne  %al
c0105e19:	0f b6 c0             	movzbl %al,%eax
c0105e1c:	85 c0                	test   %eax,%eax
c0105e1e:	74 0b                	je     c0105e2b <default_check+0x3c3>
c0105e20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e23:	8b 40 08             	mov    0x8(%eax),%eax
c0105e26:	83 f8 01             	cmp    $0x1,%eax
c0105e29:	74 24                	je     c0105e4f <default_check+0x3e7>
c0105e2b:	c7 44 24 0c 2c 7e 10 	movl   $0xc0107e2c,0xc(%esp)
c0105e32:	c0 
c0105e33:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105e3a:	c0 
c0105e3b:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
c0105e42:	00 
c0105e43:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105e4a:	e8 aa a5 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e52:	83 c0 04             	add    $0x4,%eax
c0105e55:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0105e5c:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105e5f:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105e62:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105e65:	0f a3 10             	bt     %edx,(%eax)
c0105e68:	19 c0                	sbb    %eax,%eax
c0105e6a:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0105e6d:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105e71:	0f 95 c0             	setne  %al
c0105e74:	0f b6 c0             	movzbl %al,%eax
c0105e77:	85 c0                	test   %eax,%eax
c0105e79:	74 0b                	je     c0105e86 <default_check+0x41e>
c0105e7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e7e:	8b 40 08             	mov    0x8(%eax),%eax
c0105e81:	83 f8 03             	cmp    $0x3,%eax
c0105e84:	74 24                	je     c0105eaa <default_check+0x442>
c0105e86:	c7 44 24 0c 54 7e 10 	movl   $0xc0107e54,0xc(%esp)
c0105e8d:	c0 
c0105e8e:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105e95:	c0 
c0105e96:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
c0105e9d:	00 
c0105e9e:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105ea5:	e8 4f a5 ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105eaa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105eb1:	e8 1a cf ff ff       	call   c0102dd0 <alloc_pages>
c0105eb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105eb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ebc:	83 e8 14             	sub    $0x14,%eax
c0105ebf:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105ec2:	74 24                	je     c0105ee8 <default_check+0x480>
c0105ec4:	c7 44 24 0c 7a 7e 10 	movl   $0xc0107e7a,0xc(%esp)
c0105ecb:	c0 
c0105ecc:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105ed3:	c0 
c0105ed4:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
c0105edb:	00 
c0105edc:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105ee3:	e8 11 a5 ff ff       	call   c01003f9 <__panic>
    free_page(p0);
c0105ee8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105eef:	00 
c0105ef0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ef3:	89 04 24             	mov    %eax,(%esp)
c0105ef6:	e8 0d cf ff ff       	call   c0102e08 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0105efb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105f02:	e8 c9 ce ff ff       	call   c0102dd0 <alloc_pages>
c0105f07:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f0d:	83 c0 14             	add    $0x14,%eax
c0105f10:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105f13:	74 24                	je     c0105f39 <default_check+0x4d1>
c0105f15:	c7 44 24 0c 98 7e 10 	movl   $0xc0107e98,0xc(%esp)
c0105f1c:	c0 
c0105f1d:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105f24:	c0 
c0105f25:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c0105f2c:	00 
c0105f2d:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105f34:	e8 c0 a4 ff ff       	call   c01003f9 <__panic>

    free_pages(p0, 2);
c0105f39:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105f40:	00 
c0105f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f44:	89 04 24             	mov    %eax,(%esp)
c0105f47:	e8 bc ce ff ff       	call   c0102e08 <free_pages>
    free_page(p2);
c0105f4c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105f53:	00 
c0105f54:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f57:	89 04 24             	mov    %eax,(%esp)
c0105f5a:	e8 a9 ce ff ff       	call   c0102e08 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105f5f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105f66:	e8 65 ce ff ff       	call   c0102dd0 <alloc_pages>
c0105f6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105f6e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105f72:	75 24                	jne    c0105f98 <default_check+0x530>
c0105f74:	c7 44 24 0c b8 7e 10 	movl   $0xc0107eb8,0xc(%esp)
c0105f7b:	c0 
c0105f7c:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105f83:	c0 
c0105f84:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
c0105f8b:	00 
c0105f8c:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105f93:	e8 61 a4 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0105f98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f9f:	e8 2c ce ff ff       	call   c0102dd0 <alloc_pages>
c0105fa4:	85 c0                	test   %eax,%eax
c0105fa6:	74 24                	je     c0105fcc <default_check+0x564>
c0105fa8:	c7 44 24 0c 16 7d 10 	movl   $0xc0107d16,0xc(%esp)
c0105faf:	c0 
c0105fb0:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105fb7:	c0 
c0105fb8:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
c0105fbf:	00 
c0105fc0:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105fc7:	e8 2d a4 ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c0105fcc:	a1 48 c1 16 c0       	mov    0xc016c148,%eax
c0105fd1:	85 c0                	test   %eax,%eax
c0105fd3:	74 24                	je     c0105ff9 <default_check+0x591>
c0105fd5:	c7 44 24 0c 69 7d 10 	movl   $0xc0107d69,0xc(%esp)
c0105fdc:	c0 
c0105fdd:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0105fe4:	c0 
c0105fe5:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
c0105fec:	00 
c0105fed:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0105ff4:	e8 00 a4 ff ff       	call   c01003f9 <__panic>
    nr_free = nr_free_store;
c0105ff9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ffc:	a3 48 c1 16 c0       	mov    %eax,0xc016c148

    free_list = free_list_store;
c0106001:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106004:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106007:	a3 40 c1 16 c0       	mov    %eax,0xc016c140
c010600c:	89 15 44 c1 16 c0    	mov    %edx,0xc016c144
    free_pages(p0, 5);
c0106012:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0106019:	00 
c010601a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010601d:	89 04 24             	mov    %eax,(%esp)
c0106020:	e8 e3 cd ff ff       	call   c0102e08 <free_pages>

    le = &free_list;
c0106025:	c7 45 ec 40 c1 16 c0 	movl   $0xc016c140,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010602c:	eb 5a                	jmp    c0106088 <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c010602e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106031:	8b 40 04             	mov    0x4(%eax),%eax
c0106034:	8b 00                	mov    (%eax),%eax
c0106036:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106039:	75 0d                	jne    c0106048 <default_check+0x5e0>
c010603b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010603e:	8b 00                	mov    (%eax),%eax
c0106040:	8b 40 04             	mov    0x4(%eax),%eax
c0106043:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0106046:	74 24                	je     c010606c <default_check+0x604>
c0106048:	c7 44 24 0c d8 7e 10 	movl   $0xc0107ed8,0xc(%esp)
c010604f:	c0 
c0106050:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c0106057:	c0 
c0106058:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c010605f:	00 
c0106060:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c0106067:	e8 8d a3 ff ff       	call   c01003f9 <__panic>
        struct Page *p = le2page(le, page_link);
c010606c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010606f:	83 e8 0c             	sub    $0xc,%eax
c0106072:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0106075:	ff 4d f4             	decl   -0xc(%ebp)
c0106078:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010607b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010607e:	8b 40 08             	mov    0x8(%eax),%eax
c0106081:	29 c2                	sub    %eax,%edx
c0106083:	89 d0                	mov    %edx,%eax
c0106085:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106088:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010608b:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010608e:	8b 45 88             	mov    -0x78(%ebp),%eax
c0106091:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106094:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106097:	81 7d ec 40 c1 16 c0 	cmpl   $0xc016c140,-0x14(%ebp)
c010609e:	75 8e                	jne    c010602e <default_check+0x5c6>
    }
    assert(count == 0);
c01060a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01060a4:	74 24                	je     c01060ca <default_check+0x662>
c01060a6:	c7 44 24 0c 05 7f 10 	movl   $0xc0107f05,0xc(%esp)
c01060ad:	c0 
c01060ae:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01060b5:	c0 
c01060b6:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c01060bd:	00 
c01060be:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01060c5:	e8 2f a3 ff ff       	call   c01003f9 <__panic>
    assert(total == 0);
c01060ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01060ce:	74 24                	je     c01060f4 <default_check+0x68c>
c01060d0:	c7 44 24 0c 10 7f 10 	movl   $0xc0107f10,0xc(%esp)
c01060d7:	c0 
c01060d8:	c7 44 24 08 a6 7b 10 	movl   $0xc0107ba6,0x8(%esp)
c01060df:	c0 
c01060e0:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c01060e7:	00 
c01060e8:	c7 04 24 bb 7b 10 c0 	movl   $0xc0107bbb,(%esp)
c01060ef:	e8 05 a3 ff ff       	call   c01003f9 <__panic>
}
c01060f4:	90                   	nop
c01060f5:	c9                   	leave  
c01060f6:	c3                   	ret    

c01060f7 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01060f7:	55                   	push   %ebp
c01060f8:	89 e5                	mov    %esp,%ebp
c01060fa:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01060fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106104:	eb 03                	jmp    c0106109 <strlen+0x12>
        cnt ++;
c0106106:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0106109:	8b 45 08             	mov    0x8(%ebp),%eax
c010610c:	8d 50 01             	lea    0x1(%eax),%edx
c010610f:	89 55 08             	mov    %edx,0x8(%ebp)
c0106112:	0f b6 00             	movzbl (%eax),%eax
c0106115:	84 c0                	test   %al,%al
c0106117:	75 ed                	jne    c0106106 <strlen+0xf>
    }
    return cnt;
c0106119:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010611c:	c9                   	leave  
c010611d:	c3                   	ret    

c010611e <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010611e:	55                   	push   %ebp
c010611f:	89 e5                	mov    %esp,%ebp
c0106121:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106124:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010612b:	eb 03                	jmp    c0106130 <strnlen+0x12>
        cnt ++;
c010612d:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106130:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106133:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106136:	73 10                	jae    c0106148 <strnlen+0x2a>
c0106138:	8b 45 08             	mov    0x8(%ebp),%eax
c010613b:	8d 50 01             	lea    0x1(%eax),%edx
c010613e:	89 55 08             	mov    %edx,0x8(%ebp)
c0106141:	0f b6 00             	movzbl (%eax),%eax
c0106144:	84 c0                	test   %al,%al
c0106146:	75 e5                	jne    c010612d <strnlen+0xf>
    }
    return cnt;
c0106148:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010614b:	c9                   	leave  
c010614c:	c3                   	ret    

c010614d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010614d:	55                   	push   %ebp
c010614e:	89 e5                	mov    %esp,%ebp
c0106150:	57                   	push   %edi
c0106151:	56                   	push   %esi
c0106152:	83 ec 20             	sub    $0x20,%esp
c0106155:	8b 45 08             	mov    0x8(%ebp),%eax
c0106158:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010615b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010615e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0106161:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106164:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106167:	89 d1                	mov    %edx,%ecx
c0106169:	89 c2                	mov    %eax,%edx
c010616b:	89 ce                	mov    %ecx,%esi
c010616d:	89 d7                	mov    %edx,%edi
c010616f:	ac                   	lods   %ds:(%esi),%al
c0106170:	aa                   	stos   %al,%es:(%edi)
c0106171:	84 c0                	test   %al,%al
c0106173:	75 fa                	jne    c010616f <strcpy+0x22>
c0106175:	89 fa                	mov    %edi,%edx
c0106177:	89 f1                	mov    %esi,%ecx
c0106179:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010617c:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010617f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0106182:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0106185:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0106186:	83 c4 20             	add    $0x20,%esp
c0106189:	5e                   	pop    %esi
c010618a:	5f                   	pop    %edi
c010618b:	5d                   	pop    %ebp
c010618c:	c3                   	ret    

c010618d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010618d:	55                   	push   %ebp
c010618e:	89 e5                	mov    %esp,%ebp
c0106190:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106193:	8b 45 08             	mov    0x8(%ebp),%eax
c0106196:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0106199:	eb 1e                	jmp    c01061b9 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010619b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010619e:	0f b6 10             	movzbl (%eax),%edx
c01061a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061a4:	88 10                	mov    %dl,(%eax)
c01061a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061a9:	0f b6 00             	movzbl (%eax),%eax
c01061ac:	84 c0                	test   %al,%al
c01061ae:	74 03                	je     c01061b3 <strncpy+0x26>
            src ++;
c01061b0:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c01061b3:	ff 45 fc             	incl   -0x4(%ebp)
c01061b6:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c01061b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01061bd:	75 dc                	jne    c010619b <strncpy+0xe>
    }
    return dst;
c01061bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01061c2:	c9                   	leave  
c01061c3:	c3                   	ret    

c01061c4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01061c4:	55                   	push   %ebp
c01061c5:	89 e5                	mov    %esp,%ebp
c01061c7:	57                   	push   %edi
c01061c8:	56                   	push   %esi
c01061c9:	83 ec 20             	sub    $0x20,%esp
c01061cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01061cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01061d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01061d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01061db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061de:	89 d1                	mov    %edx,%ecx
c01061e0:	89 c2                	mov    %eax,%edx
c01061e2:	89 ce                	mov    %ecx,%esi
c01061e4:	89 d7                	mov    %edx,%edi
c01061e6:	ac                   	lods   %ds:(%esi),%al
c01061e7:	ae                   	scas   %es:(%edi),%al
c01061e8:	75 08                	jne    c01061f2 <strcmp+0x2e>
c01061ea:	84 c0                	test   %al,%al
c01061ec:	75 f8                	jne    c01061e6 <strcmp+0x22>
c01061ee:	31 c0                	xor    %eax,%eax
c01061f0:	eb 04                	jmp    c01061f6 <strcmp+0x32>
c01061f2:	19 c0                	sbb    %eax,%eax
c01061f4:	0c 01                	or     $0x1,%al
c01061f6:	89 fa                	mov    %edi,%edx
c01061f8:	89 f1                	mov    %esi,%ecx
c01061fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01061fd:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106200:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0106203:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0106206:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0106207:	83 c4 20             	add    $0x20,%esp
c010620a:	5e                   	pop    %esi
c010620b:	5f                   	pop    %edi
c010620c:	5d                   	pop    %ebp
c010620d:	c3                   	ret    

c010620e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010620e:	55                   	push   %ebp
c010620f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106211:	eb 09                	jmp    c010621c <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0106213:	ff 4d 10             	decl   0x10(%ebp)
c0106216:	ff 45 08             	incl   0x8(%ebp)
c0106219:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010621c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106220:	74 1a                	je     c010623c <strncmp+0x2e>
c0106222:	8b 45 08             	mov    0x8(%ebp),%eax
c0106225:	0f b6 00             	movzbl (%eax),%eax
c0106228:	84 c0                	test   %al,%al
c010622a:	74 10                	je     c010623c <strncmp+0x2e>
c010622c:	8b 45 08             	mov    0x8(%ebp),%eax
c010622f:	0f b6 10             	movzbl (%eax),%edx
c0106232:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106235:	0f b6 00             	movzbl (%eax),%eax
c0106238:	38 c2                	cmp    %al,%dl
c010623a:	74 d7                	je     c0106213 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010623c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106240:	74 18                	je     c010625a <strncmp+0x4c>
c0106242:	8b 45 08             	mov    0x8(%ebp),%eax
c0106245:	0f b6 00             	movzbl (%eax),%eax
c0106248:	0f b6 d0             	movzbl %al,%edx
c010624b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010624e:	0f b6 00             	movzbl (%eax),%eax
c0106251:	0f b6 c0             	movzbl %al,%eax
c0106254:	29 c2                	sub    %eax,%edx
c0106256:	89 d0                	mov    %edx,%eax
c0106258:	eb 05                	jmp    c010625f <strncmp+0x51>
c010625a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010625f:	5d                   	pop    %ebp
c0106260:	c3                   	ret    

c0106261 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0106261:	55                   	push   %ebp
c0106262:	89 e5                	mov    %esp,%ebp
c0106264:	83 ec 04             	sub    $0x4,%esp
c0106267:	8b 45 0c             	mov    0xc(%ebp),%eax
c010626a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010626d:	eb 13                	jmp    c0106282 <strchr+0x21>
        if (*s == c) {
c010626f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106272:	0f b6 00             	movzbl (%eax),%eax
c0106275:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0106278:	75 05                	jne    c010627f <strchr+0x1e>
            return (char *)s;
c010627a:	8b 45 08             	mov    0x8(%ebp),%eax
c010627d:	eb 12                	jmp    c0106291 <strchr+0x30>
        }
        s ++;
c010627f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106282:	8b 45 08             	mov    0x8(%ebp),%eax
c0106285:	0f b6 00             	movzbl (%eax),%eax
c0106288:	84 c0                	test   %al,%al
c010628a:	75 e3                	jne    c010626f <strchr+0xe>
    }
    return NULL;
c010628c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106291:	c9                   	leave  
c0106292:	c3                   	ret    

c0106293 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0106293:	55                   	push   %ebp
c0106294:	89 e5                	mov    %esp,%ebp
c0106296:	83 ec 04             	sub    $0x4,%esp
c0106299:	8b 45 0c             	mov    0xc(%ebp),%eax
c010629c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010629f:	eb 0e                	jmp    c01062af <strfind+0x1c>
        if (*s == c) {
c01062a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01062a4:	0f b6 00             	movzbl (%eax),%eax
c01062a7:	38 45 fc             	cmp    %al,-0x4(%ebp)
c01062aa:	74 0f                	je     c01062bb <strfind+0x28>
            break;
        }
        s ++;
c01062ac:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c01062af:	8b 45 08             	mov    0x8(%ebp),%eax
c01062b2:	0f b6 00             	movzbl (%eax),%eax
c01062b5:	84 c0                	test   %al,%al
c01062b7:	75 e8                	jne    c01062a1 <strfind+0xe>
c01062b9:	eb 01                	jmp    c01062bc <strfind+0x29>
            break;
c01062bb:	90                   	nop
    }
    return (char *)s;
c01062bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01062bf:	c9                   	leave  
c01062c0:	c3                   	ret    

c01062c1 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01062c1:	55                   	push   %ebp
c01062c2:	89 e5                	mov    %esp,%ebp
c01062c4:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01062c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01062ce:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01062d5:	eb 03                	jmp    c01062da <strtol+0x19>
        s ++;
c01062d7:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c01062da:	8b 45 08             	mov    0x8(%ebp),%eax
c01062dd:	0f b6 00             	movzbl (%eax),%eax
c01062e0:	3c 20                	cmp    $0x20,%al
c01062e2:	74 f3                	je     c01062d7 <strtol+0x16>
c01062e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01062e7:	0f b6 00             	movzbl (%eax),%eax
c01062ea:	3c 09                	cmp    $0x9,%al
c01062ec:	74 e9                	je     c01062d7 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01062ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01062f1:	0f b6 00             	movzbl (%eax),%eax
c01062f4:	3c 2b                	cmp    $0x2b,%al
c01062f6:	75 05                	jne    c01062fd <strtol+0x3c>
        s ++;
c01062f8:	ff 45 08             	incl   0x8(%ebp)
c01062fb:	eb 14                	jmp    c0106311 <strtol+0x50>
    }
    else if (*s == '-') {
c01062fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106300:	0f b6 00             	movzbl (%eax),%eax
c0106303:	3c 2d                	cmp    $0x2d,%al
c0106305:	75 0a                	jne    c0106311 <strtol+0x50>
        s ++, neg = 1;
c0106307:	ff 45 08             	incl   0x8(%ebp)
c010630a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106311:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106315:	74 06                	je     c010631d <strtol+0x5c>
c0106317:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010631b:	75 22                	jne    c010633f <strtol+0x7e>
c010631d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106320:	0f b6 00             	movzbl (%eax),%eax
c0106323:	3c 30                	cmp    $0x30,%al
c0106325:	75 18                	jne    c010633f <strtol+0x7e>
c0106327:	8b 45 08             	mov    0x8(%ebp),%eax
c010632a:	40                   	inc    %eax
c010632b:	0f b6 00             	movzbl (%eax),%eax
c010632e:	3c 78                	cmp    $0x78,%al
c0106330:	75 0d                	jne    c010633f <strtol+0x7e>
        s += 2, base = 16;
c0106332:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0106336:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010633d:	eb 29                	jmp    c0106368 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010633f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106343:	75 16                	jne    c010635b <strtol+0x9a>
c0106345:	8b 45 08             	mov    0x8(%ebp),%eax
c0106348:	0f b6 00             	movzbl (%eax),%eax
c010634b:	3c 30                	cmp    $0x30,%al
c010634d:	75 0c                	jne    c010635b <strtol+0x9a>
        s ++, base = 8;
c010634f:	ff 45 08             	incl   0x8(%ebp)
c0106352:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0106359:	eb 0d                	jmp    c0106368 <strtol+0xa7>
    }
    else if (base == 0) {
c010635b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010635f:	75 07                	jne    c0106368 <strtol+0xa7>
        base = 10;
c0106361:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0106368:	8b 45 08             	mov    0x8(%ebp),%eax
c010636b:	0f b6 00             	movzbl (%eax),%eax
c010636e:	3c 2f                	cmp    $0x2f,%al
c0106370:	7e 1b                	jle    c010638d <strtol+0xcc>
c0106372:	8b 45 08             	mov    0x8(%ebp),%eax
c0106375:	0f b6 00             	movzbl (%eax),%eax
c0106378:	3c 39                	cmp    $0x39,%al
c010637a:	7f 11                	jg     c010638d <strtol+0xcc>
            dig = *s - '0';
c010637c:	8b 45 08             	mov    0x8(%ebp),%eax
c010637f:	0f b6 00             	movzbl (%eax),%eax
c0106382:	0f be c0             	movsbl %al,%eax
c0106385:	83 e8 30             	sub    $0x30,%eax
c0106388:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010638b:	eb 48                	jmp    c01063d5 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010638d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106390:	0f b6 00             	movzbl (%eax),%eax
c0106393:	3c 60                	cmp    $0x60,%al
c0106395:	7e 1b                	jle    c01063b2 <strtol+0xf1>
c0106397:	8b 45 08             	mov    0x8(%ebp),%eax
c010639a:	0f b6 00             	movzbl (%eax),%eax
c010639d:	3c 7a                	cmp    $0x7a,%al
c010639f:	7f 11                	jg     c01063b2 <strtol+0xf1>
            dig = *s - 'a' + 10;
c01063a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01063a4:	0f b6 00             	movzbl (%eax),%eax
c01063a7:	0f be c0             	movsbl %al,%eax
c01063aa:	83 e8 57             	sub    $0x57,%eax
c01063ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01063b0:	eb 23                	jmp    c01063d5 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01063b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01063b5:	0f b6 00             	movzbl (%eax),%eax
c01063b8:	3c 40                	cmp    $0x40,%al
c01063ba:	7e 3b                	jle    c01063f7 <strtol+0x136>
c01063bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01063bf:	0f b6 00             	movzbl (%eax),%eax
c01063c2:	3c 5a                	cmp    $0x5a,%al
c01063c4:	7f 31                	jg     c01063f7 <strtol+0x136>
            dig = *s - 'A' + 10;
c01063c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01063c9:	0f b6 00             	movzbl (%eax),%eax
c01063cc:	0f be c0             	movsbl %al,%eax
c01063cf:	83 e8 37             	sub    $0x37,%eax
c01063d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01063d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063d8:	3b 45 10             	cmp    0x10(%ebp),%eax
c01063db:	7d 19                	jge    c01063f6 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01063dd:	ff 45 08             	incl   0x8(%ebp)
c01063e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01063e3:	0f af 45 10          	imul   0x10(%ebp),%eax
c01063e7:	89 c2                	mov    %eax,%edx
c01063e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063ec:	01 d0                	add    %edx,%eax
c01063ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c01063f1:	e9 72 ff ff ff       	jmp    c0106368 <strtol+0xa7>
            break;
c01063f6:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01063f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01063fb:	74 08                	je     c0106405 <strtol+0x144>
        *endptr = (char *) s;
c01063fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106400:	8b 55 08             	mov    0x8(%ebp),%edx
c0106403:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106405:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106409:	74 07                	je     c0106412 <strtol+0x151>
c010640b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010640e:	f7 d8                	neg    %eax
c0106410:	eb 03                	jmp    c0106415 <strtol+0x154>
c0106412:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106415:	c9                   	leave  
c0106416:	c3                   	ret    

c0106417 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106417:	55                   	push   %ebp
c0106418:	89 e5                	mov    %esp,%ebp
c010641a:	57                   	push   %edi
c010641b:	83 ec 24             	sub    $0x24,%esp
c010641e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106421:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106424:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0106428:	8b 55 08             	mov    0x8(%ebp),%edx
c010642b:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010642e:	88 45 f7             	mov    %al,-0x9(%ebp)
c0106431:	8b 45 10             	mov    0x10(%ebp),%eax
c0106434:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106437:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010643a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010643e:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106441:	89 d7                	mov    %edx,%edi
c0106443:	f3 aa                	rep stos %al,%es:(%edi)
c0106445:	89 fa                	mov    %edi,%edx
c0106447:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010644a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010644d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106450:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106451:	83 c4 24             	add    $0x24,%esp
c0106454:	5f                   	pop    %edi
c0106455:	5d                   	pop    %ebp
c0106456:	c3                   	ret    

c0106457 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0106457:	55                   	push   %ebp
c0106458:	89 e5                	mov    %esp,%ebp
c010645a:	57                   	push   %edi
c010645b:	56                   	push   %esi
c010645c:	53                   	push   %ebx
c010645d:	83 ec 30             	sub    $0x30,%esp
c0106460:	8b 45 08             	mov    0x8(%ebp),%eax
c0106463:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106466:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106469:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010646c:	8b 45 10             	mov    0x10(%ebp),%eax
c010646f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0106472:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106475:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106478:	73 42                	jae    c01064bc <memmove+0x65>
c010647a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010647d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106480:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106483:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106486:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106489:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010648c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010648f:	c1 e8 02             	shr    $0x2,%eax
c0106492:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106494:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106497:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010649a:	89 d7                	mov    %edx,%edi
c010649c:	89 c6                	mov    %eax,%esi
c010649e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01064a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01064a3:	83 e1 03             	and    $0x3,%ecx
c01064a6:	74 02                	je     c01064aa <memmove+0x53>
c01064a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01064aa:	89 f0                	mov    %esi,%eax
c01064ac:	89 fa                	mov    %edi,%edx
c01064ae:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01064b1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01064b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c01064b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c01064ba:	eb 36                	jmp    c01064f2 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01064bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064bf:	8d 50 ff             	lea    -0x1(%eax),%edx
c01064c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01064c5:	01 c2                	add    %eax,%edx
c01064c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064ca:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01064cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064d0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c01064d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064d6:	89 c1                	mov    %eax,%ecx
c01064d8:	89 d8                	mov    %ebx,%eax
c01064da:	89 d6                	mov    %edx,%esi
c01064dc:	89 c7                	mov    %eax,%edi
c01064de:	fd                   	std    
c01064df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01064e1:	fc                   	cld    
c01064e2:	89 f8                	mov    %edi,%eax
c01064e4:	89 f2                	mov    %esi,%edx
c01064e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01064e9:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01064ec:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01064ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01064f2:	83 c4 30             	add    $0x30,%esp
c01064f5:	5b                   	pop    %ebx
c01064f6:	5e                   	pop    %esi
c01064f7:	5f                   	pop    %edi
c01064f8:	5d                   	pop    %ebp
c01064f9:	c3                   	ret    

c01064fa <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01064fa:	55                   	push   %ebp
c01064fb:	89 e5                	mov    %esp,%ebp
c01064fd:	57                   	push   %edi
c01064fe:	56                   	push   %esi
c01064ff:	83 ec 20             	sub    $0x20,%esp
c0106502:	8b 45 08             	mov    0x8(%ebp),%eax
c0106505:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106508:	8b 45 0c             	mov    0xc(%ebp),%eax
c010650b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010650e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106511:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106514:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106517:	c1 e8 02             	shr    $0x2,%eax
c010651a:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010651c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010651f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106522:	89 d7                	mov    %edx,%edi
c0106524:	89 c6                	mov    %eax,%esi
c0106526:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106528:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010652b:	83 e1 03             	and    $0x3,%ecx
c010652e:	74 02                	je     c0106532 <memcpy+0x38>
c0106530:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106532:	89 f0                	mov    %esi,%eax
c0106534:	89 fa                	mov    %edi,%edx
c0106536:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106539:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010653c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010653f:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0106542:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106543:	83 c4 20             	add    $0x20,%esp
c0106546:	5e                   	pop    %esi
c0106547:	5f                   	pop    %edi
c0106548:	5d                   	pop    %ebp
c0106549:	c3                   	ret    

c010654a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010654a:	55                   	push   %ebp
c010654b:	89 e5                	mov    %esp,%ebp
c010654d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106550:	8b 45 08             	mov    0x8(%ebp),%eax
c0106553:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0106556:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106559:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010655c:	eb 2e                	jmp    c010658c <memcmp+0x42>
        if (*s1 != *s2) {
c010655e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106561:	0f b6 10             	movzbl (%eax),%edx
c0106564:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106567:	0f b6 00             	movzbl (%eax),%eax
c010656a:	38 c2                	cmp    %al,%dl
c010656c:	74 18                	je     c0106586 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010656e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106571:	0f b6 00             	movzbl (%eax),%eax
c0106574:	0f b6 d0             	movzbl %al,%edx
c0106577:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010657a:	0f b6 00             	movzbl (%eax),%eax
c010657d:	0f b6 c0             	movzbl %al,%eax
c0106580:	29 c2                	sub    %eax,%edx
c0106582:	89 d0                	mov    %edx,%eax
c0106584:	eb 18                	jmp    c010659e <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0106586:	ff 45 fc             	incl   -0x4(%ebp)
c0106589:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010658c:	8b 45 10             	mov    0x10(%ebp),%eax
c010658f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106592:	89 55 10             	mov    %edx,0x10(%ebp)
c0106595:	85 c0                	test   %eax,%eax
c0106597:	75 c5                	jne    c010655e <memcmp+0x14>
    }
    return 0;
c0106599:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010659e:	c9                   	leave  
c010659f:	c3                   	ret    

c01065a0 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01065a0:	55                   	push   %ebp
c01065a1:	89 e5                	mov    %esp,%ebp
c01065a3:	83 ec 58             	sub    $0x58,%esp
c01065a6:	8b 45 10             	mov    0x10(%ebp),%eax
c01065a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01065ac:	8b 45 14             	mov    0x14(%ebp),%eax
c01065af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01065b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01065b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01065b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01065bb:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01065be:	8b 45 18             	mov    0x18(%ebp),%eax
c01065c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01065c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01065ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01065cd:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01065d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01065d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01065da:	74 1c                	je     c01065f8 <printnum+0x58>
c01065dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065df:	ba 00 00 00 00       	mov    $0x0,%edx
c01065e4:	f7 75 e4             	divl   -0x1c(%ebp)
c01065e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01065ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065ed:	ba 00 00 00 00       	mov    $0x0,%edx
c01065f2:	f7 75 e4             	divl   -0x1c(%ebp)
c01065f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01065fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065fe:	f7 75 e4             	divl   -0x1c(%ebp)
c0106601:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106604:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106607:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010660a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010660d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106610:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106613:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106616:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0106619:	8b 45 18             	mov    0x18(%ebp),%eax
c010661c:	ba 00 00 00 00       	mov    $0x0,%edx
c0106621:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0106624:	72 56                	jb     c010667c <printnum+0xdc>
c0106626:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0106629:	77 05                	ja     c0106630 <printnum+0x90>
c010662b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010662e:	72 4c                	jb     c010667c <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106630:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106633:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106636:	8b 45 20             	mov    0x20(%ebp),%eax
c0106639:	89 44 24 18          	mov    %eax,0x18(%esp)
c010663d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106641:	8b 45 18             	mov    0x18(%ebp),%eax
c0106644:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106648:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010664b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010664e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106652:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106656:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106659:	89 44 24 04          	mov    %eax,0x4(%esp)
c010665d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106660:	89 04 24             	mov    %eax,(%esp)
c0106663:	e8 38 ff ff ff       	call   c01065a0 <printnum>
c0106668:	eb 1b                	jmp    c0106685 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010666a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010666d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106671:	8b 45 20             	mov    0x20(%ebp),%eax
c0106674:	89 04 24             	mov    %eax,(%esp)
c0106677:	8b 45 08             	mov    0x8(%ebp),%eax
c010667a:	ff d0                	call   *%eax
        while (-- width > 0)
c010667c:	ff 4d 1c             	decl   0x1c(%ebp)
c010667f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106683:	7f e5                	jg     c010666a <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0106685:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106688:	05 cc 7f 10 c0       	add    $0xc0107fcc,%eax
c010668d:	0f b6 00             	movzbl (%eax),%eax
c0106690:	0f be c0             	movsbl %al,%eax
c0106693:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106696:	89 54 24 04          	mov    %edx,0x4(%esp)
c010669a:	89 04 24             	mov    %eax,(%esp)
c010669d:	8b 45 08             	mov    0x8(%ebp),%eax
c01066a0:	ff d0                	call   *%eax
}
c01066a2:	90                   	nop
c01066a3:	c9                   	leave  
c01066a4:	c3                   	ret    

c01066a5 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01066a5:	55                   	push   %ebp
c01066a6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01066a8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01066ac:	7e 14                	jle    c01066c2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01066ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01066b1:	8b 00                	mov    (%eax),%eax
c01066b3:	8d 48 08             	lea    0x8(%eax),%ecx
c01066b6:	8b 55 08             	mov    0x8(%ebp),%edx
c01066b9:	89 0a                	mov    %ecx,(%edx)
c01066bb:	8b 50 04             	mov    0x4(%eax),%edx
c01066be:	8b 00                	mov    (%eax),%eax
c01066c0:	eb 30                	jmp    c01066f2 <getuint+0x4d>
    }
    else if (lflag) {
c01066c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01066c6:	74 16                	je     c01066de <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01066c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01066cb:	8b 00                	mov    (%eax),%eax
c01066cd:	8d 48 04             	lea    0x4(%eax),%ecx
c01066d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01066d3:	89 0a                	mov    %ecx,(%edx)
c01066d5:	8b 00                	mov    (%eax),%eax
c01066d7:	ba 00 00 00 00       	mov    $0x0,%edx
c01066dc:	eb 14                	jmp    c01066f2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01066de:	8b 45 08             	mov    0x8(%ebp),%eax
c01066e1:	8b 00                	mov    (%eax),%eax
c01066e3:	8d 48 04             	lea    0x4(%eax),%ecx
c01066e6:	8b 55 08             	mov    0x8(%ebp),%edx
c01066e9:	89 0a                	mov    %ecx,(%edx)
c01066eb:	8b 00                	mov    (%eax),%eax
c01066ed:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01066f2:	5d                   	pop    %ebp
c01066f3:	c3                   	ret    

c01066f4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01066f4:	55                   	push   %ebp
c01066f5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01066f7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01066fb:	7e 14                	jle    c0106711 <getint+0x1d>
        return va_arg(*ap, long long);
c01066fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106700:	8b 00                	mov    (%eax),%eax
c0106702:	8d 48 08             	lea    0x8(%eax),%ecx
c0106705:	8b 55 08             	mov    0x8(%ebp),%edx
c0106708:	89 0a                	mov    %ecx,(%edx)
c010670a:	8b 50 04             	mov    0x4(%eax),%edx
c010670d:	8b 00                	mov    (%eax),%eax
c010670f:	eb 28                	jmp    c0106739 <getint+0x45>
    }
    else if (lflag) {
c0106711:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106715:	74 12                	je     c0106729 <getint+0x35>
        return va_arg(*ap, long);
c0106717:	8b 45 08             	mov    0x8(%ebp),%eax
c010671a:	8b 00                	mov    (%eax),%eax
c010671c:	8d 48 04             	lea    0x4(%eax),%ecx
c010671f:	8b 55 08             	mov    0x8(%ebp),%edx
c0106722:	89 0a                	mov    %ecx,(%edx)
c0106724:	8b 00                	mov    (%eax),%eax
c0106726:	99                   	cltd   
c0106727:	eb 10                	jmp    c0106739 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0106729:	8b 45 08             	mov    0x8(%ebp),%eax
c010672c:	8b 00                	mov    (%eax),%eax
c010672e:	8d 48 04             	lea    0x4(%eax),%ecx
c0106731:	8b 55 08             	mov    0x8(%ebp),%edx
c0106734:	89 0a                	mov    %ecx,(%edx)
c0106736:	8b 00                	mov    (%eax),%eax
c0106738:	99                   	cltd   
    }
}
c0106739:	5d                   	pop    %ebp
c010673a:	c3                   	ret    

c010673b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010673b:	55                   	push   %ebp
c010673c:	89 e5                	mov    %esp,%ebp
c010673e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106741:	8d 45 14             	lea    0x14(%ebp),%eax
c0106744:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0106747:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010674a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010674e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106751:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106755:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106758:	89 44 24 04          	mov    %eax,0x4(%esp)
c010675c:	8b 45 08             	mov    0x8(%ebp),%eax
c010675f:	89 04 24             	mov    %eax,(%esp)
c0106762:	e8 03 00 00 00       	call   c010676a <vprintfmt>
    va_end(ap);
}
c0106767:	90                   	nop
c0106768:	c9                   	leave  
c0106769:	c3                   	ret    

c010676a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010676a:	55                   	push   %ebp
c010676b:	89 e5                	mov    %esp,%ebp
c010676d:	56                   	push   %esi
c010676e:	53                   	push   %ebx
c010676f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0106772:	eb 17                	jmp    c010678b <vprintfmt+0x21>
            if (ch == '\0') {
c0106774:	85 db                	test   %ebx,%ebx
c0106776:	0f 84 bf 03 00 00    	je     c0106b3b <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010677c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010677f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106783:	89 1c 24             	mov    %ebx,(%esp)
c0106786:	8b 45 08             	mov    0x8(%ebp),%eax
c0106789:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010678b:	8b 45 10             	mov    0x10(%ebp),%eax
c010678e:	8d 50 01             	lea    0x1(%eax),%edx
c0106791:	89 55 10             	mov    %edx,0x10(%ebp)
c0106794:	0f b6 00             	movzbl (%eax),%eax
c0106797:	0f b6 d8             	movzbl %al,%ebx
c010679a:	83 fb 25             	cmp    $0x25,%ebx
c010679d:	75 d5                	jne    c0106774 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010679f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01067a3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01067aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01067b0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01067b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01067ba:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01067bd:	8b 45 10             	mov    0x10(%ebp),%eax
c01067c0:	8d 50 01             	lea    0x1(%eax),%edx
c01067c3:	89 55 10             	mov    %edx,0x10(%ebp)
c01067c6:	0f b6 00             	movzbl (%eax),%eax
c01067c9:	0f b6 d8             	movzbl %al,%ebx
c01067cc:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01067cf:	83 f8 55             	cmp    $0x55,%eax
c01067d2:	0f 87 37 03 00 00    	ja     c0106b0f <vprintfmt+0x3a5>
c01067d8:	8b 04 85 f0 7f 10 c0 	mov    -0x3fef8010(,%eax,4),%eax
c01067df:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01067e1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01067e5:	eb d6                	jmp    c01067bd <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01067e7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01067eb:	eb d0                	jmp    c01067bd <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01067ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01067f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01067f7:	89 d0                	mov    %edx,%eax
c01067f9:	c1 e0 02             	shl    $0x2,%eax
c01067fc:	01 d0                	add    %edx,%eax
c01067fe:	01 c0                	add    %eax,%eax
c0106800:	01 d8                	add    %ebx,%eax
c0106802:	83 e8 30             	sub    $0x30,%eax
c0106805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0106808:	8b 45 10             	mov    0x10(%ebp),%eax
c010680b:	0f b6 00             	movzbl (%eax),%eax
c010680e:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106811:	83 fb 2f             	cmp    $0x2f,%ebx
c0106814:	7e 38                	jle    c010684e <vprintfmt+0xe4>
c0106816:	83 fb 39             	cmp    $0x39,%ebx
c0106819:	7f 33                	jg     c010684e <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c010681b:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010681e:	eb d4                	jmp    c01067f4 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106820:	8b 45 14             	mov    0x14(%ebp),%eax
c0106823:	8d 50 04             	lea    0x4(%eax),%edx
c0106826:	89 55 14             	mov    %edx,0x14(%ebp)
c0106829:	8b 00                	mov    (%eax),%eax
c010682b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010682e:	eb 1f                	jmp    c010684f <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0106830:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106834:	79 87                	jns    c01067bd <vprintfmt+0x53>
                width = 0;
c0106836:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010683d:	e9 7b ff ff ff       	jmp    c01067bd <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0106842:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0106849:	e9 6f ff ff ff       	jmp    c01067bd <vprintfmt+0x53>
            goto process_precision;
c010684e:	90                   	nop

        process_precision:
            if (width < 0)
c010684f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106853:	0f 89 64 ff ff ff    	jns    c01067bd <vprintfmt+0x53>
                width = precision, precision = -1;
c0106859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010685c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010685f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0106866:	e9 52 ff ff ff       	jmp    c01067bd <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010686b:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010686e:	e9 4a ff ff ff       	jmp    c01067bd <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0106873:	8b 45 14             	mov    0x14(%ebp),%eax
c0106876:	8d 50 04             	lea    0x4(%eax),%edx
c0106879:	89 55 14             	mov    %edx,0x14(%ebp)
c010687c:	8b 00                	mov    (%eax),%eax
c010687e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106881:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106885:	89 04 24             	mov    %eax,(%esp)
c0106888:	8b 45 08             	mov    0x8(%ebp),%eax
c010688b:	ff d0                	call   *%eax
            break;
c010688d:	e9 a4 02 00 00       	jmp    c0106b36 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0106892:	8b 45 14             	mov    0x14(%ebp),%eax
c0106895:	8d 50 04             	lea    0x4(%eax),%edx
c0106898:	89 55 14             	mov    %edx,0x14(%ebp)
c010689b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010689d:	85 db                	test   %ebx,%ebx
c010689f:	79 02                	jns    c01068a3 <vprintfmt+0x139>
                err = -err;
c01068a1:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01068a3:	83 fb 06             	cmp    $0x6,%ebx
c01068a6:	7f 0b                	jg     c01068b3 <vprintfmt+0x149>
c01068a8:	8b 34 9d b0 7f 10 c0 	mov    -0x3fef8050(,%ebx,4),%esi
c01068af:	85 f6                	test   %esi,%esi
c01068b1:	75 23                	jne    c01068d6 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01068b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01068b7:	c7 44 24 08 dd 7f 10 	movl   $0xc0107fdd,0x8(%esp)
c01068be:	c0 
c01068bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01068c9:	89 04 24             	mov    %eax,(%esp)
c01068cc:	e8 6a fe ff ff       	call   c010673b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01068d1:	e9 60 02 00 00       	jmp    c0106b36 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01068d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01068da:	c7 44 24 08 e6 7f 10 	movl   $0xc0107fe6,0x8(%esp)
c01068e1:	c0 
c01068e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01068ec:	89 04 24             	mov    %eax,(%esp)
c01068ef:	e8 47 fe ff ff       	call   c010673b <printfmt>
            break;
c01068f4:	e9 3d 02 00 00       	jmp    c0106b36 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01068f9:	8b 45 14             	mov    0x14(%ebp),%eax
c01068fc:	8d 50 04             	lea    0x4(%eax),%edx
c01068ff:	89 55 14             	mov    %edx,0x14(%ebp)
c0106902:	8b 30                	mov    (%eax),%esi
c0106904:	85 f6                	test   %esi,%esi
c0106906:	75 05                	jne    c010690d <vprintfmt+0x1a3>
                p = "(null)";
c0106908:	be e9 7f 10 c0       	mov    $0xc0107fe9,%esi
            }
            if (width > 0 && padc != '-') {
c010690d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106911:	7e 76                	jle    c0106989 <vprintfmt+0x21f>
c0106913:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106917:	74 70                	je     c0106989 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106919:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010691c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106920:	89 34 24             	mov    %esi,(%esp)
c0106923:	e8 f6 f7 ff ff       	call   c010611e <strnlen>
c0106928:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010692b:	29 c2                	sub    %eax,%edx
c010692d:	89 d0                	mov    %edx,%eax
c010692f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106932:	eb 16                	jmp    c010694a <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0106934:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106938:	8b 55 0c             	mov    0xc(%ebp),%edx
c010693b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010693f:	89 04 24             	mov    %eax,(%esp)
c0106942:	8b 45 08             	mov    0x8(%ebp),%eax
c0106945:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106947:	ff 4d e8             	decl   -0x18(%ebp)
c010694a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010694e:	7f e4                	jg     c0106934 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106950:	eb 37                	jmp    c0106989 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0106952:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106956:	74 1f                	je     c0106977 <vprintfmt+0x20d>
c0106958:	83 fb 1f             	cmp    $0x1f,%ebx
c010695b:	7e 05                	jle    c0106962 <vprintfmt+0x1f8>
c010695d:	83 fb 7e             	cmp    $0x7e,%ebx
c0106960:	7e 15                	jle    c0106977 <vprintfmt+0x20d>
                    putch('?', putdat);
c0106962:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106965:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106969:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0106970:	8b 45 08             	mov    0x8(%ebp),%eax
c0106973:	ff d0                	call   *%eax
c0106975:	eb 0f                	jmp    c0106986 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0106977:	8b 45 0c             	mov    0xc(%ebp),%eax
c010697a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010697e:	89 1c 24             	mov    %ebx,(%esp)
c0106981:	8b 45 08             	mov    0x8(%ebp),%eax
c0106984:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106986:	ff 4d e8             	decl   -0x18(%ebp)
c0106989:	89 f0                	mov    %esi,%eax
c010698b:	8d 70 01             	lea    0x1(%eax),%esi
c010698e:	0f b6 00             	movzbl (%eax),%eax
c0106991:	0f be d8             	movsbl %al,%ebx
c0106994:	85 db                	test   %ebx,%ebx
c0106996:	74 27                	je     c01069bf <vprintfmt+0x255>
c0106998:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010699c:	78 b4                	js     c0106952 <vprintfmt+0x1e8>
c010699e:	ff 4d e4             	decl   -0x1c(%ebp)
c01069a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01069a5:	79 ab                	jns    c0106952 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c01069a7:	eb 16                	jmp    c01069bf <vprintfmt+0x255>
                putch(' ', putdat);
c01069a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069b0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01069b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01069ba:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c01069bc:	ff 4d e8             	decl   -0x18(%ebp)
c01069bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01069c3:	7f e4                	jg     c01069a9 <vprintfmt+0x23f>
            }
            break;
c01069c5:	e9 6c 01 00 00       	jmp    c0106b36 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01069ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01069cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069d1:	8d 45 14             	lea    0x14(%ebp),%eax
c01069d4:	89 04 24             	mov    %eax,(%esp)
c01069d7:	e8 18 fd ff ff       	call   c01066f4 <getint>
c01069dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01069df:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01069e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01069e8:	85 d2                	test   %edx,%edx
c01069ea:	79 26                	jns    c0106a12 <vprintfmt+0x2a8>
                putch('-', putdat);
c01069ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01069fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01069fd:	ff d0                	call   *%eax
                num = -(long long)num;
c01069ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106a05:	f7 d8                	neg    %eax
c0106a07:	83 d2 00             	adc    $0x0,%edx
c0106a0a:	f7 da                	neg    %edx
c0106a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a0f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106a12:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106a19:	e9 a8 00 00 00       	jmp    c0106ac6 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106a1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a25:	8d 45 14             	lea    0x14(%ebp),%eax
c0106a28:	89 04 24             	mov    %eax,(%esp)
c0106a2b:	e8 75 fc ff ff       	call   c01066a5 <getuint>
c0106a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a33:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106a36:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106a3d:	e9 84 00 00 00       	jmp    c0106ac6 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106a42:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a49:	8d 45 14             	lea    0x14(%ebp),%eax
c0106a4c:	89 04 24             	mov    %eax,(%esp)
c0106a4f:	e8 51 fc ff ff       	call   c01066a5 <getuint>
c0106a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a57:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106a5a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106a61:	eb 63                	jmp    c0106ac6 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0106a63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a6a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106a71:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a74:	ff d0                	call   *%eax
            putch('x', putdat);
c0106a76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a7d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106a84:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a87:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106a89:	8b 45 14             	mov    0x14(%ebp),%eax
c0106a8c:	8d 50 04             	lea    0x4(%eax),%edx
c0106a8f:	89 55 14             	mov    %edx,0x14(%ebp)
c0106a92:	8b 00                	mov    (%eax),%eax
c0106a94:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106a9e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106aa5:	eb 1f                	jmp    c0106ac6 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106aa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106aae:	8d 45 14             	lea    0x14(%ebp),%eax
c0106ab1:	89 04 24             	mov    %eax,(%esp)
c0106ab4:	e8 ec fb ff ff       	call   c01066a5 <getuint>
c0106ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106abc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106abf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106ac6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106aca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106acd:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106ad1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106ad4:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106ad8:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106ae2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ae6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106aea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aed:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106af1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106af4:	89 04 24             	mov    %eax,(%esp)
c0106af7:	e8 a4 fa ff ff       	call   c01065a0 <printnum>
            break;
c0106afc:	eb 38                	jmp    c0106b36 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106afe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b05:	89 1c 24             	mov    %ebx,(%esp)
c0106b08:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b0b:	ff d0                	call   *%eax
            break;
c0106b0d:	eb 27                	jmp    c0106b36 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b16:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106b1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b20:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106b22:	ff 4d 10             	decl   0x10(%ebp)
c0106b25:	eb 03                	jmp    c0106b2a <vprintfmt+0x3c0>
c0106b27:	ff 4d 10             	decl   0x10(%ebp)
c0106b2a:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b2d:	48                   	dec    %eax
c0106b2e:	0f b6 00             	movzbl (%eax),%eax
c0106b31:	3c 25                	cmp    $0x25,%al
c0106b33:	75 f2                	jne    c0106b27 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106b35:	90                   	nop
    while (1) {
c0106b36:	e9 37 fc ff ff       	jmp    c0106772 <vprintfmt+0x8>
                return;
c0106b3b:	90                   	nop
        }
    }
}
c0106b3c:	83 c4 40             	add    $0x40,%esp
c0106b3f:	5b                   	pop    %ebx
c0106b40:	5e                   	pop    %esi
c0106b41:	5d                   	pop    %ebp
c0106b42:	c3                   	ret    

c0106b43 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106b43:	55                   	push   %ebp
c0106b44:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106b46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b49:	8b 40 08             	mov    0x8(%eax),%eax
c0106b4c:	8d 50 01             	lea    0x1(%eax),%edx
c0106b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b52:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106b55:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b58:	8b 10                	mov    (%eax),%edx
c0106b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b5d:	8b 40 04             	mov    0x4(%eax),%eax
c0106b60:	39 c2                	cmp    %eax,%edx
c0106b62:	73 12                	jae    c0106b76 <sprintputch+0x33>
        *b->buf ++ = ch;
c0106b64:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b67:	8b 00                	mov    (%eax),%eax
c0106b69:	8d 48 01             	lea    0x1(%eax),%ecx
c0106b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106b6f:	89 0a                	mov    %ecx,(%edx)
c0106b71:	8b 55 08             	mov    0x8(%ebp),%edx
c0106b74:	88 10                	mov    %dl,(%eax)
    }
}
c0106b76:	90                   	nop
c0106b77:	5d                   	pop    %ebp
c0106b78:	c3                   	ret    

c0106b79 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106b79:	55                   	push   %ebp
c0106b7a:	89 e5                	mov    %esp,%ebp
c0106b7c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106b7f:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b88:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106b8c:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b8f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b9d:	89 04 24             	mov    %eax,(%esp)
c0106ba0:	e8 08 00 00 00       	call   c0106bad <vsnprintf>
c0106ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106bab:	c9                   	leave  
c0106bac:	c3                   	ret    

c0106bad <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106bad:	55                   	push   %ebp
c0106bae:	89 e5                	mov    %esp,%ebp
c0106bb0:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bbc:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bc2:	01 d0                	add    %edx,%eax
c0106bc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106bce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106bd2:	74 0a                	je     c0106bde <vsnprintf+0x31>
c0106bd4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106bda:	39 c2                	cmp    %eax,%edx
c0106bdc:	76 07                	jbe    c0106be5 <vsnprintf+0x38>
        return -E_INVAL;
c0106bde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106be3:	eb 2a                	jmp    c0106c0f <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106be5:	8b 45 14             	mov    0x14(%ebp),%eax
c0106be8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106bec:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bef:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bfa:	c7 04 24 43 6b 10 c0 	movl   $0xc0106b43,(%esp)
c0106c01:	e8 64 fb ff ff       	call   c010676a <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106c06:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c09:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106c0f:	c9                   	leave  
c0106c10:	c3                   	ret    
