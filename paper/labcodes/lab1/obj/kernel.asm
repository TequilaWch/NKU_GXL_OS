
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 20 fd 10 00       	mov    $0x10fd20,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 37 2e 00 00       	call   102e63 <memset>

    cons_init();                // init the console
  10002c:	e8 52 15 00 00       	call   101583 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 60 36 10 00 	movl   $0x103660,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 7c 36 10 00 	movl   $0x10367c,(%esp)
  100046:	e8 21 02 00 00       	call   10026c <cprintf>

    print_kerninfo();
  10004b:	e8 c2 08 00 00       	call   100912 <print_kerninfo>

    grade_backtrace();
  100050:	e8 8e 00 00 00       	call   1000e3 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 de 2a 00 00       	call   102b38 <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 63 16 00 00       	call   1016c2 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 c3 17 00 00       	call   101827 <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 fb 0c 00 00       	call   100d64 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 8e 17 00 00       	call   1017fc <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006e:	e8 6b 01 00 00       	call   1001de <lab1_switch_test>

    /* do nothing */
    while (1);
  100073:	eb fe                	jmp    100073 <kern_init+0x73>

00100075 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100075:	55                   	push   %ebp
  100076:	89 e5                	mov    %esp,%ebp
  100078:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  10007b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100082:	00 
  100083:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10008a:	00 
  10008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100092:	e8 bb 0c 00 00       	call   100d52 <mon_backtrace>
}
  100097:	90                   	nop
  100098:	c9                   	leave  
  100099:	c3                   	ret    

0010009a <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  10009a:	55                   	push   %ebp
  10009b:	89 e5                	mov    %esp,%ebp
  10009d:	53                   	push   %ebx
  10009e:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000a7:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000b9:	89 04 24             	mov    %eax,(%esp)
  1000bc:	e8 b4 ff ff ff       	call   100075 <grade_backtrace2>
}
  1000c1:	90                   	nop
  1000c2:	83 c4 14             	add    $0x14,%esp
  1000c5:	5b                   	pop    %ebx
  1000c6:	5d                   	pop    %ebp
  1000c7:	c3                   	ret    

001000c8 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c8:	55                   	push   %ebp
  1000c9:	89 e5                	mov    %esp,%ebp
  1000cb:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d8:	89 04 24             	mov    %eax,(%esp)
  1000db:	e8 ba ff ff ff       	call   10009a <grade_backtrace1>
}
  1000e0:	90                   	nop
  1000e1:	c9                   	leave  
  1000e2:	c3                   	ret    

001000e3 <grade_backtrace>:

void
grade_backtrace(void) {
  1000e3:	55                   	push   %ebp
  1000e4:	89 e5                	mov    %esp,%ebp
  1000e6:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e9:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000ee:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f5:	ff 
  1000f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100101:	e8 c2 ff ff ff       	call   1000c8 <grade_backtrace0>
}
  100106:	90                   	nop
  100107:	c9                   	leave  
  100108:	c3                   	ret    

00100109 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100109:	55                   	push   %ebp
  10010a:	89 e5                	mov    %esp,%ebp
  10010c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100112:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100115:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100118:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10011b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011f:	83 e0 03             	and    $0x3,%eax
  100122:	89 c2                	mov    %eax,%edx
  100124:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100129:	89 54 24 08          	mov    %edx,0x8(%esp)
  10012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100131:	c7 04 24 81 36 10 00 	movl   $0x103681,(%esp)
  100138:	e8 2f 01 00 00       	call   10026c <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10013d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100141:	89 c2                	mov    %eax,%edx
  100143:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100148:	89 54 24 08          	mov    %edx,0x8(%esp)
  10014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100150:	c7 04 24 8f 36 10 00 	movl   $0x10368f,(%esp)
  100157:	e8 10 01 00 00       	call   10026c <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10015c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100160:	89 c2                	mov    %eax,%edx
  100162:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100167:	89 54 24 08          	mov    %edx,0x8(%esp)
  10016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016f:	c7 04 24 9d 36 10 00 	movl   $0x10369d,(%esp)
  100176:	e8 f1 00 00 00       	call   10026c <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10017b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017f:	89 c2                	mov    %eax,%edx
  100181:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100186:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018e:	c7 04 24 ab 36 10 00 	movl   $0x1036ab,(%esp)
  100195:	e8 d2 00 00 00       	call   10026c <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10019e:	89 c2                	mov    %eax,%edx
  1001a0:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001ad:	c7 04 24 b9 36 10 00 	movl   $0x1036b9,(%esp)
  1001b4:	e8 b3 00 00 00       	call   10026c <cprintf>
    round ++;
  1001b9:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001be:	40                   	inc    %eax
  1001bf:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001c4:	90                   	nop
  1001c5:	c9                   	leave  
  1001c6:	c3                   	ret    

001001c7 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001c7:	55                   	push   %ebp
  1001c8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO  
    asm volatile(
  1001ca:	83 ec 08             	sub    $0x8,%esp
  1001cd:	cd 78                	int    $0x78
  1001cf:	89 ec                	mov    %ebp,%esp
        "movl %%ebp, %%esp;"
        :
        : "i"(T_SWITCH_TOU)
    );
    //cprintf("to user finish \n");
}
  1001d1:	90                   	nop
  1001d2:	5d                   	pop    %ebp
  1001d3:	c3                   	ret    

001001d4 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001d4:	55                   	push   %ebp
  1001d5:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  1001d7:	cd 79                	int    $0x79
  1001d9:	89 ec                	mov    %ebp,%esp
	    "movl %%ebp, %%esp;"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
    //cprintf("to kernel finish \n");
}
  1001db:	90                   	nop
  1001dc:	5d                   	pop    %ebp
  1001dd:	c3                   	ret    

001001de <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001de:	55                   	push   %ebp
  1001df:	89 e5                	mov    %esp,%ebp
  1001e1:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001e4:	e8 20 ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001e9:	c7 04 24 c8 36 10 00 	movl   $0x1036c8,(%esp)
  1001f0:	e8 77 00 00 00       	call   10026c <cprintf>
    lab1_switch_to_user();
  1001f5:	e8 cd ff ff ff       	call   1001c7 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001fa:	e8 0a ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001ff:	c7 04 24 e8 36 10 00 	movl   $0x1036e8,(%esp)
  100206:	e8 61 00 00 00       	call   10026c <cprintf>
    lab1_switch_to_kernel();
  10020b:	e8 c4 ff ff ff       	call   1001d4 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100210:	e8 f4 fe ff ff       	call   100109 <lab1_print_cur_status>
}
  100215:	90                   	nop
  100216:	c9                   	leave  
  100217:	c3                   	ret    

00100218 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100218:	55                   	push   %ebp
  100219:	89 e5                	mov    %esp,%ebp
  10021b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10021e:	8b 45 08             	mov    0x8(%ebp),%eax
  100221:	89 04 24             	mov    %eax,(%esp)
  100224:	e8 87 13 00 00       	call   1015b0 <cons_putc>
    (*cnt) ++;
  100229:	8b 45 0c             	mov    0xc(%ebp),%eax
  10022c:	8b 00                	mov    (%eax),%eax
  10022e:	8d 50 01             	lea    0x1(%eax),%edx
  100231:	8b 45 0c             	mov    0xc(%ebp),%eax
  100234:	89 10                	mov    %edx,(%eax)
}
  100236:	90                   	nop
  100237:	c9                   	leave  
  100238:	c3                   	ret    

00100239 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100239:	55                   	push   %ebp
  10023a:	89 e5                	mov    %esp,%ebp
  10023c:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10023f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100246:	8b 45 0c             	mov    0xc(%ebp),%eax
  100249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10024d:	8b 45 08             	mov    0x8(%ebp),%eax
  100250:	89 44 24 08          	mov    %eax,0x8(%esp)
  100254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100257:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025b:	c7 04 24 18 02 10 00 	movl   $0x100218,(%esp)
  100262:	e8 4f 2f 00 00       	call   1031b6 <vprintfmt>
    return cnt;
  100267:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10026a:	c9                   	leave  
  10026b:	c3                   	ret    

0010026c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10026c:	55                   	push   %ebp
  10026d:	89 e5                	mov    %esp,%ebp
  10026f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100272:	8d 45 0c             	lea    0xc(%ebp),%eax
  100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10027f:	8b 45 08             	mov    0x8(%ebp),%eax
  100282:	89 04 24             	mov    %eax,(%esp)
  100285:	e8 af ff ff ff       	call   100239 <vcprintf>
  10028a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100298:	8b 45 08             	mov    0x8(%ebp),%eax
  10029b:	89 04 24             	mov    %eax,(%esp)
  10029e:	e8 0d 13 00 00       	call   1015b0 <cons_putc>
}
  1002a3:	90                   	nop
  1002a4:	c9                   	leave  
  1002a5:	c3                   	ret    

001002a6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002a6:	55                   	push   %ebp
  1002a7:	89 e5                	mov    %esp,%ebp
  1002a9:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002b3:	eb 13                	jmp    1002c8 <cputs+0x22>
        cputch(c, &cnt);
  1002b5:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002b9:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002c0:	89 04 24             	mov    %eax,(%esp)
  1002c3:	e8 50 ff ff ff       	call   100218 <cputch>
    while ((c = *str ++) != '\0') {
  1002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1002cb:	8d 50 01             	lea    0x1(%eax),%edx
  1002ce:	89 55 08             	mov    %edx,0x8(%ebp)
  1002d1:	0f b6 00             	movzbl (%eax),%eax
  1002d4:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002d7:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002db:	75 d8                	jne    1002b5 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1002dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002e4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1002eb:	e8 28 ff ff ff       	call   100218 <cputch>
    return cnt;
  1002f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002f3:	c9                   	leave  
  1002f4:	c3                   	ret    

001002f5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002f5:	55                   	push   %ebp
  1002f6:	89 e5                	mov    %esp,%ebp
  1002f8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002fb:	e8 da 12 00 00       	call   1015da <cons_getc>
  100300:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100303:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100307:	74 f2                	je     1002fb <getchar+0x6>
        /* do nothing */;
    return c;
  100309:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10030c:	c9                   	leave  
  10030d:	c3                   	ret    

0010030e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10030e:	55                   	push   %ebp
  10030f:	89 e5                	mov    %esp,%ebp
  100311:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100314:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100318:	74 13                	je     10032d <readline+0x1f>
        cprintf("%s", prompt);
  10031a:	8b 45 08             	mov    0x8(%ebp),%eax
  10031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100321:	c7 04 24 07 37 10 00 	movl   $0x103707,(%esp)
  100328:	e8 3f ff ff ff       	call   10026c <cprintf>
    }
    int i = 0, c;
  10032d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100334:	e8 bc ff ff ff       	call   1002f5 <getchar>
  100339:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10033c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100340:	79 07                	jns    100349 <readline+0x3b>
            return NULL;
  100342:	b8 00 00 00 00       	mov    $0x0,%eax
  100347:	eb 78                	jmp    1003c1 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100349:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10034d:	7e 28                	jle    100377 <readline+0x69>
  10034f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100356:	7f 1f                	jg     100377 <readline+0x69>
            cputchar(c);
  100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10035b:	89 04 24             	mov    %eax,(%esp)
  10035e:	e8 2f ff ff ff       	call   100292 <cputchar>
            buf[i ++] = c;
  100363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100366:	8d 50 01             	lea    0x1(%eax),%edx
  100369:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10036c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10036f:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100375:	eb 45                	jmp    1003bc <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  100377:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  10037b:	75 16                	jne    100393 <readline+0x85>
  10037d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100381:	7e 10                	jle    100393 <readline+0x85>
            cputchar(c);
  100383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100386:	89 04 24             	mov    %eax,(%esp)
  100389:	e8 04 ff ff ff       	call   100292 <cputchar>
            i --;
  10038e:	ff 4d f4             	decl   -0xc(%ebp)
  100391:	eb 29                	jmp    1003bc <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  100393:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100397:	74 06                	je     10039f <readline+0x91>
  100399:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10039d:	75 95                	jne    100334 <readline+0x26>
            cputchar(c);
  10039f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003a2:	89 04 24             	mov    %eax,(%esp)
  1003a5:	e8 e8 fe ff ff       	call   100292 <cputchar>
            buf[i] = '\0';
  1003aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003ad:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1003b2:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003b5:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1003ba:	eb 05                	jmp    1003c1 <readline+0xb3>
        c = getchar();
  1003bc:	e9 73 ff ff ff       	jmp    100334 <readline+0x26>
        }
    }
}
  1003c1:	c9                   	leave  
  1003c2:	c3                   	ret    

001003c3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003c3:	55                   	push   %ebp
  1003c4:	89 e5                	mov    %esp,%ebp
  1003c6:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003c9:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  1003ce:	85 c0                	test   %eax,%eax
  1003d0:	75 5b                	jne    10042d <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003d2:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  1003d9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003dc:	8d 45 14             	lea    0x14(%ebp),%eax
  1003df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003f0:	c7 04 24 0a 37 10 00 	movl   $0x10370a,(%esp)
  1003f7:	e8 70 fe ff ff       	call   10026c <cprintf>
    vcprintf(fmt, ap);
  1003fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  100403:	8b 45 10             	mov    0x10(%ebp),%eax
  100406:	89 04 24             	mov    %eax,(%esp)
  100409:	e8 2b fe ff ff       	call   100239 <vcprintf>
    cprintf("\n");
  10040e:	c7 04 24 26 37 10 00 	movl   $0x103726,(%esp)
  100415:	e8 52 fe ff ff       	call   10026c <cprintf>
    
    cprintf("stack trackback:\n");
  10041a:	c7 04 24 28 37 10 00 	movl   $0x103728,(%esp)
  100421:	e8 46 fe ff ff       	call   10026c <cprintf>
    print_stackframe();
  100426:	e8 32 06 00 00       	call   100a5d <print_stackframe>
  10042b:	eb 01                	jmp    10042e <__panic+0x6b>
        goto panic_dead;
  10042d:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  10042e:	e8 d0 13 00 00       	call   101803 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100433:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10043a:	e8 46 08 00 00       	call   100c85 <kmonitor>
  10043f:	eb f2                	jmp    100433 <__panic+0x70>

00100441 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100441:	55                   	push   %ebp
  100442:	89 e5                	mov    %esp,%ebp
  100444:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100447:	8d 45 14             	lea    0x14(%ebp),%eax
  10044a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  10044d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100450:	89 44 24 08          	mov    %eax,0x8(%esp)
  100454:	8b 45 08             	mov    0x8(%ebp),%eax
  100457:	89 44 24 04          	mov    %eax,0x4(%esp)
  10045b:	c7 04 24 3a 37 10 00 	movl   $0x10373a,(%esp)
  100462:	e8 05 fe ff ff       	call   10026c <cprintf>
    vcprintf(fmt, ap);
  100467:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10046a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10046e:	8b 45 10             	mov    0x10(%ebp),%eax
  100471:	89 04 24             	mov    %eax,(%esp)
  100474:	e8 c0 fd ff ff       	call   100239 <vcprintf>
    cprintf("\n");
  100479:	c7 04 24 26 37 10 00 	movl   $0x103726,(%esp)
  100480:	e8 e7 fd ff ff       	call   10026c <cprintf>
    va_end(ap);
}
  100485:	90                   	nop
  100486:	c9                   	leave  
  100487:	c3                   	ret    

00100488 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100488:	55                   	push   %ebp
  100489:	89 e5                	mov    %esp,%ebp
    return is_panic;
  10048b:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100490:	5d                   	pop    %ebp
  100491:	c3                   	ret    

00100492 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100492:	55                   	push   %ebp
  100493:	89 e5                	mov    %esp,%ebp
  100495:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100498:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049b:	8b 00                	mov    (%eax),%eax
  10049d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a3:	8b 00                	mov    (%eax),%eax
  1004a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004af:	e9 ca 00 00 00       	jmp    10057e <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004ba:	01 d0                	add    %edx,%eax
  1004bc:	89 c2                	mov    %eax,%edx
  1004be:	c1 ea 1f             	shr    $0x1f,%edx
  1004c1:	01 d0                	add    %edx,%eax
  1004c3:	d1 f8                	sar    %eax
  1004c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004ce:	eb 03                	jmp    1004d3 <stab_binsearch+0x41>
            m --;
  1004d0:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004d9:	7c 1f                	jl     1004fa <stab_binsearch+0x68>
  1004db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004de:	89 d0                	mov    %edx,%eax
  1004e0:	01 c0                	add    %eax,%eax
  1004e2:	01 d0                	add    %edx,%eax
  1004e4:	c1 e0 02             	shl    $0x2,%eax
  1004e7:	89 c2                	mov    %eax,%edx
  1004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ec:	01 d0                	add    %edx,%eax
  1004ee:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004f2:	0f b6 c0             	movzbl %al,%eax
  1004f5:	39 45 14             	cmp    %eax,0x14(%ebp)
  1004f8:	75 d6                	jne    1004d0 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  1004fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100500:	7d 09                	jge    10050b <stab_binsearch+0x79>
            l = true_m + 1;
  100502:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100505:	40                   	inc    %eax
  100506:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100509:	eb 73                	jmp    10057e <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10050b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100512:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100515:	89 d0                	mov    %edx,%eax
  100517:	01 c0                	add    %eax,%eax
  100519:	01 d0                	add    %edx,%eax
  10051b:	c1 e0 02             	shl    $0x2,%eax
  10051e:	89 c2                	mov    %eax,%edx
  100520:	8b 45 08             	mov    0x8(%ebp),%eax
  100523:	01 d0                	add    %edx,%eax
  100525:	8b 40 08             	mov    0x8(%eax),%eax
  100528:	39 45 18             	cmp    %eax,0x18(%ebp)
  10052b:	76 11                	jbe    10053e <stab_binsearch+0xac>
            *region_left = m;
  10052d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100530:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100533:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100538:	40                   	inc    %eax
  100539:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10053c:	eb 40                	jmp    10057e <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  10053e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100541:	89 d0                	mov    %edx,%eax
  100543:	01 c0                	add    %eax,%eax
  100545:	01 d0                	add    %edx,%eax
  100547:	c1 e0 02             	shl    $0x2,%eax
  10054a:	89 c2                	mov    %eax,%edx
  10054c:	8b 45 08             	mov    0x8(%ebp),%eax
  10054f:	01 d0                	add    %edx,%eax
  100551:	8b 40 08             	mov    0x8(%eax),%eax
  100554:	39 45 18             	cmp    %eax,0x18(%ebp)
  100557:	73 14                	jae    10056d <stab_binsearch+0xdb>
            *region_right = m - 1;
  100559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10055c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10055f:	8b 45 10             	mov    0x10(%ebp),%eax
  100562:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100567:	48                   	dec    %eax
  100568:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10056b:	eb 11                	jmp    10057e <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  10056d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100570:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100573:	89 10                	mov    %edx,(%eax)
            l = m;
  100575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100578:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  10057b:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  10057e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100581:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100584:	0f 8e 2a ff ff ff    	jle    1004b4 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  10058a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10058e:	75 0f                	jne    10059f <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  100590:	8b 45 0c             	mov    0xc(%ebp),%eax
  100593:	8b 00                	mov    (%eax),%eax
  100595:	8d 50 ff             	lea    -0x1(%eax),%edx
  100598:	8b 45 10             	mov    0x10(%ebp),%eax
  10059b:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10059d:	eb 3e                	jmp    1005dd <stab_binsearch+0x14b>
        l = *region_right;
  10059f:	8b 45 10             	mov    0x10(%ebp),%eax
  1005a2:	8b 00                	mov    (%eax),%eax
  1005a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005a7:	eb 03                	jmp    1005ac <stab_binsearch+0x11a>
  1005a9:	ff 4d fc             	decl   -0x4(%ebp)
  1005ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005af:	8b 00                	mov    (%eax),%eax
  1005b1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1005b4:	7e 1f                	jle    1005d5 <stab_binsearch+0x143>
  1005b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005b9:	89 d0                	mov    %edx,%eax
  1005bb:	01 c0                	add    %eax,%eax
  1005bd:	01 d0                	add    %edx,%eax
  1005bf:	c1 e0 02             	shl    $0x2,%eax
  1005c2:	89 c2                	mov    %eax,%edx
  1005c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005c7:	01 d0                	add    %edx,%eax
  1005c9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005cd:	0f b6 c0             	movzbl %al,%eax
  1005d0:	39 45 14             	cmp    %eax,0x14(%ebp)
  1005d3:	75 d4                	jne    1005a9 <stab_binsearch+0x117>
        *region_left = l;
  1005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005db:	89 10                	mov    %edx,(%eax)
}
  1005dd:	90                   	nop
  1005de:	c9                   	leave  
  1005df:	c3                   	ret    

001005e0 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005e0:	55                   	push   %ebp
  1005e1:	89 e5                	mov    %esp,%ebp
  1005e3:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e9:	c7 00 58 37 10 00    	movl   $0x103758,(%eax)
    info->eip_line = 0;
  1005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fc:	c7 40 08 58 37 10 00 	movl   $0x103758,0x8(%eax)
    info->eip_fn_namelen = 9;
  100603:	8b 45 0c             	mov    0xc(%ebp),%eax
  100606:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10060d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100610:	8b 55 08             	mov    0x8(%ebp),%edx
  100613:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100616:	8b 45 0c             	mov    0xc(%ebp),%eax
  100619:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100620:	c7 45 f4 ac 3f 10 00 	movl   $0x103fac,-0xc(%ebp)
    stab_end = __STAB_END__;
  100627:	c7 45 f0 30 be 10 00 	movl   $0x10be30,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10062e:	c7 45 ec 31 be 10 00 	movl   $0x10be31,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100635:	c7 45 e8 0d df 10 00 	movl   $0x10df0d,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10063c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100642:	76 0b                	jbe    10064f <debuginfo_eip+0x6f>
  100644:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100647:	48                   	dec    %eax
  100648:	0f b6 00             	movzbl (%eax),%eax
  10064b:	84 c0                	test   %al,%al
  10064d:	74 0a                	je     100659 <debuginfo_eip+0x79>
        return -1;
  10064f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100654:	e9 b7 02 00 00       	jmp    100910 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100659:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100666:	29 c2                	sub    %eax,%edx
  100668:	89 d0                	mov    %edx,%eax
  10066a:	c1 f8 02             	sar    $0x2,%eax
  10066d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100673:	48                   	dec    %eax
  100674:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100677:	8b 45 08             	mov    0x8(%ebp),%eax
  10067a:	89 44 24 10          	mov    %eax,0x10(%esp)
  10067e:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100685:	00 
  100686:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100689:	89 44 24 08          	mov    %eax,0x8(%esp)
  10068d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100690:	89 44 24 04          	mov    %eax,0x4(%esp)
  100694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100697:	89 04 24             	mov    %eax,(%esp)
  10069a:	e8 f3 fd ff ff       	call   100492 <stab_binsearch>
    if (lfile == 0)
  10069f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006a2:	85 c0                	test   %eax,%eax
  1006a4:	75 0a                	jne    1006b0 <debuginfo_eip+0xd0>
        return -1;
  1006a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006ab:	e9 60 02 00 00       	jmp    100910 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1006bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006c3:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006ca:	00 
  1006cb:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006dc:	89 04 24             	mov    %eax,(%esp)
  1006df:	e8 ae fd ff ff       	call   100492 <stab_binsearch>

    if (lfun <= rfun) {
  1006e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ea:	39 c2                	cmp    %eax,%edx
  1006ec:	7f 7c                	jg     10076a <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006f1:	89 c2                	mov    %eax,%edx
  1006f3:	89 d0                	mov    %edx,%eax
  1006f5:	01 c0                	add    %eax,%eax
  1006f7:	01 d0                	add    %edx,%eax
  1006f9:	c1 e0 02             	shl    $0x2,%eax
  1006fc:	89 c2                	mov    %eax,%edx
  1006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100701:	01 d0                	add    %edx,%eax
  100703:	8b 00                	mov    (%eax),%eax
  100705:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100708:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10070b:	29 d1                	sub    %edx,%ecx
  10070d:	89 ca                	mov    %ecx,%edx
  10070f:	39 d0                	cmp    %edx,%eax
  100711:	73 22                	jae    100735 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100713:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100716:	89 c2                	mov    %eax,%edx
  100718:	89 d0                	mov    %edx,%eax
  10071a:	01 c0                	add    %eax,%eax
  10071c:	01 d0                	add    %edx,%eax
  10071e:	c1 e0 02             	shl    $0x2,%eax
  100721:	89 c2                	mov    %eax,%edx
  100723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100726:	01 d0                	add    %edx,%eax
  100728:	8b 10                	mov    (%eax),%edx
  10072a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10072d:	01 c2                	add    %eax,%edx
  10072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100732:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100735:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100738:	89 c2                	mov    %eax,%edx
  10073a:	89 d0                	mov    %edx,%eax
  10073c:	01 c0                	add    %eax,%eax
  10073e:	01 d0                	add    %edx,%eax
  100740:	c1 e0 02             	shl    $0x2,%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100748:	01 d0                	add    %edx,%eax
  10074a:	8b 50 08             	mov    0x8(%eax),%edx
  10074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100750:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100753:	8b 45 0c             	mov    0xc(%ebp),%eax
  100756:	8b 40 10             	mov    0x10(%eax),%eax
  100759:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10075c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100762:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100765:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100768:	eb 15                	jmp    10077f <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10076a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10076d:	8b 55 08             	mov    0x8(%ebp),%edx
  100770:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100776:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100779:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10077c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  10077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100782:	8b 40 08             	mov    0x8(%eax),%eax
  100785:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  10078c:	00 
  10078d:	89 04 24             	mov    %eax,(%esp)
  100790:	e8 4a 25 00 00       	call   102cdf <strfind>
  100795:	89 c2                	mov    %eax,%edx
  100797:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079a:	8b 40 08             	mov    0x8(%eax),%eax
  10079d:	29 c2                	sub    %eax,%edx
  10079f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a2:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1007a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007ac:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007b3:	00 
  1007b4:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007bb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007be:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c5:	89 04 24             	mov    %eax,(%esp)
  1007c8:	e8 c5 fc ff ff       	call   100492 <stab_binsearch>
    if (lline <= rline) {
  1007cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007d3:	39 c2                	cmp    %eax,%edx
  1007d5:	7f 23                	jg     1007fa <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007da:	89 c2                	mov    %eax,%edx
  1007dc:	89 d0                	mov    %edx,%eax
  1007de:	01 c0                	add    %eax,%eax
  1007e0:	01 d0                	add    %edx,%eax
  1007e2:	c1 e0 02             	shl    $0x2,%eax
  1007e5:	89 c2                	mov    %eax,%edx
  1007e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ea:	01 d0                	add    %edx,%eax
  1007ec:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007f0:	89 c2                	mov    %eax,%edx
  1007f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f5:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007f8:	eb 11                	jmp    10080b <debuginfo_eip+0x22b>
        return -1;
  1007fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007ff:	e9 0c 01 00 00       	jmp    100910 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100804:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100807:	48                   	dec    %eax
  100808:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  10080b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10080e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100811:	39 c2                	cmp    %eax,%edx
  100813:	7c 56                	jl     10086b <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  100815:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100818:	89 c2                	mov    %eax,%edx
  10081a:	89 d0                	mov    %edx,%eax
  10081c:	01 c0                	add    %eax,%eax
  10081e:	01 d0                	add    %edx,%eax
  100820:	c1 e0 02             	shl    $0x2,%eax
  100823:	89 c2                	mov    %eax,%edx
  100825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100828:	01 d0                	add    %edx,%eax
  10082a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10082e:	3c 84                	cmp    $0x84,%al
  100830:	74 39                	je     10086b <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100835:	89 c2                	mov    %eax,%edx
  100837:	89 d0                	mov    %edx,%eax
  100839:	01 c0                	add    %eax,%eax
  10083b:	01 d0                	add    %edx,%eax
  10083d:	c1 e0 02             	shl    $0x2,%eax
  100840:	89 c2                	mov    %eax,%edx
  100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100845:	01 d0                	add    %edx,%eax
  100847:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10084b:	3c 64                	cmp    $0x64,%al
  10084d:	75 b5                	jne    100804 <debuginfo_eip+0x224>
  10084f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100852:	89 c2                	mov    %eax,%edx
  100854:	89 d0                	mov    %edx,%eax
  100856:	01 c0                	add    %eax,%eax
  100858:	01 d0                	add    %edx,%eax
  10085a:	c1 e0 02             	shl    $0x2,%eax
  10085d:	89 c2                	mov    %eax,%edx
  10085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100862:	01 d0                	add    %edx,%eax
  100864:	8b 40 08             	mov    0x8(%eax),%eax
  100867:	85 c0                	test   %eax,%eax
  100869:	74 99                	je     100804 <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10086b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10086e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100871:	39 c2                	cmp    %eax,%edx
  100873:	7c 46                	jl     1008bb <debuginfo_eip+0x2db>
  100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100878:	89 c2                	mov    %eax,%edx
  10087a:	89 d0                	mov    %edx,%eax
  10087c:	01 c0                	add    %eax,%eax
  10087e:	01 d0                	add    %edx,%eax
  100880:	c1 e0 02             	shl    $0x2,%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100888:	01 d0                	add    %edx,%eax
  10088a:	8b 00                	mov    (%eax),%eax
  10088c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10088f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100892:	29 d1                	sub    %edx,%ecx
  100894:	89 ca                	mov    %ecx,%edx
  100896:	39 d0                	cmp    %edx,%eax
  100898:	73 21                	jae    1008bb <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  10089a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089d:	89 c2                	mov    %eax,%edx
  10089f:	89 d0                	mov    %edx,%eax
  1008a1:	01 c0                	add    %eax,%eax
  1008a3:	01 d0                	add    %edx,%eax
  1008a5:	c1 e0 02             	shl    $0x2,%eax
  1008a8:	89 c2                	mov    %eax,%edx
  1008aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ad:	01 d0                	add    %edx,%eax
  1008af:	8b 10                	mov    (%eax),%edx
  1008b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008b4:	01 c2                	add    %eax,%edx
  1008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008c1:	39 c2                	cmp    %eax,%edx
  1008c3:	7d 46                	jge    10090b <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008c8:	40                   	inc    %eax
  1008c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008cc:	eb 16                	jmp    1008e4 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008d1:	8b 40 14             	mov    0x14(%eax),%eax
  1008d4:	8d 50 01             	lea    0x1(%eax),%edx
  1008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008da:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  1008dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008e0:	40                   	inc    %eax
  1008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  1008ea:	39 c2                	cmp    %eax,%edx
  1008ec:	7d 1d                	jge    10090b <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f1:	89 c2                	mov    %eax,%edx
  1008f3:	89 d0                	mov    %edx,%eax
  1008f5:	01 c0                	add    %eax,%eax
  1008f7:	01 d0                	add    %edx,%eax
  1008f9:	c1 e0 02             	shl    $0x2,%eax
  1008fc:	89 c2                	mov    %eax,%edx
  1008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100901:	01 d0                	add    %edx,%eax
  100903:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100907:	3c a0                	cmp    $0xa0,%al
  100909:	74 c3                	je     1008ce <debuginfo_eip+0x2ee>
        }
    }
    return 0;
  10090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100918:	c7 04 24 62 37 10 00 	movl   $0x103762,(%esp)
  10091f:	e8 48 f9 ff ff       	call   10026c <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100924:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10092b:	00 
  10092c:	c7 04 24 7b 37 10 00 	movl   $0x10377b,(%esp)
  100933:	e8 34 f9 ff ff       	call   10026c <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100938:	c7 44 24 04 5d 36 10 	movl   $0x10365d,0x4(%esp)
  10093f:	00 
  100940:	c7 04 24 93 37 10 00 	movl   $0x103793,(%esp)
  100947:	e8 20 f9 ff ff       	call   10026c <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  10094c:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100953:	00 
  100954:	c7 04 24 ab 37 10 00 	movl   $0x1037ab,(%esp)
  10095b:	e8 0c f9 ff ff       	call   10026c <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100960:	c7 44 24 04 20 fd 10 	movl   $0x10fd20,0x4(%esp)
  100967:	00 
  100968:	c7 04 24 c3 37 10 00 	movl   $0x1037c3,(%esp)
  10096f:	e8 f8 f8 ff ff       	call   10026c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100974:	b8 20 fd 10 00       	mov    $0x10fd20,%eax
  100979:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10097f:	b8 00 00 10 00       	mov    $0x100000,%eax
  100984:	29 c2                	sub    %eax,%edx
  100986:	89 d0                	mov    %edx,%eax
  100988:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10098e:	85 c0                	test   %eax,%eax
  100990:	0f 48 c2             	cmovs  %edx,%eax
  100993:	c1 f8 0a             	sar    $0xa,%eax
  100996:	89 44 24 04          	mov    %eax,0x4(%esp)
  10099a:	c7 04 24 dc 37 10 00 	movl   $0x1037dc,(%esp)
  1009a1:	e8 c6 f8 ff ff       	call   10026c <cprintf>
}
  1009a6:	90                   	nop
  1009a7:	c9                   	leave  
  1009a8:	c3                   	ret    

001009a9 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009a9:	55                   	push   %ebp
  1009aa:	89 e5                	mov    %esp,%ebp
  1009ac:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009b2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1009bc:	89 04 24             	mov    %eax,(%esp)
  1009bf:	e8 1c fc ff ff       	call   1005e0 <debuginfo_eip>
  1009c4:	85 c0                	test   %eax,%eax
  1009c6:	74 15                	je     1009dd <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009cf:	c7 04 24 06 38 10 00 	movl   $0x103806,(%esp)
  1009d6:	e8 91 f8 ff ff       	call   10026c <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009db:	eb 6c                	jmp    100a49 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009e4:	eb 1b                	jmp    100a01 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  1009e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ec:	01 d0                	add    %edx,%eax
  1009ee:	0f b6 00             	movzbl (%eax),%eax
  1009f1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009fa:	01 ca                	add    %ecx,%edx
  1009fc:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009fe:	ff 45 f4             	incl   -0xc(%ebp)
  100a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a07:	7c dd                	jl     1009e6 <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100a09:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a12:	01 d0                	add    %edx,%eax
  100a14:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  100a1d:	89 d1                	mov    %edx,%ecx
  100a1f:	29 c1                	sub    %eax,%ecx
  100a21:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a24:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a27:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a2b:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a31:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a35:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a3d:	c7 04 24 22 38 10 00 	movl   $0x103822,(%esp)
  100a44:	e8 23 f8 ff ff       	call   10026c <cprintf>
}
  100a49:	90                   	nop
  100a4a:	c9                   	leave  
  100a4b:	c3                   	ret    

00100a4c <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a4c:	55                   	push   %ebp
  100a4d:	89 e5                	mov    %esp,%ebp
  100a4f:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a52:	8b 45 04             	mov    0x4(%ebp),%eax
  100a55:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a5b:	c9                   	leave  
  100a5c:	c3                   	ret    

00100a5d <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a5d:	55                   	push   %ebp
  100a5e:	89 e5                	mov    %esp,%ebp
  100a60:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a63:	89 e8                	mov    %ebp,%eax
  100a65:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a68:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
  100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  100a6e:	e8 d9 ff ff ff       	call   100a4c <read_eip>
  100a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  100a76:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a7d:	e9 84 00 00 00       	jmp    100b06 <print_stackframe+0xa9>
    	cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
  100a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a90:	c7 04 24 34 38 10 00 	movl   $0x103834,(%esp)
  100a97:	e8 d0 f7 ff ff       	call   10026c <cprintf>
    	uint32_t *calling_arguments = (uint32_t *) ebp + 2;
  100a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a9f:	83 c0 08             	add    $0x8,%eax
  100aa2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    	for(int j=0;j<4;j++)
  100aa5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100aac:	eb 24                	jmp    100ad2 <print_stackframe+0x75>
    		cprintf(" 0x%08x ", calling_arguments[j]);		
  100aae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ab1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ab8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100abb:	01 d0                	add    %edx,%eax
  100abd:	8b 00                	mov    (%eax),%eax
  100abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ac3:	c7 04 24 50 38 10 00 	movl   $0x103850,(%esp)
  100aca:	e8 9d f7 ff ff       	call   10026c <cprintf>
    	for(int j=0;j<4;j++)
  100acf:	ff 45 e8             	incl   -0x18(%ebp)
  100ad2:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100ad6:	7e d6                	jle    100aae <print_stackframe+0x51>
        cprintf("\n");
  100ad8:	c7 04 24 59 38 10 00 	movl   $0x103859,(%esp)
  100adf:	e8 88 f7 ff ff       	call   10026c <cprintf>
		print_debuginfo(eip-1);
  100ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ae7:	48                   	dec    %eax
  100ae8:	89 04 24             	mov    %eax,(%esp)
  100aeb:	e8 b9 fe ff ff       	call   1009a9 <print_debuginfo>
    	eip = ((uint32_t *)ebp)[1];
  100af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af3:	83 c0 04             	add    $0x4,%eax
  100af6:	8b 00                	mov    (%eax),%eax
  100af8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    	ebp = ((uint32_t *)ebp)[0];
  100afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100afe:	8b 00                	mov    (%eax),%eax
  100b00:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(int i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  100b03:	ff 45 ec             	incl   -0x14(%ebp)
  100b06:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b0a:	7f 0a                	jg     100b16 <print_stackframe+0xb9>
  100b0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b10:	0f 85 6c ff ff ff    	jne    100a82 <print_stackframe+0x25>
	}
}
  100b16:	90                   	nop
  100b17:	c9                   	leave  
  100b18:	c3                   	ret    

00100b19 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b19:	55                   	push   %ebp
  100b1a:	89 e5                	mov    %esp,%ebp
  100b1c:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b26:	eb 0c                	jmp    100b34 <parse+0x1b>
            *buf ++ = '\0';
  100b28:	8b 45 08             	mov    0x8(%ebp),%eax
  100b2b:	8d 50 01             	lea    0x1(%eax),%edx
  100b2e:	89 55 08             	mov    %edx,0x8(%ebp)
  100b31:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b34:	8b 45 08             	mov    0x8(%ebp),%eax
  100b37:	0f b6 00             	movzbl (%eax),%eax
  100b3a:	84 c0                	test   %al,%al
  100b3c:	74 1d                	je     100b5b <parse+0x42>
  100b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b41:	0f b6 00             	movzbl (%eax),%eax
  100b44:	0f be c0             	movsbl %al,%eax
  100b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4b:	c7 04 24 dc 38 10 00 	movl   $0x1038dc,(%esp)
  100b52:	e8 56 21 00 00       	call   102cad <strchr>
  100b57:	85 c0                	test   %eax,%eax
  100b59:	75 cd                	jne    100b28 <parse+0xf>
        }
        if (*buf == '\0') {
  100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5e:	0f b6 00             	movzbl (%eax),%eax
  100b61:	84 c0                	test   %al,%al
  100b63:	74 65                	je     100bca <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b65:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b69:	75 14                	jne    100b7f <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b6b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b72:	00 
  100b73:	c7 04 24 e1 38 10 00 	movl   $0x1038e1,(%esp)
  100b7a:	e8 ed f6 ff ff       	call   10026c <cprintf>
        }
        argv[argc ++] = buf;
  100b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b82:	8d 50 01             	lea    0x1(%eax),%edx
  100b85:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b92:	01 c2                	add    %eax,%edx
  100b94:	8b 45 08             	mov    0x8(%ebp),%eax
  100b97:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b99:	eb 03                	jmp    100b9e <parse+0x85>
            buf ++;
  100b9b:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  100ba1:	0f b6 00             	movzbl (%eax),%eax
  100ba4:	84 c0                	test   %al,%al
  100ba6:	74 8c                	je     100b34 <parse+0x1b>
  100ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  100bab:	0f b6 00             	movzbl (%eax),%eax
  100bae:	0f be c0             	movsbl %al,%eax
  100bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bb5:	c7 04 24 dc 38 10 00 	movl   $0x1038dc,(%esp)
  100bbc:	e8 ec 20 00 00       	call   102cad <strchr>
  100bc1:	85 c0                	test   %eax,%eax
  100bc3:	74 d6                	je     100b9b <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bc5:	e9 6a ff ff ff       	jmp    100b34 <parse+0x1b>
            break;
  100bca:	90                   	nop
        }
    }
    return argc;
  100bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bce:	c9                   	leave  
  100bcf:	c3                   	ret    

00100bd0 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bd0:	55                   	push   %ebp
  100bd1:	89 e5                	mov    %esp,%ebp
  100bd3:	53                   	push   %ebx
  100bd4:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bd7:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bde:	8b 45 08             	mov    0x8(%ebp),%eax
  100be1:	89 04 24             	mov    %eax,(%esp)
  100be4:	e8 30 ff ff ff       	call   100b19 <parse>
  100be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100bf0:	75 0a                	jne    100bfc <runcmd+0x2c>
        return 0;
  100bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  100bf7:	e9 83 00 00 00       	jmp    100c7f <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bfc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c03:	eb 5a                	jmp    100c5f <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c05:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c0b:	89 d0                	mov    %edx,%eax
  100c0d:	01 c0                	add    %eax,%eax
  100c0f:	01 d0                	add    %edx,%eax
  100c11:	c1 e0 02             	shl    $0x2,%eax
  100c14:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c19:	8b 00                	mov    (%eax),%eax
  100c1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c1f:	89 04 24             	mov    %eax,(%esp)
  100c22:	e8 e9 1f 00 00       	call   102c10 <strcmp>
  100c27:	85 c0                	test   %eax,%eax
  100c29:	75 31                	jne    100c5c <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c2e:	89 d0                	mov    %edx,%eax
  100c30:	01 c0                	add    %eax,%eax
  100c32:	01 d0                	add    %edx,%eax
  100c34:	c1 e0 02             	shl    $0x2,%eax
  100c37:	05 08 e0 10 00       	add    $0x10e008,%eax
  100c3c:	8b 10                	mov    (%eax),%edx
  100c3e:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c41:	83 c0 04             	add    $0x4,%eax
  100c44:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c47:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c55:	89 1c 24             	mov    %ebx,(%esp)
  100c58:	ff d2                	call   *%edx
  100c5a:	eb 23                	jmp    100c7f <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c5c:	ff 45 f4             	incl   -0xc(%ebp)
  100c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c62:	83 f8 02             	cmp    $0x2,%eax
  100c65:	76 9e                	jbe    100c05 <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c67:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c6e:	c7 04 24 ff 38 10 00 	movl   $0x1038ff,(%esp)
  100c75:	e8 f2 f5 ff ff       	call   10026c <cprintf>
    return 0;
  100c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c7f:	83 c4 64             	add    $0x64,%esp
  100c82:	5b                   	pop    %ebx
  100c83:	5d                   	pop    %ebp
  100c84:	c3                   	ret    

00100c85 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c85:	55                   	push   %ebp
  100c86:	89 e5                	mov    %esp,%ebp
  100c88:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c8b:	c7 04 24 18 39 10 00 	movl   $0x103918,(%esp)
  100c92:	e8 d5 f5 ff ff       	call   10026c <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c97:	c7 04 24 40 39 10 00 	movl   $0x103940,(%esp)
  100c9e:	e8 c9 f5 ff ff       	call   10026c <cprintf>

    if (tf != NULL) {
  100ca3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ca7:	74 0b                	je     100cb4 <kmonitor+0x2f>
        print_trapframe(tf);
  100ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  100cac:	89 04 24             	mov    %eax,(%esp)
  100caf:	e8 a4 0d 00 00       	call   101a58 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cb4:	c7 04 24 65 39 10 00 	movl   $0x103965,(%esp)
  100cbb:	e8 4e f6 ff ff       	call   10030e <readline>
  100cc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cc7:	74 eb                	je     100cb4 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  100ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cd3:	89 04 24             	mov    %eax,(%esp)
  100cd6:	e8 f5 fe ff ff       	call   100bd0 <runcmd>
  100cdb:	85 c0                	test   %eax,%eax
  100cdd:	78 02                	js     100ce1 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100cdf:	eb d3                	jmp    100cb4 <kmonitor+0x2f>
                break;
  100ce1:	90                   	nop
            }
        }
    }
}
  100ce2:	90                   	nop
  100ce3:	c9                   	leave  
  100ce4:	c3                   	ret    

00100ce5 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100ce5:	55                   	push   %ebp
  100ce6:	89 e5                	mov    %esp,%ebp
  100ce8:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ceb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100cf2:	eb 3d                	jmp    100d31 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100cf4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cf7:	89 d0                	mov    %edx,%eax
  100cf9:	01 c0                	add    %eax,%eax
  100cfb:	01 d0                	add    %edx,%eax
  100cfd:	c1 e0 02             	shl    $0x2,%eax
  100d00:	05 04 e0 10 00       	add    $0x10e004,%eax
  100d05:	8b 08                	mov    (%eax),%ecx
  100d07:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d0a:	89 d0                	mov    %edx,%eax
  100d0c:	01 c0                	add    %eax,%eax
  100d0e:	01 d0                	add    %edx,%eax
  100d10:	c1 e0 02             	shl    $0x2,%eax
  100d13:	05 00 e0 10 00       	add    $0x10e000,%eax
  100d18:	8b 00                	mov    (%eax),%eax
  100d1a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d22:	c7 04 24 69 39 10 00 	movl   $0x103969,(%esp)
  100d29:	e8 3e f5 ff ff       	call   10026c <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d2e:	ff 45 f4             	incl   -0xc(%ebp)
  100d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d34:	83 f8 02             	cmp    $0x2,%eax
  100d37:	76 bb                	jbe    100cf4 <mon_help+0xf>
    }
    return 0;
  100d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d3e:	c9                   	leave  
  100d3f:	c3                   	ret    

00100d40 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d40:	55                   	push   %ebp
  100d41:	89 e5                	mov    %esp,%ebp
  100d43:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d46:	e8 c7 fb ff ff       	call   100912 <print_kerninfo>
    return 0;
  100d4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d50:	c9                   	leave  
  100d51:	c3                   	ret    

00100d52 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d52:	55                   	push   %ebp
  100d53:	89 e5                	mov    %esp,%ebp
  100d55:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d58:	e8 00 fd ff ff       	call   100a5d <print_stackframe>
    return 0;
  100d5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d62:	c9                   	leave  
  100d63:	c3                   	ret    

00100d64 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d64:	55                   	push   %ebp
  100d65:	89 e5                	mov    %esp,%ebp
  100d67:	83 ec 28             	sub    $0x28,%esp
  100d6a:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100d70:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d74:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100d78:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100d7c:	ee                   	out    %al,(%dx)
  100d7d:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d83:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d87:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d8b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d8f:	ee                   	out    %al,(%dx)
  100d90:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100d96:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100d9a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100d9e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100da2:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100da3:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100daa:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dad:	c7 04 24 72 39 10 00 	movl   $0x103972,(%esp)
  100db4:	e8 b3 f4 ff ff       	call   10026c <cprintf>
    pic_enable(IRQ_TIMER);
  100db9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dc0:	e8 ca 08 00 00       	call   10168f <pic_enable>
}
  100dc5:	90                   	nop
  100dc6:	c9                   	leave  
  100dc7:	c3                   	ret    

00100dc8 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100dc8:	55                   	push   %ebp
  100dc9:	89 e5                	mov    %esp,%ebp
  100dcb:	83 ec 10             	sub    $0x10,%esp
  100dce:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100dd4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100dd8:	89 c2                	mov    %eax,%edx
  100dda:	ec                   	in     (%dx),%al
  100ddb:	88 45 f1             	mov    %al,-0xf(%ebp)
  100dde:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100de4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100de8:	89 c2                	mov    %eax,%edx
  100dea:	ec                   	in     (%dx),%al
  100deb:	88 45 f5             	mov    %al,-0xb(%ebp)
  100dee:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100df4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100df8:	89 c2                	mov    %eax,%edx
  100dfa:	ec                   	in     (%dx),%al
  100dfb:	88 45 f9             	mov    %al,-0x7(%ebp)
  100dfe:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e04:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e08:	89 c2                	mov    %eax,%edx
  100e0a:	ec                   	in     (%dx),%al
  100e0b:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e0e:	90                   	nop
  100e0f:	c9                   	leave  
  100e10:	c3                   	ret    

00100e11 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e11:	55                   	push   %ebp
  100e12:	89 e5                	mov    %esp,%ebp
  100e14:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e17:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e21:	0f b7 00             	movzwl (%eax),%eax
  100e24:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e28:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e2b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e33:	0f b7 00             	movzwl (%eax),%eax
  100e36:	0f b7 c0             	movzwl %ax,%eax
  100e39:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100e3e:	74 12                	je     100e52 <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e40:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e47:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e4e:	b4 03 
  100e50:	eb 13                	jmp    100e65 <cga_init+0x54>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e52:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e55:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e59:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e5c:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e63:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e65:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e6c:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100e70:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e74:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100e78:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100e7c:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e7d:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e84:	40                   	inc    %eax
  100e85:	0f b7 c0             	movzwl %ax,%eax
  100e88:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e8c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100e90:	89 c2                	mov    %eax,%edx
  100e92:	ec                   	in     (%dx),%al
  100e93:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100e96:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100e9a:	0f b6 c0             	movzbl %al,%eax
  100e9d:	c1 e0 08             	shl    $0x8,%eax
  100ea0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100ea3:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100eaa:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100eae:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100eb2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eb6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100eba:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ebb:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ec2:	40                   	inc    %eax
  100ec3:	0f b7 c0             	movzwl %ax,%eax
  100ec6:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100eca:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ece:	89 c2                	mov    %eax,%edx
  100ed0:	ec                   	in     (%dx),%al
  100ed1:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100ed4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100ed8:	0f b6 c0             	movzbl %al,%eax
  100edb:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ee1:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ee9:	0f b7 c0             	movzwl %ax,%eax
  100eec:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100ef2:	90                   	nop
  100ef3:	c9                   	leave  
  100ef4:	c3                   	ret    

00100ef5 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100ef5:	55                   	push   %ebp
  100ef6:	89 e5                	mov    %esp,%ebp
  100ef8:	83 ec 48             	sub    $0x48,%esp
  100efb:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f01:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f05:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f09:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f0d:	ee                   	out    %al,(%dx)
  100f0e:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f14:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  100f18:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f1c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f20:	ee                   	out    %al,(%dx)
  100f21:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f27:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  100f2b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f2f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f33:	ee                   	out    %al,(%dx)
  100f34:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f3a:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f3e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f42:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f46:	ee                   	out    %al,(%dx)
  100f47:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100f4d:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  100f51:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f55:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f59:	ee                   	out    %al,(%dx)
  100f5a:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100f60:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  100f64:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f68:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f6c:	ee                   	out    %al,(%dx)
  100f6d:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f73:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  100f77:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f7b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f7f:	ee                   	out    %al,(%dx)
  100f80:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f86:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f8a:	89 c2                	mov    %eax,%edx
  100f8c:	ec                   	in     (%dx),%al
  100f8d:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f90:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100f94:	3c ff                	cmp    $0xff,%al
  100f96:	0f 95 c0             	setne  %al
  100f99:	0f b6 c0             	movzbl %al,%eax
  100f9c:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100fa1:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fa7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100fab:	89 c2                	mov    %eax,%edx
  100fad:	ec                   	in     (%dx),%al
  100fae:	88 45 f1             	mov    %al,-0xf(%ebp)
  100fb1:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  100fb7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100fbb:	89 c2                	mov    %eax,%edx
  100fbd:	ec                   	in     (%dx),%al
  100fbe:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fc1:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fc6:	85 c0                	test   %eax,%eax
  100fc8:	74 0c                	je     100fd6 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100fca:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100fd1:	e8 b9 06 00 00       	call   10168f <pic_enable>
    }
}
  100fd6:	90                   	nop
  100fd7:	c9                   	leave  
  100fd8:	c3                   	ret    

00100fd9 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fd9:	55                   	push   %ebp
  100fda:	89 e5                	mov    %esp,%ebp
  100fdc:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fdf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fe6:	eb 08                	jmp    100ff0 <lpt_putc_sub+0x17>
        delay();
  100fe8:	e8 db fd ff ff       	call   100dc8 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fed:	ff 45 fc             	incl   -0x4(%ebp)
  100ff0:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  100ff6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100ffa:	89 c2                	mov    %eax,%edx
  100ffc:	ec                   	in     (%dx),%al
  100ffd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101000:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101004:	84 c0                	test   %al,%al
  101006:	78 09                	js     101011 <lpt_putc_sub+0x38>
  101008:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10100f:	7e d7                	jle    100fe8 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101011:	8b 45 08             	mov    0x8(%ebp),%eax
  101014:	0f b6 c0             	movzbl %al,%eax
  101017:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  10101d:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101020:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101024:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101028:	ee                   	out    %al,(%dx)
  101029:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  10102f:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101033:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101037:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10103b:	ee                   	out    %al,(%dx)
  10103c:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101042:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  101046:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10104a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10104e:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10104f:	90                   	nop
  101050:	c9                   	leave  
  101051:	c3                   	ret    

00101052 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101052:	55                   	push   %ebp
  101053:	89 e5                	mov    %esp,%ebp
  101055:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101058:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10105c:	74 0d                	je     10106b <lpt_putc+0x19>
        lpt_putc_sub(c);
  10105e:	8b 45 08             	mov    0x8(%ebp),%eax
  101061:	89 04 24             	mov    %eax,(%esp)
  101064:	e8 70 ff ff ff       	call   100fd9 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  101069:	eb 24                	jmp    10108f <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  10106b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101072:	e8 62 ff ff ff       	call   100fd9 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101077:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10107e:	e8 56 ff ff ff       	call   100fd9 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101083:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10108a:	e8 4a ff ff ff       	call   100fd9 <lpt_putc_sub>
}
  10108f:	90                   	nop
  101090:	c9                   	leave  
  101091:	c3                   	ret    

00101092 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101092:	55                   	push   %ebp
  101093:	89 e5                	mov    %esp,%ebp
  101095:	53                   	push   %ebx
  101096:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101099:	8b 45 08             	mov    0x8(%ebp),%eax
  10109c:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010a1:	85 c0                	test   %eax,%eax
  1010a3:	75 07                	jne    1010ac <cga_putc+0x1a>
        c |= 0x0700;
  1010a5:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1010af:	0f b6 c0             	movzbl %al,%eax
  1010b2:	83 f8 0a             	cmp    $0xa,%eax
  1010b5:	74 55                	je     10110c <cga_putc+0x7a>
  1010b7:	83 f8 0d             	cmp    $0xd,%eax
  1010ba:	74 63                	je     10111f <cga_putc+0x8d>
  1010bc:	83 f8 08             	cmp    $0x8,%eax
  1010bf:	0f 85 94 00 00 00    	jne    101159 <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
  1010c5:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010cc:	85 c0                	test   %eax,%eax
  1010ce:	0f 84 af 00 00 00    	je     101183 <cga_putc+0xf1>
            crt_pos --;
  1010d4:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010db:	48                   	dec    %eax
  1010dc:	0f b7 c0             	movzwl %ax,%eax
  1010df:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1010e8:	98                   	cwtl   
  1010e9:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010ee:	98                   	cwtl   
  1010ef:	83 c8 20             	or     $0x20,%eax
  1010f2:	98                   	cwtl   
  1010f3:	8b 15 60 ee 10 00    	mov    0x10ee60,%edx
  1010f9:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101100:	01 c9                	add    %ecx,%ecx
  101102:	01 ca                	add    %ecx,%edx
  101104:	0f b7 c0             	movzwl %ax,%eax
  101107:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10110a:	eb 77                	jmp    101183 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  10110c:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101113:	83 c0 50             	add    $0x50,%eax
  101116:	0f b7 c0             	movzwl %ax,%eax
  101119:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10111f:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101126:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  10112d:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101132:	89 c8                	mov    %ecx,%eax
  101134:	f7 e2                	mul    %edx
  101136:	c1 ea 06             	shr    $0x6,%edx
  101139:	89 d0                	mov    %edx,%eax
  10113b:	c1 e0 02             	shl    $0x2,%eax
  10113e:	01 d0                	add    %edx,%eax
  101140:	c1 e0 04             	shl    $0x4,%eax
  101143:	29 c1                	sub    %eax,%ecx
  101145:	89 c8                	mov    %ecx,%eax
  101147:	0f b7 c0             	movzwl %ax,%eax
  10114a:	29 c3                	sub    %eax,%ebx
  10114c:	89 d8                	mov    %ebx,%eax
  10114e:	0f b7 c0             	movzwl %ax,%eax
  101151:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  101157:	eb 2b                	jmp    101184 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101159:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  10115f:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101166:	8d 50 01             	lea    0x1(%eax),%edx
  101169:	0f b7 d2             	movzwl %dx,%edx
  10116c:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101173:	01 c0                	add    %eax,%eax
  101175:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101178:	8b 45 08             	mov    0x8(%ebp),%eax
  10117b:	0f b7 c0             	movzwl %ax,%eax
  10117e:	66 89 02             	mov    %ax,(%edx)
        break;
  101181:	eb 01                	jmp    101184 <cga_putc+0xf2>
        break;
  101183:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101184:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10118b:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101190:	76 5d                	jbe    1011ef <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101192:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101197:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10119d:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011a2:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011a9:	00 
  1011aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011ae:	89 04 24             	mov    %eax,(%esp)
  1011b1:	e8 ed 1c 00 00       	call   102ea3 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011b6:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011bd:	eb 14                	jmp    1011d3 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  1011bf:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011c7:	01 d2                	add    %edx,%edx
  1011c9:	01 d0                	add    %edx,%eax
  1011cb:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011d0:	ff 45 f4             	incl   -0xc(%ebp)
  1011d3:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011da:	7e e3                	jle    1011bf <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
  1011dc:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011e3:	83 e8 50             	sub    $0x50,%eax
  1011e6:	0f b7 c0             	movzwl %ax,%eax
  1011e9:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011ef:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011f6:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1011fa:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  1011fe:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101202:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101206:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101207:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10120e:	c1 e8 08             	shr    $0x8,%eax
  101211:	0f b7 c0             	movzwl %ax,%eax
  101214:	0f b6 c0             	movzbl %al,%eax
  101217:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10121e:	42                   	inc    %edx
  10121f:	0f b7 d2             	movzwl %dx,%edx
  101222:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  101226:	88 45 e9             	mov    %al,-0x17(%ebp)
  101229:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10122d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101231:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101232:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101239:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10123d:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  101241:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101245:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101249:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10124a:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101251:	0f b6 c0             	movzbl %al,%eax
  101254:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10125b:	42                   	inc    %edx
  10125c:	0f b7 d2             	movzwl %dx,%edx
  10125f:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101263:	88 45 f1             	mov    %al,-0xf(%ebp)
  101266:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10126a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10126e:	ee                   	out    %al,(%dx)
}
  10126f:	90                   	nop
  101270:	83 c4 34             	add    $0x34,%esp
  101273:	5b                   	pop    %ebx
  101274:	5d                   	pop    %ebp
  101275:	c3                   	ret    

00101276 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101276:	55                   	push   %ebp
  101277:	89 e5                	mov    %esp,%ebp
  101279:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10127c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101283:	eb 08                	jmp    10128d <serial_putc_sub+0x17>
        delay();
  101285:	e8 3e fb ff ff       	call   100dc8 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10128a:	ff 45 fc             	incl   -0x4(%ebp)
  10128d:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101293:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101297:	89 c2                	mov    %eax,%edx
  101299:	ec                   	in     (%dx),%al
  10129a:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10129d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1012a1:	0f b6 c0             	movzbl %al,%eax
  1012a4:	83 e0 20             	and    $0x20,%eax
  1012a7:	85 c0                	test   %eax,%eax
  1012a9:	75 09                	jne    1012b4 <serial_putc_sub+0x3e>
  1012ab:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012b2:	7e d1                	jle    101285 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  1012b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1012b7:	0f b6 c0             	movzbl %al,%eax
  1012ba:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012c0:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012c3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012c7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012cb:	ee                   	out    %al,(%dx)
}
  1012cc:	90                   	nop
  1012cd:	c9                   	leave  
  1012ce:	c3                   	ret    

001012cf <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012cf:	55                   	push   %ebp
  1012d0:	89 e5                	mov    %esp,%ebp
  1012d2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012d5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012d9:	74 0d                	je     1012e8 <serial_putc+0x19>
        serial_putc_sub(c);
  1012db:	8b 45 08             	mov    0x8(%ebp),%eax
  1012de:	89 04 24             	mov    %eax,(%esp)
  1012e1:	e8 90 ff ff ff       	call   101276 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1012e6:	eb 24                	jmp    10130c <serial_putc+0x3d>
        serial_putc_sub('\b');
  1012e8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012ef:	e8 82 ff ff ff       	call   101276 <serial_putc_sub>
        serial_putc_sub(' ');
  1012f4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1012fb:	e8 76 ff ff ff       	call   101276 <serial_putc_sub>
        serial_putc_sub('\b');
  101300:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101307:	e8 6a ff ff ff       	call   101276 <serial_putc_sub>
}
  10130c:	90                   	nop
  10130d:	c9                   	leave  
  10130e:	c3                   	ret    

0010130f <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10130f:	55                   	push   %ebp
  101310:	89 e5                	mov    %esp,%ebp
  101312:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101315:	eb 33                	jmp    10134a <cons_intr+0x3b>
        if (c != 0) {
  101317:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10131b:	74 2d                	je     10134a <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10131d:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101322:	8d 50 01             	lea    0x1(%eax),%edx
  101325:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  10132b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10132e:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101334:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101339:	3d 00 02 00 00       	cmp    $0x200,%eax
  10133e:	75 0a                	jne    10134a <cons_intr+0x3b>
                cons.wpos = 0;
  101340:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101347:	00 00 00 
    while ((c = (*proc)()) != -1) {
  10134a:	8b 45 08             	mov    0x8(%ebp),%eax
  10134d:	ff d0                	call   *%eax
  10134f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101352:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101356:	75 bf                	jne    101317 <cons_intr+0x8>
            }
        }
    }
}
  101358:	90                   	nop
  101359:	c9                   	leave  
  10135a:	c3                   	ret    

0010135b <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10135b:	55                   	push   %ebp
  10135c:	89 e5                	mov    %esp,%ebp
  10135e:	83 ec 10             	sub    $0x10,%esp
  101361:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101367:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10136b:	89 c2                	mov    %eax,%edx
  10136d:	ec                   	in     (%dx),%al
  10136e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101371:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101375:	0f b6 c0             	movzbl %al,%eax
  101378:	83 e0 01             	and    $0x1,%eax
  10137b:	85 c0                	test   %eax,%eax
  10137d:	75 07                	jne    101386 <serial_proc_data+0x2b>
        return -1;
  10137f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101384:	eb 2a                	jmp    1013b0 <serial_proc_data+0x55>
  101386:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10138c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101390:	89 c2                	mov    %eax,%edx
  101392:	ec                   	in     (%dx),%al
  101393:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101396:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  10139a:	0f b6 c0             	movzbl %al,%eax
  10139d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013a0:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013a4:	75 07                	jne    1013ad <serial_proc_data+0x52>
        c = '\b';
  1013a6:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013b0:	c9                   	leave  
  1013b1:	c3                   	ret    

001013b2 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013b2:	55                   	push   %ebp
  1013b3:	89 e5                	mov    %esp,%ebp
  1013b5:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013b8:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013bd:	85 c0                	test   %eax,%eax
  1013bf:	74 0c                	je     1013cd <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013c1:	c7 04 24 5b 13 10 00 	movl   $0x10135b,(%esp)
  1013c8:	e8 42 ff ff ff       	call   10130f <cons_intr>
    }
}
  1013cd:	90                   	nop
  1013ce:	c9                   	leave  
  1013cf:	c3                   	ret    

001013d0 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013d0:	55                   	push   %ebp
  1013d1:	89 e5                	mov    %esp,%ebp
  1013d3:	83 ec 38             	sub    $0x38,%esp
  1013d6:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1013df:	89 c2                	mov    %eax,%edx
  1013e1:	ec                   	in     (%dx),%al
  1013e2:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013e5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013e9:	0f b6 c0             	movzbl %al,%eax
  1013ec:	83 e0 01             	and    $0x1,%eax
  1013ef:	85 c0                	test   %eax,%eax
  1013f1:	75 0a                	jne    1013fd <kbd_proc_data+0x2d>
        return -1;
  1013f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013f8:	e9 55 01 00 00       	jmp    101552 <kbd_proc_data+0x182>
  1013fd:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101403:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101406:	89 c2                	mov    %eax,%edx
  101408:	ec                   	in     (%dx),%al
  101409:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10140c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101410:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101413:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101417:	75 17                	jne    101430 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101419:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10141e:	83 c8 40             	or     $0x40,%eax
  101421:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101426:	b8 00 00 00 00       	mov    $0x0,%eax
  10142b:	e9 22 01 00 00       	jmp    101552 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  101430:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101434:	84 c0                	test   %al,%al
  101436:	79 45                	jns    10147d <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101438:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10143d:	83 e0 40             	and    $0x40,%eax
  101440:	85 c0                	test   %eax,%eax
  101442:	75 08                	jne    10144c <kbd_proc_data+0x7c>
  101444:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101448:	24 7f                	and    $0x7f,%al
  10144a:	eb 04                	jmp    101450 <kbd_proc_data+0x80>
  10144c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101450:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101453:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101457:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10145e:	0c 40                	or     $0x40,%al
  101460:	0f b6 c0             	movzbl %al,%eax
  101463:	f7 d0                	not    %eax
  101465:	89 c2                	mov    %eax,%edx
  101467:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10146c:	21 d0                	and    %edx,%eax
  10146e:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101473:	b8 00 00 00 00       	mov    $0x0,%eax
  101478:	e9 d5 00 00 00       	jmp    101552 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  10147d:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101482:	83 e0 40             	and    $0x40,%eax
  101485:	85 c0                	test   %eax,%eax
  101487:	74 11                	je     10149a <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101489:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10148d:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101492:	83 e0 bf             	and    $0xffffffbf,%eax
  101495:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  10149a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10149e:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  1014a5:	0f b6 d0             	movzbl %al,%edx
  1014a8:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014ad:	09 d0                	or     %edx,%eax
  1014af:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014b4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b8:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014bf:	0f b6 d0             	movzbl %al,%edx
  1014c2:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014c7:	31 d0                	xor    %edx,%eax
  1014c9:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014ce:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014d3:	83 e0 03             	and    $0x3,%eax
  1014d6:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014dd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014e1:	01 d0                	add    %edx,%eax
  1014e3:	0f b6 00             	movzbl (%eax),%eax
  1014e6:	0f b6 c0             	movzbl %al,%eax
  1014e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014ec:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014f1:	83 e0 08             	and    $0x8,%eax
  1014f4:	85 c0                	test   %eax,%eax
  1014f6:	74 22                	je     10151a <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1014f8:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014fc:	7e 0c                	jle    10150a <kbd_proc_data+0x13a>
  1014fe:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101502:	7f 06                	jg     10150a <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101504:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101508:	eb 10                	jmp    10151a <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  10150a:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10150e:	7e 0a                	jle    10151a <kbd_proc_data+0x14a>
  101510:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101514:	7f 04                	jg     10151a <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  101516:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10151a:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10151f:	f7 d0                	not    %eax
  101521:	83 e0 06             	and    $0x6,%eax
  101524:	85 c0                	test   %eax,%eax
  101526:	75 27                	jne    10154f <kbd_proc_data+0x17f>
  101528:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  10152f:	75 1e                	jne    10154f <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  101531:	c7 04 24 8d 39 10 00 	movl   $0x10398d,(%esp)
  101538:	e8 2f ed ff ff       	call   10026c <cprintf>
  10153d:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101543:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101547:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10154b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10154e:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10154f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101552:	c9                   	leave  
  101553:	c3                   	ret    

00101554 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101554:	55                   	push   %ebp
  101555:	89 e5                	mov    %esp,%ebp
  101557:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  10155a:	c7 04 24 d0 13 10 00 	movl   $0x1013d0,(%esp)
  101561:	e8 a9 fd ff ff       	call   10130f <cons_intr>
}
  101566:	90                   	nop
  101567:	c9                   	leave  
  101568:	c3                   	ret    

00101569 <kbd_init>:

static void
kbd_init(void) {
  101569:	55                   	push   %ebp
  10156a:	89 e5                	mov    %esp,%ebp
  10156c:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10156f:	e8 e0 ff ff ff       	call   101554 <kbd_intr>
    pic_enable(IRQ_KBD);
  101574:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10157b:	e8 0f 01 00 00       	call   10168f <pic_enable>
}
  101580:	90                   	nop
  101581:	c9                   	leave  
  101582:	c3                   	ret    

00101583 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101583:	55                   	push   %ebp
  101584:	89 e5                	mov    %esp,%ebp
  101586:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101589:	e8 83 f8 ff ff       	call   100e11 <cga_init>
    serial_init();
  10158e:	e8 62 f9 ff ff       	call   100ef5 <serial_init>
    kbd_init();
  101593:	e8 d1 ff ff ff       	call   101569 <kbd_init>
    if (!serial_exists) {
  101598:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  10159d:	85 c0                	test   %eax,%eax
  10159f:	75 0c                	jne    1015ad <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015a1:	c7 04 24 99 39 10 00 	movl   $0x103999,(%esp)
  1015a8:	e8 bf ec ff ff       	call   10026c <cprintf>
    }
}
  1015ad:	90                   	nop
  1015ae:	c9                   	leave  
  1015af:	c3                   	ret    

001015b0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015b0:	55                   	push   %ebp
  1015b1:	89 e5                	mov    %esp,%ebp
  1015b3:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1015b9:	89 04 24             	mov    %eax,(%esp)
  1015bc:	e8 91 fa ff ff       	call   101052 <lpt_putc>
    cga_putc(c);
  1015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1015c4:	89 04 24             	mov    %eax,(%esp)
  1015c7:	e8 c6 fa ff ff       	call   101092 <cga_putc>
    serial_putc(c);
  1015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1015cf:	89 04 24             	mov    %eax,(%esp)
  1015d2:	e8 f8 fc ff ff       	call   1012cf <serial_putc>
}
  1015d7:	90                   	nop
  1015d8:	c9                   	leave  
  1015d9:	c3                   	ret    

001015da <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015da:	55                   	push   %ebp
  1015db:	89 e5                	mov    %esp,%ebp
  1015dd:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015e0:	e8 cd fd ff ff       	call   1013b2 <serial_intr>
    kbd_intr();
  1015e5:	e8 6a ff ff ff       	call   101554 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015ea:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015f0:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015f5:	39 c2                	cmp    %eax,%edx
  1015f7:	74 36                	je     10162f <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015f9:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015fe:	8d 50 01             	lea    0x1(%eax),%edx
  101601:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  101607:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  10160e:	0f b6 c0             	movzbl %al,%eax
  101611:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101614:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101619:	3d 00 02 00 00       	cmp    $0x200,%eax
  10161e:	75 0a                	jne    10162a <cons_getc+0x50>
            cons.rpos = 0;
  101620:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  101627:	00 00 00 
        }
        return c;
  10162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10162d:	eb 05                	jmp    101634 <cons_getc+0x5a>
    }
    return 0;
  10162f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101634:	c9                   	leave  
  101635:	c3                   	ret    

00101636 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101636:	55                   	push   %ebp
  101637:	89 e5                	mov    %esp,%ebp
  101639:	83 ec 14             	sub    $0x14,%esp
  10163c:	8b 45 08             	mov    0x8(%ebp),%eax
  10163f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101643:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101646:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  10164c:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101651:	85 c0                	test   %eax,%eax
  101653:	74 37                	je     10168c <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101655:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101658:	0f b6 c0             	movzbl %al,%eax
  10165b:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  101661:	88 45 f9             	mov    %al,-0x7(%ebp)
  101664:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101668:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10166c:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10166d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101671:	c1 e8 08             	shr    $0x8,%eax
  101674:	0f b7 c0             	movzwl %ax,%eax
  101677:	0f b6 c0             	movzbl %al,%eax
  10167a:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  101680:	88 45 fd             	mov    %al,-0x3(%ebp)
  101683:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101687:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10168b:	ee                   	out    %al,(%dx)
    }
}
  10168c:	90                   	nop
  10168d:	c9                   	leave  
  10168e:	c3                   	ret    

0010168f <pic_enable>:

void
pic_enable(unsigned int irq) {
  10168f:	55                   	push   %ebp
  101690:	89 e5                	mov    %esp,%ebp
  101692:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101695:	8b 45 08             	mov    0x8(%ebp),%eax
  101698:	ba 01 00 00 00       	mov    $0x1,%edx
  10169d:	88 c1                	mov    %al,%cl
  10169f:	d3 e2                	shl    %cl,%edx
  1016a1:	89 d0                	mov    %edx,%eax
  1016a3:	98                   	cwtl   
  1016a4:	f7 d0                	not    %eax
  1016a6:	0f bf d0             	movswl %ax,%edx
  1016a9:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016b0:	98                   	cwtl   
  1016b1:	21 d0                	and    %edx,%eax
  1016b3:	98                   	cwtl   
  1016b4:	0f b7 c0             	movzwl %ax,%eax
  1016b7:	89 04 24             	mov    %eax,(%esp)
  1016ba:	e8 77 ff ff ff       	call   101636 <pic_setmask>
}
  1016bf:	90                   	nop
  1016c0:	c9                   	leave  
  1016c1:	c3                   	ret    

001016c2 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016c2:	55                   	push   %ebp
  1016c3:	89 e5                	mov    %esp,%ebp
  1016c5:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1016c8:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016cf:	00 00 00 
  1016d2:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1016d8:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  1016dc:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1016e0:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1016e4:	ee                   	out    %al,(%dx)
  1016e5:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1016eb:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  1016ef:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1016f3:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1016f7:	ee                   	out    %al,(%dx)
  1016f8:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1016fe:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  101702:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101706:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10170a:	ee                   	out    %al,(%dx)
  10170b:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101711:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  101715:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101719:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10171d:	ee                   	out    %al,(%dx)
  10171e:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101724:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  101728:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10172c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101730:	ee                   	out    %al,(%dx)
  101731:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  101737:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  10173b:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10173f:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101743:	ee                   	out    %al,(%dx)
  101744:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  10174a:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  10174e:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101752:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101756:	ee                   	out    %al,(%dx)
  101757:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  10175d:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  101761:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101765:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101769:	ee                   	out    %al,(%dx)
  10176a:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101770:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  101774:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101778:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10177c:	ee                   	out    %al,(%dx)
  10177d:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101783:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  101787:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10178b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10178f:	ee                   	out    %al,(%dx)
  101790:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101796:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  10179a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10179e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017a2:	ee                   	out    %al,(%dx)
  1017a3:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1017a9:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  1017ad:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1017b1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017b5:	ee                   	out    %al,(%dx)
  1017b6:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1017bc:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  1017c0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1017c4:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017c8:	ee                   	out    %al,(%dx)
  1017c9:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1017cf:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  1017d3:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1017d7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1017db:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017dc:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017e3:	3d ff ff 00 00       	cmp    $0xffff,%eax
  1017e8:	74 0f                	je     1017f9 <pic_init+0x137>
        pic_setmask(irq_mask);
  1017ea:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017f1:	89 04 24             	mov    %eax,(%esp)
  1017f4:	e8 3d fe ff ff       	call   101636 <pic_setmask>
    }
}
  1017f9:	90                   	nop
  1017fa:	c9                   	leave  
  1017fb:	c3                   	ret    

001017fc <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1017fc:	55                   	push   %ebp
  1017fd:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1017ff:	fb                   	sti    
    sti();
}
  101800:	90                   	nop
  101801:	5d                   	pop    %ebp
  101802:	c3                   	ret    

00101803 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101803:	55                   	push   %ebp
  101804:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  101806:	fa                   	cli    
    cli();
}
  101807:	90                   	nop
  101808:	5d                   	pop    %ebp
  101809:	c3                   	ret    

0010180a <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10180a:	55                   	push   %ebp
  10180b:	89 e5                	mov    %esp,%ebp
  10180d:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101810:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101817:	00 
  101818:	c7 04 24 c0 39 10 00 	movl   $0x1039c0,(%esp)
  10181f:	e8 48 ea ff ff       	call   10026c <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101824:	90                   	nop
  101825:	c9                   	leave  
  101826:	c3                   	ret    

00101827 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101827:	55                   	push   %ebp
  101828:	89 e5                	mov    %esp,%ebp
  10182a:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) { 
  10182d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101834:	e9 c4 00 00 00       	jmp    1018fd <idt_init+0xd6>
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
  101839:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10183c:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101843:	0f b7 d0             	movzwl %ax,%edx
  101846:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101849:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  101850:	00 
  101851:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101854:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  10185b:	00 08 00 
  10185e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101861:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101868:	00 
  101869:	80 e2 e0             	and    $0xe0,%dl
  10186c:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101873:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101876:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10187d:	00 
  10187e:	80 e2 1f             	and    $0x1f,%dl
  101881:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101888:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10188b:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101892:	00 
  101893:	80 e2 f0             	and    $0xf0,%dl
  101896:	80 ca 0e             	or     $0xe,%dl
  101899:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018a3:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018aa:	00 
  1018ab:	80 e2 ef             	and    $0xef,%dl
  1018ae:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b8:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018bf:	00 
  1018c0:	80 e2 9f             	and    $0x9f,%dl
  1018c3:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018cd:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018d4:	00 
  1018d5:	80 ca 80             	or     $0x80,%dl
  1018d8:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e2:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018e9:	c1 e8 10             	shr    $0x10,%eax
  1018ec:	0f b7 d0             	movzwl %ax,%edx
  1018ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f2:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  1018f9:	00 
    for (int i = 0; i < 256; i++) { 
  1018fa:	ff 45 fc             	incl   -0x4(%ebp)
  1018fd:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  101904:	0f 8e 2f ff ff ff    	jle    101839 <idt_init+0x12>
    }
    //referenced: #define SETGATE(gate, istrap, sel, off, dpl)
    //so the 'istrap' below is set as 1;
    //referenced:  KERNEL_CS    ((GD_KTEXT) | DPL_KERNEL)
    SETGATE(idt[T_SWITCH_TOK], 1, KERNEL_CS, __vectors[T_SWITCH_TOK], DPL_USER);
  10190a:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  10190f:	0f b7 c0             	movzwl %ax,%eax
  101912:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  101918:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  10191f:	08 00 
  101921:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101928:	24 e0                	and    $0xe0,%al
  10192a:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10192f:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101936:	24 1f                	and    $0x1f,%al
  101938:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10193d:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101944:	0c 0f                	or     $0xf,%al
  101946:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10194b:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101952:	24 ef                	and    $0xef,%al
  101954:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101959:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101960:	0c 60                	or     $0x60,%al
  101962:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101967:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10196e:	0c 80                	or     $0x80,%al
  101970:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101975:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  10197a:	c1 e8 10             	shr    $0x10,%eax
  10197d:	0f b7 c0             	movzwl %ax,%eax
  101980:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
    SETGATE(idt[T_SWITCH_TOU], 1, KERNEL_CS, __vectors[T_SWITCH_TOU], DPL_KERNEL);
  101986:	a1 c0 e7 10 00       	mov    0x10e7c0,%eax
  10198b:	0f b7 c0             	movzwl %ax,%eax
  10198e:	66 a3 60 f4 10 00    	mov    %ax,0x10f460
  101994:	66 c7 05 62 f4 10 00 	movw   $0x8,0x10f462
  10199b:	08 00 
  10199d:	0f b6 05 64 f4 10 00 	movzbl 0x10f464,%eax
  1019a4:	24 e0                	and    $0xe0,%al
  1019a6:	a2 64 f4 10 00       	mov    %al,0x10f464
  1019ab:	0f b6 05 64 f4 10 00 	movzbl 0x10f464,%eax
  1019b2:	24 1f                	and    $0x1f,%al
  1019b4:	a2 64 f4 10 00       	mov    %al,0x10f464
  1019b9:	0f b6 05 65 f4 10 00 	movzbl 0x10f465,%eax
  1019c0:	0c 0f                	or     $0xf,%al
  1019c2:	a2 65 f4 10 00       	mov    %al,0x10f465
  1019c7:	0f b6 05 65 f4 10 00 	movzbl 0x10f465,%eax
  1019ce:	24 ef                	and    $0xef,%al
  1019d0:	a2 65 f4 10 00       	mov    %al,0x10f465
  1019d5:	0f b6 05 65 f4 10 00 	movzbl 0x10f465,%eax
  1019dc:	24 9f                	and    $0x9f,%al
  1019de:	a2 65 f4 10 00       	mov    %al,0x10f465
  1019e3:	0f b6 05 65 f4 10 00 	movzbl 0x10f465,%eax
  1019ea:	0c 80                	or     $0x80,%al
  1019ec:	a2 65 f4 10 00       	mov    %al,0x10f465
  1019f1:	a1 c0 e7 10 00       	mov    0x10e7c0,%eax
  1019f6:	c1 e8 10             	shr    $0x10,%eax
  1019f9:	0f b7 c0             	movzwl %ax,%eax
  1019fc:	66 a3 66 f4 10 00    	mov    %ax,0x10f466
  101a02:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a0c:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  101a0f:	90                   	nop
  101a10:	c9                   	leave  
  101a11:	c3                   	ret    

00101a12 <trapname>:

static const char *
trapname(int trapno) {
  101a12:	55                   	push   %ebp
  101a13:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a15:	8b 45 08             	mov    0x8(%ebp),%eax
  101a18:	83 f8 13             	cmp    $0x13,%eax
  101a1b:	77 0c                	ja     101a29 <trapname+0x17>
        return excnames[trapno];
  101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a20:	8b 04 85 60 3d 10 00 	mov    0x103d60(,%eax,4),%eax
  101a27:	eb 18                	jmp    101a41 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a29:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a2d:	7e 0d                	jle    101a3c <trapname+0x2a>
  101a2f:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a33:	7f 07                	jg     101a3c <trapname+0x2a>
        return "Hardware Interrupt";
  101a35:	b8 ca 39 10 00       	mov    $0x1039ca,%eax
  101a3a:	eb 05                	jmp    101a41 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a3c:	b8 dd 39 10 00       	mov    $0x1039dd,%eax
}
  101a41:	5d                   	pop    %ebp
  101a42:	c3                   	ret    

00101a43 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a43:	55                   	push   %ebp
  101a44:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a46:	8b 45 08             	mov    0x8(%ebp),%eax
  101a49:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a4d:	83 f8 08             	cmp    $0x8,%eax
  101a50:	0f 94 c0             	sete   %al
  101a53:	0f b6 c0             	movzbl %al,%eax
}
  101a56:	5d                   	pop    %ebp
  101a57:	c3                   	ret    

00101a58 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a58:	55                   	push   %ebp
  101a59:	89 e5                	mov    %esp,%ebp
  101a5b:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a65:	c7 04 24 1e 3a 10 00 	movl   $0x103a1e,(%esp)
  101a6c:	e8 fb e7 ff ff       	call   10026c <cprintf>
    print_regs(&tf->tf_regs);
  101a71:	8b 45 08             	mov    0x8(%ebp),%eax
  101a74:	89 04 24             	mov    %eax,(%esp)
  101a77:	e8 8f 01 00 00       	call   101c0b <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7f:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a83:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a87:	c7 04 24 2f 3a 10 00 	movl   $0x103a2f,(%esp)
  101a8e:	e8 d9 e7 ff ff       	call   10026c <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a93:	8b 45 08             	mov    0x8(%ebp),%eax
  101a96:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9e:	c7 04 24 42 3a 10 00 	movl   $0x103a42,(%esp)
  101aa5:	e8 c2 e7 ff ff       	call   10026c <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  101aad:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab5:	c7 04 24 55 3a 10 00 	movl   $0x103a55,(%esp)
  101abc:	e8 ab e7 ff ff       	call   10026c <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac4:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acc:	c7 04 24 68 3a 10 00 	movl   $0x103a68,(%esp)
  101ad3:	e8 94 e7 ff ff       	call   10026c <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  101adb:	8b 40 30             	mov    0x30(%eax),%eax
  101ade:	89 04 24             	mov    %eax,(%esp)
  101ae1:	e8 2c ff ff ff       	call   101a12 <trapname>
  101ae6:	89 c2                	mov    %eax,%edx
  101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  101aeb:	8b 40 30             	mov    0x30(%eax),%eax
  101aee:	89 54 24 08          	mov    %edx,0x8(%esp)
  101af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af6:	c7 04 24 7b 3a 10 00 	movl   $0x103a7b,(%esp)
  101afd:	e8 6a e7 ff ff       	call   10026c <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b02:	8b 45 08             	mov    0x8(%ebp),%eax
  101b05:	8b 40 34             	mov    0x34(%eax),%eax
  101b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0c:	c7 04 24 8d 3a 10 00 	movl   $0x103a8d,(%esp)
  101b13:	e8 54 e7 ff ff       	call   10026c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b18:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1b:	8b 40 38             	mov    0x38(%eax),%eax
  101b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b22:	c7 04 24 9c 3a 10 00 	movl   $0x103a9c,(%esp)
  101b29:	e8 3e e7 ff ff       	call   10026c <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b31:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b39:	c7 04 24 ab 3a 10 00 	movl   $0x103aab,(%esp)
  101b40:	e8 27 e7 ff ff       	call   10026c <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b45:	8b 45 08             	mov    0x8(%ebp),%eax
  101b48:	8b 40 40             	mov    0x40(%eax),%eax
  101b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4f:	c7 04 24 be 3a 10 00 	movl   $0x103abe,(%esp)
  101b56:	e8 11 e7 ff ff       	call   10026c <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b62:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b69:	eb 3d                	jmp    101ba8 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6e:	8b 50 40             	mov    0x40(%eax),%edx
  101b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b74:	21 d0                	and    %edx,%eax
  101b76:	85 c0                	test   %eax,%eax
  101b78:	74 28                	je     101ba2 <print_trapframe+0x14a>
  101b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b7d:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b84:	85 c0                	test   %eax,%eax
  101b86:	74 1a                	je     101ba2 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b8b:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b92:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b96:	c7 04 24 cd 3a 10 00 	movl   $0x103acd,(%esp)
  101b9d:	e8 ca e6 ff ff       	call   10026c <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ba2:	ff 45 f4             	incl   -0xc(%ebp)
  101ba5:	d1 65 f0             	shll   -0x10(%ebp)
  101ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bab:	83 f8 17             	cmp    $0x17,%eax
  101bae:	76 bb                	jbe    101b6b <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb3:	8b 40 40             	mov    0x40(%eax),%eax
  101bb6:	c1 e8 0c             	shr    $0xc,%eax
  101bb9:	83 e0 03             	and    $0x3,%eax
  101bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc0:	c7 04 24 d1 3a 10 00 	movl   $0x103ad1,(%esp)
  101bc7:	e8 a0 e6 ff ff       	call   10026c <cprintf>

    if (!trap_in_kernel(tf)) {
  101bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcf:	89 04 24             	mov    %eax,(%esp)
  101bd2:	e8 6c fe ff ff       	call   101a43 <trap_in_kernel>
  101bd7:	85 c0                	test   %eax,%eax
  101bd9:	75 2d                	jne    101c08 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  101bde:	8b 40 44             	mov    0x44(%eax),%eax
  101be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be5:	c7 04 24 da 3a 10 00 	movl   $0x103ada,(%esp)
  101bec:	e8 7b e6 ff ff       	call   10026c <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf4:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfc:	c7 04 24 e9 3a 10 00 	movl   $0x103ae9,(%esp)
  101c03:	e8 64 e6 ff ff       	call   10026c <cprintf>
    }
}
  101c08:	90                   	nop
  101c09:	c9                   	leave  
  101c0a:	c3                   	ret    

00101c0b <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c0b:	55                   	push   %ebp
  101c0c:	89 e5                	mov    %esp,%ebp
  101c0e:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c11:	8b 45 08             	mov    0x8(%ebp),%eax
  101c14:	8b 00                	mov    (%eax),%eax
  101c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1a:	c7 04 24 fc 3a 10 00 	movl   $0x103afc,(%esp)
  101c21:	e8 46 e6 ff ff       	call   10026c <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c26:	8b 45 08             	mov    0x8(%ebp),%eax
  101c29:	8b 40 04             	mov    0x4(%eax),%eax
  101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c30:	c7 04 24 0b 3b 10 00 	movl   $0x103b0b,(%esp)
  101c37:	e8 30 e6 ff ff       	call   10026c <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3f:	8b 40 08             	mov    0x8(%eax),%eax
  101c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c46:	c7 04 24 1a 3b 10 00 	movl   $0x103b1a,(%esp)
  101c4d:	e8 1a e6 ff ff       	call   10026c <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c52:	8b 45 08             	mov    0x8(%ebp),%eax
  101c55:	8b 40 0c             	mov    0xc(%eax),%eax
  101c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5c:	c7 04 24 29 3b 10 00 	movl   $0x103b29,(%esp)
  101c63:	e8 04 e6 ff ff       	call   10026c <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c68:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6b:	8b 40 10             	mov    0x10(%eax),%eax
  101c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c72:	c7 04 24 38 3b 10 00 	movl   $0x103b38,(%esp)
  101c79:	e8 ee e5 ff ff       	call   10026c <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c81:	8b 40 14             	mov    0x14(%eax),%eax
  101c84:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c88:	c7 04 24 47 3b 10 00 	movl   $0x103b47,(%esp)
  101c8f:	e8 d8 e5 ff ff       	call   10026c <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c94:	8b 45 08             	mov    0x8(%ebp),%eax
  101c97:	8b 40 18             	mov    0x18(%eax),%eax
  101c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9e:	c7 04 24 56 3b 10 00 	movl   $0x103b56,(%esp)
  101ca5:	e8 c2 e5 ff ff       	call   10026c <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101caa:	8b 45 08             	mov    0x8(%ebp),%eax
  101cad:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb4:	c7 04 24 65 3b 10 00 	movl   $0x103b65,(%esp)
  101cbb:	e8 ac e5 ff ff       	call   10026c <cprintf>
}
  101cc0:	90                   	nop
  101cc1:	c9                   	leave  
  101cc2:	c3                   	ret    

00101cc3 <trap_dispatch>:
}
*/

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cc3:	55                   	push   %ebp
  101cc4:	89 e5                	mov    %esp,%ebp
  101cc6:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  101ccc:	8b 40 30             	mov    0x30(%eax),%eax
  101ccf:	83 f8 2f             	cmp    $0x2f,%eax
  101cd2:	77 21                	ja     101cf5 <trap_dispatch+0x32>
  101cd4:	83 f8 2e             	cmp    $0x2e,%eax
  101cd7:	0f 83 77 02 00 00    	jae    101f54 <trap_dispatch+0x291>
  101cdd:	83 f8 21             	cmp    $0x21,%eax
  101ce0:	0f 84 95 00 00 00    	je     101d7b <trap_dispatch+0xb8>
  101ce6:	83 f8 24             	cmp    $0x24,%eax
  101ce9:	74 67                	je     101d52 <trap_dispatch+0x8f>
  101ceb:	83 f8 20             	cmp    $0x20,%eax
  101cee:	74 1c                	je     101d0c <trap_dispatch+0x49>
  101cf0:	e9 2a 02 00 00       	jmp    101f1f <trap_dispatch+0x25c>
  101cf5:	83 f8 78             	cmp    $0x78,%eax
  101cf8:	0f 84 8d 01 00 00    	je     101e8b <trap_dispatch+0x1c8>
  101cfe:	83 f8 79             	cmp    $0x79,%eax
  101d01:	0f 84 d7 01 00 00    	je     101ede <trap_dispatch+0x21b>
  101d07:	e9 13 02 00 00       	jmp    101f1f <trap_dispatch+0x25c>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks += 1;
  101d0c:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101d11:	40                   	inc    %eax
  101d12:	a3 08 f9 10 00       	mov    %eax,0x10f908
        if (!(ticks % TICK_NUM)) {
  101d17:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101d1d:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d22:	89 c8                	mov    %ecx,%eax
  101d24:	f7 e2                	mul    %edx
  101d26:	c1 ea 05             	shr    $0x5,%edx
  101d29:	89 d0                	mov    %edx,%eax
  101d2b:	c1 e0 02             	shl    $0x2,%eax
  101d2e:	01 d0                	add    %edx,%eax
  101d30:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d37:	01 d0                	add    %edx,%eax
  101d39:	c1 e0 02             	shl    $0x2,%eax
  101d3c:	29 c1                	sub    %eax,%ecx
  101d3e:	89 ca                	mov    %ecx,%edx
  101d40:	85 d2                	test   %edx,%edx
  101d42:	0f 85 0f 02 00 00    	jne    101f57 <trap_dispatch+0x294>
            print_ticks();
  101d48:	e8 bd fa ff ff       	call   10180a <print_ticks>
        }
        break;
  101d4d:	e9 05 02 00 00       	jmp    101f57 <trap_dispatch+0x294>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d52:	e8 83 f8 ff ff       	call   1015da <cons_getc>
  101d57:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d5a:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d5e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d62:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d6a:	c7 04 24 74 3b 10 00 	movl   $0x103b74,(%esp)
  101d71:	e8 f6 e4 ff ff       	call   10026c <cprintf>
        break;
  101d76:	e9 e3 01 00 00       	jmp    101f5e <trap_dispatch+0x29b>
    // LAB1 : Challenge 2
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d7b:	e8 5a f8 ff ff       	call   1015da <cons_getc>
  101d80:	88 45 f7             	mov    %al,-0x9(%ebp)
        if (c == '3' && (tf->tf_cs & 3) != 3) {
  101d83:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
  101d87:	75 6f                	jne    101df8 <trap_dispatch+0x135>
  101d89:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d90:	83 e0 03             	and    $0x3,%eax
  101d93:	83 f8 03             	cmp    $0x3,%eax
  101d96:	74 60                	je     101df8 <trap_dispatch+0x135>
            cprintf("[system] change to user [%03d] %c\n", c, c);
  101d98:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d9c:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101da0:	89 54 24 08          	mov    %edx,0x8(%esp)
  101da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da8:	c7 04 24 88 3b 10 00 	movl   $0x103b88,(%esp)
  101daf:	e8 b8 e4 ff ff       	call   10026c <cprintf>
            tf->tf_cs = USER_CS;
  101db4:	8b 45 08             	mov    0x8(%ebp),%eax
  101db7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = USER_DS;
  101dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc0:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
  101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc9:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
  101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd2:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
            tf->tf_eflags |= 0x3000;
  101dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  101ddb:	8b 40 40             	mov    0x40(%eax),%eax
  101dde:	0d 00 30 00 00       	or     $0x3000,%eax
  101de3:	89 c2                	mov    %eax,%edx
  101de5:	8b 45 08             	mov    0x8(%ebp),%eax
  101de8:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
  101deb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dee:	89 04 24             	mov    %eax,(%esp)
  101df1:	e8 62 fc ff ff       	call   101a58 <print_trapframe>
  101df6:	eb 72                	jmp    101e6a <trap_dispatch+0x1a7>
        }
        else if (c == '0' && (tf->tf_cs & 3) != 0) {
  101df8:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
  101dfc:	75 6c                	jne    101e6a <trap_dispatch+0x1a7>
  101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  101e01:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e05:	83 e0 03             	and    $0x3,%eax
  101e08:	85 c0                	test   %eax,%eax
  101e0a:	74 5e                	je     101e6a <trap_dispatch+0x1a7>
            cprintf("[system] change to kernel [%03d] %c\n", c, c);
  101e0c:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e10:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e14:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e18:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e1c:	c7 04 24 ac 3b 10 00 	movl   $0x103bac,(%esp)
  101e23:	e8 44 e4 ff ff       	call   10026c <cprintf>
            tf->tf_cs = KERNEL_CS;
  101e28:	8b 45 08             	mov    0x8(%ebp),%eax
  101e2b:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = KERNEL_DS;
  101e31:	8b 45 08             	mov    0x8(%ebp),%eax
  101e34:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
  101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e3d:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
            tf->tf_ss = KERNEL_DS;
  101e43:	8b 45 08             	mov    0x8(%ebp),%eax
  101e46:	66 c7 40 48 10 00    	movw   $0x10,0x48(%eax)
            tf->tf_eflags &= 0x0fff;
  101e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4f:	8b 40 40             	mov    0x40(%eax),%eax
  101e52:	25 ff 0f 00 00       	and    $0xfff,%eax
  101e57:	89 c2                	mov    %eax,%edx
  101e59:	8b 45 08             	mov    0x8(%ebp),%eax
  101e5c:	89 50 40             	mov    %edx,0x40(%eax)
            print_trapframe(tf);
  101e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  101e62:	89 04 24             	mov    %eax,(%esp)
  101e65:	e8 ee fb ff ff       	call   101a58 <print_trapframe>
        }
        cprintf("kbd [%03d] %c\n", c, c);
  101e6a:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e6e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e72:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e76:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e7a:	c7 04 24 d1 3b 10 00 	movl   $0x103bd1,(%esp)
  101e81:	e8 e6 e3 ff ff       	call   10026c <cprintf>
        break;
  101e86:	e9 d3 00 00 00       	jmp    101f5e <trap_dispatch+0x29b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) 
  101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e92:	83 f8 1b             	cmp    $0x1b,%eax
  101e95:	0f 84 bf 00 00 00    	je     101f5a <trap_dispatch+0x297>
        {
            tf->tf_cs = USER_CS;
  101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9e:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
  101ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea7:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
  101ead:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb0:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb7:	66 89 50 28          	mov    %dx,0x28(%eax)
  101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ebe:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec5:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags |= FL_IOPL_MASK;
  101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  101ecc:	8b 40 40             	mov    0x40(%eax),%eax
  101ecf:	0d 00 30 00 00       	or     $0x3000,%eax
  101ed4:	89 c2                	mov    %eax,%edx
  101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ed9:	89 50 40             	mov    %edx,0x40(%eax)
            // then iret will jump to the right stack

            //tf->tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
            //*((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
        }
        break;
  101edc:	eb 7c                	jmp    101f5a <trap_dispatch+0x297>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) 
  101ede:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ee5:	83 f8 08             	cmp    $0x8,%eax
  101ee8:	74 73                	je     101f5d <trap_dispatch+0x29a>
        {
            tf->tf_cs = KERNEL_CS;
  101eea:	8b 45 08             	mov    0x8(%ebp),%eax
  101eed:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef6:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101efc:	8b 45 08             	mov    0x8(%ebp),%eax
  101eff:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101f03:	8b 45 08             	mov    0x8(%ebp),%eax
  101f06:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101f0d:	8b 40 40             	mov    0x40(%eax),%eax
  101f10:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101f15:	89 c2                	mov    %eax,%edx
  101f17:	8b 45 08             	mov    0x8(%ebp),%eax
  101f1a:	89 50 40             	mov    %edx,0x40(%eax)
            //switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
            //memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
            //*((uint32_t *)tf - 1) = (uint32_t)switchu2k;
        }
        break;
  101f1d:	eb 3e                	jmp    101f5d <trap_dispatch+0x29a>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  101f22:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f26:	83 e0 03             	and    $0x3,%eax
  101f29:	85 c0                	test   %eax,%eax
  101f2b:	75 31                	jne    101f5e <trap_dispatch+0x29b>
            print_trapframe(tf);
  101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  101f30:	89 04 24             	mov    %eax,(%esp)
  101f33:	e8 20 fb ff ff       	call   101a58 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101f38:	c7 44 24 08 e0 3b 10 	movl   $0x103be0,0x8(%esp)
  101f3f:	00 
  101f40:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  101f47:	00 
  101f48:	c7 04 24 fc 3b 10 00 	movl   $0x103bfc,(%esp)
  101f4f:	e8 6f e4 ff ff       	call   1003c3 <__panic>
        break;
  101f54:	90                   	nop
  101f55:	eb 07                	jmp    101f5e <trap_dispatch+0x29b>
        break;
  101f57:	90                   	nop
  101f58:	eb 04                	jmp    101f5e <trap_dispatch+0x29b>
        break;
  101f5a:	90                   	nop
  101f5b:	eb 01                	jmp    101f5e <trap_dispatch+0x29b>
        break;
  101f5d:	90                   	nop
        }
    }
}
  101f5e:	90                   	nop
  101f5f:	c9                   	leave  
  101f60:	c3                   	ret    

00101f61 <trap>:
/* *
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
  101f61:	55                   	push   %ebp
  101f62:	89 e5                	mov    %esp,%ebp
  101f64:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101f67:	8b 45 08             	mov    0x8(%ebp),%eax
  101f6a:	89 04 24             	mov    %eax,(%esp)
  101f6d:	e8 51 fd ff ff       	call   101cc3 <trap_dispatch>
}
  101f72:	90                   	nop
  101f73:	c9                   	leave  
  101f74:	c3                   	ret    

00101f75 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f75:	6a 00                	push   $0x0
  pushl $0
  101f77:	6a 00                	push   $0x0
  jmp __alltraps
  101f79:	e9 69 0a 00 00       	jmp    1029e7 <__alltraps>

00101f7e <vector1>:
.globl vector1
vector1:
  pushl $0
  101f7e:	6a 00                	push   $0x0
  pushl $1
  101f80:	6a 01                	push   $0x1
  jmp __alltraps
  101f82:	e9 60 0a 00 00       	jmp    1029e7 <__alltraps>

00101f87 <vector2>:
.globl vector2
vector2:
  pushl $0
  101f87:	6a 00                	push   $0x0
  pushl $2
  101f89:	6a 02                	push   $0x2
  jmp __alltraps
  101f8b:	e9 57 0a 00 00       	jmp    1029e7 <__alltraps>

00101f90 <vector3>:
.globl vector3
vector3:
  pushl $0
  101f90:	6a 00                	push   $0x0
  pushl $3
  101f92:	6a 03                	push   $0x3
  jmp __alltraps
  101f94:	e9 4e 0a 00 00       	jmp    1029e7 <__alltraps>

00101f99 <vector4>:
.globl vector4
vector4:
  pushl $0
  101f99:	6a 00                	push   $0x0
  pushl $4
  101f9b:	6a 04                	push   $0x4
  jmp __alltraps
  101f9d:	e9 45 0a 00 00       	jmp    1029e7 <__alltraps>

00101fa2 <vector5>:
.globl vector5
vector5:
  pushl $0
  101fa2:	6a 00                	push   $0x0
  pushl $5
  101fa4:	6a 05                	push   $0x5
  jmp __alltraps
  101fa6:	e9 3c 0a 00 00       	jmp    1029e7 <__alltraps>

00101fab <vector6>:
.globl vector6
vector6:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $6
  101fad:	6a 06                	push   $0x6
  jmp __alltraps
  101faf:	e9 33 0a 00 00       	jmp    1029e7 <__alltraps>

00101fb4 <vector7>:
.globl vector7
vector7:
  pushl $0
  101fb4:	6a 00                	push   $0x0
  pushl $7
  101fb6:	6a 07                	push   $0x7
  jmp __alltraps
  101fb8:	e9 2a 0a 00 00       	jmp    1029e7 <__alltraps>

00101fbd <vector8>:
.globl vector8
vector8:
  pushl $8
  101fbd:	6a 08                	push   $0x8
  jmp __alltraps
  101fbf:	e9 23 0a 00 00       	jmp    1029e7 <__alltraps>

00101fc4 <vector9>:
.globl vector9
vector9:
  pushl $0
  101fc4:	6a 00                	push   $0x0
  pushl $9
  101fc6:	6a 09                	push   $0x9
  jmp __alltraps
  101fc8:	e9 1a 0a 00 00       	jmp    1029e7 <__alltraps>

00101fcd <vector10>:
.globl vector10
vector10:
  pushl $10
  101fcd:	6a 0a                	push   $0xa
  jmp __alltraps
  101fcf:	e9 13 0a 00 00       	jmp    1029e7 <__alltraps>

00101fd4 <vector11>:
.globl vector11
vector11:
  pushl $11
  101fd4:	6a 0b                	push   $0xb
  jmp __alltraps
  101fd6:	e9 0c 0a 00 00       	jmp    1029e7 <__alltraps>

00101fdb <vector12>:
.globl vector12
vector12:
  pushl $12
  101fdb:	6a 0c                	push   $0xc
  jmp __alltraps
  101fdd:	e9 05 0a 00 00       	jmp    1029e7 <__alltraps>

00101fe2 <vector13>:
.globl vector13
vector13:
  pushl $13
  101fe2:	6a 0d                	push   $0xd
  jmp __alltraps
  101fe4:	e9 fe 09 00 00       	jmp    1029e7 <__alltraps>

00101fe9 <vector14>:
.globl vector14
vector14:
  pushl $14
  101fe9:	6a 0e                	push   $0xe
  jmp __alltraps
  101feb:	e9 f7 09 00 00       	jmp    1029e7 <__alltraps>

00101ff0 <vector15>:
.globl vector15
vector15:
  pushl $0
  101ff0:	6a 00                	push   $0x0
  pushl $15
  101ff2:	6a 0f                	push   $0xf
  jmp __alltraps
  101ff4:	e9 ee 09 00 00       	jmp    1029e7 <__alltraps>

00101ff9 <vector16>:
.globl vector16
vector16:
  pushl $0
  101ff9:	6a 00                	push   $0x0
  pushl $16
  101ffb:	6a 10                	push   $0x10
  jmp __alltraps
  101ffd:	e9 e5 09 00 00       	jmp    1029e7 <__alltraps>

00102002 <vector17>:
.globl vector17
vector17:
  pushl $17
  102002:	6a 11                	push   $0x11
  jmp __alltraps
  102004:	e9 de 09 00 00       	jmp    1029e7 <__alltraps>

00102009 <vector18>:
.globl vector18
vector18:
  pushl $0
  102009:	6a 00                	push   $0x0
  pushl $18
  10200b:	6a 12                	push   $0x12
  jmp __alltraps
  10200d:	e9 d5 09 00 00       	jmp    1029e7 <__alltraps>

00102012 <vector19>:
.globl vector19
vector19:
  pushl $0
  102012:	6a 00                	push   $0x0
  pushl $19
  102014:	6a 13                	push   $0x13
  jmp __alltraps
  102016:	e9 cc 09 00 00       	jmp    1029e7 <__alltraps>

0010201b <vector20>:
.globl vector20
vector20:
  pushl $0
  10201b:	6a 00                	push   $0x0
  pushl $20
  10201d:	6a 14                	push   $0x14
  jmp __alltraps
  10201f:	e9 c3 09 00 00       	jmp    1029e7 <__alltraps>

00102024 <vector21>:
.globl vector21
vector21:
  pushl $0
  102024:	6a 00                	push   $0x0
  pushl $21
  102026:	6a 15                	push   $0x15
  jmp __alltraps
  102028:	e9 ba 09 00 00       	jmp    1029e7 <__alltraps>

0010202d <vector22>:
.globl vector22
vector22:
  pushl $0
  10202d:	6a 00                	push   $0x0
  pushl $22
  10202f:	6a 16                	push   $0x16
  jmp __alltraps
  102031:	e9 b1 09 00 00       	jmp    1029e7 <__alltraps>

00102036 <vector23>:
.globl vector23
vector23:
  pushl $0
  102036:	6a 00                	push   $0x0
  pushl $23
  102038:	6a 17                	push   $0x17
  jmp __alltraps
  10203a:	e9 a8 09 00 00       	jmp    1029e7 <__alltraps>

0010203f <vector24>:
.globl vector24
vector24:
  pushl $0
  10203f:	6a 00                	push   $0x0
  pushl $24
  102041:	6a 18                	push   $0x18
  jmp __alltraps
  102043:	e9 9f 09 00 00       	jmp    1029e7 <__alltraps>

00102048 <vector25>:
.globl vector25
vector25:
  pushl $0
  102048:	6a 00                	push   $0x0
  pushl $25
  10204a:	6a 19                	push   $0x19
  jmp __alltraps
  10204c:	e9 96 09 00 00       	jmp    1029e7 <__alltraps>

00102051 <vector26>:
.globl vector26
vector26:
  pushl $0
  102051:	6a 00                	push   $0x0
  pushl $26
  102053:	6a 1a                	push   $0x1a
  jmp __alltraps
  102055:	e9 8d 09 00 00       	jmp    1029e7 <__alltraps>

0010205a <vector27>:
.globl vector27
vector27:
  pushl $0
  10205a:	6a 00                	push   $0x0
  pushl $27
  10205c:	6a 1b                	push   $0x1b
  jmp __alltraps
  10205e:	e9 84 09 00 00       	jmp    1029e7 <__alltraps>

00102063 <vector28>:
.globl vector28
vector28:
  pushl $0
  102063:	6a 00                	push   $0x0
  pushl $28
  102065:	6a 1c                	push   $0x1c
  jmp __alltraps
  102067:	e9 7b 09 00 00       	jmp    1029e7 <__alltraps>

0010206c <vector29>:
.globl vector29
vector29:
  pushl $0
  10206c:	6a 00                	push   $0x0
  pushl $29
  10206e:	6a 1d                	push   $0x1d
  jmp __alltraps
  102070:	e9 72 09 00 00       	jmp    1029e7 <__alltraps>

00102075 <vector30>:
.globl vector30
vector30:
  pushl $0
  102075:	6a 00                	push   $0x0
  pushl $30
  102077:	6a 1e                	push   $0x1e
  jmp __alltraps
  102079:	e9 69 09 00 00       	jmp    1029e7 <__alltraps>

0010207e <vector31>:
.globl vector31
vector31:
  pushl $0
  10207e:	6a 00                	push   $0x0
  pushl $31
  102080:	6a 1f                	push   $0x1f
  jmp __alltraps
  102082:	e9 60 09 00 00       	jmp    1029e7 <__alltraps>

00102087 <vector32>:
.globl vector32
vector32:
  pushl $0
  102087:	6a 00                	push   $0x0
  pushl $32
  102089:	6a 20                	push   $0x20
  jmp __alltraps
  10208b:	e9 57 09 00 00       	jmp    1029e7 <__alltraps>

00102090 <vector33>:
.globl vector33
vector33:
  pushl $0
  102090:	6a 00                	push   $0x0
  pushl $33
  102092:	6a 21                	push   $0x21
  jmp __alltraps
  102094:	e9 4e 09 00 00       	jmp    1029e7 <__alltraps>

00102099 <vector34>:
.globl vector34
vector34:
  pushl $0
  102099:	6a 00                	push   $0x0
  pushl $34
  10209b:	6a 22                	push   $0x22
  jmp __alltraps
  10209d:	e9 45 09 00 00       	jmp    1029e7 <__alltraps>

001020a2 <vector35>:
.globl vector35
vector35:
  pushl $0
  1020a2:	6a 00                	push   $0x0
  pushl $35
  1020a4:	6a 23                	push   $0x23
  jmp __alltraps
  1020a6:	e9 3c 09 00 00       	jmp    1029e7 <__alltraps>

001020ab <vector36>:
.globl vector36
vector36:
  pushl $0
  1020ab:	6a 00                	push   $0x0
  pushl $36
  1020ad:	6a 24                	push   $0x24
  jmp __alltraps
  1020af:	e9 33 09 00 00       	jmp    1029e7 <__alltraps>

001020b4 <vector37>:
.globl vector37
vector37:
  pushl $0
  1020b4:	6a 00                	push   $0x0
  pushl $37
  1020b6:	6a 25                	push   $0x25
  jmp __alltraps
  1020b8:	e9 2a 09 00 00       	jmp    1029e7 <__alltraps>

001020bd <vector38>:
.globl vector38
vector38:
  pushl $0
  1020bd:	6a 00                	push   $0x0
  pushl $38
  1020bf:	6a 26                	push   $0x26
  jmp __alltraps
  1020c1:	e9 21 09 00 00       	jmp    1029e7 <__alltraps>

001020c6 <vector39>:
.globl vector39
vector39:
  pushl $0
  1020c6:	6a 00                	push   $0x0
  pushl $39
  1020c8:	6a 27                	push   $0x27
  jmp __alltraps
  1020ca:	e9 18 09 00 00       	jmp    1029e7 <__alltraps>

001020cf <vector40>:
.globl vector40
vector40:
  pushl $0
  1020cf:	6a 00                	push   $0x0
  pushl $40
  1020d1:	6a 28                	push   $0x28
  jmp __alltraps
  1020d3:	e9 0f 09 00 00       	jmp    1029e7 <__alltraps>

001020d8 <vector41>:
.globl vector41
vector41:
  pushl $0
  1020d8:	6a 00                	push   $0x0
  pushl $41
  1020da:	6a 29                	push   $0x29
  jmp __alltraps
  1020dc:	e9 06 09 00 00       	jmp    1029e7 <__alltraps>

001020e1 <vector42>:
.globl vector42
vector42:
  pushl $0
  1020e1:	6a 00                	push   $0x0
  pushl $42
  1020e3:	6a 2a                	push   $0x2a
  jmp __alltraps
  1020e5:	e9 fd 08 00 00       	jmp    1029e7 <__alltraps>

001020ea <vector43>:
.globl vector43
vector43:
  pushl $0
  1020ea:	6a 00                	push   $0x0
  pushl $43
  1020ec:	6a 2b                	push   $0x2b
  jmp __alltraps
  1020ee:	e9 f4 08 00 00       	jmp    1029e7 <__alltraps>

001020f3 <vector44>:
.globl vector44
vector44:
  pushl $0
  1020f3:	6a 00                	push   $0x0
  pushl $44
  1020f5:	6a 2c                	push   $0x2c
  jmp __alltraps
  1020f7:	e9 eb 08 00 00       	jmp    1029e7 <__alltraps>

001020fc <vector45>:
.globl vector45
vector45:
  pushl $0
  1020fc:	6a 00                	push   $0x0
  pushl $45
  1020fe:	6a 2d                	push   $0x2d
  jmp __alltraps
  102100:	e9 e2 08 00 00       	jmp    1029e7 <__alltraps>

00102105 <vector46>:
.globl vector46
vector46:
  pushl $0
  102105:	6a 00                	push   $0x0
  pushl $46
  102107:	6a 2e                	push   $0x2e
  jmp __alltraps
  102109:	e9 d9 08 00 00       	jmp    1029e7 <__alltraps>

0010210e <vector47>:
.globl vector47
vector47:
  pushl $0
  10210e:	6a 00                	push   $0x0
  pushl $47
  102110:	6a 2f                	push   $0x2f
  jmp __alltraps
  102112:	e9 d0 08 00 00       	jmp    1029e7 <__alltraps>

00102117 <vector48>:
.globl vector48
vector48:
  pushl $0
  102117:	6a 00                	push   $0x0
  pushl $48
  102119:	6a 30                	push   $0x30
  jmp __alltraps
  10211b:	e9 c7 08 00 00       	jmp    1029e7 <__alltraps>

00102120 <vector49>:
.globl vector49
vector49:
  pushl $0
  102120:	6a 00                	push   $0x0
  pushl $49
  102122:	6a 31                	push   $0x31
  jmp __alltraps
  102124:	e9 be 08 00 00       	jmp    1029e7 <__alltraps>

00102129 <vector50>:
.globl vector50
vector50:
  pushl $0
  102129:	6a 00                	push   $0x0
  pushl $50
  10212b:	6a 32                	push   $0x32
  jmp __alltraps
  10212d:	e9 b5 08 00 00       	jmp    1029e7 <__alltraps>

00102132 <vector51>:
.globl vector51
vector51:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $51
  102134:	6a 33                	push   $0x33
  jmp __alltraps
  102136:	e9 ac 08 00 00       	jmp    1029e7 <__alltraps>

0010213b <vector52>:
.globl vector52
vector52:
  pushl $0
  10213b:	6a 00                	push   $0x0
  pushl $52
  10213d:	6a 34                	push   $0x34
  jmp __alltraps
  10213f:	e9 a3 08 00 00       	jmp    1029e7 <__alltraps>

00102144 <vector53>:
.globl vector53
vector53:
  pushl $0
  102144:	6a 00                	push   $0x0
  pushl $53
  102146:	6a 35                	push   $0x35
  jmp __alltraps
  102148:	e9 9a 08 00 00       	jmp    1029e7 <__alltraps>

0010214d <vector54>:
.globl vector54
vector54:
  pushl $0
  10214d:	6a 00                	push   $0x0
  pushl $54
  10214f:	6a 36                	push   $0x36
  jmp __alltraps
  102151:	e9 91 08 00 00       	jmp    1029e7 <__alltraps>

00102156 <vector55>:
.globl vector55
vector55:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $55
  102158:	6a 37                	push   $0x37
  jmp __alltraps
  10215a:	e9 88 08 00 00       	jmp    1029e7 <__alltraps>

0010215f <vector56>:
.globl vector56
vector56:
  pushl $0
  10215f:	6a 00                	push   $0x0
  pushl $56
  102161:	6a 38                	push   $0x38
  jmp __alltraps
  102163:	e9 7f 08 00 00       	jmp    1029e7 <__alltraps>

00102168 <vector57>:
.globl vector57
vector57:
  pushl $0
  102168:	6a 00                	push   $0x0
  pushl $57
  10216a:	6a 39                	push   $0x39
  jmp __alltraps
  10216c:	e9 76 08 00 00       	jmp    1029e7 <__alltraps>

00102171 <vector58>:
.globl vector58
vector58:
  pushl $0
  102171:	6a 00                	push   $0x0
  pushl $58
  102173:	6a 3a                	push   $0x3a
  jmp __alltraps
  102175:	e9 6d 08 00 00       	jmp    1029e7 <__alltraps>

0010217a <vector59>:
.globl vector59
vector59:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $59
  10217c:	6a 3b                	push   $0x3b
  jmp __alltraps
  10217e:	e9 64 08 00 00       	jmp    1029e7 <__alltraps>

00102183 <vector60>:
.globl vector60
vector60:
  pushl $0
  102183:	6a 00                	push   $0x0
  pushl $60
  102185:	6a 3c                	push   $0x3c
  jmp __alltraps
  102187:	e9 5b 08 00 00       	jmp    1029e7 <__alltraps>

0010218c <vector61>:
.globl vector61
vector61:
  pushl $0
  10218c:	6a 00                	push   $0x0
  pushl $61
  10218e:	6a 3d                	push   $0x3d
  jmp __alltraps
  102190:	e9 52 08 00 00       	jmp    1029e7 <__alltraps>

00102195 <vector62>:
.globl vector62
vector62:
  pushl $0
  102195:	6a 00                	push   $0x0
  pushl $62
  102197:	6a 3e                	push   $0x3e
  jmp __alltraps
  102199:	e9 49 08 00 00       	jmp    1029e7 <__alltraps>

0010219e <vector63>:
.globl vector63
vector63:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $63
  1021a0:	6a 3f                	push   $0x3f
  jmp __alltraps
  1021a2:	e9 40 08 00 00       	jmp    1029e7 <__alltraps>

001021a7 <vector64>:
.globl vector64
vector64:
  pushl $0
  1021a7:	6a 00                	push   $0x0
  pushl $64
  1021a9:	6a 40                	push   $0x40
  jmp __alltraps
  1021ab:	e9 37 08 00 00       	jmp    1029e7 <__alltraps>

001021b0 <vector65>:
.globl vector65
vector65:
  pushl $0
  1021b0:	6a 00                	push   $0x0
  pushl $65
  1021b2:	6a 41                	push   $0x41
  jmp __alltraps
  1021b4:	e9 2e 08 00 00       	jmp    1029e7 <__alltraps>

001021b9 <vector66>:
.globl vector66
vector66:
  pushl $0
  1021b9:	6a 00                	push   $0x0
  pushl $66
  1021bb:	6a 42                	push   $0x42
  jmp __alltraps
  1021bd:	e9 25 08 00 00       	jmp    1029e7 <__alltraps>

001021c2 <vector67>:
.globl vector67
vector67:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $67
  1021c4:	6a 43                	push   $0x43
  jmp __alltraps
  1021c6:	e9 1c 08 00 00       	jmp    1029e7 <__alltraps>

001021cb <vector68>:
.globl vector68
vector68:
  pushl $0
  1021cb:	6a 00                	push   $0x0
  pushl $68
  1021cd:	6a 44                	push   $0x44
  jmp __alltraps
  1021cf:	e9 13 08 00 00       	jmp    1029e7 <__alltraps>

001021d4 <vector69>:
.globl vector69
vector69:
  pushl $0
  1021d4:	6a 00                	push   $0x0
  pushl $69
  1021d6:	6a 45                	push   $0x45
  jmp __alltraps
  1021d8:	e9 0a 08 00 00       	jmp    1029e7 <__alltraps>

001021dd <vector70>:
.globl vector70
vector70:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $70
  1021df:	6a 46                	push   $0x46
  jmp __alltraps
  1021e1:	e9 01 08 00 00       	jmp    1029e7 <__alltraps>

001021e6 <vector71>:
.globl vector71
vector71:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $71
  1021e8:	6a 47                	push   $0x47
  jmp __alltraps
  1021ea:	e9 f8 07 00 00       	jmp    1029e7 <__alltraps>

001021ef <vector72>:
.globl vector72
vector72:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $72
  1021f1:	6a 48                	push   $0x48
  jmp __alltraps
  1021f3:	e9 ef 07 00 00       	jmp    1029e7 <__alltraps>

001021f8 <vector73>:
.globl vector73
vector73:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $73
  1021fa:	6a 49                	push   $0x49
  jmp __alltraps
  1021fc:	e9 e6 07 00 00       	jmp    1029e7 <__alltraps>

00102201 <vector74>:
.globl vector74
vector74:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $74
  102203:	6a 4a                	push   $0x4a
  jmp __alltraps
  102205:	e9 dd 07 00 00       	jmp    1029e7 <__alltraps>

0010220a <vector75>:
.globl vector75
vector75:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $75
  10220c:	6a 4b                	push   $0x4b
  jmp __alltraps
  10220e:	e9 d4 07 00 00       	jmp    1029e7 <__alltraps>

00102213 <vector76>:
.globl vector76
vector76:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $76
  102215:	6a 4c                	push   $0x4c
  jmp __alltraps
  102217:	e9 cb 07 00 00       	jmp    1029e7 <__alltraps>

0010221c <vector77>:
.globl vector77
vector77:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $77
  10221e:	6a 4d                	push   $0x4d
  jmp __alltraps
  102220:	e9 c2 07 00 00       	jmp    1029e7 <__alltraps>

00102225 <vector78>:
.globl vector78
vector78:
  pushl $0
  102225:	6a 00                	push   $0x0
  pushl $78
  102227:	6a 4e                	push   $0x4e
  jmp __alltraps
  102229:	e9 b9 07 00 00       	jmp    1029e7 <__alltraps>

0010222e <vector79>:
.globl vector79
vector79:
  pushl $0
  10222e:	6a 00                	push   $0x0
  pushl $79
  102230:	6a 4f                	push   $0x4f
  jmp __alltraps
  102232:	e9 b0 07 00 00       	jmp    1029e7 <__alltraps>

00102237 <vector80>:
.globl vector80
vector80:
  pushl $0
  102237:	6a 00                	push   $0x0
  pushl $80
  102239:	6a 50                	push   $0x50
  jmp __alltraps
  10223b:	e9 a7 07 00 00       	jmp    1029e7 <__alltraps>

00102240 <vector81>:
.globl vector81
vector81:
  pushl $0
  102240:	6a 00                	push   $0x0
  pushl $81
  102242:	6a 51                	push   $0x51
  jmp __alltraps
  102244:	e9 9e 07 00 00       	jmp    1029e7 <__alltraps>

00102249 <vector82>:
.globl vector82
vector82:
  pushl $0
  102249:	6a 00                	push   $0x0
  pushl $82
  10224b:	6a 52                	push   $0x52
  jmp __alltraps
  10224d:	e9 95 07 00 00       	jmp    1029e7 <__alltraps>

00102252 <vector83>:
.globl vector83
vector83:
  pushl $0
  102252:	6a 00                	push   $0x0
  pushl $83
  102254:	6a 53                	push   $0x53
  jmp __alltraps
  102256:	e9 8c 07 00 00       	jmp    1029e7 <__alltraps>

0010225b <vector84>:
.globl vector84
vector84:
  pushl $0
  10225b:	6a 00                	push   $0x0
  pushl $84
  10225d:	6a 54                	push   $0x54
  jmp __alltraps
  10225f:	e9 83 07 00 00       	jmp    1029e7 <__alltraps>

00102264 <vector85>:
.globl vector85
vector85:
  pushl $0
  102264:	6a 00                	push   $0x0
  pushl $85
  102266:	6a 55                	push   $0x55
  jmp __alltraps
  102268:	e9 7a 07 00 00       	jmp    1029e7 <__alltraps>

0010226d <vector86>:
.globl vector86
vector86:
  pushl $0
  10226d:	6a 00                	push   $0x0
  pushl $86
  10226f:	6a 56                	push   $0x56
  jmp __alltraps
  102271:	e9 71 07 00 00       	jmp    1029e7 <__alltraps>

00102276 <vector87>:
.globl vector87
vector87:
  pushl $0
  102276:	6a 00                	push   $0x0
  pushl $87
  102278:	6a 57                	push   $0x57
  jmp __alltraps
  10227a:	e9 68 07 00 00       	jmp    1029e7 <__alltraps>

0010227f <vector88>:
.globl vector88
vector88:
  pushl $0
  10227f:	6a 00                	push   $0x0
  pushl $88
  102281:	6a 58                	push   $0x58
  jmp __alltraps
  102283:	e9 5f 07 00 00       	jmp    1029e7 <__alltraps>

00102288 <vector89>:
.globl vector89
vector89:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $89
  10228a:	6a 59                	push   $0x59
  jmp __alltraps
  10228c:	e9 56 07 00 00       	jmp    1029e7 <__alltraps>

00102291 <vector90>:
.globl vector90
vector90:
  pushl $0
  102291:	6a 00                	push   $0x0
  pushl $90
  102293:	6a 5a                	push   $0x5a
  jmp __alltraps
  102295:	e9 4d 07 00 00       	jmp    1029e7 <__alltraps>

0010229a <vector91>:
.globl vector91
vector91:
  pushl $0
  10229a:	6a 00                	push   $0x0
  pushl $91
  10229c:	6a 5b                	push   $0x5b
  jmp __alltraps
  10229e:	e9 44 07 00 00       	jmp    1029e7 <__alltraps>

001022a3 <vector92>:
.globl vector92
vector92:
  pushl $0
  1022a3:	6a 00                	push   $0x0
  pushl $92
  1022a5:	6a 5c                	push   $0x5c
  jmp __alltraps
  1022a7:	e9 3b 07 00 00       	jmp    1029e7 <__alltraps>

001022ac <vector93>:
.globl vector93
vector93:
  pushl $0
  1022ac:	6a 00                	push   $0x0
  pushl $93
  1022ae:	6a 5d                	push   $0x5d
  jmp __alltraps
  1022b0:	e9 32 07 00 00       	jmp    1029e7 <__alltraps>

001022b5 <vector94>:
.globl vector94
vector94:
  pushl $0
  1022b5:	6a 00                	push   $0x0
  pushl $94
  1022b7:	6a 5e                	push   $0x5e
  jmp __alltraps
  1022b9:	e9 29 07 00 00       	jmp    1029e7 <__alltraps>

001022be <vector95>:
.globl vector95
vector95:
  pushl $0
  1022be:	6a 00                	push   $0x0
  pushl $95
  1022c0:	6a 5f                	push   $0x5f
  jmp __alltraps
  1022c2:	e9 20 07 00 00       	jmp    1029e7 <__alltraps>

001022c7 <vector96>:
.globl vector96
vector96:
  pushl $0
  1022c7:	6a 00                	push   $0x0
  pushl $96
  1022c9:	6a 60                	push   $0x60
  jmp __alltraps
  1022cb:	e9 17 07 00 00       	jmp    1029e7 <__alltraps>

001022d0 <vector97>:
.globl vector97
vector97:
  pushl $0
  1022d0:	6a 00                	push   $0x0
  pushl $97
  1022d2:	6a 61                	push   $0x61
  jmp __alltraps
  1022d4:	e9 0e 07 00 00       	jmp    1029e7 <__alltraps>

001022d9 <vector98>:
.globl vector98
vector98:
  pushl $0
  1022d9:	6a 00                	push   $0x0
  pushl $98
  1022db:	6a 62                	push   $0x62
  jmp __alltraps
  1022dd:	e9 05 07 00 00       	jmp    1029e7 <__alltraps>

001022e2 <vector99>:
.globl vector99
vector99:
  pushl $0
  1022e2:	6a 00                	push   $0x0
  pushl $99
  1022e4:	6a 63                	push   $0x63
  jmp __alltraps
  1022e6:	e9 fc 06 00 00       	jmp    1029e7 <__alltraps>

001022eb <vector100>:
.globl vector100
vector100:
  pushl $0
  1022eb:	6a 00                	push   $0x0
  pushl $100
  1022ed:	6a 64                	push   $0x64
  jmp __alltraps
  1022ef:	e9 f3 06 00 00       	jmp    1029e7 <__alltraps>

001022f4 <vector101>:
.globl vector101
vector101:
  pushl $0
  1022f4:	6a 00                	push   $0x0
  pushl $101
  1022f6:	6a 65                	push   $0x65
  jmp __alltraps
  1022f8:	e9 ea 06 00 00       	jmp    1029e7 <__alltraps>

001022fd <vector102>:
.globl vector102
vector102:
  pushl $0
  1022fd:	6a 00                	push   $0x0
  pushl $102
  1022ff:	6a 66                	push   $0x66
  jmp __alltraps
  102301:	e9 e1 06 00 00       	jmp    1029e7 <__alltraps>

00102306 <vector103>:
.globl vector103
vector103:
  pushl $0
  102306:	6a 00                	push   $0x0
  pushl $103
  102308:	6a 67                	push   $0x67
  jmp __alltraps
  10230a:	e9 d8 06 00 00       	jmp    1029e7 <__alltraps>

0010230f <vector104>:
.globl vector104
vector104:
  pushl $0
  10230f:	6a 00                	push   $0x0
  pushl $104
  102311:	6a 68                	push   $0x68
  jmp __alltraps
  102313:	e9 cf 06 00 00       	jmp    1029e7 <__alltraps>

00102318 <vector105>:
.globl vector105
vector105:
  pushl $0
  102318:	6a 00                	push   $0x0
  pushl $105
  10231a:	6a 69                	push   $0x69
  jmp __alltraps
  10231c:	e9 c6 06 00 00       	jmp    1029e7 <__alltraps>

00102321 <vector106>:
.globl vector106
vector106:
  pushl $0
  102321:	6a 00                	push   $0x0
  pushl $106
  102323:	6a 6a                	push   $0x6a
  jmp __alltraps
  102325:	e9 bd 06 00 00       	jmp    1029e7 <__alltraps>

0010232a <vector107>:
.globl vector107
vector107:
  pushl $0
  10232a:	6a 00                	push   $0x0
  pushl $107
  10232c:	6a 6b                	push   $0x6b
  jmp __alltraps
  10232e:	e9 b4 06 00 00       	jmp    1029e7 <__alltraps>

00102333 <vector108>:
.globl vector108
vector108:
  pushl $0
  102333:	6a 00                	push   $0x0
  pushl $108
  102335:	6a 6c                	push   $0x6c
  jmp __alltraps
  102337:	e9 ab 06 00 00       	jmp    1029e7 <__alltraps>

0010233c <vector109>:
.globl vector109
vector109:
  pushl $0
  10233c:	6a 00                	push   $0x0
  pushl $109
  10233e:	6a 6d                	push   $0x6d
  jmp __alltraps
  102340:	e9 a2 06 00 00       	jmp    1029e7 <__alltraps>

00102345 <vector110>:
.globl vector110
vector110:
  pushl $0
  102345:	6a 00                	push   $0x0
  pushl $110
  102347:	6a 6e                	push   $0x6e
  jmp __alltraps
  102349:	e9 99 06 00 00       	jmp    1029e7 <__alltraps>

0010234e <vector111>:
.globl vector111
vector111:
  pushl $0
  10234e:	6a 00                	push   $0x0
  pushl $111
  102350:	6a 6f                	push   $0x6f
  jmp __alltraps
  102352:	e9 90 06 00 00       	jmp    1029e7 <__alltraps>

00102357 <vector112>:
.globl vector112
vector112:
  pushl $0
  102357:	6a 00                	push   $0x0
  pushl $112
  102359:	6a 70                	push   $0x70
  jmp __alltraps
  10235b:	e9 87 06 00 00       	jmp    1029e7 <__alltraps>

00102360 <vector113>:
.globl vector113
vector113:
  pushl $0
  102360:	6a 00                	push   $0x0
  pushl $113
  102362:	6a 71                	push   $0x71
  jmp __alltraps
  102364:	e9 7e 06 00 00       	jmp    1029e7 <__alltraps>

00102369 <vector114>:
.globl vector114
vector114:
  pushl $0
  102369:	6a 00                	push   $0x0
  pushl $114
  10236b:	6a 72                	push   $0x72
  jmp __alltraps
  10236d:	e9 75 06 00 00       	jmp    1029e7 <__alltraps>

00102372 <vector115>:
.globl vector115
vector115:
  pushl $0
  102372:	6a 00                	push   $0x0
  pushl $115
  102374:	6a 73                	push   $0x73
  jmp __alltraps
  102376:	e9 6c 06 00 00       	jmp    1029e7 <__alltraps>

0010237b <vector116>:
.globl vector116
vector116:
  pushl $0
  10237b:	6a 00                	push   $0x0
  pushl $116
  10237d:	6a 74                	push   $0x74
  jmp __alltraps
  10237f:	e9 63 06 00 00       	jmp    1029e7 <__alltraps>

00102384 <vector117>:
.globl vector117
vector117:
  pushl $0
  102384:	6a 00                	push   $0x0
  pushl $117
  102386:	6a 75                	push   $0x75
  jmp __alltraps
  102388:	e9 5a 06 00 00       	jmp    1029e7 <__alltraps>

0010238d <vector118>:
.globl vector118
vector118:
  pushl $0
  10238d:	6a 00                	push   $0x0
  pushl $118
  10238f:	6a 76                	push   $0x76
  jmp __alltraps
  102391:	e9 51 06 00 00       	jmp    1029e7 <__alltraps>

00102396 <vector119>:
.globl vector119
vector119:
  pushl $0
  102396:	6a 00                	push   $0x0
  pushl $119
  102398:	6a 77                	push   $0x77
  jmp __alltraps
  10239a:	e9 48 06 00 00       	jmp    1029e7 <__alltraps>

0010239f <vector120>:
.globl vector120
vector120:
  pushl $0
  10239f:	6a 00                	push   $0x0
  pushl $120
  1023a1:	6a 78                	push   $0x78
  jmp __alltraps
  1023a3:	e9 3f 06 00 00       	jmp    1029e7 <__alltraps>

001023a8 <vector121>:
.globl vector121
vector121:
  pushl $0
  1023a8:	6a 00                	push   $0x0
  pushl $121
  1023aa:	6a 79                	push   $0x79
  jmp __alltraps
  1023ac:	e9 36 06 00 00       	jmp    1029e7 <__alltraps>

001023b1 <vector122>:
.globl vector122
vector122:
  pushl $0
  1023b1:	6a 00                	push   $0x0
  pushl $122
  1023b3:	6a 7a                	push   $0x7a
  jmp __alltraps
  1023b5:	e9 2d 06 00 00       	jmp    1029e7 <__alltraps>

001023ba <vector123>:
.globl vector123
vector123:
  pushl $0
  1023ba:	6a 00                	push   $0x0
  pushl $123
  1023bc:	6a 7b                	push   $0x7b
  jmp __alltraps
  1023be:	e9 24 06 00 00       	jmp    1029e7 <__alltraps>

001023c3 <vector124>:
.globl vector124
vector124:
  pushl $0
  1023c3:	6a 00                	push   $0x0
  pushl $124
  1023c5:	6a 7c                	push   $0x7c
  jmp __alltraps
  1023c7:	e9 1b 06 00 00       	jmp    1029e7 <__alltraps>

001023cc <vector125>:
.globl vector125
vector125:
  pushl $0
  1023cc:	6a 00                	push   $0x0
  pushl $125
  1023ce:	6a 7d                	push   $0x7d
  jmp __alltraps
  1023d0:	e9 12 06 00 00       	jmp    1029e7 <__alltraps>

001023d5 <vector126>:
.globl vector126
vector126:
  pushl $0
  1023d5:	6a 00                	push   $0x0
  pushl $126
  1023d7:	6a 7e                	push   $0x7e
  jmp __alltraps
  1023d9:	e9 09 06 00 00       	jmp    1029e7 <__alltraps>

001023de <vector127>:
.globl vector127
vector127:
  pushl $0
  1023de:	6a 00                	push   $0x0
  pushl $127
  1023e0:	6a 7f                	push   $0x7f
  jmp __alltraps
  1023e2:	e9 00 06 00 00       	jmp    1029e7 <__alltraps>

001023e7 <vector128>:
.globl vector128
vector128:
  pushl $0
  1023e7:	6a 00                	push   $0x0
  pushl $128
  1023e9:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1023ee:	e9 f4 05 00 00       	jmp    1029e7 <__alltraps>

001023f3 <vector129>:
.globl vector129
vector129:
  pushl $0
  1023f3:	6a 00                	push   $0x0
  pushl $129
  1023f5:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1023fa:	e9 e8 05 00 00       	jmp    1029e7 <__alltraps>

001023ff <vector130>:
.globl vector130
vector130:
  pushl $0
  1023ff:	6a 00                	push   $0x0
  pushl $130
  102401:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102406:	e9 dc 05 00 00       	jmp    1029e7 <__alltraps>

0010240b <vector131>:
.globl vector131
vector131:
  pushl $0
  10240b:	6a 00                	push   $0x0
  pushl $131
  10240d:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102412:	e9 d0 05 00 00       	jmp    1029e7 <__alltraps>

00102417 <vector132>:
.globl vector132
vector132:
  pushl $0
  102417:	6a 00                	push   $0x0
  pushl $132
  102419:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10241e:	e9 c4 05 00 00       	jmp    1029e7 <__alltraps>

00102423 <vector133>:
.globl vector133
vector133:
  pushl $0
  102423:	6a 00                	push   $0x0
  pushl $133
  102425:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10242a:	e9 b8 05 00 00       	jmp    1029e7 <__alltraps>

0010242f <vector134>:
.globl vector134
vector134:
  pushl $0
  10242f:	6a 00                	push   $0x0
  pushl $134
  102431:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102436:	e9 ac 05 00 00       	jmp    1029e7 <__alltraps>

0010243b <vector135>:
.globl vector135
vector135:
  pushl $0
  10243b:	6a 00                	push   $0x0
  pushl $135
  10243d:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102442:	e9 a0 05 00 00       	jmp    1029e7 <__alltraps>

00102447 <vector136>:
.globl vector136
vector136:
  pushl $0
  102447:	6a 00                	push   $0x0
  pushl $136
  102449:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10244e:	e9 94 05 00 00       	jmp    1029e7 <__alltraps>

00102453 <vector137>:
.globl vector137
vector137:
  pushl $0
  102453:	6a 00                	push   $0x0
  pushl $137
  102455:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10245a:	e9 88 05 00 00       	jmp    1029e7 <__alltraps>

0010245f <vector138>:
.globl vector138
vector138:
  pushl $0
  10245f:	6a 00                	push   $0x0
  pushl $138
  102461:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102466:	e9 7c 05 00 00       	jmp    1029e7 <__alltraps>

0010246b <vector139>:
.globl vector139
vector139:
  pushl $0
  10246b:	6a 00                	push   $0x0
  pushl $139
  10246d:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102472:	e9 70 05 00 00       	jmp    1029e7 <__alltraps>

00102477 <vector140>:
.globl vector140
vector140:
  pushl $0
  102477:	6a 00                	push   $0x0
  pushl $140
  102479:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10247e:	e9 64 05 00 00       	jmp    1029e7 <__alltraps>

00102483 <vector141>:
.globl vector141
vector141:
  pushl $0
  102483:	6a 00                	push   $0x0
  pushl $141
  102485:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10248a:	e9 58 05 00 00       	jmp    1029e7 <__alltraps>

0010248f <vector142>:
.globl vector142
vector142:
  pushl $0
  10248f:	6a 00                	push   $0x0
  pushl $142
  102491:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102496:	e9 4c 05 00 00       	jmp    1029e7 <__alltraps>

0010249b <vector143>:
.globl vector143
vector143:
  pushl $0
  10249b:	6a 00                	push   $0x0
  pushl $143
  10249d:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1024a2:	e9 40 05 00 00       	jmp    1029e7 <__alltraps>

001024a7 <vector144>:
.globl vector144
vector144:
  pushl $0
  1024a7:	6a 00                	push   $0x0
  pushl $144
  1024a9:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1024ae:	e9 34 05 00 00       	jmp    1029e7 <__alltraps>

001024b3 <vector145>:
.globl vector145
vector145:
  pushl $0
  1024b3:	6a 00                	push   $0x0
  pushl $145
  1024b5:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1024ba:	e9 28 05 00 00       	jmp    1029e7 <__alltraps>

001024bf <vector146>:
.globl vector146
vector146:
  pushl $0
  1024bf:	6a 00                	push   $0x0
  pushl $146
  1024c1:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1024c6:	e9 1c 05 00 00       	jmp    1029e7 <__alltraps>

001024cb <vector147>:
.globl vector147
vector147:
  pushl $0
  1024cb:	6a 00                	push   $0x0
  pushl $147
  1024cd:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1024d2:	e9 10 05 00 00       	jmp    1029e7 <__alltraps>

001024d7 <vector148>:
.globl vector148
vector148:
  pushl $0
  1024d7:	6a 00                	push   $0x0
  pushl $148
  1024d9:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1024de:	e9 04 05 00 00       	jmp    1029e7 <__alltraps>

001024e3 <vector149>:
.globl vector149
vector149:
  pushl $0
  1024e3:	6a 00                	push   $0x0
  pushl $149
  1024e5:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1024ea:	e9 f8 04 00 00       	jmp    1029e7 <__alltraps>

001024ef <vector150>:
.globl vector150
vector150:
  pushl $0
  1024ef:	6a 00                	push   $0x0
  pushl $150
  1024f1:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1024f6:	e9 ec 04 00 00       	jmp    1029e7 <__alltraps>

001024fb <vector151>:
.globl vector151
vector151:
  pushl $0
  1024fb:	6a 00                	push   $0x0
  pushl $151
  1024fd:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102502:	e9 e0 04 00 00       	jmp    1029e7 <__alltraps>

00102507 <vector152>:
.globl vector152
vector152:
  pushl $0
  102507:	6a 00                	push   $0x0
  pushl $152
  102509:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10250e:	e9 d4 04 00 00       	jmp    1029e7 <__alltraps>

00102513 <vector153>:
.globl vector153
vector153:
  pushl $0
  102513:	6a 00                	push   $0x0
  pushl $153
  102515:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10251a:	e9 c8 04 00 00       	jmp    1029e7 <__alltraps>

0010251f <vector154>:
.globl vector154
vector154:
  pushl $0
  10251f:	6a 00                	push   $0x0
  pushl $154
  102521:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102526:	e9 bc 04 00 00       	jmp    1029e7 <__alltraps>

0010252b <vector155>:
.globl vector155
vector155:
  pushl $0
  10252b:	6a 00                	push   $0x0
  pushl $155
  10252d:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102532:	e9 b0 04 00 00       	jmp    1029e7 <__alltraps>

00102537 <vector156>:
.globl vector156
vector156:
  pushl $0
  102537:	6a 00                	push   $0x0
  pushl $156
  102539:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10253e:	e9 a4 04 00 00       	jmp    1029e7 <__alltraps>

00102543 <vector157>:
.globl vector157
vector157:
  pushl $0
  102543:	6a 00                	push   $0x0
  pushl $157
  102545:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10254a:	e9 98 04 00 00       	jmp    1029e7 <__alltraps>

0010254f <vector158>:
.globl vector158
vector158:
  pushl $0
  10254f:	6a 00                	push   $0x0
  pushl $158
  102551:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102556:	e9 8c 04 00 00       	jmp    1029e7 <__alltraps>

0010255b <vector159>:
.globl vector159
vector159:
  pushl $0
  10255b:	6a 00                	push   $0x0
  pushl $159
  10255d:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102562:	e9 80 04 00 00       	jmp    1029e7 <__alltraps>

00102567 <vector160>:
.globl vector160
vector160:
  pushl $0
  102567:	6a 00                	push   $0x0
  pushl $160
  102569:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10256e:	e9 74 04 00 00       	jmp    1029e7 <__alltraps>

00102573 <vector161>:
.globl vector161
vector161:
  pushl $0
  102573:	6a 00                	push   $0x0
  pushl $161
  102575:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10257a:	e9 68 04 00 00       	jmp    1029e7 <__alltraps>

0010257f <vector162>:
.globl vector162
vector162:
  pushl $0
  10257f:	6a 00                	push   $0x0
  pushl $162
  102581:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102586:	e9 5c 04 00 00       	jmp    1029e7 <__alltraps>

0010258b <vector163>:
.globl vector163
vector163:
  pushl $0
  10258b:	6a 00                	push   $0x0
  pushl $163
  10258d:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102592:	e9 50 04 00 00       	jmp    1029e7 <__alltraps>

00102597 <vector164>:
.globl vector164
vector164:
  pushl $0
  102597:	6a 00                	push   $0x0
  pushl $164
  102599:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10259e:	e9 44 04 00 00       	jmp    1029e7 <__alltraps>

001025a3 <vector165>:
.globl vector165
vector165:
  pushl $0
  1025a3:	6a 00                	push   $0x0
  pushl $165
  1025a5:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1025aa:	e9 38 04 00 00       	jmp    1029e7 <__alltraps>

001025af <vector166>:
.globl vector166
vector166:
  pushl $0
  1025af:	6a 00                	push   $0x0
  pushl $166
  1025b1:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1025b6:	e9 2c 04 00 00       	jmp    1029e7 <__alltraps>

001025bb <vector167>:
.globl vector167
vector167:
  pushl $0
  1025bb:	6a 00                	push   $0x0
  pushl $167
  1025bd:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1025c2:	e9 20 04 00 00       	jmp    1029e7 <__alltraps>

001025c7 <vector168>:
.globl vector168
vector168:
  pushl $0
  1025c7:	6a 00                	push   $0x0
  pushl $168
  1025c9:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1025ce:	e9 14 04 00 00       	jmp    1029e7 <__alltraps>

001025d3 <vector169>:
.globl vector169
vector169:
  pushl $0
  1025d3:	6a 00                	push   $0x0
  pushl $169
  1025d5:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1025da:	e9 08 04 00 00       	jmp    1029e7 <__alltraps>

001025df <vector170>:
.globl vector170
vector170:
  pushl $0
  1025df:	6a 00                	push   $0x0
  pushl $170
  1025e1:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1025e6:	e9 fc 03 00 00       	jmp    1029e7 <__alltraps>

001025eb <vector171>:
.globl vector171
vector171:
  pushl $0
  1025eb:	6a 00                	push   $0x0
  pushl $171
  1025ed:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1025f2:	e9 f0 03 00 00       	jmp    1029e7 <__alltraps>

001025f7 <vector172>:
.globl vector172
vector172:
  pushl $0
  1025f7:	6a 00                	push   $0x0
  pushl $172
  1025f9:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1025fe:	e9 e4 03 00 00       	jmp    1029e7 <__alltraps>

00102603 <vector173>:
.globl vector173
vector173:
  pushl $0
  102603:	6a 00                	push   $0x0
  pushl $173
  102605:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10260a:	e9 d8 03 00 00       	jmp    1029e7 <__alltraps>

0010260f <vector174>:
.globl vector174
vector174:
  pushl $0
  10260f:	6a 00                	push   $0x0
  pushl $174
  102611:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102616:	e9 cc 03 00 00       	jmp    1029e7 <__alltraps>

0010261b <vector175>:
.globl vector175
vector175:
  pushl $0
  10261b:	6a 00                	push   $0x0
  pushl $175
  10261d:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102622:	e9 c0 03 00 00       	jmp    1029e7 <__alltraps>

00102627 <vector176>:
.globl vector176
vector176:
  pushl $0
  102627:	6a 00                	push   $0x0
  pushl $176
  102629:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10262e:	e9 b4 03 00 00       	jmp    1029e7 <__alltraps>

00102633 <vector177>:
.globl vector177
vector177:
  pushl $0
  102633:	6a 00                	push   $0x0
  pushl $177
  102635:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10263a:	e9 a8 03 00 00       	jmp    1029e7 <__alltraps>

0010263f <vector178>:
.globl vector178
vector178:
  pushl $0
  10263f:	6a 00                	push   $0x0
  pushl $178
  102641:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102646:	e9 9c 03 00 00       	jmp    1029e7 <__alltraps>

0010264b <vector179>:
.globl vector179
vector179:
  pushl $0
  10264b:	6a 00                	push   $0x0
  pushl $179
  10264d:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102652:	e9 90 03 00 00       	jmp    1029e7 <__alltraps>

00102657 <vector180>:
.globl vector180
vector180:
  pushl $0
  102657:	6a 00                	push   $0x0
  pushl $180
  102659:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10265e:	e9 84 03 00 00       	jmp    1029e7 <__alltraps>

00102663 <vector181>:
.globl vector181
vector181:
  pushl $0
  102663:	6a 00                	push   $0x0
  pushl $181
  102665:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10266a:	e9 78 03 00 00       	jmp    1029e7 <__alltraps>

0010266f <vector182>:
.globl vector182
vector182:
  pushl $0
  10266f:	6a 00                	push   $0x0
  pushl $182
  102671:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102676:	e9 6c 03 00 00       	jmp    1029e7 <__alltraps>

0010267b <vector183>:
.globl vector183
vector183:
  pushl $0
  10267b:	6a 00                	push   $0x0
  pushl $183
  10267d:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102682:	e9 60 03 00 00       	jmp    1029e7 <__alltraps>

00102687 <vector184>:
.globl vector184
vector184:
  pushl $0
  102687:	6a 00                	push   $0x0
  pushl $184
  102689:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10268e:	e9 54 03 00 00       	jmp    1029e7 <__alltraps>

00102693 <vector185>:
.globl vector185
vector185:
  pushl $0
  102693:	6a 00                	push   $0x0
  pushl $185
  102695:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10269a:	e9 48 03 00 00       	jmp    1029e7 <__alltraps>

0010269f <vector186>:
.globl vector186
vector186:
  pushl $0
  10269f:	6a 00                	push   $0x0
  pushl $186
  1026a1:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1026a6:	e9 3c 03 00 00       	jmp    1029e7 <__alltraps>

001026ab <vector187>:
.globl vector187
vector187:
  pushl $0
  1026ab:	6a 00                	push   $0x0
  pushl $187
  1026ad:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1026b2:	e9 30 03 00 00       	jmp    1029e7 <__alltraps>

001026b7 <vector188>:
.globl vector188
vector188:
  pushl $0
  1026b7:	6a 00                	push   $0x0
  pushl $188
  1026b9:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1026be:	e9 24 03 00 00       	jmp    1029e7 <__alltraps>

001026c3 <vector189>:
.globl vector189
vector189:
  pushl $0
  1026c3:	6a 00                	push   $0x0
  pushl $189
  1026c5:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1026ca:	e9 18 03 00 00       	jmp    1029e7 <__alltraps>

001026cf <vector190>:
.globl vector190
vector190:
  pushl $0
  1026cf:	6a 00                	push   $0x0
  pushl $190
  1026d1:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1026d6:	e9 0c 03 00 00       	jmp    1029e7 <__alltraps>

001026db <vector191>:
.globl vector191
vector191:
  pushl $0
  1026db:	6a 00                	push   $0x0
  pushl $191
  1026dd:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1026e2:	e9 00 03 00 00       	jmp    1029e7 <__alltraps>

001026e7 <vector192>:
.globl vector192
vector192:
  pushl $0
  1026e7:	6a 00                	push   $0x0
  pushl $192
  1026e9:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1026ee:	e9 f4 02 00 00       	jmp    1029e7 <__alltraps>

001026f3 <vector193>:
.globl vector193
vector193:
  pushl $0
  1026f3:	6a 00                	push   $0x0
  pushl $193
  1026f5:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1026fa:	e9 e8 02 00 00       	jmp    1029e7 <__alltraps>

001026ff <vector194>:
.globl vector194
vector194:
  pushl $0
  1026ff:	6a 00                	push   $0x0
  pushl $194
  102701:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102706:	e9 dc 02 00 00       	jmp    1029e7 <__alltraps>

0010270b <vector195>:
.globl vector195
vector195:
  pushl $0
  10270b:	6a 00                	push   $0x0
  pushl $195
  10270d:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102712:	e9 d0 02 00 00       	jmp    1029e7 <__alltraps>

00102717 <vector196>:
.globl vector196
vector196:
  pushl $0
  102717:	6a 00                	push   $0x0
  pushl $196
  102719:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10271e:	e9 c4 02 00 00       	jmp    1029e7 <__alltraps>

00102723 <vector197>:
.globl vector197
vector197:
  pushl $0
  102723:	6a 00                	push   $0x0
  pushl $197
  102725:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10272a:	e9 b8 02 00 00       	jmp    1029e7 <__alltraps>

0010272f <vector198>:
.globl vector198
vector198:
  pushl $0
  10272f:	6a 00                	push   $0x0
  pushl $198
  102731:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102736:	e9 ac 02 00 00       	jmp    1029e7 <__alltraps>

0010273b <vector199>:
.globl vector199
vector199:
  pushl $0
  10273b:	6a 00                	push   $0x0
  pushl $199
  10273d:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102742:	e9 a0 02 00 00       	jmp    1029e7 <__alltraps>

00102747 <vector200>:
.globl vector200
vector200:
  pushl $0
  102747:	6a 00                	push   $0x0
  pushl $200
  102749:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10274e:	e9 94 02 00 00       	jmp    1029e7 <__alltraps>

00102753 <vector201>:
.globl vector201
vector201:
  pushl $0
  102753:	6a 00                	push   $0x0
  pushl $201
  102755:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10275a:	e9 88 02 00 00       	jmp    1029e7 <__alltraps>

0010275f <vector202>:
.globl vector202
vector202:
  pushl $0
  10275f:	6a 00                	push   $0x0
  pushl $202
  102761:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102766:	e9 7c 02 00 00       	jmp    1029e7 <__alltraps>

0010276b <vector203>:
.globl vector203
vector203:
  pushl $0
  10276b:	6a 00                	push   $0x0
  pushl $203
  10276d:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102772:	e9 70 02 00 00       	jmp    1029e7 <__alltraps>

00102777 <vector204>:
.globl vector204
vector204:
  pushl $0
  102777:	6a 00                	push   $0x0
  pushl $204
  102779:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10277e:	e9 64 02 00 00       	jmp    1029e7 <__alltraps>

00102783 <vector205>:
.globl vector205
vector205:
  pushl $0
  102783:	6a 00                	push   $0x0
  pushl $205
  102785:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10278a:	e9 58 02 00 00       	jmp    1029e7 <__alltraps>

0010278f <vector206>:
.globl vector206
vector206:
  pushl $0
  10278f:	6a 00                	push   $0x0
  pushl $206
  102791:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102796:	e9 4c 02 00 00       	jmp    1029e7 <__alltraps>

0010279b <vector207>:
.globl vector207
vector207:
  pushl $0
  10279b:	6a 00                	push   $0x0
  pushl $207
  10279d:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1027a2:	e9 40 02 00 00       	jmp    1029e7 <__alltraps>

001027a7 <vector208>:
.globl vector208
vector208:
  pushl $0
  1027a7:	6a 00                	push   $0x0
  pushl $208
  1027a9:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1027ae:	e9 34 02 00 00       	jmp    1029e7 <__alltraps>

001027b3 <vector209>:
.globl vector209
vector209:
  pushl $0
  1027b3:	6a 00                	push   $0x0
  pushl $209
  1027b5:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1027ba:	e9 28 02 00 00       	jmp    1029e7 <__alltraps>

001027bf <vector210>:
.globl vector210
vector210:
  pushl $0
  1027bf:	6a 00                	push   $0x0
  pushl $210
  1027c1:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1027c6:	e9 1c 02 00 00       	jmp    1029e7 <__alltraps>

001027cb <vector211>:
.globl vector211
vector211:
  pushl $0
  1027cb:	6a 00                	push   $0x0
  pushl $211
  1027cd:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1027d2:	e9 10 02 00 00       	jmp    1029e7 <__alltraps>

001027d7 <vector212>:
.globl vector212
vector212:
  pushl $0
  1027d7:	6a 00                	push   $0x0
  pushl $212
  1027d9:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1027de:	e9 04 02 00 00       	jmp    1029e7 <__alltraps>

001027e3 <vector213>:
.globl vector213
vector213:
  pushl $0
  1027e3:	6a 00                	push   $0x0
  pushl $213
  1027e5:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1027ea:	e9 f8 01 00 00       	jmp    1029e7 <__alltraps>

001027ef <vector214>:
.globl vector214
vector214:
  pushl $0
  1027ef:	6a 00                	push   $0x0
  pushl $214
  1027f1:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1027f6:	e9 ec 01 00 00       	jmp    1029e7 <__alltraps>

001027fb <vector215>:
.globl vector215
vector215:
  pushl $0
  1027fb:	6a 00                	push   $0x0
  pushl $215
  1027fd:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102802:	e9 e0 01 00 00       	jmp    1029e7 <__alltraps>

00102807 <vector216>:
.globl vector216
vector216:
  pushl $0
  102807:	6a 00                	push   $0x0
  pushl $216
  102809:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10280e:	e9 d4 01 00 00       	jmp    1029e7 <__alltraps>

00102813 <vector217>:
.globl vector217
vector217:
  pushl $0
  102813:	6a 00                	push   $0x0
  pushl $217
  102815:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10281a:	e9 c8 01 00 00       	jmp    1029e7 <__alltraps>

0010281f <vector218>:
.globl vector218
vector218:
  pushl $0
  10281f:	6a 00                	push   $0x0
  pushl $218
  102821:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102826:	e9 bc 01 00 00       	jmp    1029e7 <__alltraps>

0010282b <vector219>:
.globl vector219
vector219:
  pushl $0
  10282b:	6a 00                	push   $0x0
  pushl $219
  10282d:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102832:	e9 b0 01 00 00       	jmp    1029e7 <__alltraps>

00102837 <vector220>:
.globl vector220
vector220:
  pushl $0
  102837:	6a 00                	push   $0x0
  pushl $220
  102839:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10283e:	e9 a4 01 00 00       	jmp    1029e7 <__alltraps>

00102843 <vector221>:
.globl vector221
vector221:
  pushl $0
  102843:	6a 00                	push   $0x0
  pushl $221
  102845:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10284a:	e9 98 01 00 00       	jmp    1029e7 <__alltraps>

0010284f <vector222>:
.globl vector222
vector222:
  pushl $0
  10284f:	6a 00                	push   $0x0
  pushl $222
  102851:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102856:	e9 8c 01 00 00       	jmp    1029e7 <__alltraps>

0010285b <vector223>:
.globl vector223
vector223:
  pushl $0
  10285b:	6a 00                	push   $0x0
  pushl $223
  10285d:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102862:	e9 80 01 00 00       	jmp    1029e7 <__alltraps>

00102867 <vector224>:
.globl vector224
vector224:
  pushl $0
  102867:	6a 00                	push   $0x0
  pushl $224
  102869:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10286e:	e9 74 01 00 00       	jmp    1029e7 <__alltraps>

00102873 <vector225>:
.globl vector225
vector225:
  pushl $0
  102873:	6a 00                	push   $0x0
  pushl $225
  102875:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10287a:	e9 68 01 00 00       	jmp    1029e7 <__alltraps>

0010287f <vector226>:
.globl vector226
vector226:
  pushl $0
  10287f:	6a 00                	push   $0x0
  pushl $226
  102881:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102886:	e9 5c 01 00 00       	jmp    1029e7 <__alltraps>

0010288b <vector227>:
.globl vector227
vector227:
  pushl $0
  10288b:	6a 00                	push   $0x0
  pushl $227
  10288d:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102892:	e9 50 01 00 00       	jmp    1029e7 <__alltraps>

00102897 <vector228>:
.globl vector228
vector228:
  pushl $0
  102897:	6a 00                	push   $0x0
  pushl $228
  102899:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10289e:	e9 44 01 00 00       	jmp    1029e7 <__alltraps>

001028a3 <vector229>:
.globl vector229
vector229:
  pushl $0
  1028a3:	6a 00                	push   $0x0
  pushl $229
  1028a5:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1028aa:	e9 38 01 00 00       	jmp    1029e7 <__alltraps>

001028af <vector230>:
.globl vector230
vector230:
  pushl $0
  1028af:	6a 00                	push   $0x0
  pushl $230
  1028b1:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1028b6:	e9 2c 01 00 00       	jmp    1029e7 <__alltraps>

001028bb <vector231>:
.globl vector231
vector231:
  pushl $0
  1028bb:	6a 00                	push   $0x0
  pushl $231
  1028bd:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1028c2:	e9 20 01 00 00       	jmp    1029e7 <__alltraps>

001028c7 <vector232>:
.globl vector232
vector232:
  pushl $0
  1028c7:	6a 00                	push   $0x0
  pushl $232
  1028c9:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1028ce:	e9 14 01 00 00       	jmp    1029e7 <__alltraps>

001028d3 <vector233>:
.globl vector233
vector233:
  pushl $0
  1028d3:	6a 00                	push   $0x0
  pushl $233
  1028d5:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1028da:	e9 08 01 00 00       	jmp    1029e7 <__alltraps>

001028df <vector234>:
.globl vector234
vector234:
  pushl $0
  1028df:	6a 00                	push   $0x0
  pushl $234
  1028e1:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1028e6:	e9 fc 00 00 00       	jmp    1029e7 <__alltraps>

001028eb <vector235>:
.globl vector235
vector235:
  pushl $0
  1028eb:	6a 00                	push   $0x0
  pushl $235
  1028ed:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1028f2:	e9 f0 00 00 00       	jmp    1029e7 <__alltraps>

001028f7 <vector236>:
.globl vector236
vector236:
  pushl $0
  1028f7:	6a 00                	push   $0x0
  pushl $236
  1028f9:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1028fe:	e9 e4 00 00 00       	jmp    1029e7 <__alltraps>

00102903 <vector237>:
.globl vector237
vector237:
  pushl $0
  102903:	6a 00                	push   $0x0
  pushl $237
  102905:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10290a:	e9 d8 00 00 00       	jmp    1029e7 <__alltraps>

0010290f <vector238>:
.globl vector238
vector238:
  pushl $0
  10290f:	6a 00                	push   $0x0
  pushl $238
  102911:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102916:	e9 cc 00 00 00       	jmp    1029e7 <__alltraps>

0010291b <vector239>:
.globl vector239
vector239:
  pushl $0
  10291b:	6a 00                	push   $0x0
  pushl $239
  10291d:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102922:	e9 c0 00 00 00       	jmp    1029e7 <__alltraps>

00102927 <vector240>:
.globl vector240
vector240:
  pushl $0
  102927:	6a 00                	push   $0x0
  pushl $240
  102929:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10292e:	e9 b4 00 00 00       	jmp    1029e7 <__alltraps>

00102933 <vector241>:
.globl vector241
vector241:
  pushl $0
  102933:	6a 00                	push   $0x0
  pushl $241
  102935:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10293a:	e9 a8 00 00 00       	jmp    1029e7 <__alltraps>

0010293f <vector242>:
.globl vector242
vector242:
  pushl $0
  10293f:	6a 00                	push   $0x0
  pushl $242
  102941:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102946:	e9 9c 00 00 00       	jmp    1029e7 <__alltraps>

0010294b <vector243>:
.globl vector243
vector243:
  pushl $0
  10294b:	6a 00                	push   $0x0
  pushl $243
  10294d:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102952:	e9 90 00 00 00       	jmp    1029e7 <__alltraps>

00102957 <vector244>:
.globl vector244
vector244:
  pushl $0
  102957:	6a 00                	push   $0x0
  pushl $244
  102959:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10295e:	e9 84 00 00 00       	jmp    1029e7 <__alltraps>

00102963 <vector245>:
.globl vector245
vector245:
  pushl $0
  102963:	6a 00                	push   $0x0
  pushl $245
  102965:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10296a:	e9 78 00 00 00       	jmp    1029e7 <__alltraps>

0010296f <vector246>:
.globl vector246
vector246:
  pushl $0
  10296f:	6a 00                	push   $0x0
  pushl $246
  102971:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102976:	e9 6c 00 00 00       	jmp    1029e7 <__alltraps>

0010297b <vector247>:
.globl vector247
vector247:
  pushl $0
  10297b:	6a 00                	push   $0x0
  pushl $247
  10297d:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102982:	e9 60 00 00 00       	jmp    1029e7 <__alltraps>

00102987 <vector248>:
.globl vector248
vector248:
  pushl $0
  102987:	6a 00                	push   $0x0
  pushl $248
  102989:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10298e:	e9 54 00 00 00       	jmp    1029e7 <__alltraps>

00102993 <vector249>:
.globl vector249
vector249:
  pushl $0
  102993:	6a 00                	push   $0x0
  pushl $249
  102995:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10299a:	e9 48 00 00 00       	jmp    1029e7 <__alltraps>

0010299f <vector250>:
.globl vector250
vector250:
  pushl $0
  10299f:	6a 00                	push   $0x0
  pushl $250
  1029a1:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1029a6:	e9 3c 00 00 00       	jmp    1029e7 <__alltraps>

001029ab <vector251>:
.globl vector251
vector251:
  pushl $0
  1029ab:	6a 00                	push   $0x0
  pushl $251
  1029ad:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1029b2:	e9 30 00 00 00       	jmp    1029e7 <__alltraps>

001029b7 <vector252>:
.globl vector252
vector252:
  pushl $0
  1029b7:	6a 00                	push   $0x0
  pushl $252
  1029b9:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1029be:	e9 24 00 00 00       	jmp    1029e7 <__alltraps>

001029c3 <vector253>:
.globl vector253
vector253:
  pushl $0
  1029c3:	6a 00                	push   $0x0
  pushl $253
  1029c5:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1029ca:	e9 18 00 00 00       	jmp    1029e7 <__alltraps>

001029cf <vector254>:
.globl vector254
vector254:
  pushl $0
  1029cf:	6a 00                	push   $0x0
  pushl $254
  1029d1:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1029d6:	e9 0c 00 00 00       	jmp    1029e7 <__alltraps>

001029db <vector255>:
.globl vector255
vector255:
  pushl $0
  1029db:	6a 00                	push   $0x0
  pushl $255
  1029dd:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1029e2:	e9 00 00 00 00       	jmp    1029e7 <__alltraps>

001029e7 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1029e7:	1e                   	push   %ds
    pushl %es
  1029e8:	06                   	push   %es
    pushl %fs
  1029e9:	0f a0                	push   %fs
    pushl %gs
  1029eb:	0f a8                	push   %gs
    pushal
  1029ed:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  1029ee:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  1029f3:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1029f5:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1029f7:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1029f8:	e8 64 f5 ff ff       	call   101f61 <trap>

    # pop the pushed stack pointer
    popl %esp
  1029fd:	5c                   	pop    %esp

001029fe <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1029fe:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1029ff:	0f a9                	pop    %gs
    popl %fs
  102a01:	0f a1                	pop    %fs
    popl %es
  102a03:	07                   	pop    %es
    popl %ds
  102a04:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102a05:	83 c4 08             	add    $0x8,%esp
    iret
  102a08:	cf                   	iret   

00102a09 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a09:	55                   	push   %ebp
  102a0a:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0f:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a12:	b8 23 00 00 00       	mov    $0x23,%eax
  102a17:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a19:	b8 23 00 00 00       	mov    $0x23,%eax
  102a1e:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a20:	b8 10 00 00 00       	mov    $0x10,%eax
  102a25:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a27:	b8 10 00 00 00       	mov    $0x10,%eax
  102a2c:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a2e:	b8 10 00 00 00       	mov    $0x10,%eax
  102a33:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a35:	ea 3c 2a 10 00 08 00 	ljmp   $0x8,$0x102a3c
}
  102a3c:	90                   	nop
  102a3d:	5d                   	pop    %ebp
  102a3e:	c3                   	ret    

00102a3f <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a3f:	55                   	push   %ebp
  102a40:	89 e5                	mov    %esp,%ebp
  102a42:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102a45:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  102a4a:	05 00 04 00 00       	add    $0x400,%eax
  102a4f:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  102a54:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  102a5b:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102a5d:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  102a64:	68 00 
  102a66:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102a6b:	0f b7 c0             	movzwl %ax,%eax
  102a6e:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  102a74:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102a79:	c1 e8 10             	shr    $0x10,%eax
  102a7c:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  102a81:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a88:	24 f0                	and    $0xf0,%al
  102a8a:	0c 09                	or     $0x9,%al
  102a8c:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102a91:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a98:	0c 10                	or     $0x10,%al
  102a9a:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102a9f:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102aa6:	24 9f                	and    $0x9f,%al
  102aa8:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102aad:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102ab4:	0c 80                	or     $0x80,%al
  102ab6:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102abb:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102ac2:	24 f0                	and    $0xf0,%al
  102ac4:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102ac9:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102ad0:	24 ef                	and    $0xef,%al
  102ad2:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102ad7:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102ade:	24 df                	and    $0xdf,%al
  102ae0:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102ae5:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102aec:	0c 40                	or     $0x40,%al
  102aee:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102af3:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102afa:	24 7f                	and    $0x7f,%al
  102afc:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102b01:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102b06:	c1 e8 18             	shr    $0x18,%eax
  102b09:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102b0e:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102b15:	24 ef                	and    $0xef,%al
  102b17:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102b1c:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  102b23:	e8 e1 fe ff ff       	call   102a09 <lgdt>
  102b28:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102b2e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b32:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b35:	90                   	nop
  102b36:	c9                   	leave  
  102b37:	c3                   	ret    

00102b38 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102b38:	55                   	push   %ebp
  102b39:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102b3b:	e8 ff fe ff ff       	call   102a3f <gdt_init>
}
  102b40:	90                   	nop
  102b41:	5d                   	pop    %ebp
  102b42:	c3                   	ret    

00102b43 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102b43:	55                   	push   %ebp
  102b44:	89 e5                	mov    %esp,%ebp
  102b46:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102b49:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102b50:	eb 03                	jmp    102b55 <strlen+0x12>
        cnt ++;
  102b52:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  102b55:	8b 45 08             	mov    0x8(%ebp),%eax
  102b58:	8d 50 01             	lea    0x1(%eax),%edx
  102b5b:	89 55 08             	mov    %edx,0x8(%ebp)
  102b5e:	0f b6 00             	movzbl (%eax),%eax
  102b61:	84 c0                	test   %al,%al
  102b63:	75 ed                	jne    102b52 <strlen+0xf>
    }
    return cnt;
  102b65:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102b68:	c9                   	leave  
  102b69:	c3                   	ret    

00102b6a <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102b6a:	55                   	push   %ebp
  102b6b:	89 e5                	mov    %esp,%ebp
  102b6d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102b70:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102b77:	eb 03                	jmp    102b7c <strnlen+0x12>
        cnt ++;
  102b79:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102b7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b7f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102b82:	73 10                	jae    102b94 <strnlen+0x2a>
  102b84:	8b 45 08             	mov    0x8(%ebp),%eax
  102b87:	8d 50 01             	lea    0x1(%eax),%edx
  102b8a:	89 55 08             	mov    %edx,0x8(%ebp)
  102b8d:	0f b6 00             	movzbl (%eax),%eax
  102b90:	84 c0                	test   %al,%al
  102b92:	75 e5                	jne    102b79 <strnlen+0xf>
    }
    return cnt;
  102b94:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102b97:	c9                   	leave  
  102b98:	c3                   	ret    

00102b99 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102b99:	55                   	push   %ebp
  102b9a:	89 e5                	mov    %esp,%ebp
  102b9c:	57                   	push   %edi
  102b9d:	56                   	push   %esi
  102b9e:	83 ec 20             	sub    $0x20,%esp
  102ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102baa:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bb3:	89 d1                	mov    %edx,%ecx
  102bb5:	89 c2                	mov    %eax,%edx
  102bb7:	89 ce                	mov    %ecx,%esi
  102bb9:	89 d7                	mov    %edx,%edi
  102bbb:	ac                   	lods   %ds:(%esi),%al
  102bbc:	aa                   	stos   %al,%es:(%edi)
  102bbd:	84 c0                	test   %al,%al
  102bbf:	75 fa                	jne    102bbb <strcpy+0x22>
  102bc1:	89 fa                	mov    %edi,%edx
  102bc3:	89 f1                	mov    %esi,%ecx
  102bc5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102bc8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102bcb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  102bd1:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102bd2:	83 c4 20             	add    $0x20,%esp
  102bd5:	5e                   	pop    %esi
  102bd6:	5f                   	pop    %edi
  102bd7:	5d                   	pop    %ebp
  102bd8:	c3                   	ret    

00102bd9 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102bd9:	55                   	push   %ebp
  102bda:	89 e5                	mov    %esp,%ebp
  102bdc:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  102be2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102be5:	eb 1e                	jmp    102c05 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  102be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bea:	0f b6 10             	movzbl (%eax),%edx
  102bed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102bf0:	88 10                	mov    %dl,(%eax)
  102bf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102bf5:	0f b6 00             	movzbl (%eax),%eax
  102bf8:	84 c0                	test   %al,%al
  102bfa:	74 03                	je     102bff <strncpy+0x26>
            src ++;
  102bfc:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  102bff:	ff 45 fc             	incl   -0x4(%ebp)
  102c02:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  102c05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102c09:	75 dc                	jne    102be7 <strncpy+0xe>
    }
    return dst;
  102c0b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102c0e:	c9                   	leave  
  102c0f:	c3                   	ret    

00102c10 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102c10:	55                   	push   %ebp
  102c11:	89 e5                	mov    %esp,%ebp
  102c13:	57                   	push   %edi
  102c14:	56                   	push   %esi
  102c15:	83 ec 20             	sub    $0x20,%esp
  102c18:	8b 45 08             	mov    0x8(%ebp),%eax
  102c1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c21:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  102c24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102c2a:	89 d1                	mov    %edx,%ecx
  102c2c:	89 c2                	mov    %eax,%edx
  102c2e:	89 ce                	mov    %ecx,%esi
  102c30:	89 d7                	mov    %edx,%edi
  102c32:	ac                   	lods   %ds:(%esi),%al
  102c33:	ae                   	scas   %es:(%edi),%al
  102c34:	75 08                	jne    102c3e <strcmp+0x2e>
  102c36:	84 c0                	test   %al,%al
  102c38:	75 f8                	jne    102c32 <strcmp+0x22>
  102c3a:	31 c0                	xor    %eax,%eax
  102c3c:	eb 04                	jmp    102c42 <strcmp+0x32>
  102c3e:	19 c0                	sbb    %eax,%eax
  102c40:	0c 01                	or     $0x1,%al
  102c42:	89 fa                	mov    %edi,%edx
  102c44:	89 f1                	mov    %esi,%ecx
  102c46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102c49:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102c4c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  102c4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102c52:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102c53:	83 c4 20             	add    $0x20,%esp
  102c56:	5e                   	pop    %esi
  102c57:	5f                   	pop    %edi
  102c58:	5d                   	pop    %ebp
  102c59:	c3                   	ret    

00102c5a <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102c5a:	55                   	push   %ebp
  102c5b:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102c5d:	eb 09                	jmp    102c68 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  102c5f:	ff 4d 10             	decl   0x10(%ebp)
  102c62:	ff 45 08             	incl   0x8(%ebp)
  102c65:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102c68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102c6c:	74 1a                	je     102c88 <strncmp+0x2e>
  102c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  102c71:	0f b6 00             	movzbl (%eax),%eax
  102c74:	84 c0                	test   %al,%al
  102c76:	74 10                	je     102c88 <strncmp+0x2e>
  102c78:	8b 45 08             	mov    0x8(%ebp),%eax
  102c7b:	0f b6 10             	movzbl (%eax),%edx
  102c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c81:	0f b6 00             	movzbl (%eax),%eax
  102c84:	38 c2                	cmp    %al,%dl
  102c86:	74 d7                	je     102c5f <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102c88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102c8c:	74 18                	je     102ca6 <strncmp+0x4c>
  102c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  102c91:	0f b6 00             	movzbl (%eax),%eax
  102c94:	0f b6 d0             	movzbl %al,%edx
  102c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c9a:	0f b6 00             	movzbl (%eax),%eax
  102c9d:	0f b6 c0             	movzbl %al,%eax
  102ca0:	29 c2                	sub    %eax,%edx
  102ca2:	89 d0                	mov    %edx,%eax
  102ca4:	eb 05                	jmp    102cab <strncmp+0x51>
  102ca6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102cab:	5d                   	pop    %ebp
  102cac:	c3                   	ret    

00102cad <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102cad:	55                   	push   %ebp
  102cae:	89 e5                	mov    %esp,%ebp
  102cb0:	83 ec 04             	sub    $0x4,%esp
  102cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cb6:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102cb9:	eb 13                	jmp    102cce <strchr+0x21>
        if (*s == c) {
  102cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  102cbe:	0f b6 00             	movzbl (%eax),%eax
  102cc1:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102cc4:	75 05                	jne    102ccb <strchr+0x1e>
            return (char *)s;
  102cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  102cc9:	eb 12                	jmp    102cdd <strchr+0x30>
        }
        s ++;
  102ccb:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  102cce:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd1:	0f b6 00             	movzbl (%eax),%eax
  102cd4:	84 c0                	test   %al,%al
  102cd6:	75 e3                	jne    102cbb <strchr+0xe>
    }
    return NULL;
  102cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102cdd:	c9                   	leave  
  102cde:	c3                   	ret    

00102cdf <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102cdf:	55                   	push   %ebp
  102ce0:	89 e5                	mov    %esp,%ebp
  102ce2:	83 ec 04             	sub    $0x4,%esp
  102ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ce8:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102ceb:	eb 0e                	jmp    102cfb <strfind+0x1c>
        if (*s == c) {
  102ced:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf0:	0f b6 00             	movzbl (%eax),%eax
  102cf3:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102cf6:	74 0f                	je     102d07 <strfind+0x28>
            break;
        }
        s ++;
  102cf8:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  102cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  102cfe:	0f b6 00             	movzbl (%eax),%eax
  102d01:	84 c0                	test   %al,%al
  102d03:	75 e8                	jne    102ced <strfind+0xe>
  102d05:	eb 01                	jmp    102d08 <strfind+0x29>
            break;
  102d07:	90                   	nop
    }
    return (char *)s;
  102d08:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102d0b:	c9                   	leave  
  102d0c:	c3                   	ret    

00102d0d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102d0d:	55                   	push   %ebp
  102d0e:	89 e5                	mov    %esp,%ebp
  102d10:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102d13:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102d1a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102d21:	eb 03                	jmp    102d26 <strtol+0x19>
        s ++;
  102d23:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  102d26:	8b 45 08             	mov    0x8(%ebp),%eax
  102d29:	0f b6 00             	movzbl (%eax),%eax
  102d2c:	3c 20                	cmp    $0x20,%al
  102d2e:	74 f3                	je     102d23 <strtol+0x16>
  102d30:	8b 45 08             	mov    0x8(%ebp),%eax
  102d33:	0f b6 00             	movzbl (%eax),%eax
  102d36:	3c 09                	cmp    $0x9,%al
  102d38:	74 e9                	je     102d23 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  102d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  102d3d:	0f b6 00             	movzbl (%eax),%eax
  102d40:	3c 2b                	cmp    $0x2b,%al
  102d42:	75 05                	jne    102d49 <strtol+0x3c>
        s ++;
  102d44:	ff 45 08             	incl   0x8(%ebp)
  102d47:	eb 14                	jmp    102d5d <strtol+0x50>
    }
    else if (*s == '-') {
  102d49:	8b 45 08             	mov    0x8(%ebp),%eax
  102d4c:	0f b6 00             	movzbl (%eax),%eax
  102d4f:	3c 2d                	cmp    $0x2d,%al
  102d51:	75 0a                	jne    102d5d <strtol+0x50>
        s ++, neg = 1;
  102d53:	ff 45 08             	incl   0x8(%ebp)
  102d56:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102d5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102d61:	74 06                	je     102d69 <strtol+0x5c>
  102d63:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102d67:	75 22                	jne    102d8b <strtol+0x7e>
  102d69:	8b 45 08             	mov    0x8(%ebp),%eax
  102d6c:	0f b6 00             	movzbl (%eax),%eax
  102d6f:	3c 30                	cmp    $0x30,%al
  102d71:	75 18                	jne    102d8b <strtol+0x7e>
  102d73:	8b 45 08             	mov    0x8(%ebp),%eax
  102d76:	40                   	inc    %eax
  102d77:	0f b6 00             	movzbl (%eax),%eax
  102d7a:	3c 78                	cmp    $0x78,%al
  102d7c:	75 0d                	jne    102d8b <strtol+0x7e>
        s += 2, base = 16;
  102d7e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102d82:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102d89:	eb 29                	jmp    102db4 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  102d8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102d8f:	75 16                	jne    102da7 <strtol+0x9a>
  102d91:	8b 45 08             	mov    0x8(%ebp),%eax
  102d94:	0f b6 00             	movzbl (%eax),%eax
  102d97:	3c 30                	cmp    $0x30,%al
  102d99:	75 0c                	jne    102da7 <strtol+0x9a>
        s ++, base = 8;
  102d9b:	ff 45 08             	incl   0x8(%ebp)
  102d9e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102da5:	eb 0d                	jmp    102db4 <strtol+0xa7>
    }
    else if (base == 0) {
  102da7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102dab:	75 07                	jne    102db4 <strtol+0xa7>
        base = 10;
  102dad:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102db4:	8b 45 08             	mov    0x8(%ebp),%eax
  102db7:	0f b6 00             	movzbl (%eax),%eax
  102dba:	3c 2f                	cmp    $0x2f,%al
  102dbc:	7e 1b                	jle    102dd9 <strtol+0xcc>
  102dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  102dc1:	0f b6 00             	movzbl (%eax),%eax
  102dc4:	3c 39                	cmp    $0x39,%al
  102dc6:	7f 11                	jg     102dd9 <strtol+0xcc>
            dig = *s - '0';
  102dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  102dcb:	0f b6 00             	movzbl (%eax),%eax
  102dce:	0f be c0             	movsbl %al,%eax
  102dd1:	83 e8 30             	sub    $0x30,%eax
  102dd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102dd7:	eb 48                	jmp    102e21 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  102ddc:	0f b6 00             	movzbl (%eax),%eax
  102ddf:	3c 60                	cmp    $0x60,%al
  102de1:	7e 1b                	jle    102dfe <strtol+0xf1>
  102de3:	8b 45 08             	mov    0x8(%ebp),%eax
  102de6:	0f b6 00             	movzbl (%eax),%eax
  102de9:	3c 7a                	cmp    $0x7a,%al
  102deb:	7f 11                	jg     102dfe <strtol+0xf1>
            dig = *s - 'a' + 10;
  102ded:	8b 45 08             	mov    0x8(%ebp),%eax
  102df0:	0f b6 00             	movzbl (%eax),%eax
  102df3:	0f be c0             	movsbl %al,%eax
  102df6:	83 e8 57             	sub    $0x57,%eax
  102df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102dfc:	eb 23                	jmp    102e21 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  102e01:	0f b6 00             	movzbl (%eax),%eax
  102e04:	3c 40                	cmp    $0x40,%al
  102e06:	7e 3b                	jle    102e43 <strtol+0x136>
  102e08:	8b 45 08             	mov    0x8(%ebp),%eax
  102e0b:	0f b6 00             	movzbl (%eax),%eax
  102e0e:	3c 5a                	cmp    $0x5a,%al
  102e10:	7f 31                	jg     102e43 <strtol+0x136>
            dig = *s - 'A' + 10;
  102e12:	8b 45 08             	mov    0x8(%ebp),%eax
  102e15:	0f b6 00             	movzbl (%eax),%eax
  102e18:	0f be c0             	movsbl %al,%eax
  102e1b:	83 e8 37             	sub    $0x37,%eax
  102e1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e24:	3b 45 10             	cmp    0x10(%ebp),%eax
  102e27:	7d 19                	jge    102e42 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  102e29:	ff 45 08             	incl   0x8(%ebp)
  102e2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  102e33:	89 c2                	mov    %eax,%edx
  102e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e38:	01 d0                	add    %edx,%eax
  102e3a:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  102e3d:	e9 72 ff ff ff       	jmp    102db4 <strtol+0xa7>
            break;
  102e42:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  102e43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102e47:	74 08                	je     102e51 <strtol+0x144>
        *endptr = (char *) s;
  102e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  102e4f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102e51:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102e55:	74 07                	je     102e5e <strtol+0x151>
  102e57:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e5a:	f7 d8                	neg    %eax
  102e5c:	eb 03                	jmp    102e61 <strtol+0x154>
  102e5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102e61:	c9                   	leave  
  102e62:	c3                   	ret    

00102e63 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102e63:	55                   	push   %ebp
  102e64:	89 e5                	mov    %esp,%ebp
  102e66:	57                   	push   %edi
  102e67:	83 ec 24             	sub    $0x24,%esp
  102e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e6d:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102e70:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102e74:	8b 55 08             	mov    0x8(%ebp),%edx
  102e77:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102e7a:	88 45 f7             	mov    %al,-0x9(%ebp)
  102e7d:	8b 45 10             	mov    0x10(%ebp),%eax
  102e80:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102e83:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102e86:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102e8a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102e8d:	89 d7                	mov    %edx,%edi
  102e8f:	f3 aa                	rep stos %al,%es:(%edi)
  102e91:	89 fa                	mov    %edi,%edx
  102e93:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102e96:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102e99:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e9c:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102e9d:	83 c4 24             	add    $0x24,%esp
  102ea0:	5f                   	pop    %edi
  102ea1:	5d                   	pop    %ebp
  102ea2:	c3                   	ret    

00102ea3 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102ea3:	55                   	push   %ebp
  102ea4:	89 e5                	mov    %esp,%ebp
  102ea6:	57                   	push   %edi
  102ea7:	56                   	push   %esi
  102ea8:	53                   	push   %ebx
  102ea9:	83 ec 30             	sub    $0x30,%esp
  102eac:	8b 45 08             	mov    0x8(%ebp),%eax
  102eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102eb8:	8b 45 10             	mov    0x10(%ebp),%eax
  102ebb:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ec1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102ec4:	73 42                	jae    102f08 <memmove+0x65>
  102ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ec9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ecf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102ed2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ed5:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102ed8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102edb:	c1 e8 02             	shr    $0x2,%eax
  102ede:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102ee0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ee6:	89 d7                	mov    %edx,%edi
  102ee8:	89 c6                	mov    %eax,%esi
  102eea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102eec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102eef:	83 e1 03             	and    $0x3,%ecx
  102ef2:	74 02                	je     102ef6 <memmove+0x53>
  102ef4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102ef6:	89 f0                	mov    %esi,%eax
  102ef8:	89 fa                	mov    %edi,%edx
  102efa:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102efd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102f00:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  102f03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  102f06:	eb 36                	jmp    102f3e <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102f08:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f0b:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f11:	01 c2                	add    %eax,%edx
  102f13:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f16:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f1c:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  102f1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f22:	89 c1                	mov    %eax,%ecx
  102f24:	89 d8                	mov    %ebx,%eax
  102f26:	89 d6                	mov    %edx,%esi
  102f28:	89 c7                	mov    %eax,%edi
  102f2a:	fd                   	std    
  102f2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102f2d:	fc                   	cld    
  102f2e:	89 f8                	mov    %edi,%eax
  102f30:	89 f2                	mov    %esi,%edx
  102f32:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102f35:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102f38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  102f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102f3e:	83 c4 30             	add    $0x30,%esp
  102f41:	5b                   	pop    %ebx
  102f42:	5e                   	pop    %esi
  102f43:	5f                   	pop    %edi
  102f44:	5d                   	pop    %ebp
  102f45:	c3                   	ret    

00102f46 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102f46:	55                   	push   %ebp
  102f47:	89 e5                	mov    %esp,%ebp
  102f49:	57                   	push   %edi
  102f4a:	56                   	push   %esi
  102f4b:	83 ec 20             	sub    $0x20,%esp
  102f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f5a:	8b 45 10             	mov    0x10(%ebp),%eax
  102f5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102f60:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f63:	c1 e8 02             	shr    $0x2,%eax
  102f66:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102f68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f6e:	89 d7                	mov    %edx,%edi
  102f70:	89 c6                	mov    %eax,%esi
  102f72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102f74:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102f77:	83 e1 03             	and    $0x3,%ecx
  102f7a:	74 02                	je     102f7e <memcpy+0x38>
  102f7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102f7e:	89 f0                	mov    %esi,%eax
  102f80:	89 fa                	mov    %edi,%edx
  102f82:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102f85:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102f88:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  102f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  102f8e:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102f8f:	83 c4 20             	add    $0x20,%esp
  102f92:	5e                   	pop    %esi
  102f93:	5f                   	pop    %edi
  102f94:	5d                   	pop    %ebp
  102f95:	c3                   	ret    

00102f96 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102f96:	55                   	push   %ebp
  102f97:	89 e5                	mov    %esp,%ebp
  102f99:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  102f9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fa5:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102fa8:	eb 2e                	jmp    102fd8 <memcmp+0x42>
        if (*s1 != *s2) {
  102faa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102fad:	0f b6 10             	movzbl (%eax),%edx
  102fb0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102fb3:	0f b6 00             	movzbl (%eax),%eax
  102fb6:	38 c2                	cmp    %al,%dl
  102fb8:	74 18                	je     102fd2 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102fba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102fbd:	0f b6 00             	movzbl (%eax),%eax
  102fc0:	0f b6 d0             	movzbl %al,%edx
  102fc3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102fc6:	0f b6 00             	movzbl (%eax),%eax
  102fc9:	0f b6 c0             	movzbl %al,%eax
  102fcc:	29 c2                	sub    %eax,%edx
  102fce:	89 d0                	mov    %edx,%eax
  102fd0:	eb 18                	jmp    102fea <memcmp+0x54>
        }
        s1 ++, s2 ++;
  102fd2:	ff 45 fc             	incl   -0x4(%ebp)
  102fd5:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  102fd8:	8b 45 10             	mov    0x10(%ebp),%eax
  102fdb:	8d 50 ff             	lea    -0x1(%eax),%edx
  102fde:	89 55 10             	mov    %edx,0x10(%ebp)
  102fe1:	85 c0                	test   %eax,%eax
  102fe3:	75 c5                	jne    102faa <memcmp+0x14>
    }
    return 0;
  102fe5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102fea:	c9                   	leave  
  102feb:	c3                   	ret    

00102fec <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102fec:	55                   	push   %ebp
  102fed:	89 e5                	mov    %esp,%ebp
  102fef:	83 ec 58             	sub    $0x58,%esp
  102ff2:	8b 45 10             	mov    0x10(%ebp),%eax
  102ff5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  102ffb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102ffe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103001:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103004:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103007:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  10300a:	8b 45 18             	mov    0x18(%ebp),%eax
  10300d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103010:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103013:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103016:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103019:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10301c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10301f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103022:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103026:	74 1c                	je     103044 <printnum+0x58>
  103028:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10302b:	ba 00 00 00 00       	mov    $0x0,%edx
  103030:	f7 75 e4             	divl   -0x1c(%ebp)
  103033:	89 55 f4             	mov    %edx,-0xc(%ebp)
  103036:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103039:	ba 00 00 00 00       	mov    $0x0,%edx
  10303e:	f7 75 e4             	divl   -0x1c(%ebp)
  103041:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103044:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103047:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10304a:	f7 75 e4             	divl   -0x1c(%ebp)
  10304d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103050:	89 55 dc             	mov    %edx,-0x24(%ebp)
  103053:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103056:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103059:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10305c:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10305f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103062:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  103065:	8b 45 18             	mov    0x18(%ebp),%eax
  103068:	ba 00 00 00 00       	mov    $0x0,%edx
  10306d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  103070:	72 56                	jb     1030c8 <printnum+0xdc>
  103072:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  103075:	77 05                	ja     10307c <printnum+0x90>
  103077:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  10307a:	72 4c                	jb     1030c8 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  10307c:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10307f:	8d 50 ff             	lea    -0x1(%eax),%edx
  103082:	8b 45 20             	mov    0x20(%ebp),%eax
  103085:	89 44 24 18          	mov    %eax,0x18(%esp)
  103089:	89 54 24 14          	mov    %edx,0x14(%esp)
  10308d:	8b 45 18             	mov    0x18(%ebp),%eax
  103090:	89 44 24 10          	mov    %eax,0x10(%esp)
  103094:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103097:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10309a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10309e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1030a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ac:	89 04 24             	mov    %eax,(%esp)
  1030af:	e8 38 ff ff ff       	call   102fec <printnum>
  1030b4:	eb 1b                	jmp    1030d1 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1030b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030bd:	8b 45 20             	mov    0x20(%ebp),%eax
  1030c0:	89 04 24             	mov    %eax,(%esp)
  1030c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1030c6:	ff d0                	call   *%eax
        while (-- width > 0)
  1030c8:	ff 4d 1c             	decl   0x1c(%ebp)
  1030cb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1030cf:	7f e5                	jg     1030b6 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1030d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1030d4:	05 30 3e 10 00       	add    $0x103e30,%eax
  1030d9:	0f b6 00             	movzbl (%eax),%eax
  1030dc:	0f be c0             	movsbl %al,%eax
  1030df:	8b 55 0c             	mov    0xc(%ebp),%edx
  1030e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1030e6:	89 04 24             	mov    %eax,(%esp)
  1030e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ec:	ff d0                	call   *%eax
}
  1030ee:	90                   	nop
  1030ef:	c9                   	leave  
  1030f0:	c3                   	ret    

001030f1 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1030f1:	55                   	push   %ebp
  1030f2:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1030f4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1030f8:	7e 14                	jle    10310e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1030fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1030fd:	8b 00                	mov    (%eax),%eax
  1030ff:	8d 48 08             	lea    0x8(%eax),%ecx
  103102:	8b 55 08             	mov    0x8(%ebp),%edx
  103105:	89 0a                	mov    %ecx,(%edx)
  103107:	8b 50 04             	mov    0x4(%eax),%edx
  10310a:	8b 00                	mov    (%eax),%eax
  10310c:	eb 30                	jmp    10313e <getuint+0x4d>
    }
    else if (lflag) {
  10310e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103112:	74 16                	je     10312a <getuint+0x39>
        return va_arg(*ap, unsigned long);
  103114:	8b 45 08             	mov    0x8(%ebp),%eax
  103117:	8b 00                	mov    (%eax),%eax
  103119:	8d 48 04             	lea    0x4(%eax),%ecx
  10311c:	8b 55 08             	mov    0x8(%ebp),%edx
  10311f:	89 0a                	mov    %ecx,(%edx)
  103121:	8b 00                	mov    (%eax),%eax
  103123:	ba 00 00 00 00       	mov    $0x0,%edx
  103128:	eb 14                	jmp    10313e <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10312a:	8b 45 08             	mov    0x8(%ebp),%eax
  10312d:	8b 00                	mov    (%eax),%eax
  10312f:	8d 48 04             	lea    0x4(%eax),%ecx
  103132:	8b 55 08             	mov    0x8(%ebp),%edx
  103135:	89 0a                	mov    %ecx,(%edx)
  103137:	8b 00                	mov    (%eax),%eax
  103139:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10313e:	5d                   	pop    %ebp
  10313f:	c3                   	ret    

00103140 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  103140:	55                   	push   %ebp
  103141:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103143:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103147:	7e 14                	jle    10315d <getint+0x1d>
        return va_arg(*ap, long long);
  103149:	8b 45 08             	mov    0x8(%ebp),%eax
  10314c:	8b 00                	mov    (%eax),%eax
  10314e:	8d 48 08             	lea    0x8(%eax),%ecx
  103151:	8b 55 08             	mov    0x8(%ebp),%edx
  103154:	89 0a                	mov    %ecx,(%edx)
  103156:	8b 50 04             	mov    0x4(%eax),%edx
  103159:	8b 00                	mov    (%eax),%eax
  10315b:	eb 28                	jmp    103185 <getint+0x45>
    }
    else if (lflag) {
  10315d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103161:	74 12                	je     103175 <getint+0x35>
        return va_arg(*ap, long);
  103163:	8b 45 08             	mov    0x8(%ebp),%eax
  103166:	8b 00                	mov    (%eax),%eax
  103168:	8d 48 04             	lea    0x4(%eax),%ecx
  10316b:	8b 55 08             	mov    0x8(%ebp),%edx
  10316e:	89 0a                	mov    %ecx,(%edx)
  103170:	8b 00                	mov    (%eax),%eax
  103172:	99                   	cltd   
  103173:	eb 10                	jmp    103185 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  103175:	8b 45 08             	mov    0x8(%ebp),%eax
  103178:	8b 00                	mov    (%eax),%eax
  10317a:	8d 48 04             	lea    0x4(%eax),%ecx
  10317d:	8b 55 08             	mov    0x8(%ebp),%edx
  103180:	89 0a                	mov    %ecx,(%edx)
  103182:	8b 00                	mov    (%eax),%eax
  103184:	99                   	cltd   
    }
}
  103185:	5d                   	pop    %ebp
  103186:	c3                   	ret    

00103187 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  103187:	55                   	push   %ebp
  103188:	89 e5                	mov    %esp,%ebp
  10318a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  10318d:	8d 45 14             	lea    0x14(%ebp),%eax
  103190:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  103193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10319a:	8b 45 10             	mov    0x10(%ebp),%eax
  10319d:	89 44 24 08          	mov    %eax,0x8(%esp)
  1031a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1031ab:	89 04 24             	mov    %eax,(%esp)
  1031ae:	e8 03 00 00 00       	call   1031b6 <vprintfmt>
    va_end(ap);
}
  1031b3:	90                   	nop
  1031b4:	c9                   	leave  
  1031b5:	c3                   	ret    

001031b6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1031b6:	55                   	push   %ebp
  1031b7:	89 e5                	mov    %esp,%ebp
  1031b9:	56                   	push   %esi
  1031ba:	53                   	push   %ebx
  1031bb:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1031be:	eb 17                	jmp    1031d7 <vprintfmt+0x21>
            if (ch == '\0') {
  1031c0:	85 db                	test   %ebx,%ebx
  1031c2:	0f 84 bf 03 00 00    	je     103587 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1031c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031cf:	89 1c 24             	mov    %ebx,(%esp)
  1031d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1031d5:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1031d7:	8b 45 10             	mov    0x10(%ebp),%eax
  1031da:	8d 50 01             	lea    0x1(%eax),%edx
  1031dd:	89 55 10             	mov    %edx,0x10(%ebp)
  1031e0:	0f b6 00             	movzbl (%eax),%eax
  1031e3:	0f b6 d8             	movzbl %al,%ebx
  1031e6:	83 fb 25             	cmp    $0x25,%ebx
  1031e9:	75 d5                	jne    1031c0 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  1031eb:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1031ef:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1031f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1031f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1031fc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103203:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103206:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  103209:	8b 45 10             	mov    0x10(%ebp),%eax
  10320c:	8d 50 01             	lea    0x1(%eax),%edx
  10320f:	89 55 10             	mov    %edx,0x10(%ebp)
  103212:	0f b6 00             	movzbl (%eax),%eax
  103215:	0f b6 d8             	movzbl %al,%ebx
  103218:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10321b:	83 f8 55             	cmp    $0x55,%eax
  10321e:	0f 87 37 03 00 00    	ja     10355b <vprintfmt+0x3a5>
  103224:	8b 04 85 54 3e 10 00 	mov    0x103e54(,%eax,4),%eax
  10322b:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10322d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103231:	eb d6                	jmp    103209 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  103233:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  103237:	eb d0                	jmp    103209 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103239:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  103240:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103243:	89 d0                	mov    %edx,%eax
  103245:	c1 e0 02             	shl    $0x2,%eax
  103248:	01 d0                	add    %edx,%eax
  10324a:	01 c0                	add    %eax,%eax
  10324c:	01 d8                	add    %ebx,%eax
  10324e:	83 e8 30             	sub    $0x30,%eax
  103251:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  103254:	8b 45 10             	mov    0x10(%ebp),%eax
  103257:	0f b6 00             	movzbl (%eax),%eax
  10325a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10325d:	83 fb 2f             	cmp    $0x2f,%ebx
  103260:	7e 38                	jle    10329a <vprintfmt+0xe4>
  103262:	83 fb 39             	cmp    $0x39,%ebx
  103265:	7f 33                	jg     10329a <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  103267:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  10326a:	eb d4                	jmp    103240 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  10326c:	8b 45 14             	mov    0x14(%ebp),%eax
  10326f:	8d 50 04             	lea    0x4(%eax),%edx
  103272:	89 55 14             	mov    %edx,0x14(%ebp)
  103275:	8b 00                	mov    (%eax),%eax
  103277:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  10327a:	eb 1f                	jmp    10329b <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  10327c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103280:	79 87                	jns    103209 <vprintfmt+0x53>
                width = 0;
  103282:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  103289:	e9 7b ff ff ff       	jmp    103209 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  10328e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  103295:	e9 6f ff ff ff       	jmp    103209 <vprintfmt+0x53>
            goto process_precision;
  10329a:	90                   	nop

        process_precision:
            if (width < 0)
  10329b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10329f:	0f 89 64 ff ff ff    	jns    103209 <vprintfmt+0x53>
                width = precision, precision = -1;
  1032a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032ab:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1032b2:	e9 52 ff ff ff       	jmp    103209 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1032b7:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1032ba:	e9 4a ff ff ff       	jmp    103209 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1032bf:	8b 45 14             	mov    0x14(%ebp),%eax
  1032c2:	8d 50 04             	lea    0x4(%eax),%edx
  1032c5:	89 55 14             	mov    %edx,0x14(%ebp)
  1032c8:	8b 00                	mov    (%eax),%eax
  1032ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  1032cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  1032d1:	89 04 24             	mov    %eax,(%esp)
  1032d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1032d7:	ff d0                	call   *%eax
            break;
  1032d9:	e9 a4 02 00 00       	jmp    103582 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1032de:	8b 45 14             	mov    0x14(%ebp),%eax
  1032e1:	8d 50 04             	lea    0x4(%eax),%edx
  1032e4:	89 55 14             	mov    %edx,0x14(%ebp)
  1032e7:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1032e9:	85 db                	test   %ebx,%ebx
  1032eb:	79 02                	jns    1032ef <vprintfmt+0x139>
                err = -err;
  1032ed:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1032ef:	83 fb 06             	cmp    $0x6,%ebx
  1032f2:	7f 0b                	jg     1032ff <vprintfmt+0x149>
  1032f4:	8b 34 9d 14 3e 10 00 	mov    0x103e14(,%ebx,4),%esi
  1032fb:	85 f6                	test   %esi,%esi
  1032fd:	75 23                	jne    103322 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  1032ff:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103303:	c7 44 24 08 41 3e 10 	movl   $0x103e41,0x8(%esp)
  10330a:	00 
  10330b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10330e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103312:	8b 45 08             	mov    0x8(%ebp),%eax
  103315:	89 04 24             	mov    %eax,(%esp)
  103318:	e8 6a fe ff ff       	call   103187 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10331d:	e9 60 02 00 00       	jmp    103582 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  103322:	89 74 24 0c          	mov    %esi,0xc(%esp)
  103326:	c7 44 24 08 4a 3e 10 	movl   $0x103e4a,0x8(%esp)
  10332d:	00 
  10332e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103331:	89 44 24 04          	mov    %eax,0x4(%esp)
  103335:	8b 45 08             	mov    0x8(%ebp),%eax
  103338:	89 04 24             	mov    %eax,(%esp)
  10333b:	e8 47 fe ff ff       	call   103187 <printfmt>
            break;
  103340:	e9 3d 02 00 00       	jmp    103582 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103345:	8b 45 14             	mov    0x14(%ebp),%eax
  103348:	8d 50 04             	lea    0x4(%eax),%edx
  10334b:	89 55 14             	mov    %edx,0x14(%ebp)
  10334e:	8b 30                	mov    (%eax),%esi
  103350:	85 f6                	test   %esi,%esi
  103352:	75 05                	jne    103359 <vprintfmt+0x1a3>
                p = "(null)";
  103354:	be 4d 3e 10 00       	mov    $0x103e4d,%esi
            }
            if (width > 0 && padc != '-') {
  103359:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10335d:	7e 76                	jle    1033d5 <vprintfmt+0x21f>
  10335f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  103363:	74 70                	je     1033d5 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  103365:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103368:	89 44 24 04          	mov    %eax,0x4(%esp)
  10336c:	89 34 24             	mov    %esi,(%esp)
  10336f:	e8 f6 f7 ff ff       	call   102b6a <strnlen>
  103374:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103377:	29 c2                	sub    %eax,%edx
  103379:	89 d0                	mov    %edx,%eax
  10337b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10337e:	eb 16                	jmp    103396 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  103380:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  103384:	8b 55 0c             	mov    0xc(%ebp),%edx
  103387:	89 54 24 04          	mov    %edx,0x4(%esp)
  10338b:	89 04 24             	mov    %eax,(%esp)
  10338e:	8b 45 08             	mov    0x8(%ebp),%eax
  103391:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  103393:	ff 4d e8             	decl   -0x18(%ebp)
  103396:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10339a:	7f e4                	jg     103380 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10339c:	eb 37                	jmp    1033d5 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  10339e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1033a2:	74 1f                	je     1033c3 <vprintfmt+0x20d>
  1033a4:	83 fb 1f             	cmp    $0x1f,%ebx
  1033a7:	7e 05                	jle    1033ae <vprintfmt+0x1f8>
  1033a9:	83 fb 7e             	cmp    $0x7e,%ebx
  1033ac:	7e 15                	jle    1033c3 <vprintfmt+0x20d>
                    putch('?', putdat);
  1033ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033b5:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1033bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1033bf:	ff d0                	call   *%eax
  1033c1:	eb 0f                	jmp    1033d2 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  1033c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033ca:	89 1c 24             	mov    %ebx,(%esp)
  1033cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1033d0:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1033d2:	ff 4d e8             	decl   -0x18(%ebp)
  1033d5:	89 f0                	mov    %esi,%eax
  1033d7:	8d 70 01             	lea    0x1(%eax),%esi
  1033da:	0f b6 00             	movzbl (%eax),%eax
  1033dd:	0f be d8             	movsbl %al,%ebx
  1033e0:	85 db                	test   %ebx,%ebx
  1033e2:	74 27                	je     10340b <vprintfmt+0x255>
  1033e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1033e8:	78 b4                	js     10339e <vprintfmt+0x1e8>
  1033ea:	ff 4d e4             	decl   -0x1c(%ebp)
  1033ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1033f1:	79 ab                	jns    10339e <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  1033f3:	eb 16                	jmp    10340b <vprintfmt+0x255>
                putch(' ', putdat);
  1033f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033fc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103403:	8b 45 08             	mov    0x8(%ebp),%eax
  103406:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  103408:	ff 4d e8             	decl   -0x18(%ebp)
  10340b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10340f:	7f e4                	jg     1033f5 <vprintfmt+0x23f>
            }
            break;
  103411:	e9 6c 01 00 00       	jmp    103582 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  103416:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103419:	89 44 24 04          	mov    %eax,0x4(%esp)
  10341d:	8d 45 14             	lea    0x14(%ebp),%eax
  103420:	89 04 24             	mov    %eax,(%esp)
  103423:	e8 18 fd ff ff       	call   103140 <getint>
  103428:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10342b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  10342e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103431:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103434:	85 d2                	test   %edx,%edx
  103436:	79 26                	jns    10345e <vprintfmt+0x2a8>
                putch('-', putdat);
  103438:	8b 45 0c             	mov    0xc(%ebp),%eax
  10343b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10343f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  103446:	8b 45 08             	mov    0x8(%ebp),%eax
  103449:	ff d0                	call   *%eax
                num = -(long long)num;
  10344b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10344e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103451:	f7 d8                	neg    %eax
  103453:	83 d2 00             	adc    $0x0,%edx
  103456:	f7 da                	neg    %edx
  103458:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10345b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10345e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103465:	e9 a8 00 00 00       	jmp    103512 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  10346a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10346d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103471:	8d 45 14             	lea    0x14(%ebp),%eax
  103474:	89 04 24             	mov    %eax,(%esp)
  103477:	e8 75 fc ff ff       	call   1030f1 <getuint>
  10347c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10347f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  103482:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103489:	e9 84 00 00 00       	jmp    103512 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  10348e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103491:	89 44 24 04          	mov    %eax,0x4(%esp)
  103495:	8d 45 14             	lea    0x14(%ebp),%eax
  103498:	89 04 24             	mov    %eax,(%esp)
  10349b:	e8 51 fc ff ff       	call   1030f1 <getuint>
  1034a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034a3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1034a6:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1034ad:	eb 63                	jmp    103512 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  1034af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1034bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1034c0:	ff d0                	call   *%eax
            putch('x', putdat);
  1034c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034c9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1034d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1034d3:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1034d5:	8b 45 14             	mov    0x14(%ebp),%eax
  1034d8:	8d 50 04             	lea    0x4(%eax),%edx
  1034db:	89 55 14             	mov    %edx,0x14(%ebp)
  1034de:	8b 00                	mov    (%eax),%eax
  1034e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1034ea:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1034f1:	eb 1f                	jmp    103512 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1034f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034fa:	8d 45 14             	lea    0x14(%ebp),%eax
  1034fd:	89 04 24             	mov    %eax,(%esp)
  103500:	e8 ec fb ff ff       	call   1030f1 <getuint>
  103505:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103508:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10350b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103512:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  103516:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103519:	89 54 24 18          	mov    %edx,0x18(%esp)
  10351d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103520:	89 54 24 14          	mov    %edx,0x14(%esp)
  103524:	89 44 24 10          	mov    %eax,0x10(%esp)
  103528:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10352b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10352e:	89 44 24 08          	mov    %eax,0x8(%esp)
  103532:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103536:	8b 45 0c             	mov    0xc(%ebp),%eax
  103539:	89 44 24 04          	mov    %eax,0x4(%esp)
  10353d:	8b 45 08             	mov    0x8(%ebp),%eax
  103540:	89 04 24             	mov    %eax,(%esp)
  103543:	e8 a4 fa ff ff       	call   102fec <printnum>
            break;
  103548:	eb 38                	jmp    103582 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10354a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10354d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103551:	89 1c 24             	mov    %ebx,(%esp)
  103554:	8b 45 08             	mov    0x8(%ebp),%eax
  103557:	ff d0                	call   *%eax
            break;
  103559:	eb 27                	jmp    103582 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10355b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10355e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103562:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  103569:	8b 45 08             	mov    0x8(%ebp),%eax
  10356c:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  10356e:	ff 4d 10             	decl   0x10(%ebp)
  103571:	eb 03                	jmp    103576 <vprintfmt+0x3c0>
  103573:	ff 4d 10             	decl   0x10(%ebp)
  103576:	8b 45 10             	mov    0x10(%ebp),%eax
  103579:	48                   	dec    %eax
  10357a:	0f b6 00             	movzbl (%eax),%eax
  10357d:	3c 25                	cmp    $0x25,%al
  10357f:	75 f2                	jne    103573 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  103581:	90                   	nop
    while (1) {
  103582:	e9 37 fc ff ff       	jmp    1031be <vprintfmt+0x8>
                return;
  103587:	90                   	nop
        }
    }
}
  103588:	83 c4 40             	add    $0x40,%esp
  10358b:	5b                   	pop    %ebx
  10358c:	5e                   	pop    %esi
  10358d:	5d                   	pop    %ebp
  10358e:	c3                   	ret    

0010358f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10358f:	55                   	push   %ebp
  103590:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103592:	8b 45 0c             	mov    0xc(%ebp),%eax
  103595:	8b 40 08             	mov    0x8(%eax),%eax
  103598:	8d 50 01             	lea    0x1(%eax),%edx
  10359b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10359e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1035a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035a4:	8b 10                	mov    (%eax),%edx
  1035a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035a9:	8b 40 04             	mov    0x4(%eax),%eax
  1035ac:	39 c2                	cmp    %eax,%edx
  1035ae:	73 12                	jae    1035c2 <sprintputch+0x33>
        *b->buf ++ = ch;
  1035b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035b3:	8b 00                	mov    (%eax),%eax
  1035b5:	8d 48 01             	lea    0x1(%eax),%ecx
  1035b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1035bb:	89 0a                	mov    %ecx,(%edx)
  1035bd:	8b 55 08             	mov    0x8(%ebp),%edx
  1035c0:	88 10                	mov    %dl,(%eax)
    }
}
  1035c2:	90                   	nop
  1035c3:	5d                   	pop    %ebp
  1035c4:	c3                   	ret    

001035c5 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1035c5:	55                   	push   %ebp
  1035c6:	89 e5                	mov    %esp,%ebp
  1035c8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1035cb:	8d 45 14             	lea    0x14(%ebp),%eax
  1035ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1035d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1035d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1035d8:	8b 45 10             	mov    0x10(%ebp),%eax
  1035db:	89 44 24 08          	mov    %eax,0x8(%esp)
  1035df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1035e9:	89 04 24             	mov    %eax,(%esp)
  1035ec:	e8 08 00 00 00       	call   1035f9 <vsnprintf>
  1035f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1035f7:	c9                   	leave  
  1035f8:	c3                   	ret    

001035f9 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1035f9:	55                   	push   %ebp
  1035fa:	89 e5                	mov    %esp,%ebp
  1035fc:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1035ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103602:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103605:	8b 45 0c             	mov    0xc(%ebp),%eax
  103608:	8d 50 ff             	lea    -0x1(%eax),%edx
  10360b:	8b 45 08             	mov    0x8(%ebp),%eax
  10360e:	01 d0                	add    %edx,%eax
  103610:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103613:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  10361a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10361e:	74 0a                	je     10362a <vsnprintf+0x31>
  103620:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103626:	39 c2                	cmp    %eax,%edx
  103628:	76 07                	jbe    103631 <vsnprintf+0x38>
        return -E_INVAL;
  10362a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10362f:	eb 2a                	jmp    10365b <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103631:	8b 45 14             	mov    0x14(%ebp),%eax
  103634:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103638:	8b 45 10             	mov    0x10(%ebp),%eax
  10363b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10363f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103642:	89 44 24 04          	mov    %eax,0x4(%esp)
  103646:	c7 04 24 8f 35 10 00 	movl   $0x10358f,(%esp)
  10364d:	e8 64 fb ff ff       	call   1031b6 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  103652:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103655:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103658:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10365b:	c9                   	leave  
  10365c:	c3                   	ret    
