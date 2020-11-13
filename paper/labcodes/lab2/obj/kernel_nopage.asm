
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 b0 11 40       	mov    $0x4011b000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    # 将cr0修改完成后的值，重新送至cr0中(此时第0位PE位已经为1，页机制已经开启，当前页表地址为刚刚构造的__boot_pgdir)
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 b0 11 00       	mov    %eax,0x11b000

    # 设置C的内核栈
    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 a0 11 00       	mov    $0x11a000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 60 14 1e 00       	mov    $0x1e1460,%edx
  100041:	b8 36 aa 11 00       	mov    $0x11aa36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 aa 11 00 	movl   $0x11aa36,(%esp)
  10005d:	e8 b5 63 00 00       	call   106417 <memset>

    cons_init();                // init the console
  100062:	e8 90 15 00 00       	call   1015f7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 20 6c 10 00 	movl   $0x106c20,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 3c 6c 10 00 	movl   $0x106c3c,(%esp)
  10007c:	e8 21 02 00 00       	call   1002a2 <cprintf>

    print_kerninfo();
  100081:	e8 c2 08 00 00       	call   100948 <print_kerninfo>

    grade_backtrace();
  100086:	e8 8e 00 00 00       	call   100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 12 33 00 00       	call   1033a2 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 c7 16 00 00       	call   10175c <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 27 18 00 00       	call   1018c1 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 fb 0c 00 00       	call   100d9a <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 f2 17 00 00       	call   101896 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  1000a4:	e8 6b 01 00 00       	call   100214 <lab1_switch_test>

    /* do nothing */
    while (1);
  1000a9:	eb fe                	jmp    1000a9 <kern_init+0x73>

001000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000ab:	55                   	push   %ebp
  1000ac:	89 e5                	mov    %esp,%ebp
  1000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b8:	00 
  1000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000c0:	00 
  1000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c8:	e8 bb 0c 00 00       	call   100d88 <mon_backtrace>
}
  1000cd:	90                   	nop
  1000ce:	c9                   	leave  
  1000cf:	c3                   	ret    

001000d0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000d0:	55                   	push   %ebp
  1000d1:	89 e5                	mov    %esp,%ebp
  1000d3:	53                   	push   %ebx
  1000d4:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d7:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000da:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000dd:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1000e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ef:	89 04 24             	mov    %eax,(%esp)
  1000f2:	e8 b4 ff ff ff       	call   1000ab <grade_backtrace2>
}
  1000f7:	90                   	nop
  1000f8:	83 c4 14             	add    $0x14,%esp
  1000fb:	5b                   	pop    %ebx
  1000fc:	5d                   	pop    %ebp
  1000fd:	c3                   	ret    

001000fe <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fe:	55                   	push   %ebp
  1000ff:	89 e5                	mov    %esp,%ebp
  100101:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100104:	8b 45 10             	mov    0x10(%ebp),%eax
  100107:	89 44 24 04          	mov    %eax,0x4(%esp)
  10010b:	8b 45 08             	mov    0x8(%ebp),%eax
  10010e:	89 04 24             	mov    %eax,(%esp)
  100111:	e8 ba ff ff ff       	call   1000d0 <grade_backtrace1>
}
  100116:	90                   	nop
  100117:	c9                   	leave  
  100118:	c3                   	ret    

00100119 <grade_backtrace>:

void
grade_backtrace(void) {
  100119:	55                   	push   %ebp
  10011a:	89 e5                	mov    %esp,%ebp
  10011c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011f:	b8 36 00 10 00       	mov    $0x100036,%eax
  100124:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  10012b:	ff 
  10012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100137:	e8 c2 ff ff ff       	call   1000fe <grade_backtrace0>
}
  10013c:	90                   	nop
  10013d:	c9                   	leave  
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 d0 11 00       	mov    0x11d000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 41 6c 10 00 	movl   $0x106c41,(%esp)
  10016e:	e8 2f 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 d0 11 00       	mov    0x11d000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 4f 6c 10 00 	movl   $0x106c4f,(%esp)
  10018d:	e8 10 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 d0 11 00       	mov    0x11d000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 5d 6c 10 00 	movl   $0x106c5d,(%esp)
  1001ac:	e8 f1 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 6b 6c 10 00 	movl   $0x106c6b,(%esp)
  1001cb:	e8 d2 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 79 6c 10 00 	movl   $0x106c79,(%esp)
  1001ea:	e8 b3 00 00 00       	call   1002a2 <cprintf>
    round ++;
  1001ef:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 d0 11 00       	mov    %eax,0x11d000
}
  1001fa:	90                   	nop
  1001fb:	c9                   	leave  
  1001fc:	c3                   	ret    

001001fd <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fd:	55                   	push   %ebp
  1001fe:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO  
    asm volatile(
  100200:	83 ec 08             	sub    $0x8,%esp
  100203:	cd 78                	int    $0x78
  100205:	89 ec                	mov    %ebp,%esp
        "movl %%ebp, %%esp;"
        :
        : "i"(T_SWITCH_TOU)
    );
    //cprintf("to user finish \n");
}
  100207:	90                   	nop
  100208:	5d                   	pop    %ebp
  100209:	c3                   	ret    

0010020a <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  10020a:	55                   	push   %ebp
  10020b:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  10020d:	cd 79                	int    $0x79
  10020f:	89 ec                	mov    %ebp,%esp
	    "movl %%ebp, %%esp;"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
    //cprintf("to kernel finish \n");
}
  100211:	90                   	nop
  100212:	5d                   	pop    %ebp
  100213:	c3                   	ret    

00100214 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100214:	55                   	push   %ebp
  100215:	89 e5                	mov    %esp,%ebp
  100217:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10021a:	e8 20 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10021f:	c7 04 24 88 6c 10 00 	movl   $0x106c88,(%esp)
  100226:	e8 77 00 00 00       	call   1002a2 <cprintf>
    lab1_switch_to_user();
  10022b:	e8 cd ff ff ff       	call   1001fd <lab1_switch_to_user>
    lab1_print_cur_status();
  100230:	e8 0a ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100235:	c7 04 24 a8 6c 10 00 	movl   $0x106ca8,(%esp)
  10023c:	e8 61 00 00 00       	call   1002a2 <cprintf>
    lab1_switch_to_kernel();
  100241:	e8 c4 ff ff ff       	call   10020a <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100246:	e8 f4 fe ff ff       	call   10013f <lab1_print_cur_status>
}
  10024b:	90                   	nop
  10024c:	c9                   	leave  
  10024d:	c3                   	ret    

0010024e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10024e:	55                   	push   %ebp
  10024f:	89 e5                	mov    %esp,%ebp
  100251:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100254:	8b 45 08             	mov    0x8(%ebp),%eax
  100257:	89 04 24             	mov    %eax,(%esp)
  10025a:	e8 c5 13 00 00       	call   101624 <cons_putc>
    (*cnt) ++;
  10025f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100262:	8b 00                	mov    (%eax),%eax
  100264:	8d 50 01             	lea    0x1(%eax),%edx
  100267:	8b 45 0c             	mov    0xc(%ebp),%eax
  10026a:	89 10                	mov    %edx,(%eax)
}
  10026c:	90                   	nop
  10026d:	c9                   	leave  
  10026e:	c3                   	ret    

0010026f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10026f:	55                   	push   %ebp
  100270:	89 e5                	mov    %esp,%ebp
  100272:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10027f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100283:	8b 45 08             	mov    0x8(%ebp),%eax
  100286:	89 44 24 08          	mov    %eax,0x8(%esp)
  10028a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10028d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100291:	c7 04 24 4e 02 10 00 	movl   $0x10024e,(%esp)
  100298:	e8 cd 64 00 00       	call   10676a <vprintfmt>
    return cnt;
  10029d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002a0:	c9                   	leave  
  1002a1:	c3                   	ret    

001002a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  1002a2:	55                   	push   %ebp
  1002a3:	89 e5                	mov    %esp,%ebp
  1002a5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1002a8:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b8:	89 04 24             	mov    %eax,(%esp)
  1002bb:	e8 af ff ff ff       	call   10026f <vcprintf>
  1002c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002c6:	c9                   	leave  
  1002c7:	c3                   	ret    

001002c8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002c8:	55                   	push   %ebp
  1002c9:	89 e5                	mov    %esp,%ebp
  1002cb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d1:	89 04 24             	mov    %eax,(%esp)
  1002d4:	e8 4b 13 00 00       	call   101624 <cons_putc>
}
  1002d9:	90                   	nop
  1002da:	c9                   	leave  
  1002db:	c3                   	ret    

001002dc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002dc:	55                   	push   %ebp
  1002dd:	89 e5                	mov    %esp,%ebp
  1002df:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002e9:	eb 13                	jmp    1002fe <cputs+0x22>
        cputch(c, &cnt);
  1002eb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002ef:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002f6:	89 04 24             	mov    %eax,(%esp)
  1002f9:	e8 50 ff ff ff       	call   10024e <cputch>
    while ((c = *str ++) != '\0') {
  1002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100301:	8d 50 01             	lea    0x1(%eax),%edx
  100304:	89 55 08             	mov    %edx,0x8(%ebp)
  100307:	0f b6 00             	movzbl (%eax),%eax
  10030a:	88 45 f7             	mov    %al,-0x9(%ebp)
  10030d:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100311:	75 d8                	jne    1002eb <cputs+0xf>
    }
    cputch('\n', &cnt);
  100313:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100316:	89 44 24 04          	mov    %eax,0x4(%esp)
  10031a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100321:	e8 28 ff ff ff       	call   10024e <cputch>
    return cnt;
  100326:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100329:	c9                   	leave  
  10032a:	c3                   	ret    

0010032b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10032b:	55                   	push   %ebp
  10032c:	89 e5                	mov    %esp,%ebp
  10032e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100331:	e8 2b 13 00 00       	call   101661 <cons_getc>
  100336:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10033d:	74 f2                	je     100331 <getchar+0x6>
        /* do nothing */;
    return c;
  10033f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100342:	c9                   	leave  
  100343:	c3                   	ret    

00100344 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100344:	55                   	push   %ebp
  100345:	89 e5                	mov    %esp,%ebp
  100347:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10034a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10034e:	74 13                	je     100363 <readline+0x1f>
        cprintf("%s", prompt);
  100350:	8b 45 08             	mov    0x8(%ebp),%eax
  100353:	89 44 24 04          	mov    %eax,0x4(%esp)
  100357:	c7 04 24 c7 6c 10 00 	movl   $0x106cc7,(%esp)
  10035e:	e8 3f ff ff ff       	call   1002a2 <cprintf>
    }
    int i = 0, c;
  100363:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10036a:	e8 bc ff ff ff       	call   10032b <getchar>
  10036f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100372:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100376:	79 07                	jns    10037f <readline+0x3b>
            return NULL;
  100378:	b8 00 00 00 00       	mov    $0x0,%eax
  10037d:	eb 78                	jmp    1003f7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10037f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100383:	7e 28                	jle    1003ad <readline+0x69>
  100385:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10038c:	7f 1f                	jg     1003ad <readline+0x69>
            cputchar(c);
  10038e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100391:	89 04 24             	mov    %eax,(%esp)
  100394:	e8 2f ff ff ff       	call   1002c8 <cputchar>
            buf[i ++] = c;
  100399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10039c:	8d 50 01             	lea    0x1(%eax),%edx
  10039f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1003a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1003a5:	88 90 20 d0 11 00    	mov    %dl,0x11d020(%eax)
  1003ab:	eb 45                	jmp    1003f2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1003ad:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003b1:	75 16                	jne    1003c9 <readline+0x85>
  1003b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003b7:	7e 10                	jle    1003c9 <readline+0x85>
            cputchar(c);
  1003b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003bc:	89 04 24             	mov    %eax,(%esp)
  1003bf:	e8 04 ff ff ff       	call   1002c8 <cputchar>
            i --;
  1003c4:	ff 4d f4             	decl   -0xc(%ebp)
  1003c7:	eb 29                	jmp    1003f2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003c9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003cd:	74 06                	je     1003d5 <readline+0x91>
  1003cf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003d3:	75 95                	jne    10036a <readline+0x26>
            cputchar(c);
  1003d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003d8:	89 04 24             	mov    %eax,(%esp)
  1003db:	e8 e8 fe ff ff       	call   1002c8 <cputchar>
            buf[i] = '\0';
  1003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003e3:	05 20 d0 11 00       	add    $0x11d020,%eax
  1003e8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003eb:	b8 20 d0 11 00       	mov    $0x11d020,%eax
  1003f0:	eb 05                	jmp    1003f7 <readline+0xb3>
        c = getchar();
  1003f2:	e9 73 ff ff ff       	jmp    10036a <readline+0x26>
        }
    }
}
  1003f7:	c9                   	leave  
  1003f8:	c3                   	ret    

001003f9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003f9:	55                   	push   %ebp
  1003fa:	89 e5                	mov    %esp,%ebp
  1003fc:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003ff:	a1 20 d4 11 00       	mov    0x11d420,%eax
  100404:	85 c0                	test   %eax,%eax
  100406:	75 5b                	jne    100463 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100408:	c7 05 20 d4 11 00 01 	movl   $0x1,0x11d420
  10040f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100412:	8d 45 14             	lea    0x14(%ebp),%eax
  100415:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100418:	8b 45 0c             	mov    0xc(%ebp),%eax
  10041b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10041f:	8b 45 08             	mov    0x8(%ebp),%eax
  100422:	89 44 24 04          	mov    %eax,0x4(%esp)
  100426:	c7 04 24 ca 6c 10 00 	movl   $0x106cca,(%esp)
  10042d:	e8 70 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100435:	89 44 24 04          	mov    %eax,0x4(%esp)
  100439:	8b 45 10             	mov    0x10(%ebp),%eax
  10043c:	89 04 24             	mov    %eax,(%esp)
  10043f:	e8 2b fe ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  100444:	c7 04 24 e6 6c 10 00 	movl   $0x106ce6,(%esp)
  10044b:	e8 52 fe ff ff       	call   1002a2 <cprintf>
    
    cprintf("stack trackback:\n");
  100450:	c7 04 24 e8 6c 10 00 	movl   $0x106ce8,(%esp)
  100457:	e8 46 fe ff ff       	call   1002a2 <cprintf>
    print_stackframe();
  10045c:	e8 32 06 00 00       	call   100a93 <print_stackframe>
  100461:	eb 01                	jmp    100464 <__panic+0x6b>
        goto panic_dead;
  100463:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100464:	e8 34 14 00 00       	call   10189d <intr_disable>
    while (1) {
        kmonitor(NULL);
  100469:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100470:	e8 46 08 00 00       	call   100cbb <kmonitor>
  100475:	eb f2                	jmp    100469 <__panic+0x70>

00100477 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100477:	55                   	push   %ebp
  100478:	89 e5                	mov    %esp,%ebp
  10047a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10047d:	8d 45 14             	lea    0x14(%ebp),%eax
  100480:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100483:	8b 45 0c             	mov    0xc(%ebp),%eax
  100486:	89 44 24 08          	mov    %eax,0x8(%esp)
  10048a:	8b 45 08             	mov    0x8(%ebp),%eax
  10048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100491:	c7 04 24 fa 6c 10 00 	movl   $0x106cfa,(%esp)
  100498:	e8 05 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  10049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a7:	89 04 24             	mov    %eax,(%esp)
  1004aa:	e8 c0 fd ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  1004af:	c7 04 24 e6 6c 10 00 	movl   $0x106ce6,(%esp)
  1004b6:	e8 e7 fd ff ff       	call   1002a2 <cprintf>
    va_end(ap);
}
  1004bb:	90                   	nop
  1004bc:	c9                   	leave  
  1004bd:	c3                   	ret    

001004be <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004be:	55                   	push   %ebp
  1004bf:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004c1:	a1 20 d4 11 00       	mov    0x11d420,%eax
}
  1004c6:	5d                   	pop    %ebp
  1004c7:	c3                   	ret    

001004c8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004c8:	55                   	push   %ebp
  1004c9:	89 e5                	mov    %esp,%ebp
  1004cb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004d1:	8b 00                	mov    (%eax),%eax
  1004d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004d6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d9:	8b 00                	mov    (%eax),%eax
  1004db:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004e5:	e9 ca 00 00 00       	jmp    1005b4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004f0:	01 d0                	add    %edx,%eax
  1004f2:	89 c2                	mov    %eax,%edx
  1004f4:	c1 ea 1f             	shr    $0x1f,%edx
  1004f7:	01 d0                	add    %edx,%eax
  1004f9:	d1 f8                	sar    %eax
  1004fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100501:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100504:	eb 03                	jmp    100509 <stab_binsearch+0x41>
            m --;
  100506:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100509:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10050c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10050f:	7c 1f                	jl     100530 <stab_binsearch+0x68>
  100511:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100514:	89 d0                	mov    %edx,%eax
  100516:	01 c0                	add    %eax,%eax
  100518:	01 d0                	add    %edx,%eax
  10051a:	c1 e0 02             	shl    $0x2,%eax
  10051d:	89 c2                	mov    %eax,%edx
  10051f:	8b 45 08             	mov    0x8(%ebp),%eax
  100522:	01 d0                	add    %edx,%eax
  100524:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100528:	0f b6 c0             	movzbl %al,%eax
  10052b:	39 45 14             	cmp    %eax,0x14(%ebp)
  10052e:	75 d6                	jne    100506 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100533:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100536:	7d 09                	jge    100541 <stab_binsearch+0x79>
            l = true_m + 1;
  100538:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10053b:	40                   	inc    %eax
  10053c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10053f:	eb 73                	jmp    1005b4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100541:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100548:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10054b:	89 d0                	mov    %edx,%eax
  10054d:	01 c0                	add    %eax,%eax
  10054f:	01 d0                	add    %edx,%eax
  100551:	c1 e0 02             	shl    $0x2,%eax
  100554:	89 c2                	mov    %eax,%edx
  100556:	8b 45 08             	mov    0x8(%ebp),%eax
  100559:	01 d0                	add    %edx,%eax
  10055b:	8b 40 08             	mov    0x8(%eax),%eax
  10055e:	39 45 18             	cmp    %eax,0x18(%ebp)
  100561:	76 11                	jbe    100574 <stab_binsearch+0xac>
            *region_left = m;
  100563:	8b 45 0c             	mov    0xc(%ebp),%eax
  100566:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100569:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10056b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10056e:	40                   	inc    %eax
  10056f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100572:	eb 40                	jmp    1005b4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100574:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100577:	89 d0                	mov    %edx,%eax
  100579:	01 c0                	add    %eax,%eax
  10057b:	01 d0                	add    %edx,%eax
  10057d:	c1 e0 02             	shl    $0x2,%eax
  100580:	89 c2                	mov    %eax,%edx
  100582:	8b 45 08             	mov    0x8(%ebp),%eax
  100585:	01 d0                	add    %edx,%eax
  100587:	8b 40 08             	mov    0x8(%eax),%eax
  10058a:	39 45 18             	cmp    %eax,0x18(%ebp)
  10058d:	73 14                	jae    1005a3 <stab_binsearch+0xdb>
            *region_right = m - 1;
  10058f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100592:	8d 50 ff             	lea    -0x1(%eax),%edx
  100595:	8b 45 10             	mov    0x10(%ebp),%eax
  100598:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10059a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059d:	48                   	dec    %eax
  10059e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1005a1:	eb 11                	jmp    1005b4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005a9:	89 10                	mov    %edx,(%eax)
            l = m;
  1005ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005b1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1005b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005ba:	0f 8e 2a ff ff ff    	jle    1004ea <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1005c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005c4:	75 0f                	jne    1005d5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005c9:	8b 00                	mov    (%eax),%eax
  1005cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1005d1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005d3:	eb 3e                	jmp    100613 <stab_binsearch+0x14b>
        l = *region_right;
  1005d5:	8b 45 10             	mov    0x10(%ebp),%eax
  1005d8:	8b 00                	mov    (%eax),%eax
  1005da:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005dd:	eb 03                	jmp    1005e2 <stab_binsearch+0x11a>
  1005df:	ff 4d fc             	decl   -0x4(%ebp)
  1005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e5:	8b 00                	mov    (%eax),%eax
  1005e7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1005ea:	7e 1f                	jle    10060b <stab_binsearch+0x143>
  1005ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005ef:	89 d0                	mov    %edx,%eax
  1005f1:	01 c0                	add    %eax,%eax
  1005f3:	01 d0                	add    %edx,%eax
  1005f5:	c1 e0 02             	shl    $0x2,%eax
  1005f8:	89 c2                	mov    %eax,%edx
  1005fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1005fd:	01 d0                	add    %edx,%eax
  1005ff:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100603:	0f b6 c0             	movzbl %al,%eax
  100606:	39 45 14             	cmp    %eax,0x14(%ebp)
  100609:	75 d4                	jne    1005df <stab_binsearch+0x117>
        *region_left = l;
  10060b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100611:	89 10                	mov    %edx,(%eax)
}
  100613:	90                   	nop
  100614:	c9                   	leave  
  100615:	c3                   	ret    

00100616 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100616:	55                   	push   %ebp
  100617:	89 e5                	mov    %esp,%ebp
  100619:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10061c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061f:	c7 00 18 6d 10 00    	movl   $0x106d18,(%eax)
    info->eip_line = 0;
  100625:	8b 45 0c             	mov    0xc(%ebp),%eax
  100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10062f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100632:	c7 40 08 18 6d 10 00 	movl   $0x106d18,0x8(%eax)
    info->eip_fn_namelen = 9;
  100639:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100643:	8b 45 0c             	mov    0xc(%ebp),%eax
  100646:	8b 55 08             	mov    0x8(%ebp),%edx
  100649:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10064c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10064f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100656:	c7 45 f4 48 81 10 00 	movl   $0x108148,-0xc(%ebp)
    stab_end = __STAB_END__;
  10065d:	c7 45 f0 00 44 11 00 	movl   $0x114400,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100664:	c7 45 ec 01 44 11 00 	movl   $0x114401,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10066b:	c7 45 e8 cf 71 11 00 	movl   $0x1171cf,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100675:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100678:	76 0b                	jbe    100685 <debuginfo_eip+0x6f>
  10067a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10067d:	48                   	dec    %eax
  10067e:	0f b6 00             	movzbl (%eax),%eax
  100681:	84 c0                	test   %al,%al
  100683:	74 0a                	je     10068f <debuginfo_eip+0x79>
        return -1;
  100685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10068a:	e9 b7 02 00 00       	jmp    100946 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10068f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10069c:	29 c2                	sub    %eax,%edx
  10069e:	89 d0                	mov    %edx,%eax
  1006a0:	c1 f8 02             	sar    $0x2,%eax
  1006a3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006a9:	48                   	dec    %eax
  1006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1006b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006b4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006bb:	00 
  1006bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006cd:	89 04 24             	mov    %eax,(%esp)
  1006d0:	e8 f3 fd ff ff       	call   1004c8 <stab_binsearch>
    if (lfile == 0)
  1006d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d8:	85 c0                	test   %eax,%eax
  1006da:	75 0a                	jne    1006e6 <debuginfo_eip+0xd0>
        return -1;
  1006dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006e1:	e9 60 02 00 00       	jmp    100946 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006f9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100700:	00 
  100701:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100704:	89 44 24 08          	mov    %eax,0x8(%esp)
  100708:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10070b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10070f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100712:	89 04 24             	mov    %eax,(%esp)
  100715:	e8 ae fd ff ff       	call   1004c8 <stab_binsearch>

    if (lfun <= rfun) {
  10071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10071d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100720:	39 c2                	cmp    %eax,%edx
  100722:	7f 7c                	jg     1007a0 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100724:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100727:	89 c2                	mov    %eax,%edx
  100729:	89 d0                	mov    %edx,%eax
  10072b:	01 c0                	add    %eax,%eax
  10072d:	01 d0                	add    %edx,%eax
  10072f:	c1 e0 02             	shl    $0x2,%eax
  100732:	89 c2                	mov    %eax,%edx
  100734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100737:	01 d0                	add    %edx,%eax
  100739:	8b 00                	mov    (%eax),%eax
  10073b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10073e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100741:	29 d1                	sub    %edx,%ecx
  100743:	89 ca                	mov    %ecx,%edx
  100745:	39 d0                	cmp    %edx,%eax
  100747:	73 22                	jae    10076b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100749:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10074c:	89 c2                	mov    %eax,%edx
  10074e:	89 d0                	mov    %edx,%eax
  100750:	01 c0                	add    %eax,%eax
  100752:	01 d0                	add    %edx,%eax
  100754:	c1 e0 02             	shl    $0x2,%eax
  100757:	89 c2                	mov    %eax,%edx
  100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10075c:	01 d0                	add    %edx,%eax
  10075e:	8b 10                	mov    (%eax),%edx
  100760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100763:	01 c2                	add    %eax,%edx
  100765:	8b 45 0c             	mov    0xc(%ebp),%eax
  100768:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10076b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10076e:	89 c2                	mov    %eax,%edx
  100770:	89 d0                	mov    %edx,%eax
  100772:	01 c0                	add    %eax,%eax
  100774:	01 d0                	add    %edx,%eax
  100776:	c1 e0 02             	shl    $0x2,%eax
  100779:	89 c2                	mov    %eax,%edx
  10077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10077e:	01 d0                	add    %edx,%eax
  100780:	8b 50 08             	mov    0x8(%eax),%edx
  100783:	8b 45 0c             	mov    0xc(%ebp),%eax
  100786:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100789:	8b 45 0c             	mov    0xc(%ebp),%eax
  10078c:	8b 40 10             	mov    0x10(%eax),%eax
  10078f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100792:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100795:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100798:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10079b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10079e:	eb 15                	jmp    1007b5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a3:	8b 55 08             	mov    0x8(%ebp),%edx
  1007a6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b8:	8b 40 08             	mov    0x8(%eax),%eax
  1007bb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007c2:	00 
  1007c3:	89 04 24             	mov    %eax,(%esp)
  1007c6:	e8 c8 5a 00 00       	call   106293 <strfind>
  1007cb:	89 c2                	mov    %eax,%edx
  1007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d0:	8b 40 08             	mov    0x8(%eax),%eax
  1007d3:	29 c2                	sub    %eax,%edx
  1007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007db:	8b 45 08             	mov    0x8(%ebp),%eax
  1007de:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007e2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007e9:	00 
  1007ea:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007f1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007fb:	89 04 24             	mov    %eax,(%esp)
  1007fe:	e8 c5 fc ff ff       	call   1004c8 <stab_binsearch>
    if (lline <= rline) {
  100803:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100806:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100809:	39 c2                	cmp    %eax,%edx
  10080b:	7f 23                	jg     100830 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  10080d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100810:	89 c2                	mov    %eax,%edx
  100812:	89 d0                	mov    %edx,%eax
  100814:	01 c0                	add    %eax,%eax
  100816:	01 d0                	add    %edx,%eax
  100818:	c1 e0 02             	shl    $0x2,%eax
  10081b:	89 c2                	mov    %eax,%edx
  10081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100820:	01 d0                	add    %edx,%eax
  100822:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100826:	89 c2                	mov    %eax,%edx
  100828:	8b 45 0c             	mov    0xc(%ebp),%eax
  10082b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10082e:	eb 11                	jmp    100841 <debuginfo_eip+0x22b>
        return -1;
  100830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100835:	e9 0c 01 00 00       	jmp    100946 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10083a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10083d:	48                   	dec    %eax
  10083e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100841:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100847:	39 c2                	cmp    %eax,%edx
  100849:	7c 56                	jl     1008a1 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  10084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084e:	89 c2                	mov    %eax,%edx
  100850:	89 d0                	mov    %edx,%eax
  100852:	01 c0                	add    %eax,%eax
  100854:	01 d0                	add    %edx,%eax
  100856:	c1 e0 02             	shl    $0x2,%eax
  100859:	89 c2                	mov    %eax,%edx
  10085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085e:	01 d0                	add    %edx,%eax
  100860:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100864:	3c 84                	cmp    $0x84,%al
  100866:	74 39                	je     1008a1 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100868:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10086b:	89 c2                	mov    %eax,%edx
  10086d:	89 d0                	mov    %edx,%eax
  10086f:	01 c0                	add    %eax,%eax
  100871:	01 d0                	add    %edx,%eax
  100873:	c1 e0 02             	shl    $0x2,%eax
  100876:	89 c2                	mov    %eax,%edx
  100878:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10087b:	01 d0                	add    %edx,%eax
  10087d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100881:	3c 64                	cmp    $0x64,%al
  100883:	75 b5                	jne    10083a <debuginfo_eip+0x224>
  100885:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100888:	89 c2                	mov    %eax,%edx
  10088a:	89 d0                	mov    %edx,%eax
  10088c:	01 c0                	add    %eax,%eax
  10088e:	01 d0                	add    %edx,%eax
  100890:	c1 e0 02             	shl    $0x2,%eax
  100893:	89 c2                	mov    %eax,%edx
  100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100898:	01 d0                	add    %edx,%eax
  10089a:	8b 40 08             	mov    0x8(%eax),%eax
  10089d:	85 c0                	test   %eax,%eax
  10089f:	74 99                	je     10083a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1008a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008a7:	39 c2                	cmp    %eax,%edx
  1008a9:	7c 46                	jl     1008f1 <debuginfo_eip+0x2db>
  1008ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008ae:	89 c2                	mov    %eax,%edx
  1008b0:	89 d0                	mov    %edx,%eax
  1008b2:	01 c0                	add    %eax,%eax
  1008b4:	01 d0                	add    %edx,%eax
  1008b6:	c1 e0 02             	shl    $0x2,%eax
  1008b9:	89 c2                	mov    %eax,%edx
  1008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008be:	01 d0                	add    %edx,%eax
  1008c0:	8b 00                	mov    (%eax),%eax
  1008c2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008c8:	29 d1                	sub    %edx,%ecx
  1008ca:	89 ca                	mov    %ecx,%edx
  1008cc:	39 d0                	cmp    %edx,%eax
  1008ce:	73 21                	jae    1008f1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008d3:	89 c2                	mov    %eax,%edx
  1008d5:	89 d0                	mov    %edx,%eax
  1008d7:	01 c0                	add    %eax,%eax
  1008d9:	01 d0                	add    %edx,%eax
  1008db:	c1 e0 02             	shl    $0x2,%eax
  1008de:	89 c2                	mov    %eax,%edx
  1008e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008e3:	01 d0                	add    %edx,%eax
  1008e5:	8b 10                	mov    (%eax),%edx
  1008e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008ea:	01 c2                	add    %eax,%edx
  1008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008ef:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008f7:	39 c2                	cmp    %eax,%edx
  1008f9:	7d 46                	jge    100941 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008fe:	40                   	inc    %eax
  1008ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100902:	eb 16                	jmp    10091a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100904:	8b 45 0c             	mov    0xc(%ebp),%eax
  100907:	8b 40 14             	mov    0x14(%eax),%eax
  10090a:	8d 50 01             	lea    0x1(%eax),%edx
  10090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100910:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100913:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100916:	40                   	inc    %eax
  100917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10091a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10091d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100920:	39 c2                	cmp    %eax,%edx
  100922:	7d 1d                	jge    100941 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100924:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100927:	89 c2                	mov    %eax,%edx
  100929:	89 d0                	mov    %edx,%eax
  10092b:	01 c0                	add    %eax,%eax
  10092d:	01 d0                	add    %edx,%eax
  10092f:	c1 e0 02             	shl    $0x2,%eax
  100932:	89 c2                	mov    %eax,%edx
  100934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100937:	01 d0                	add    %edx,%eax
  100939:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10093d:	3c a0                	cmp    $0xa0,%al
  10093f:	74 c3                	je     100904 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
  100941:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100946:	c9                   	leave  
  100947:	c3                   	ret    

00100948 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100948:	55                   	push   %ebp
  100949:	89 e5                	mov    %esp,%ebp
  10094b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10094e:	c7 04 24 22 6d 10 00 	movl   $0x106d22,(%esp)
  100955:	e8 48 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10095a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100961:	00 
  100962:	c7 04 24 3b 6d 10 00 	movl   $0x106d3b,(%esp)
  100969:	e8 34 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10096e:	c7 44 24 04 11 6c 10 	movl   $0x106c11,0x4(%esp)
  100975:	00 
  100976:	c7 04 24 53 6d 10 00 	movl   $0x106d53,(%esp)
  10097d:	e8 20 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100982:	c7 44 24 04 36 aa 11 	movl   $0x11aa36,0x4(%esp)
  100989:	00 
  10098a:	c7 04 24 6b 6d 10 00 	movl   $0x106d6b,(%esp)
  100991:	e8 0c f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100996:	c7 44 24 04 60 14 1e 	movl   $0x1e1460,0x4(%esp)
  10099d:	00 
  10099e:	c7 04 24 83 6d 10 00 	movl   $0x106d83,(%esp)
  1009a5:	e8 f8 f8 ff ff       	call   1002a2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009aa:	b8 60 14 1e 00       	mov    $0x1e1460,%eax
  1009af:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009ba:	29 c2                	sub    %eax,%edx
  1009bc:	89 d0                	mov    %edx,%eax
  1009be:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009c4:	85 c0                	test   %eax,%eax
  1009c6:	0f 48 c2             	cmovs  %edx,%eax
  1009c9:	c1 f8 0a             	sar    $0xa,%eax
  1009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d0:	c7 04 24 9c 6d 10 00 	movl   $0x106d9c,(%esp)
  1009d7:	e8 c6 f8 ff ff       	call   1002a2 <cprintf>
}
  1009dc:	90                   	nop
  1009dd:	c9                   	leave  
  1009de:	c3                   	ret    

001009df <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009df:	55                   	push   %ebp
  1009e0:	89 e5                	mov    %esp,%ebp
  1009e2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f2:	89 04 24             	mov    %eax,(%esp)
  1009f5:	e8 1c fc ff ff       	call   100616 <debuginfo_eip>
  1009fa:	85 c0                	test   %eax,%eax
  1009fc:	74 15                	je     100a13 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a05:	c7 04 24 c6 6d 10 00 	movl   $0x106dc6,(%esp)
  100a0c:	e8 91 f8 ff ff       	call   1002a2 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a11:	eb 6c                	jmp    100a7f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a1a:	eb 1b                	jmp    100a37 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a22:	01 d0                	add    %edx,%eax
  100a24:	0f b6 00             	movzbl (%eax),%eax
  100a27:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a30:	01 ca                	add    %ecx,%edx
  100a32:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a34:	ff 45 f4             	incl   -0xc(%ebp)
  100a37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a3a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a3d:	7c dd                	jl     100a1c <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100a3f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a48:	01 d0                	add    %edx,%eax
  100a4a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a50:	8b 55 08             	mov    0x8(%ebp),%edx
  100a53:	89 d1                	mov    %edx,%ecx
  100a55:	29 c1                	sub    %eax,%ecx
  100a57:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a5d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a61:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a67:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a73:	c7 04 24 e2 6d 10 00 	movl   $0x106de2,(%esp)
  100a7a:	e8 23 f8 ff ff       	call   1002a2 <cprintf>
}
  100a7f:	90                   	nop
  100a80:	c9                   	leave  
  100a81:	c3                   	ret    

00100a82 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a82:	55                   	push   %ebp
  100a83:	89 e5                	mov    %esp,%ebp
  100a85:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a88:	8b 45 04             	mov    0x4(%ebp),%eax
  100a8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a91:	c9                   	leave  
  100a92:	c3                   	ret    

00100a93 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a93:	55                   	push   %ebp
  100a94:	89 e5                	mov    %esp,%ebp
  100a96:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a99:	89 e8                	mov    %ebp,%eax
  100a9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
  100aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  100aa4:	e8 d9 ff ff ff       	call   100a82 <read_eip>
  100aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  100aac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100ab3:	e9 84 00 00 00       	jmp    100b3c <print_stackframe+0xa9>
    	cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
  100ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  100abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ac6:	c7 04 24 f4 6d 10 00 	movl   $0x106df4,(%esp)
  100acd:	e8 d0 f7 ff ff       	call   1002a2 <cprintf>
    	uint32_t *calling_arguments = (uint32_t *) ebp + 2;
  100ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ad5:	83 c0 08             	add    $0x8,%eax
  100ad8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    	for(int j=0;j<4;j++)
  100adb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ae2:	eb 24                	jmp    100b08 <print_stackframe+0x75>
    		cprintf(" 0x%08x ", calling_arguments[j]);		
  100ae4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ae7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100af1:	01 d0                	add    %edx,%eax
  100af3:	8b 00                	mov    (%eax),%eax
  100af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100af9:	c7 04 24 10 6e 10 00 	movl   $0x106e10,(%esp)
  100b00:	e8 9d f7 ff ff       	call   1002a2 <cprintf>
    	for(int j=0;j<4;j++)
  100b05:	ff 45 e8             	incl   -0x18(%ebp)
  100b08:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100b0c:	7e d6                	jle    100ae4 <print_stackframe+0x51>
        cprintf("\n");
  100b0e:	c7 04 24 19 6e 10 00 	movl   $0x106e19,(%esp)
  100b15:	e8 88 f7 ff ff       	call   1002a2 <cprintf>
		print_debuginfo(eip-1);
  100b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b1d:	48                   	dec    %eax
  100b1e:	89 04 24             	mov    %eax,(%esp)
  100b21:	e8 b9 fe ff ff       	call   1009df <print_debuginfo>
    	eip = ((uint32_t *)ebp)[1];
  100b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b29:	83 c0 04             	add    $0x4,%eax
  100b2c:	8b 00                	mov    (%eax),%eax
  100b2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    	ebp = ((uint32_t *)ebp)[0];
  100b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b34:	8b 00                	mov    (%eax),%eax
  100b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  100b39:	ff 45 ec             	incl   -0x14(%ebp)
  100b3c:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b40:	7f 0a                	jg     100b4c <print_stackframe+0xb9>
  100b42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b46:	0f 85 6c ff ff ff    	jne    100ab8 <print_stackframe+0x25>
	}
}
  100b4c:	90                   	nop
  100b4d:	c9                   	leave  
  100b4e:	c3                   	ret    

00100b4f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b4f:	55                   	push   %ebp
  100b50:	89 e5                	mov    %esp,%ebp
  100b52:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b5c:	eb 0c                	jmp    100b6a <parse+0x1b>
            *buf ++ = '\0';
  100b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b61:	8d 50 01             	lea    0x1(%eax),%edx
  100b64:	89 55 08             	mov    %edx,0x8(%ebp)
  100b67:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b6d:	0f b6 00             	movzbl (%eax),%eax
  100b70:	84 c0                	test   %al,%al
  100b72:	74 1d                	je     100b91 <parse+0x42>
  100b74:	8b 45 08             	mov    0x8(%ebp),%eax
  100b77:	0f b6 00             	movzbl (%eax),%eax
  100b7a:	0f be c0             	movsbl %al,%eax
  100b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b81:	c7 04 24 9c 6e 10 00 	movl   $0x106e9c,(%esp)
  100b88:	e8 d4 56 00 00       	call   106261 <strchr>
  100b8d:	85 c0                	test   %eax,%eax
  100b8f:	75 cd                	jne    100b5e <parse+0xf>
        }
        if (*buf == '\0') {
  100b91:	8b 45 08             	mov    0x8(%ebp),%eax
  100b94:	0f b6 00             	movzbl (%eax),%eax
  100b97:	84 c0                	test   %al,%al
  100b99:	74 65                	je     100c00 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b9b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b9f:	75 14                	jne    100bb5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ba1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ba8:	00 
  100ba9:	c7 04 24 a1 6e 10 00 	movl   $0x106ea1,(%esp)
  100bb0:	e8 ed f6 ff ff       	call   1002a2 <cprintf>
        }
        argv[argc ++] = buf;
  100bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bb8:	8d 50 01             	lea    0x1(%eax),%edx
  100bbb:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bc8:	01 c2                	add    %eax,%edx
  100bca:	8b 45 08             	mov    0x8(%ebp),%eax
  100bcd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bcf:	eb 03                	jmp    100bd4 <parse+0x85>
            buf ++;
  100bd1:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  100bd7:	0f b6 00             	movzbl (%eax),%eax
  100bda:	84 c0                	test   %al,%al
  100bdc:	74 8c                	je     100b6a <parse+0x1b>
  100bde:	8b 45 08             	mov    0x8(%ebp),%eax
  100be1:	0f b6 00             	movzbl (%eax),%eax
  100be4:	0f be c0             	movsbl %al,%eax
  100be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100beb:	c7 04 24 9c 6e 10 00 	movl   $0x106e9c,(%esp)
  100bf2:	e8 6a 56 00 00       	call   106261 <strchr>
  100bf7:	85 c0                	test   %eax,%eax
  100bf9:	74 d6                	je     100bd1 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bfb:	e9 6a ff ff ff       	jmp    100b6a <parse+0x1b>
            break;
  100c00:	90                   	nop
        }
    }
    return argc;
  100c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c04:	c9                   	leave  
  100c05:	c3                   	ret    

00100c06 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c06:	55                   	push   %ebp
  100c07:	89 e5                	mov    %esp,%ebp
  100c09:	53                   	push   %ebx
  100c0a:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c0d:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c14:	8b 45 08             	mov    0x8(%ebp),%eax
  100c17:	89 04 24             	mov    %eax,(%esp)
  100c1a:	e8 30 ff ff ff       	call   100b4f <parse>
  100c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c26:	75 0a                	jne    100c32 <runcmd+0x2c>
        return 0;
  100c28:	b8 00 00 00 00       	mov    $0x0,%eax
  100c2d:	e9 83 00 00 00       	jmp    100cb5 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c39:	eb 5a                	jmp    100c95 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c3b:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c41:	89 d0                	mov    %edx,%eax
  100c43:	01 c0                	add    %eax,%eax
  100c45:	01 d0                	add    %edx,%eax
  100c47:	c1 e0 02             	shl    $0x2,%eax
  100c4a:	05 00 a0 11 00       	add    $0x11a000,%eax
  100c4f:	8b 00                	mov    (%eax),%eax
  100c51:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c55:	89 04 24             	mov    %eax,(%esp)
  100c58:	e8 67 55 00 00       	call   1061c4 <strcmp>
  100c5d:	85 c0                	test   %eax,%eax
  100c5f:	75 31                	jne    100c92 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c64:	89 d0                	mov    %edx,%eax
  100c66:	01 c0                	add    %eax,%eax
  100c68:	01 d0                	add    %edx,%eax
  100c6a:	c1 e0 02             	shl    $0x2,%eax
  100c6d:	05 08 a0 11 00       	add    $0x11a008,%eax
  100c72:	8b 10                	mov    (%eax),%edx
  100c74:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c77:	83 c0 04             	add    $0x4,%eax
  100c7a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c7d:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c8b:	89 1c 24             	mov    %ebx,(%esp)
  100c8e:	ff d2                	call   *%edx
  100c90:	eb 23                	jmp    100cb5 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c92:	ff 45 f4             	incl   -0xc(%ebp)
  100c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c98:	83 f8 02             	cmp    $0x2,%eax
  100c9b:	76 9e                	jbe    100c3b <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c9d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ca4:	c7 04 24 bf 6e 10 00 	movl   $0x106ebf,(%esp)
  100cab:	e8 f2 f5 ff ff       	call   1002a2 <cprintf>
    return 0;
  100cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cb5:	83 c4 64             	add    $0x64,%esp
  100cb8:	5b                   	pop    %ebx
  100cb9:	5d                   	pop    %ebp
  100cba:	c3                   	ret    

00100cbb <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cbb:	55                   	push   %ebp
  100cbc:	89 e5                	mov    %esp,%ebp
  100cbe:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cc1:	c7 04 24 d8 6e 10 00 	movl   $0x106ed8,(%esp)
  100cc8:	e8 d5 f5 ff ff       	call   1002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100ccd:	c7 04 24 00 6f 10 00 	movl   $0x106f00,(%esp)
  100cd4:	e8 c9 f5 ff ff       	call   1002a2 <cprintf>

    if (tf != NULL) {
  100cd9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cdd:	74 0b                	je     100cea <kmonitor+0x2f>
        print_trapframe(tf);
  100cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  100ce2:	89 04 24             	mov    %eax,(%esp)
  100ce5:	e8 08 0e 00 00       	call   101af2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cea:	c7 04 24 25 6f 10 00 	movl   $0x106f25,(%esp)
  100cf1:	e8 4e f6 ff ff       	call   100344 <readline>
  100cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cf9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cfd:	74 eb                	je     100cea <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cff:	8b 45 08             	mov    0x8(%ebp),%eax
  100d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d09:	89 04 24             	mov    %eax,(%esp)
  100d0c:	e8 f5 fe ff ff       	call   100c06 <runcmd>
  100d11:	85 c0                	test   %eax,%eax
  100d13:	78 02                	js     100d17 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100d15:	eb d3                	jmp    100cea <kmonitor+0x2f>
                break;
  100d17:	90                   	nop
            }
        }
    }
}
  100d18:	90                   	nop
  100d19:	c9                   	leave  
  100d1a:	c3                   	ret    

00100d1b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d1b:	55                   	push   %ebp
  100d1c:	89 e5                	mov    %esp,%ebp
  100d1e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d28:	eb 3d                	jmp    100d67 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d2d:	89 d0                	mov    %edx,%eax
  100d2f:	01 c0                	add    %eax,%eax
  100d31:	01 d0                	add    %edx,%eax
  100d33:	c1 e0 02             	shl    $0x2,%eax
  100d36:	05 04 a0 11 00       	add    $0x11a004,%eax
  100d3b:	8b 08                	mov    (%eax),%ecx
  100d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d40:	89 d0                	mov    %edx,%eax
  100d42:	01 c0                	add    %eax,%eax
  100d44:	01 d0                	add    %edx,%eax
  100d46:	c1 e0 02             	shl    $0x2,%eax
  100d49:	05 00 a0 11 00       	add    $0x11a000,%eax
  100d4e:	8b 00                	mov    (%eax),%eax
  100d50:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d54:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d58:	c7 04 24 29 6f 10 00 	movl   $0x106f29,(%esp)
  100d5f:	e8 3e f5 ff ff       	call   1002a2 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d64:	ff 45 f4             	incl   -0xc(%ebp)
  100d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d6a:	83 f8 02             	cmp    $0x2,%eax
  100d6d:	76 bb                	jbe    100d2a <mon_help+0xf>
    }
    return 0;
  100d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d74:	c9                   	leave  
  100d75:	c3                   	ret    

00100d76 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d76:	55                   	push   %ebp
  100d77:	89 e5                	mov    %esp,%ebp
  100d79:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d7c:	e8 c7 fb ff ff       	call   100948 <print_kerninfo>
    return 0;
  100d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d86:	c9                   	leave  
  100d87:	c3                   	ret    

00100d88 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d88:	55                   	push   %ebp
  100d89:	89 e5                	mov    %esp,%ebp
  100d8b:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d8e:	e8 00 fd ff ff       	call   100a93 <print_stackframe>
    return 0;
  100d93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d98:	c9                   	leave  
  100d99:	c3                   	ret    

00100d9a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d9a:	55                   	push   %ebp
  100d9b:	89 e5                	mov    %esp,%ebp
  100d9d:	83 ec 28             	sub    $0x28,%esp
  100da0:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100da6:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100daa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dae:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100db2:	ee                   	out    %al,(%dx)
  100db3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100db9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dbd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dc5:	ee                   	out    %al,(%dx)
  100dc6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dcc:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100dd0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dd4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dd8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dd9:	c7 05 0c df 11 00 00 	movl   $0x0,0x11df0c
  100de0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100de3:	c7 04 24 32 6f 10 00 	movl   $0x106f32,(%esp)
  100dea:	e8 b3 f4 ff ff       	call   1002a2 <cprintf>
    pic_enable(IRQ_TIMER);
  100def:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100df6:	e8 2e 09 00 00       	call   101729 <pic_enable>
}
  100dfb:	90                   	nop
  100dfc:	c9                   	leave  
  100dfd:	c3                   	ret    

00100dfe <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100dfe:	55                   	push   %ebp
  100dff:	89 e5                	mov    %esp,%ebp
  100e01:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e04:	9c                   	pushf  
  100e05:	58                   	pop    %eax
  100e06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e0c:	25 00 02 00 00       	and    $0x200,%eax
  100e11:	85 c0                	test   %eax,%eax
  100e13:	74 0c                	je     100e21 <__intr_save+0x23>
        intr_disable();
  100e15:	e8 83 0a 00 00       	call   10189d <intr_disable>
        return 1;
  100e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  100e1f:	eb 05                	jmp    100e26 <__intr_save+0x28>
    }
    return 0;
  100e21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e26:	c9                   	leave  
  100e27:	c3                   	ret    

00100e28 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e28:	55                   	push   %ebp
  100e29:	89 e5                	mov    %esp,%ebp
  100e2b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e2e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e32:	74 05                	je     100e39 <__intr_restore+0x11>
        intr_enable();
  100e34:	e8 5d 0a 00 00       	call   101896 <intr_enable>
    }
}
  100e39:	90                   	nop
  100e3a:	c9                   	leave  
  100e3b:	c3                   	ret    

00100e3c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e3c:	55                   	push   %ebp
  100e3d:	89 e5                	mov    %esp,%ebp
  100e3f:	83 ec 10             	sub    $0x10,%esp
  100e42:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e48:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e4c:	89 c2                	mov    %eax,%edx
  100e4e:	ec                   	in     (%dx),%al
  100e4f:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e52:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e58:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e5c:	89 c2                	mov    %eax,%edx
  100e5e:	ec                   	in     (%dx),%al
  100e5f:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e62:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e68:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e6c:	89 c2                	mov    %eax,%edx
  100e6e:	ec                   	in     (%dx),%al
  100e6f:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e72:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e78:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e7c:	89 c2                	mov    %eax,%edx
  100e7e:	ec                   	in     (%dx),%al
  100e7f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e82:	90                   	nop
  100e83:	c9                   	leave  
  100e84:	c3                   	ret    

00100e85 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e85:	55                   	push   %ebp
  100e86:	89 e5                	mov    %esp,%ebp
  100e88:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e8b:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e95:	0f b7 00             	movzwl (%eax),%eax
  100e98:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e9f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea7:	0f b7 00             	movzwl (%eax),%eax
  100eaa:	0f b7 c0             	movzwl %ax,%eax
  100ead:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100eb2:	74 12                	je     100ec6 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100eb4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ebb:	66 c7 05 46 d4 11 00 	movw   $0x3b4,0x11d446
  100ec2:	b4 03 
  100ec4:	eb 13                	jmp    100ed9 <cga_init+0x54>
    } else {
        *cp = was;
  100ec6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ecd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ed0:	66 c7 05 46 d4 11 00 	movw   $0x3d4,0x11d446
  100ed7:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ed9:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100ee0:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ee4:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ee8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100eec:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ef0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ef1:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100ef8:	40                   	inc    %eax
  100ef9:	0f b7 c0             	movzwl %ax,%eax
  100efc:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f00:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f04:	89 c2                	mov    %eax,%edx
  100f06:	ec                   	in     (%dx),%al
  100f07:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f0a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f0e:	0f b6 c0             	movzbl %al,%eax
  100f11:	c1 e0 08             	shl    $0x8,%eax
  100f14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f17:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100f1e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f22:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f26:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f2a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f2e:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f2f:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100f36:	40                   	inc    %eax
  100f37:	0f b7 c0             	movzwl %ax,%eax
  100f3a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f3e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f42:	89 c2                	mov    %eax,%edx
  100f44:	ec                   	in     (%dx),%al
  100f45:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f48:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f4c:	0f b6 c0             	movzbl %al,%eax
  100f4f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f52:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f55:	a3 40 d4 11 00       	mov    %eax,0x11d440
    crt_pos = pos;
  100f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f5d:	0f b7 c0             	movzwl %ax,%eax
  100f60:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
}
  100f66:	90                   	nop
  100f67:	c9                   	leave  
  100f68:	c3                   	ret    

00100f69 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f69:	55                   	push   %ebp
  100f6a:	89 e5                	mov    %esp,%ebp
  100f6c:	83 ec 48             	sub    $0x48,%esp
  100f6f:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f75:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f79:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f7d:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f81:	ee                   	out    %al,(%dx)
  100f82:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f88:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  100f8c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f90:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f94:	ee                   	out    %al,(%dx)
  100f95:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f9b:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  100f9f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fa3:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fa7:	ee                   	out    %al,(%dx)
  100fa8:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fae:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fb2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fb6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fba:	ee                   	out    %al,(%dx)
  100fbb:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fc1:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  100fc5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fc9:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fcd:	ee                   	out    %al,(%dx)
  100fce:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fd4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  100fd8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fdc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fe0:	ee                   	out    %al,(%dx)
  100fe1:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fe7:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  100feb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fef:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100ff3:	ee                   	out    %al,(%dx)
  100ff4:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ffa:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ffe:	89 c2                	mov    %eax,%edx
  101000:	ec                   	in     (%dx),%al
  101001:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  101004:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101008:	3c ff                	cmp    $0xff,%al
  10100a:	0f 95 c0             	setne  %al
  10100d:	0f b6 c0             	movzbl %al,%eax
  101010:	a3 48 d4 11 00       	mov    %eax,0x11d448
  101015:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10101b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10101f:	89 c2                	mov    %eax,%edx
  101021:	ec                   	in     (%dx),%al
  101022:	88 45 f1             	mov    %al,-0xf(%ebp)
  101025:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10102b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10102f:	89 c2                	mov    %eax,%edx
  101031:	ec                   	in     (%dx),%al
  101032:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101035:	a1 48 d4 11 00       	mov    0x11d448,%eax
  10103a:	85 c0                	test   %eax,%eax
  10103c:	74 0c                	je     10104a <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  10103e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101045:	e8 df 06 00 00       	call   101729 <pic_enable>
    }
}
  10104a:	90                   	nop
  10104b:	c9                   	leave  
  10104c:	c3                   	ret    

0010104d <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10104d:	55                   	push   %ebp
  10104e:	89 e5                	mov    %esp,%ebp
  101050:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101053:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10105a:	eb 08                	jmp    101064 <lpt_putc_sub+0x17>
        delay();
  10105c:	e8 db fd ff ff       	call   100e3c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101061:	ff 45 fc             	incl   -0x4(%ebp)
  101064:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10106a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10106e:	89 c2                	mov    %eax,%edx
  101070:	ec                   	in     (%dx),%al
  101071:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101074:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101078:	84 c0                	test   %al,%al
  10107a:	78 09                	js     101085 <lpt_putc_sub+0x38>
  10107c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101083:	7e d7                	jle    10105c <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101085:	8b 45 08             	mov    0x8(%ebp),%eax
  101088:	0f b6 c0             	movzbl %al,%eax
  10108b:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101091:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101094:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101098:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10109c:	ee                   	out    %al,(%dx)
  10109d:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010a3:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010a7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010ab:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010af:	ee                   	out    %al,(%dx)
  1010b0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010b6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  1010ba:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010be:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010c2:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010c3:	90                   	nop
  1010c4:	c9                   	leave  
  1010c5:	c3                   	ret    

001010c6 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010c6:	55                   	push   %ebp
  1010c7:	89 e5                	mov    %esp,%ebp
  1010c9:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010cc:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010d0:	74 0d                	je     1010df <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1010d5:	89 04 24             	mov    %eax,(%esp)
  1010d8:	e8 70 ff ff ff       	call   10104d <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010dd:	eb 24                	jmp    101103 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  1010df:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e6:	e8 62 ff ff ff       	call   10104d <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010f2:	e8 56 ff ff ff       	call   10104d <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010f7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010fe:	e8 4a ff ff ff       	call   10104d <lpt_putc_sub>
}
  101103:	90                   	nop
  101104:	c9                   	leave  
  101105:	c3                   	ret    

00101106 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101106:	55                   	push   %ebp
  101107:	89 e5                	mov    %esp,%ebp
  101109:	53                   	push   %ebx
  10110a:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10110d:	8b 45 08             	mov    0x8(%ebp),%eax
  101110:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101115:	85 c0                	test   %eax,%eax
  101117:	75 07                	jne    101120 <cga_putc+0x1a>
        c |= 0x0700;
  101119:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101120:	8b 45 08             	mov    0x8(%ebp),%eax
  101123:	0f b6 c0             	movzbl %al,%eax
  101126:	83 f8 0a             	cmp    $0xa,%eax
  101129:	74 55                	je     101180 <cga_putc+0x7a>
  10112b:	83 f8 0d             	cmp    $0xd,%eax
  10112e:	74 63                	je     101193 <cga_putc+0x8d>
  101130:	83 f8 08             	cmp    $0x8,%eax
  101133:	0f 85 94 00 00 00    	jne    1011cd <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
  101139:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101140:	85 c0                	test   %eax,%eax
  101142:	0f 84 af 00 00 00    	je     1011f7 <cga_putc+0xf1>
            crt_pos --;
  101148:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  10114f:	48                   	dec    %eax
  101150:	0f b7 c0             	movzwl %ax,%eax
  101153:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101159:	8b 45 08             	mov    0x8(%ebp),%eax
  10115c:	98                   	cwtl   
  10115d:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101162:	98                   	cwtl   
  101163:	83 c8 20             	or     $0x20,%eax
  101166:	98                   	cwtl   
  101167:	8b 15 40 d4 11 00    	mov    0x11d440,%edx
  10116d:	0f b7 0d 44 d4 11 00 	movzwl 0x11d444,%ecx
  101174:	01 c9                	add    %ecx,%ecx
  101176:	01 ca                	add    %ecx,%edx
  101178:	0f b7 c0             	movzwl %ax,%eax
  10117b:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10117e:	eb 77                	jmp    1011f7 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  101180:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101187:	83 c0 50             	add    $0x50,%eax
  10118a:	0f b7 c0             	movzwl %ax,%eax
  10118d:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101193:	0f b7 1d 44 d4 11 00 	movzwl 0x11d444,%ebx
  10119a:	0f b7 0d 44 d4 11 00 	movzwl 0x11d444,%ecx
  1011a1:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011a6:	89 c8                	mov    %ecx,%eax
  1011a8:	f7 e2                	mul    %edx
  1011aa:	c1 ea 06             	shr    $0x6,%edx
  1011ad:	89 d0                	mov    %edx,%eax
  1011af:	c1 e0 02             	shl    $0x2,%eax
  1011b2:	01 d0                	add    %edx,%eax
  1011b4:	c1 e0 04             	shl    $0x4,%eax
  1011b7:	29 c1                	sub    %eax,%ecx
  1011b9:	89 c8                	mov    %ecx,%eax
  1011bb:	0f b7 c0             	movzwl %ax,%eax
  1011be:	29 c3                	sub    %eax,%ebx
  1011c0:	89 d8                	mov    %ebx,%eax
  1011c2:	0f b7 c0             	movzwl %ax,%eax
  1011c5:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
        break;
  1011cb:	eb 2b                	jmp    1011f8 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011cd:	8b 0d 40 d4 11 00    	mov    0x11d440,%ecx
  1011d3:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1011da:	8d 50 01             	lea    0x1(%eax),%edx
  1011dd:	0f b7 d2             	movzwl %dx,%edx
  1011e0:	66 89 15 44 d4 11 00 	mov    %dx,0x11d444
  1011e7:	01 c0                	add    %eax,%eax
  1011e9:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1011ef:	0f b7 c0             	movzwl %ax,%eax
  1011f2:	66 89 02             	mov    %ax,(%edx)
        break;
  1011f5:	eb 01                	jmp    1011f8 <cga_putc+0xf2>
        break;
  1011f7:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011f8:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1011ff:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101204:	76 5d                	jbe    101263 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101206:	a1 40 d4 11 00       	mov    0x11d440,%eax
  10120b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101211:	a1 40 d4 11 00       	mov    0x11d440,%eax
  101216:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10121d:	00 
  10121e:	89 54 24 04          	mov    %edx,0x4(%esp)
  101222:	89 04 24             	mov    %eax,(%esp)
  101225:	e8 2d 52 00 00       	call   106457 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10122a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101231:	eb 14                	jmp    101247 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  101233:	a1 40 d4 11 00       	mov    0x11d440,%eax
  101238:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10123b:	01 d2                	add    %edx,%edx
  10123d:	01 d0                	add    %edx,%eax
  10123f:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101244:	ff 45 f4             	incl   -0xc(%ebp)
  101247:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10124e:	7e e3                	jle    101233 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
  101250:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101257:	83 e8 50             	sub    $0x50,%eax
  10125a:	0f b7 c0             	movzwl %ax,%eax
  10125d:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101263:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  10126a:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  10126e:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101272:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101276:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10127a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10127b:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101282:	c1 e8 08             	shr    $0x8,%eax
  101285:	0f b7 c0             	movzwl %ax,%eax
  101288:	0f b6 c0             	movzbl %al,%eax
  10128b:	0f b7 15 46 d4 11 00 	movzwl 0x11d446,%edx
  101292:	42                   	inc    %edx
  101293:	0f b7 d2             	movzwl %dx,%edx
  101296:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  10129a:	88 45 e9             	mov    %al,-0x17(%ebp)
  10129d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012a1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012a5:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1012a6:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  1012ad:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012b1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  1012b5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012b9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012bd:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012be:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1012c5:	0f b6 c0             	movzbl %al,%eax
  1012c8:	0f b7 15 46 d4 11 00 	movzwl 0x11d446,%edx
  1012cf:	42                   	inc    %edx
  1012d0:	0f b7 d2             	movzwl %dx,%edx
  1012d3:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1012d7:	88 45 f1             	mov    %al,-0xf(%ebp)
  1012da:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1012de:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1012e2:	ee                   	out    %al,(%dx)
}
  1012e3:	90                   	nop
  1012e4:	83 c4 34             	add    $0x34,%esp
  1012e7:	5b                   	pop    %ebx
  1012e8:	5d                   	pop    %ebp
  1012e9:	c3                   	ret    

001012ea <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012ea:	55                   	push   %ebp
  1012eb:	89 e5                	mov    %esp,%ebp
  1012ed:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012f7:	eb 08                	jmp    101301 <serial_putc_sub+0x17>
        delay();
  1012f9:	e8 3e fb ff ff       	call   100e3c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012fe:	ff 45 fc             	incl   -0x4(%ebp)
  101301:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101307:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10130b:	89 c2                	mov    %eax,%edx
  10130d:	ec                   	in     (%dx),%al
  10130e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101311:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101315:	0f b6 c0             	movzbl %al,%eax
  101318:	83 e0 20             	and    $0x20,%eax
  10131b:	85 c0                	test   %eax,%eax
  10131d:	75 09                	jne    101328 <serial_putc_sub+0x3e>
  10131f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101326:	7e d1                	jle    1012f9 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101328:	8b 45 08             	mov    0x8(%ebp),%eax
  10132b:	0f b6 c0             	movzbl %al,%eax
  10132e:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101334:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101337:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10133b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10133f:	ee                   	out    %al,(%dx)
}
  101340:	90                   	nop
  101341:	c9                   	leave  
  101342:	c3                   	ret    

00101343 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101343:	55                   	push   %ebp
  101344:	89 e5                	mov    %esp,%ebp
  101346:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101349:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10134d:	74 0d                	je     10135c <serial_putc+0x19>
        serial_putc_sub(c);
  10134f:	8b 45 08             	mov    0x8(%ebp),%eax
  101352:	89 04 24             	mov    %eax,(%esp)
  101355:	e8 90 ff ff ff       	call   1012ea <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10135a:	eb 24                	jmp    101380 <serial_putc+0x3d>
        serial_putc_sub('\b');
  10135c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101363:	e8 82 ff ff ff       	call   1012ea <serial_putc_sub>
        serial_putc_sub(' ');
  101368:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10136f:	e8 76 ff ff ff       	call   1012ea <serial_putc_sub>
        serial_putc_sub('\b');
  101374:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10137b:	e8 6a ff ff ff       	call   1012ea <serial_putc_sub>
}
  101380:	90                   	nop
  101381:	c9                   	leave  
  101382:	c3                   	ret    

00101383 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101383:	55                   	push   %ebp
  101384:	89 e5                	mov    %esp,%ebp
  101386:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101389:	eb 33                	jmp    1013be <cons_intr+0x3b>
        if (c != 0) {
  10138b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10138f:	74 2d                	je     1013be <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101391:	a1 64 d6 11 00       	mov    0x11d664,%eax
  101396:	8d 50 01             	lea    0x1(%eax),%edx
  101399:	89 15 64 d6 11 00    	mov    %edx,0x11d664
  10139f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013a2:	88 90 60 d4 11 00    	mov    %dl,0x11d460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013a8:	a1 64 d6 11 00       	mov    0x11d664,%eax
  1013ad:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013b2:	75 0a                	jne    1013be <cons_intr+0x3b>
                cons.wpos = 0;
  1013b4:	c7 05 64 d6 11 00 00 	movl   $0x0,0x11d664
  1013bb:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013be:	8b 45 08             	mov    0x8(%ebp),%eax
  1013c1:	ff d0                	call   *%eax
  1013c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013c6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013ca:	75 bf                	jne    10138b <cons_intr+0x8>
            }
        }
    }
}
  1013cc:	90                   	nop
  1013cd:	c9                   	leave  
  1013ce:	c3                   	ret    

001013cf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013cf:	55                   	push   %ebp
  1013d0:	89 e5                	mov    %esp,%ebp
  1013d2:	83 ec 10             	sub    $0x10,%esp
  1013d5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013db:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013df:	89 c2                	mov    %eax,%edx
  1013e1:	ec                   	in     (%dx),%al
  1013e2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013e5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013e9:	0f b6 c0             	movzbl %al,%eax
  1013ec:	83 e0 01             	and    $0x1,%eax
  1013ef:	85 c0                	test   %eax,%eax
  1013f1:	75 07                	jne    1013fa <serial_proc_data+0x2b>
        return -1;
  1013f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013f8:	eb 2a                	jmp    101424 <serial_proc_data+0x55>
  1013fa:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101400:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101404:	89 c2                	mov    %eax,%edx
  101406:	ec                   	in     (%dx),%al
  101407:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  10140a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  10140e:	0f b6 c0             	movzbl %al,%eax
  101411:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101414:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101418:	75 07                	jne    101421 <serial_proc_data+0x52>
        c = '\b';
  10141a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101421:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101424:	c9                   	leave  
  101425:	c3                   	ret    

00101426 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101426:	55                   	push   %ebp
  101427:	89 e5                	mov    %esp,%ebp
  101429:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10142c:	a1 48 d4 11 00       	mov    0x11d448,%eax
  101431:	85 c0                	test   %eax,%eax
  101433:	74 0c                	je     101441 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101435:	c7 04 24 cf 13 10 00 	movl   $0x1013cf,(%esp)
  10143c:	e8 42 ff ff ff       	call   101383 <cons_intr>
    }
}
  101441:	90                   	nop
  101442:	c9                   	leave  
  101443:	c3                   	ret    

00101444 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101444:	55                   	push   %ebp
  101445:	89 e5                	mov    %esp,%ebp
  101447:	83 ec 38             	sub    $0x38,%esp
  10144a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101453:	89 c2                	mov    %eax,%edx
  101455:	ec                   	in     (%dx),%al
  101456:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101459:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10145d:	0f b6 c0             	movzbl %al,%eax
  101460:	83 e0 01             	and    $0x1,%eax
  101463:	85 c0                	test   %eax,%eax
  101465:	75 0a                	jne    101471 <kbd_proc_data+0x2d>
        return -1;
  101467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10146c:	e9 55 01 00 00       	jmp    1015c6 <kbd_proc_data+0x182>
  101471:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101477:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10147a:	89 c2                	mov    %eax,%edx
  10147c:	ec                   	in     (%dx),%al
  10147d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101480:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101484:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101487:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10148b:	75 17                	jne    1014a4 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  10148d:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101492:	83 c8 40             	or     $0x40,%eax
  101495:	a3 68 d6 11 00       	mov    %eax,0x11d668
        return 0;
  10149a:	b8 00 00 00 00       	mov    $0x0,%eax
  10149f:	e9 22 01 00 00       	jmp    1015c6 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  1014a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a8:	84 c0                	test   %al,%al
  1014aa:	79 45                	jns    1014f1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014ac:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1014b1:	83 e0 40             	and    $0x40,%eax
  1014b4:	85 c0                	test   %eax,%eax
  1014b6:	75 08                	jne    1014c0 <kbd_proc_data+0x7c>
  1014b8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bc:	24 7f                	and    $0x7f,%al
  1014be:	eb 04                	jmp    1014c4 <kbd_proc_data+0x80>
  1014c0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014cb:	0f b6 80 40 a0 11 00 	movzbl 0x11a040(%eax),%eax
  1014d2:	0c 40                	or     $0x40,%al
  1014d4:	0f b6 c0             	movzbl %al,%eax
  1014d7:	f7 d0                	not    %eax
  1014d9:	89 c2                	mov    %eax,%edx
  1014db:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1014e0:	21 d0                	and    %edx,%eax
  1014e2:	a3 68 d6 11 00       	mov    %eax,0x11d668
        return 0;
  1014e7:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ec:	e9 d5 00 00 00       	jmp    1015c6 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  1014f1:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1014f6:	83 e0 40             	and    $0x40,%eax
  1014f9:	85 c0                	test   %eax,%eax
  1014fb:	74 11                	je     10150e <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014fd:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101501:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101506:	83 e0 bf             	and    $0xffffffbf,%eax
  101509:	a3 68 d6 11 00       	mov    %eax,0x11d668
    }

    shift |= shiftcode[data];
  10150e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101512:	0f b6 80 40 a0 11 00 	movzbl 0x11a040(%eax),%eax
  101519:	0f b6 d0             	movzbl %al,%edx
  10151c:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101521:	09 d0                	or     %edx,%eax
  101523:	a3 68 d6 11 00       	mov    %eax,0x11d668
    shift ^= togglecode[data];
  101528:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10152c:	0f b6 80 40 a1 11 00 	movzbl 0x11a140(%eax),%eax
  101533:	0f b6 d0             	movzbl %al,%edx
  101536:	a1 68 d6 11 00       	mov    0x11d668,%eax
  10153b:	31 d0                	xor    %edx,%eax
  10153d:	a3 68 d6 11 00       	mov    %eax,0x11d668

    c = charcode[shift & (CTL | SHIFT)][data];
  101542:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101547:	83 e0 03             	and    $0x3,%eax
  10154a:	8b 14 85 40 a5 11 00 	mov    0x11a540(,%eax,4),%edx
  101551:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101555:	01 d0                	add    %edx,%eax
  101557:	0f b6 00             	movzbl (%eax),%eax
  10155a:	0f b6 c0             	movzbl %al,%eax
  10155d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101560:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101565:	83 e0 08             	and    $0x8,%eax
  101568:	85 c0                	test   %eax,%eax
  10156a:	74 22                	je     10158e <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  10156c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101570:	7e 0c                	jle    10157e <kbd_proc_data+0x13a>
  101572:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101576:	7f 06                	jg     10157e <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101578:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10157c:	eb 10                	jmp    10158e <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  10157e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101582:	7e 0a                	jle    10158e <kbd_proc_data+0x14a>
  101584:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101588:	7f 04                	jg     10158e <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10158a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10158e:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101593:	f7 d0                	not    %eax
  101595:	83 e0 06             	and    $0x6,%eax
  101598:	85 c0                	test   %eax,%eax
  10159a:	75 27                	jne    1015c3 <kbd_proc_data+0x17f>
  10159c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015a3:	75 1e                	jne    1015c3 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  1015a5:	c7 04 24 4d 6f 10 00 	movl   $0x106f4d,(%esp)
  1015ac:	e8 f1 ec ff ff       	call   1002a2 <cprintf>
  1015b1:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015b7:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015bb:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015bf:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1015c2:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015c6:	c9                   	leave  
  1015c7:	c3                   	ret    

001015c8 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015c8:	55                   	push   %ebp
  1015c9:	89 e5                	mov    %esp,%ebp
  1015cb:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015ce:	c7 04 24 44 14 10 00 	movl   $0x101444,(%esp)
  1015d5:	e8 a9 fd ff ff       	call   101383 <cons_intr>
}
  1015da:	90                   	nop
  1015db:	c9                   	leave  
  1015dc:	c3                   	ret    

001015dd <kbd_init>:

static void
kbd_init(void) {
  1015dd:	55                   	push   %ebp
  1015de:	89 e5                	mov    %esp,%ebp
  1015e0:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015e3:	e8 e0 ff ff ff       	call   1015c8 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015ef:	e8 35 01 00 00       	call   101729 <pic_enable>
}
  1015f4:	90                   	nop
  1015f5:	c9                   	leave  
  1015f6:	c3                   	ret    

001015f7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015f7:	55                   	push   %ebp
  1015f8:	89 e5                	mov    %esp,%ebp
  1015fa:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015fd:	e8 83 f8 ff ff       	call   100e85 <cga_init>
    serial_init();
  101602:	e8 62 f9 ff ff       	call   100f69 <serial_init>
    kbd_init();
  101607:	e8 d1 ff ff ff       	call   1015dd <kbd_init>
    if (!serial_exists) {
  10160c:	a1 48 d4 11 00       	mov    0x11d448,%eax
  101611:	85 c0                	test   %eax,%eax
  101613:	75 0c                	jne    101621 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101615:	c7 04 24 59 6f 10 00 	movl   $0x106f59,(%esp)
  10161c:	e8 81 ec ff ff       	call   1002a2 <cprintf>
    }
}
  101621:	90                   	nop
  101622:	c9                   	leave  
  101623:	c3                   	ret    

00101624 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101624:	55                   	push   %ebp
  101625:	89 e5                	mov    %esp,%ebp
  101627:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10162a:	e8 cf f7 ff ff       	call   100dfe <__intr_save>
  10162f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101632:	8b 45 08             	mov    0x8(%ebp),%eax
  101635:	89 04 24             	mov    %eax,(%esp)
  101638:	e8 89 fa ff ff       	call   1010c6 <lpt_putc>
        cga_putc(c);
  10163d:	8b 45 08             	mov    0x8(%ebp),%eax
  101640:	89 04 24             	mov    %eax,(%esp)
  101643:	e8 be fa ff ff       	call   101106 <cga_putc>
        serial_putc(c);
  101648:	8b 45 08             	mov    0x8(%ebp),%eax
  10164b:	89 04 24             	mov    %eax,(%esp)
  10164e:	e8 f0 fc ff ff       	call   101343 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101656:	89 04 24             	mov    %eax,(%esp)
  101659:	e8 ca f7 ff ff       	call   100e28 <__intr_restore>
}
  10165e:	90                   	nop
  10165f:	c9                   	leave  
  101660:	c3                   	ret    

00101661 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101661:	55                   	push   %ebp
  101662:	89 e5                	mov    %esp,%ebp
  101664:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101667:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10166e:	e8 8b f7 ff ff       	call   100dfe <__intr_save>
  101673:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101676:	e8 ab fd ff ff       	call   101426 <serial_intr>
        kbd_intr();
  10167b:	e8 48 ff ff ff       	call   1015c8 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101680:	8b 15 60 d6 11 00    	mov    0x11d660,%edx
  101686:	a1 64 d6 11 00       	mov    0x11d664,%eax
  10168b:	39 c2                	cmp    %eax,%edx
  10168d:	74 31                	je     1016c0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10168f:	a1 60 d6 11 00       	mov    0x11d660,%eax
  101694:	8d 50 01             	lea    0x1(%eax),%edx
  101697:	89 15 60 d6 11 00    	mov    %edx,0x11d660
  10169d:	0f b6 80 60 d4 11 00 	movzbl 0x11d460(%eax),%eax
  1016a4:	0f b6 c0             	movzbl %al,%eax
  1016a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016aa:	a1 60 d6 11 00       	mov    0x11d660,%eax
  1016af:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016b4:	75 0a                	jne    1016c0 <cons_getc+0x5f>
                cons.rpos = 0;
  1016b6:	c7 05 60 d6 11 00 00 	movl   $0x0,0x11d660
  1016bd:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016c3:	89 04 24             	mov    %eax,(%esp)
  1016c6:	e8 5d f7 ff ff       	call   100e28 <__intr_restore>
    return c;
  1016cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016ce:	c9                   	leave  
  1016cf:	c3                   	ret    

001016d0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016d0:	55                   	push   %ebp
  1016d1:	89 e5                	mov    %esp,%ebp
  1016d3:	83 ec 14             	sub    $0x14,%esp
  1016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1016d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016e0:	66 a3 50 a5 11 00    	mov    %ax,0x11a550
    if (did_init) {
  1016e6:	a1 6c d6 11 00       	mov    0x11d66c,%eax
  1016eb:	85 c0                	test   %eax,%eax
  1016ed:	74 37                	je     101726 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016f2:	0f b6 c0             	movzbl %al,%eax
  1016f5:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1016fb:	88 45 f9             	mov    %al,-0x7(%ebp)
  1016fe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101702:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101706:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101707:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10170b:	c1 e8 08             	shr    $0x8,%eax
  10170e:	0f b7 c0             	movzwl %ax,%eax
  101711:	0f b6 c0             	movzbl %al,%eax
  101714:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10171a:	88 45 fd             	mov    %al,-0x3(%ebp)
  10171d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101721:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101725:	ee                   	out    %al,(%dx)
    }
}
  101726:	90                   	nop
  101727:	c9                   	leave  
  101728:	c3                   	ret    

00101729 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101729:	55                   	push   %ebp
  10172a:	89 e5                	mov    %esp,%ebp
  10172c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10172f:	8b 45 08             	mov    0x8(%ebp),%eax
  101732:	ba 01 00 00 00       	mov    $0x1,%edx
  101737:	88 c1                	mov    %al,%cl
  101739:	d3 e2                	shl    %cl,%edx
  10173b:	89 d0                	mov    %edx,%eax
  10173d:	98                   	cwtl   
  10173e:	f7 d0                	not    %eax
  101740:	0f bf d0             	movswl %ax,%edx
  101743:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  10174a:	98                   	cwtl   
  10174b:	21 d0                	and    %edx,%eax
  10174d:	98                   	cwtl   
  10174e:	0f b7 c0             	movzwl %ax,%eax
  101751:	89 04 24             	mov    %eax,(%esp)
  101754:	e8 77 ff ff ff       	call   1016d0 <pic_setmask>
}
  101759:	90                   	nop
  10175a:	c9                   	leave  
  10175b:	c3                   	ret    

0010175c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  10175c:	55                   	push   %ebp
  10175d:	89 e5                	mov    %esp,%ebp
  10175f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101762:	c7 05 6c d6 11 00 01 	movl   $0x1,0x11d66c
  101769:	00 00 00 
  10176c:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101772:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  101776:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  10177a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10177e:	ee                   	out    %al,(%dx)
  10177f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101785:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  101789:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10178d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101791:	ee                   	out    %al,(%dx)
  101792:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101798:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  10179c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017a0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017a4:	ee                   	out    %al,(%dx)
  1017a5:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  1017ab:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  1017af:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017b3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017b7:	ee                   	out    %al,(%dx)
  1017b8:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1017be:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  1017c2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017c6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017ca:	ee                   	out    %al,(%dx)
  1017cb:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1017d1:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  1017d5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017d9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017dd:	ee                   	out    %al,(%dx)
  1017de:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1017e4:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  1017e8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017ec:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017f0:	ee                   	out    %al,(%dx)
  1017f1:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1017f7:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  1017fb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017ff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101803:	ee                   	out    %al,(%dx)
  101804:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  10180a:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  10180e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101812:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101816:	ee                   	out    %al,(%dx)
  101817:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10181d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  101821:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101825:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101829:	ee                   	out    %al,(%dx)
  10182a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101830:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  101834:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101838:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10183c:	ee                   	out    %al,(%dx)
  10183d:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101843:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  101847:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10184b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10184f:	ee                   	out    %al,(%dx)
  101850:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101856:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  10185a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10185e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101862:	ee                   	out    %al,(%dx)
  101863:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  101869:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  10186d:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101871:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101875:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101876:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  10187d:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101882:	74 0f                	je     101893 <pic_init+0x137>
        pic_setmask(irq_mask);
  101884:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  10188b:	89 04 24             	mov    %eax,(%esp)
  10188e:	e8 3d fe ff ff       	call   1016d0 <pic_setmask>
    }
}
  101893:	90                   	nop
  101894:	c9                   	leave  
  101895:	c3                   	ret    

00101896 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101896:	55                   	push   %ebp
  101897:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101899:	fb                   	sti    
    sti();
}
  10189a:	90                   	nop
  10189b:	5d                   	pop    %ebp
  10189c:	c3                   	ret    

0010189d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10189d:	55                   	push   %ebp
  10189e:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  1018a0:	fa                   	cli    
    cli();
}
  1018a1:	90                   	nop
  1018a2:	5d                   	pop    %ebp
  1018a3:	c3                   	ret    

001018a4 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1018a4:	55                   	push   %ebp
  1018a5:	89 e5                	mov    %esp,%ebp
  1018a7:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1018aa:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018b1:	00 
  1018b2:	c7 04 24 80 6f 10 00 	movl   $0x106f80,(%esp)
  1018b9:	e8 e4 e9 ff ff       	call   1002a2 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018be:	90                   	nop
  1018bf:	c9                   	leave  
  1018c0:	c3                   	ret    

001018c1 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018c1:	55                   	push   %ebp
  1018c2:	89 e5                	mov    %esp,%ebp
  1018c4:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) { 
  1018c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018ce:	e9 c4 00 00 00       	jmp    101997 <idt_init+0xd6>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
  1018d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d6:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  1018dd:	0f b7 d0             	movzwl %ax,%edx
  1018e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e3:	66 89 14 c5 80 d6 11 	mov    %dx,0x11d680(,%eax,8)
  1018ea:	00 
  1018eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ee:	66 c7 04 c5 82 d6 11 	movw   $0x8,0x11d682(,%eax,8)
  1018f5:	00 08 00 
  1018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fb:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  101902:	00 
  101903:	80 e2 e0             	and    $0xe0,%dl
  101906:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  10190d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101910:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  101917:	00 
  101918:	80 e2 1f             	and    $0x1f,%dl
  10191b:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  101922:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101925:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  10192c:	00 
  10192d:	80 e2 f0             	and    $0xf0,%dl
  101930:	80 ca 0e             	or     $0xe,%dl
  101933:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  10193a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10193d:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101944:	00 
  101945:	80 e2 ef             	and    $0xef,%dl
  101948:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  10194f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101952:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101959:	00 
  10195a:	80 e2 9f             	and    $0x9f,%dl
  10195d:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101964:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101967:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  10196e:	00 
  10196f:	80 ca 80             	or     $0x80,%dl
  101972:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  101983:	c1 e8 10             	shr    $0x10,%eax
  101986:	0f b7 d0             	movzwl %ax,%edx
  101989:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198c:	66 89 14 c5 86 d6 11 	mov    %dx,0x11d686(,%eax,8)
  101993:	00 
    for (int i = 0; i < 256; i++) { 
  101994:	ff 45 fc             	incl   -0x4(%ebp)
  101997:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  10199e:	0f 8e 2f ff ff ff    	jle    1018d3 <idt_init+0x12>
    }
    //referenced: #define SETGATE(gate, istrap, sel, off, dpl)
    //so the 'istrap' below is set as 1;
    //referenced:  KERNEL_CS    ((GD_KTEXT) | DPL_KERNEL)
    SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], DPL_USER);
  1019a4:	a1 c4 a7 11 00       	mov    0x11a7c4,%eax
  1019a9:	0f b7 c0             	movzwl %ax,%eax
  1019ac:	66 a3 48 da 11 00    	mov    %ax,0x11da48
  1019b2:	66 c7 05 4a da 11 00 	movw   $0x8,0x11da4a
  1019b9:	08 00 
  1019bb:	0f b6 05 4c da 11 00 	movzbl 0x11da4c,%eax
  1019c2:	24 e0                	and    $0xe0,%al
  1019c4:	a2 4c da 11 00       	mov    %al,0x11da4c
  1019c9:	0f b6 05 4c da 11 00 	movzbl 0x11da4c,%eax
  1019d0:	24 1f                	and    $0x1f,%al
  1019d2:	a2 4c da 11 00       	mov    %al,0x11da4c
  1019d7:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  1019de:	0c 0f                	or     $0xf,%al
  1019e0:	a2 4d da 11 00       	mov    %al,0x11da4d
  1019e5:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  1019ec:	24 ef                	and    $0xef,%al
  1019ee:	a2 4d da 11 00       	mov    %al,0x11da4d
  1019f3:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  1019fa:	0c 60                	or     $0x60,%al
  1019fc:	a2 4d da 11 00       	mov    %al,0x11da4d
  101a01:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  101a08:	0c 80                	or     $0x80,%al
  101a0a:	a2 4d da 11 00       	mov    %al,0x11da4d
  101a0f:	a1 c4 a7 11 00       	mov    0x11a7c4,%eax
  101a14:	c1 e8 10             	shr    $0x10,%eax
  101a17:	0f b7 c0             	movzwl %ax,%eax
  101a1a:	66 a3 4e da 11 00    	mov    %ax,0x11da4e
    SETGATE(idt[T_SWITCH_TOU], 1, KERNEL_CS, __vectors[T_SWITCH_TOU], DPL_KERNEL);
  101a20:	a1 c0 a7 11 00       	mov    0x11a7c0,%eax
  101a25:	0f b7 c0             	movzwl %ax,%eax
  101a28:	66 a3 40 da 11 00    	mov    %ax,0x11da40
  101a2e:	66 c7 05 42 da 11 00 	movw   $0x8,0x11da42
  101a35:	08 00 
  101a37:	0f b6 05 44 da 11 00 	movzbl 0x11da44,%eax
  101a3e:	24 e0                	and    $0xe0,%al
  101a40:	a2 44 da 11 00       	mov    %al,0x11da44
  101a45:	0f b6 05 44 da 11 00 	movzbl 0x11da44,%eax
  101a4c:	24 1f                	and    $0x1f,%al
  101a4e:	a2 44 da 11 00       	mov    %al,0x11da44
  101a53:	0f b6 05 45 da 11 00 	movzbl 0x11da45,%eax
  101a5a:	0c 0f                	or     $0xf,%al
  101a5c:	a2 45 da 11 00       	mov    %al,0x11da45
  101a61:	0f b6 05 45 da 11 00 	movzbl 0x11da45,%eax
  101a68:	24 ef                	and    $0xef,%al
  101a6a:	a2 45 da 11 00       	mov    %al,0x11da45
  101a6f:	0f b6 05 45 da 11 00 	movzbl 0x11da45,%eax
  101a76:	24 9f                	and    $0x9f,%al
  101a78:	a2 45 da 11 00       	mov    %al,0x11da45
  101a7d:	0f b6 05 45 da 11 00 	movzbl 0x11da45,%eax
  101a84:	0c 80                	or     $0x80,%al
  101a86:	a2 45 da 11 00       	mov    %al,0x11da45
  101a8b:	a1 c0 a7 11 00       	mov    0x11a7c0,%eax
  101a90:	c1 e8 10             	shr    $0x10,%eax
  101a93:	0f b7 c0             	movzwl %ax,%eax
  101a96:	66 a3 46 da 11 00    	mov    %ax,0x11da46
  101a9c:	c7 45 f8 60 a5 11 00 	movl   $0x11a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101aa3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101aa6:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  101aa9:	90                   	nop
  101aaa:	c9                   	leave  
  101aab:	c3                   	ret    

00101aac <trapname>:

static const char *
trapname(int trapno) {
  101aac:	55                   	push   %ebp
  101aad:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab2:	83 f8 13             	cmp    $0x13,%eax
  101ab5:	77 0c                	ja     101ac3 <trapname+0x17>
        return excnames[trapno];
  101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aba:	8b 04 85 20 73 10 00 	mov    0x107320(,%eax,4),%eax
  101ac1:	eb 18                	jmp    101adb <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101ac3:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101ac7:	7e 0d                	jle    101ad6 <trapname+0x2a>
  101ac9:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101acd:	7f 07                	jg     101ad6 <trapname+0x2a>
        return "Hardware Interrupt";
  101acf:	b8 8a 6f 10 00       	mov    $0x106f8a,%eax
  101ad4:	eb 05                	jmp    101adb <trapname+0x2f>
    }
    return "(unknown trap)";
  101ad6:	b8 9d 6f 10 00       	mov    $0x106f9d,%eax
}
  101adb:	5d                   	pop    %ebp
  101adc:	c3                   	ret    

00101add <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101add:	55                   	push   %ebp
  101ade:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ae7:	83 f8 08             	cmp    $0x8,%eax
  101aea:	0f 94 c0             	sete   %al
  101aed:	0f b6 c0             	movzbl %al,%eax
}
  101af0:	5d                   	pop    %ebp
  101af1:	c3                   	ret    

00101af2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101af2:	55                   	push   %ebp
  101af3:	89 e5                	mov    %esp,%ebp
  101af5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101af8:	8b 45 08             	mov    0x8(%ebp),%eax
  101afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aff:	c7 04 24 de 6f 10 00 	movl   $0x106fde,(%esp)
  101b06:	e8 97 e7 ff ff       	call   1002a2 <cprintf>
    print_regs(&tf->tf_regs);
  101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b0e:	89 04 24             	mov    %eax,(%esp)
  101b11:	e8 8f 01 00 00       	call   101ca5 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b16:	8b 45 08             	mov    0x8(%ebp),%eax
  101b19:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b21:	c7 04 24 ef 6f 10 00 	movl   $0x106fef,(%esp)
  101b28:	e8 75 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b30:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b38:	c7 04 24 02 70 10 00 	movl   $0x107002,(%esp)
  101b3f:	e8 5e e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b44:	8b 45 08             	mov    0x8(%ebp),%eax
  101b47:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4f:	c7 04 24 15 70 10 00 	movl   $0x107015,(%esp)
  101b56:	e8 47 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b66:	c7 04 24 28 70 10 00 	movl   $0x107028,(%esp)
  101b6d:	e8 30 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b72:	8b 45 08             	mov    0x8(%ebp),%eax
  101b75:	8b 40 30             	mov    0x30(%eax),%eax
  101b78:	89 04 24             	mov    %eax,(%esp)
  101b7b:	e8 2c ff ff ff       	call   101aac <trapname>
  101b80:	89 c2                	mov    %eax,%edx
  101b82:	8b 45 08             	mov    0x8(%ebp),%eax
  101b85:	8b 40 30             	mov    0x30(%eax),%eax
  101b88:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b90:	c7 04 24 3b 70 10 00 	movl   $0x10703b,(%esp)
  101b97:	e8 06 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9f:	8b 40 34             	mov    0x34(%eax),%eax
  101ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba6:	c7 04 24 4d 70 10 00 	movl   $0x10704d,(%esp)
  101bad:	e8 f0 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb5:	8b 40 38             	mov    0x38(%eax),%eax
  101bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bbc:	c7 04 24 5c 70 10 00 	movl   $0x10705c,(%esp)
  101bc3:	e8 da e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd3:	c7 04 24 6b 70 10 00 	movl   $0x10706b,(%esp)
  101bda:	e8 c3 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  101be2:	8b 40 40             	mov    0x40(%eax),%eax
  101be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be9:	c7 04 24 7e 70 10 00 	movl   $0x10707e,(%esp)
  101bf0:	e8 ad e6 ff ff       	call   1002a2 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101bfc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c03:	eb 3d                	jmp    101c42 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c05:	8b 45 08             	mov    0x8(%ebp),%eax
  101c08:	8b 50 40             	mov    0x40(%eax),%edx
  101c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c0e:	21 d0                	and    %edx,%eax
  101c10:	85 c0                	test   %eax,%eax
  101c12:	74 28                	je     101c3c <print_trapframe+0x14a>
  101c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c17:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101c1e:	85 c0                	test   %eax,%eax
  101c20:	74 1a                	je     101c3c <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c25:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c30:	c7 04 24 8d 70 10 00 	movl   $0x10708d,(%esp)
  101c37:	e8 66 e6 ff ff       	call   1002a2 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c3c:	ff 45 f4             	incl   -0xc(%ebp)
  101c3f:	d1 65 f0             	shll   -0x10(%ebp)
  101c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c45:	83 f8 17             	cmp    $0x17,%eax
  101c48:	76 bb                	jbe    101c05 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4d:	8b 40 40             	mov    0x40(%eax),%eax
  101c50:	c1 e8 0c             	shr    $0xc,%eax
  101c53:	83 e0 03             	and    $0x3,%eax
  101c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5a:	c7 04 24 91 70 10 00 	movl   $0x107091,(%esp)
  101c61:	e8 3c e6 ff ff       	call   1002a2 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c66:	8b 45 08             	mov    0x8(%ebp),%eax
  101c69:	89 04 24             	mov    %eax,(%esp)
  101c6c:	e8 6c fe ff ff       	call   101add <trap_in_kernel>
  101c71:	85 c0                	test   %eax,%eax
  101c73:	75 2d                	jne    101ca2 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c75:	8b 45 08             	mov    0x8(%ebp),%eax
  101c78:	8b 40 44             	mov    0x44(%eax),%eax
  101c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7f:	c7 04 24 9a 70 10 00 	movl   $0x10709a,(%esp)
  101c86:	e8 17 e6 ff ff       	call   1002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c92:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c96:	c7 04 24 a9 70 10 00 	movl   $0x1070a9,(%esp)
  101c9d:	e8 00 e6 ff ff       	call   1002a2 <cprintf>
    }
}
  101ca2:	90                   	nop
  101ca3:	c9                   	leave  
  101ca4:	c3                   	ret    

00101ca5 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101ca5:	55                   	push   %ebp
  101ca6:	89 e5                	mov    %esp,%ebp
  101ca8:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cab:	8b 45 08             	mov    0x8(%ebp),%eax
  101cae:	8b 00                	mov    (%eax),%eax
  101cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb4:	c7 04 24 bc 70 10 00 	movl   $0x1070bc,(%esp)
  101cbb:	e8 e2 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc3:	8b 40 04             	mov    0x4(%eax),%eax
  101cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cca:	c7 04 24 cb 70 10 00 	movl   $0x1070cb,(%esp)
  101cd1:	e8 cc e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd9:	8b 40 08             	mov    0x8(%eax),%eax
  101cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce0:	c7 04 24 da 70 10 00 	movl   $0x1070da,(%esp)
  101ce7:	e8 b6 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101cec:	8b 45 08             	mov    0x8(%ebp),%eax
  101cef:	8b 40 0c             	mov    0xc(%eax),%eax
  101cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf6:	c7 04 24 e9 70 10 00 	movl   $0x1070e9,(%esp)
  101cfd:	e8 a0 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d02:	8b 45 08             	mov    0x8(%ebp),%eax
  101d05:	8b 40 10             	mov    0x10(%eax),%eax
  101d08:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0c:	c7 04 24 f8 70 10 00 	movl   $0x1070f8,(%esp)
  101d13:	e8 8a e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d18:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1b:	8b 40 14             	mov    0x14(%eax),%eax
  101d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d22:	c7 04 24 07 71 10 00 	movl   $0x107107,(%esp)
  101d29:	e8 74 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101d31:	8b 40 18             	mov    0x18(%eax),%eax
  101d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d38:	c7 04 24 16 71 10 00 	movl   $0x107116,(%esp)
  101d3f:	e8 5e e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d44:	8b 45 08             	mov    0x8(%ebp),%eax
  101d47:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d4e:	c7 04 24 25 71 10 00 	movl   $0x107125,(%esp)
  101d55:	e8 48 e5 ff ff       	call   1002a2 <cprintf>
}
  101d5a:	90                   	nop
  101d5b:	c9                   	leave  
  101d5c:	c3                   	ret    

00101d5d <trap_dispatch>:
}
*/

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d5d:	55                   	push   %ebp
  101d5e:	89 e5                	mov    %esp,%ebp
  101d60:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101d63:	8b 45 08             	mov    0x8(%ebp),%eax
  101d66:	8b 40 30             	mov    0x30(%eax),%eax
  101d69:	83 f8 2f             	cmp    $0x2f,%eax
  101d6c:	77 21                	ja     101d8f <trap_dispatch+0x32>
  101d6e:	83 f8 2e             	cmp    $0x2e,%eax
  101d71:	0f 83 77 02 00 00    	jae    101fee <trap_dispatch+0x291>
  101d77:	83 f8 21             	cmp    $0x21,%eax
  101d7a:	0f 84 95 00 00 00    	je     101e15 <trap_dispatch+0xb8>
  101d80:	83 f8 24             	cmp    $0x24,%eax
  101d83:	74 67                	je     101dec <trap_dispatch+0x8f>
  101d85:	83 f8 20             	cmp    $0x20,%eax
  101d88:	74 1c                	je     101da6 <trap_dispatch+0x49>
  101d8a:	e9 2a 02 00 00       	jmp    101fb9 <trap_dispatch+0x25c>
  101d8f:	83 f8 78             	cmp    $0x78,%eax
  101d92:	0f 84 8d 01 00 00    	je     101f25 <trap_dispatch+0x1c8>
  101d98:	83 f8 79             	cmp    $0x79,%eax
  101d9b:	0f 84 d7 01 00 00    	je     101f78 <trap_dispatch+0x21b>
  101da1:	e9 13 02 00 00       	jmp    101fb9 <trap_dispatch+0x25c>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks += 1;
  101da6:	a1 0c df 11 00       	mov    0x11df0c,%eax
  101dab:	40                   	inc    %eax
  101dac:	a3 0c df 11 00       	mov    %eax,0x11df0c
        if (!(ticks % TICK_NUM)) {
  101db1:	8b 0d 0c df 11 00    	mov    0x11df0c,%ecx
  101db7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101dbc:	89 c8                	mov    %ecx,%eax
  101dbe:	f7 e2                	mul    %edx
  101dc0:	c1 ea 05             	shr    $0x5,%edx
  101dc3:	89 d0                	mov    %edx,%eax
  101dc5:	c1 e0 02             	shl    $0x2,%eax
  101dc8:	01 d0                	add    %edx,%eax
  101dca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101dd1:	01 d0                	add    %edx,%eax
  101dd3:	c1 e0 02             	shl    $0x2,%eax
  101dd6:	29 c1                	sub    %eax,%ecx
  101dd8:	89 ca                	mov    %ecx,%edx
  101dda:	85 d2                	test   %edx,%edx
  101ddc:	0f 85 0f 02 00 00    	jne    101ff1 <trap_dispatch+0x294>
            print_ticks();
  101de2:	e8 bd fa ff ff       	call   1018a4 <print_ticks>
        }
        break;
  101de7:	e9 05 02 00 00       	jmp    101ff1 <trap_dispatch+0x294>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101dec:	e8 70 f8 ff ff       	call   101661 <cons_getc>
  101df1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101df4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101df8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dfc:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e04:	c7 04 24 34 71 10 00 	movl   $0x107134,(%esp)
  101e0b:	e8 92 e4 ff ff       	call   1002a2 <cprintf>
        break;
  101e10:	e9 e3 01 00 00       	jmp    101ff8 <trap_dispatch+0x29b>
    // LAB1 : Challenge 2
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101e15:	e8 47 f8 ff ff       	call   101661 <cons_getc>
  101e1a:	88 45 f7             	mov    %al,-0x9(%ebp)
        if (c == '3' && (tf->tf_cs & 3) != 3) {
  101e1d:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
  101e21:	75 6f                	jne    101e92 <trap_dispatch+0x135>
  101e23:	8b 45 08             	mov    0x8(%ebp),%eax
  101e26:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e2a:	83 e0 03             	and    $0x3,%eax
  101e2d:	83 f8 03             	cmp    $0x3,%eax
  101e30:	74 60                	je     101e92 <trap_dispatch+0x135>
            cprintf("[system] change to user [%03d] %c\n", c, c);
  101e32:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e36:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e3a:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e42:	c7 04 24 48 71 10 00 	movl   $0x107148,(%esp)
  101e49:	e8 54 e4 ff ff       	call   1002a2 <cprintf>
            tf->tf_cs = USER_CS;
  101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  101e51:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = USER_DS;
  101e57:	8b 45 08             	mov    0x8(%ebp),%eax
  101e5a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
  101e60:	8b 45 08             	mov    0x8(%ebp),%eax
  101e63:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
  101e69:	8b 45 08             	mov    0x8(%ebp),%eax
  101e6c:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
            tf->tf_eflags |= 0x3000;
  101e72:	8b 45 08             	mov    0x8(%ebp),%eax
  101e75:	8b 40 40             	mov    0x40(%eax),%eax
  101e78:	0d 00 30 00 00       	or     $0x3000,%eax
  101e7d:	89 c2                	mov    %eax,%edx
  101e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  101e82:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
  101e85:	8b 45 08             	mov    0x8(%ebp),%eax
  101e88:	89 04 24             	mov    %eax,(%esp)
  101e8b:	e8 62 fc ff ff       	call   101af2 <print_trapframe>
  101e90:	eb 72                	jmp    101f04 <trap_dispatch+0x1a7>
        }
        else if (c == '0' && (tf->tf_cs & 3) != 0) {
  101e92:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
  101e96:	75 6c                	jne    101f04 <trap_dispatch+0x1a7>
  101e98:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e9f:	83 e0 03             	and    $0x3,%eax
  101ea2:	85 c0                	test   %eax,%eax
  101ea4:	74 5e                	je     101f04 <trap_dispatch+0x1a7>
            cprintf("[system] change to kernel [%03d] %c\n", c, c);
  101ea6:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101eaa:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101eae:	89 54 24 08          	mov    %edx,0x8(%esp)
  101eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101eb6:	c7 04 24 6c 71 10 00 	movl   $0x10716c,(%esp)
  101ebd:	e8 e0 e3 ff ff       	call   1002a2 <cprintf>
            tf->tf_cs = KERNEL_CS;
  101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec5:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = KERNEL_DS;
  101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ece:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
  101ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ed7:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
            tf->tf_ss = KERNEL_DS;
  101edd:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee0:	66 c7 40 48 10 00    	movw   $0x10,0x48(%eax)
            tf->tf_eflags &= 0x0fff;
  101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee9:	8b 40 40             	mov    0x40(%eax),%eax
  101eec:	25 ff 0f 00 00       	and    $0xfff,%eax
  101ef1:	89 c2                	mov    %eax,%edx
  101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef6:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
  101ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  101efc:	89 04 24             	mov    %eax,(%esp)
  101eff:	e8 ee fb ff ff       	call   101af2 <print_trapframe>
        }
        cprintf("kbd [%03d] %c\n", c, c);
  101f04:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101f08:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101f0c:	89 54 24 08          	mov    %edx,0x8(%esp)
  101f10:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f14:	c7 04 24 91 71 10 00 	movl   $0x107191,(%esp)
  101f1b:	e8 82 e3 ff ff       	call   1002a2 <cprintf>
        break;
  101f20:	e9 d3 00 00 00       	jmp    101ff8 <trap_dispatch+0x29b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) 
  101f25:	8b 45 08             	mov    0x8(%ebp),%eax
  101f28:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f2c:	83 f8 1b             	cmp    $0x1b,%eax
  101f2f:	0f 84 bf 00 00 00    	je     101ff4 <trap_dispatch+0x297>
        {
            tf->tf_cs = USER_CS;
  101f35:	8b 45 08             	mov    0x8(%ebp),%eax
  101f38:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
  101f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f41:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
  101f47:	8b 45 08             	mov    0x8(%ebp),%eax
  101f4a:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f51:	66 89 50 28          	mov    %dx,0x28(%eax)
  101f55:	8b 45 08             	mov    0x8(%ebp),%eax
  101f58:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101f5f:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags |= FL_IOPL_MASK;
  101f63:	8b 45 08             	mov    0x8(%ebp),%eax
  101f66:	8b 40 40             	mov    0x40(%eax),%eax
  101f69:	0d 00 30 00 00       	or     $0x3000,%eax
  101f6e:	89 c2                	mov    %eax,%edx
  101f70:	8b 45 08             	mov    0x8(%ebp),%eax
  101f73:	89 50 40             	mov    %edx,0x40(%eax)
            // then iret will jump to the right stack

            //tf->tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
            //*((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
        }
        break;
  101f76:	eb 7c                	jmp    101ff4 <trap_dispatch+0x297>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) 
  101f78:	8b 45 08             	mov    0x8(%ebp),%eax
  101f7b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f7f:	83 f8 08             	cmp    $0x8,%eax
  101f82:	74 73                	je     101ff7 <trap_dispatch+0x29a>
        {
            tf->tf_cs = KERNEL_CS;
  101f84:	8b 45 08             	mov    0x8(%ebp),%eax
  101f87:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101f90:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101f96:	8b 45 08             	mov    0x8(%ebp),%eax
  101f99:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  101fa0:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  101fa7:	8b 40 40             	mov    0x40(%eax),%eax
  101faa:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101faf:	89 c2                	mov    %eax,%edx
  101fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  101fb4:	89 50 40             	mov    %edx,0x40(%eax)
            //switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
            //memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
            //*((uint32_t *)tf - 1) = (uint32_t)switchu2k;
        }
        break;
  101fb7:	eb 3e                	jmp    101ff7 <trap_dispatch+0x29a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  101fbc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101fc0:	83 e0 03             	and    $0x3,%eax
  101fc3:	85 c0                	test   %eax,%eax
  101fc5:	75 31                	jne    101ff8 <trap_dispatch+0x29b>
            print_trapframe(tf);
  101fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  101fca:	89 04 24             	mov    %eax,(%esp)
  101fcd:	e8 20 fb ff ff       	call   101af2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101fd2:	c7 44 24 08 a0 71 10 	movl   $0x1071a0,0x8(%esp)
  101fd9:	00 
  101fda:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  101fe1:	00 
  101fe2:	c7 04 24 bc 71 10 00 	movl   $0x1071bc,(%esp)
  101fe9:	e8 0b e4 ff ff       	call   1003f9 <__panic>
        break;
  101fee:	90                   	nop
  101fef:	eb 07                	jmp    101ff8 <trap_dispatch+0x29b>
        break;
  101ff1:	90                   	nop
  101ff2:	eb 04                	jmp    101ff8 <trap_dispatch+0x29b>
        break;
  101ff4:	90                   	nop
  101ff5:	eb 01                	jmp    101ff8 <trap_dispatch+0x29b>
        break;
  101ff7:	90                   	nop
        }
    }
}
  101ff8:	90                   	nop
  101ff9:	c9                   	leave  
  101ffa:	c3                   	ret    

00101ffb <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101ffb:	55                   	push   %ebp
  101ffc:	89 e5                	mov    %esp,%ebp
  101ffe:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  102001:	8b 45 08             	mov    0x8(%ebp),%eax
  102004:	89 04 24             	mov    %eax,(%esp)
  102007:	e8 51 fd ff ff       	call   101d5d <trap_dispatch>
}
  10200c:	90                   	nop
  10200d:	c9                   	leave  
  10200e:	c3                   	ret    

0010200f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  10200f:	6a 00                	push   $0x0
  pushl $0
  102011:	6a 00                	push   $0x0
  jmp __alltraps
  102013:	e9 69 0a 00 00       	jmp    102a81 <__alltraps>

00102018 <vector1>:
.globl vector1
vector1:
  pushl $0
  102018:	6a 00                	push   $0x0
  pushl $1
  10201a:	6a 01                	push   $0x1
  jmp __alltraps
  10201c:	e9 60 0a 00 00       	jmp    102a81 <__alltraps>

00102021 <vector2>:
.globl vector2
vector2:
  pushl $0
  102021:	6a 00                	push   $0x0
  pushl $2
  102023:	6a 02                	push   $0x2
  jmp __alltraps
  102025:	e9 57 0a 00 00       	jmp    102a81 <__alltraps>

0010202a <vector3>:
.globl vector3
vector3:
  pushl $0
  10202a:	6a 00                	push   $0x0
  pushl $3
  10202c:	6a 03                	push   $0x3
  jmp __alltraps
  10202e:	e9 4e 0a 00 00       	jmp    102a81 <__alltraps>

00102033 <vector4>:
.globl vector4
vector4:
  pushl $0
  102033:	6a 00                	push   $0x0
  pushl $4
  102035:	6a 04                	push   $0x4
  jmp __alltraps
  102037:	e9 45 0a 00 00       	jmp    102a81 <__alltraps>

0010203c <vector5>:
.globl vector5
vector5:
  pushl $0
  10203c:	6a 00                	push   $0x0
  pushl $5
  10203e:	6a 05                	push   $0x5
  jmp __alltraps
  102040:	e9 3c 0a 00 00       	jmp    102a81 <__alltraps>

00102045 <vector6>:
.globl vector6
vector6:
  pushl $0
  102045:	6a 00                	push   $0x0
  pushl $6
  102047:	6a 06                	push   $0x6
  jmp __alltraps
  102049:	e9 33 0a 00 00       	jmp    102a81 <__alltraps>

0010204e <vector7>:
.globl vector7
vector7:
  pushl $0
  10204e:	6a 00                	push   $0x0
  pushl $7
  102050:	6a 07                	push   $0x7
  jmp __alltraps
  102052:	e9 2a 0a 00 00       	jmp    102a81 <__alltraps>

00102057 <vector8>:
.globl vector8
vector8:
  pushl $8
  102057:	6a 08                	push   $0x8
  jmp __alltraps
  102059:	e9 23 0a 00 00       	jmp    102a81 <__alltraps>

0010205e <vector9>:
.globl vector9
vector9:
  pushl $0
  10205e:	6a 00                	push   $0x0
  pushl $9
  102060:	6a 09                	push   $0x9
  jmp __alltraps
  102062:	e9 1a 0a 00 00       	jmp    102a81 <__alltraps>

00102067 <vector10>:
.globl vector10
vector10:
  pushl $10
  102067:	6a 0a                	push   $0xa
  jmp __alltraps
  102069:	e9 13 0a 00 00       	jmp    102a81 <__alltraps>

0010206e <vector11>:
.globl vector11
vector11:
  pushl $11
  10206e:	6a 0b                	push   $0xb
  jmp __alltraps
  102070:	e9 0c 0a 00 00       	jmp    102a81 <__alltraps>

00102075 <vector12>:
.globl vector12
vector12:
  pushl $12
  102075:	6a 0c                	push   $0xc
  jmp __alltraps
  102077:	e9 05 0a 00 00       	jmp    102a81 <__alltraps>

0010207c <vector13>:
.globl vector13
vector13:
  pushl $13
  10207c:	6a 0d                	push   $0xd
  jmp __alltraps
  10207e:	e9 fe 09 00 00       	jmp    102a81 <__alltraps>

00102083 <vector14>:
.globl vector14
vector14:
  pushl $14
  102083:	6a 0e                	push   $0xe
  jmp __alltraps
  102085:	e9 f7 09 00 00       	jmp    102a81 <__alltraps>

0010208a <vector15>:
.globl vector15
vector15:
  pushl $0
  10208a:	6a 00                	push   $0x0
  pushl $15
  10208c:	6a 0f                	push   $0xf
  jmp __alltraps
  10208e:	e9 ee 09 00 00       	jmp    102a81 <__alltraps>

00102093 <vector16>:
.globl vector16
vector16:
  pushl $0
  102093:	6a 00                	push   $0x0
  pushl $16
  102095:	6a 10                	push   $0x10
  jmp __alltraps
  102097:	e9 e5 09 00 00       	jmp    102a81 <__alltraps>

0010209c <vector17>:
.globl vector17
vector17:
  pushl $17
  10209c:	6a 11                	push   $0x11
  jmp __alltraps
  10209e:	e9 de 09 00 00       	jmp    102a81 <__alltraps>

001020a3 <vector18>:
.globl vector18
vector18:
  pushl $0
  1020a3:	6a 00                	push   $0x0
  pushl $18
  1020a5:	6a 12                	push   $0x12
  jmp __alltraps
  1020a7:	e9 d5 09 00 00       	jmp    102a81 <__alltraps>

001020ac <vector19>:
.globl vector19
vector19:
  pushl $0
  1020ac:	6a 00                	push   $0x0
  pushl $19
  1020ae:	6a 13                	push   $0x13
  jmp __alltraps
  1020b0:	e9 cc 09 00 00       	jmp    102a81 <__alltraps>

001020b5 <vector20>:
.globl vector20
vector20:
  pushl $0
  1020b5:	6a 00                	push   $0x0
  pushl $20
  1020b7:	6a 14                	push   $0x14
  jmp __alltraps
  1020b9:	e9 c3 09 00 00       	jmp    102a81 <__alltraps>

001020be <vector21>:
.globl vector21
vector21:
  pushl $0
  1020be:	6a 00                	push   $0x0
  pushl $21
  1020c0:	6a 15                	push   $0x15
  jmp __alltraps
  1020c2:	e9 ba 09 00 00       	jmp    102a81 <__alltraps>

001020c7 <vector22>:
.globl vector22
vector22:
  pushl $0
  1020c7:	6a 00                	push   $0x0
  pushl $22
  1020c9:	6a 16                	push   $0x16
  jmp __alltraps
  1020cb:	e9 b1 09 00 00       	jmp    102a81 <__alltraps>

001020d0 <vector23>:
.globl vector23
vector23:
  pushl $0
  1020d0:	6a 00                	push   $0x0
  pushl $23
  1020d2:	6a 17                	push   $0x17
  jmp __alltraps
  1020d4:	e9 a8 09 00 00       	jmp    102a81 <__alltraps>

001020d9 <vector24>:
.globl vector24
vector24:
  pushl $0
  1020d9:	6a 00                	push   $0x0
  pushl $24
  1020db:	6a 18                	push   $0x18
  jmp __alltraps
  1020dd:	e9 9f 09 00 00       	jmp    102a81 <__alltraps>

001020e2 <vector25>:
.globl vector25
vector25:
  pushl $0
  1020e2:	6a 00                	push   $0x0
  pushl $25
  1020e4:	6a 19                	push   $0x19
  jmp __alltraps
  1020e6:	e9 96 09 00 00       	jmp    102a81 <__alltraps>

001020eb <vector26>:
.globl vector26
vector26:
  pushl $0
  1020eb:	6a 00                	push   $0x0
  pushl $26
  1020ed:	6a 1a                	push   $0x1a
  jmp __alltraps
  1020ef:	e9 8d 09 00 00       	jmp    102a81 <__alltraps>

001020f4 <vector27>:
.globl vector27
vector27:
  pushl $0
  1020f4:	6a 00                	push   $0x0
  pushl $27
  1020f6:	6a 1b                	push   $0x1b
  jmp __alltraps
  1020f8:	e9 84 09 00 00       	jmp    102a81 <__alltraps>

001020fd <vector28>:
.globl vector28
vector28:
  pushl $0
  1020fd:	6a 00                	push   $0x0
  pushl $28
  1020ff:	6a 1c                	push   $0x1c
  jmp __alltraps
  102101:	e9 7b 09 00 00       	jmp    102a81 <__alltraps>

00102106 <vector29>:
.globl vector29
vector29:
  pushl $0
  102106:	6a 00                	push   $0x0
  pushl $29
  102108:	6a 1d                	push   $0x1d
  jmp __alltraps
  10210a:	e9 72 09 00 00       	jmp    102a81 <__alltraps>

0010210f <vector30>:
.globl vector30
vector30:
  pushl $0
  10210f:	6a 00                	push   $0x0
  pushl $30
  102111:	6a 1e                	push   $0x1e
  jmp __alltraps
  102113:	e9 69 09 00 00       	jmp    102a81 <__alltraps>

00102118 <vector31>:
.globl vector31
vector31:
  pushl $0
  102118:	6a 00                	push   $0x0
  pushl $31
  10211a:	6a 1f                	push   $0x1f
  jmp __alltraps
  10211c:	e9 60 09 00 00       	jmp    102a81 <__alltraps>

00102121 <vector32>:
.globl vector32
vector32:
  pushl $0
  102121:	6a 00                	push   $0x0
  pushl $32
  102123:	6a 20                	push   $0x20
  jmp __alltraps
  102125:	e9 57 09 00 00       	jmp    102a81 <__alltraps>

0010212a <vector33>:
.globl vector33
vector33:
  pushl $0
  10212a:	6a 00                	push   $0x0
  pushl $33
  10212c:	6a 21                	push   $0x21
  jmp __alltraps
  10212e:	e9 4e 09 00 00       	jmp    102a81 <__alltraps>

00102133 <vector34>:
.globl vector34
vector34:
  pushl $0
  102133:	6a 00                	push   $0x0
  pushl $34
  102135:	6a 22                	push   $0x22
  jmp __alltraps
  102137:	e9 45 09 00 00       	jmp    102a81 <__alltraps>

0010213c <vector35>:
.globl vector35
vector35:
  pushl $0
  10213c:	6a 00                	push   $0x0
  pushl $35
  10213e:	6a 23                	push   $0x23
  jmp __alltraps
  102140:	e9 3c 09 00 00       	jmp    102a81 <__alltraps>

00102145 <vector36>:
.globl vector36
vector36:
  pushl $0
  102145:	6a 00                	push   $0x0
  pushl $36
  102147:	6a 24                	push   $0x24
  jmp __alltraps
  102149:	e9 33 09 00 00       	jmp    102a81 <__alltraps>

0010214e <vector37>:
.globl vector37
vector37:
  pushl $0
  10214e:	6a 00                	push   $0x0
  pushl $37
  102150:	6a 25                	push   $0x25
  jmp __alltraps
  102152:	e9 2a 09 00 00       	jmp    102a81 <__alltraps>

00102157 <vector38>:
.globl vector38
vector38:
  pushl $0
  102157:	6a 00                	push   $0x0
  pushl $38
  102159:	6a 26                	push   $0x26
  jmp __alltraps
  10215b:	e9 21 09 00 00       	jmp    102a81 <__alltraps>

00102160 <vector39>:
.globl vector39
vector39:
  pushl $0
  102160:	6a 00                	push   $0x0
  pushl $39
  102162:	6a 27                	push   $0x27
  jmp __alltraps
  102164:	e9 18 09 00 00       	jmp    102a81 <__alltraps>

00102169 <vector40>:
.globl vector40
vector40:
  pushl $0
  102169:	6a 00                	push   $0x0
  pushl $40
  10216b:	6a 28                	push   $0x28
  jmp __alltraps
  10216d:	e9 0f 09 00 00       	jmp    102a81 <__alltraps>

00102172 <vector41>:
.globl vector41
vector41:
  pushl $0
  102172:	6a 00                	push   $0x0
  pushl $41
  102174:	6a 29                	push   $0x29
  jmp __alltraps
  102176:	e9 06 09 00 00       	jmp    102a81 <__alltraps>

0010217b <vector42>:
.globl vector42
vector42:
  pushl $0
  10217b:	6a 00                	push   $0x0
  pushl $42
  10217d:	6a 2a                	push   $0x2a
  jmp __alltraps
  10217f:	e9 fd 08 00 00       	jmp    102a81 <__alltraps>

00102184 <vector43>:
.globl vector43
vector43:
  pushl $0
  102184:	6a 00                	push   $0x0
  pushl $43
  102186:	6a 2b                	push   $0x2b
  jmp __alltraps
  102188:	e9 f4 08 00 00       	jmp    102a81 <__alltraps>

0010218d <vector44>:
.globl vector44
vector44:
  pushl $0
  10218d:	6a 00                	push   $0x0
  pushl $44
  10218f:	6a 2c                	push   $0x2c
  jmp __alltraps
  102191:	e9 eb 08 00 00       	jmp    102a81 <__alltraps>

00102196 <vector45>:
.globl vector45
vector45:
  pushl $0
  102196:	6a 00                	push   $0x0
  pushl $45
  102198:	6a 2d                	push   $0x2d
  jmp __alltraps
  10219a:	e9 e2 08 00 00       	jmp    102a81 <__alltraps>

0010219f <vector46>:
.globl vector46
vector46:
  pushl $0
  10219f:	6a 00                	push   $0x0
  pushl $46
  1021a1:	6a 2e                	push   $0x2e
  jmp __alltraps
  1021a3:	e9 d9 08 00 00       	jmp    102a81 <__alltraps>

001021a8 <vector47>:
.globl vector47
vector47:
  pushl $0
  1021a8:	6a 00                	push   $0x0
  pushl $47
  1021aa:	6a 2f                	push   $0x2f
  jmp __alltraps
  1021ac:	e9 d0 08 00 00       	jmp    102a81 <__alltraps>

001021b1 <vector48>:
.globl vector48
vector48:
  pushl $0
  1021b1:	6a 00                	push   $0x0
  pushl $48
  1021b3:	6a 30                	push   $0x30
  jmp __alltraps
  1021b5:	e9 c7 08 00 00       	jmp    102a81 <__alltraps>

001021ba <vector49>:
.globl vector49
vector49:
  pushl $0
  1021ba:	6a 00                	push   $0x0
  pushl $49
  1021bc:	6a 31                	push   $0x31
  jmp __alltraps
  1021be:	e9 be 08 00 00       	jmp    102a81 <__alltraps>

001021c3 <vector50>:
.globl vector50
vector50:
  pushl $0
  1021c3:	6a 00                	push   $0x0
  pushl $50
  1021c5:	6a 32                	push   $0x32
  jmp __alltraps
  1021c7:	e9 b5 08 00 00       	jmp    102a81 <__alltraps>

001021cc <vector51>:
.globl vector51
vector51:
  pushl $0
  1021cc:	6a 00                	push   $0x0
  pushl $51
  1021ce:	6a 33                	push   $0x33
  jmp __alltraps
  1021d0:	e9 ac 08 00 00       	jmp    102a81 <__alltraps>

001021d5 <vector52>:
.globl vector52
vector52:
  pushl $0
  1021d5:	6a 00                	push   $0x0
  pushl $52
  1021d7:	6a 34                	push   $0x34
  jmp __alltraps
  1021d9:	e9 a3 08 00 00       	jmp    102a81 <__alltraps>

001021de <vector53>:
.globl vector53
vector53:
  pushl $0
  1021de:	6a 00                	push   $0x0
  pushl $53
  1021e0:	6a 35                	push   $0x35
  jmp __alltraps
  1021e2:	e9 9a 08 00 00       	jmp    102a81 <__alltraps>

001021e7 <vector54>:
.globl vector54
vector54:
  pushl $0
  1021e7:	6a 00                	push   $0x0
  pushl $54
  1021e9:	6a 36                	push   $0x36
  jmp __alltraps
  1021eb:	e9 91 08 00 00       	jmp    102a81 <__alltraps>

001021f0 <vector55>:
.globl vector55
vector55:
  pushl $0
  1021f0:	6a 00                	push   $0x0
  pushl $55
  1021f2:	6a 37                	push   $0x37
  jmp __alltraps
  1021f4:	e9 88 08 00 00       	jmp    102a81 <__alltraps>

001021f9 <vector56>:
.globl vector56
vector56:
  pushl $0
  1021f9:	6a 00                	push   $0x0
  pushl $56
  1021fb:	6a 38                	push   $0x38
  jmp __alltraps
  1021fd:	e9 7f 08 00 00       	jmp    102a81 <__alltraps>

00102202 <vector57>:
.globl vector57
vector57:
  pushl $0
  102202:	6a 00                	push   $0x0
  pushl $57
  102204:	6a 39                	push   $0x39
  jmp __alltraps
  102206:	e9 76 08 00 00       	jmp    102a81 <__alltraps>

0010220b <vector58>:
.globl vector58
vector58:
  pushl $0
  10220b:	6a 00                	push   $0x0
  pushl $58
  10220d:	6a 3a                	push   $0x3a
  jmp __alltraps
  10220f:	e9 6d 08 00 00       	jmp    102a81 <__alltraps>

00102214 <vector59>:
.globl vector59
vector59:
  pushl $0
  102214:	6a 00                	push   $0x0
  pushl $59
  102216:	6a 3b                	push   $0x3b
  jmp __alltraps
  102218:	e9 64 08 00 00       	jmp    102a81 <__alltraps>

0010221d <vector60>:
.globl vector60
vector60:
  pushl $0
  10221d:	6a 00                	push   $0x0
  pushl $60
  10221f:	6a 3c                	push   $0x3c
  jmp __alltraps
  102221:	e9 5b 08 00 00       	jmp    102a81 <__alltraps>

00102226 <vector61>:
.globl vector61
vector61:
  pushl $0
  102226:	6a 00                	push   $0x0
  pushl $61
  102228:	6a 3d                	push   $0x3d
  jmp __alltraps
  10222a:	e9 52 08 00 00       	jmp    102a81 <__alltraps>

0010222f <vector62>:
.globl vector62
vector62:
  pushl $0
  10222f:	6a 00                	push   $0x0
  pushl $62
  102231:	6a 3e                	push   $0x3e
  jmp __alltraps
  102233:	e9 49 08 00 00       	jmp    102a81 <__alltraps>

00102238 <vector63>:
.globl vector63
vector63:
  pushl $0
  102238:	6a 00                	push   $0x0
  pushl $63
  10223a:	6a 3f                	push   $0x3f
  jmp __alltraps
  10223c:	e9 40 08 00 00       	jmp    102a81 <__alltraps>

00102241 <vector64>:
.globl vector64
vector64:
  pushl $0
  102241:	6a 00                	push   $0x0
  pushl $64
  102243:	6a 40                	push   $0x40
  jmp __alltraps
  102245:	e9 37 08 00 00       	jmp    102a81 <__alltraps>

0010224a <vector65>:
.globl vector65
vector65:
  pushl $0
  10224a:	6a 00                	push   $0x0
  pushl $65
  10224c:	6a 41                	push   $0x41
  jmp __alltraps
  10224e:	e9 2e 08 00 00       	jmp    102a81 <__alltraps>

00102253 <vector66>:
.globl vector66
vector66:
  pushl $0
  102253:	6a 00                	push   $0x0
  pushl $66
  102255:	6a 42                	push   $0x42
  jmp __alltraps
  102257:	e9 25 08 00 00       	jmp    102a81 <__alltraps>

0010225c <vector67>:
.globl vector67
vector67:
  pushl $0
  10225c:	6a 00                	push   $0x0
  pushl $67
  10225e:	6a 43                	push   $0x43
  jmp __alltraps
  102260:	e9 1c 08 00 00       	jmp    102a81 <__alltraps>

00102265 <vector68>:
.globl vector68
vector68:
  pushl $0
  102265:	6a 00                	push   $0x0
  pushl $68
  102267:	6a 44                	push   $0x44
  jmp __alltraps
  102269:	e9 13 08 00 00       	jmp    102a81 <__alltraps>

0010226e <vector69>:
.globl vector69
vector69:
  pushl $0
  10226e:	6a 00                	push   $0x0
  pushl $69
  102270:	6a 45                	push   $0x45
  jmp __alltraps
  102272:	e9 0a 08 00 00       	jmp    102a81 <__alltraps>

00102277 <vector70>:
.globl vector70
vector70:
  pushl $0
  102277:	6a 00                	push   $0x0
  pushl $70
  102279:	6a 46                	push   $0x46
  jmp __alltraps
  10227b:	e9 01 08 00 00       	jmp    102a81 <__alltraps>

00102280 <vector71>:
.globl vector71
vector71:
  pushl $0
  102280:	6a 00                	push   $0x0
  pushl $71
  102282:	6a 47                	push   $0x47
  jmp __alltraps
  102284:	e9 f8 07 00 00       	jmp    102a81 <__alltraps>

00102289 <vector72>:
.globl vector72
vector72:
  pushl $0
  102289:	6a 00                	push   $0x0
  pushl $72
  10228b:	6a 48                	push   $0x48
  jmp __alltraps
  10228d:	e9 ef 07 00 00       	jmp    102a81 <__alltraps>

00102292 <vector73>:
.globl vector73
vector73:
  pushl $0
  102292:	6a 00                	push   $0x0
  pushl $73
  102294:	6a 49                	push   $0x49
  jmp __alltraps
  102296:	e9 e6 07 00 00       	jmp    102a81 <__alltraps>

0010229b <vector74>:
.globl vector74
vector74:
  pushl $0
  10229b:	6a 00                	push   $0x0
  pushl $74
  10229d:	6a 4a                	push   $0x4a
  jmp __alltraps
  10229f:	e9 dd 07 00 00       	jmp    102a81 <__alltraps>

001022a4 <vector75>:
.globl vector75
vector75:
  pushl $0
  1022a4:	6a 00                	push   $0x0
  pushl $75
  1022a6:	6a 4b                	push   $0x4b
  jmp __alltraps
  1022a8:	e9 d4 07 00 00       	jmp    102a81 <__alltraps>

001022ad <vector76>:
.globl vector76
vector76:
  pushl $0
  1022ad:	6a 00                	push   $0x0
  pushl $76
  1022af:	6a 4c                	push   $0x4c
  jmp __alltraps
  1022b1:	e9 cb 07 00 00       	jmp    102a81 <__alltraps>

001022b6 <vector77>:
.globl vector77
vector77:
  pushl $0
  1022b6:	6a 00                	push   $0x0
  pushl $77
  1022b8:	6a 4d                	push   $0x4d
  jmp __alltraps
  1022ba:	e9 c2 07 00 00       	jmp    102a81 <__alltraps>

001022bf <vector78>:
.globl vector78
vector78:
  pushl $0
  1022bf:	6a 00                	push   $0x0
  pushl $78
  1022c1:	6a 4e                	push   $0x4e
  jmp __alltraps
  1022c3:	e9 b9 07 00 00       	jmp    102a81 <__alltraps>

001022c8 <vector79>:
.globl vector79
vector79:
  pushl $0
  1022c8:	6a 00                	push   $0x0
  pushl $79
  1022ca:	6a 4f                	push   $0x4f
  jmp __alltraps
  1022cc:	e9 b0 07 00 00       	jmp    102a81 <__alltraps>

001022d1 <vector80>:
.globl vector80
vector80:
  pushl $0
  1022d1:	6a 00                	push   $0x0
  pushl $80
  1022d3:	6a 50                	push   $0x50
  jmp __alltraps
  1022d5:	e9 a7 07 00 00       	jmp    102a81 <__alltraps>

001022da <vector81>:
.globl vector81
vector81:
  pushl $0
  1022da:	6a 00                	push   $0x0
  pushl $81
  1022dc:	6a 51                	push   $0x51
  jmp __alltraps
  1022de:	e9 9e 07 00 00       	jmp    102a81 <__alltraps>

001022e3 <vector82>:
.globl vector82
vector82:
  pushl $0
  1022e3:	6a 00                	push   $0x0
  pushl $82
  1022e5:	6a 52                	push   $0x52
  jmp __alltraps
  1022e7:	e9 95 07 00 00       	jmp    102a81 <__alltraps>

001022ec <vector83>:
.globl vector83
vector83:
  pushl $0
  1022ec:	6a 00                	push   $0x0
  pushl $83
  1022ee:	6a 53                	push   $0x53
  jmp __alltraps
  1022f0:	e9 8c 07 00 00       	jmp    102a81 <__alltraps>

001022f5 <vector84>:
.globl vector84
vector84:
  pushl $0
  1022f5:	6a 00                	push   $0x0
  pushl $84
  1022f7:	6a 54                	push   $0x54
  jmp __alltraps
  1022f9:	e9 83 07 00 00       	jmp    102a81 <__alltraps>

001022fe <vector85>:
.globl vector85
vector85:
  pushl $0
  1022fe:	6a 00                	push   $0x0
  pushl $85
  102300:	6a 55                	push   $0x55
  jmp __alltraps
  102302:	e9 7a 07 00 00       	jmp    102a81 <__alltraps>

00102307 <vector86>:
.globl vector86
vector86:
  pushl $0
  102307:	6a 00                	push   $0x0
  pushl $86
  102309:	6a 56                	push   $0x56
  jmp __alltraps
  10230b:	e9 71 07 00 00       	jmp    102a81 <__alltraps>

00102310 <vector87>:
.globl vector87
vector87:
  pushl $0
  102310:	6a 00                	push   $0x0
  pushl $87
  102312:	6a 57                	push   $0x57
  jmp __alltraps
  102314:	e9 68 07 00 00       	jmp    102a81 <__alltraps>

00102319 <vector88>:
.globl vector88
vector88:
  pushl $0
  102319:	6a 00                	push   $0x0
  pushl $88
  10231b:	6a 58                	push   $0x58
  jmp __alltraps
  10231d:	e9 5f 07 00 00       	jmp    102a81 <__alltraps>

00102322 <vector89>:
.globl vector89
vector89:
  pushl $0
  102322:	6a 00                	push   $0x0
  pushl $89
  102324:	6a 59                	push   $0x59
  jmp __alltraps
  102326:	e9 56 07 00 00       	jmp    102a81 <__alltraps>

0010232b <vector90>:
.globl vector90
vector90:
  pushl $0
  10232b:	6a 00                	push   $0x0
  pushl $90
  10232d:	6a 5a                	push   $0x5a
  jmp __alltraps
  10232f:	e9 4d 07 00 00       	jmp    102a81 <__alltraps>

00102334 <vector91>:
.globl vector91
vector91:
  pushl $0
  102334:	6a 00                	push   $0x0
  pushl $91
  102336:	6a 5b                	push   $0x5b
  jmp __alltraps
  102338:	e9 44 07 00 00       	jmp    102a81 <__alltraps>

0010233d <vector92>:
.globl vector92
vector92:
  pushl $0
  10233d:	6a 00                	push   $0x0
  pushl $92
  10233f:	6a 5c                	push   $0x5c
  jmp __alltraps
  102341:	e9 3b 07 00 00       	jmp    102a81 <__alltraps>

00102346 <vector93>:
.globl vector93
vector93:
  pushl $0
  102346:	6a 00                	push   $0x0
  pushl $93
  102348:	6a 5d                	push   $0x5d
  jmp __alltraps
  10234a:	e9 32 07 00 00       	jmp    102a81 <__alltraps>

0010234f <vector94>:
.globl vector94
vector94:
  pushl $0
  10234f:	6a 00                	push   $0x0
  pushl $94
  102351:	6a 5e                	push   $0x5e
  jmp __alltraps
  102353:	e9 29 07 00 00       	jmp    102a81 <__alltraps>

00102358 <vector95>:
.globl vector95
vector95:
  pushl $0
  102358:	6a 00                	push   $0x0
  pushl $95
  10235a:	6a 5f                	push   $0x5f
  jmp __alltraps
  10235c:	e9 20 07 00 00       	jmp    102a81 <__alltraps>

00102361 <vector96>:
.globl vector96
vector96:
  pushl $0
  102361:	6a 00                	push   $0x0
  pushl $96
  102363:	6a 60                	push   $0x60
  jmp __alltraps
  102365:	e9 17 07 00 00       	jmp    102a81 <__alltraps>

0010236a <vector97>:
.globl vector97
vector97:
  pushl $0
  10236a:	6a 00                	push   $0x0
  pushl $97
  10236c:	6a 61                	push   $0x61
  jmp __alltraps
  10236e:	e9 0e 07 00 00       	jmp    102a81 <__alltraps>

00102373 <vector98>:
.globl vector98
vector98:
  pushl $0
  102373:	6a 00                	push   $0x0
  pushl $98
  102375:	6a 62                	push   $0x62
  jmp __alltraps
  102377:	e9 05 07 00 00       	jmp    102a81 <__alltraps>

0010237c <vector99>:
.globl vector99
vector99:
  pushl $0
  10237c:	6a 00                	push   $0x0
  pushl $99
  10237e:	6a 63                	push   $0x63
  jmp __alltraps
  102380:	e9 fc 06 00 00       	jmp    102a81 <__alltraps>

00102385 <vector100>:
.globl vector100
vector100:
  pushl $0
  102385:	6a 00                	push   $0x0
  pushl $100
  102387:	6a 64                	push   $0x64
  jmp __alltraps
  102389:	e9 f3 06 00 00       	jmp    102a81 <__alltraps>

0010238e <vector101>:
.globl vector101
vector101:
  pushl $0
  10238e:	6a 00                	push   $0x0
  pushl $101
  102390:	6a 65                	push   $0x65
  jmp __alltraps
  102392:	e9 ea 06 00 00       	jmp    102a81 <__alltraps>

00102397 <vector102>:
.globl vector102
vector102:
  pushl $0
  102397:	6a 00                	push   $0x0
  pushl $102
  102399:	6a 66                	push   $0x66
  jmp __alltraps
  10239b:	e9 e1 06 00 00       	jmp    102a81 <__alltraps>

001023a0 <vector103>:
.globl vector103
vector103:
  pushl $0
  1023a0:	6a 00                	push   $0x0
  pushl $103
  1023a2:	6a 67                	push   $0x67
  jmp __alltraps
  1023a4:	e9 d8 06 00 00       	jmp    102a81 <__alltraps>

001023a9 <vector104>:
.globl vector104
vector104:
  pushl $0
  1023a9:	6a 00                	push   $0x0
  pushl $104
  1023ab:	6a 68                	push   $0x68
  jmp __alltraps
  1023ad:	e9 cf 06 00 00       	jmp    102a81 <__alltraps>

001023b2 <vector105>:
.globl vector105
vector105:
  pushl $0
  1023b2:	6a 00                	push   $0x0
  pushl $105
  1023b4:	6a 69                	push   $0x69
  jmp __alltraps
  1023b6:	e9 c6 06 00 00       	jmp    102a81 <__alltraps>

001023bb <vector106>:
.globl vector106
vector106:
  pushl $0
  1023bb:	6a 00                	push   $0x0
  pushl $106
  1023bd:	6a 6a                	push   $0x6a
  jmp __alltraps
  1023bf:	e9 bd 06 00 00       	jmp    102a81 <__alltraps>

001023c4 <vector107>:
.globl vector107
vector107:
  pushl $0
  1023c4:	6a 00                	push   $0x0
  pushl $107
  1023c6:	6a 6b                	push   $0x6b
  jmp __alltraps
  1023c8:	e9 b4 06 00 00       	jmp    102a81 <__alltraps>

001023cd <vector108>:
.globl vector108
vector108:
  pushl $0
  1023cd:	6a 00                	push   $0x0
  pushl $108
  1023cf:	6a 6c                	push   $0x6c
  jmp __alltraps
  1023d1:	e9 ab 06 00 00       	jmp    102a81 <__alltraps>

001023d6 <vector109>:
.globl vector109
vector109:
  pushl $0
  1023d6:	6a 00                	push   $0x0
  pushl $109
  1023d8:	6a 6d                	push   $0x6d
  jmp __alltraps
  1023da:	e9 a2 06 00 00       	jmp    102a81 <__alltraps>

001023df <vector110>:
.globl vector110
vector110:
  pushl $0
  1023df:	6a 00                	push   $0x0
  pushl $110
  1023e1:	6a 6e                	push   $0x6e
  jmp __alltraps
  1023e3:	e9 99 06 00 00       	jmp    102a81 <__alltraps>

001023e8 <vector111>:
.globl vector111
vector111:
  pushl $0
  1023e8:	6a 00                	push   $0x0
  pushl $111
  1023ea:	6a 6f                	push   $0x6f
  jmp __alltraps
  1023ec:	e9 90 06 00 00       	jmp    102a81 <__alltraps>

001023f1 <vector112>:
.globl vector112
vector112:
  pushl $0
  1023f1:	6a 00                	push   $0x0
  pushl $112
  1023f3:	6a 70                	push   $0x70
  jmp __alltraps
  1023f5:	e9 87 06 00 00       	jmp    102a81 <__alltraps>

001023fa <vector113>:
.globl vector113
vector113:
  pushl $0
  1023fa:	6a 00                	push   $0x0
  pushl $113
  1023fc:	6a 71                	push   $0x71
  jmp __alltraps
  1023fe:	e9 7e 06 00 00       	jmp    102a81 <__alltraps>

00102403 <vector114>:
.globl vector114
vector114:
  pushl $0
  102403:	6a 00                	push   $0x0
  pushl $114
  102405:	6a 72                	push   $0x72
  jmp __alltraps
  102407:	e9 75 06 00 00       	jmp    102a81 <__alltraps>

0010240c <vector115>:
.globl vector115
vector115:
  pushl $0
  10240c:	6a 00                	push   $0x0
  pushl $115
  10240e:	6a 73                	push   $0x73
  jmp __alltraps
  102410:	e9 6c 06 00 00       	jmp    102a81 <__alltraps>

00102415 <vector116>:
.globl vector116
vector116:
  pushl $0
  102415:	6a 00                	push   $0x0
  pushl $116
  102417:	6a 74                	push   $0x74
  jmp __alltraps
  102419:	e9 63 06 00 00       	jmp    102a81 <__alltraps>

0010241e <vector117>:
.globl vector117
vector117:
  pushl $0
  10241e:	6a 00                	push   $0x0
  pushl $117
  102420:	6a 75                	push   $0x75
  jmp __alltraps
  102422:	e9 5a 06 00 00       	jmp    102a81 <__alltraps>

00102427 <vector118>:
.globl vector118
vector118:
  pushl $0
  102427:	6a 00                	push   $0x0
  pushl $118
  102429:	6a 76                	push   $0x76
  jmp __alltraps
  10242b:	e9 51 06 00 00       	jmp    102a81 <__alltraps>

00102430 <vector119>:
.globl vector119
vector119:
  pushl $0
  102430:	6a 00                	push   $0x0
  pushl $119
  102432:	6a 77                	push   $0x77
  jmp __alltraps
  102434:	e9 48 06 00 00       	jmp    102a81 <__alltraps>

00102439 <vector120>:
.globl vector120
vector120:
  pushl $0
  102439:	6a 00                	push   $0x0
  pushl $120
  10243b:	6a 78                	push   $0x78
  jmp __alltraps
  10243d:	e9 3f 06 00 00       	jmp    102a81 <__alltraps>

00102442 <vector121>:
.globl vector121
vector121:
  pushl $0
  102442:	6a 00                	push   $0x0
  pushl $121
  102444:	6a 79                	push   $0x79
  jmp __alltraps
  102446:	e9 36 06 00 00       	jmp    102a81 <__alltraps>

0010244b <vector122>:
.globl vector122
vector122:
  pushl $0
  10244b:	6a 00                	push   $0x0
  pushl $122
  10244d:	6a 7a                	push   $0x7a
  jmp __alltraps
  10244f:	e9 2d 06 00 00       	jmp    102a81 <__alltraps>

00102454 <vector123>:
.globl vector123
vector123:
  pushl $0
  102454:	6a 00                	push   $0x0
  pushl $123
  102456:	6a 7b                	push   $0x7b
  jmp __alltraps
  102458:	e9 24 06 00 00       	jmp    102a81 <__alltraps>

0010245d <vector124>:
.globl vector124
vector124:
  pushl $0
  10245d:	6a 00                	push   $0x0
  pushl $124
  10245f:	6a 7c                	push   $0x7c
  jmp __alltraps
  102461:	e9 1b 06 00 00       	jmp    102a81 <__alltraps>

00102466 <vector125>:
.globl vector125
vector125:
  pushl $0
  102466:	6a 00                	push   $0x0
  pushl $125
  102468:	6a 7d                	push   $0x7d
  jmp __alltraps
  10246a:	e9 12 06 00 00       	jmp    102a81 <__alltraps>

0010246f <vector126>:
.globl vector126
vector126:
  pushl $0
  10246f:	6a 00                	push   $0x0
  pushl $126
  102471:	6a 7e                	push   $0x7e
  jmp __alltraps
  102473:	e9 09 06 00 00       	jmp    102a81 <__alltraps>

00102478 <vector127>:
.globl vector127
vector127:
  pushl $0
  102478:	6a 00                	push   $0x0
  pushl $127
  10247a:	6a 7f                	push   $0x7f
  jmp __alltraps
  10247c:	e9 00 06 00 00       	jmp    102a81 <__alltraps>

00102481 <vector128>:
.globl vector128
vector128:
  pushl $0
  102481:	6a 00                	push   $0x0
  pushl $128
  102483:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102488:	e9 f4 05 00 00       	jmp    102a81 <__alltraps>

0010248d <vector129>:
.globl vector129
vector129:
  pushl $0
  10248d:	6a 00                	push   $0x0
  pushl $129
  10248f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102494:	e9 e8 05 00 00       	jmp    102a81 <__alltraps>

00102499 <vector130>:
.globl vector130
vector130:
  pushl $0
  102499:	6a 00                	push   $0x0
  pushl $130
  10249b:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1024a0:	e9 dc 05 00 00       	jmp    102a81 <__alltraps>

001024a5 <vector131>:
.globl vector131
vector131:
  pushl $0
  1024a5:	6a 00                	push   $0x0
  pushl $131
  1024a7:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1024ac:	e9 d0 05 00 00       	jmp    102a81 <__alltraps>

001024b1 <vector132>:
.globl vector132
vector132:
  pushl $0
  1024b1:	6a 00                	push   $0x0
  pushl $132
  1024b3:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1024b8:	e9 c4 05 00 00       	jmp    102a81 <__alltraps>

001024bd <vector133>:
.globl vector133
vector133:
  pushl $0
  1024bd:	6a 00                	push   $0x0
  pushl $133
  1024bf:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1024c4:	e9 b8 05 00 00       	jmp    102a81 <__alltraps>

001024c9 <vector134>:
.globl vector134
vector134:
  pushl $0
  1024c9:	6a 00                	push   $0x0
  pushl $134
  1024cb:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1024d0:	e9 ac 05 00 00       	jmp    102a81 <__alltraps>

001024d5 <vector135>:
.globl vector135
vector135:
  pushl $0
  1024d5:	6a 00                	push   $0x0
  pushl $135
  1024d7:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1024dc:	e9 a0 05 00 00       	jmp    102a81 <__alltraps>

001024e1 <vector136>:
.globl vector136
vector136:
  pushl $0
  1024e1:	6a 00                	push   $0x0
  pushl $136
  1024e3:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1024e8:	e9 94 05 00 00       	jmp    102a81 <__alltraps>

001024ed <vector137>:
.globl vector137
vector137:
  pushl $0
  1024ed:	6a 00                	push   $0x0
  pushl $137
  1024ef:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1024f4:	e9 88 05 00 00       	jmp    102a81 <__alltraps>

001024f9 <vector138>:
.globl vector138
vector138:
  pushl $0
  1024f9:	6a 00                	push   $0x0
  pushl $138
  1024fb:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102500:	e9 7c 05 00 00       	jmp    102a81 <__alltraps>

00102505 <vector139>:
.globl vector139
vector139:
  pushl $0
  102505:	6a 00                	push   $0x0
  pushl $139
  102507:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10250c:	e9 70 05 00 00       	jmp    102a81 <__alltraps>

00102511 <vector140>:
.globl vector140
vector140:
  pushl $0
  102511:	6a 00                	push   $0x0
  pushl $140
  102513:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102518:	e9 64 05 00 00       	jmp    102a81 <__alltraps>

0010251d <vector141>:
.globl vector141
vector141:
  pushl $0
  10251d:	6a 00                	push   $0x0
  pushl $141
  10251f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102524:	e9 58 05 00 00       	jmp    102a81 <__alltraps>

00102529 <vector142>:
.globl vector142
vector142:
  pushl $0
  102529:	6a 00                	push   $0x0
  pushl $142
  10252b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102530:	e9 4c 05 00 00       	jmp    102a81 <__alltraps>

00102535 <vector143>:
.globl vector143
vector143:
  pushl $0
  102535:	6a 00                	push   $0x0
  pushl $143
  102537:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10253c:	e9 40 05 00 00       	jmp    102a81 <__alltraps>

00102541 <vector144>:
.globl vector144
vector144:
  pushl $0
  102541:	6a 00                	push   $0x0
  pushl $144
  102543:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102548:	e9 34 05 00 00       	jmp    102a81 <__alltraps>

0010254d <vector145>:
.globl vector145
vector145:
  pushl $0
  10254d:	6a 00                	push   $0x0
  pushl $145
  10254f:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102554:	e9 28 05 00 00       	jmp    102a81 <__alltraps>

00102559 <vector146>:
.globl vector146
vector146:
  pushl $0
  102559:	6a 00                	push   $0x0
  pushl $146
  10255b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102560:	e9 1c 05 00 00       	jmp    102a81 <__alltraps>

00102565 <vector147>:
.globl vector147
vector147:
  pushl $0
  102565:	6a 00                	push   $0x0
  pushl $147
  102567:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10256c:	e9 10 05 00 00       	jmp    102a81 <__alltraps>

00102571 <vector148>:
.globl vector148
vector148:
  pushl $0
  102571:	6a 00                	push   $0x0
  pushl $148
  102573:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102578:	e9 04 05 00 00       	jmp    102a81 <__alltraps>

0010257d <vector149>:
.globl vector149
vector149:
  pushl $0
  10257d:	6a 00                	push   $0x0
  pushl $149
  10257f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102584:	e9 f8 04 00 00       	jmp    102a81 <__alltraps>

00102589 <vector150>:
.globl vector150
vector150:
  pushl $0
  102589:	6a 00                	push   $0x0
  pushl $150
  10258b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102590:	e9 ec 04 00 00       	jmp    102a81 <__alltraps>

00102595 <vector151>:
.globl vector151
vector151:
  pushl $0
  102595:	6a 00                	push   $0x0
  pushl $151
  102597:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10259c:	e9 e0 04 00 00       	jmp    102a81 <__alltraps>

001025a1 <vector152>:
.globl vector152
vector152:
  pushl $0
  1025a1:	6a 00                	push   $0x0
  pushl $152
  1025a3:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1025a8:	e9 d4 04 00 00       	jmp    102a81 <__alltraps>

001025ad <vector153>:
.globl vector153
vector153:
  pushl $0
  1025ad:	6a 00                	push   $0x0
  pushl $153
  1025af:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1025b4:	e9 c8 04 00 00       	jmp    102a81 <__alltraps>

001025b9 <vector154>:
.globl vector154
vector154:
  pushl $0
  1025b9:	6a 00                	push   $0x0
  pushl $154
  1025bb:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1025c0:	e9 bc 04 00 00       	jmp    102a81 <__alltraps>

001025c5 <vector155>:
.globl vector155
vector155:
  pushl $0
  1025c5:	6a 00                	push   $0x0
  pushl $155
  1025c7:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1025cc:	e9 b0 04 00 00       	jmp    102a81 <__alltraps>

001025d1 <vector156>:
.globl vector156
vector156:
  pushl $0
  1025d1:	6a 00                	push   $0x0
  pushl $156
  1025d3:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1025d8:	e9 a4 04 00 00       	jmp    102a81 <__alltraps>

001025dd <vector157>:
.globl vector157
vector157:
  pushl $0
  1025dd:	6a 00                	push   $0x0
  pushl $157
  1025df:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1025e4:	e9 98 04 00 00       	jmp    102a81 <__alltraps>

001025e9 <vector158>:
.globl vector158
vector158:
  pushl $0
  1025e9:	6a 00                	push   $0x0
  pushl $158
  1025eb:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1025f0:	e9 8c 04 00 00       	jmp    102a81 <__alltraps>

001025f5 <vector159>:
.globl vector159
vector159:
  pushl $0
  1025f5:	6a 00                	push   $0x0
  pushl $159
  1025f7:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1025fc:	e9 80 04 00 00       	jmp    102a81 <__alltraps>

00102601 <vector160>:
.globl vector160
vector160:
  pushl $0
  102601:	6a 00                	push   $0x0
  pushl $160
  102603:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102608:	e9 74 04 00 00       	jmp    102a81 <__alltraps>

0010260d <vector161>:
.globl vector161
vector161:
  pushl $0
  10260d:	6a 00                	push   $0x0
  pushl $161
  10260f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102614:	e9 68 04 00 00       	jmp    102a81 <__alltraps>

00102619 <vector162>:
.globl vector162
vector162:
  pushl $0
  102619:	6a 00                	push   $0x0
  pushl $162
  10261b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102620:	e9 5c 04 00 00       	jmp    102a81 <__alltraps>

00102625 <vector163>:
.globl vector163
vector163:
  pushl $0
  102625:	6a 00                	push   $0x0
  pushl $163
  102627:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10262c:	e9 50 04 00 00       	jmp    102a81 <__alltraps>

00102631 <vector164>:
.globl vector164
vector164:
  pushl $0
  102631:	6a 00                	push   $0x0
  pushl $164
  102633:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102638:	e9 44 04 00 00       	jmp    102a81 <__alltraps>

0010263d <vector165>:
.globl vector165
vector165:
  pushl $0
  10263d:	6a 00                	push   $0x0
  pushl $165
  10263f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102644:	e9 38 04 00 00       	jmp    102a81 <__alltraps>

00102649 <vector166>:
.globl vector166
vector166:
  pushl $0
  102649:	6a 00                	push   $0x0
  pushl $166
  10264b:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102650:	e9 2c 04 00 00       	jmp    102a81 <__alltraps>

00102655 <vector167>:
.globl vector167
vector167:
  pushl $0
  102655:	6a 00                	push   $0x0
  pushl $167
  102657:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10265c:	e9 20 04 00 00       	jmp    102a81 <__alltraps>

00102661 <vector168>:
.globl vector168
vector168:
  pushl $0
  102661:	6a 00                	push   $0x0
  pushl $168
  102663:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102668:	e9 14 04 00 00       	jmp    102a81 <__alltraps>

0010266d <vector169>:
.globl vector169
vector169:
  pushl $0
  10266d:	6a 00                	push   $0x0
  pushl $169
  10266f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102674:	e9 08 04 00 00       	jmp    102a81 <__alltraps>

00102679 <vector170>:
.globl vector170
vector170:
  pushl $0
  102679:	6a 00                	push   $0x0
  pushl $170
  10267b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102680:	e9 fc 03 00 00       	jmp    102a81 <__alltraps>

00102685 <vector171>:
.globl vector171
vector171:
  pushl $0
  102685:	6a 00                	push   $0x0
  pushl $171
  102687:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10268c:	e9 f0 03 00 00       	jmp    102a81 <__alltraps>

00102691 <vector172>:
.globl vector172
vector172:
  pushl $0
  102691:	6a 00                	push   $0x0
  pushl $172
  102693:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102698:	e9 e4 03 00 00       	jmp    102a81 <__alltraps>

0010269d <vector173>:
.globl vector173
vector173:
  pushl $0
  10269d:	6a 00                	push   $0x0
  pushl $173
  10269f:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1026a4:	e9 d8 03 00 00       	jmp    102a81 <__alltraps>

001026a9 <vector174>:
.globl vector174
vector174:
  pushl $0
  1026a9:	6a 00                	push   $0x0
  pushl $174
  1026ab:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1026b0:	e9 cc 03 00 00       	jmp    102a81 <__alltraps>

001026b5 <vector175>:
.globl vector175
vector175:
  pushl $0
  1026b5:	6a 00                	push   $0x0
  pushl $175
  1026b7:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1026bc:	e9 c0 03 00 00       	jmp    102a81 <__alltraps>

001026c1 <vector176>:
.globl vector176
vector176:
  pushl $0
  1026c1:	6a 00                	push   $0x0
  pushl $176
  1026c3:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1026c8:	e9 b4 03 00 00       	jmp    102a81 <__alltraps>

001026cd <vector177>:
.globl vector177
vector177:
  pushl $0
  1026cd:	6a 00                	push   $0x0
  pushl $177
  1026cf:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1026d4:	e9 a8 03 00 00       	jmp    102a81 <__alltraps>

001026d9 <vector178>:
.globl vector178
vector178:
  pushl $0
  1026d9:	6a 00                	push   $0x0
  pushl $178
  1026db:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1026e0:	e9 9c 03 00 00       	jmp    102a81 <__alltraps>

001026e5 <vector179>:
.globl vector179
vector179:
  pushl $0
  1026e5:	6a 00                	push   $0x0
  pushl $179
  1026e7:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1026ec:	e9 90 03 00 00       	jmp    102a81 <__alltraps>

001026f1 <vector180>:
.globl vector180
vector180:
  pushl $0
  1026f1:	6a 00                	push   $0x0
  pushl $180
  1026f3:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1026f8:	e9 84 03 00 00       	jmp    102a81 <__alltraps>

001026fd <vector181>:
.globl vector181
vector181:
  pushl $0
  1026fd:	6a 00                	push   $0x0
  pushl $181
  1026ff:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102704:	e9 78 03 00 00       	jmp    102a81 <__alltraps>

00102709 <vector182>:
.globl vector182
vector182:
  pushl $0
  102709:	6a 00                	push   $0x0
  pushl $182
  10270b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102710:	e9 6c 03 00 00       	jmp    102a81 <__alltraps>

00102715 <vector183>:
.globl vector183
vector183:
  pushl $0
  102715:	6a 00                	push   $0x0
  pushl $183
  102717:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10271c:	e9 60 03 00 00       	jmp    102a81 <__alltraps>

00102721 <vector184>:
.globl vector184
vector184:
  pushl $0
  102721:	6a 00                	push   $0x0
  pushl $184
  102723:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102728:	e9 54 03 00 00       	jmp    102a81 <__alltraps>

0010272d <vector185>:
.globl vector185
vector185:
  pushl $0
  10272d:	6a 00                	push   $0x0
  pushl $185
  10272f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102734:	e9 48 03 00 00       	jmp    102a81 <__alltraps>

00102739 <vector186>:
.globl vector186
vector186:
  pushl $0
  102739:	6a 00                	push   $0x0
  pushl $186
  10273b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102740:	e9 3c 03 00 00       	jmp    102a81 <__alltraps>

00102745 <vector187>:
.globl vector187
vector187:
  pushl $0
  102745:	6a 00                	push   $0x0
  pushl $187
  102747:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10274c:	e9 30 03 00 00       	jmp    102a81 <__alltraps>

00102751 <vector188>:
.globl vector188
vector188:
  pushl $0
  102751:	6a 00                	push   $0x0
  pushl $188
  102753:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102758:	e9 24 03 00 00       	jmp    102a81 <__alltraps>

0010275d <vector189>:
.globl vector189
vector189:
  pushl $0
  10275d:	6a 00                	push   $0x0
  pushl $189
  10275f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102764:	e9 18 03 00 00       	jmp    102a81 <__alltraps>

00102769 <vector190>:
.globl vector190
vector190:
  pushl $0
  102769:	6a 00                	push   $0x0
  pushl $190
  10276b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102770:	e9 0c 03 00 00       	jmp    102a81 <__alltraps>

00102775 <vector191>:
.globl vector191
vector191:
  pushl $0
  102775:	6a 00                	push   $0x0
  pushl $191
  102777:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10277c:	e9 00 03 00 00       	jmp    102a81 <__alltraps>

00102781 <vector192>:
.globl vector192
vector192:
  pushl $0
  102781:	6a 00                	push   $0x0
  pushl $192
  102783:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102788:	e9 f4 02 00 00       	jmp    102a81 <__alltraps>

0010278d <vector193>:
.globl vector193
vector193:
  pushl $0
  10278d:	6a 00                	push   $0x0
  pushl $193
  10278f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102794:	e9 e8 02 00 00       	jmp    102a81 <__alltraps>

00102799 <vector194>:
.globl vector194
vector194:
  pushl $0
  102799:	6a 00                	push   $0x0
  pushl $194
  10279b:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1027a0:	e9 dc 02 00 00       	jmp    102a81 <__alltraps>

001027a5 <vector195>:
.globl vector195
vector195:
  pushl $0
  1027a5:	6a 00                	push   $0x0
  pushl $195
  1027a7:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1027ac:	e9 d0 02 00 00       	jmp    102a81 <__alltraps>

001027b1 <vector196>:
.globl vector196
vector196:
  pushl $0
  1027b1:	6a 00                	push   $0x0
  pushl $196
  1027b3:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1027b8:	e9 c4 02 00 00       	jmp    102a81 <__alltraps>

001027bd <vector197>:
.globl vector197
vector197:
  pushl $0
  1027bd:	6a 00                	push   $0x0
  pushl $197
  1027bf:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1027c4:	e9 b8 02 00 00       	jmp    102a81 <__alltraps>

001027c9 <vector198>:
.globl vector198
vector198:
  pushl $0
  1027c9:	6a 00                	push   $0x0
  pushl $198
  1027cb:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1027d0:	e9 ac 02 00 00       	jmp    102a81 <__alltraps>

001027d5 <vector199>:
.globl vector199
vector199:
  pushl $0
  1027d5:	6a 00                	push   $0x0
  pushl $199
  1027d7:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1027dc:	e9 a0 02 00 00       	jmp    102a81 <__alltraps>

001027e1 <vector200>:
.globl vector200
vector200:
  pushl $0
  1027e1:	6a 00                	push   $0x0
  pushl $200
  1027e3:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1027e8:	e9 94 02 00 00       	jmp    102a81 <__alltraps>

001027ed <vector201>:
.globl vector201
vector201:
  pushl $0
  1027ed:	6a 00                	push   $0x0
  pushl $201
  1027ef:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1027f4:	e9 88 02 00 00       	jmp    102a81 <__alltraps>

001027f9 <vector202>:
.globl vector202
vector202:
  pushl $0
  1027f9:	6a 00                	push   $0x0
  pushl $202
  1027fb:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102800:	e9 7c 02 00 00       	jmp    102a81 <__alltraps>

00102805 <vector203>:
.globl vector203
vector203:
  pushl $0
  102805:	6a 00                	push   $0x0
  pushl $203
  102807:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10280c:	e9 70 02 00 00       	jmp    102a81 <__alltraps>

00102811 <vector204>:
.globl vector204
vector204:
  pushl $0
  102811:	6a 00                	push   $0x0
  pushl $204
  102813:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102818:	e9 64 02 00 00       	jmp    102a81 <__alltraps>

0010281d <vector205>:
.globl vector205
vector205:
  pushl $0
  10281d:	6a 00                	push   $0x0
  pushl $205
  10281f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102824:	e9 58 02 00 00       	jmp    102a81 <__alltraps>

00102829 <vector206>:
.globl vector206
vector206:
  pushl $0
  102829:	6a 00                	push   $0x0
  pushl $206
  10282b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102830:	e9 4c 02 00 00       	jmp    102a81 <__alltraps>

00102835 <vector207>:
.globl vector207
vector207:
  pushl $0
  102835:	6a 00                	push   $0x0
  pushl $207
  102837:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10283c:	e9 40 02 00 00       	jmp    102a81 <__alltraps>

00102841 <vector208>:
.globl vector208
vector208:
  pushl $0
  102841:	6a 00                	push   $0x0
  pushl $208
  102843:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102848:	e9 34 02 00 00       	jmp    102a81 <__alltraps>

0010284d <vector209>:
.globl vector209
vector209:
  pushl $0
  10284d:	6a 00                	push   $0x0
  pushl $209
  10284f:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102854:	e9 28 02 00 00       	jmp    102a81 <__alltraps>

00102859 <vector210>:
.globl vector210
vector210:
  pushl $0
  102859:	6a 00                	push   $0x0
  pushl $210
  10285b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102860:	e9 1c 02 00 00       	jmp    102a81 <__alltraps>

00102865 <vector211>:
.globl vector211
vector211:
  pushl $0
  102865:	6a 00                	push   $0x0
  pushl $211
  102867:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10286c:	e9 10 02 00 00       	jmp    102a81 <__alltraps>

00102871 <vector212>:
.globl vector212
vector212:
  pushl $0
  102871:	6a 00                	push   $0x0
  pushl $212
  102873:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102878:	e9 04 02 00 00       	jmp    102a81 <__alltraps>

0010287d <vector213>:
.globl vector213
vector213:
  pushl $0
  10287d:	6a 00                	push   $0x0
  pushl $213
  10287f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102884:	e9 f8 01 00 00       	jmp    102a81 <__alltraps>

00102889 <vector214>:
.globl vector214
vector214:
  pushl $0
  102889:	6a 00                	push   $0x0
  pushl $214
  10288b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102890:	e9 ec 01 00 00       	jmp    102a81 <__alltraps>

00102895 <vector215>:
.globl vector215
vector215:
  pushl $0
  102895:	6a 00                	push   $0x0
  pushl $215
  102897:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10289c:	e9 e0 01 00 00       	jmp    102a81 <__alltraps>

001028a1 <vector216>:
.globl vector216
vector216:
  pushl $0
  1028a1:	6a 00                	push   $0x0
  pushl $216
  1028a3:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1028a8:	e9 d4 01 00 00       	jmp    102a81 <__alltraps>

001028ad <vector217>:
.globl vector217
vector217:
  pushl $0
  1028ad:	6a 00                	push   $0x0
  pushl $217
  1028af:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1028b4:	e9 c8 01 00 00       	jmp    102a81 <__alltraps>

001028b9 <vector218>:
.globl vector218
vector218:
  pushl $0
  1028b9:	6a 00                	push   $0x0
  pushl $218
  1028bb:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1028c0:	e9 bc 01 00 00       	jmp    102a81 <__alltraps>

001028c5 <vector219>:
.globl vector219
vector219:
  pushl $0
  1028c5:	6a 00                	push   $0x0
  pushl $219
  1028c7:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1028cc:	e9 b0 01 00 00       	jmp    102a81 <__alltraps>

001028d1 <vector220>:
.globl vector220
vector220:
  pushl $0
  1028d1:	6a 00                	push   $0x0
  pushl $220
  1028d3:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1028d8:	e9 a4 01 00 00       	jmp    102a81 <__alltraps>

001028dd <vector221>:
.globl vector221
vector221:
  pushl $0
  1028dd:	6a 00                	push   $0x0
  pushl $221
  1028df:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1028e4:	e9 98 01 00 00       	jmp    102a81 <__alltraps>

001028e9 <vector222>:
.globl vector222
vector222:
  pushl $0
  1028e9:	6a 00                	push   $0x0
  pushl $222
  1028eb:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1028f0:	e9 8c 01 00 00       	jmp    102a81 <__alltraps>

001028f5 <vector223>:
.globl vector223
vector223:
  pushl $0
  1028f5:	6a 00                	push   $0x0
  pushl $223
  1028f7:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1028fc:	e9 80 01 00 00       	jmp    102a81 <__alltraps>

00102901 <vector224>:
.globl vector224
vector224:
  pushl $0
  102901:	6a 00                	push   $0x0
  pushl $224
  102903:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102908:	e9 74 01 00 00       	jmp    102a81 <__alltraps>

0010290d <vector225>:
.globl vector225
vector225:
  pushl $0
  10290d:	6a 00                	push   $0x0
  pushl $225
  10290f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102914:	e9 68 01 00 00       	jmp    102a81 <__alltraps>

00102919 <vector226>:
.globl vector226
vector226:
  pushl $0
  102919:	6a 00                	push   $0x0
  pushl $226
  10291b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102920:	e9 5c 01 00 00       	jmp    102a81 <__alltraps>

00102925 <vector227>:
.globl vector227
vector227:
  pushl $0
  102925:	6a 00                	push   $0x0
  pushl $227
  102927:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10292c:	e9 50 01 00 00       	jmp    102a81 <__alltraps>

00102931 <vector228>:
.globl vector228
vector228:
  pushl $0
  102931:	6a 00                	push   $0x0
  pushl $228
  102933:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102938:	e9 44 01 00 00       	jmp    102a81 <__alltraps>

0010293d <vector229>:
.globl vector229
vector229:
  pushl $0
  10293d:	6a 00                	push   $0x0
  pushl $229
  10293f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102944:	e9 38 01 00 00       	jmp    102a81 <__alltraps>

00102949 <vector230>:
.globl vector230
vector230:
  pushl $0
  102949:	6a 00                	push   $0x0
  pushl $230
  10294b:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102950:	e9 2c 01 00 00       	jmp    102a81 <__alltraps>

00102955 <vector231>:
.globl vector231
vector231:
  pushl $0
  102955:	6a 00                	push   $0x0
  pushl $231
  102957:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10295c:	e9 20 01 00 00       	jmp    102a81 <__alltraps>

00102961 <vector232>:
.globl vector232
vector232:
  pushl $0
  102961:	6a 00                	push   $0x0
  pushl $232
  102963:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102968:	e9 14 01 00 00       	jmp    102a81 <__alltraps>

0010296d <vector233>:
.globl vector233
vector233:
  pushl $0
  10296d:	6a 00                	push   $0x0
  pushl $233
  10296f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102974:	e9 08 01 00 00       	jmp    102a81 <__alltraps>

00102979 <vector234>:
.globl vector234
vector234:
  pushl $0
  102979:	6a 00                	push   $0x0
  pushl $234
  10297b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102980:	e9 fc 00 00 00       	jmp    102a81 <__alltraps>

00102985 <vector235>:
.globl vector235
vector235:
  pushl $0
  102985:	6a 00                	push   $0x0
  pushl $235
  102987:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10298c:	e9 f0 00 00 00       	jmp    102a81 <__alltraps>

00102991 <vector236>:
.globl vector236
vector236:
  pushl $0
  102991:	6a 00                	push   $0x0
  pushl $236
  102993:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102998:	e9 e4 00 00 00       	jmp    102a81 <__alltraps>

0010299d <vector237>:
.globl vector237
vector237:
  pushl $0
  10299d:	6a 00                	push   $0x0
  pushl $237
  10299f:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1029a4:	e9 d8 00 00 00       	jmp    102a81 <__alltraps>

001029a9 <vector238>:
.globl vector238
vector238:
  pushl $0
  1029a9:	6a 00                	push   $0x0
  pushl $238
  1029ab:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1029b0:	e9 cc 00 00 00       	jmp    102a81 <__alltraps>

001029b5 <vector239>:
.globl vector239
vector239:
  pushl $0
  1029b5:	6a 00                	push   $0x0
  pushl $239
  1029b7:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1029bc:	e9 c0 00 00 00       	jmp    102a81 <__alltraps>

001029c1 <vector240>:
.globl vector240
vector240:
  pushl $0
  1029c1:	6a 00                	push   $0x0
  pushl $240
  1029c3:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1029c8:	e9 b4 00 00 00       	jmp    102a81 <__alltraps>

001029cd <vector241>:
.globl vector241
vector241:
  pushl $0
  1029cd:	6a 00                	push   $0x0
  pushl $241
  1029cf:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1029d4:	e9 a8 00 00 00       	jmp    102a81 <__alltraps>

001029d9 <vector242>:
.globl vector242
vector242:
  pushl $0
  1029d9:	6a 00                	push   $0x0
  pushl $242
  1029db:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1029e0:	e9 9c 00 00 00       	jmp    102a81 <__alltraps>

001029e5 <vector243>:
.globl vector243
vector243:
  pushl $0
  1029e5:	6a 00                	push   $0x0
  pushl $243
  1029e7:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1029ec:	e9 90 00 00 00       	jmp    102a81 <__alltraps>

001029f1 <vector244>:
.globl vector244
vector244:
  pushl $0
  1029f1:	6a 00                	push   $0x0
  pushl $244
  1029f3:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1029f8:	e9 84 00 00 00       	jmp    102a81 <__alltraps>

001029fd <vector245>:
.globl vector245
vector245:
  pushl $0
  1029fd:	6a 00                	push   $0x0
  pushl $245
  1029ff:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102a04:	e9 78 00 00 00       	jmp    102a81 <__alltraps>

00102a09 <vector246>:
.globl vector246
vector246:
  pushl $0
  102a09:	6a 00                	push   $0x0
  pushl $246
  102a0b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102a10:	e9 6c 00 00 00       	jmp    102a81 <__alltraps>

00102a15 <vector247>:
.globl vector247
vector247:
  pushl $0
  102a15:	6a 00                	push   $0x0
  pushl $247
  102a17:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102a1c:	e9 60 00 00 00       	jmp    102a81 <__alltraps>

00102a21 <vector248>:
.globl vector248
vector248:
  pushl $0
  102a21:	6a 00                	push   $0x0
  pushl $248
  102a23:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102a28:	e9 54 00 00 00       	jmp    102a81 <__alltraps>

00102a2d <vector249>:
.globl vector249
vector249:
  pushl $0
  102a2d:	6a 00                	push   $0x0
  pushl $249
  102a2f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102a34:	e9 48 00 00 00       	jmp    102a81 <__alltraps>

00102a39 <vector250>:
.globl vector250
vector250:
  pushl $0
  102a39:	6a 00                	push   $0x0
  pushl $250
  102a3b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102a40:	e9 3c 00 00 00       	jmp    102a81 <__alltraps>

00102a45 <vector251>:
.globl vector251
vector251:
  pushl $0
  102a45:	6a 00                	push   $0x0
  pushl $251
  102a47:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102a4c:	e9 30 00 00 00       	jmp    102a81 <__alltraps>

00102a51 <vector252>:
.globl vector252
vector252:
  pushl $0
  102a51:	6a 00                	push   $0x0
  pushl $252
  102a53:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102a58:	e9 24 00 00 00       	jmp    102a81 <__alltraps>

00102a5d <vector253>:
.globl vector253
vector253:
  pushl $0
  102a5d:	6a 00                	push   $0x0
  pushl $253
  102a5f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102a64:	e9 18 00 00 00       	jmp    102a81 <__alltraps>

00102a69 <vector254>:
.globl vector254
vector254:
  pushl $0
  102a69:	6a 00                	push   $0x0
  pushl $254
  102a6b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102a70:	e9 0c 00 00 00       	jmp    102a81 <__alltraps>

00102a75 <vector255>:
.globl vector255
vector255:
  pushl $0
  102a75:	6a 00                	push   $0x0
  pushl $255
  102a77:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102a7c:	e9 00 00 00 00       	jmp    102a81 <__alltraps>

00102a81 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102a81:	1e                   	push   %ds
    pushl %es
  102a82:	06                   	push   %es
    pushl %fs
  102a83:	0f a0                	push   %fs
    pushl %gs
  102a85:	0f a8                	push   %gs
    pushal
  102a87:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102a88:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102a8d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102a8f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102a91:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102a92:	e8 64 f5 ff ff       	call   101ffb <trap>

    # pop the pushed stack pointer
    popl %esp
  102a97:	5c                   	pop    %esp

00102a98 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102a98:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102a99:	0f a9                	pop    %gs
    popl %fs
  102a9b:	0f a1                	pop    %fs
    popl %es
  102a9d:	07                   	pop    %es
    popl %ds
  102a9e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102a9f:	83 c4 08             	add    $0x8,%esp
    iret
  102aa2:	cf                   	iret   

00102aa3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102aa3:	55                   	push   %ebp
  102aa4:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  102aa9:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  102aaf:	29 d0                	sub    %edx,%eax
  102ab1:	c1 f8 02             	sar    $0x2,%eax
  102ab4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102aba:	5d                   	pop    %ebp
  102abb:	c3                   	ret    

00102abc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102abc:	55                   	push   %ebp
  102abd:	89 e5                	mov    %esp,%ebp
  102abf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ac5:	89 04 24             	mov    %eax,(%esp)
  102ac8:	e8 d6 ff ff ff       	call   102aa3 <page2ppn>
  102acd:	c1 e0 0c             	shl    $0xc,%eax
}
  102ad0:	c9                   	leave  
  102ad1:	c3                   	ret    

00102ad2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102ad2:	55                   	push   %ebp
  102ad3:	89 e5                	mov    %esp,%ebp
  102ad5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  102adb:	c1 e8 0c             	shr    $0xc,%eax
  102ade:	89 c2                	mov    %eax,%edx
  102ae0:	a1 80 de 11 00       	mov    0x11de80,%eax
  102ae5:	39 c2                	cmp    %eax,%edx
  102ae7:	72 1c                	jb     102b05 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102ae9:	c7 44 24 08 70 73 10 	movl   $0x107370,0x8(%esp)
  102af0:	00 
  102af1:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  102af8:	00 
  102af9:	c7 04 24 8f 73 10 00 	movl   $0x10738f,(%esp)
  102b00:	e8 f4 d8 ff ff       	call   1003f9 <__panic>
    }
    return &pages[PPN(pa)];
  102b05:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  102b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b0e:	c1 e8 0c             	shr    $0xc,%eax
  102b11:	89 c2                	mov    %eax,%edx
  102b13:	89 d0                	mov    %edx,%eax
  102b15:	c1 e0 02             	shl    $0x2,%eax
  102b18:	01 d0                	add    %edx,%eax
  102b1a:	c1 e0 02             	shl    $0x2,%eax
  102b1d:	01 c8                	add    %ecx,%eax
}
  102b1f:	c9                   	leave  
  102b20:	c3                   	ret    

00102b21 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102b21:	55                   	push   %ebp
  102b22:	89 e5                	mov    %esp,%ebp
  102b24:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102b27:	8b 45 08             	mov    0x8(%ebp),%eax
  102b2a:	89 04 24             	mov    %eax,(%esp)
  102b2d:	e8 8a ff ff ff       	call   102abc <page2pa>
  102b32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b38:	c1 e8 0c             	shr    $0xc,%eax
  102b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102b3e:	a1 80 de 11 00       	mov    0x11de80,%eax
  102b43:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102b46:	72 23                	jb     102b6b <page2kva+0x4a>
  102b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102b4f:	c7 44 24 08 a0 73 10 	movl   $0x1073a0,0x8(%esp)
  102b56:	00 
  102b57:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  102b5e:	00 
  102b5f:	c7 04 24 8f 73 10 00 	movl   $0x10738f,(%esp)
  102b66:	e8 8e d8 ff ff       	call   1003f9 <__panic>
  102b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b6e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102b73:	c9                   	leave  
  102b74:	c3                   	ret    

00102b75 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102b75:	55                   	push   %ebp
  102b76:	89 e5                	mov    %esp,%ebp
  102b78:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7e:	83 e0 01             	and    $0x1,%eax
  102b81:	85 c0                	test   %eax,%eax
  102b83:	75 1c                	jne    102ba1 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102b85:	c7 44 24 08 c4 73 10 	movl   $0x1073c4,0x8(%esp)
  102b8c:	00 
  102b8d:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  102b94:	00 
  102b95:	c7 04 24 8f 73 10 00 	movl   $0x10738f,(%esp)
  102b9c:	e8 58 d8 ff ff       	call   1003f9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102ba9:	89 04 24             	mov    %eax,(%esp)
  102bac:	e8 21 ff ff ff       	call   102ad2 <pa2page>
}
  102bb1:	c9                   	leave  
  102bb2:	c3                   	ret    

00102bb3 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  102bb3:	55                   	push   %ebp
  102bb4:	89 e5                	mov    %esp,%ebp
  102bb6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102bc1:	89 04 24             	mov    %eax,(%esp)
  102bc4:	e8 09 ff ff ff       	call   102ad2 <pa2page>
}
  102bc9:	c9                   	leave  
  102bca:	c3                   	ret    

00102bcb <page_ref>:

static inline int
page_ref(struct Page *page) {
  102bcb:	55                   	push   %ebp
  102bcc:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102bce:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd1:	8b 00                	mov    (%eax),%eax
}
  102bd3:	5d                   	pop    %ebp
  102bd4:	c3                   	ret    

00102bd5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102bd5:	55                   	push   %ebp
  102bd6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  102bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bde:	89 10                	mov    %edx,(%eax)
}
  102be0:	90                   	nop
  102be1:	5d                   	pop    %ebp
  102be2:	c3                   	ret    

00102be3 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102be3:	55                   	push   %ebp
  102be4:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102be6:	8b 45 08             	mov    0x8(%ebp),%eax
  102be9:	8b 00                	mov    (%eax),%eax
  102beb:	8d 50 01             	lea    0x1(%eax),%edx
  102bee:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf1:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf6:	8b 00                	mov    (%eax),%eax
}
  102bf8:	5d                   	pop    %ebp
  102bf9:	c3                   	ret    

00102bfa <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102bfa:	55                   	push   %ebp
  102bfb:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  102c00:	8b 00                	mov    (%eax),%eax
  102c02:	8d 50 ff             	lea    -0x1(%eax),%edx
  102c05:	8b 45 08             	mov    0x8(%ebp),%eax
  102c08:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c0d:	8b 00                	mov    (%eax),%eax
}
  102c0f:	5d                   	pop    %ebp
  102c10:	c3                   	ret    

00102c11 <__intr_save>:
__intr_save(void) {
  102c11:	55                   	push   %ebp
  102c12:	89 e5                	mov    %esp,%ebp
  102c14:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102c17:	9c                   	pushf  
  102c18:	58                   	pop    %eax
  102c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102c1f:	25 00 02 00 00       	and    $0x200,%eax
  102c24:	85 c0                	test   %eax,%eax
  102c26:	74 0c                	je     102c34 <__intr_save+0x23>
        intr_disable();
  102c28:	e8 70 ec ff ff       	call   10189d <intr_disable>
        return 1;
  102c2d:	b8 01 00 00 00       	mov    $0x1,%eax
  102c32:	eb 05                	jmp    102c39 <__intr_save+0x28>
    return 0;
  102c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102c39:	c9                   	leave  
  102c3a:	c3                   	ret    

00102c3b <__intr_restore>:
__intr_restore(bool flag) {
  102c3b:	55                   	push   %ebp
  102c3c:	89 e5                	mov    %esp,%ebp
  102c3e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102c41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102c45:	74 05                	je     102c4c <__intr_restore+0x11>
        intr_enable();
  102c47:	e8 4a ec ff ff       	call   101896 <intr_enable>
}
  102c4c:	90                   	nop
  102c4d:	c9                   	leave  
  102c4e:	c3                   	ret    

00102c4f <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102c4f:	55                   	push   %ebp
  102c50:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102c52:	8b 45 08             	mov    0x8(%ebp),%eax
  102c55:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102c58:	b8 23 00 00 00       	mov    $0x23,%eax
  102c5d:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102c5f:	b8 23 00 00 00       	mov    $0x23,%eax
  102c64:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102c66:	b8 10 00 00 00       	mov    $0x10,%eax
  102c6b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102c6d:	b8 10 00 00 00       	mov    $0x10,%eax
  102c72:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102c74:	b8 10 00 00 00       	mov    $0x10,%eax
  102c79:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102c7b:	ea 82 2c 10 00 08 00 	ljmp   $0x8,$0x102c82
}
  102c82:	90                   	nop
  102c83:	5d                   	pop    %ebp
  102c84:	c3                   	ret    

00102c85 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102c85:	55                   	push   %ebp
  102c86:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102c88:	8b 45 08             	mov    0x8(%ebp),%eax
  102c8b:	a3 a4 de 11 00       	mov    %eax,0x11dea4
}
  102c90:	90                   	nop
  102c91:	5d                   	pop    %ebp
  102c92:	c3                   	ret    

00102c93 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102c93:	55                   	push   %ebp
  102c94:	89 e5                	mov    %esp,%ebp
  102c96:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102c99:	b8 00 a0 11 00       	mov    $0x11a000,%eax
  102c9e:	89 04 24             	mov    %eax,(%esp)
  102ca1:	e8 df ff ff ff       	call   102c85 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102ca6:	66 c7 05 a8 de 11 00 	movw   $0x10,0x11dea8
  102cad:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102caf:	66 c7 05 28 aa 11 00 	movw   $0x68,0x11aa28
  102cb6:	68 00 
  102cb8:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102cbd:	0f b7 c0             	movzwl %ax,%eax
  102cc0:	66 a3 2a aa 11 00    	mov    %ax,0x11aa2a
  102cc6:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102ccb:	c1 e8 10             	shr    $0x10,%eax
  102cce:	a2 2c aa 11 00       	mov    %al,0x11aa2c
  102cd3:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102cda:	24 f0                	and    $0xf0,%al
  102cdc:	0c 09                	or     $0x9,%al
  102cde:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102ce3:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102cea:	24 ef                	and    $0xef,%al
  102cec:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102cf1:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102cf8:	24 9f                	and    $0x9f,%al
  102cfa:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102cff:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102d06:	0c 80                	or     $0x80,%al
  102d08:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102d0d:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102d14:	24 f0                	and    $0xf0,%al
  102d16:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102d1b:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102d22:	24 ef                	and    $0xef,%al
  102d24:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102d29:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102d30:	24 df                	and    $0xdf,%al
  102d32:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102d37:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102d3e:	0c 40                	or     $0x40,%al
  102d40:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102d45:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102d4c:	24 7f                	and    $0x7f,%al
  102d4e:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102d53:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102d58:	c1 e8 18             	shr    $0x18,%eax
  102d5b:	a2 2f aa 11 00       	mov    %al,0x11aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102d60:	c7 04 24 30 aa 11 00 	movl   $0x11aa30,(%esp)
  102d67:	e8 e3 fe ff ff       	call   102c4f <lgdt>
  102d6c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102d72:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102d76:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102d79:	90                   	nop
  102d7a:	c9                   	leave  
  102d7b:	c3                   	ret    

00102d7c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102d7c:	55                   	push   %ebp
  102d7d:	89 e5                	mov    %esp,%ebp
  102d7f:	83 ec 18             	sub    $0x18,%esp
    //pmm_manager = &default_pmm_manager;
    pmm_manager = &buddy_pmm_manager;
  102d82:	c7 05 10 df 11 00 84 	movl   $0x107b84,0x11df10
  102d89:	7b 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102d8c:	a1 10 df 11 00       	mov    0x11df10,%eax
  102d91:	8b 00                	mov    (%eax),%eax
  102d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d97:	c7 04 24 f0 73 10 00 	movl   $0x1073f0,(%esp)
  102d9e:	e8 ff d4 ff ff       	call   1002a2 <cprintf>
    pmm_manager->init();
  102da3:	a1 10 df 11 00       	mov    0x11df10,%eax
  102da8:	8b 40 04             	mov    0x4(%eax),%eax
  102dab:	ff d0                	call   *%eax
}
  102dad:	90                   	nop
  102dae:	c9                   	leave  
  102daf:	c3                   	ret    

00102db0 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102db0:	55                   	push   %ebp
  102db1:	89 e5                	mov    %esp,%ebp
  102db3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102db6:	a1 10 df 11 00       	mov    0x11df10,%eax
  102dbb:	8b 40 08             	mov    0x8(%eax),%eax
  102dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  102dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  102dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  102dc8:	89 14 24             	mov    %edx,(%esp)
  102dcb:	ff d0                	call   *%eax
}
  102dcd:	90                   	nop
  102dce:	c9                   	leave  
  102dcf:	c3                   	ret    

00102dd0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102dd0:	55                   	push   %ebp
  102dd1:	89 e5                	mov    %esp,%ebp
  102dd3:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102dd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102ddd:	e8 2f fe ff ff       	call   102c11 <__intr_save>
  102de2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102de5:	a1 10 df 11 00       	mov    0x11df10,%eax
  102dea:	8b 40 0c             	mov    0xc(%eax),%eax
  102ded:	8b 55 08             	mov    0x8(%ebp),%edx
  102df0:	89 14 24             	mov    %edx,(%esp)
  102df3:	ff d0                	call   *%eax
  102df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102dfb:	89 04 24             	mov    %eax,(%esp)
  102dfe:	e8 38 fe ff ff       	call   102c3b <__intr_restore>
    //cprintf("here3\n");
    return page;
  102e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102e06:	c9                   	leave  
  102e07:	c3                   	ret    

00102e08 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102e08:	55                   	push   %ebp
  102e09:	89 e5                	mov    %esp,%ebp
  102e0b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102e0e:	e8 fe fd ff ff       	call   102c11 <__intr_save>
  102e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102e16:	a1 10 df 11 00       	mov    0x11df10,%eax
  102e1b:	8b 40 10             	mov    0x10(%eax),%eax
  102e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e21:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e25:	8b 55 08             	mov    0x8(%ebp),%edx
  102e28:	89 14 24             	mov    %edx,(%esp)
  102e2b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e30:	89 04 24             	mov    %eax,(%esp)
  102e33:	e8 03 fe ff ff       	call   102c3b <__intr_restore>
}
  102e38:	90                   	nop
  102e39:	c9                   	leave  
  102e3a:	c3                   	ret    

00102e3b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102e3b:	55                   	push   %ebp
  102e3c:	89 e5                	mov    %esp,%ebp
  102e3e:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102e41:	e8 cb fd ff ff       	call   102c11 <__intr_save>
  102e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102e49:	a1 10 df 11 00       	mov    0x11df10,%eax
  102e4e:	8b 40 14             	mov    0x14(%eax),%eax
  102e51:	ff d0                	call   *%eax
  102e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e59:	89 04 24             	mov    %eax,(%esp)
  102e5c:	e8 da fd ff ff       	call   102c3b <__intr_restore>
    return ret;
  102e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102e64:	c9                   	leave  
  102e65:	c3                   	ret    

00102e66 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102e66:	55                   	push   %ebp
  102e67:	89 e5                	mov    %esp,%ebp
  102e69:	57                   	push   %edi
  102e6a:	56                   	push   %esi
  102e6b:	53                   	push   %ebx
  102e6c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102e72:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102e79:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102e80:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102e87:	c7 04 24 07 74 10 00 	movl   $0x107407,(%esp)
  102e8e:	e8 0f d4 ff ff       	call   1002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102e93:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e9a:	e9 22 01 00 00       	jmp    102fc1 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ea2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ea5:	89 d0                	mov    %edx,%eax
  102ea7:	c1 e0 02             	shl    $0x2,%eax
  102eaa:	01 d0                	add    %edx,%eax
  102eac:	c1 e0 02             	shl    $0x2,%eax
  102eaf:	01 c8                	add    %ecx,%eax
  102eb1:	8b 50 08             	mov    0x8(%eax),%edx
  102eb4:	8b 40 04             	mov    0x4(%eax),%eax
  102eb7:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102eba:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102ebd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ec0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ec3:	89 d0                	mov    %edx,%eax
  102ec5:	c1 e0 02             	shl    $0x2,%eax
  102ec8:	01 d0                	add    %edx,%eax
  102eca:	c1 e0 02             	shl    $0x2,%eax
  102ecd:	01 c8                	add    %ecx,%eax
  102ecf:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ed2:	8b 58 10             	mov    0x10(%eax),%ebx
  102ed5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ed8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102edb:	01 c8                	add    %ecx,%eax
  102edd:	11 da                	adc    %ebx,%edx
  102edf:	89 45 98             	mov    %eax,-0x68(%ebp)
  102ee2:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102ee5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ee8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eeb:	89 d0                	mov    %edx,%eax
  102eed:	c1 e0 02             	shl    $0x2,%eax
  102ef0:	01 d0                	add    %edx,%eax
  102ef2:	c1 e0 02             	shl    $0x2,%eax
  102ef5:	01 c8                	add    %ecx,%eax
  102ef7:	83 c0 14             	add    $0x14,%eax
  102efa:	8b 00                	mov    (%eax),%eax
  102efc:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102eff:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f02:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102f05:	83 c0 ff             	add    $0xffffffff,%eax
  102f08:	83 d2 ff             	adc    $0xffffffff,%edx
  102f0b:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102f11:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102f17:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f1d:	89 d0                	mov    %edx,%eax
  102f1f:	c1 e0 02             	shl    $0x2,%eax
  102f22:	01 d0                	add    %edx,%eax
  102f24:	c1 e0 02             	shl    $0x2,%eax
  102f27:	01 c8                	add    %ecx,%eax
  102f29:	8b 48 0c             	mov    0xc(%eax),%ecx
  102f2c:	8b 58 10             	mov    0x10(%eax),%ebx
  102f2f:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102f32:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102f36:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102f3c:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102f42:	89 44 24 14          	mov    %eax,0x14(%esp)
  102f46:	89 54 24 18          	mov    %edx,0x18(%esp)
  102f4a:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f4d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102f50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102f54:	89 54 24 10          	mov    %edx,0x10(%esp)
  102f58:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102f5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102f60:	c7 04 24 14 74 10 00 	movl   $0x107414,(%esp)
  102f67:	e8 36 d3 ff ff       	call   1002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102f6c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f72:	89 d0                	mov    %edx,%eax
  102f74:	c1 e0 02             	shl    $0x2,%eax
  102f77:	01 d0                	add    %edx,%eax
  102f79:	c1 e0 02             	shl    $0x2,%eax
  102f7c:	01 c8                	add    %ecx,%eax
  102f7e:	83 c0 14             	add    $0x14,%eax
  102f81:	8b 00                	mov    (%eax),%eax
  102f83:	83 f8 01             	cmp    $0x1,%eax
  102f86:	75 36                	jne    102fbe <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f8e:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102f91:	77 2b                	ja     102fbe <page_init+0x158>
  102f93:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102f96:	72 05                	jb     102f9d <page_init+0x137>
  102f98:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102f9b:	73 21                	jae    102fbe <page_init+0x158>
  102f9d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102fa1:	77 1b                	ja     102fbe <page_init+0x158>
  102fa3:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102fa7:	72 09                	jb     102fb2 <page_init+0x14c>
  102fa9:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102fb0:	77 0c                	ja     102fbe <page_init+0x158>
                maxpa = end;
  102fb2:	8b 45 98             	mov    -0x68(%ebp),%eax
  102fb5:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102fbb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102fbe:	ff 45 dc             	incl   -0x24(%ebp)
  102fc1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102fc4:	8b 00                	mov    (%eax),%eax
  102fc6:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102fc9:	0f 8c d0 fe ff ff    	jl     102e9f <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102fcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102fd3:	72 1d                	jb     102ff2 <page_init+0x18c>
  102fd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102fd9:	77 09                	ja     102fe4 <page_init+0x17e>
  102fdb:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102fe2:	76 0e                	jbe    102ff2 <page_init+0x18c>
        maxpa = KMEMSIZE;
  102fe4:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102feb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    // 此处定义的全局end数组指针，正好是ucore kernel加载后定义的第二个全局变量(kern_init处第一行定义的)
    // 其上的高位内存空间并没有被使用,因此以end为起点，存放用于管理物理内存页面的数据结构
    extern char end[];

    npage = maxpa / PGSIZE;
  102ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ff5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102ff8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102ffc:	c1 ea 0c             	shr    $0xc,%edx
  102fff:	89 c1                	mov    %eax,%ecx
  103001:	89 d3                	mov    %edx,%ebx
  103003:	89 c8                	mov    %ecx,%eax
  103005:	a3 80 de 11 00       	mov    %eax,0x11de80
    //cprintf("***********************************npage is:%d**************************\n",npage);  //result is: 32736;
    // pages指针指向->可用于分配的，物理内存页面Page数组起始地址
    // 因此其恰好位于内核空间之上(通过ROUNDUP PGSIZE取整，保证其位于一个新的物理页中)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  10300a:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  103011:	b8 60 14 1e 00       	mov    $0x1e1460,%eax
  103016:	8d 50 ff             	lea    -0x1(%eax),%edx
  103019:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10301c:	01 d0                	add    %edx,%eax
  10301e:	89 45 bc             	mov    %eax,-0x44(%ebp)
  103021:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103024:	ba 00 00 00 00       	mov    $0x0,%edx
  103029:	f7 75 c0             	divl   -0x40(%ebp)
  10302c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10302f:	29 d0                	sub    %edx,%eax
  103031:	a3 18 df 11 00       	mov    %eax,0x11df18

    for (i = 0; i < npage; i ++) {
  103036:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10303d:	eb 2e                	jmp    10306d <page_init+0x207>
        SetPageReserved(pages + i);
  10303f:	8b 0d 18 df 11 00    	mov    0x11df18,%ecx
  103045:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103048:	89 d0                	mov    %edx,%eax
  10304a:	c1 e0 02             	shl    $0x2,%eax
  10304d:	01 d0                	add    %edx,%eax
  10304f:	c1 e0 02             	shl    $0x2,%eax
  103052:	01 c8                	add    %ecx,%eax
  103054:	83 c0 04             	add    $0x4,%eax
  103057:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  10305e:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103061:	8b 45 90             	mov    -0x70(%ebp),%eax
  103064:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103067:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  10306a:	ff 45 dc             	incl   -0x24(%ebp)
  10306d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103070:	a1 80 de 11 00       	mov    0x11de80,%eax
  103075:	39 c2                	cmp    %eax,%edx
  103077:	72 c6                	jb     10303f <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  103079:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  10307f:	89 d0                	mov    %edx,%eax
  103081:	c1 e0 02             	shl    $0x2,%eax
  103084:	01 d0                	add    %edx,%eax
  103086:	c1 e0 02             	shl    $0x2,%eax
  103089:	89 c2                	mov    %eax,%edx
  10308b:	a1 18 df 11 00       	mov    0x11df18,%eax
  103090:	01 d0                	add    %edx,%eax
  103092:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103095:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  10309c:	77 23                	ja     1030c1 <page_init+0x25b>
  10309e:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1030a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1030a5:	c7 44 24 08 44 74 10 	movl   $0x107444,0x8(%esp)
  1030ac:	00 
  1030ad:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  1030b4:	00 
  1030b5:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1030bc:	e8 38 d3 ff ff       	call   1003f9 <__panic>
  1030c1:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1030c4:	05 00 00 00 40       	add    $0x40000000,%eax
  1030c9:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  1030cc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1030d3:	e9 69 01 00 00       	jmp    103241 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1030d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1030db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1030de:	89 d0                	mov    %edx,%eax
  1030e0:	c1 e0 02             	shl    $0x2,%eax
  1030e3:	01 d0                	add    %edx,%eax
  1030e5:	c1 e0 02             	shl    $0x2,%eax
  1030e8:	01 c8                	add    %ecx,%eax
  1030ea:	8b 50 08             	mov    0x8(%eax),%edx
  1030ed:	8b 40 04             	mov    0x4(%eax),%eax
  1030f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030f3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1030f6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1030f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1030fc:	89 d0                	mov    %edx,%eax
  1030fe:	c1 e0 02             	shl    $0x2,%eax
  103101:	01 d0                	add    %edx,%eax
  103103:	c1 e0 02             	shl    $0x2,%eax
  103106:	01 c8                	add    %ecx,%eax
  103108:	8b 48 0c             	mov    0xc(%eax),%ecx
  10310b:	8b 58 10             	mov    0x10(%eax),%ebx
  10310e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103111:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103114:	01 c8                	add    %ecx,%eax
  103116:	11 da                	adc    %ebx,%edx
  103118:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10311b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  10311e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103121:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103124:	89 d0                	mov    %edx,%eax
  103126:	c1 e0 02             	shl    $0x2,%eax
  103129:	01 d0                	add    %edx,%eax
  10312b:	c1 e0 02             	shl    $0x2,%eax
  10312e:	01 c8                	add    %ecx,%eax
  103130:	83 c0 14             	add    $0x14,%eax
  103133:	8b 00                	mov    (%eax),%eax
  103135:	83 f8 01             	cmp    $0x1,%eax
  103138:	0f 85 00 01 00 00    	jne    10323e <page_init+0x3d8>
            if (begin < freemem) {
  10313e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103141:	ba 00 00 00 00       	mov    $0x0,%edx
  103146:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  103149:	77 17                	ja     103162 <page_init+0x2fc>
  10314b:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  10314e:	72 05                	jb     103155 <page_init+0x2ef>
  103150:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  103153:	73 0d                	jae    103162 <page_init+0x2fc>
                begin = freemem;
  103155:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103158:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10315b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  103162:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  103166:	72 1d                	jb     103185 <page_init+0x31f>
  103168:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  10316c:	77 09                	ja     103177 <page_init+0x311>
  10316e:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  103175:	76 0e                	jbe    103185 <page_init+0x31f>
                end = KMEMSIZE;
  103177:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  10317e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  103185:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103188:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10318b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10318e:	0f 87 aa 00 00 00    	ja     10323e <page_init+0x3d8>
  103194:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103197:	72 09                	jb     1031a2 <page_init+0x33c>
  103199:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10319c:	0f 83 9c 00 00 00    	jae    10323e <page_init+0x3d8>
                // begin起始地址以PGSIZE为单位，向高位取整
                begin = ROUNDUP(begin, PGSIZE);
  1031a2:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  1031a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1031ac:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1031af:	01 d0                	add    %edx,%eax
  1031b1:	48                   	dec    %eax
  1031b2:	89 45 ac             	mov    %eax,-0x54(%ebp)
  1031b5:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1031b8:	ba 00 00 00 00       	mov    $0x0,%edx
  1031bd:	f7 75 b0             	divl   -0x50(%ebp)
  1031c0:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1031c3:	29 d0                	sub    %edx,%eax
  1031c5:	ba 00 00 00 00       	mov    $0x0,%edx
  1031ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1031cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                // end截止地址以PGSIZE为单位，向低位取整
                end = ROUNDDOWN(end, PGSIZE);
  1031d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1031d3:	89 45 a8             	mov    %eax,-0x58(%ebp)
  1031d6:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1031d9:	ba 00 00 00 00       	mov    $0x0,%edx
  1031de:	89 c3                	mov    %eax,%ebx
  1031e0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  1031e6:	89 de                	mov    %ebx,%esi
  1031e8:	89 d0                	mov    %edx,%eax
  1031ea:	83 e0 00             	and    $0x0,%eax
  1031ed:	89 c7                	mov    %eax,%edi
  1031ef:	89 75 c8             	mov    %esi,-0x38(%ebp)
  1031f2:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  1031f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1031f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1031fb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1031fe:	77 3e                	ja     10323e <page_init+0x3d8>
  103200:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103203:	72 05                	jb     10320a <page_init+0x3a4>
  103205:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103208:	73 34                	jae    10323e <page_init+0x3d8>
                    // 进行空闲内存块的映射，将其纳入物理内存管理器中管理，用于后续的物理内存分配
                    // 这里的begin、end都是探测出来的物理地址
                    // 第一个参数：起始Page结构的虚拟地址base = pa2page(begin)
                    // 第二个参数：空闲页的个数 = (end - begin) / PGSIZE
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  10320a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10320d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103210:	2b 45 d0             	sub    -0x30(%ebp),%eax
  103213:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  103216:	89 c1                	mov    %eax,%ecx
  103218:	89 d3                	mov    %edx,%ebx
  10321a:	89 c8                	mov    %ecx,%eax
  10321c:	89 da                	mov    %ebx,%edx
  10321e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103222:	c1 ea 0c             	shr    $0xc,%edx
  103225:	89 c3                	mov    %eax,%ebx
  103227:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10322a:	89 04 24             	mov    %eax,(%esp)
  10322d:	e8 a0 f8 ff ff       	call   102ad2 <pa2page>
  103232:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  103236:	89 04 24             	mov    %eax,(%esp)
  103239:	e8 72 fb ff ff       	call   102db0 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  10323e:	ff 45 dc             	incl   -0x24(%ebp)
  103241:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103244:	8b 00                	mov    (%eax),%eax
  103246:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103249:	0f 8c 89 fe ff ff    	jl     1030d8 <page_init+0x272>
                }
            }
        }
    }
}
  10324f:	90                   	nop
  103250:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103256:	5b                   	pop    %ebx
  103257:	5e                   	pop    %esi
  103258:	5f                   	pop    %edi
  103259:	5d                   	pop    %ebp
  10325a:	c3                   	ret    

0010325b <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10325b:	55                   	push   %ebp
  10325c:	89 e5                	mov    %esp,%ebp
  10325e:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103261:	8b 45 0c             	mov    0xc(%ebp),%eax
  103264:	33 45 14             	xor    0x14(%ebp),%eax
  103267:	25 ff 0f 00 00       	and    $0xfff,%eax
  10326c:	85 c0                	test   %eax,%eax
  10326e:	74 24                	je     103294 <boot_map_segment+0x39>
  103270:	c7 44 24 0c 76 74 10 	movl   $0x107476,0xc(%esp)
  103277:	00 
  103278:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  10327f:	00 
  103280:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  103287:	00 
  103288:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  10328f:	e8 65 d1 ff ff       	call   1003f9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  103294:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  10329b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10329e:	25 ff 0f 00 00       	and    $0xfff,%eax
  1032a3:	89 c2                	mov    %eax,%edx
  1032a5:	8b 45 10             	mov    0x10(%ebp),%eax
  1032a8:	01 c2                	add    %eax,%edx
  1032aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032ad:	01 d0                	add    %edx,%eax
  1032af:	48                   	dec    %eax
  1032b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1032b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032b6:	ba 00 00 00 00       	mov    $0x0,%edx
  1032bb:	f7 75 f0             	divl   -0x10(%ebp)
  1032be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032c1:	29 d0                	sub    %edx,%eax
  1032c3:	c1 e8 0c             	shr    $0xc,%eax
  1032c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1032c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032d7:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1032da:	8b 45 14             	mov    0x14(%ebp),%eax
  1032dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1032e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032e8:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1032eb:	eb 68                	jmp    103355 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1032ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1032f4:	00 
  1032f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ff:	89 04 24             	mov    %eax,(%esp)
  103302:	e8 81 01 00 00       	call   103488 <get_pte>
  103307:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10330a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10330e:	75 24                	jne    103334 <boot_map_segment+0xd9>
  103310:	c7 44 24 0c a2 74 10 	movl   $0x1074a2,0xc(%esp)
  103317:	00 
  103318:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  10331f:	00 
  103320:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  103327:	00 
  103328:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  10332f:	e8 c5 d0 ff ff       	call   1003f9 <__panic>
        *ptep = pa | PTE_P | perm;
  103334:	8b 45 14             	mov    0x14(%ebp),%eax
  103337:	0b 45 18             	or     0x18(%ebp),%eax
  10333a:	83 c8 01             	or     $0x1,%eax
  10333d:	89 c2                	mov    %eax,%edx
  10333f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103342:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103344:	ff 4d f4             	decl   -0xc(%ebp)
  103347:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10334e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103355:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103359:	75 92                	jne    1032ed <boot_map_segment+0x92>
    }
}
  10335b:	90                   	nop
  10335c:	c9                   	leave  
  10335d:	c3                   	ret    

0010335e <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10335e:	55                   	push   %ebp
  10335f:	89 e5                	mov    %esp,%ebp
  103361:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103364:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10336b:	e8 60 fa ff ff       	call   102dd0 <alloc_pages>
  103370:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103377:	75 1c                	jne    103395 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  103379:	c7 44 24 08 af 74 10 	movl   $0x1074af,0x8(%esp)
  103380:	00 
  103381:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  103388:	00 
  103389:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103390:	e8 64 d0 ff ff       	call   1003f9 <__panic>
    }
    return page2kva(p);
  103395:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103398:	89 04 24             	mov    %eax,(%esp)
  10339b:	e8 81 f7 ff ff       	call   102b21 <page2kva>
}
  1033a0:	c9                   	leave  
  1033a1:	c3                   	ret    

001033a2 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1033a2:	55                   	push   %ebp
  1033a3:	89 e5                	mov    %esp,%ebp
  1033a5:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1033a8:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1033ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033b0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1033b7:	77 23                	ja     1033dc <pmm_init+0x3a>
  1033b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1033c0:	c7 44 24 08 44 74 10 	movl   $0x107444,0x8(%esp)
  1033c7:	00 
  1033c8:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
  1033cf:	00 
  1033d0:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1033d7:	e8 1d d0 ff ff       	call   1003f9 <__panic>
  1033dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033df:	05 00 00 00 40       	add    $0x40000000,%eax
  1033e4:	a3 14 df 11 00       	mov    %eax,0x11df14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1033e9:	e8 8e f9 ff ff       	call   102d7c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1033ee:	e8 73 fa ff ff       	call   102e66 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1033f3:	e8 de 03 00 00       	call   1037d6 <check_alloc_page>

    check_pgdir();
  1033f8:	e8 f8 03 00 00       	call   1037f5 <check_pgdir>
    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    // 将当前内核页表的物理地址设置进对应的页目录项中(内核页表的自映射)
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1033fd:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103402:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103405:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10340c:	77 23                	ja     103431 <pmm_init+0x8f>
  10340e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103411:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103415:	c7 44 24 08 44 74 10 	movl   $0x107444,0x8(%esp)
  10341c:	00 
  10341d:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  103424:	00 
  103425:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  10342c:	e8 c8 cf ff ff       	call   1003f9 <__panic>
  103431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103434:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10343a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10343f:	05 ac 0f 00 00       	add    $0xfac,%eax
  103444:	83 ca 03             	or     $0x3,%edx
  103447:	89 10                	mov    %edx,(%eax)
    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    // 将内核所占用的物理内存，进行页表<->物理页的映射
    // 令处于高位虚拟内存空间的内核，正确的映射到低位的物理内存空间
    // (映射关系(虚实映射): 内核起始虚拟地址(KERNBASE)~内核截止虚拟地址(KERNBASE+KMEMSIZE) =  内核起始物理地址(0)~内核截止物理地址(KMEMSIZE))
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  103449:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10344e:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  103455:	00 
  103456:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10345d:	00 
  10345e:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  103465:	38 
  103466:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  10346d:	c0 
  10346e:	89 04 24             	mov    %eax,(%esp)
  103471:	e8 e5 fd ff ff       	call   10325b <boot_map_segment>
    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    // 重新设置GDT
    gdt_init();
  103476:	e8 18 f8 ff ff       	call   102c93 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10347b:	e8 29 0a 00 00       	call   103ea9 <check_boot_pgdir>

    print_pgdir();
  103480:	e8 a2 0e 00 00       	call   104327 <print_pgdir>

}
  103485:	90                   	nop
  103486:	c9                   	leave  
  103487:	c3                   	ret    

00103488 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103488:	55                   	push   %ebp
  103489:	89 e5                	mov    %esp,%ebp
  10348b:	83 ec 38             	sub    $0x38,%esp

PTE_U 0x004 表示可以读取对应地址的物理内存页内容
*/
    // PDX(la) 根据la的高10位获得对应的页目录项(一级页表中的某一项)索引(页目录项)
    // &pgdir[PDX(la)] 根据一级页表项索引从一级页表中找到对应的页目录项指针
    pde_t *pdep = &pgdir[PDX(la)];
  10348e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103491:	c1 e8 16             	shr    $0x16,%eax
  103494:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10349b:	8b 45 08             	mov    0x8(%ebp),%eax
  10349e:	01 d0                	add    %edx,%eax
  1034a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  1034a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034a6:	8b 00                	mov    (%eax),%eax
  1034a8:	83 e0 01             	and    $0x1,%eax
  1034ab:	85 c0                	test   %eax,%eax
  1034ad:	0f 85 af 00 00 00    	jne    103562 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  1034b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1034b7:	74 15                	je     1034ce <get_pte+0x46>
  1034b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034c0:	e8 0b f9 ff ff       	call   102dd0 <alloc_pages>
  1034c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1034cc:	75 0a                	jne    1034d8 <get_pte+0x50>
            return NULL;
  1034ce:	b8 00 00 00 00       	mov    $0x0,%eax
  1034d3:	e9 e7 00 00 00       	jmp    1035bf <get_pte+0x137>
        }
        // 二级页表所对应的物理页 引用数为1
        set_page_ref(page, 1);
  1034d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1034df:	00 
  1034e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034e3:	89 04 24             	mov    %eax,(%esp)
  1034e6:	e8 ea f6 ff ff       	call   102bd5 <set_page_ref>
        // 获得page变量的物理地址
        uintptr_t pa = page2pa(page);
  1034eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034ee:	89 04 24             	mov    %eax,(%esp)
  1034f1:	e8 c6 f5 ff ff       	call   102abc <page2pa>
  1034f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 将整个page所在的物理页格式胡，全部填满0
        memset(KADDR(pa), 0, PGSIZE);
  1034f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1034ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103502:	c1 e8 0c             	shr    $0xc,%eax
  103505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103508:	a1 80 de 11 00       	mov    0x11de80,%eax
  10350d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103510:	72 23                	jb     103535 <get_pte+0xad>
  103512:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103515:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103519:	c7 44 24 08 a0 73 10 	movl   $0x1073a0,0x8(%esp)
  103520:	00 
  103521:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
  103528:	00 
  103529:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103530:	e8 c4 ce ff ff       	call   1003f9 <__panic>
  103535:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103538:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10353d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103544:	00 
  103545:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10354c:	00 
  10354d:	89 04 24             	mov    %eax,(%esp)
  103550:	e8 c2 2e 00 00       	call   106417 <memset>
        // la对应的一级页目录项进行赋值，使其指向新创建的二级页表(页表中的数据被MMU直接处理，为了映射效率存放的都是物理地址)
        // 或PTE_U/PTE_W/PET_P 标识当前页目录项是用户级别的、可写的、已存在的
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  103555:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103558:	83 c8 07             	or     $0x7,%eax
  10355b:	89 c2                	mov    %eax,%edx
  10355d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103560:	89 10                	mov    %edx,(%eax)
    }
    // 要想通过C语言中的数组来访问对应数据，需要的是数组基址(虚拟地址),而*pdep中页目录表项中存放了对应二级页表的一个物理地址
    // PDE_ADDR将*pdep的低12位抹零对齐(指向二级页表的起始基地址)，再通过KADDR转为内核虚拟地址，进行数组访问
    // PTX(la)获得la线性地址的中间10位部分，即二级页表中对应页表项的索引下标。这样便能得到la对应的二级页表项了
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  103562:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103565:	8b 00                	mov    (%eax),%eax
  103567:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10356c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10356f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103572:	c1 e8 0c             	shr    $0xc,%eax
  103575:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103578:	a1 80 de 11 00       	mov    0x11de80,%eax
  10357d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103580:	72 23                	jb     1035a5 <get_pte+0x11d>
  103582:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103585:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103589:	c7 44 24 08 a0 73 10 	movl   $0x1073a0,0x8(%esp)
  103590:	00 
  103591:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
  103598:	00 
  103599:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1035a0:	e8 54 ce ff ff       	call   1003f9 <__panic>
  1035a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1035a8:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1035ad:	89 c2                	mov    %eax,%edx
  1035af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035b2:	c1 e8 0c             	shr    $0xc,%eax
  1035b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  1035ba:	c1 e0 02             	shl    $0x2,%eax
  1035bd:	01 d0                	add    %edx,%eax
}
  1035bf:	c9                   	leave  
  1035c0:	c3                   	ret    

001035c1 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1035c1:	55                   	push   %ebp
  1035c2:	89 e5                	mov    %esp,%ebp
  1035c4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1035c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035ce:	00 
  1035cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1035d9:	89 04 24             	mov    %eax,(%esp)
  1035dc:	e8 a7 fe ff ff       	call   103488 <get_pte>
  1035e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1035e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1035e8:	74 08                	je     1035f2 <get_page+0x31>
        *ptep_store = ptep;
  1035ea:	8b 45 10             	mov    0x10(%ebp),%eax
  1035ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1035f0:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1035f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1035f6:	74 1b                	je     103613 <get_page+0x52>
  1035f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035fb:	8b 00                	mov    (%eax),%eax
  1035fd:	83 e0 01             	and    $0x1,%eax
  103600:	85 c0                	test   %eax,%eax
  103602:	74 0f                	je     103613 <get_page+0x52>
        return pte2page(*ptep);
  103604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103607:	8b 00                	mov    (%eax),%eax
  103609:	89 04 24             	mov    %eax,(%esp)
  10360c:	e8 64 f5 ff ff       	call   102b75 <pte2page>
  103611:	eb 05                	jmp    103618 <get_page+0x57>
    }
    return NULL;
  103613:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103618:	c9                   	leave  
  103619:	c3                   	ret    

0010361a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10361a:	55                   	push   %ebp
  10361b:	89 e5                	mov    %esp,%ebp
  10361d:	83 ec 28             	sub    $0x28,%esp
                                  //(6) flush tlb
    }
#endif
        // 如果对应的二级页表项存在
        // 获得*ptep对应的Page结构
    if (*ptep & PTE_P) {
  103620:	8b 45 10             	mov    0x10(%ebp),%eax
  103623:	8b 00                	mov    (%eax),%eax
  103625:	83 e0 01             	and    $0x1,%eax
  103628:	85 c0                	test   %eax,%eax
  10362a:	74 4d                	je     103679 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  10362c:	8b 45 10             	mov    0x10(%ebp),%eax
  10362f:	8b 00                	mov    (%eax),%eax
  103631:	89 04 24             	mov    %eax,(%esp)
  103634:	e8 3c f5 ff ff       	call   102b75 <pte2page>
  103639:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  10363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10363f:	89 04 24             	mov    %eax,(%esp)
  103642:	e8 b3 f5 ff ff       	call   102bfa <page_ref_dec>
  103647:	85 c0                	test   %eax,%eax
  103649:	75 13                	jne    10365e <page_remove_pte+0x44>
            // 如果自减1后，引用数为0，需要free释放掉该物理页
            free_page(page);
  10364b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103652:	00 
  103653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103656:	89 04 24             	mov    %eax,(%esp)
  103659:	e8 aa f7 ff ff       	call   102e08 <free_pages>
        }
        // 清空当前二级页表项(整体设置为0)
        *ptep = 0;
  10365e:	8b 45 10             	mov    0x10(%ebp),%eax
  103661:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        // 由于页表项发生了改变，需要TLB快表
        tlb_invalidate(pgdir, la);
  103667:	8b 45 0c             	mov    0xc(%ebp),%eax
  10366a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10366e:	8b 45 08             	mov    0x8(%ebp),%eax
  103671:	89 04 24             	mov    %eax,(%esp)
  103674:	e8 01 01 00 00       	call   10377a <tlb_invalidate>
    }
}
  103679:	90                   	nop
  10367a:	c9                   	leave  
  10367b:	c3                   	ret    

0010367c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10367c:	55                   	push   %ebp
  10367d:	89 e5                	mov    %esp,%ebp
  10367f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103682:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103689:	00 
  10368a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10368d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103691:	8b 45 08             	mov    0x8(%ebp),%eax
  103694:	89 04 24             	mov    %eax,(%esp)
  103697:	e8 ec fd ff ff       	call   103488 <get_pte>
  10369c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  10369f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1036a3:	74 19                	je     1036be <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1036a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1036ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036af:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1036b6:	89 04 24             	mov    %eax,(%esp)
  1036b9:	e8 5c ff ff ff       	call   10361a <page_remove_pte>
    }
}
  1036be:	90                   	nop
  1036bf:	c9                   	leave  
  1036c0:	c3                   	ret    

001036c1 <page_insert>:
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
//指定一个新的page结构，来对应到这个页表；函数传入的page是想要映射的page结构，而函数中的p，则是这个页表现有的对应的page结构，
//所以函数中有一个判断p==page的语句
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1036c1:	55                   	push   %ebp
  1036c2:	89 e5                	mov    %esp,%ebp
  1036c4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1036c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1036ce:	00 
  1036cf:	8b 45 10             	mov    0x10(%ebp),%eax
  1036d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1036d9:	89 04 24             	mov    %eax,(%esp)
  1036dc:	e8 a7 fd ff ff       	call   103488 <get_pte>
  1036e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1036e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1036e8:	75 0a                	jne    1036f4 <page_insert+0x33>
        return -E_NO_MEM;
  1036ea:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1036ef:	e9 84 00 00 00       	jmp    103778 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1036f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036f7:	89 04 24             	mov    %eax,(%esp)
  1036fa:	e8 e4 f4 ff ff       	call   102be3 <page_ref_inc>
    if (*ptep & PTE_P) {
  1036ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103702:	8b 00                	mov    (%eax),%eax
  103704:	83 e0 01             	and    $0x1,%eax
  103707:	85 c0                	test   %eax,%eax
  103709:	74 3e                	je     103749 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10370b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10370e:	8b 00                	mov    (%eax),%eax
  103710:	89 04 24             	mov    %eax,(%esp)
  103713:	e8 5d f4 ff ff       	call   102b75 <pte2page>
  103718:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10371b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10371e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103721:	75 0d                	jne    103730 <page_insert+0x6f>
            page_ref_dec(page);
  103723:	8b 45 0c             	mov    0xc(%ebp),%eax
  103726:	89 04 24             	mov    %eax,(%esp)
  103729:	e8 cc f4 ff ff       	call   102bfa <page_ref_dec>
  10372e:	eb 19                	jmp    103749 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  103730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103733:	89 44 24 08          	mov    %eax,0x8(%esp)
  103737:	8b 45 10             	mov    0x10(%ebp),%eax
  10373a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10373e:	8b 45 08             	mov    0x8(%ebp),%eax
  103741:	89 04 24             	mov    %eax,(%esp)
  103744:	e8 d1 fe ff ff       	call   10361a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103749:	8b 45 0c             	mov    0xc(%ebp),%eax
  10374c:	89 04 24             	mov    %eax,(%esp)
  10374f:	e8 68 f3 ff ff       	call   102abc <page2pa>
  103754:	0b 45 14             	or     0x14(%ebp),%eax
  103757:	83 c8 01             	or     $0x1,%eax
  10375a:	89 c2                	mov    %eax,%edx
  10375c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10375f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  103761:	8b 45 10             	mov    0x10(%ebp),%eax
  103764:	89 44 24 04          	mov    %eax,0x4(%esp)
  103768:	8b 45 08             	mov    0x8(%ebp),%eax
  10376b:	89 04 24             	mov    %eax,(%esp)
  10376e:	e8 07 00 00 00       	call   10377a <tlb_invalidate>
    return 0;
  103773:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103778:	c9                   	leave  
  103779:	c3                   	ret    

0010377a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10377a:	55                   	push   %ebp
  10377b:	89 e5                	mov    %esp,%ebp
  10377d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103780:	0f 20 d8             	mov    %cr3,%eax
  103783:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  103786:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  103789:	8b 45 08             	mov    0x8(%ebp),%eax
  10378c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10378f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103796:	77 23                	ja     1037bb <tlb_invalidate+0x41>
  103798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10379b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10379f:	c7 44 24 08 44 74 10 	movl   $0x107444,0x8(%esp)
  1037a6:	00 
  1037a7:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  1037ae:	00 
  1037af:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1037b6:	e8 3e cc ff ff       	call   1003f9 <__panic>
  1037bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037be:	05 00 00 00 40       	add    $0x40000000,%eax
  1037c3:	39 d0                	cmp    %edx,%eax
  1037c5:	75 0c                	jne    1037d3 <tlb_invalidate+0x59>
        invlpg((void *)la);
  1037c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1037cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037d0:	0f 01 38             	invlpg (%eax)
    }
}
  1037d3:	90                   	nop
  1037d4:	c9                   	leave  
  1037d5:	c3                   	ret    

001037d6 <check_alloc_page>:

static void
check_alloc_page(void) {
  1037d6:	55                   	push   %ebp
  1037d7:	89 e5                	mov    %esp,%ebp
  1037d9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1037dc:	a1 10 df 11 00       	mov    0x11df10,%eax
  1037e1:	8b 40 18             	mov    0x18(%eax),%eax
  1037e4:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1037e6:	c7 04 24 c8 74 10 00 	movl   $0x1074c8,(%esp)
  1037ed:	e8 b0 ca ff ff       	call   1002a2 <cprintf>
}
  1037f2:	90                   	nop
  1037f3:	c9                   	leave  
  1037f4:	c3                   	ret    

001037f5 <check_pgdir>:

static void
check_pgdir(void) {
  1037f5:	55                   	push   %ebp
  1037f6:	89 e5                	mov    %esp,%ebp
  1037f8:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1037fb:	a1 80 de 11 00       	mov    0x11de80,%eax
  103800:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103805:	76 24                	jbe    10382b <check_pgdir+0x36>
  103807:	c7 44 24 0c e7 74 10 	movl   $0x1074e7,0xc(%esp)
  10380e:	00 
  10380f:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103816:	00 
  103817:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  10381e:	00 
  10381f:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103826:	e8 ce cb ff ff       	call   1003f9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10382b:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103830:	85 c0                	test   %eax,%eax
  103832:	74 0e                	je     103842 <check_pgdir+0x4d>
  103834:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103839:	25 ff 0f 00 00       	and    $0xfff,%eax
  10383e:	85 c0                	test   %eax,%eax
  103840:	74 24                	je     103866 <check_pgdir+0x71>
  103842:	c7 44 24 0c 04 75 10 	movl   $0x107504,0xc(%esp)
  103849:	00 
  10384a:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103851:	00 
  103852:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  103859:	00 
  10385a:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103861:	e8 93 cb ff ff       	call   1003f9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103866:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10386b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103872:	00 
  103873:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10387a:	00 
  10387b:	89 04 24             	mov    %eax,(%esp)
  10387e:	e8 3e fd ff ff       	call   1035c1 <get_page>
  103883:	85 c0                	test   %eax,%eax
  103885:	74 24                	je     1038ab <check_pgdir+0xb6>
  103887:	c7 44 24 0c 3c 75 10 	movl   $0x10753c,0xc(%esp)
  10388e:	00 
  10388f:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103896:	00 
  103897:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  10389e:	00 
  10389f:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1038a6:	e8 4e cb ff ff       	call   1003f9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1038ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038b2:	e8 19 f5 ff ff       	call   102dd0 <alloc_pages>
  1038b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("allocate p1 succeed!\n");
  1038ba:	c7 04 24 64 75 10 00 	movl   $0x107564,(%esp)
  1038c1:	e8 dc c9 ff ff       	call   1002a2 <cprintf>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1038c6:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1038cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1038d2:	00 
  1038d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038da:	00 
  1038db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1038de:	89 54 24 04          	mov    %edx,0x4(%esp)
  1038e2:	89 04 24             	mov    %eax,(%esp)
  1038e5:	e8 d7 fd ff ff       	call   1036c1 <page_insert>
  1038ea:	85 c0                	test   %eax,%eax
  1038ec:	74 24                	je     103912 <check_pgdir+0x11d>
  1038ee:	c7 44 24 0c 7c 75 10 	movl   $0x10757c,0xc(%esp)
  1038f5:	00 
  1038f6:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  1038fd:	00 
  1038fe:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  103905:	00 
  103906:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  10390d:	e8 e7 ca ff ff       	call   1003f9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103912:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103917:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10391e:	00 
  10391f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103926:	00 
  103927:	89 04 24             	mov    %eax,(%esp)
  10392a:	e8 59 fb ff ff       	call   103488 <get_pte>
  10392f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103936:	75 24                	jne    10395c <check_pgdir+0x167>
  103938:	c7 44 24 0c a8 75 10 	movl   $0x1075a8,0xc(%esp)
  10393f:	00 
  103940:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103947:	00 
  103948:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  10394f:	00 
  103950:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103957:	e8 9d ca ff ff       	call   1003f9 <__panic>
    assert(pte2page(*ptep) == p1);
  10395c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10395f:	8b 00                	mov    (%eax),%eax
  103961:	89 04 24             	mov    %eax,(%esp)
  103964:	e8 0c f2 ff ff       	call   102b75 <pte2page>
  103969:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10396c:	74 24                	je     103992 <check_pgdir+0x19d>
  10396e:	c7 44 24 0c d5 75 10 	movl   $0x1075d5,0xc(%esp)
  103975:	00 
  103976:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  10397d:	00 
  10397e:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103985:	00 
  103986:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  10398d:	e8 67 ca ff ff       	call   1003f9 <__panic>
    assert(page_ref(p1) == 1);
  103992:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103995:	89 04 24             	mov    %eax,(%esp)
  103998:	e8 2e f2 ff ff       	call   102bcb <page_ref>
  10399d:	83 f8 01             	cmp    $0x1,%eax
  1039a0:	74 24                	je     1039c6 <check_pgdir+0x1d1>
  1039a2:	c7 44 24 0c eb 75 10 	movl   $0x1075eb,0xc(%esp)
  1039a9:	00 
  1039aa:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  1039b1:	00 
  1039b2:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
  1039b9:	00 
  1039ba:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1039c1:	e8 33 ca ff ff       	call   1003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1039c6:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1039cb:	8b 00                	mov    (%eax),%eax
  1039cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1039d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1039d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039d8:	c1 e8 0c             	shr    $0xc,%eax
  1039db:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1039de:	a1 80 de 11 00       	mov    0x11de80,%eax
  1039e3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1039e6:	72 23                	jb     103a0b <check_pgdir+0x216>
  1039e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1039ef:	c7 44 24 08 a0 73 10 	movl   $0x1073a0,0x8(%esp)
  1039f6:	00 
  1039f7:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
  1039fe:	00 
  1039ff:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103a06:	e8 ee c9 ff ff       	call   1003f9 <__panic>
  103a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a0e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103a13:	83 c0 04             	add    $0x4,%eax
  103a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  103a19:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a25:	00 
  103a26:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a2d:	00 
  103a2e:	89 04 24             	mov    %eax,(%esp)
  103a31:	e8 52 fa ff ff       	call   103488 <get_pte>
  103a36:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103a39:	74 24                	je     103a5f <check_pgdir+0x26a>
  103a3b:	c7 44 24 0c 00 76 10 	movl   $0x107600,0xc(%esp)
  103a42:	00 
  103a43:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103a4a:	00 
  103a4b:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  103a52:	00 
  103a53:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103a5a:	e8 9a c9 ff ff       	call   1003f9 <__panic>

    p2 = alloc_page();
  103a5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103a66:	e8 65 f3 ff ff       	call   102dd0 <alloc_pages>
  103a6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("allocate p2 succeed!\n");
  103a6e:	c7 04 24 27 76 10 00 	movl   $0x107627,(%esp)
  103a75:	e8 28 c8 ff ff       	call   1002a2 <cprintf>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103a7a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a7f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103a86:	00 
  103a87:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103a8e:	00 
  103a8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103a92:	89 54 24 04          	mov    %edx,0x4(%esp)
  103a96:	89 04 24             	mov    %eax,(%esp)
  103a99:	e8 23 fc ff ff       	call   1036c1 <page_insert>
  103a9e:	85 c0                	test   %eax,%eax
  103aa0:	74 24                	je     103ac6 <check_pgdir+0x2d1>
  103aa2:	c7 44 24 0c 40 76 10 	movl   $0x107640,0xc(%esp)
  103aa9:	00 
  103aaa:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103ab1:	00 
  103ab2:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  103ab9:	00 
  103aba:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103ac1:	e8 33 c9 ff ff       	call   1003f9 <__panic>
    
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103ac6:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103acb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103ad2:	00 
  103ad3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103ada:	00 
  103adb:	89 04 24             	mov    %eax,(%esp)
  103ade:	e8 a5 f9 ff ff       	call   103488 <get_pte>
  103ae3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ae6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103aea:	75 24                	jne    103b10 <check_pgdir+0x31b>
  103aec:	c7 44 24 0c 78 76 10 	movl   $0x107678,0xc(%esp)
  103af3:	00 
  103af4:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103afb:	00 
  103afc:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
  103b03:	00 
  103b04:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103b0b:	e8 e9 c8 ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_U);
  103b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b13:	8b 00                	mov    (%eax),%eax
  103b15:	83 e0 04             	and    $0x4,%eax
  103b18:	85 c0                	test   %eax,%eax
  103b1a:	75 24                	jne    103b40 <check_pgdir+0x34b>
  103b1c:	c7 44 24 0c a8 76 10 	movl   $0x1076a8,0xc(%esp)
  103b23:	00 
  103b24:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103b2b:	00 
  103b2c:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  103b33:	00 
  103b34:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103b3b:	e8 b9 c8 ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_W);
  103b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b43:	8b 00                	mov    (%eax),%eax
  103b45:	83 e0 02             	and    $0x2,%eax
  103b48:	85 c0                	test   %eax,%eax
  103b4a:	75 24                	jne    103b70 <check_pgdir+0x37b>
  103b4c:	c7 44 24 0c b6 76 10 	movl   $0x1076b6,0xc(%esp)
  103b53:	00 
  103b54:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103b5b:	00 
  103b5c:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
  103b63:	00 
  103b64:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103b6b:	e8 89 c8 ff ff       	call   1003f9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103b70:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103b75:	8b 00                	mov    (%eax),%eax
  103b77:	83 e0 04             	and    $0x4,%eax
  103b7a:	85 c0                	test   %eax,%eax
  103b7c:	75 24                	jne    103ba2 <check_pgdir+0x3ad>
  103b7e:	c7 44 24 0c c4 76 10 	movl   $0x1076c4,0xc(%esp)
  103b85:	00 
  103b86:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103b8d:	00 
  103b8e:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
  103b95:	00 
  103b96:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103b9d:	e8 57 c8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 1);
  103ba2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ba5:	89 04 24             	mov    %eax,(%esp)
  103ba8:	e8 1e f0 ff ff       	call   102bcb <page_ref>
  103bad:	83 f8 01             	cmp    $0x1,%eax
  103bb0:	74 24                	je     103bd6 <check_pgdir+0x3e1>
  103bb2:	c7 44 24 0c da 76 10 	movl   $0x1076da,0xc(%esp)
  103bb9:	00 
  103bba:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103bc1:	00 
  103bc2:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
  103bc9:	00 
  103bca:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103bd1:	e8 23 c8 ff ff       	call   1003f9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103bd6:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103bdb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103be2:	00 
  103be3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103bea:	00 
  103beb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103bee:	89 54 24 04          	mov    %edx,0x4(%esp)
  103bf2:	89 04 24             	mov    %eax,(%esp)
  103bf5:	e8 c7 fa ff ff       	call   1036c1 <page_insert>
  103bfa:	85 c0                	test   %eax,%eax
  103bfc:	74 24                	je     103c22 <check_pgdir+0x42d>
  103bfe:	c7 44 24 0c ec 76 10 	movl   $0x1076ec,0xc(%esp)
  103c05:	00 
  103c06:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103c0d:	00 
  103c0e:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  103c15:	00 
  103c16:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103c1d:	e8 d7 c7 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p1) == 2);
  103c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c25:	89 04 24             	mov    %eax,(%esp)
  103c28:	e8 9e ef ff ff       	call   102bcb <page_ref>
  103c2d:	83 f8 02             	cmp    $0x2,%eax
  103c30:	74 24                	je     103c56 <check_pgdir+0x461>
  103c32:	c7 44 24 0c 18 77 10 	movl   $0x107718,0xc(%esp)
  103c39:	00 
  103c3a:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103c41:	00 
  103c42:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
  103c49:	00 
  103c4a:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103c51:	e8 a3 c7 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c59:	89 04 24             	mov    %eax,(%esp)
  103c5c:	e8 6a ef ff ff       	call   102bcb <page_ref>
  103c61:	85 c0                	test   %eax,%eax
  103c63:	74 24                	je     103c89 <check_pgdir+0x494>
  103c65:	c7 44 24 0c 2a 77 10 	movl   $0x10772a,0xc(%esp)
  103c6c:	00 
  103c6d:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103c74:	00 
  103c75:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
  103c7c:	00 
  103c7d:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103c84:	e8 70 c7 ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103c89:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103c8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103c95:	00 
  103c96:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103c9d:	00 
  103c9e:	89 04 24             	mov    %eax,(%esp)
  103ca1:	e8 e2 f7 ff ff       	call   103488 <get_pte>
  103ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103ca9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103cad:	75 24                	jne    103cd3 <check_pgdir+0x4de>
  103caf:	c7 44 24 0c 78 76 10 	movl   $0x107678,0xc(%esp)
  103cb6:	00 
  103cb7:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103cbe:	00 
  103cbf:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
  103cc6:	00 
  103cc7:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103cce:	e8 26 c7 ff ff       	call   1003f9 <__panic>
    assert(pte2page(*ptep) == p1);
  103cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cd6:	8b 00                	mov    (%eax),%eax
  103cd8:	89 04 24             	mov    %eax,(%esp)
  103cdb:	e8 95 ee ff ff       	call   102b75 <pte2page>
  103ce0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103ce3:	74 24                	je     103d09 <check_pgdir+0x514>
  103ce5:	c7 44 24 0c d5 75 10 	movl   $0x1075d5,0xc(%esp)
  103cec:	00 
  103ced:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103cf4:	00 
  103cf5:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
  103cfc:	00 
  103cfd:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103d04:	e8 f0 c6 ff ff       	call   1003f9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d0c:	8b 00                	mov    (%eax),%eax
  103d0e:	83 e0 04             	and    $0x4,%eax
  103d11:	85 c0                	test   %eax,%eax
  103d13:	74 24                	je     103d39 <check_pgdir+0x544>
  103d15:	c7 44 24 0c 3c 77 10 	movl   $0x10773c,0xc(%esp)
  103d1c:	00 
  103d1d:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103d24:	00 
  103d25:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
  103d2c:	00 
  103d2d:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103d34:	e8 c0 c6 ff ff       	call   1003f9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103d39:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103d3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103d45:	00 
  103d46:	89 04 24             	mov    %eax,(%esp)
  103d49:	e8 2e f9 ff ff       	call   10367c <page_remove>
    assert(page_ref(p1) == 1);
  103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d51:	89 04 24             	mov    %eax,(%esp)
  103d54:	e8 72 ee ff ff       	call   102bcb <page_ref>
  103d59:	83 f8 01             	cmp    $0x1,%eax
  103d5c:	74 24                	je     103d82 <check_pgdir+0x58d>
  103d5e:	c7 44 24 0c eb 75 10 	movl   $0x1075eb,0xc(%esp)
  103d65:	00 
  103d66:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103d6d:	00 
  103d6e:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
  103d75:	00 
  103d76:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103d7d:	e8 77 c6 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d85:	89 04 24             	mov    %eax,(%esp)
  103d88:	e8 3e ee ff ff       	call   102bcb <page_ref>
  103d8d:	85 c0                	test   %eax,%eax
  103d8f:	74 24                	je     103db5 <check_pgdir+0x5c0>
  103d91:	c7 44 24 0c 2a 77 10 	movl   $0x10772a,0xc(%esp)
  103d98:	00 
  103d99:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103da0:	00 
  103da1:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
  103da8:	00 
  103da9:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103db0:	e8 44 c6 ff ff       	call   1003f9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103db5:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103dba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103dc1:	00 
  103dc2:	89 04 24             	mov    %eax,(%esp)
  103dc5:	e8 b2 f8 ff ff       	call   10367c <page_remove>
    assert(page_ref(p1) == 0);
  103dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103dcd:	89 04 24             	mov    %eax,(%esp)
  103dd0:	e8 f6 ed ff ff       	call   102bcb <page_ref>
  103dd5:	85 c0                	test   %eax,%eax
  103dd7:	74 24                	je     103dfd <check_pgdir+0x608>
  103dd9:	c7 44 24 0c 51 77 10 	movl   $0x107751,0xc(%esp)
  103de0:	00 
  103de1:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103de8:	00 
  103de9:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
  103df0:	00 
  103df1:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103df8:	e8 fc c5 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103dfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e00:	89 04 24             	mov    %eax,(%esp)
  103e03:	e8 c3 ed ff ff       	call   102bcb <page_ref>
  103e08:	85 c0                	test   %eax,%eax
  103e0a:	74 24                	je     103e30 <check_pgdir+0x63b>
  103e0c:	c7 44 24 0c 2a 77 10 	movl   $0x10772a,0xc(%esp)
  103e13:	00 
  103e14:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103e1b:	00 
  103e1c:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
  103e23:	00 
  103e24:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103e2b:	e8 c9 c5 ff ff       	call   1003f9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103e30:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103e35:	8b 00                	mov    (%eax),%eax
  103e37:	89 04 24             	mov    %eax,(%esp)
  103e3a:	e8 74 ed ff ff       	call   102bb3 <pde2page>
  103e3f:	89 04 24             	mov    %eax,(%esp)
  103e42:	e8 84 ed ff ff       	call   102bcb <page_ref>
  103e47:	83 f8 01             	cmp    $0x1,%eax
  103e4a:	74 24                	je     103e70 <check_pgdir+0x67b>
  103e4c:	c7 44 24 0c 64 77 10 	movl   $0x107764,0xc(%esp)
  103e53:	00 
  103e54:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103e5b:	00 
  103e5c:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
  103e63:	00 
  103e64:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103e6b:	e8 89 c5 ff ff       	call   1003f9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103e70:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103e75:	8b 00                	mov    (%eax),%eax
  103e77:	89 04 24             	mov    %eax,(%esp)
  103e7a:	e8 34 ed ff ff       	call   102bb3 <pde2page>
  103e7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e86:	00 
  103e87:	89 04 24             	mov    %eax,(%esp)
  103e8a:	e8 79 ef ff ff       	call   102e08 <free_pages>
    boot_pgdir[0] = 0;
  103e8f:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103e94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103e9a:	c7 04 24 8b 77 10 00 	movl   $0x10778b,(%esp)
  103ea1:	e8 fc c3 ff ff       	call   1002a2 <cprintf>
}
  103ea6:	90                   	nop
  103ea7:	c9                   	leave  
  103ea8:	c3                   	ret    

00103ea9 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103ea9:	55                   	push   %ebp
  103eaa:	89 e5                	mov    %esp,%ebp
  103eac:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103eaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103eb6:	e9 ca 00 00 00       	jmp    103f85 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ebe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103ec1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ec4:	c1 e8 0c             	shr    $0xc,%eax
  103ec7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103eca:	a1 80 de 11 00       	mov    0x11de80,%eax
  103ecf:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103ed2:	72 23                	jb     103ef7 <check_boot_pgdir+0x4e>
  103ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103edb:	c7 44 24 08 a0 73 10 	movl   $0x1073a0,0x8(%esp)
  103ee2:	00 
  103ee3:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
  103eea:	00 
  103eeb:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103ef2:	e8 02 c5 ff ff       	call   1003f9 <__panic>
  103ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103efa:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103eff:	89 c2                	mov    %eax,%edx
  103f01:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103f06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103f0d:	00 
  103f0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f12:	89 04 24             	mov    %eax,(%esp)
  103f15:	e8 6e f5 ff ff       	call   103488 <get_pte>
  103f1a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103f1d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103f21:	75 24                	jne    103f47 <check_boot_pgdir+0x9e>
  103f23:	c7 44 24 0c a8 77 10 	movl   $0x1077a8,0xc(%esp)
  103f2a:	00 
  103f2b:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103f32:	00 
  103f33:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
  103f3a:	00 
  103f3b:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103f42:	e8 b2 c4 ff ff       	call   1003f9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103f47:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103f4a:	8b 00                	mov    (%eax),%eax
  103f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103f51:	89 c2                	mov    %eax,%edx
  103f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f56:	39 c2                	cmp    %eax,%edx
  103f58:	74 24                	je     103f7e <check_boot_pgdir+0xd5>
  103f5a:	c7 44 24 0c e5 77 10 	movl   $0x1077e5,0xc(%esp)
  103f61:	00 
  103f62:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103f69:	00 
  103f6a:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
  103f71:	00 
  103f72:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103f79:	e8 7b c4 ff ff       	call   1003f9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103f7e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103f85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103f88:	a1 80 de 11 00       	mov    0x11de80,%eax
  103f8d:	39 c2                	cmp    %eax,%edx
  103f8f:	0f 82 26 ff ff ff    	jb     103ebb <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103f95:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103f9a:	05 ac 0f 00 00       	add    $0xfac,%eax
  103f9f:	8b 00                	mov    (%eax),%eax
  103fa1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103fa6:	89 c2                	mov    %eax,%edx
  103fa8:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103fad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103fb0:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103fb7:	77 23                	ja     103fdc <check_boot_pgdir+0x133>
  103fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103fbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103fc0:	c7 44 24 08 44 74 10 	movl   $0x107444,0x8(%esp)
  103fc7:	00 
  103fc8:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
  103fcf:	00 
  103fd0:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  103fd7:	e8 1d c4 ff ff       	call   1003f9 <__panic>
  103fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103fdf:	05 00 00 00 40       	add    $0x40000000,%eax
  103fe4:	39 d0                	cmp    %edx,%eax
  103fe6:	74 24                	je     10400c <check_boot_pgdir+0x163>
  103fe8:	c7 44 24 0c fc 77 10 	movl   $0x1077fc,0xc(%esp)
  103fef:	00 
  103ff0:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  103ff7:	00 
  103ff8:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
  103fff:	00 
  104000:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  104007:	e8 ed c3 ff ff       	call   1003f9 <__panic>

    assert(boot_pgdir[0] == 0);
  10400c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  104011:	8b 00                	mov    (%eax),%eax
  104013:	85 c0                	test   %eax,%eax
  104015:	74 24                	je     10403b <check_boot_pgdir+0x192>
  104017:	c7 44 24 0c 30 78 10 	movl   $0x107830,0xc(%esp)
  10401e:	00 
  10401f:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  104026:	00 
  104027:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
  10402e:	00 
  10402f:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  104036:	e8 be c3 ff ff       	call   1003f9 <__panic>

    struct Page *p;
    p = alloc_page();
  10403b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104042:	e8 89 ed ff ff       	call   102dd0 <alloc_pages>
  104047:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10404a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10404f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104056:	00 
  104057:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  10405e:	00 
  10405f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104062:	89 54 24 04          	mov    %edx,0x4(%esp)
  104066:	89 04 24             	mov    %eax,(%esp)
  104069:	e8 53 f6 ff ff       	call   1036c1 <page_insert>
  10406e:	85 c0                	test   %eax,%eax
  104070:	74 24                	je     104096 <check_boot_pgdir+0x1ed>
  104072:	c7 44 24 0c 44 78 10 	movl   $0x107844,0xc(%esp)
  104079:	00 
  10407a:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  104081:	00 
  104082:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
  104089:	00 
  10408a:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  104091:	e8 63 c3 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p) == 1);
  104096:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104099:	89 04 24             	mov    %eax,(%esp)
  10409c:	e8 2a eb ff ff       	call   102bcb <page_ref>
  1040a1:	83 f8 01             	cmp    $0x1,%eax
  1040a4:	74 24                	je     1040ca <check_boot_pgdir+0x221>
  1040a6:	c7 44 24 0c 72 78 10 	movl   $0x107872,0xc(%esp)
  1040ad:	00 
  1040ae:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  1040b5:	00 
  1040b6:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
  1040bd:	00 
  1040be:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1040c5:	e8 2f c3 ff ff       	call   1003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1040ca:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1040cf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1040d6:	00 
  1040d7:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  1040de:	00 
  1040df:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1040e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1040e6:	89 04 24             	mov    %eax,(%esp)
  1040e9:	e8 d3 f5 ff ff       	call   1036c1 <page_insert>
  1040ee:	85 c0                	test   %eax,%eax
  1040f0:	74 24                	je     104116 <check_boot_pgdir+0x26d>
  1040f2:	c7 44 24 0c 84 78 10 	movl   $0x107884,0xc(%esp)
  1040f9:	00 
  1040fa:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  104101:	00 
  104102:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
  104109:	00 
  10410a:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  104111:	e8 e3 c2 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p) == 2);
  104116:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104119:	89 04 24             	mov    %eax,(%esp)
  10411c:	e8 aa ea ff ff       	call   102bcb <page_ref>
  104121:	83 f8 02             	cmp    $0x2,%eax
  104124:	74 24                	je     10414a <check_boot_pgdir+0x2a1>
  104126:	c7 44 24 0c bb 78 10 	movl   $0x1078bb,0xc(%esp)
  10412d:	00 
  10412e:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  104135:	00 
  104136:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
  10413d:	00 
  10413e:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  104145:	e8 af c2 ff ff       	call   1003f9 <__panic>

    const char *str = "ucore: Hello world!!";
  10414a:	c7 45 e8 cc 78 10 00 	movl   $0x1078cc,-0x18(%ebp)
    strcpy((void *)0x100, str);
  104151:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104154:	89 44 24 04          	mov    %eax,0x4(%esp)
  104158:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10415f:	e8 e9 1f 00 00       	call   10614d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  104164:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  10416b:	00 
  10416c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104173:	e8 4c 20 00 00       	call   1061c4 <strcmp>
  104178:	85 c0                	test   %eax,%eax
  10417a:	74 24                	je     1041a0 <check_boot_pgdir+0x2f7>
  10417c:	c7 44 24 0c e4 78 10 	movl   $0x1078e4,0xc(%esp)
  104183:	00 
  104184:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  10418b:	00 
  10418c:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
  104193:	00 
  104194:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  10419b:	e8 59 c2 ff ff       	call   1003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1041a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1041a3:	89 04 24             	mov    %eax,(%esp)
  1041a6:	e8 76 e9 ff ff       	call   102b21 <page2kva>
  1041ab:	05 00 01 00 00       	add    $0x100,%eax
  1041b0:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1041b3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1041ba:	e8 38 1f 00 00       	call   1060f7 <strlen>
  1041bf:	85 c0                	test   %eax,%eax
  1041c1:	74 24                	je     1041e7 <check_boot_pgdir+0x33e>
  1041c3:	c7 44 24 0c 1c 79 10 	movl   $0x10791c,0xc(%esp)
  1041ca:	00 
  1041cb:	c7 44 24 08 8d 74 10 	movl   $0x10748d,0x8(%esp)
  1041d2:	00 
  1041d3:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
  1041da:	00 
  1041db:	c7 04 24 68 74 10 00 	movl   $0x107468,(%esp)
  1041e2:	e8 12 c2 ff ff       	call   1003f9 <__panic>

    free_page(p);
  1041e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1041ee:	00 
  1041ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1041f2:	89 04 24             	mov    %eax,(%esp)
  1041f5:	e8 0e ec ff ff       	call   102e08 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  1041fa:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1041ff:	8b 00                	mov    (%eax),%eax
  104201:	89 04 24             	mov    %eax,(%esp)
  104204:	e8 aa e9 ff ff       	call   102bb3 <pde2page>
  104209:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104210:	00 
  104211:	89 04 24             	mov    %eax,(%esp)
  104214:	e8 ef eb ff ff       	call   102e08 <free_pages>
    boot_pgdir[0] = 0;
  104219:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10421e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  104224:	c7 04 24 40 79 10 00 	movl   $0x107940,(%esp)
  10422b:	e8 72 c0 ff ff       	call   1002a2 <cprintf>
}
  104230:	90                   	nop
  104231:	c9                   	leave  
  104232:	c3                   	ret    

00104233 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  104233:	55                   	push   %ebp
  104234:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  104236:	8b 45 08             	mov    0x8(%ebp),%eax
  104239:	83 e0 04             	and    $0x4,%eax
  10423c:	85 c0                	test   %eax,%eax
  10423e:	74 04                	je     104244 <perm2str+0x11>
  104240:	b0 75                	mov    $0x75,%al
  104242:	eb 02                	jmp    104246 <perm2str+0x13>
  104244:	b0 2d                	mov    $0x2d,%al
  104246:	a2 08 df 11 00       	mov    %al,0x11df08
    str[1] = 'r';
  10424b:	c6 05 09 df 11 00 72 	movb   $0x72,0x11df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  104252:	8b 45 08             	mov    0x8(%ebp),%eax
  104255:	83 e0 02             	and    $0x2,%eax
  104258:	85 c0                	test   %eax,%eax
  10425a:	74 04                	je     104260 <perm2str+0x2d>
  10425c:	b0 77                	mov    $0x77,%al
  10425e:	eb 02                	jmp    104262 <perm2str+0x2f>
  104260:	b0 2d                	mov    $0x2d,%al
  104262:	a2 0a df 11 00       	mov    %al,0x11df0a
    str[3] = '\0';
  104267:	c6 05 0b df 11 00 00 	movb   $0x0,0x11df0b
    return str;
  10426e:	b8 08 df 11 00       	mov    $0x11df08,%eax
}
  104273:	5d                   	pop    %ebp
  104274:	c3                   	ret    

00104275 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  104275:	55                   	push   %ebp
  104276:	89 e5                	mov    %esp,%ebp
  104278:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10427b:	8b 45 10             	mov    0x10(%ebp),%eax
  10427e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104281:	72 0d                	jb     104290 <get_pgtable_items+0x1b>
        return 0;
  104283:	b8 00 00 00 00       	mov    $0x0,%eax
  104288:	e9 98 00 00 00       	jmp    104325 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  10428d:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  104290:	8b 45 10             	mov    0x10(%ebp),%eax
  104293:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104296:	73 18                	jae    1042b0 <get_pgtable_items+0x3b>
  104298:	8b 45 10             	mov    0x10(%ebp),%eax
  10429b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1042a2:	8b 45 14             	mov    0x14(%ebp),%eax
  1042a5:	01 d0                	add    %edx,%eax
  1042a7:	8b 00                	mov    (%eax),%eax
  1042a9:	83 e0 01             	and    $0x1,%eax
  1042ac:	85 c0                	test   %eax,%eax
  1042ae:	74 dd                	je     10428d <get_pgtable_items+0x18>
    }
    if (start < right) {
  1042b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1042b3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1042b6:	73 68                	jae    104320 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  1042b8:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1042bc:	74 08                	je     1042c6 <get_pgtable_items+0x51>
            *left_store = start;
  1042be:	8b 45 18             	mov    0x18(%ebp),%eax
  1042c1:	8b 55 10             	mov    0x10(%ebp),%edx
  1042c4:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1042c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1042c9:	8d 50 01             	lea    0x1(%eax),%edx
  1042cc:	89 55 10             	mov    %edx,0x10(%ebp)
  1042cf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1042d6:	8b 45 14             	mov    0x14(%ebp),%eax
  1042d9:	01 d0                	add    %edx,%eax
  1042db:	8b 00                	mov    (%eax),%eax
  1042dd:	83 e0 07             	and    $0x7,%eax
  1042e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1042e3:	eb 03                	jmp    1042e8 <get_pgtable_items+0x73>
            start ++;
  1042e5:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1042e8:	8b 45 10             	mov    0x10(%ebp),%eax
  1042eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1042ee:	73 1d                	jae    10430d <get_pgtable_items+0x98>
  1042f0:	8b 45 10             	mov    0x10(%ebp),%eax
  1042f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1042fa:	8b 45 14             	mov    0x14(%ebp),%eax
  1042fd:	01 d0                	add    %edx,%eax
  1042ff:	8b 00                	mov    (%eax),%eax
  104301:	83 e0 07             	and    $0x7,%eax
  104304:	89 c2                	mov    %eax,%edx
  104306:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104309:	39 c2                	cmp    %eax,%edx
  10430b:	74 d8                	je     1042e5 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  10430d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104311:	74 08                	je     10431b <get_pgtable_items+0xa6>
            *right_store = start;
  104313:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104316:	8b 55 10             	mov    0x10(%ebp),%edx
  104319:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  10431b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10431e:	eb 05                	jmp    104325 <get_pgtable_items+0xb0>
    }
    return 0;
  104320:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104325:	c9                   	leave  
  104326:	c3                   	ret    

00104327 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  104327:	55                   	push   %ebp
  104328:	89 e5                	mov    %esp,%ebp
  10432a:	57                   	push   %edi
  10432b:	56                   	push   %esi
  10432c:	53                   	push   %ebx
  10432d:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  104330:	c7 04 24 60 79 10 00 	movl   $0x107960,(%esp)
  104337:	e8 66 bf ff ff       	call   1002a2 <cprintf>
    size_t left, right = 0, perm;
  10433c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104343:	e9 fa 00 00 00       	jmp    104442 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10434b:	89 04 24             	mov    %eax,(%esp)
  10434e:	e8 e0 fe ff ff       	call   104233 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104353:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104356:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104359:	29 d1                	sub    %edx,%ecx
  10435b:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10435d:	89 d6                	mov    %edx,%esi
  10435f:	c1 e6 16             	shl    $0x16,%esi
  104362:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104365:	89 d3                	mov    %edx,%ebx
  104367:	c1 e3 16             	shl    $0x16,%ebx
  10436a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10436d:	89 d1                	mov    %edx,%ecx
  10436f:	c1 e1 16             	shl    $0x16,%ecx
  104372:	8b 7d dc             	mov    -0x24(%ebp),%edi
  104375:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104378:	29 d7                	sub    %edx,%edi
  10437a:	89 fa                	mov    %edi,%edx
  10437c:	89 44 24 14          	mov    %eax,0x14(%esp)
  104380:	89 74 24 10          	mov    %esi,0x10(%esp)
  104384:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10438c:	89 54 24 04          	mov    %edx,0x4(%esp)
  104390:	c7 04 24 91 79 10 00 	movl   $0x107991,(%esp)
  104397:	e8 06 bf ff ff       	call   1002a2 <cprintf>
        size_t l, r = left * NPTEENTRY;
  10439c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10439f:	c1 e0 0a             	shl    $0xa,%eax
  1043a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1043a5:	eb 54                	jmp    1043fb <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1043a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043aa:	89 04 24             	mov    %eax,(%esp)
  1043ad:	e8 81 fe ff ff       	call   104233 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1043b2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1043b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043b8:	29 d1                	sub    %edx,%ecx
  1043ba:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1043bc:	89 d6                	mov    %edx,%esi
  1043be:	c1 e6 0c             	shl    $0xc,%esi
  1043c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043c4:	89 d3                	mov    %edx,%ebx
  1043c6:	c1 e3 0c             	shl    $0xc,%ebx
  1043c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043cc:	89 d1                	mov    %edx,%ecx
  1043ce:	c1 e1 0c             	shl    $0xc,%ecx
  1043d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1043d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043d7:	29 d7                	sub    %edx,%edi
  1043d9:	89 fa                	mov    %edi,%edx
  1043db:	89 44 24 14          	mov    %eax,0x14(%esp)
  1043df:	89 74 24 10          	mov    %esi,0x10(%esp)
  1043e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1043e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1043eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  1043ef:	c7 04 24 b0 79 10 00 	movl   $0x1079b0,(%esp)
  1043f6:	e8 a7 be ff ff       	call   1002a2 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1043fb:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  104400:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104403:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104406:	89 d3                	mov    %edx,%ebx
  104408:	c1 e3 0a             	shl    $0xa,%ebx
  10440b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10440e:	89 d1                	mov    %edx,%ecx
  104410:	c1 e1 0a             	shl    $0xa,%ecx
  104413:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104416:	89 54 24 14          	mov    %edx,0x14(%esp)
  10441a:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10441d:	89 54 24 10          	mov    %edx,0x10(%esp)
  104421:	89 74 24 0c          	mov    %esi,0xc(%esp)
  104425:	89 44 24 08          	mov    %eax,0x8(%esp)
  104429:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10442d:	89 0c 24             	mov    %ecx,(%esp)
  104430:	e8 40 fe ff ff       	call   104275 <get_pgtable_items>
  104435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104438:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10443c:	0f 85 65 ff ff ff    	jne    1043a7 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104442:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  104447:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10444a:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10444d:	89 54 24 14          	mov    %edx,0x14(%esp)
  104451:	8d 55 e0             	lea    -0x20(%ebp),%edx
  104454:	89 54 24 10          	mov    %edx,0x10(%esp)
  104458:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10445c:	89 44 24 08          	mov    %eax,0x8(%esp)
  104460:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  104467:	00 
  104468:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10446f:	e8 01 fe ff ff       	call   104275 <get_pgtable_items>
  104474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104477:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10447b:	0f 85 c7 fe ff ff    	jne    104348 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104481:	c7 04 24 d4 79 10 00 	movl   $0x1079d4,(%esp)
  104488:	e8 15 be ff ff       	call   1002a2 <cprintf>
}
  10448d:	90                   	nop
  10448e:	83 c4 4c             	add    $0x4c,%esp
  104491:	5b                   	pop    %ebx
  104492:	5e                   	pop    %esi
  104493:	5f                   	pop    %edi
  104494:	5d                   	pop    %ebp
  104495:	c3                   	ret    

00104496 <page_ref>:
page_ref(struct Page *page) {
  104496:	55                   	push   %ebp
  104497:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104499:	8b 45 08             	mov    0x8(%ebp),%eax
  10449c:	8b 00                	mov    (%eax),%eax
}
  10449e:	5d                   	pop    %ebp
  10449f:	c3                   	ret    

001044a0 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  1044a0:	55                   	push   %ebp
  1044a1:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1044a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1044a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044a9:	89 10                	mov    %edx,(%eax)
}
  1044ab:	90                   	nop
  1044ac:	5d                   	pop    %ebp
  1044ad:	c3                   	ret    

001044ae <fixsize>:
#define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//大于a的一个最小的2^k
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))//小于a的最大的2^k

static unsigned fixsize(unsigned size) {
  1044ae:	55                   	push   %ebp
  1044af:	89 e5                	mov    %esp,%ebp
  size |= size >> 1;
  1044b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1044b4:	d1 e8                	shr    %eax
  1044b6:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 2;
  1044b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1044bc:	c1 e8 02             	shr    $0x2,%eax
  1044bf:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 4;
  1044c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1044c5:	c1 e8 04             	shr    $0x4,%eax
  1044c8:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 8;
  1044cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1044ce:	c1 e8 08             	shr    $0x8,%eax
  1044d1:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 16;
  1044d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1044d7:	c1 e8 10             	shr    $0x10,%eax
  1044da:	09 45 08             	or     %eax,0x8(%ebp)
  return size+1;
  1044dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1044e0:	40                   	inc    %eax
}
  1044e1:	5d                   	pop    %ebp
  1044e2:	c3                   	ret    

001044e3 <buddy_init>:

struct allocRecord rec[40000];//存放偏移量的数组
int nr_block;//已分配的块数

static void buddy_init()
{
  1044e3:	55                   	push   %ebp
  1044e4:	89 e5                	mov    %esp,%ebp
  1044e6:	83 ec 10             	sub    $0x10,%esp
  1044e9:	c7 45 fc 40 c1 16 00 	movl   $0x16c140,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1044f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1044f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1044f6:	89 50 04             	mov    %edx,0x4(%eax)
  1044f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1044fc:	8b 50 04             	mov    0x4(%eax),%edx
  1044ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104502:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free=0;
  104504:	c7 05 48 c1 16 00 00 	movl   $0x0,0x16c148
  10450b:	00 00 00 
}
  10450e:	90                   	nop
  10450f:	c9                   	leave  
  104510:	c3                   	ret    

00104511 <buddy2_new>:

//初始化二叉树上的节点
void buddy2_new( int size ) {
  104511:	55                   	push   %ebp
  104512:	89 e5                	mov    %esp,%ebp
  104514:	83 ec 10             	sub    $0x10,%esp
  unsigned node_size;
  int i;
  nr_block=0;
  104517:	c7 05 20 df 11 00 00 	movl   $0x0,0x11df20
  10451e:	00 00 00 
  if (size < 1 || !IS_POWER_OF_2(size))
  104521:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104525:	7e 55                	jle    10457c <buddy2_new+0x6b>
  104527:	8b 45 08             	mov    0x8(%ebp),%eax
  10452a:	48                   	dec    %eax
  10452b:	23 45 08             	and    0x8(%ebp),%eax
  10452e:	85 c0                	test   %eax,%eax
  104530:	75 4a                	jne    10457c <buddy2_new+0x6b>
    return;

  root[0].size = size;
  104532:	8b 45 08             	mov    0x8(%ebp),%eax
  104535:	a3 40 df 11 00       	mov    %eax,0x11df40
  node_size = size * 2;
  10453a:	8b 45 08             	mov    0x8(%ebp),%eax
  10453d:	01 c0                	add    %eax,%eax
  10453f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  for (i = 0; i < 2 * size - 1; ++i) {
  104542:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  104549:	eb 23                	jmp    10456e <buddy2_new+0x5d>
    if (IS_POWER_OF_2(i+1))
  10454b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10454e:	40                   	inc    %eax
  10454f:	23 45 f8             	and    -0x8(%ebp),%eax
  104552:	85 c0                	test   %eax,%eax
  104554:	75 08                	jne    10455e <buddy2_new+0x4d>
      node_size /= 2;
  104556:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104559:	d1 e8                	shr    %eax
  10455b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    root[i].longest = node_size;
  10455e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104561:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104564:	89 14 c5 44 df 11 00 	mov    %edx,0x11df44(,%eax,8)
  for (i = 0; i < 2 * size - 1; ++i) {
  10456b:	ff 45 f8             	incl   -0x8(%ebp)
  10456e:	8b 45 08             	mov    0x8(%ebp),%eax
  104571:	01 c0                	add    %eax,%eax
  104573:	48                   	dec    %eax
  104574:	39 45 f8             	cmp    %eax,-0x8(%ebp)
  104577:	7c d2                	jl     10454b <buddy2_new+0x3a>
  }
  return;
  104579:	90                   	nop
  10457a:	eb 01                	jmp    10457d <buddy2_new+0x6c>
    return;
  10457c:	90                   	nop
}
  10457d:	c9                   	leave  
  10457e:	c3                   	ret    

0010457f <buddy_init_memmap>:

//初始化内存映射关系
static void
buddy_init_memmap(struct Page *base, size_t n)
{
  10457f:	55                   	push   %ebp
  104580:	89 e5                	mov    %esp,%ebp
  104582:	56                   	push   %esi
  104583:	53                   	push   %ebx
  104584:	83 ec 40             	sub    $0x40,%esp
    assert(n>0);
  104587:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10458b:	75 24                	jne    1045b1 <buddy_init_memmap+0x32>
  10458d:	c7 44 24 0c 08 7a 10 	movl   $0x107a08,0xc(%esp)
  104594:	00 
  104595:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  10459c:	00 
  10459d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  1045a4:	00 
  1045a5:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  1045ac:	e8 48 be ff ff       	call   1003f9 <__panic>
    struct Page* p=base;
  1045b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1045b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(;p!=base + n;p++)
  1045b7:	e9 dc 00 00 00       	jmp    104698 <buddy_init_memmap+0x119>
    {
        assert(PageReserved(p));
  1045bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045bf:	83 c0 04             	add    $0x4,%eax
  1045c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1045c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1045d2:	0f a3 10             	bt     %edx,(%eax)
  1045d5:	19 c0                	sbb    %eax,%eax
  1045d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1045da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1045de:	0f 95 c0             	setne  %al
  1045e1:	0f b6 c0             	movzbl %al,%eax
  1045e4:	85 c0                	test   %eax,%eax
  1045e6:	75 24                	jne    10460c <buddy_init_memmap+0x8d>
  1045e8:	c7 44 24 0c 31 7a 10 	movl   $0x107a31,0xc(%esp)
  1045ef:	00 
  1045f0:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  1045f7:	00 
  1045f8:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  1045ff:	00 
  104600:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  104607:	e8 ed bd ff ff       	call   1003f9 <__panic>
        p->flags = 0;
  10460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10460f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        p->property = 1;
  104616:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104619:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
        set_page_ref(p, 0);   
  104620:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104627:	00 
  104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10462b:	89 04 24             	mov    %eax,(%esp)
  10462e:	e8 6d fe ff ff       	call   1044a0 <set_page_ref>
        SetPageProperty(p);
  104633:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104636:	83 c0 04             	add    $0x4,%eax
  104639:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  104640:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104643:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104646:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104649:	0f ab 10             	bts    %edx,(%eax)
        list_add_before(&free_list,&(p->page_link));     
  10464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464f:	83 c0 0c             	add    $0xc,%eax
  104652:	c7 45 e0 40 c1 16 00 	movl   $0x16c140,-0x20(%ebp)
  104659:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10465c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10465f:	8b 00                	mov    (%eax),%eax
  104661:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104664:	89 55 d8             	mov    %edx,-0x28(%ebp)
  104667:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10466a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10466d:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104670:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104673:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104676:	89 10                	mov    %edx,(%eax)
  104678:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10467b:	8b 10                	mov    (%eax),%edx
  10467d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104680:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104683:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104686:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104689:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10468c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10468f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104692:	89 10                	mov    %edx,(%eax)
    for(;p!=base + n;p++)
  104694:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104698:	8b 55 0c             	mov    0xc(%ebp),%edx
  10469b:	89 d0                	mov    %edx,%eax
  10469d:	c1 e0 02             	shl    $0x2,%eax
  1046a0:	01 d0                	add    %edx,%eax
  1046a2:	c1 e0 02             	shl    $0x2,%eax
  1046a5:	89 c2                	mov    %eax,%edx
  1046a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1046aa:	01 d0                	add    %edx,%eax
  1046ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046af:	0f 85 07 ff ff ff    	jne    1045bc <buddy_init_memmap+0x3d>
    }
    nr_free += n;
  1046b5:	8b 15 48 c1 16 00    	mov    0x16c148,%edx
  1046bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046be:	01 d0                	add    %edx,%eax
  1046c0:	a3 48 c1 16 00       	mov    %eax,0x16c148
    int allocpages=UINT32_ROUND_DOWN(n);
  1046c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046c8:	d1 e8                	shr    %eax
  1046ca:	0b 45 0c             	or     0xc(%ebp),%eax
  1046cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  1046d0:	d1 ea                	shr    %edx
  1046d2:	0b 55 0c             	or     0xc(%ebp),%edx
  1046d5:	c1 ea 02             	shr    $0x2,%edx
  1046d8:	09 d0                	or     %edx,%eax
  1046da:	89 c1                	mov    %eax,%ecx
  1046dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046df:	d1 e8                	shr    %eax
  1046e1:	0b 45 0c             	or     0xc(%ebp),%eax
  1046e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1046e7:	d1 ea                	shr    %edx
  1046e9:	0b 55 0c             	or     0xc(%ebp),%edx
  1046ec:	c1 ea 02             	shr    $0x2,%edx
  1046ef:	09 d0                	or     %edx,%eax
  1046f1:	c1 e8 04             	shr    $0x4,%eax
  1046f4:	09 c1                	or     %eax,%ecx
  1046f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046f9:	d1 e8                	shr    %eax
  1046fb:	0b 45 0c             	or     0xc(%ebp),%eax
  1046fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  104701:	d1 ea                	shr    %edx
  104703:	0b 55 0c             	or     0xc(%ebp),%edx
  104706:	c1 ea 02             	shr    $0x2,%edx
  104709:	09 d0                	or     %edx,%eax
  10470b:	89 c3                	mov    %eax,%ebx
  10470d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104710:	d1 e8                	shr    %eax
  104712:	0b 45 0c             	or     0xc(%ebp),%eax
  104715:	8b 55 0c             	mov    0xc(%ebp),%edx
  104718:	d1 ea                	shr    %edx
  10471a:	0b 55 0c             	or     0xc(%ebp),%edx
  10471d:	c1 ea 02             	shr    $0x2,%edx
  104720:	09 d0                	or     %edx,%eax
  104722:	c1 e8 04             	shr    $0x4,%eax
  104725:	09 d8                	or     %ebx,%eax
  104727:	c1 e8 08             	shr    $0x8,%eax
  10472a:	09 c1                	or     %eax,%ecx
  10472c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10472f:	d1 e8                	shr    %eax
  104731:	0b 45 0c             	or     0xc(%ebp),%eax
  104734:	8b 55 0c             	mov    0xc(%ebp),%edx
  104737:	d1 ea                	shr    %edx
  104739:	0b 55 0c             	or     0xc(%ebp),%edx
  10473c:	c1 ea 02             	shr    $0x2,%edx
  10473f:	09 d0                	or     %edx,%eax
  104741:	89 c3                	mov    %eax,%ebx
  104743:	8b 45 0c             	mov    0xc(%ebp),%eax
  104746:	d1 e8                	shr    %eax
  104748:	0b 45 0c             	or     0xc(%ebp),%eax
  10474b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10474e:	d1 ea                	shr    %edx
  104750:	0b 55 0c             	or     0xc(%ebp),%edx
  104753:	c1 ea 02             	shr    $0x2,%edx
  104756:	09 d0                	or     %edx,%eax
  104758:	c1 e8 04             	shr    $0x4,%eax
  10475b:	09 c3                	or     %eax,%ebx
  10475d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104760:	d1 e8                	shr    %eax
  104762:	0b 45 0c             	or     0xc(%ebp),%eax
  104765:	8b 55 0c             	mov    0xc(%ebp),%edx
  104768:	d1 ea                	shr    %edx
  10476a:	0b 55 0c             	or     0xc(%ebp),%edx
  10476d:	c1 ea 02             	shr    $0x2,%edx
  104770:	09 d0                	or     %edx,%eax
  104772:	89 c6                	mov    %eax,%esi
  104774:	8b 45 0c             	mov    0xc(%ebp),%eax
  104777:	d1 e8                	shr    %eax
  104779:	0b 45 0c             	or     0xc(%ebp),%eax
  10477c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10477f:	d1 ea                	shr    %edx
  104781:	0b 55 0c             	or     0xc(%ebp),%edx
  104784:	c1 ea 02             	shr    $0x2,%edx
  104787:	09 d0                	or     %edx,%eax
  104789:	c1 e8 04             	shr    $0x4,%eax
  10478c:	09 f0                	or     %esi,%eax
  10478e:	c1 e8 08             	shr    $0x8,%eax
  104791:	09 d8                	or     %ebx,%eax
  104793:	c1 e8 10             	shr    $0x10,%eax
  104796:	09 c8                	or     %ecx,%eax
  104798:	d1 e8                	shr    %eax
  10479a:	23 45 0c             	and    0xc(%ebp),%eax
  10479d:	85 c0                	test   %eax,%eax
  10479f:	0f 84 dc 00 00 00    	je     104881 <buddy_init_memmap+0x302>
  1047a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047a8:	d1 e8                	shr    %eax
  1047aa:	0b 45 0c             	or     0xc(%ebp),%eax
  1047ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  1047b0:	d1 ea                	shr    %edx
  1047b2:	0b 55 0c             	or     0xc(%ebp),%edx
  1047b5:	c1 ea 02             	shr    $0x2,%edx
  1047b8:	09 d0                	or     %edx,%eax
  1047ba:	89 c1                	mov    %eax,%ecx
  1047bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047bf:	d1 e8                	shr    %eax
  1047c1:	0b 45 0c             	or     0xc(%ebp),%eax
  1047c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1047c7:	d1 ea                	shr    %edx
  1047c9:	0b 55 0c             	or     0xc(%ebp),%edx
  1047cc:	c1 ea 02             	shr    $0x2,%edx
  1047cf:	09 d0                	or     %edx,%eax
  1047d1:	c1 e8 04             	shr    $0x4,%eax
  1047d4:	09 c1                	or     %eax,%ecx
  1047d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047d9:	d1 e8                	shr    %eax
  1047db:	0b 45 0c             	or     0xc(%ebp),%eax
  1047de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1047e1:	d1 ea                	shr    %edx
  1047e3:	0b 55 0c             	or     0xc(%ebp),%edx
  1047e6:	c1 ea 02             	shr    $0x2,%edx
  1047e9:	09 d0                	or     %edx,%eax
  1047eb:	89 c3                	mov    %eax,%ebx
  1047ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047f0:	d1 e8                	shr    %eax
  1047f2:	0b 45 0c             	or     0xc(%ebp),%eax
  1047f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1047f8:	d1 ea                	shr    %edx
  1047fa:	0b 55 0c             	or     0xc(%ebp),%edx
  1047fd:	c1 ea 02             	shr    $0x2,%edx
  104800:	09 d0                	or     %edx,%eax
  104802:	c1 e8 04             	shr    $0x4,%eax
  104805:	09 d8                	or     %ebx,%eax
  104807:	c1 e8 08             	shr    $0x8,%eax
  10480a:	09 c1                	or     %eax,%ecx
  10480c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10480f:	d1 e8                	shr    %eax
  104811:	0b 45 0c             	or     0xc(%ebp),%eax
  104814:	8b 55 0c             	mov    0xc(%ebp),%edx
  104817:	d1 ea                	shr    %edx
  104819:	0b 55 0c             	or     0xc(%ebp),%edx
  10481c:	c1 ea 02             	shr    $0x2,%edx
  10481f:	09 d0                	or     %edx,%eax
  104821:	89 c3                	mov    %eax,%ebx
  104823:	8b 45 0c             	mov    0xc(%ebp),%eax
  104826:	d1 e8                	shr    %eax
  104828:	0b 45 0c             	or     0xc(%ebp),%eax
  10482b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10482e:	d1 ea                	shr    %edx
  104830:	0b 55 0c             	or     0xc(%ebp),%edx
  104833:	c1 ea 02             	shr    $0x2,%edx
  104836:	09 d0                	or     %edx,%eax
  104838:	c1 e8 04             	shr    $0x4,%eax
  10483b:	09 c3                	or     %eax,%ebx
  10483d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104840:	d1 e8                	shr    %eax
  104842:	0b 45 0c             	or     0xc(%ebp),%eax
  104845:	8b 55 0c             	mov    0xc(%ebp),%edx
  104848:	d1 ea                	shr    %edx
  10484a:	0b 55 0c             	or     0xc(%ebp),%edx
  10484d:	c1 ea 02             	shr    $0x2,%edx
  104850:	09 d0                	or     %edx,%eax
  104852:	89 c6                	mov    %eax,%esi
  104854:	8b 45 0c             	mov    0xc(%ebp),%eax
  104857:	d1 e8                	shr    %eax
  104859:	0b 45 0c             	or     0xc(%ebp),%eax
  10485c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10485f:	d1 ea                	shr    %edx
  104861:	0b 55 0c             	or     0xc(%ebp),%edx
  104864:	c1 ea 02             	shr    $0x2,%edx
  104867:	09 d0                	or     %edx,%eax
  104869:	c1 e8 04             	shr    $0x4,%eax
  10486c:	09 f0                	or     %esi,%eax
  10486e:	c1 e8 08             	shr    $0x8,%eax
  104871:	09 d8                	or     %ebx,%eax
  104873:	c1 e8 10             	shr    $0x10,%eax
  104876:	09 c8                	or     %ecx,%eax
  104878:	d1 e8                	shr    %eax
  10487a:	f7 d0                	not    %eax
  10487c:	23 45 0c             	and    0xc(%ebp),%eax
  10487f:	eb 03                	jmp    104884 <buddy_init_memmap+0x305>
  104881:	8b 45 0c             	mov    0xc(%ebp),%eax
  104884:	89 45 f0             	mov    %eax,-0x10(%ebp)
    buddy2_new(allocpages);
  104887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10488a:	89 04 24             	mov    %eax,(%esp)
  10488d:	e8 7f fc ff ff       	call   104511 <buddy2_new>
}
  104892:	90                   	nop
  104893:	83 c4 40             	add    $0x40,%esp
  104896:	5b                   	pop    %ebx
  104897:	5e                   	pop    %esi
  104898:	5d                   	pop    %ebp
  104899:	c3                   	ret    

0010489a <buddy2_alloc>:

//内存分配
int buddy2_alloc(struct buddy2* self, int size) {
  10489a:	55                   	push   %ebp
  10489b:	89 e5                	mov    %esp,%ebp
  10489d:	53                   	push   %ebx
  10489e:	83 ec 14             	sub    $0x14,%esp
  unsigned index = 0;//节点的标号
  1048a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  unsigned node_size;
  unsigned offset = 0;
  1048a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  if (self==NULL)//无法分配
  1048af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1048b3:	75 0a                	jne    1048bf <buddy2_alloc+0x25>
    return -1;
  1048b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1048ba:	e9 63 01 00 00       	jmp    104a22 <buddy2_alloc+0x188>

  if (size <= 0)//分配不合理
  1048bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1048c3:	7f 09                	jg     1048ce <buddy2_alloc+0x34>
    size = 1;
  1048c5:	c7 45 0c 01 00 00 00 	movl   $0x1,0xc(%ebp)
  1048cc:	eb 19                	jmp    1048e7 <buddy2_alloc+0x4d>
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
  1048ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048d1:	48                   	dec    %eax
  1048d2:	23 45 0c             	and    0xc(%ebp),%eax
  1048d5:	85 c0                	test   %eax,%eax
  1048d7:	74 0e                	je     1048e7 <buddy2_alloc+0x4d>
    size = fixsize(size);
  1048d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048dc:	89 04 24             	mov    %eax,(%esp)
  1048df:	e8 ca fb ff ff       	call   1044ae <fixsize>
  1048e4:	89 45 0c             	mov    %eax,0xc(%ebp)

  if (self[index].longest < size)//可分配内存不足
  1048e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1048ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  1048f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1048f4:	01 d0                	add    %edx,%eax
  1048f6:	8b 50 04             	mov    0x4(%eax),%edx
  1048f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048fc:	39 c2                	cmp    %eax,%edx
  1048fe:	73 0a                	jae    10490a <buddy2_alloc+0x70>
    return -1;
  104900:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104905:	e9 18 01 00 00       	jmp    104a22 <buddy2_alloc+0x188>

  //cprintf("size is:%d\n",size);

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
  10490a:	8b 45 08             	mov    0x8(%ebp),%eax
  10490d:	8b 00                	mov    (%eax),%eax
  10490f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104912:	e9 85 00 00 00       	jmp    10499c <buddy2_alloc+0x102>

    //cprintf("self[index].longest is: %d\n",self[index].longest);
    //cprintf("node_size is:%d\n",node_size);

    if (self[LEFT_LEAF(index)].longest >= size)
  104917:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10491a:	c1 e0 04             	shl    $0x4,%eax
  10491d:	8d 50 08             	lea    0x8(%eax),%edx
  104920:	8b 45 08             	mov    0x8(%ebp),%eax
  104923:	01 d0                	add    %edx,%eax
  104925:	8b 50 04             	mov    0x4(%eax),%edx
  104928:	8b 45 0c             	mov    0xc(%ebp),%eax
  10492b:	39 c2                	cmp    %eax,%edx
  10492d:	72 5c                	jb     10498b <buddy2_alloc+0xf1>
    {
      //cprintf("left.longest is:%d\n",self[LEFT_LEAF(index)].longest);
       if(self[RIGHT_LEAF(index)].longest>=size)
  10492f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104932:	40                   	inc    %eax
  104933:	c1 e0 04             	shl    $0x4,%eax
  104936:	89 c2                	mov    %eax,%edx
  104938:	8b 45 08             	mov    0x8(%ebp),%eax
  10493b:	01 d0                	add    %edx,%eax
  10493d:	8b 50 04             	mov    0x4(%eax),%edx
  104940:	8b 45 0c             	mov    0xc(%ebp),%eax
  104943:	39 c2                	cmp    %eax,%edx
  104945:	72 39                	jb     104980 <buddy2_alloc+0xe6>
        {
           //cprintf("right.longest is:%d\n",self[RIGHT_LEAF(index)].longest);
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
  104947:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10494a:	c1 e0 04             	shl    $0x4,%eax
  10494d:	8d 50 08             	lea    0x8(%eax),%edx
  104950:	8b 45 08             	mov    0x8(%ebp),%eax
  104953:	01 d0                	add    %edx,%eax
  104955:	8b 50 04             	mov    0x4(%eax),%edx
  104958:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10495b:	40                   	inc    %eax
  10495c:	c1 e0 04             	shl    $0x4,%eax
  10495f:	89 c1                	mov    %eax,%ecx
  104961:	8b 45 08             	mov    0x8(%ebp),%eax
  104964:	01 c8                	add    %ecx,%eax
  104966:	8b 40 04             	mov    0x4(%eax),%eax
  104969:	39 c2                	cmp    %eax,%edx
  10496b:	77 08                	ja     104975 <buddy2_alloc+0xdb>
  10496d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104970:	01 c0                	add    %eax,%eax
  104972:	40                   	inc    %eax
  104973:	eb 06                	jmp    10497b <buddy2_alloc+0xe1>
  104975:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104978:	40                   	inc    %eax
  104979:	01 c0                	add    %eax,%eax
  10497b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10497e:	eb 14                	jmp    104994 <buddy2_alloc+0xfa>
        }
       else
       {
         //cprintf("left_index is:%d\n",LEFT_LEAF(index));

         index=LEFT_LEAF(index);
  104980:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104983:	01 c0                	add    %eax,%eax
  104985:	40                   	inc    %eax
  104986:	89 45 f8             	mov    %eax,-0x8(%ebp)
  104989:	eb 09                	jmp    104994 <buddy2_alloc+0xfa>
    else
    { 
      
      //cprintf("right_index is:%d\n",RIGHT_LEAF(index));

      index = RIGHT_LEAF(index);
  10498b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10498e:	40                   	inc    %eax
  10498f:	01 c0                	add    %eax,%eax
  104991:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(node_size = self->size; node_size != size; node_size /= 2 ) {
  104994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104997:	d1 e8                	shr    %eax
  104999:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10499c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10499f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1049a2:	0f 85 6f ff ff ff    	jne    104917 <buddy2_alloc+0x7d>

    }
     
  }

  self[index].longest = 0;//标记节点为已使用
  1049a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1049ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  1049b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1049b5:	01 d0                	add    %edx,%eax
  1049b7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  offset = (index + 1) * node_size - self->size;
  1049be:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1049c1:	40                   	inc    %eax
  1049c2:	0f af 45 f4          	imul   -0xc(%ebp),%eax
  1049c6:	89 c2                	mov    %eax,%edx
  1049c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1049cb:	8b 00                	mov    (%eax),%eax
  1049cd:	29 c2                	sub    %eax,%edx
  1049cf:	89 d0                	mov    %edx,%eax
  1049d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  //cprintf("index is:%d\n",index);
  while (index) {
  1049d4:	eb 43                	jmp    104a19 <buddy2_alloc+0x17f>
    index = PARENT(index);
  1049d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1049d9:	40                   	inc    %eax
  1049da:	d1 e8                	shr    %eax
  1049dc:	48                   	dec    %eax
  1049dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
    self[index].longest = 
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  1049e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1049e3:	40                   	inc    %eax
  1049e4:	c1 e0 04             	shl    $0x4,%eax
  1049e7:	89 c2                	mov    %eax,%edx
  1049e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1049ec:	01 d0                	add    %edx,%eax
  1049ee:	8b 50 04             	mov    0x4(%eax),%edx
  1049f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1049f4:	c1 e0 04             	shl    $0x4,%eax
  1049f7:	8d 48 08             	lea    0x8(%eax),%ecx
  1049fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1049fd:	01 c8                	add    %ecx,%eax
  1049ff:	8b 40 04             	mov    0x4(%eax),%eax
    self[index].longest = 
  104a02:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  104a05:	8d 1c cd 00 00 00 00 	lea    0x0(,%ecx,8),%ebx
  104a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  104a0f:	01 d9                	add    %ebx,%ecx
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  104a11:	39 c2                	cmp    %eax,%edx
  104a13:	0f 43 c2             	cmovae %edx,%eax
    self[index].longest = 
  104a16:	89 41 04             	mov    %eax,0x4(%ecx)
  while (index) {
  104a19:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  104a1d:	75 b7                	jne    1049d6 <buddy2_alloc+0x13c>
  }
//向上刷新，修改先祖结点的数值

  //cprintf("offset id:%d\n",offset);
  return offset;
  104a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  104a22:	83 c4 14             	add    $0x14,%esp
  104a25:	5b                   	pop    %ebx
  104a26:	5d                   	pop    %ebp
  104a27:	c3                   	ret    

00104a28 <buddy_alloc_pages>:

static struct Page*
buddy_alloc_pages(size_t n){
  104a28:	55                   	push   %ebp
  104a29:	89 e5                	mov    %esp,%ebp
  104a2b:	53                   	push   %ebx
  104a2c:	83 ec 44             	sub    $0x44,%esp
  assert(n>0);
  104a2f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104a33:	75 24                	jne    104a59 <buddy_alloc_pages+0x31>
  104a35:	c7 44 24 0c 08 7a 10 	movl   $0x107a08,0xc(%esp)
  104a3c:	00 
  104a3d:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  104a44:	00 
  104a45:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  104a4c:	00 
  104a4d:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  104a54:	e8 a0 b9 ff ff       	call   1003f9 <__panic>
  if(n>nr_free)
  104a59:	a1 48 c1 16 00       	mov    0x16c148,%eax
  104a5e:	39 45 08             	cmp    %eax,0x8(%ebp)
  104a61:	76 0a                	jbe    104a6d <buddy_alloc_pages+0x45>
   return NULL;
  104a63:	b8 00 00 00 00       	mov    $0x0,%eax
  104a68:	e9 41 01 00 00       	jmp    104bae <buddy_alloc_pages+0x186>
  struct Page* page=NULL;
  104a6d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  struct Page* p;
  list_entry_t *le=&free_list,*len;
  104a74:	c7 45 f4 40 c1 16 00 	movl   $0x16c140,-0xc(%ebp)
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
  104a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  104a7e:	8b 1d 20 df 11 00    	mov    0x11df20,%ebx
  104a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  104a88:	c7 04 24 40 df 11 00 	movl   $0x11df40,(%esp)
  104a8f:	e8 06 fe ff ff       	call   10489a <buddy2_alloc>
  104a94:	89 c2                	mov    %eax,%edx
  104a96:	89 d8                	mov    %ebx,%eax
  104a98:	01 c0                	add    %eax,%eax
  104a9a:	01 d8                	add    %ebx,%eax
  104a9c:	c1 e0 02             	shl    $0x2,%eax
  104a9f:	05 64 c1 16 00       	add    $0x16c164,%eax
  104aa4:	89 10                	mov    %edx,(%eax)
  int i;
  for(i=0;i<rec[nr_block].offset+1;i++)
  104aa6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104aad:	eb 12                	jmp    104ac1 <buddy_alloc_pages+0x99>
  104aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ab2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return listelm->next;
  104ab5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104ab8:	8b 40 04             	mov    0x4(%eax),%eax
    le=list_next(le);
  104abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(i=0;i<rec[nr_block].offset+1;i++)
  104abe:	ff 45 f0             	incl   -0x10(%ebp)
  104ac1:	8b 15 20 df 11 00    	mov    0x11df20,%edx
  104ac7:	89 d0                	mov    %edx,%eax
  104ac9:	01 c0                	add    %eax,%eax
  104acb:	01 d0                	add    %edx,%eax
  104acd:	c1 e0 02             	shl    $0x2,%eax
  104ad0:	05 64 c1 16 00       	add    $0x16c164,%eax
  104ad5:	8b 00                	mov    (%eax),%eax
  104ad7:	40                   	inc    %eax
  104ad8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104adb:	7c d2                	jl     104aaf <buddy_alloc_pages+0x87>
  page=le2page(le,page_link);
  104add:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ae0:	83 e8 0c             	sub    $0xc,%eax
  104ae3:	89 45 e8             	mov    %eax,-0x18(%ebp)

  //cprintf("here1\n");


  int allocpages;
  if(!IS_POWER_OF_2(n))
  104ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  104ae9:	48                   	dec    %eax
  104aea:	23 45 08             	and    0x8(%ebp),%eax
  104aed:	85 c0                	test   %eax,%eax
  104aef:	74 10                	je     104b01 <buddy_alloc_pages+0xd9>
   allocpages=fixsize(n);
  104af1:	8b 45 08             	mov    0x8(%ebp),%eax
  104af4:	89 04 24             	mov    %eax,(%esp)
  104af7:	e8 b2 f9 ff ff       	call   1044ae <fixsize>
  104afc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104aff:	eb 06                	jmp    104b07 <buddy_alloc_pages+0xdf>
  else
  {
     allocpages=n;
  104b01:	8b 45 08             	mov    0x8(%ebp),%eax
  104b04:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }
  //根据需求n得到块大小
  rec[nr_block].base=page;//记录分配块首页
  104b07:	8b 15 20 df 11 00    	mov    0x11df20,%edx
  104b0d:	89 d0                	mov    %edx,%eax
  104b0f:	01 c0                	add    %eax,%eax
  104b11:	01 d0                	add    %edx,%eax
  104b13:	c1 e0 02             	shl    $0x2,%eax
  104b16:	8d 90 60 c1 16 00    	lea    0x16c160(%eax),%edx
  104b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104b1f:	89 02                	mov    %eax,(%edx)
  rec[nr_block].nr=allocpages;//记录分配的页数
  104b21:	8b 15 20 df 11 00    	mov    0x11df20,%edx
  104b27:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  104b2a:	89 d0                	mov    %edx,%eax
  104b2c:	01 c0                	add    %eax,%eax
  104b2e:	01 d0                	add    %edx,%eax
  104b30:	c1 e0 02             	shl    $0x2,%eax
  104b33:	05 68 c1 16 00       	add    $0x16c168,%eax
  104b38:	89 08                	mov    %ecx,(%eax)
  nr_block++;
  104b3a:	a1 20 df 11 00       	mov    0x11df20,%eax
  104b3f:	40                   	inc    %eax
  104b40:	a3 20 df 11 00       	mov    %eax,0x11df20
  for(i=0;i<allocpages;i++)
  104b45:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104b4c:	eb 3a                	jmp    104b88 <buddy_alloc_pages+0x160>
  104b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b51:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104b54:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104b57:	8b 40 04             	mov    0x4(%eax),%eax
  {
    len=list_next(le);
  104b5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    p=le2page(le,page_link);
  104b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b60:	83 e8 0c             	sub    $0xc,%eax
  104b63:	89 45 e0             	mov    %eax,-0x20(%ebp)
    ClearPageProperty(p);
  104b66:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104b69:	83 c0 04             	add    $0x4,%eax
  104b6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
  104b73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104b76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104b79:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104b7c:	0f b3 10             	btr    %edx,(%eax)
    le=len;
  104b7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(i=0;i<allocpages;i++)
  104b85:	ff 45 f0             	incl   -0x10(%ebp)
  104b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104b8e:	7c be                	jl     104b4e <buddy_alloc_pages+0x126>
  }//修改每一页的状态
  nr_free-=allocpages;//减去已被分配的页数
  104b90:	8b 15 48 c1 16 00    	mov    0x16c148,%edx
  104b96:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b99:	29 c2                	sub    %eax,%edx
  104b9b:	89 d0                	mov    %edx,%eax
  104b9d:	a3 48 c1 16 00       	mov    %eax,0x16c148
  
  //cprintf("here2\n");

  page->property=n;
  104ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  104ba8:	89 50 08             	mov    %edx,0x8(%eax)
  return page;   
  104bab:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  104bae:	83 c4 44             	add    $0x44,%esp
  104bb1:	5b                   	pop    %ebx
  104bb2:	5d                   	pop    %ebp
  104bb3:	c3                   	ret    

00104bb4 <buddy_free_pages>:

void buddy_free_pages(struct Page* base, size_t n) {
  104bb4:	55                   	push   %ebp
  104bb5:	89 e5                	mov    %esp,%ebp
  104bb7:	83 ec 58             	sub    $0x58,%esp
  unsigned node_size, index = 0;
  104bba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  unsigned left_longest, right_longest;
  struct buddy2* self=root;
  104bc1:	c7 45 e0 40 df 11 00 	movl   $0x11df40,-0x20(%ebp)
  104bc8:	c7 45 c8 40 c1 16 00 	movl   $0x16c140,-0x38(%ebp)
  104bcf:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104bd2:	8b 40 04             	mov    0x4(%eax),%eax
  
  list_entry_t *le=list_next(&free_list);
  104bd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i=0;
  104bd8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  for(i=0;i<nr_block;i++)//找到块
  104bdf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  104be6:	eb 1b                	jmp    104c03 <buddy_free_pages+0x4f>
  {
    if(rec[i].base==base)
  104be8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104beb:	89 d0                	mov    %edx,%eax
  104bed:	01 c0                	add    %eax,%eax
  104bef:	01 d0                	add    %edx,%eax
  104bf1:	c1 e0 02             	shl    $0x2,%eax
  104bf4:	05 60 c1 16 00       	add    $0x16c160,%eax
  104bf9:	8b 00                	mov    (%eax),%eax
  104bfb:	39 45 08             	cmp    %eax,0x8(%ebp)
  104bfe:	74 0f                	je     104c0f <buddy_free_pages+0x5b>
  for(i=0;i<nr_block;i++)//找到块
  104c00:	ff 45 e8             	incl   -0x18(%ebp)
  104c03:	a1 20 df 11 00       	mov    0x11df20,%eax
  104c08:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104c0b:	7c db                	jl     104be8 <buddy_free_pages+0x34>
  104c0d:	eb 01                	jmp    104c10 <buddy_free_pages+0x5c>
     break;
  104c0f:	90                   	nop
  }
  int offset=rec[i].offset;
  104c10:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104c13:	89 d0                	mov    %edx,%eax
  104c15:	01 c0                	add    %eax,%eax
  104c17:	01 d0                	add    %edx,%eax
  104c19:	c1 e0 02             	shl    $0x2,%eax
  104c1c:	05 64 c1 16 00       	add    $0x16c164,%eax
  104c21:	8b 00                	mov    (%eax),%eax
  104c23:	89 45 dc             	mov    %eax,-0x24(%ebp)
  int pos=i;//暂存i
  104c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c29:	89 45 d8             	mov    %eax,-0x28(%ebp)
  i=0;
  104c2c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  while(i<offset)
  104c33:	eb 12                	jmp    104c47 <buddy_free_pages+0x93>
  104c35:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  104c3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104c3e:	8b 40 04             	mov    0x4(%eax),%eax
  {
    le=list_next(le);
  104c41:	89 45 ec             	mov    %eax,-0x14(%ebp)
    i++;
  104c44:	ff 45 e8             	incl   -0x18(%ebp)
  while(i<offset)
  104c47:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c4a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104c4d:	7c e6                	jl     104c35 <buddy_free_pages+0x81>
  }
  int allocpages;
  if(!IS_POWER_OF_2(n))
  104c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c52:	48                   	dec    %eax
  104c53:	23 45 0c             	and    0xc(%ebp),%eax
  104c56:	85 c0                	test   %eax,%eax
  104c58:	74 10                	je     104c6a <buddy_free_pages+0xb6>
   allocpages=fixsize(n);
  104c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c5d:	89 04 24             	mov    %eax,(%esp)
  104c60:	e8 49 f8 ff ff       	call   1044ae <fixsize>
  104c65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104c68:	eb 06                	jmp    104c70 <buddy_free_pages+0xbc>
  else
  {
     allocpages=n;
  104c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  104c6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  }
  assert(self && offset >= 0 && offset < self->size);//是否合法
  104c70:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104c74:	74 12                	je     104c88 <buddy_free_pages+0xd4>
  104c76:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104c7a:	78 0c                	js     104c88 <buddy_free_pages+0xd4>
  104c7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104c7f:	8b 10                	mov    (%eax),%edx
  104c81:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c84:	39 c2                	cmp    %eax,%edx
  104c86:	77 24                	ja     104cac <buddy_free_pages+0xf8>
  104c88:	c7 44 24 0c 44 7a 10 	movl   $0x107a44,0xc(%esp)
  104c8f:	00 
  104c90:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  104c97:	00 
  104c98:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  104c9f:	00 
  104ca0:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  104ca7:	e8 4d b7 ff ff       	call   1003f9 <__panic>
  node_size = 1;
  104cac:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  index = offset + self->size - 1;
  104cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104cb6:	8b 10                	mov    (%eax),%edx
  104cb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104cbb:	01 d0                	add    %edx,%eax
  104cbd:	48                   	dec    %eax
  104cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nr_free+=allocpages;//更新空闲页的数量
  104cc1:	8b 15 48 c1 16 00    	mov    0x16c148,%edx
  104cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104cca:	01 d0                	add    %edx,%eax
  104ccc:	a3 48 c1 16 00       	mov    %eax,0x16c148
  struct Page* p;
  //self[index].longest = allocpages;
  self[index].longest=node_size;
  104cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cd4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  104cdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104cde:	01 c2                	add    %eax,%edx
  104ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ce3:	89 42 04             	mov    %eax,0x4(%edx)
  for(i=0;i<allocpages;i++)//回收已分配的页
  104ce6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  104ced:	eb 48                	jmp    104d37 <buddy_free_pages+0x183>
  {
     p=le2page(le,page_link);
  104cef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104cf2:	83 e8 0c             	sub    $0xc,%eax
  104cf5:	89 45 cc             	mov    %eax,-0x34(%ebp)
     p->flags=0;
  104cf8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104cfb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
     p->property=1;
  104d02:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104d05:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
     SetPageProperty(p);
  104d0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104d0f:	83 c0 04             	add    $0x4,%eax
  104d12:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  104d19:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104d1c:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104d1f:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104d22:	0f ab 10             	bts    %edx,(%eax)
  104d25:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d28:	89 45 c0             	mov    %eax,-0x40(%ebp)
  104d2b:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104d2e:	8b 40 04             	mov    0x4(%eax),%eax
     le=list_next(le);
  104d31:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(i=0;i<allocpages;i++)//回收已分配的页
  104d34:	ff 45 e8             	incl   -0x18(%ebp)
  104d37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d3a:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  104d3d:	7c b0                	jl     104cef <buddy_free_pages+0x13b>
  }
  while (index) {//向上合并，修改先祖节点的记录值
  104d3f:	eb 75                	jmp    104db6 <buddy_free_pages+0x202>
    index = PARENT(index);
  104d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d44:	40                   	inc    %eax
  104d45:	d1 e8                	shr    %eax
  104d47:	48                   	dec    %eax
  104d48:	89 45 f0             	mov    %eax,-0x10(%ebp)
    node_size *= 2;
  104d4b:	d1 65 f4             	shll   -0xc(%ebp)

    left_longest = self[LEFT_LEAF(index)].longest;
  104d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d51:	c1 e0 04             	shl    $0x4,%eax
  104d54:	8d 50 08             	lea    0x8(%eax),%edx
  104d57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104d5a:	01 d0                	add    %edx,%eax
  104d5c:	8b 40 04             	mov    0x4(%eax),%eax
  104d5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    right_longest = self[RIGHT_LEAF(index)].longest;
  104d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d65:	40                   	inc    %eax
  104d66:	c1 e0 04             	shl    $0x4,%eax
  104d69:	89 c2                	mov    %eax,%edx
  104d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104d6e:	01 d0                	add    %edx,%eax
  104d70:	8b 40 04             	mov    0x4(%eax),%eax
  104d73:	89 45 d0             	mov    %eax,-0x30(%ebp)
    
    if (left_longest + right_longest == node_size) 
  104d76:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d79:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d7c:	01 d0                	add    %edx,%eax
  104d7e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104d81:	75 17                	jne    104d9a <buddy_free_pages+0x1e6>
      self[index].longest = node_size;
  104d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d86:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  104d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104d90:	01 c2                	add    %eax,%edx
  104d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d95:	89 42 04             	mov    %eax,0x4(%edx)
  104d98:	eb 1c                	jmp    104db6 <buddy_free_pages+0x202>
    else
      self[index].longest = MAX(left_longest, right_longest);
  104d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d9d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  104da4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104da7:	01 c2                	add    %eax,%edx
  104da9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104dac:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  104daf:	0f 43 45 d0          	cmovae -0x30(%ebp),%eax
  104db3:	89 42 04             	mov    %eax,0x4(%edx)
  while (index) {//向上合并，修改先祖节点的记录值
  104db6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104dba:	75 85                	jne    104d41 <buddy_free_pages+0x18d>
  }
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
  104dbc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104dbf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104dc2:	eb 39                	jmp    104dfd <buddy_free_pages+0x249>
  {
    rec[i]=rec[i+1];
  104dc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104dc7:	8d 48 01             	lea    0x1(%eax),%ecx
  104dca:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104dcd:	89 d0                	mov    %edx,%eax
  104dcf:	01 c0                	add    %eax,%eax
  104dd1:	01 d0                	add    %edx,%eax
  104dd3:	c1 e0 02             	shl    $0x2,%eax
  104dd6:	8d 90 60 c1 16 00    	lea    0x16c160(%eax),%edx
  104ddc:	89 c8                	mov    %ecx,%eax
  104dde:	01 c0                	add    %eax,%eax
  104de0:	01 c8                	add    %ecx,%eax
  104de2:	c1 e0 02             	shl    $0x2,%eax
  104de5:	05 60 c1 16 00       	add    $0x16c160,%eax
  104dea:	8b 08                	mov    (%eax),%ecx
  104dec:	89 0a                	mov    %ecx,(%edx)
  104dee:	8b 48 04             	mov    0x4(%eax),%ecx
  104df1:	89 4a 04             	mov    %ecx,0x4(%edx)
  104df4:	8b 40 08             	mov    0x8(%eax),%eax
  104df7:	89 42 08             	mov    %eax,0x8(%edx)
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
  104dfa:	ff 45 e8             	incl   -0x18(%ebp)
  104dfd:	a1 20 df 11 00       	mov    0x11df20,%eax
  104e02:	48                   	dec    %eax
  104e03:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104e06:	7c bc                	jl     104dc4 <buddy_free_pages+0x210>
  }
  nr_block--;//更新分配块数的值
  104e08:	a1 20 df 11 00       	mov    0x11df20,%eax
  104e0d:	48                   	dec    %eax
  104e0e:	a3 20 df 11 00       	mov    %eax,0x11df20
}
  104e13:	90                   	nop
  104e14:	c9                   	leave  
  104e15:	c3                   	ret    

00104e16 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
  104e16:	55                   	push   %ebp
  104e17:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104e19:	a1 48 c1 16 00       	mov    0x16c148,%eax
}
  104e1e:	5d                   	pop    %ebp
  104e1f:	c3                   	ret    

00104e20 <buddy_check>:

static void
buddy_check(void) {
  104e20:	55                   	push   %ebp
  104e21:	89 e5                	mov    %esp,%ebp
  104e23:	83 ec 28             	sub    $0x28,%esp
  
    struct Page  *A, *B;
    A = B  =NULL;
  104e26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e30:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert((A = alloc_page()) != NULL);
  104e33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e3a:	e8 91 df ff ff       	call   102dd0 <alloc_pages>
  104e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104e46:	75 24                	jne    104e6c <buddy_check+0x4c>
  104e48:	c7 44 24 0c 6f 7a 10 	movl   $0x107a6f,0xc(%esp)
  104e4f:	00 
  104e50:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  104e57:	00 
  104e58:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104e5f:	00 
  104e60:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  104e67:	e8 8d b5 ff ff       	call   1003f9 <__panic>
    assert((B = alloc_page()) != NULL);
  104e6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e73:	e8 58 df ff ff       	call   102dd0 <alloc_pages>
  104e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104e7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104e7f:	75 24                	jne    104ea5 <buddy_check+0x85>
  104e81:	c7 44 24 0c 8a 7a 10 	movl   $0x107a8a,0xc(%esp)
  104e88:	00 
  104e89:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  104e90:	00 
  104e91:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  104e98:	00 
  104e99:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  104ea0:	e8 54 b5 ff ff       	call   1003f9 <__panic>

    assert( A != B);
  104ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ea8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104eab:	75 24                	jne    104ed1 <buddy_check+0xb1>
  104ead:	c7 44 24 0c a5 7a 10 	movl   $0x107aa5,0xc(%esp)
  104eb4:	00 
  104eb5:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  104ebc:	00 
  104ebd:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  104ec4:	00 
  104ec5:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  104ecc:	e8 28 b5 ff ff       	call   1003f9 <__panic>
    assert(page_ref(A) == 0 && page_ref(B) == 0);
  104ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ed4:	89 04 24             	mov    %eax,(%esp)
  104ed7:	e8 ba f5 ff ff       	call   104496 <page_ref>
  104edc:	85 c0                	test   %eax,%eax
  104ede:	75 0f                	jne    104eef <buddy_check+0xcf>
  104ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ee3:	89 04 24             	mov    %eax,(%esp)
  104ee6:	e8 ab f5 ff ff       	call   104496 <page_ref>
  104eeb:	85 c0                	test   %eax,%eax
  104eed:	74 24                	je     104f13 <buddy_check+0xf3>
  104eef:	c7 44 24 0c ac 7a 10 	movl   $0x107aac,0xc(%esp)
  104ef6:	00 
  104ef7:	c7 44 24 08 0c 7a 10 	movl   $0x107a0c,0x8(%esp)
  104efe:	00 
  104eff:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  104f06:	00 
  104f07:	c7 04 24 21 7a 10 00 	movl   $0x107a21,(%esp)
  104f0e:	e8 e6 b4 ff ff       	call   1003f9 <__panic>
    //free page就是free pages(A,1)
    free_page(A);
  104f13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f1a:	00 
  104f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f1e:	89 04 24             	mov    %eax,(%esp)
  104f21:	e8 e2 de ff ff       	call   102e08 <free_pages>
    free_page(B);
  104f26:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f2d:	00 
  104f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f31:	89 04 24             	mov    %eax,(%esp)
  104f34:	e8 cf de ff ff       	call   102e08 <free_pages>
    
    
    cprintf("*******************************Check begin***************************\n");
  104f39:	c7 04 24 d4 7a 10 00 	movl   $0x107ad4,(%esp)
  104f40:	e8 5d b3 ff ff       	call   1002a2 <cprintf>
    //A=alloc_pages(500);     //alloc_pages返回的是开始分配的那一页的地址
    A=alloc_pages(70);
  104f45:	c7 04 24 46 00 00 00 	movl   $0x46,(%esp)
  104f4c:	e8 7f de ff ff       	call   102dd0 <alloc_pages>
  104f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //B=alloc_pages(500);
    B=alloc_pages(35);
  104f54:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
  104f5b:	e8 70 de ff ff       	call   102dd0 <alloc_pages>
  104f60:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("A %p\n",A);
  104f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f66:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f6a:	c7 04 24 1b 7b 10 00 	movl   $0x107b1b,(%esp)
  104f71:	e8 2c b3 ff ff       	call   1002a2 <cprintf>
    cprintf("B %p\n",B);
  104f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f7d:	c7 04 24 21 7b 10 00 	movl   $0x107b21,(%esp)
  104f84:	e8 19 b3 ff ff       	call   1002a2 <cprintf>
    cprintf("********************************Check End****************************\n");
  104f89:	c7 04 24 28 7b 10 00 	movl   $0x107b28,(%esp)
  104f90:	e8 0d b3 ff ff       	call   1002a2 <cprintf>
    cprintf("D %p\n",D);
    free_pages(D,60);
    cprintf("C %p\n",C);
    free_pages(C,80);
    free_pages(p0,1000);//全部释放*/
}
  104f95:	90                   	nop
  104f96:	c9                   	leave  
  104f97:	c3                   	ret    

00104f98 <page2ppn>:
page2ppn(struct Page *page) {
  104f98:	55                   	push   %ebp
  104f99:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  104f9e:	8b 15 18 df 11 00    	mov    0x11df18,%edx
  104fa4:	29 d0                	sub    %edx,%eax
  104fa6:	c1 f8 02             	sar    $0x2,%eax
  104fa9:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104faf:	5d                   	pop    %ebp
  104fb0:	c3                   	ret    

00104fb1 <page2pa>:
page2pa(struct Page *page) {
  104fb1:	55                   	push   %ebp
  104fb2:	89 e5                	mov    %esp,%ebp
  104fb4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  104fba:	89 04 24             	mov    %eax,(%esp)
  104fbd:	e8 d6 ff ff ff       	call   104f98 <page2ppn>
  104fc2:	c1 e0 0c             	shl    $0xc,%eax
}
  104fc5:	c9                   	leave  
  104fc6:	c3                   	ret    

00104fc7 <page_ref>:
page_ref(struct Page *page) {
  104fc7:	55                   	push   %ebp
  104fc8:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104fca:	8b 45 08             	mov    0x8(%ebp),%eax
  104fcd:	8b 00                	mov    (%eax),%eax
}
  104fcf:	5d                   	pop    %ebp
  104fd0:	c3                   	ret    

00104fd1 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  104fd1:	55                   	push   %ebp
  104fd2:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  104fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  104fda:	89 10                	mov    %edx,(%eax)
}
  104fdc:	90                   	nop
  104fdd:	5d                   	pop    %ebp
  104fde:	c3                   	ret    

00104fdf <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104fdf:	55                   	push   %ebp
  104fe0:	89 e5                	mov    %esp,%ebp
  104fe2:	83 ec 10             	sub    $0x10,%esp
  104fe5:	c7 45 fc 40 c1 16 00 	movl   $0x16c140,-0x4(%ebp)
    elm->prev = elm->next = elm;
  104fec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104fef:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104ff2:	89 50 04             	mov    %edx,0x4(%eax)
  104ff5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104ff8:	8b 50 04             	mov    0x4(%eax),%edx
  104ffb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104ffe:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  105000:	c7 05 48 c1 16 00 00 	movl   $0x0,0x16c148
  105007:	00 00 00 
}
  10500a:	90                   	nop
  10500b:	c9                   	leave  
  10500c:	c3                   	ret    

0010500d <default_init_memmap>:
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}*/

static void
default_init_memmap(struct Page *base, size_t n) {
  10500d:	55                   	push   %ebp
  10500e:	89 e5                	mov    %esp,%ebp
  105010:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);   //使用assert宏，当为假时中止程序
  105013:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105017:	75 24                	jne    10503d <default_init_memmap+0x30>
  105019:	c7 44 24 0c a0 7b 10 	movl   $0x107ba0,0xc(%esp)
  105020:	00 
  105021:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105028:	00 
  105029:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  105030:	00 
  105031:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105038:	e8 bc b3 ff ff       	call   1003f9 <__panic>
    struct Page *p = base;//声明一个base的Page，随后生成起始地址为base的n个连续页
  10503d:	8b 45 08             	mov    0x8(%ebp),%eax
  105040:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) { //初始化n块物理页
  105043:	e9 de 00 00 00       	jmp    105126 <default_init_memmap+0x119>
        assert(PageReserved(p)); //确保此页不是保留页，如果是，中止程序
  105048:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10504b:	83 c0 04             	add    $0x4,%eax
  10504e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  105055:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105058:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10505b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10505e:	0f a3 10             	bt     %edx,(%eax)
  105061:	19 c0                	sbb    %eax,%eax
  105063:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  105066:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10506a:	0f 95 c0             	setne  %al
  10506d:	0f b6 c0             	movzbl %al,%eax
  105070:	85 c0                	test   %eax,%eax
  105072:	75 24                	jne    105098 <default_init_memmap+0x8b>
  105074:	c7 44 24 0c d1 7b 10 	movl   $0x107bd1,0xc(%esp)
  10507b:	00 
  10507c:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105083:	00 
  105084:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  10508b:	00 
  10508c:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105093:	e8 61 b3 ff ff       	call   1003f9 <__panic>
        p->flags = p->property= 0; //标志位置为0
  105098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10509b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1050a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050a5:	8b 50 08             	mov    0x8(%eax),%edx
  1050a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050ab:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(p);       //设置为保留页
  1050ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050b1:	83 c0 04             	add    $0x4,%eax
  1050b4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1050bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1050be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1050c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1050c4:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);  
  1050c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1050ce:	00 
  1050cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050d2:	89 04 24             	mov    %eax,(%esp)
  1050d5:	e8 f7 fe ff ff       	call   104fd1 <set_page_ref>
        list_add_before(&free_list, &(p->page_link)); //加入空闲链表
  1050da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050dd:	83 c0 0c             	add    $0xc,%eax
  1050e0:	c7 45 e4 40 c1 16 00 	movl   $0x16c140,-0x1c(%ebp)
  1050e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1050ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050ed:	8b 00                	mov    (%eax),%eax
  1050ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1050f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1050f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1050f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
  1050fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105101:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105104:	89 10                	mov    %edx,(%eax)
  105106:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105109:	8b 10                	mov    (%eax),%edx
  10510b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10510e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  105111:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105114:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105117:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10511a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10511d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105120:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) { //初始化n块物理页
  105122:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  105126:	8b 55 0c             	mov    0xc(%ebp),%edx
  105129:	89 d0                	mov    %edx,%eax
  10512b:	c1 e0 02             	shl    $0x2,%eax
  10512e:	01 d0                	add    %edx,%eax
  105130:	c1 e0 02             	shl    $0x2,%eax
  105133:	89 c2                	mov    %eax,%edx
  105135:	8b 45 08             	mov    0x8(%ebp),%eax
  105138:	01 d0                	add    %edx,%eax
  10513a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10513d:	0f 85 05 ff ff ff    	jne    105048 <default_init_memmap+0x3b>
    }
    nr_free += n;  //空闲页总数置为n
  105143:	8b 15 48 c1 16 00    	mov    0x16c148,%edx
  105149:	8b 45 0c             	mov    0xc(%ebp),%eax
  10514c:	01 d0                	add    %edx,%eax
  10514e:	a3 48 c1 16 00       	mov    %eax,0x16c148
    base->property = n; //修改base的连续空页值为n
  105153:	8b 45 08             	mov    0x8(%ebp),%eax
  105156:	8b 55 0c             	mov    0xc(%ebp),%edx
  105159:	89 50 08             	mov    %edx,0x8(%eax)
}
  10515c:	90                   	nop
  10515d:	c9                   	leave  
  10515e:	c3                   	ret    

0010515f <default_alloc_pages>:
    }
    return page;
}*/

static struct Page *
default_alloc_pages(size_t n) {
  10515f:	55                   	push   %ebp
  105160:	89 e5                	mov    %esp,%ebp
  105162:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0); 
  105165:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105169:	75 24                	jne    10518f <default_alloc_pages+0x30>
  10516b:	c7 44 24 0c a0 7b 10 	movl   $0x107ba0,0xc(%esp)
  105172:	00 
  105173:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  10517a:	00 
  10517b:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  105182:	00 
  105183:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  10518a:	e8 6a b2 ff ff       	call   1003f9 <__panic>
    if (n > nr_free) { //如果需要分配的页少于空闲页的总数,返回NULL
  10518f:	a1 48 c1 16 00       	mov    0x16c148,%eax
  105194:	39 45 08             	cmp    %eax,0x8(%ebp)
  105197:	76 0a                	jbe    1051a3 <default_alloc_pages+0x44>
        return NULL;
  105199:	b8 00 00 00 00       	mov    $0x0,%eax
  10519e:	e9 36 01 00 00       	jmp    1052d9 <default_alloc_pages+0x17a>
    }
    list_entry_t *le, *len; //声明一个空闲链表的头部和长度
    le = &free_list;  //空闲链表的头部
  1051a3:	c7 45 f4 40 c1 16 00 	movl   $0x16c140,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {//遍历整个链表
  1051aa:	e9 09 01 00 00       	jmp    1052b8 <default_alloc_pages+0x159>
      struct Page *p = le2page(le, page_link); //转换为页
  1051af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1051b2:	83 e8 0c             	sub    $0xc,%eax
  1051b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){//找到页(whose first `n` pages can be malloced)
  1051b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1051bb:	8b 40 08             	mov    0x8(%eax),%eax
  1051be:	39 45 08             	cmp    %eax,0x8(%ebp)
  1051c1:	0f 87 f1 00 00 00    	ja     1052b8 <default_alloc_pages+0x159>
        int i;
        for(i=0;i<n;i++){//对前n页进行操作
  1051c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1051ce:	eb 7b                	jmp    10524b <default_alloc_pages+0xec>
  1051d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1051d3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  1051d6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1051d9:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le); 
  1051dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link); //转换为页
  1051df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1051e2:	83 e8 0c             	sub    $0xc,%eax
  1051e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp); //PG_reserved = '1'
  1051e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1051eb:	83 c0 04             	add    $0x4,%eax
  1051ee:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  1051f5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1051f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1051fb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1051fe:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);//PG_property = '0'
  105201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105204:	83 c0 04             	add    $0x4,%eax
  105207:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  10520e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105211:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105214:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105217:	0f b3 10             	btr    %edx,(%eax)
  10521a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10521d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
  105220:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105223:	8b 40 04             	mov    0x4(%eax),%eax
  105226:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105229:	8b 12                	mov    (%edx),%edx
  10522b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10522e:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  105231:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105237:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10523a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10523d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105240:	89 10                	mov    %edx,(%eax)
          list_del(le); //将此页从free_list中清除
          le = len;
  105242:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105245:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for(i=0;i<n;i++){//对前n页进行操作
  105248:	ff 45 f0             	incl   -0x10(%ebp)
  10524b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10524e:	39 45 08             	cmp    %eax,0x8(%ebp)
  105251:	0f 87 79 ff ff ff    	ja     1051d0 <default_alloc_pages+0x71>
        }
        if(p->property>n){ //如果页块大小大于所需大小，分割页块
  105257:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10525a:	8b 40 08             	mov    0x8(%eax),%eax
  10525d:	39 45 08             	cmp    %eax,0x8(%ebp)
  105260:	73 12                	jae    105274 <default_alloc_pages+0x115>
          (le2page(le,page_link))->property = p->property-n;
  105262:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105265:	8b 40 08             	mov    0x8(%eax),%eax
  105268:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10526b:	83 ea 0c             	sub    $0xc,%edx
  10526e:	2b 45 08             	sub    0x8(%ebp),%eax
  105271:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
  105274:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105277:	83 c0 04             	add    $0x4,%eax
  10527a:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  105281:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  105284:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105287:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10528a:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
  10528d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105290:	83 c0 04             	add    $0x4,%eax
  105293:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  10529a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10529d:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1052a0:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1052a3:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n; //减去已经分配的页块大小
  1052a6:	a1 48 c1 16 00       	mov    0x16c148,%eax
  1052ab:	2b 45 08             	sub    0x8(%ebp),%eax
  1052ae:	a3 48 c1 16 00       	mov    %eax,0x16c148
        return p;
  1052b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052b6:	eb 21                	jmp    1052d9 <default_alloc_pages+0x17a>
  1052b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052bb:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->next;
  1052be:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1052c1:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {//遍历整个链表
  1052c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1052c7:	81 7d f4 40 c1 16 00 	cmpl   $0x16c140,-0xc(%ebp)
  1052ce:	0f 85 db fe ff ff    	jne    1051af <default_alloc_pages+0x50>
      }
    }
    return NULL;
  1052d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1052d9:	c9                   	leave  
  1052da:	c3                   	ret    

001052db <default_free_pages>:
    list_add_before(le, &(base->page_link));
}*/


static void
default_free_pages(struct Page *base, size_t n) {
  1052db:	55                   	push   %ebp
  1052dc:	89 e5                	mov    %esp,%ebp
  1052de:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);  
  1052e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1052e5:	75 24                	jne    10530b <default_free_pages+0x30>
  1052e7:	c7 44 24 0c a0 7b 10 	movl   $0x107ba0,0xc(%esp)
  1052ee:	00 
  1052ef:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1052f6:	00 
  1052f7:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  1052fe:	00 
  1052ff:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105306:	e8 ee b0 ff ff       	call   1003f9 <__panic>
    assert(PageReserved(base));    //检查需要释放的页块是否已经被分配
  10530b:	8b 45 08             	mov    0x8(%ebp),%eax
  10530e:	83 c0 04             	add    $0x4,%eax
  105311:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  105318:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10531b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10531e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105321:	0f a3 10             	bt     %edx,(%eax)
  105324:	19 c0                	sbb    %eax,%eax
  105326:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  105329:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10532d:	0f 95 c0             	setne  %al
  105330:	0f b6 c0             	movzbl %al,%eax
  105333:	85 c0                	test   %eax,%eax
  105335:	75 24                	jne    10535b <default_free_pages+0x80>
  105337:	c7 44 24 0c e1 7b 10 	movl   $0x107be1,0xc(%esp)
  10533e:	00 
  10533f:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105346:	00 
  105347:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  10534e:	00 
  10534f:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105356:	e8 9e b0 ff ff       	call   1003f9 <__panic>
    list_entry_t *le = &free_list; 
  10535b:	c7 45 f4 40 c1 16 00 	movl   $0x16c140,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {//找到释放的位置
  105362:	eb 11                	jmp    105375 <default_free_pages+0x9a>
      p = le2page(le, page_link);
  105364:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105367:	83 e8 0c             	sub    $0xc,%eax
  10536a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){    
  10536d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105370:	3b 45 08             	cmp    0x8(%ebp),%eax
  105373:	77 1a                	ja     10538f <default_free_pages+0xb4>
  105375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10537b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10537e:	8b 40 04             	mov    0x4(%eax),%eax
    while((le=list_next(le)) != &free_list) {//找到释放的位置
  105381:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105384:	81 7d f4 40 c1 16 00 	cmpl   $0x16c140,-0xc(%ebp)
  10538b:	75 d7                	jne    105364 <default_free_pages+0x89>
  10538d:	eb 01                	jmp    105390 <default_free_pages+0xb5>
        break;
  10538f:	90                   	nop
      }
    }
    for(p=base;p<base+n;p++){              
  105390:	8b 45 08             	mov    0x8(%ebp),%eax
  105393:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105396:	eb 4b                	jmp    1053e3 <default_free_pages+0x108>
      list_add_before(le, &(p->page_link)); //在这个位置开始，插入释放数量的空页
  105398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10539b:	8d 50 0c             	lea    0xc(%eax),%edx
  10539e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1053a4:	89 55 d8             	mov    %edx,-0x28(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1053a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053aa:	8b 00                	mov    (%eax),%eax
  1053ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1053b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1053b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
  1053bb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1053be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1053c1:	89 10                	mov    %edx,(%eax)
  1053c3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1053c6:	8b 10                	mov    (%eax),%edx
  1053c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1053cb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1053ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1053d1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1053d4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1053d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1053da:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1053dd:	89 10                	mov    %edx,(%eax)
    for(p=base;p<base+n;p++){              
  1053df:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
  1053e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1053e6:	89 d0                	mov    %edx,%eax
  1053e8:	c1 e0 02             	shl    $0x2,%eax
  1053eb:	01 d0                	add    %edx,%eax
  1053ed:	c1 e0 02             	shl    $0x2,%eax
  1053f0:	89 c2                	mov    %eax,%edx
  1053f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1053f5:	01 d0                	add    %edx,%eax
  1053f7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1053fa:	72 9c                	jb     105398 <default_free_pages+0xbd>
    }
    base->flags = 0;         //修改标志位
  1053fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1053ff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);   //修改引用次数为0 
  105406:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10540d:	00 
  10540e:	8b 45 08             	mov    0x8(%ebp),%eax
  105411:	89 04 24             	mov    %eax,(%esp)
  105414:	e8 b8 fb ff ff       	call   104fd1 <set_page_ref>
    ClearPageProperty(base);
  105419:	8b 45 08             	mov    0x8(%ebp),%eax
  10541c:	83 c0 04             	add    $0x4,%eax
  10541f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  105426:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105429:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10542c:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10542f:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
  105432:	8b 45 08             	mov    0x8(%ebp),%eax
  105435:	83 c0 04             	add    $0x4,%eax
  105438:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  10543f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105442:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105445:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105448:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;      //设置连续大小为n
  10544b:	8b 45 08             	mov    0x8(%ebp),%eax
  10544e:	8b 55 0c             	mov    0xc(%ebp),%edx
  105451:	89 50 08             	mov    %edx,0x8(%eax)
    //如果是高位，则向高地址合并
    p = le2page(le,page_link) ;
  105454:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105457:	83 e8 0c             	sub    $0xc,%eax
  10545a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  //满足base+n==p，因此，尝试向后合并空闲页。
  //如果能合并，那么base的连续空闲页加上p的连续空闲页，且p的连续空闲页置为0；
  //如果之后的页不能合并，那么p->property一直为0，下面的代码不会对它产生影响。
    if( base+n == p ){
  10545d:	8b 55 0c             	mov    0xc(%ebp),%edx
  105460:	89 d0                	mov    %edx,%eax
  105462:	c1 e0 02             	shl    $0x2,%eax
  105465:	01 d0                	add    %edx,%eax
  105467:	c1 e0 02             	shl    $0x2,%eax
  10546a:	89 c2                	mov    %eax,%edx
  10546c:	8b 45 08             	mov    0x8(%ebp),%eax
  10546f:	01 d0                	add    %edx,%eax
  105471:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  105474:	75 1e                	jne    105494 <default_free_pages+0x1b9>
      base->property += p->property;
  105476:	8b 45 08             	mov    0x8(%ebp),%eax
  105479:	8b 50 08             	mov    0x8(%eax),%edx
  10547c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10547f:	8b 40 08             	mov    0x8(%eax),%eax
  105482:	01 c2                	add    %eax,%edx
  105484:	8b 45 08             	mov    0x8(%ebp),%eax
  105487:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
  10548a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10548d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
     //如果是低位且在范围内，则向低地址合并
     //获取基地址页的前一个页，如果为空，那么循环查找之前所有为空，能够合并的页
    le = list_prev(&(base->page_link));
  105494:	8b 45 08             	mov    0x8(%ebp),%eax
  105497:	83 c0 0c             	add    $0xc,%eax
  10549a:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return listelm->prev;
  10549d:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1054a0:	8b 00                	mov    (%eax),%eax
  1054a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
  1054a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054a8:	83 e8 0c             	sub    $0xc,%eax
  1054ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){ //满足条件，未分配则合并
  1054ae:	81 7d f4 40 c1 16 00 	cmpl   $0x16c140,-0xc(%ebp)
  1054b5:	74 57                	je     10550e <default_free_pages+0x233>
  1054b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1054ba:	83 e8 14             	sub    $0x14,%eax
  1054bd:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1054c0:	75 4c                	jne    10550e <default_free_pages+0x233>
      while(le!=&free_list){
  1054c2:	eb 41                	jmp    105505 <default_free_pages+0x22a>
        if(p->property){ //连续
  1054c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054c7:	8b 40 08             	mov    0x8(%eax),%eax
  1054ca:	85 c0                	test   %eax,%eax
  1054cc:	74 20                	je     1054ee <default_free_pages+0x213>
          p->property += base->property;
  1054ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054d1:	8b 50 08             	mov    0x8(%eax),%edx
  1054d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1054d7:	8b 40 08             	mov    0x8(%eax),%eax
  1054da:	01 c2                	add    %eax,%edx
  1054dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054df:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
  1054e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1054e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          //不断更新前一个页p的property值，并将base->property置为0
          break;
  1054ec:	eb 20                	jmp    10550e <default_free_pages+0x233>
  1054ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054f1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  1054f4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1054f7:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
  1054f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
  1054fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054ff:	83 e8 0c             	sub    $0xc,%eax
  105502:	89 45 f0             	mov    %eax,-0x10(%ebp)
      while(le!=&free_list){
  105505:	81 7d f4 40 c1 16 00 	cmpl   $0x16c140,-0xc(%ebp)
  10550c:	75 b6                	jne    1054c4 <default_free_pages+0x1e9>
      }
    }

    nr_free += n;//空闲页数量加n
  10550e:	8b 15 48 c1 16 00    	mov    0x16c148,%edx
  105514:	8b 45 0c             	mov    0xc(%ebp),%eax
  105517:	01 d0                	add    %edx,%eax
  105519:	a3 48 c1 16 00       	mov    %eax,0x16c148
    return ;
  10551e:	90                   	nop
} 
  10551f:	c9                   	leave  
  105520:	c3                   	ret    

00105521 <default_nr_free_pages>:


static size_t
default_nr_free_pages(void) {
  105521:	55                   	push   %ebp
  105522:	89 e5                	mov    %esp,%ebp
    return nr_free;
  105524:	a1 48 c1 16 00       	mov    0x16c148,%eax
}
  105529:	5d                   	pop    %ebp
  10552a:	c3                   	ret    

0010552b <basic_check>:

static void
basic_check(void) {
  10552b:	55                   	push   %ebp
  10552c:	89 e5                	mov    %esp,%ebp
  10552e:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  105531:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10553b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10553e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105541:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  105544:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10554b:	e8 80 d8 ff ff       	call   102dd0 <alloc_pages>
  105550:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105553:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  105557:	75 24                	jne    10557d <basic_check+0x52>
  105559:	c7 44 24 0c f4 7b 10 	movl   $0x107bf4,0xc(%esp)
  105560:	00 
  105561:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105568:	00 
  105569:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
  105570:	00 
  105571:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105578:	e8 7c ae ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  10557d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105584:	e8 47 d8 ff ff       	call   102dd0 <alloc_pages>
  105589:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10558c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105590:	75 24                	jne    1055b6 <basic_check+0x8b>
  105592:	c7 44 24 0c 10 7c 10 	movl   $0x107c10,0xc(%esp)
  105599:	00 
  10559a:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1055a1:	00 
  1055a2:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
  1055a9:	00 
  1055aa:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1055b1:	e8 43 ae ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1055b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1055bd:	e8 0e d8 ff ff       	call   102dd0 <alloc_pages>
  1055c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1055c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1055c9:	75 24                	jne    1055ef <basic_check+0xc4>
  1055cb:	c7 44 24 0c 2c 7c 10 	movl   $0x107c2c,0xc(%esp)
  1055d2:	00 
  1055d3:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1055da:	00 
  1055db:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
  1055e2:	00 
  1055e3:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1055ea:	e8 0a ae ff ff       	call   1003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  1055ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055f2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1055f5:	74 10                	je     105607 <basic_check+0xdc>
  1055f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1055fd:	74 08                	je     105607 <basic_check+0xdc>
  1055ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105602:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  105605:	75 24                	jne    10562b <basic_check+0x100>
  105607:	c7 44 24 0c 48 7c 10 	movl   $0x107c48,0xc(%esp)
  10560e:	00 
  10560f:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105616:	00 
  105617:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
  10561e:	00 
  10561f:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105626:	e8 ce ad ff ff       	call   1003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10562b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10562e:	89 04 24             	mov    %eax,(%esp)
  105631:	e8 91 f9 ff ff       	call   104fc7 <page_ref>
  105636:	85 c0                	test   %eax,%eax
  105638:	75 1e                	jne    105658 <basic_check+0x12d>
  10563a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10563d:	89 04 24             	mov    %eax,(%esp)
  105640:	e8 82 f9 ff ff       	call   104fc7 <page_ref>
  105645:	85 c0                	test   %eax,%eax
  105647:	75 0f                	jne    105658 <basic_check+0x12d>
  105649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10564c:	89 04 24             	mov    %eax,(%esp)
  10564f:	e8 73 f9 ff ff       	call   104fc7 <page_ref>
  105654:	85 c0                	test   %eax,%eax
  105656:	74 24                	je     10567c <basic_check+0x151>
  105658:	c7 44 24 0c 6c 7c 10 	movl   $0x107c6c,0xc(%esp)
  10565f:	00 
  105660:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105667:	00 
  105668:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
  10566f:	00 
  105670:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105677:	e8 7d ad ff ff       	call   1003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  10567c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10567f:	89 04 24             	mov    %eax,(%esp)
  105682:	e8 2a f9 ff ff       	call   104fb1 <page2pa>
  105687:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  10568d:	c1 e2 0c             	shl    $0xc,%edx
  105690:	39 d0                	cmp    %edx,%eax
  105692:	72 24                	jb     1056b8 <basic_check+0x18d>
  105694:	c7 44 24 0c a8 7c 10 	movl   $0x107ca8,0xc(%esp)
  10569b:	00 
  10569c:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1056a3:	00 
  1056a4:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
  1056ab:	00 
  1056ac:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1056b3:	e8 41 ad ff ff       	call   1003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1056b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056bb:	89 04 24             	mov    %eax,(%esp)
  1056be:	e8 ee f8 ff ff       	call   104fb1 <page2pa>
  1056c3:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  1056c9:	c1 e2 0c             	shl    $0xc,%edx
  1056cc:	39 d0                	cmp    %edx,%eax
  1056ce:	72 24                	jb     1056f4 <basic_check+0x1c9>
  1056d0:	c7 44 24 0c c5 7c 10 	movl   $0x107cc5,0xc(%esp)
  1056d7:	00 
  1056d8:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1056df:	00 
  1056e0:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
  1056e7:	00 
  1056e8:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1056ef:	e8 05 ad ff ff       	call   1003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  1056f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1056f7:	89 04 24             	mov    %eax,(%esp)
  1056fa:	e8 b2 f8 ff ff       	call   104fb1 <page2pa>
  1056ff:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  105705:	c1 e2 0c             	shl    $0xc,%edx
  105708:	39 d0                	cmp    %edx,%eax
  10570a:	72 24                	jb     105730 <basic_check+0x205>
  10570c:	c7 44 24 0c e2 7c 10 	movl   $0x107ce2,0xc(%esp)
  105713:	00 
  105714:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  10571b:	00 
  10571c:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
  105723:	00 
  105724:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  10572b:	e8 c9 ac ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  105730:	a1 40 c1 16 00       	mov    0x16c140,%eax
  105735:	8b 15 44 c1 16 00    	mov    0x16c144,%edx
  10573b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10573e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105741:	c7 45 dc 40 c1 16 00 	movl   $0x16c140,-0x24(%ebp)
    elm->prev = elm->next = elm;
  105748:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10574b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10574e:	89 50 04             	mov    %edx,0x4(%eax)
  105751:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105754:	8b 50 04             	mov    0x4(%eax),%edx
  105757:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10575a:	89 10                	mov    %edx,(%eax)
  10575c:	c7 45 e0 40 c1 16 00 	movl   $0x16c140,-0x20(%ebp)
    return list->next == list;
  105763:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105766:	8b 40 04             	mov    0x4(%eax),%eax
  105769:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  10576c:	0f 94 c0             	sete   %al
  10576f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105772:	85 c0                	test   %eax,%eax
  105774:	75 24                	jne    10579a <basic_check+0x26f>
  105776:	c7 44 24 0c ff 7c 10 	movl   $0x107cff,0xc(%esp)
  10577d:	00 
  10577e:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105785:	00 
  105786:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
  10578d:	00 
  10578e:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105795:	e8 5f ac ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  10579a:	a1 48 c1 16 00       	mov    0x16c148,%eax
  10579f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1057a2:	c7 05 48 c1 16 00 00 	movl   $0x0,0x16c148
  1057a9:	00 00 00 

    assert(alloc_page() == NULL);
  1057ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1057b3:	e8 18 d6 ff ff       	call   102dd0 <alloc_pages>
  1057b8:	85 c0                	test   %eax,%eax
  1057ba:	74 24                	je     1057e0 <basic_check+0x2b5>
  1057bc:	c7 44 24 0c 16 7d 10 	movl   $0x107d16,0xc(%esp)
  1057c3:	00 
  1057c4:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1057cb:	00 
  1057cc:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
  1057d3:	00 
  1057d4:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1057db:	e8 19 ac ff ff       	call   1003f9 <__panic>

    free_page(p0);
  1057e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1057e7:	00 
  1057e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057eb:	89 04 24             	mov    %eax,(%esp)
  1057ee:	e8 15 d6 ff ff       	call   102e08 <free_pages>
    free_page(p1);
  1057f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1057fa:	00 
  1057fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057fe:	89 04 24             	mov    %eax,(%esp)
  105801:	e8 02 d6 ff ff       	call   102e08 <free_pages>
    free_page(p2);
  105806:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10580d:	00 
  10580e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105811:	89 04 24             	mov    %eax,(%esp)
  105814:	e8 ef d5 ff ff       	call   102e08 <free_pages>
    assert(nr_free == 3);
  105819:	a1 48 c1 16 00       	mov    0x16c148,%eax
  10581e:	83 f8 03             	cmp    $0x3,%eax
  105821:	74 24                	je     105847 <basic_check+0x31c>
  105823:	c7 44 24 0c 2b 7d 10 	movl   $0x107d2b,0xc(%esp)
  10582a:	00 
  10582b:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105832:	00 
  105833:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
  10583a:	00 
  10583b:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105842:	e8 b2 ab ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  105847:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10584e:	e8 7d d5 ff ff       	call   102dd0 <alloc_pages>
  105853:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105856:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10585a:	75 24                	jne    105880 <basic_check+0x355>
  10585c:	c7 44 24 0c f4 7b 10 	movl   $0x107bf4,0xc(%esp)
  105863:	00 
  105864:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  10586b:	00 
  10586c:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
  105873:	00 
  105874:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  10587b:	e8 79 ab ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  105880:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105887:	e8 44 d5 ff ff       	call   102dd0 <alloc_pages>
  10588c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10588f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105893:	75 24                	jne    1058b9 <basic_check+0x38e>
  105895:	c7 44 24 0c 10 7c 10 	movl   $0x107c10,0xc(%esp)
  10589c:	00 
  10589d:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1058a4:	00 
  1058a5:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
  1058ac:	00 
  1058ad:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1058b4:	e8 40 ab ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1058b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1058c0:	e8 0b d5 ff ff       	call   102dd0 <alloc_pages>
  1058c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1058c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1058cc:	75 24                	jne    1058f2 <basic_check+0x3c7>
  1058ce:	c7 44 24 0c 2c 7c 10 	movl   $0x107c2c,0xc(%esp)
  1058d5:	00 
  1058d6:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1058dd:	00 
  1058de:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
  1058e5:	00 
  1058e6:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1058ed:	e8 07 ab ff ff       	call   1003f9 <__panic>

    assert(alloc_page() == NULL);
  1058f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1058f9:	e8 d2 d4 ff ff       	call   102dd0 <alloc_pages>
  1058fe:	85 c0                	test   %eax,%eax
  105900:	74 24                	je     105926 <basic_check+0x3fb>
  105902:	c7 44 24 0c 16 7d 10 	movl   $0x107d16,0xc(%esp)
  105909:	00 
  10590a:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105911:	00 
  105912:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
  105919:	00 
  10591a:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105921:	e8 d3 aa ff ff       	call   1003f9 <__panic>

    free_page(p0);
  105926:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10592d:	00 
  10592e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105931:	89 04 24             	mov    %eax,(%esp)
  105934:	e8 cf d4 ff ff       	call   102e08 <free_pages>
  105939:	c7 45 d8 40 c1 16 00 	movl   $0x16c140,-0x28(%ebp)
  105940:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105943:	8b 40 04             	mov    0x4(%eax),%eax
  105946:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  105949:	0f 94 c0             	sete   %al
  10594c:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  10594f:	85 c0                	test   %eax,%eax
  105951:	74 24                	je     105977 <basic_check+0x44c>
  105953:	c7 44 24 0c 38 7d 10 	movl   $0x107d38,0xc(%esp)
  10595a:	00 
  10595b:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105962:	00 
  105963:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
  10596a:	00 
  10596b:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105972:	e8 82 aa ff ff       	call   1003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  105977:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10597e:	e8 4d d4 ff ff       	call   102dd0 <alloc_pages>
  105983:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105986:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105989:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10598c:	74 24                	je     1059b2 <basic_check+0x487>
  10598e:	c7 44 24 0c 50 7d 10 	movl   $0x107d50,0xc(%esp)
  105995:	00 
  105996:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  10599d:	00 
  10599e:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
  1059a5:	00 
  1059a6:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1059ad:	e8 47 aa ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  1059b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1059b9:	e8 12 d4 ff ff       	call   102dd0 <alloc_pages>
  1059be:	85 c0                	test   %eax,%eax
  1059c0:	74 24                	je     1059e6 <basic_check+0x4bb>
  1059c2:	c7 44 24 0c 16 7d 10 	movl   $0x107d16,0xc(%esp)
  1059c9:	00 
  1059ca:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1059d1:	00 
  1059d2:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
  1059d9:	00 
  1059da:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1059e1:	e8 13 aa ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  1059e6:	a1 48 c1 16 00       	mov    0x16c148,%eax
  1059eb:	85 c0                	test   %eax,%eax
  1059ed:	74 24                	je     105a13 <basic_check+0x4e8>
  1059ef:	c7 44 24 0c 69 7d 10 	movl   $0x107d69,0xc(%esp)
  1059f6:	00 
  1059f7:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1059fe:	00 
  1059ff:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
  105a06:	00 
  105a07:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105a0e:	e8 e6 a9 ff ff       	call   1003f9 <__panic>
    free_list = free_list_store;
  105a13:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105a16:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105a19:	a3 40 c1 16 00       	mov    %eax,0x16c140
  105a1e:	89 15 44 c1 16 00    	mov    %edx,0x16c144
    nr_free = nr_free_store;
  105a24:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a27:	a3 48 c1 16 00       	mov    %eax,0x16c148

    free_page(p);
  105a2c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105a33:	00 
  105a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a37:	89 04 24             	mov    %eax,(%esp)
  105a3a:	e8 c9 d3 ff ff       	call   102e08 <free_pages>
    free_page(p1);
  105a3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105a46:	00 
  105a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a4a:	89 04 24             	mov    %eax,(%esp)
  105a4d:	e8 b6 d3 ff ff       	call   102e08 <free_pages>
    free_page(p2);
  105a52:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105a59:	00 
  105a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a5d:	89 04 24             	mov    %eax,(%esp)
  105a60:	e8 a3 d3 ff ff       	call   102e08 <free_pages>
}
  105a65:	90                   	nop
  105a66:	c9                   	leave  
  105a67:	c3                   	ret    

00105a68 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  105a68:	55                   	push   %ebp
  105a69:	89 e5                	mov    %esp,%ebp
  105a6b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  105a71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105a78:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  105a7f:	c7 45 ec 40 c1 16 00 	movl   $0x16c140,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105a86:	eb 6a                	jmp    105af2 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  105a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a8b:	83 e8 0c             	sub    $0xc,%eax
  105a8e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  105a91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105a94:	83 c0 04             	add    $0x4,%eax
  105a97:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  105a9e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105aa1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105aa4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105aa7:	0f a3 10             	bt     %edx,(%eax)
  105aaa:	19 c0                	sbb    %eax,%eax
  105aac:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  105aaf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  105ab3:	0f 95 c0             	setne  %al
  105ab6:	0f b6 c0             	movzbl %al,%eax
  105ab9:	85 c0                	test   %eax,%eax
  105abb:	75 24                	jne    105ae1 <default_check+0x79>
  105abd:	c7 44 24 0c 76 7d 10 	movl   $0x107d76,0xc(%esp)
  105ac4:	00 
  105ac5:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105acc:	00 
  105acd:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
  105ad4:	00 
  105ad5:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105adc:	e8 18 a9 ff ff       	call   1003f9 <__panic>
        count ++, total += p->property;
  105ae1:	ff 45 f4             	incl   -0xc(%ebp)
  105ae4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105ae7:	8b 50 08             	mov    0x8(%eax),%edx
  105aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105aed:	01 d0                	add    %edx,%eax
  105aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105af5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  105af8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105afb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105afe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105b01:	81 7d ec 40 c1 16 00 	cmpl   $0x16c140,-0x14(%ebp)
  105b08:	0f 85 7a ff ff ff    	jne    105a88 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  105b0e:	e8 28 d3 ff ff       	call   102e3b <nr_free_pages>
  105b13:	89 c2                	mov    %eax,%edx
  105b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b18:	39 c2                	cmp    %eax,%edx
  105b1a:	74 24                	je     105b40 <default_check+0xd8>
  105b1c:	c7 44 24 0c 86 7d 10 	movl   $0x107d86,0xc(%esp)
  105b23:	00 
  105b24:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105b2b:	00 
  105b2c:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
  105b33:	00 
  105b34:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105b3b:	e8 b9 a8 ff ff       	call   1003f9 <__panic>

    basic_check();
  105b40:	e8 e6 f9 ff ff       	call   10552b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  105b45:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105b4c:	e8 7f d2 ff ff       	call   102dd0 <alloc_pages>
  105b51:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  105b54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b58:	75 24                	jne    105b7e <default_check+0x116>
  105b5a:	c7 44 24 0c 9f 7d 10 	movl   $0x107d9f,0xc(%esp)
  105b61:	00 
  105b62:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105b69:	00 
  105b6a:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
  105b71:	00 
  105b72:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105b79:	e8 7b a8 ff ff       	call   1003f9 <__panic>
    assert(!PageProperty(p0));
  105b7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105b81:	83 c0 04             	add    $0x4,%eax
  105b84:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  105b8b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105b8e:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105b91:	8b 55 c0             	mov    -0x40(%ebp),%edx
  105b94:	0f a3 10             	bt     %edx,(%eax)
  105b97:	19 c0                	sbb    %eax,%eax
  105b99:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  105b9c:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  105ba0:	0f 95 c0             	setne  %al
  105ba3:	0f b6 c0             	movzbl %al,%eax
  105ba6:	85 c0                	test   %eax,%eax
  105ba8:	74 24                	je     105bce <default_check+0x166>
  105baa:	c7 44 24 0c aa 7d 10 	movl   $0x107daa,0xc(%esp)
  105bb1:	00 
  105bb2:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105bb9:	00 
  105bba:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
  105bc1:	00 
  105bc2:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105bc9:	e8 2b a8 ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  105bce:	a1 40 c1 16 00       	mov    0x16c140,%eax
  105bd3:	8b 15 44 c1 16 00    	mov    0x16c144,%edx
  105bd9:	89 45 80             	mov    %eax,-0x80(%ebp)
  105bdc:	89 55 84             	mov    %edx,-0x7c(%ebp)
  105bdf:	c7 45 b0 40 c1 16 00 	movl   $0x16c140,-0x50(%ebp)
    elm->prev = elm->next = elm;
  105be6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105be9:	8b 55 b0             	mov    -0x50(%ebp),%edx
  105bec:	89 50 04             	mov    %edx,0x4(%eax)
  105bef:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105bf2:	8b 50 04             	mov    0x4(%eax),%edx
  105bf5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105bf8:	89 10                	mov    %edx,(%eax)
  105bfa:	c7 45 b4 40 c1 16 00 	movl   $0x16c140,-0x4c(%ebp)
    return list->next == list;
  105c01:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105c04:	8b 40 04             	mov    0x4(%eax),%eax
  105c07:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  105c0a:	0f 94 c0             	sete   %al
  105c0d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105c10:	85 c0                	test   %eax,%eax
  105c12:	75 24                	jne    105c38 <default_check+0x1d0>
  105c14:	c7 44 24 0c ff 7c 10 	movl   $0x107cff,0xc(%esp)
  105c1b:	00 
  105c1c:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105c23:	00 
  105c24:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
  105c2b:	00 
  105c2c:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105c33:	e8 c1 a7 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  105c38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105c3f:	e8 8c d1 ff ff       	call   102dd0 <alloc_pages>
  105c44:	85 c0                	test   %eax,%eax
  105c46:	74 24                	je     105c6c <default_check+0x204>
  105c48:	c7 44 24 0c 16 7d 10 	movl   $0x107d16,0xc(%esp)
  105c4f:	00 
  105c50:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105c57:	00 
  105c58:	c7 44 24 04 af 01 00 	movl   $0x1af,0x4(%esp)
  105c5f:	00 
  105c60:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105c67:	e8 8d a7 ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  105c6c:	a1 48 c1 16 00       	mov    0x16c148,%eax
  105c71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  105c74:	c7 05 48 c1 16 00 00 	movl   $0x0,0x16c148
  105c7b:	00 00 00 

    free_pages(p0 + 2, 3);
  105c7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c81:	83 c0 28             	add    $0x28,%eax
  105c84:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105c8b:	00 
  105c8c:	89 04 24             	mov    %eax,(%esp)
  105c8f:	e8 74 d1 ff ff       	call   102e08 <free_pages>
    assert(alloc_pages(4) == NULL);
  105c94:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  105c9b:	e8 30 d1 ff ff       	call   102dd0 <alloc_pages>
  105ca0:	85 c0                	test   %eax,%eax
  105ca2:	74 24                	je     105cc8 <default_check+0x260>
  105ca4:	c7 44 24 0c bc 7d 10 	movl   $0x107dbc,0xc(%esp)
  105cab:	00 
  105cac:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105cb3:	00 
  105cb4:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
  105cbb:	00 
  105cbc:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105cc3:	e8 31 a7 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  105cc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ccb:	83 c0 28             	add    $0x28,%eax
  105cce:	83 c0 04             	add    $0x4,%eax
  105cd1:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  105cd8:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105cdb:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105cde:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105ce1:	0f a3 10             	bt     %edx,(%eax)
  105ce4:	19 c0                	sbb    %eax,%eax
  105ce6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  105ce9:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  105ced:	0f 95 c0             	setne  %al
  105cf0:	0f b6 c0             	movzbl %al,%eax
  105cf3:	85 c0                	test   %eax,%eax
  105cf5:	74 0e                	je     105d05 <default_check+0x29d>
  105cf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105cfa:	83 c0 28             	add    $0x28,%eax
  105cfd:	8b 40 08             	mov    0x8(%eax),%eax
  105d00:	83 f8 03             	cmp    $0x3,%eax
  105d03:	74 24                	je     105d29 <default_check+0x2c1>
  105d05:	c7 44 24 0c d4 7d 10 	movl   $0x107dd4,0xc(%esp)
  105d0c:	00 
  105d0d:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105d14:	00 
  105d15:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
  105d1c:	00 
  105d1d:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105d24:	e8 d0 a6 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105d29:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105d30:	e8 9b d0 ff ff       	call   102dd0 <alloc_pages>
  105d35:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105d38:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  105d3c:	75 24                	jne    105d62 <default_check+0x2fa>
  105d3e:	c7 44 24 0c 00 7e 10 	movl   $0x107e00,0xc(%esp)
  105d45:	00 
  105d46:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105d4d:	00 
  105d4e:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
  105d55:	00 
  105d56:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105d5d:	e8 97 a6 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  105d62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105d69:	e8 62 d0 ff ff       	call   102dd0 <alloc_pages>
  105d6e:	85 c0                	test   %eax,%eax
  105d70:	74 24                	je     105d96 <default_check+0x32e>
  105d72:	c7 44 24 0c 16 7d 10 	movl   $0x107d16,0xc(%esp)
  105d79:	00 
  105d7a:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105d81:	00 
  105d82:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
  105d89:	00 
  105d8a:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105d91:	e8 63 a6 ff ff       	call   1003f9 <__panic>
    assert(p0 + 2 == p1);
  105d96:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d99:	83 c0 28             	add    $0x28,%eax
  105d9c:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  105d9f:	74 24                	je     105dc5 <default_check+0x35d>
  105da1:	c7 44 24 0c 1e 7e 10 	movl   $0x107e1e,0xc(%esp)
  105da8:	00 
  105da9:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105db0:	00 
  105db1:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
  105db8:	00 
  105db9:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105dc0:	e8 34 a6 ff ff       	call   1003f9 <__panic>

    p2 = p0 + 1;
  105dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105dc8:	83 c0 14             	add    $0x14,%eax
  105dcb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  105dce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105dd5:	00 
  105dd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105dd9:	89 04 24             	mov    %eax,(%esp)
  105ddc:	e8 27 d0 ff ff       	call   102e08 <free_pages>
    free_pages(p1, 3);
  105de1:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105de8:	00 
  105de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105dec:	89 04 24             	mov    %eax,(%esp)
  105def:	e8 14 d0 ff ff       	call   102e08 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105df4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105df7:	83 c0 04             	add    $0x4,%eax
  105dfa:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105e01:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105e04:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105e07:	8b 55 a0             	mov    -0x60(%ebp),%edx
  105e0a:	0f a3 10             	bt     %edx,(%eax)
  105e0d:	19 c0                	sbb    %eax,%eax
  105e0f:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105e12:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105e16:	0f 95 c0             	setne  %al
  105e19:	0f b6 c0             	movzbl %al,%eax
  105e1c:	85 c0                	test   %eax,%eax
  105e1e:	74 0b                	je     105e2b <default_check+0x3c3>
  105e20:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e23:	8b 40 08             	mov    0x8(%eax),%eax
  105e26:	83 f8 01             	cmp    $0x1,%eax
  105e29:	74 24                	je     105e4f <default_check+0x3e7>
  105e2b:	c7 44 24 0c 2c 7e 10 	movl   $0x107e2c,0xc(%esp)
  105e32:	00 
  105e33:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105e3a:	00 
  105e3b:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
  105e42:	00 
  105e43:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105e4a:	e8 aa a5 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e52:	83 c0 04             	add    $0x4,%eax
  105e55:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  105e5c:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105e5f:	8b 45 90             	mov    -0x70(%ebp),%eax
  105e62:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105e65:	0f a3 10             	bt     %edx,(%eax)
  105e68:	19 c0                	sbb    %eax,%eax
  105e6a:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  105e6d:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105e71:	0f 95 c0             	setne  %al
  105e74:	0f b6 c0             	movzbl %al,%eax
  105e77:	85 c0                	test   %eax,%eax
  105e79:	74 0b                	je     105e86 <default_check+0x41e>
  105e7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e7e:	8b 40 08             	mov    0x8(%eax),%eax
  105e81:	83 f8 03             	cmp    $0x3,%eax
  105e84:	74 24                	je     105eaa <default_check+0x442>
  105e86:	c7 44 24 0c 54 7e 10 	movl   $0x107e54,0xc(%esp)
  105e8d:	00 
  105e8e:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105e95:	00 
  105e96:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
  105e9d:	00 
  105e9e:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105ea5:	e8 4f a5 ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  105eaa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105eb1:	e8 1a cf ff ff       	call   102dd0 <alloc_pages>
  105eb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105eb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ebc:	83 e8 14             	sub    $0x14,%eax
  105ebf:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105ec2:	74 24                	je     105ee8 <default_check+0x480>
  105ec4:	c7 44 24 0c 7a 7e 10 	movl   $0x107e7a,0xc(%esp)
  105ecb:	00 
  105ecc:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105ed3:	00 
  105ed4:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
  105edb:	00 
  105edc:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105ee3:	e8 11 a5 ff ff       	call   1003f9 <__panic>
    free_page(p0);
  105ee8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105eef:	00 
  105ef0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ef3:	89 04 24             	mov    %eax,(%esp)
  105ef6:	e8 0d cf ff ff       	call   102e08 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  105efb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105f02:	e8 c9 ce ff ff       	call   102dd0 <alloc_pages>
  105f07:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f0d:	83 c0 14             	add    $0x14,%eax
  105f10:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105f13:	74 24                	je     105f39 <default_check+0x4d1>
  105f15:	c7 44 24 0c 98 7e 10 	movl   $0x107e98,0xc(%esp)
  105f1c:	00 
  105f1d:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105f24:	00 
  105f25:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  105f2c:	00 
  105f2d:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105f34:	e8 c0 a4 ff ff       	call   1003f9 <__panic>

    free_pages(p0, 2);
  105f39:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105f40:	00 
  105f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f44:	89 04 24             	mov    %eax,(%esp)
  105f47:	e8 bc ce ff ff       	call   102e08 <free_pages>
    free_page(p2);
  105f4c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105f53:	00 
  105f54:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f57:	89 04 24             	mov    %eax,(%esp)
  105f5a:	e8 a9 ce ff ff       	call   102e08 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105f5f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105f66:	e8 65 ce ff ff       	call   102dd0 <alloc_pages>
  105f6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105f6e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105f72:	75 24                	jne    105f98 <default_check+0x530>
  105f74:	c7 44 24 0c b8 7e 10 	movl   $0x107eb8,0xc(%esp)
  105f7b:	00 
  105f7c:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105f83:	00 
  105f84:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
  105f8b:	00 
  105f8c:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105f93:	e8 61 a4 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  105f98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105f9f:	e8 2c ce ff ff       	call   102dd0 <alloc_pages>
  105fa4:	85 c0                	test   %eax,%eax
  105fa6:	74 24                	je     105fcc <default_check+0x564>
  105fa8:	c7 44 24 0c 16 7d 10 	movl   $0x107d16,0xc(%esp)
  105faf:	00 
  105fb0:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105fb7:	00 
  105fb8:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
  105fbf:	00 
  105fc0:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105fc7:	e8 2d a4 ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  105fcc:	a1 48 c1 16 00       	mov    0x16c148,%eax
  105fd1:	85 c0                	test   %eax,%eax
  105fd3:	74 24                	je     105ff9 <default_check+0x591>
  105fd5:	c7 44 24 0c 69 7d 10 	movl   $0x107d69,0xc(%esp)
  105fdc:	00 
  105fdd:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  105fe4:	00 
  105fe5:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
  105fec:	00 
  105fed:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  105ff4:	e8 00 a4 ff ff       	call   1003f9 <__panic>
    nr_free = nr_free_store;
  105ff9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ffc:	a3 48 c1 16 00       	mov    %eax,0x16c148

    free_list = free_list_store;
  106001:	8b 45 80             	mov    -0x80(%ebp),%eax
  106004:	8b 55 84             	mov    -0x7c(%ebp),%edx
  106007:	a3 40 c1 16 00       	mov    %eax,0x16c140
  10600c:	89 15 44 c1 16 00    	mov    %edx,0x16c144
    free_pages(p0, 5);
  106012:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  106019:	00 
  10601a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10601d:	89 04 24             	mov    %eax,(%esp)
  106020:	e8 e3 cd ff ff       	call   102e08 <free_pages>

    le = &free_list;
  106025:	c7 45 ec 40 c1 16 00 	movl   $0x16c140,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10602c:	eb 5a                	jmp    106088 <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  10602e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106031:	8b 40 04             	mov    0x4(%eax),%eax
  106034:	8b 00                	mov    (%eax),%eax
  106036:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  106039:	75 0d                	jne    106048 <default_check+0x5e0>
  10603b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10603e:	8b 00                	mov    (%eax),%eax
  106040:	8b 40 04             	mov    0x4(%eax),%eax
  106043:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  106046:	74 24                	je     10606c <default_check+0x604>
  106048:	c7 44 24 0c d8 7e 10 	movl   $0x107ed8,0xc(%esp)
  10604f:	00 
  106050:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  106057:	00 
  106058:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
  10605f:	00 
  106060:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  106067:	e8 8d a3 ff ff       	call   1003f9 <__panic>
        struct Page *p = le2page(le, page_link);
  10606c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10606f:	83 e8 0c             	sub    $0xc,%eax
  106072:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  106075:	ff 4d f4             	decl   -0xc(%ebp)
  106078:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10607b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10607e:	8b 40 08             	mov    0x8(%eax),%eax
  106081:	29 c2                	sub    %eax,%edx
  106083:	89 d0                	mov    %edx,%eax
  106085:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106088:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10608b:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  10608e:	8b 45 88             	mov    -0x78(%ebp),%eax
  106091:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  106094:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106097:	81 7d ec 40 c1 16 00 	cmpl   $0x16c140,-0x14(%ebp)
  10609e:	75 8e                	jne    10602e <default_check+0x5c6>
    }
    assert(count == 0);
  1060a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1060a4:	74 24                	je     1060ca <default_check+0x662>
  1060a6:	c7 44 24 0c 05 7f 10 	movl   $0x107f05,0xc(%esp)
  1060ad:	00 
  1060ae:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1060b5:	00 
  1060b6:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
  1060bd:	00 
  1060be:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1060c5:	e8 2f a3 ff ff       	call   1003f9 <__panic>
    assert(total == 0);
  1060ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1060ce:	74 24                	je     1060f4 <default_check+0x68c>
  1060d0:	c7 44 24 0c 10 7f 10 	movl   $0x107f10,0xc(%esp)
  1060d7:	00 
  1060d8:	c7 44 24 08 a6 7b 10 	movl   $0x107ba6,0x8(%esp)
  1060df:	00 
  1060e0:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  1060e7:	00 
  1060e8:	c7 04 24 bb 7b 10 00 	movl   $0x107bbb,(%esp)
  1060ef:	e8 05 a3 ff ff       	call   1003f9 <__panic>
}
  1060f4:	90                   	nop
  1060f5:	c9                   	leave  
  1060f6:	c3                   	ret    

001060f7 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1060f7:	55                   	push   %ebp
  1060f8:	89 e5                	mov    %esp,%ebp
  1060fa:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1060fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  106104:	eb 03                	jmp    106109 <strlen+0x12>
        cnt ++;
  106106:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  106109:	8b 45 08             	mov    0x8(%ebp),%eax
  10610c:	8d 50 01             	lea    0x1(%eax),%edx
  10610f:	89 55 08             	mov    %edx,0x8(%ebp)
  106112:	0f b6 00             	movzbl (%eax),%eax
  106115:	84 c0                	test   %al,%al
  106117:	75 ed                	jne    106106 <strlen+0xf>
    }
    return cnt;
  106119:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10611c:	c9                   	leave  
  10611d:	c3                   	ret    

0010611e <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10611e:	55                   	push   %ebp
  10611f:	89 e5                	mov    %esp,%ebp
  106121:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106124:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10612b:	eb 03                	jmp    106130 <strnlen+0x12>
        cnt ++;
  10612d:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106130:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106133:	3b 45 0c             	cmp    0xc(%ebp),%eax
  106136:	73 10                	jae    106148 <strnlen+0x2a>
  106138:	8b 45 08             	mov    0x8(%ebp),%eax
  10613b:	8d 50 01             	lea    0x1(%eax),%edx
  10613e:	89 55 08             	mov    %edx,0x8(%ebp)
  106141:	0f b6 00             	movzbl (%eax),%eax
  106144:	84 c0                	test   %al,%al
  106146:	75 e5                	jne    10612d <strnlen+0xf>
    }
    return cnt;
  106148:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10614b:	c9                   	leave  
  10614c:	c3                   	ret    

0010614d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10614d:	55                   	push   %ebp
  10614e:	89 e5                	mov    %esp,%ebp
  106150:	57                   	push   %edi
  106151:	56                   	push   %esi
  106152:	83 ec 20             	sub    $0x20,%esp
  106155:	8b 45 08             	mov    0x8(%ebp),%eax
  106158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10615b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10615e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  106161:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106167:	89 d1                	mov    %edx,%ecx
  106169:	89 c2                	mov    %eax,%edx
  10616b:	89 ce                	mov    %ecx,%esi
  10616d:	89 d7                	mov    %edx,%edi
  10616f:	ac                   	lods   %ds:(%esi),%al
  106170:	aa                   	stos   %al,%es:(%edi)
  106171:	84 c0                	test   %al,%al
  106173:	75 fa                	jne    10616f <strcpy+0x22>
  106175:	89 fa                	mov    %edi,%edx
  106177:	89 f1                	mov    %esi,%ecx
  106179:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10617c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10617f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  106182:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  106185:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  106186:	83 c4 20             	add    $0x20,%esp
  106189:	5e                   	pop    %esi
  10618a:	5f                   	pop    %edi
  10618b:	5d                   	pop    %ebp
  10618c:	c3                   	ret    

0010618d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  10618d:	55                   	push   %ebp
  10618e:	89 e5                	mov    %esp,%ebp
  106190:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  106193:	8b 45 08             	mov    0x8(%ebp),%eax
  106196:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  106199:	eb 1e                	jmp    1061b9 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  10619b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10619e:	0f b6 10             	movzbl (%eax),%edx
  1061a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1061a4:	88 10                	mov    %dl,(%eax)
  1061a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1061a9:	0f b6 00             	movzbl (%eax),%eax
  1061ac:	84 c0                	test   %al,%al
  1061ae:	74 03                	je     1061b3 <strncpy+0x26>
            src ++;
  1061b0:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  1061b3:	ff 45 fc             	incl   -0x4(%ebp)
  1061b6:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  1061b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1061bd:	75 dc                	jne    10619b <strncpy+0xe>
    }
    return dst;
  1061bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1061c2:	c9                   	leave  
  1061c3:	c3                   	ret    

001061c4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1061c4:	55                   	push   %ebp
  1061c5:	89 e5                	mov    %esp,%ebp
  1061c7:	57                   	push   %edi
  1061c8:	56                   	push   %esi
  1061c9:	83 ec 20             	sub    $0x20,%esp
  1061cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1061cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1061d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1061d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1061db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1061de:	89 d1                	mov    %edx,%ecx
  1061e0:	89 c2                	mov    %eax,%edx
  1061e2:	89 ce                	mov    %ecx,%esi
  1061e4:	89 d7                	mov    %edx,%edi
  1061e6:	ac                   	lods   %ds:(%esi),%al
  1061e7:	ae                   	scas   %es:(%edi),%al
  1061e8:	75 08                	jne    1061f2 <strcmp+0x2e>
  1061ea:	84 c0                	test   %al,%al
  1061ec:	75 f8                	jne    1061e6 <strcmp+0x22>
  1061ee:	31 c0                	xor    %eax,%eax
  1061f0:	eb 04                	jmp    1061f6 <strcmp+0x32>
  1061f2:	19 c0                	sbb    %eax,%eax
  1061f4:	0c 01                	or     $0x1,%al
  1061f6:	89 fa                	mov    %edi,%edx
  1061f8:	89 f1                	mov    %esi,%ecx
  1061fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1061fd:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106200:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  106203:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  106206:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  106207:	83 c4 20             	add    $0x20,%esp
  10620a:	5e                   	pop    %esi
  10620b:	5f                   	pop    %edi
  10620c:	5d                   	pop    %ebp
  10620d:	c3                   	ret    

0010620e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  10620e:	55                   	push   %ebp
  10620f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106211:	eb 09                	jmp    10621c <strncmp+0xe>
        n --, s1 ++, s2 ++;
  106213:	ff 4d 10             	decl   0x10(%ebp)
  106216:	ff 45 08             	incl   0x8(%ebp)
  106219:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10621c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106220:	74 1a                	je     10623c <strncmp+0x2e>
  106222:	8b 45 08             	mov    0x8(%ebp),%eax
  106225:	0f b6 00             	movzbl (%eax),%eax
  106228:	84 c0                	test   %al,%al
  10622a:	74 10                	je     10623c <strncmp+0x2e>
  10622c:	8b 45 08             	mov    0x8(%ebp),%eax
  10622f:	0f b6 10             	movzbl (%eax),%edx
  106232:	8b 45 0c             	mov    0xc(%ebp),%eax
  106235:	0f b6 00             	movzbl (%eax),%eax
  106238:	38 c2                	cmp    %al,%dl
  10623a:	74 d7                	je     106213 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  10623c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106240:	74 18                	je     10625a <strncmp+0x4c>
  106242:	8b 45 08             	mov    0x8(%ebp),%eax
  106245:	0f b6 00             	movzbl (%eax),%eax
  106248:	0f b6 d0             	movzbl %al,%edx
  10624b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10624e:	0f b6 00             	movzbl (%eax),%eax
  106251:	0f b6 c0             	movzbl %al,%eax
  106254:	29 c2                	sub    %eax,%edx
  106256:	89 d0                	mov    %edx,%eax
  106258:	eb 05                	jmp    10625f <strncmp+0x51>
  10625a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10625f:	5d                   	pop    %ebp
  106260:	c3                   	ret    

00106261 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  106261:	55                   	push   %ebp
  106262:	89 e5                	mov    %esp,%ebp
  106264:	83 ec 04             	sub    $0x4,%esp
  106267:	8b 45 0c             	mov    0xc(%ebp),%eax
  10626a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10626d:	eb 13                	jmp    106282 <strchr+0x21>
        if (*s == c) {
  10626f:	8b 45 08             	mov    0x8(%ebp),%eax
  106272:	0f b6 00             	movzbl (%eax),%eax
  106275:	38 45 fc             	cmp    %al,-0x4(%ebp)
  106278:	75 05                	jne    10627f <strchr+0x1e>
            return (char *)s;
  10627a:	8b 45 08             	mov    0x8(%ebp),%eax
  10627d:	eb 12                	jmp    106291 <strchr+0x30>
        }
        s ++;
  10627f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  106282:	8b 45 08             	mov    0x8(%ebp),%eax
  106285:	0f b6 00             	movzbl (%eax),%eax
  106288:	84 c0                	test   %al,%al
  10628a:	75 e3                	jne    10626f <strchr+0xe>
    }
    return NULL;
  10628c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106291:	c9                   	leave  
  106292:	c3                   	ret    

00106293 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  106293:	55                   	push   %ebp
  106294:	89 e5                	mov    %esp,%ebp
  106296:	83 ec 04             	sub    $0x4,%esp
  106299:	8b 45 0c             	mov    0xc(%ebp),%eax
  10629c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10629f:	eb 0e                	jmp    1062af <strfind+0x1c>
        if (*s == c) {
  1062a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1062a4:	0f b6 00             	movzbl (%eax),%eax
  1062a7:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1062aa:	74 0f                	je     1062bb <strfind+0x28>
            break;
        }
        s ++;
  1062ac:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  1062af:	8b 45 08             	mov    0x8(%ebp),%eax
  1062b2:	0f b6 00             	movzbl (%eax),%eax
  1062b5:	84 c0                	test   %al,%al
  1062b7:	75 e8                	jne    1062a1 <strfind+0xe>
  1062b9:	eb 01                	jmp    1062bc <strfind+0x29>
            break;
  1062bb:	90                   	nop
    }
    return (char *)s;
  1062bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1062bf:	c9                   	leave  
  1062c0:	c3                   	ret    

001062c1 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1062c1:	55                   	push   %ebp
  1062c2:	89 e5                	mov    %esp,%ebp
  1062c4:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1062c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1062ce:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1062d5:	eb 03                	jmp    1062da <strtol+0x19>
        s ++;
  1062d7:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  1062da:	8b 45 08             	mov    0x8(%ebp),%eax
  1062dd:	0f b6 00             	movzbl (%eax),%eax
  1062e0:	3c 20                	cmp    $0x20,%al
  1062e2:	74 f3                	je     1062d7 <strtol+0x16>
  1062e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1062e7:	0f b6 00             	movzbl (%eax),%eax
  1062ea:	3c 09                	cmp    $0x9,%al
  1062ec:	74 e9                	je     1062d7 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1062ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1062f1:	0f b6 00             	movzbl (%eax),%eax
  1062f4:	3c 2b                	cmp    $0x2b,%al
  1062f6:	75 05                	jne    1062fd <strtol+0x3c>
        s ++;
  1062f8:	ff 45 08             	incl   0x8(%ebp)
  1062fb:	eb 14                	jmp    106311 <strtol+0x50>
    }
    else if (*s == '-') {
  1062fd:	8b 45 08             	mov    0x8(%ebp),%eax
  106300:	0f b6 00             	movzbl (%eax),%eax
  106303:	3c 2d                	cmp    $0x2d,%al
  106305:	75 0a                	jne    106311 <strtol+0x50>
        s ++, neg = 1;
  106307:	ff 45 08             	incl   0x8(%ebp)
  10630a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  106311:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106315:	74 06                	je     10631d <strtol+0x5c>
  106317:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10631b:	75 22                	jne    10633f <strtol+0x7e>
  10631d:	8b 45 08             	mov    0x8(%ebp),%eax
  106320:	0f b6 00             	movzbl (%eax),%eax
  106323:	3c 30                	cmp    $0x30,%al
  106325:	75 18                	jne    10633f <strtol+0x7e>
  106327:	8b 45 08             	mov    0x8(%ebp),%eax
  10632a:	40                   	inc    %eax
  10632b:	0f b6 00             	movzbl (%eax),%eax
  10632e:	3c 78                	cmp    $0x78,%al
  106330:	75 0d                	jne    10633f <strtol+0x7e>
        s += 2, base = 16;
  106332:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  106336:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  10633d:	eb 29                	jmp    106368 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  10633f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106343:	75 16                	jne    10635b <strtol+0x9a>
  106345:	8b 45 08             	mov    0x8(%ebp),%eax
  106348:	0f b6 00             	movzbl (%eax),%eax
  10634b:	3c 30                	cmp    $0x30,%al
  10634d:	75 0c                	jne    10635b <strtol+0x9a>
        s ++, base = 8;
  10634f:	ff 45 08             	incl   0x8(%ebp)
  106352:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  106359:	eb 0d                	jmp    106368 <strtol+0xa7>
    }
    else if (base == 0) {
  10635b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10635f:	75 07                	jne    106368 <strtol+0xa7>
        base = 10;
  106361:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  106368:	8b 45 08             	mov    0x8(%ebp),%eax
  10636b:	0f b6 00             	movzbl (%eax),%eax
  10636e:	3c 2f                	cmp    $0x2f,%al
  106370:	7e 1b                	jle    10638d <strtol+0xcc>
  106372:	8b 45 08             	mov    0x8(%ebp),%eax
  106375:	0f b6 00             	movzbl (%eax),%eax
  106378:	3c 39                	cmp    $0x39,%al
  10637a:	7f 11                	jg     10638d <strtol+0xcc>
            dig = *s - '0';
  10637c:	8b 45 08             	mov    0x8(%ebp),%eax
  10637f:	0f b6 00             	movzbl (%eax),%eax
  106382:	0f be c0             	movsbl %al,%eax
  106385:	83 e8 30             	sub    $0x30,%eax
  106388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10638b:	eb 48                	jmp    1063d5 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  10638d:	8b 45 08             	mov    0x8(%ebp),%eax
  106390:	0f b6 00             	movzbl (%eax),%eax
  106393:	3c 60                	cmp    $0x60,%al
  106395:	7e 1b                	jle    1063b2 <strtol+0xf1>
  106397:	8b 45 08             	mov    0x8(%ebp),%eax
  10639a:	0f b6 00             	movzbl (%eax),%eax
  10639d:	3c 7a                	cmp    $0x7a,%al
  10639f:	7f 11                	jg     1063b2 <strtol+0xf1>
            dig = *s - 'a' + 10;
  1063a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1063a4:	0f b6 00             	movzbl (%eax),%eax
  1063a7:	0f be c0             	movsbl %al,%eax
  1063aa:	83 e8 57             	sub    $0x57,%eax
  1063ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1063b0:	eb 23                	jmp    1063d5 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1063b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1063b5:	0f b6 00             	movzbl (%eax),%eax
  1063b8:	3c 40                	cmp    $0x40,%al
  1063ba:	7e 3b                	jle    1063f7 <strtol+0x136>
  1063bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1063bf:	0f b6 00             	movzbl (%eax),%eax
  1063c2:	3c 5a                	cmp    $0x5a,%al
  1063c4:	7f 31                	jg     1063f7 <strtol+0x136>
            dig = *s - 'A' + 10;
  1063c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1063c9:	0f b6 00             	movzbl (%eax),%eax
  1063cc:	0f be c0             	movsbl %al,%eax
  1063cf:	83 e8 37             	sub    $0x37,%eax
  1063d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1063d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1063d8:	3b 45 10             	cmp    0x10(%ebp),%eax
  1063db:	7d 19                	jge    1063f6 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  1063dd:	ff 45 08             	incl   0x8(%ebp)
  1063e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1063e3:	0f af 45 10          	imul   0x10(%ebp),%eax
  1063e7:	89 c2                	mov    %eax,%edx
  1063e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1063ec:	01 d0                	add    %edx,%eax
  1063ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  1063f1:	e9 72 ff ff ff       	jmp    106368 <strtol+0xa7>
            break;
  1063f6:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1063f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1063fb:	74 08                	je     106405 <strtol+0x144>
        *endptr = (char *) s;
  1063fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  106400:	8b 55 08             	mov    0x8(%ebp),%edx
  106403:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  106405:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  106409:	74 07                	je     106412 <strtol+0x151>
  10640b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10640e:	f7 d8                	neg    %eax
  106410:	eb 03                	jmp    106415 <strtol+0x154>
  106412:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  106415:	c9                   	leave  
  106416:	c3                   	ret    

00106417 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  106417:	55                   	push   %ebp
  106418:	89 e5                	mov    %esp,%ebp
  10641a:	57                   	push   %edi
  10641b:	83 ec 24             	sub    $0x24,%esp
  10641e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106421:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106424:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  106428:	8b 55 08             	mov    0x8(%ebp),%edx
  10642b:	89 55 f8             	mov    %edx,-0x8(%ebp)
  10642e:	88 45 f7             	mov    %al,-0x9(%ebp)
  106431:	8b 45 10             	mov    0x10(%ebp),%eax
  106434:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  106437:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10643a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10643e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  106441:	89 d7                	mov    %edx,%edi
  106443:	f3 aa                	rep stos %al,%es:(%edi)
  106445:	89 fa                	mov    %edi,%edx
  106447:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10644a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  10644d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106450:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  106451:	83 c4 24             	add    $0x24,%esp
  106454:	5f                   	pop    %edi
  106455:	5d                   	pop    %ebp
  106456:	c3                   	ret    

00106457 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  106457:	55                   	push   %ebp
  106458:	89 e5                	mov    %esp,%ebp
  10645a:	57                   	push   %edi
  10645b:	56                   	push   %esi
  10645c:	53                   	push   %ebx
  10645d:	83 ec 30             	sub    $0x30,%esp
  106460:	8b 45 08             	mov    0x8(%ebp),%eax
  106463:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106466:	8b 45 0c             	mov    0xc(%ebp),%eax
  106469:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10646c:	8b 45 10             	mov    0x10(%ebp),%eax
  10646f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  106472:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106475:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  106478:	73 42                	jae    1064bc <memmove+0x65>
  10647a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10647d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106480:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106486:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106489:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10648c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10648f:	c1 e8 02             	shr    $0x2,%eax
  106492:	89 c1                	mov    %eax,%ecx
    asm volatile (
  106494:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106497:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10649a:	89 d7                	mov    %edx,%edi
  10649c:	89 c6                	mov    %eax,%esi
  10649e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1064a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1064a3:	83 e1 03             	and    $0x3,%ecx
  1064a6:	74 02                	je     1064aa <memmove+0x53>
  1064a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1064aa:	89 f0                	mov    %esi,%eax
  1064ac:	89 fa                	mov    %edi,%edx
  1064ae:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1064b1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1064b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  1064b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  1064ba:	eb 36                	jmp    1064f2 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1064bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1064bf:	8d 50 ff             	lea    -0x1(%eax),%edx
  1064c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1064c5:	01 c2                	add    %eax,%edx
  1064c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1064ca:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1064cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1064d0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  1064d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1064d6:	89 c1                	mov    %eax,%ecx
  1064d8:	89 d8                	mov    %ebx,%eax
  1064da:	89 d6                	mov    %edx,%esi
  1064dc:	89 c7                	mov    %eax,%edi
  1064de:	fd                   	std    
  1064df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1064e1:	fc                   	cld    
  1064e2:	89 f8                	mov    %edi,%eax
  1064e4:	89 f2                	mov    %esi,%edx
  1064e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1064e9:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1064ec:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1064ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1064f2:	83 c4 30             	add    $0x30,%esp
  1064f5:	5b                   	pop    %ebx
  1064f6:	5e                   	pop    %esi
  1064f7:	5f                   	pop    %edi
  1064f8:	5d                   	pop    %ebp
  1064f9:	c3                   	ret    

001064fa <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1064fa:	55                   	push   %ebp
  1064fb:	89 e5                	mov    %esp,%ebp
  1064fd:	57                   	push   %edi
  1064fe:	56                   	push   %esi
  1064ff:	83 ec 20             	sub    $0x20,%esp
  106502:	8b 45 08             	mov    0x8(%ebp),%eax
  106505:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106508:	8b 45 0c             	mov    0xc(%ebp),%eax
  10650b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10650e:	8b 45 10             	mov    0x10(%ebp),%eax
  106511:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106514:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106517:	c1 e8 02             	shr    $0x2,%eax
  10651a:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10651c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10651f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106522:	89 d7                	mov    %edx,%edi
  106524:	89 c6                	mov    %eax,%esi
  106526:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106528:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10652b:	83 e1 03             	and    $0x3,%ecx
  10652e:	74 02                	je     106532 <memcpy+0x38>
  106530:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106532:	89 f0                	mov    %esi,%eax
  106534:	89 fa                	mov    %edi,%edx
  106536:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106539:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10653c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  10653f:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  106542:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106543:	83 c4 20             	add    $0x20,%esp
  106546:	5e                   	pop    %esi
  106547:	5f                   	pop    %edi
  106548:	5d                   	pop    %ebp
  106549:	c3                   	ret    

0010654a <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10654a:	55                   	push   %ebp
  10654b:	89 e5                	mov    %esp,%ebp
  10654d:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  106550:	8b 45 08             	mov    0x8(%ebp),%eax
  106553:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  106556:	8b 45 0c             	mov    0xc(%ebp),%eax
  106559:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10655c:	eb 2e                	jmp    10658c <memcmp+0x42>
        if (*s1 != *s2) {
  10655e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106561:	0f b6 10             	movzbl (%eax),%edx
  106564:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106567:	0f b6 00             	movzbl (%eax),%eax
  10656a:	38 c2                	cmp    %al,%dl
  10656c:	74 18                	je     106586 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  10656e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106571:	0f b6 00             	movzbl (%eax),%eax
  106574:	0f b6 d0             	movzbl %al,%edx
  106577:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10657a:	0f b6 00             	movzbl (%eax),%eax
  10657d:	0f b6 c0             	movzbl %al,%eax
  106580:	29 c2                	sub    %eax,%edx
  106582:	89 d0                	mov    %edx,%eax
  106584:	eb 18                	jmp    10659e <memcmp+0x54>
        }
        s1 ++, s2 ++;
  106586:	ff 45 fc             	incl   -0x4(%ebp)
  106589:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  10658c:	8b 45 10             	mov    0x10(%ebp),%eax
  10658f:	8d 50 ff             	lea    -0x1(%eax),%edx
  106592:	89 55 10             	mov    %edx,0x10(%ebp)
  106595:	85 c0                	test   %eax,%eax
  106597:	75 c5                	jne    10655e <memcmp+0x14>
    }
    return 0;
  106599:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10659e:	c9                   	leave  
  10659f:	c3                   	ret    

001065a0 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1065a0:	55                   	push   %ebp
  1065a1:	89 e5                	mov    %esp,%ebp
  1065a3:	83 ec 58             	sub    $0x58,%esp
  1065a6:	8b 45 10             	mov    0x10(%ebp),%eax
  1065a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1065ac:	8b 45 14             	mov    0x14(%ebp),%eax
  1065af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1065b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1065b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1065b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1065bb:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1065be:	8b 45 18             	mov    0x18(%ebp),%eax
  1065c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1065c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1065c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1065ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1065cd:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1065d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1065d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1065da:	74 1c                	je     1065f8 <printnum+0x58>
  1065dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065df:	ba 00 00 00 00       	mov    $0x0,%edx
  1065e4:	f7 75 e4             	divl   -0x1c(%ebp)
  1065e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1065ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065ed:	ba 00 00 00 00       	mov    $0x0,%edx
  1065f2:	f7 75 e4             	divl   -0x1c(%ebp)
  1065f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1065f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1065fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1065fe:	f7 75 e4             	divl   -0x1c(%ebp)
  106601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106604:	89 55 dc             	mov    %edx,-0x24(%ebp)
  106607:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10660a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10660d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106610:	89 55 ec             	mov    %edx,-0x14(%ebp)
  106613:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106616:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  106619:	8b 45 18             	mov    0x18(%ebp),%eax
  10661c:	ba 00 00 00 00       	mov    $0x0,%edx
  106621:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  106624:	72 56                	jb     10667c <printnum+0xdc>
  106626:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  106629:	77 05                	ja     106630 <printnum+0x90>
  10662b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  10662e:	72 4c                	jb     10667c <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  106630:	8b 45 1c             	mov    0x1c(%ebp),%eax
  106633:	8d 50 ff             	lea    -0x1(%eax),%edx
  106636:	8b 45 20             	mov    0x20(%ebp),%eax
  106639:	89 44 24 18          	mov    %eax,0x18(%esp)
  10663d:	89 54 24 14          	mov    %edx,0x14(%esp)
  106641:	8b 45 18             	mov    0x18(%ebp),%eax
  106644:	89 44 24 10          	mov    %eax,0x10(%esp)
  106648:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10664b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10664e:	89 44 24 08          	mov    %eax,0x8(%esp)
  106652:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106656:	8b 45 0c             	mov    0xc(%ebp),%eax
  106659:	89 44 24 04          	mov    %eax,0x4(%esp)
  10665d:	8b 45 08             	mov    0x8(%ebp),%eax
  106660:	89 04 24             	mov    %eax,(%esp)
  106663:	e8 38 ff ff ff       	call   1065a0 <printnum>
  106668:	eb 1b                	jmp    106685 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10666a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10666d:	89 44 24 04          	mov    %eax,0x4(%esp)
  106671:	8b 45 20             	mov    0x20(%ebp),%eax
  106674:	89 04 24             	mov    %eax,(%esp)
  106677:	8b 45 08             	mov    0x8(%ebp),%eax
  10667a:	ff d0                	call   *%eax
        while (-- width > 0)
  10667c:	ff 4d 1c             	decl   0x1c(%ebp)
  10667f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  106683:	7f e5                	jg     10666a <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  106685:	8b 45 d8             	mov    -0x28(%ebp),%eax
  106688:	05 cc 7f 10 00       	add    $0x107fcc,%eax
  10668d:	0f b6 00             	movzbl (%eax),%eax
  106690:	0f be c0             	movsbl %al,%eax
  106693:	8b 55 0c             	mov    0xc(%ebp),%edx
  106696:	89 54 24 04          	mov    %edx,0x4(%esp)
  10669a:	89 04 24             	mov    %eax,(%esp)
  10669d:	8b 45 08             	mov    0x8(%ebp),%eax
  1066a0:	ff d0                	call   *%eax
}
  1066a2:	90                   	nop
  1066a3:	c9                   	leave  
  1066a4:	c3                   	ret    

001066a5 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1066a5:	55                   	push   %ebp
  1066a6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1066a8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1066ac:	7e 14                	jle    1066c2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1066ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1066b1:	8b 00                	mov    (%eax),%eax
  1066b3:	8d 48 08             	lea    0x8(%eax),%ecx
  1066b6:	8b 55 08             	mov    0x8(%ebp),%edx
  1066b9:	89 0a                	mov    %ecx,(%edx)
  1066bb:	8b 50 04             	mov    0x4(%eax),%edx
  1066be:	8b 00                	mov    (%eax),%eax
  1066c0:	eb 30                	jmp    1066f2 <getuint+0x4d>
    }
    else if (lflag) {
  1066c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1066c6:	74 16                	je     1066de <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1066c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1066cb:	8b 00                	mov    (%eax),%eax
  1066cd:	8d 48 04             	lea    0x4(%eax),%ecx
  1066d0:	8b 55 08             	mov    0x8(%ebp),%edx
  1066d3:	89 0a                	mov    %ecx,(%edx)
  1066d5:	8b 00                	mov    (%eax),%eax
  1066d7:	ba 00 00 00 00       	mov    $0x0,%edx
  1066dc:	eb 14                	jmp    1066f2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1066de:	8b 45 08             	mov    0x8(%ebp),%eax
  1066e1:	8b 00                	mov    (%eax),%eax
  1066e3:	8d 48 04             	lea    0x4(%eax),%ecx
  1066e6:	8b 55 08             	mov    0x8(%ebp),%edx
  1066e9:	89 0a                	mov    %ecx,(%edx)
  1066eb:	8b 00                	mov    (%eax),%eax
  1066ed:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1066f2:	5d                   	pop    %ebp
  1066f3:	c3                   	ret    

001066f4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1066f4:	55                   	push   %ebp
  1066f5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1066f7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1066fb:	7e 14                	jle    106711 <getint+0x1d>
        return va_arg(*ap, long long);
  1066fd:	8b 45 08             	mov    0x8(%ebp),%eax
  106700:	8b 00                	mov    (%eax),%eax
  106702:	8d 48 08             	lea    0x8(%eax),%ecx
  106705:	8b 55 08             	mov    0x8(%ebp),%edx
  106708:	89 0a                	mov    %ecx,(%edx)
  10670a:	8b 50 04             	mov    0x4(%eax),%edx
  10670d:	8b 00                	mov    (%eax),%eax
  10670f:	eb 28                	jmp    106739 <getint+0x45>
    }
    else if (lflag) {
  106711:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106715:	74 12                	je     106729 <getint+0x35>
        return va_arg(*ap, long);
  106717:	8b 45 08             	mov    0x8(%ebp),%eax
  10671a:	8b 00                	mov    (%eax),%eax
  10671c:	8d 48 04             	lea    0x4(%eax),%ecx
  10671f:	8b 55 08             	mov    0x8(%ebp),%edx
  106722:	89 0a                	mov    %ecx,(%edx)
  106724:	8b 00                	mov    (%eax),%eax
  106726:	99                   	cltd   
  106727:	eb 10                	jmp    106739 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  106729:	8b 45 08             	mov    0x8(%ebp),%eax
  10672c:	8b 00                	mov    (%eax),%eax
  10672e:	8d 48 04             	lea    0x4(%eax),%ecx
  106731:	8b 55 08             	mov    0x8(%ebp),%edx
  106734:	89 0a                	mov    %ecx,(%edx)
  106736:	8b 00                	mov    (%eax),%eax
  106738:	99                   	cltd   
    }
}
  106739:	5d                   	pop    %ebp
  10673a:	c3                   	ret    

0010673b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10673b:	55                   	push   %ebp
  10673c:	89 e5                	mov    %esp,%ebp
  10673e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  106741:	8d 45 14             	lea    0x14(%ebp),%eax
  106744:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  106747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10674a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10674e:	8b 45 10             	mov    0x10(%ebp),%eax
  106751:	89 44 24 08          	mov    %eax,0x8(%esp)
  106755:	8b 45 0c             	mov    0xc(%ebp),%eax
  106758:	89 44 24 04          	mov    %eax,0x4(%esp)
  10675c:	8b 45 08             	mov    0x8(%ebp),%eax
  10675f:	89 04 24             	mov    %eax,(%esp)
  106762:	e8 03 00 00 00       	call   10676a <vprintfmt>
    va_end(ap);
}
  106767:	90                   	nop
  106768:	c9                   	leave  
  106769:	c3                   	ret    

0010676a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10676a:	55                   	push   %ebp
  10676b:	89 e5                	mov    %esp,%ebp
  10676d:	56                   	push   %esi
  10676e:	53                   	push   %ebx
  10676f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  106772:	eb 17                	jmp    10678b <vprintfmt+0x21>
            if (ch == '\0') {
  106774:	85 db                	test   %ebx,%ebx
  106776:	0f 84 bf 03 00 00    	je     106b3b <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  10677c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10677f:	89 44 24 04          	mov    %eax,0x4(%esp)
  106783:	89 1c 24             	mov    %ebx,(%esp)
  106786:	8b 45 08             	mov    0x8(%ebp),%eax
  106789:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10678b:	8b 45 10             	mov    0x10(%ebp),%eax
  10678e:	8d 50 01             	lea    0x1(%eax),%edx
  106791:	89 55 10             	mov    %edx,0x10(%ebp)
  106794:	0f b6 00             	movzbl (%eax),%eax
  106797:	0f b6 d8             	movzbl %al,%ebx
  10679a:	83 fb 25             	cmp    $0x25,%ebx
  10679d:	75 d5                	jne    106774 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  10679f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1067a3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1067aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1067ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1067b0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1067b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1067ba:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1067bd:	8b 45 10             	mov    0x10(%ebp),%eax
  1067c0:	8d 50 01             	lea    0x1(%eax),%edx
  1067c3:	89 55 10             	mov    %edx,0x10(%ebp)
  1067c6:	0f b6 00             	movzbl (%eax),%eax
  1067c9:	0f b6 d8             	movzbl %al,%ebx
  1067cc:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1067cf:	83 f8 55             	cmp    $0x55,%eax
  1067d2:	0f 87 37 03 00 00    	ja     106b0f <vprintfmt+0x3a5>
  1067d8:	8b 04 85 f0 7f 10 00 	mov    0x107ff0(,%eax,4),%eax
  1067df:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  1067e1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  1067e5:	eb d6                	jmp    1067bd <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  1067e7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  1067eb:	eb d0                	jmp    1067bd <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1067ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1067f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1067f7:	89 d0                	mov    %edx,%eax
  1067f9:	c1 e0 02             	shl    $0x2,%eax
  1067fc:	01 d0                	add    %edx,%eax
  1067fe:	01 c0                	add    %eax,%eax
  106800:	01 d8                	add    %ebx,%eax
  106802:	83 e8 30             	sub    $0x30,%eax
  106805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  106808:	8b 45 10             	mov    0x10(%ebp),%eax
  10680b:	0f b6 00             	movzbl (%eax),%eax
  10680e:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  106811:	83 fb 2f             	cmp    $0x2f,%ebx
  106814:	7e 38                	jle    10684e <vprintfmt+0xe4>
  106816:	83 fb 39             	cmp    $0x39,%ebx
  106819:	7f 33                	jg     10684e <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  10681b:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  10681e:	eb d4                	jmp    1067f4 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  106820:	8b 45 14             	mov    0x14(%ebp),%eax
  106823:	8d 50 04             	lea    0x4(%eax),%edx
  106826:	89 55 14             	mov    %edx,0x14(%ebp)
  106829:	8b 00                	mov    (%eax),%eax
  10682b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  10682e:	eb 1f                	jmp    10684f <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  106830:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106834:	79 87                	jns    1067bd <vprintfmt+0x53>
                width = 0;
  106836:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  10683d:	e9 7b ff ff ff       	jmp    1067bd <vprintfmt+0x53>

        case '#':
            altflag = 1;
  106842:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  106849:	e9 6f ff ff ff       	jmp    1067bd <vprintfmt+0x53>
            goto process_precision;
  10684e:	90                   	nop

        process_precision:
            if (width < 0)
  10684f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106853:	0f 89 64 ff ff ff    	jns    1067bd <vprintfmt+0x53>
                width = precision, precision = -1;
  106859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10685c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10685f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  106866:	e9 52 ff ff ff       	jmp    1067bd <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  10686b:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  10686e:	e9 4a ff ff ff       	jmp    1067bd <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  106873:	8b 45 14             	mov    0x14(%ebp),%eax
  106876:	8d 50 04             	lea    0x4(%eax),%edx
  106879:	89 55 14             	mov    %edx,0x14(%ebp)
  10687c:	8b 00                	mov    (%eax),%eax
  10687e:	8b 55 0c             	mov    0xc(%ebp),%edx
  106881:	89 54 24 04          	mov    %edx,0x4(%esp)
  106885:	89 04 24             	mov    %eax,(%esp)
  106888:	8b 45 08             	mov    0x8(%ebp),%eax
  10688b:	ff d0                	call   *%eax
            break;
  10688d:	e9 a4 02 00 00       	jmp    106b36 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  106892:	8b 45 14             	mov    0x14(%ebp),%eax
  106895:	8d 50 04             	lea    0x4(%eax),%edx
  106898:	89 55 14             	mov    %edx,0x14(%ebp)
  10689b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  10689d:	85 db                	test   %ebx,%ebx
  10689f:	79 02                	jns    1068a3 <vprintfmt+0x139>
                err = -err;
  1068a1:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1068a3:	83 fb 06             	cmp    $0x6,%ebx
  1068a6:	7f 0b                	jg     1068b3 <vprintfmt+0x149>
  1068a8:	8b 34 9d b0 7f 10 00 	mov    0x107fb0(,%ebx,4),%esi
  1068af:	85 f6                	test   %esi,%esi
  1068b1:	75 23                	jne    1068d6 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  1068b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1068b7:	c7 44 24 08 dd 7f 10 	movl   $0x107fdd,0x8(%esp)
  1068be:	00 
  1068bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1068c9:	89 04 24             	mov    %eax,(%esp)
  1068cc:	e8 6a fe ff ff       	call   10673b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1068d1:	e9 60 02 00 00       	jmp    106b36 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  1068d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1068da:	c7 44 24 08 e6 7f 10 	movl   $0x107fe6,0x8(%esp)
  1068e1:	00 
  1068e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1068ec:	89 04 24             	mov    %eax,(%esp)
  1068ef:	e8 47 fe ff ff       	call   10673b <printfmt>
            break;
  1068f4:	e9 3d 02 00 00       	jmp    106b36 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1068f9:	8b 45 14             	mov    0x14(%ebp),%eax
  1068fc:	8d 50 04             	lea    0x4(%eax),%edx
  1068ff:	89 55 14             	mov    %edx,0x14(%ebp)
  106902:	8b 30                	mov    (%eax),%esi
  106904:	85 f6                	test   %esi,%esi
  106906:	75 05                	jne    10690d <vprintfmt+0x1a3>
                p = "(null)";
  106908:	be e9 7f 10 00       	mov    $0x107fe9,%esi
            }
            if (width > 0 && padc != '-') {
  10690d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106911:	7e 76                	jle    106989 <vprintfmt+0x21f>
  106913:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  106917:	74 70                	je     106989 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  106919:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10691c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106920:	89 34 24             	mov    %esi,(%esp)
  106923:	e8 f6 f7 ff ff       	call   10611e <strnlen>
  106928:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10692b:	29 c2                	sub    %eax,%edx
  10692d:	89 d0                	mov    %edx,%eax
  10692f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106932:	eb 16                	jmp    10694a <vprintfmt+0x1e0>
                    putch(padc, putdat);
  106934:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  106938:	8b 55 0c             	mov    0xc(%ebp),%edx
  10693b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10693f:	89 04 24             	mov    %eax,(%esp)
  106942:	8b 45 08             	mov    0x8(%ebp),%eax
  106945:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  106947:	ff 4d e8             	decl   -0x18(%ebp)
  10694a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10694e:	7f e4                	jg     106934 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106950:	eb 37                	jmp    106989 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  106952:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106956:	74 1f                	je     106977 <vprintfmt+0x20d>
  106958:	83 fb 1f             	cmp    $0x1f,%ebx
  10695b:	7e 05                	jle    106962 <vprintfmt+0x1f8>
  10695d:	83 fb 7e             	cmp    $0x7e,%ebx
  106960:	7e 15                	jle    106977 <vprintfmt+0x20d>
                    putch('?', putdat);
  106962:	8b 45 0c             	mov    0xc(%ebp),%eax
  106965:	89 44 24 04          	mov    %eax,0x4(%esp)
  106969:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  106970:	8b 45 08             	mov    0x8(%ebp),%eax
  106973:	ff d0                	call   *%eax
  106975:	eb 0f                	jmp    106986 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  106977:	8b 45 0c             	mov    0xc(%ebp),%eax
  10697a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10697e:	89 1c 24             	mov    %ebx,(%esp)
  106981:	8b 45 08             	mov    0x8(%ebp),%eax
  106984:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106986:	ff 4d e8             	decl   -0x18(%ebp)
  106989:	89 f0                	mov    %esi,%eax
  10698b:	8d 70 01             	lea    0x1(%eax),%esi
  10698e:	0f b6 00             	movzbl (%eax),%eax
  106991:	0f be d8             	movsbl %al,%ebx
  106994:	85 db                	test   %ebx,%ebx
  106996:	74 27                	je     1069bf <vprintfmt+0x255>
  106998:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10699c:	78 b4                	js     106952 <vprintfmt+0x1e8>
  10699e:	ff 4d e4             	decl   -0x1c(%ebp)
  1069a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1069a5:	79 ab                	jns    106952 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  1069a7:	eb 16                	jmp    1069bf <vprintfmt+0x255>
                putch(' ', putdat);
  1069a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1069ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069b0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1069b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1069ba:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  1069bc:	ff 4d e8             	decl   -0x18(%ebp)
  1069bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1069c3:	7f e4                	jg     1069a9 <vprintfmt+0x23f>
            }
            break;
  1069c5:	e9 6c 01 00 00       	jmp    106b36 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1069ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1069cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069d1:	8d 45 14             	lea    0x14(%ebp),%eax
  1069d4:	89 04 24             	mov    %eax,(%esp)
  1069d7:	e8 18 fd ff ff       	call   1066f4 <getint>
  1069dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1069df:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1069e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1069e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1069e8:	85 d2                	test   %edx,%edx
  1069ea:	79 26                	jns    106a12 <vprintfmt+0x2a8>
                putch('-', putdat);
  1069ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1069ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1069fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1069fd:	ff d0                	call   *%eax
                num = -(long long)num;
  1069ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106a05:	f7 d8                	neg    %eax
  106a07:	83 d2 00             	adc    $0x0,%edx
  106a0a:	f7 da                	neg    %edx
  106a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106a0f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106a12:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106a19:	e9 a8 00 00 00       	jmp    106ac6 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  106a1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a25:	8d 45 14             	lea    0x14(%ebp),%eax
  106a28:	89 04 24             	mov    %eax,(%esp)
  106a2b:	e8 75 fc ff ff       	call   1066a5 <getuint>
  106a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106a33:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  106a36:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106a3d:	e9 84 00 00 00       	jmp    106ac6 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106a42:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a49:	8d 45 14             	lea    0x14(%ebp),%eax
  106a4c:	89 04 24             	mov    %eax,(%esp)
  106a4f:	e8 51 fc ff ff       	call   1066a5 <getuint>
  106a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106a57:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106a5a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106a61:	eb 63                	jmp    106ac6 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  106a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a6a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106a71:	8b 45 08             	mov    0x8(%ebp),%eax
  106a74:	ff d0                	call   *%eax
            putch('x', putdat);
  106a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a7d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  106a84:	8b 45 08             	mov    0x8(%ebp),%eax
  106a87:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106a89:	8b 45 14             	mov    0x14(%ebp),%eax
  106a8c:	8d 50 04             	lea    0x4(%eax),%edx
  106a8f:	89 55 14             	mov    %edx,0x14(%ebp)
  106a92:	8b 00                	mov    (%eax),%eax
  106a94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  106a9e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  106aa5:	eb 1f                	jmp    106ac6 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  106aa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  106aae:	8d 45 14             	lea    0x14(%ebp),%eax
  106ab1:	89 04 24             	mov    %eax,(%esp)
  106ab4:	e8 ec fb ff ff       	call   1066a5 <getuint>
  106ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106abc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106abf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106ac6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106aca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106acd:	89 54 24 18          	mov    %edx,0x18(%esp)
  106ad1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106ad4:	89 54 24 14          	mov    %edx,0x14(%esp)
  106ad8:	89 44 24 10          	mov    %eax,0x10(%esp)
  106adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106ae2:	89 44 24 08          	mov    %eax,0x8(%esp)
  106ae6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  106aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  106af1:	8b 45 08             	mov    0x8(%ebp),%eax
  106af4:	89 04 24             	mov    %eax,(%esp)
  106af7:	e8 a4 fa ff ff       	call   1065a0 <printnum>
            break;
  106afc:	eb 38                	jmp    106b36 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  106afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b01:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b05:	89 1c 24             	mov    %ebx,(%esp)
  106b08:	8b 45 08             	mov    0x8(%ebp),%eax
  106b0b:	ff d0                	call   *%eax
            break;
  106b0d:	eb 27                	jmp    106b36 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  106b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b16:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  106b20:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106b22:	ff 4d 10             	decl   0x10(%ebp)
  106b25:	eb 03                	jmp    106b2a <vprintfmt+0x3c0>
  106b27:	ff 4d 10             	decl   0x10(%ebp)
  106b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  106b2d:	48                   	dec    %eax
  106b2e:	0f b6 00             	movzbl (%eax),%eax
  106b31:	3c 25                	cmp    $0x25,%al
  106b33:	75 f2                	jne    106b27 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106b35:	90                   	nop
    while (1) {
  106b36:	e9 37 fc ff ff       	jmp    106772 <vprintfmt+0x8>
                return;
  106b3b:	90                   	nop
        }
    }
}
  106b3c:	83 c4 40             	add    $0x40,%esp
  106b3f:	5b                   	pop    %ebx
  106b40:	5e                   	pop    %esi
  106b41:	5d                   	pop    %ebp
  106b42:	c3                   	ret    

00106b43 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106b43:	55                   	push   %ebp
  106b44:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b49:	8b 40 08             	mov    0x8(%eax),%eax
  106b4c:	8d 50 01             	lea    0x1(%eax),%edx
  106b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b52:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b58:	8b 10                	mov    (%eax),%edx
  106b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b5d:	8b 40 04             	mov    0x4(%eax),%eax
  106b60:	39 c2                	cmp    %eax,%edx
  106b62:	73 12                	jae    106b76 <sprintputch+0x33>
        *b->buf ++ = ch;
  106b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b67:	8b 00                	mov    (%eax),%eax
  106b69:	8d 48 01             	lea    0x1(%eax),%ecx
  106b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  106b6f:	89 0a                	mov    %ecx,(%edx)
  106b71:	8b 55 08             	mov    0x8(%ebp),%edx
  106b74:	88 10                	mov    %dl,(%eax)
    }
}
  106b76:	90                   	nop
  106b77:	5d                   	pop    %ebp
  106b78:	c3                   	ret    

00106b79 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106b79:	55                   	push   %ebp
  106b7a:	89 e5                	mov    %esp,%ebp
  106b7c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106b7f:	8d 45 14             	lea    0x14(%ebp),%eax
  106b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106b8c:	8b 45 10             	mov    0x10(%ebp),%eax
  106b8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  106b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b96:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  106b9d:	89 04 24             	mov    %eax,(%esp)
  106ba0:	e8 08 00 00 00       	call   106bad <vsnprintf>
  106ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106bab:	c9                   	leave  
  106bac:	c3                   	ret    

00106bad <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106bad:	55                   	push   %ebp
  106bae:	89 e5                	mov    %esp,%ebp
  106bb0:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  106bb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bbc:	8d 50 ff             	lea    -0x1(%eax),%edx
  106bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  106bc2:	01 d0                	add    %edx,%eax
  106bc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106bc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106bce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106bd2:	74 0a                	je     106bde <vsnprintf+0x31>
  106bd4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106bda:	39 c2                	cmp    %eax,%edx
  106bdc:	76 07                	jbe    106be5 <vsnprintf+0x38>
        return -E_INVAL;
  106bde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106be3:	eb 2a                	jmp    106c0f <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106be5:	8b 45 14             	mov    0x14(%ebp),%eax
  106be8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106bec:	8b 45 10             	mov    0x10(%ebp),%eax
  106bef:	89 44 24 08          	mov    %eax,0x8(%esp)
  106bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  106bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bfa:	c7 04 24 43 6b 10 00 	movl   $0x106b43,(%esp)
  106c01:	e8 64 fb ff ff       	call   10676a <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  106c06:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106c09:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106c0f:	c9                   	leave  
  106c10:	c3                   	ret    
