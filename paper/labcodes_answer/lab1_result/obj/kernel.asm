
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
void kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

void
kern_init(void){
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 80 fd 10 00       	mov    $0x10fd80,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	83 ec 04             	sub    $0x4,%esp
  100017:	50                   	push   %eax
  100018:	6a 00                	push   $0x0
  10001a:	68 16 ea 10 00       	push   $0x10ea16
  10001f:	e8 93 2d 00 00       	call   102db7 <memset>
  100024:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
  100027:	e8 42 15 00 00       	call   10156e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10002c:	c7 45 f4 60 35 10 00 	movl   $0x103560,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100033:	83 ec 08             	sub    $0x8,%esp
  100036:	ff 75 f4             	pushl  -0xc(%ebp)
  100039:	68 7c 35 10 00       	push   $0x10357c
  10003e:	e8 0a 02 00 00       	call   10024d <cprintf>
  100043:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
  100046:	e8 a1 08 00 00       	call   1008ec <print_kerninfo>

    grade_backtrace();
  10004b:	e8 79 00 00 00       	call   1000c9 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100050:	e8 26 2a 00 00       	call   102a7b <pmm_init>

    pic_init();                 // init interrupt controller
  100055:	e8 57 16 00 00       	call   1016b1 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005a:	e8 b8 17 00 00       	call   101817 <idt_init>

    clock_init();               // init clock interrupt
  10005f:	e8 eb 0c 00 00       	call   100d4f <clock_init>
    intr_enable();              // enable irq interrupt
  100064:	e8 85 17 00 00       	call   1017ee <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  100069:	e8 50 01 00 00       	call   1001be <lab1_switch_test>

    /* do nothing */
    while (1);
  10006e:	eb fe                	jmp    10006e <kern_init+0x6e>

00100070 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100070:	55                   	push   %ebp
  100071:	89 e5                	mov    %esp,%ebp
  100073:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
  100076:	83 ec 04             	sub    $0x4,%esp
  100079:	6a 00                	push   $0x0
  10007b:	6a 00                	push   $0x0
  10007d:	6a 00                	push   $0x0
  10007f:	e8 b9 0c 00 00       	call   100d3d <mon_backtrace>
  100084:	83 c4 10             	add    $0x10,%esp
}
  100087:	90                   	nop
  100088:	c9                   	leave  
  100089:	c3                   	ret    

0010008a <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  10008a:	55                   	push   %ebp
  10008b:	89 e5                	mov    %esp,%ebp
  10008d:	53                   	push   %ebx
  10008e:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  100091:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  100094:	8b 55 0c             	mov    0xc(%ebp),%edx
  100097:	8d 5d 08             	lea    0x8(%ebp),%ebx
  10009a:	8b 45 08             	mov    0x8(%ebp),%eax
  10009d:	51                   	push   %ecx
  10009e:	52                   	push   %edx
  10009f:	53                   	push   %ebx
  1000a0:	50                   	push   %eax
  1000a1:	e8 ca ff ff ff       	call   100070 <grade_backtrace2>
  1000a6:	83 c4 10             	add    $0x10,%esp
}
  1000a9:	90                   	nop
  1000aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000ad:	c9                   	leave  
  1000ae:	c3                   	ret    

001000af <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000af:	55                   	push   %ebp
  1000b0:	89 e5                	mov    %esp,%ebp
  1000b2:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
  1000b5:	83 ec 08             	sub    $0x8,%esp
  1000b8:	ff 75 10             	pushl  0x10(%ebp)
  1000bb:	ff 75 08             	pushl  0x8(%ebp)
  1000be:	e8 c7 ff ff ff       	call   10008a <grade_backtrace1>
  1000c3:	83 c4 10             	add    $0x10,%esp
}
  1000c6:	90                   	nop
  1000c7:	c9                   	leave  
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace>:

void
grade_backtrace(void) {
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000cf:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000d4:	83 ec 04             	sub    $0x4,%esp
  1000d7:	68 00 00 ff ff       	push   $0xffff0000
  1000dc:	50                   	push   %eax
  1000dd:	6a 00                	push   $0x0
  1000df:	e8 cb ff ff ff       	call   1000af <grade_backtrace0>
  1000e4:	83 c4 10             	add    $0x10,%esp
}
  1000e7:	90                   	nop
  1000e8:	c9                   	leave  
  1000e9:	c3                   	ret    

001000ea <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  1000ea:	55                   	push   %ebp
  1000eb:	89 e5                	mov    %esp,%ebp
  1000ed:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  1000f0:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  1000f3:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  1000f6:	8c 45 f2             	mov    %es,-0xe(%ebp)
  1000f9:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  1000fc:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100100:	0f b7 c0             	movzwl %ax,%eax
  100103:	83 e0 03             	and    $0x3,%eax
  100106:	89 c2                	mov    %eax,%edx
  100108:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  10010d:	83 ec 04             	sub    $0x4,%esp
  100110:	52                   	push   %edx
  100111:	50                   	push   %eax
  100112:	68 81 35 10 00       	push   $0x103581
  100117:	e8 31 01 00 00       	call   10024d <cprintf>
  10011c:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
  10011f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100123:	0f b7 d0             	movzwl %ax,%edx
  100126:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  10012b:	83 ec 04             	sub    $0x4,%esp
  10012e:	52                   	push   %edx
  10012f:	50                   	push   %eax
  100130:	68 8f 35 10 00       	push   $0x10358f
  100135:	e8 13 01 00 00       	call   10024d <cprintf>
  10013a:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
  10013d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100141:	0f b7 d0             	movzwl %ax,%edx
  100144:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100149:	83 ec 04             	sub    $0x4,%esp
  10014c:	52                   	push   %edx
  10014d:	50                   	push   %eax
  10014e:	68 9d 35 10 00       	push   $0x10359d
  100153:	e8 f5 00 00 00       	call   10024d <cprintf>
  100158:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
  10015b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10015f:	0f b7 d0             	movzwl %ax,%edx
  100162:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100167:	83 ec 04             	sub    $0x4,%esp
  10016a:	52                   	push   %edx
  10016b:	50                   	push   %eax
  10016c:	68 ab 35 10 00       	push   $0x1035ab
  100171:	e8 d7 00 00 00       	call   10024d <cprintf>
  100176:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
  100179:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10017d:	0f b7 d0             	movzwl %ax,%edx
  100180:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100185:	83 ec 04             	sub    $0x4,%esp
  100188:	52                   	push   %edx
  100189:	50                   	push   %eax
  10018a:	68 b9 35 10 00       	push   $0x1035b9
  10018f:	e8 b9 00 00 00       	call   10024d <cprintf>
  100194:	83 c4 10             	add    $0x10,%esp
    round ++;
  100197:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  10019c:	83 c0 01             	add    $0x1,%eax
  10019f:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001a4:	90                   	nop
  1001a5:	c9                   	leave  
  1001a6:	c3                   	ret    

001001a7 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001a7:	55                   	push   %ebp
  1001a8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  1001aa:	83 ec 08             	sub    $0x8,%esp
  1001ad:	cd 78                	int    $0x78
  1001af:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001b1:	90                   	nop
  1001b2:	5d                   	pop    %ebp
  1001b3:	c3                   	ret    

001001b4 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001b4:	55                   	push   %ebp
  1001b5:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  1001b7:	cd 79                	int    $0x79
  1001b9:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  1001bb:	90                   	nop
  1001bc:	5d                   	pop    %ebp
  1001bd:	c3                   	ret    

001001be <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001be:	55                   	push   %ebp
  1001bf:	89 e5                	mov    %esp,%ebp
  1001c1:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
  1001c4:	e8 21 ff ff ff       	call   1000ea <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001c9:	83 ec 0c             	sub    $0xc,%esp
  1001cc:	68 c8 35 10 00       	push   $0x1035c8
  1001d1:	e8 77 00 00 00       	call   10024d <cprintf>
  1001d6:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
  1001d9:	e8 c9 ff ff ff       	call   1001a7 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001de:	e8 07 ff ff ff       	call   1000ea <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001e3:	83 ec 0c             	sub    $0xc,%esp
  1001e6:	68 e8 35 10 00       	push   $0x1035e8
  1001eb:	e8 5d 00 00 00       	call   10024d <cprintf>
  1001f0:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
  1001f3:	e8 bc ff ff ff       	call   1001b4 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  1001f8:	e8 ed fe ff ff       	call   1000ea <lab1_print_cur_status>
}
  1001fd:	90                   	nop
  1001fe:	c9                   	leave  
  1001ff:	c3                   	ret    

00100200 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100200:	55                   	push   %ebp
  100201:	89 e5                	mov    %esp,%ebp
  100203:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  100206:	83 ec 0c             	sub    $0xc,%esp
  100209:	ff 75 08             	pushl  0x8(%ebp)
  10020c:	e8 8e 13 00 00       	call   10159f <cons_putc>
  100211:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  100214:	8b 45 0c             	mov    0xc(%ebp),%eax
  100217:	8b 00                	mov    (%eax),%eax
  100219:	8d 50 01             	lea    0x1(%eax),%edx
  10021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10021f:	89 10                	mov    %edx,(%eax)
}
  100221:	90                   	nop
  100222:	c9                   	leave  
  100223:	c3                   	ret    

00100224 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100224:	55                   	push   %ebp
  100225:	89 e5                	mov    %esp,%ebp
  100227:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  10022a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100231:	ff 75 0c             	pushl  0xc(%ebp)
  100234:	ff 75 08             	pushl  0x8(%ebp)
  100237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10023a:	50                   	push   %eax
  10023b:	68 00 02 10 00       	push   $0x100200
  100240:	e8 a8 2e 00 00       	call   1030ed <vprintfmt>
  100245:	83 c4 10             	add    $0x10,%esp
    return cnt;
  100248:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10024b:	c9                   	leave  
  10024c:	c3                   	ret    

0010024d <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10024d:	55                   	push   %ebp
  10024e:	89 e5                	mov    %esp,%ebp
  100250:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100253:	8d 45 0c             	lea    0xc(%ebp),%eax
  100256:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10025c:	83 ec 08             	sub    $0x8,%esp
  10025f:	50                   	push   %eax
  100260:	ff 75 08             	pushl  0x8(%ebp)
  100263:	e8 bc ff ff ff       	call   100224 <vcprintf>
  100268:	83 c4 10             	add    $0x10,%esp
  10026b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100271:	c9                   	leave  
  100272:	c3                   	ret    

00100273 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100273:	55                   	push   %ebp
  100274:	89 e5                	mov    %esp,%ebp
  100276:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  100279:	83 ec 0c             	sub    $0xc,%esp
  10027c:	ff 75 08             	pushl  0x8(%ebp)
  10027f:	e8 1b 13 00 00       	call   10159f <cons_putc>
  100284:	83 c4 10             	add    $0x10,%esp
}
  100287:	90                   	nop
  100288:	c9                   	leave  
  100289:	c3                   	ret    

0010028a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10028a:	55                   	push   %ebp
  10028b:	89 e5                	mov    %esp,%ebp
  10028d:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  100290:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100297:	eb 14                	jmp    1002ad <cputs+0x23>
        cputch(c, &cnt);
  100299:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10029d:	83 ec 08             	sub    $0x8,%esp
  1002a0:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002a3:	52                   	push   %edx
  1002a4:	50                   	push   %eax
  1002a5:	e8 56 ff ff ff       	call   100200 <cputch>
  1002aa:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
  1002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b0:	8d 50 01             	lea    0x1(%eax),%edx
  1002b3:	89 55 08             	mov    %edx,0x8(%ebp)
  1002b6:	0f b6 00             	movzbl (%eax),%eax
  1002b9:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002bc:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002c0:	75 d7                	jne    100299 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1002c2:	83 ec 08             	sub    $0x8,%esp
  1002c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002c8:	50                   	push   %eax
  1002c9:	6a 0a                	push   $0xa
  1002cb:	e8 30 ff ff ff       	call   100200 <cputch>
  1002d0:	83 c4 10             	add    $0x10,%esp
    return cnt;
  1002d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002d6:	c9                   	leave  
  1002d7:	c3                   	ret    

001002d8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002d8:	55                   	push   %ebp
  1002d9:	89 e5                	mov    %esp,%ebp
  1002db:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002de:	e8 ec 12 00 00       	call   1015cf <cons_getc>
  1002e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1002e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ea:	74 f2                	je     1002de <getchar+0x6>
        /* do nothing */;
    return c;
  1002ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002ef:	c9                   	leave  
  1002f0:	c3                   	ret    

001002f1 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  1002f1:	55                   	push   %ebp
  1002f2:	89 e5                	mov    %esp,%ebp
  1002f4:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
  1002f7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1002fb:	74 13                	je     100310 <readline+0x1f>
        cprintf("%s", prompt);
  1002fd:	83 ec 08             	sub    $0x8,%esp
  100300:	ff 75 08             	pushl  0x8(%ebp)
  100303:	68 07 36 10 00       	push   $0x103607
  100308:	e8 40 ff ff ff       	call   10024d <cprintf>
  10030d:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
  100310:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100317:	e8 bc ff ff ff       	call   1002d8 <getchar>
  10031c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10031f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100323:	79 0a                	jns    10032f <readline+0x3e>
            return NULL;
  100325:	b8 00 00 00 00       	mov    $0x0,%eax
  10032a:	e9 82 00 00 00       	jmp    1003b1 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10032f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100333:	7e 2b                	jle    100360 <readline+0x6f>
  100335:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10033c:	7f 22                	jg     100360 <readline+0x6f>
            cputchar(c);
  10033e:	83 ec 0c             	sub    $0xc,%esp
  100341:	ff 75 f0             	pushl  -0x10(%ebp)
  100344:	e8 2a ff ff ff       	call   100273 <cputchar>
  100349:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
  10034c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10034f:	8d 50 01             	lea    0x1(%eax),%edx
  100352:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100355:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100358:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  10035e:	eb 4c                	jmp    1003ac <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
  100360:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100364:	75 1a                	jne    100380 <readline+0x8f>
  100366:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10036a:	7e 14                	jle    100380 <readline+0x8f>
            cputchar(c);
  10036c:	83 ec 0c             	sub    $0xc,%esp
  10036f:	ff 75 f0             	pushl  -0x10(%ebp)
  100372:	e8 fc fe ff ff       	call   100273 <cputchar>
  100377:	83 c4 10             	add    $0x10,%esp
            i --;
  10037a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10037e:	eb 2c                	jmp    1003ac <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
  100380:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100384:	74 06                	je     10038c <readline+0x9b>
  100386:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10038a:	75 8b                	jne    100317 <readline+0x26>
            cputchar(c);
  10038c:	83 ec 0c             	sub    $0xc,%esp
  10038f:	ff 75 f0             	pushl  -0x10(%ebp)
  100392:	e8 dc fe ff ff       	call   100273 <cputchar>
  100397:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
  10039a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10039d:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1003a2:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003a5:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1003aa:	eb 05                	jmp    1003b1 <readline+0xc0>
        c = getchar();
  1003ac:	e9 66 ff ff ff       	jmp    100317 <readline+0x26>
        }
    }
}
  1003b1:	c9                   	leave  
  1003b2:	c3                   	ret    

001003b3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003b3:	55                   	push   %ebp
  1003b4:	89 e5                	mov    %esp,%ebp
  1003b6:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
  1003b9:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  1003be:	85 c0                	test   %eax,%eax
  1003c0:	75 5f                	jne    100421 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
  1003c2:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  1003c9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003cc:	8d 45 14             	lea    0x14(%ebp),%eax
  1003cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003d2:	83 ec 04             	sub    $0x4,%esp
  1003d5:	ff 75 0c             	pushl  0xc(%ebp)
  1003d8:	ff 75 08             	pushl  0x8(%ebp)
  1003db:	68 0a 36 10 00       	push   $0x10360a
  1003e0:	e8 68 fe ff ff       	call   10024d <cprintf>
  1003e5:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  1003e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003eb:	83 ec 08             	sub    $0x8,%esp
  1003ee:	50                   	push   %eax
  1003ef:	ff 75 10             	pushl  0x10(%ebp)
  1003f2:	e8 2d fe ff ff       	call   100224 <vcprintf>
  1003f7:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  1003fa:	83 ec 0c             	sub    $0xc,%esp
  1003fd:	68 26 36 10 00       	push   $0x103626
  100402:	e8 46 fe ff ff       	call   10024d <cprintf>
  100407:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
  10040a:	83 ec 0c             	sub    $0xc,%esp
  10040d:	68 28 36 10 00       	push   $0x103628
  100412:	e8 36 fe ff ff       	call   10024d <cprintf>
  100417:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
  10041a:	e8 17 06 00 00       	call   100a36 <print_stackframe>
  10041f:	eb 01                	jmp    100422 <__panic+0x6f>
        goto panic_dead;
  100421:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100422:	e8 ce 13 00 00       	call   1017f5 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100427:	83 ec 0c             	sub    $0xc,%esp
  10042a:	6a 00                	push   $0x0
  10042c:	e8 32 08 00 00       	call   100c63 <kmonitor>
  100431:	83 c4 10             	add    $0x10,%esp
  100434:	eb f1                	jmp    100427 <__panic+0x74>

00100436 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100436:	55                   	push   %ebp
  100437:	89 e5                	mov    %esp,%ebp
  100439:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  10043c:	8d 45 14             	lea    0x14(%ebp),%eax
  10043f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100442:	83 ec 04             	sub    $0x4,%esp
  100445:	ff 75 0c             	pushl  0xc(%ebp)
  100448:	ff 75 08             	pushl  0x8(%ebp)
  10044b:	68 3a 36 10 00       	push   $0x10363a
  100450:	e8 f8 fd ff ff       	call   10024d <cprintf>
  100455:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  100458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10045b:	83 ec 08             	sub    $0x8,%esp
  10045e:	50                   	push   %eax
  10045f:	ff 75 10             	pushl  0x10(%ebp)
  100462:	e8 bd fd ff ff       	call   100224 <vcprintf>
  100467:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  10046a:	83 ec 0c             	sub    $0xc,%esp
  10046d:	68 26 36 10 00       	push   $0x103626
  100472:	e8 d6 fd ff ff       	call   10024d <cprintf>
  100477:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  10047a:	90                   	nop
  10047b:	c9                   	leave  
  10047c:	c3                   	ret    

0010047d <is_kernel_panic>:

bool
is_kernel_panic(void) {
  10047d:	55                   	push   %ebp
  10047e:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100480:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100485:	5d                   	pop    %ebp
  100486:	c3                   	ret    

00100487 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100487:	55                   	push   %ebp
  100488:	89 e5                	mov    %esp,%ebp
  10048a:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  10048d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100490:	8b 00                	mov    (%eax),%eax
  100492:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100495:	8b 45 10             	mov    0x10(%ebp),%eax
  100498:	8b 00                	mov    (%eax),%eax
  10049a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10049d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004a4:	e9 d2 00 00 00       	jmp    10057b <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1004a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004af:	01 d0                	add    %edx,%eax
  1004b1:	89 c2                	mov    %eax,%edx
  1004b3:	c1 ea 1f             	shr    $0x1f,%edx
  1004b6:	01 d0                	add    %edx,%eax
  1004b8:	d1 f8                	sar    %eax
  1004ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004c3:	eb 04                	jmp    1004c9 <stab_binsearch+0x42>
            m --;
  1004c5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004cc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004cf:	7c 1f                	jl     1004f0 <stab_binsearch+0x69>
  1004d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d4:	89 d0                	mov    %edx,%eax
  1004d6:	01 c0                	add    %eax,%eax
  1004d8:	01 d0                	add    %edx,%eax
  1004da:	c1 e0 02             	shl    $0x2,%eax
  1004dd:	89 c2                	mov    %eax,%edx
  1004df:	8b 45 08             	mov    0x8(%ebp),%eax
  1004e2:	01 d0                	add    %edx,%eax
  1004e4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004e8:	0f b6 c0             	movzbl %al,%eax
  1004eb:	39 45 14             	cmp    %eax,0x14(%ebp)
  1004ee:	75 d5                	jne    1004c5 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  1004f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004f3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004f6:	7d 0b                	jge    100503 <stab_binsearch+0x7c>
            l = true_m + 1;
  1004f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004fb:	83 c0 01             	add    $0x1,%eax
  1004fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100501:	eb 78                	jmp    10057b <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100503:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10050a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10050d:	89 d0                	mov    %edx,%eax
  10050f:	01 c0                	add    %eax,%eax
  100511:	01 d0                	add    %edx,%eax
  100513:	c1 e0 02             	shl    $0x2,%eax
  100516:	89 c2                	mov    %eax,%edx
  100518:	8b 45 08             	mov    0x8(%ebp),%eax
  10051b:	01 d0                	add    %edx,%eax
  10051d:	8b 40 08             	mov    0x8(%eax),%eax
  100520:	39 45 18             	cmp    %eax,0x18(%ebp)
  100523:	76 13                	jbe    100538 <stab_binsearch+0xb1>
            *region_left = m;
  100525:	8b 45 0c             	mov    0xc(%ebp),%eax
  100528:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10052b:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10052d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100530:	83 c0 01             	add    $0x1,%eax
  100533:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100536:	eb 43                	jmp    10057b <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100538:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053b:	89 d0                	mov    %edx,%eax
  10053d:	01 c0                	add    %eax,%eax
  10053f:	01 d0                	add    %edx,%eax
  100541:	c1 e0 02             	shl    $0x2,%eax
  100544:	89 c2                	mov    %eax,%edx
  100546:	8b 45 08             	mov    0x8(%ebp),%eax
  100549:	01 d0                	add    %edx,%eax
  10054b:	8b 40 08             	mov    0x8(%eax),%eax
  10054e:	39 45 18             	cmp    %eax,0x18(%ebp)
  100551:	73 16                	jae    100569 <stab_binsearch+0xe2>
            *region_right = m - 1;
  100553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100556:	8d 50 ff             	lea    -0x1(%eax),%edx
  100559:	8b 45 10             	mov    0x10(%ebp),%eax
  10055c:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10055e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100561:	83 e8 01             	sub    $0x1,%eax
  100564:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100567:	eb 12                	jmp    10057b <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100569:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10056f:	89 10                	mov    %edx,(%eax)
            l = m;
  100571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100574:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  100577:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
  10057b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10057e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100581:	0f 8e 22 ff ff ff    	jle    1004a9 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  100587:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10058b:	75 0f                	jne    10059c <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  10058d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100590:	8b 00                	mov    (%eax),%eax
  100592:	8d 50 ff             	lea    -0x1(%eax),%edx
  100595:	8b 45 10             	mov    0x10(%ebp),%eax
  100598:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10059a:	eb 3f                	jmp    1005db <stab_binsearch+0x154>
        l = *region_right;
  10059c:	8b 45 10             	mov    0x10(%ebp),%eax
  10059f:	8b 00                	mov    (%eax),%eax
  1005a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005a4:	eb 04                	jmp    1005aa <stab_binsearch+0x123>
  1005a6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005ad:	8b 00                	mov    (%eax),%eax
  1005af:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1005b2:	7e 1f                	jle    1005d3 <stab_binsearch+0x14c>
  1005b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005b7:	89 d0                	mov    %edx,%eax
  1005b9:	01 c0                	add    %eax,%eax
  1005bb:	01 d0                	add    %edx,%eax
  1005bd:	c1 e0 02             	shl    $0x2,%eax
  1005c0:	89 c2                	mov    %eax,%edx
  1005c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1005c5:	01 d0                	add    %edx,%eax
  1005c7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005cb:	0f b6 c0             	movzbl %al,%eax
  1005ce:	39 45 14             	cmp    %eax,0x14(%ebp)
  1005d1:	75 d3                	jne    1005a6 <stab_binsearch+0x11f>
        *region_left = l;
  1005d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005d9:	89 10                	mov    %edx,(%eax)
}
  1005db:	90                   	nop
  1005dc:	c9                   	leave  
  1005dd:	c3                   	ret    

001005de <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005de:	55                   	push   %ebp
  1005df:	89 e5                	mov    %esp,%ebp
  1005e1:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e7:	c7 00 58 36 10 00    	movl   $0x103658,(%eax)
    info->eip_line = 0;
  1005ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fa:	c7 40 08 58 36 10 00 	movl   $0x103658,0x8(%eax)
    info->eip_fn_namelen = 9;
  100601:	8b 45 0c             	mov    0xc(%ebp),%eax
  100604:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10060b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060e:	8b 55 08             	mov    0x8(%ebp),%edx
  100611:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100614:	8b 45 0c             	mov    0xc(%ebp),%eax
  100617:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10061e:	c7 45 f4 6c 3e 10 00 	movl   $0x103e6c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100625:	c7 45 f0 24 bc 10 00 	movl   $0x10bc24,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10062c:	c7 45 ec 25 bc 10 00 	movl   $0x10bc25,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100633:	c7 45 e8 18 dd 10 00 	movl   $0x10dd18,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10063a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100640:	76 0d                	jbe    10064f <debuginfo_eip+0x71>
  100642:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100645:	83 e8 01             	sub    $0x1,%eax
  100648:	0f b6 00             	movzbl (%eax),%eax
  10064b:	84 c0                	test   %al,%al
  10064d:	74 0a                	je     100659 <debuginfo_eip+0x7b>
        return -1;
  10064f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100654:	e9 91 02 00 00       	jmp    1008ea <debuginfo_eip+0x30c>
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
  100673:	83 e8 01             	sub    $0x1,%eax
  100676:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100679:	ff 75 08             	pushl  0x8(%ebp)
  10067c:	6a 64                	push   $0x64
  10067e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100681:	50                   	push   %eax
  100682:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100685:	50                   	push   %eax
  100686:	ff 75 f4             	pushl  -0xc(%ebp)
  100689:	e8 f9 fd ff ff       	call   100487 <stab_binsearch>
  10068e:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
  100691:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100694:	85 c0                	test   %eax,%eax
  100696:	75 0a                	jne    1006a2 <debuginfo_eip+0xc4>
        return -1;
  100698:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10069d:	e9 48 02 00 00       	jmp    1008ea <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006ae:	ff 75 08             	pushl  0x8(%ebp)
  1006b1:	6a 24                	push   $0x24
  1006b3:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006b6:	50                   	push   %eax
  1006b7:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006ba:	50                   	push   %eax
  1006bb:	ff 75 f4             	pushl  -0xc(%ebp)
  1006be:	e8 c4 fd ff ff       	call   100487 <stab_binsearch>
  1006c3:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
  1006c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006cc:	39 c2                	cmp    %eax,%edx
  1006ce:	7f 7c                	jg     10074c <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006d3:	89 c2                	mov    %eax,%edx
  1006d5:	89 d0                	mov    %edx,%eax
  1006d7:	01 c0                	add    %eax,%eax
  1006d9:	01 d0                	add    %edx,%eax
  1006db:	c1 e0 02             	shl    $0x2,%eax
  1006de:	89 c2                	mov    %eax,%edx
  1006e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006e3:	01 d0                	add    %edx,%eax
  1006e5:	8b 00                	mov    (%eax),%eax
  1006e7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1006ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1006ed:	29 d1                	sub    %edx,%ecx
  1006ef:	89 ca                	mov    %ecx,%edx
  1006f1:	39 d0                	cmp    %edx,%eax
  1006f3:	73 22                	jae    100717 <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  1006f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006f8:	89 c2                	mov    %eax,%edx
  1006fa:	89 d0                	mov    %edx,%eax
  1006fc:	01 c0                	add    %eax,%eax
  1006fe:	01 d0                	add    %edx,%eax
  100700:	c1 e0 02             	shl    $0x2,%eax
  100703:	89 c2                	mov    %eax,%edx
  100705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100708:	01 d0                	add    %edx,%eax
  10070a:	8b 10                	mov    (%eax),%edx
  10070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10070f:	01 c2                	add    %eax,%edx
  100711:	8b 45 0c             	mov    0xc(%ebp),%eax
  100714:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100717:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10071a:	89 c2                	mov    %eax,%edx
  10071c:	89 d0                	mov    %edx,%eax
  10071e:	01 c0                	add    %eax,%eax
  100720:	01 d0                	add    %edx,%eax
  100722:	c1 e0 02             	shl    $0x2,%eax
  100725:	89 c2                	mov    %eax,%edx
  100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072a:	01 d0                	add    %edx,%eax
  10072c:	8b 50 08             	mov    0x8(%eax),%edx
  10072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100732:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100735:	8b 45 0c             	mov    0xc(%ebp),%eax
  100738:	8b 40 10             	mov    0x10(%eax),%eax
  10073b:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10073e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100741:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100744:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100747:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10074a:	eb 15                	jmp    100761 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10074c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10074f:	8b 55 08             	mov    0x8(%ebp),%edx
  100752:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10075b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10075e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  100761:	8b 45 0c             	mov    0xc(%ebp),%eax
  100764:	8b 40 08             	mov    0x8(%eax),%eax
  100767:	83 ec 08             	sub    $0x8,%esp
  10076a:	6a 3a                	push   $0x3a
  10076c:	50                   	push   %eax
  10076d:	e8 b9 24 00 00       	call   102c2b <strfind>
  100772:	83 c4 10             	add    $0x10,%esp
  100775:	89 c2                	mov    %eax,%edx
  100777:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077a:	8b 40 08             	mov    0x8(%eax),%eax
  10077d:	29 c2                	sub    %eax,%edx
  10077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100782:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100785:	83 ec 0c             	sub    $0xc,%esp
  100788:	ff 75 08             	pushl  0x8(%ebp)
  10078b:	6a 44                	push   $0x44
  10078d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100790:	50                   	push   %eax
  100791:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100794:	50                   	push   %eax
  100795:	ff 75 f4             	pushl  -0xc(%ebp)
  100798:	e8 ea fc ff ff       	call   100487 <stab_binsearch>
  10079d:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
  1007a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007a6:	39 c2                	cmp    %eax,%edx
  1007a8:	7f 24                	jg     1007ce <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
  1007aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007ad:	89 c2                	mov    %eax,%edx
  1007af:	89 d0                	mov    %edx,%eax
  1007b1:	01 c0                	add    %eax,%eax
  1007b3:	01 d0                	add    %edx,%eax
  1007b5:	c1 e0 02             	shl    $0x2,%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007bd:	01 d0                	add    %edx,%eax
  1007bf:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007c3:	0f b7 d0             	movzwl %ax,%edx
  1007c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c9:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007cc:	eb 13                	jmp    1007e1 <debuginfo_eip+0x203>
        return -1;
  1007ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007d3:	e9 12 01 00 00       	jmp    1008ea <debuginfo_eip+0x30c>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  1007d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007db:	83 e8 01             	sub    $0x1,%eax
  1007de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  1007e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007e7:	39 c2                	cmp    %eax,%edx
  1007e9:	7c 56                	jl     100841 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
  1007eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007ee:	89 c2                	mov    %eax,%edx
  1007f0:	89 d0                	mov    %edx,%eax
  1007f2:	01 c0                	add    %eax,%eax
  1007f4:	01 d0                	add    %edx,%eax
  1007f6:	c1 e0 02             	shl    $0x2,%eax
  1007f9:	89 c2                	mov    %eax,%edx
  1007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007fe:	01 d0                	add    %edx,%eax
  100800:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100804:	3c 84                	cmp    $0x84,%al
  100806:	74 39                	je     100841 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100808:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	89 d0                	mov    %edx,%eax
  10080f:	01 c0                	add    %eax,%eax
  100811:	01 d0                	add    %edx,%eax
  100813:	c1 e0 02             	shl    $0x2,%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10081b:	01 d0                	add    %edx,%eax
  10081d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100821:	3c 64                	cmp    $0x64,%al
  100823:	75 b3                	jne    1007d8 <debuginfo_eip+0x1fa>
  100825:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100828:	89 c2                	mov    %eax,%edx
  10082a:	89 d0                	mov    %edx,%eax
  10082c:	01 c0                	add    %eax,%eax
  10082e:	01 d0                	add    %edx,%eax
  100830:	c1 e0 02             	shl    $0x2,%eax
  100833:	89 c2                	mov    %eax,%edx
  100835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100838:	01 d0                	add    %edx,%eax
  10083a:	8b 40 08             	mov    0x8(%eax),%eax
  10083d:	85 c0                	test   %eax,%eax
  10083f:	74 97                	je     1007d8 <debuginfo_eip+0x1fa>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100841:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100847:	39 c2                	cmp    %eax,%edx
  100849:	7c 46                	jl     100891 <debuginfo_eip+0x2b3>
  10084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084e:	89 c2                	mov    %eax,%edx
  100850:	89 d0                	mov    %edx,%eax
  100852:	01 c0                	add    %eax,%eax
  100854:	01 d0                	add    %edx,%eax
  100856:	c1 e0 02             	shl    $0x2,%eax
  100859:	89 c2                	mov    %eax,%edx
  10085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085e:	01 d0                	add    %edx,%eax
  100860:	8b 00                	mov    (%eax),%eax
  100862:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100865:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100868:	29 d1                	sub    %edx,%ecx
  10086a:	89 ca                	mov    %ecx,%edx
  10086c:	39 d0                	cmp    %edx,%eax
  10086e:	73 21                	jae    100891 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100870:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100873:	89 c2                	mov    %eax,%edx
  100875:	89 d0                	mov    %edx,%eax
  100877:	01 c0                	add    %eax,%eax
  100879:	01 d0                	add    %edx,%eax
  10087b:	c1 e0 02             	shl    $0x2,%eax
  10087e:	89 c2                	mov    %eax,%edx
  100880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100883:	01 d0                	add    %edx,%eax
  100885:	8b 10                	mov    (%eax),%edx
  100887:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10088a:	01 c2                	add    %eax,%edx
  10088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10088f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100891:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100894:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100897:	39 c2                	cmp    %eax,%edx
  100899:	7d 4a                	jge    1008e5 <debuginfo_eip+0x307>
        for (lline = lfun + 1;
  10089b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10089e:	83 c0 01             	add    $0x1,%eax
  1008a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008a4:	eb 18                	jmp    1008be <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008a9:	8b 40 14             	mov    0x14(%eax),%eax
  1008ac:	8d 50 01             	lea    0x1(%eax),%edx
  1008af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b2:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  1008b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008b8:	83 c0 01             	add    $0x1,%eax
  1008bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  1008c4:	39 c2                	cmp    %eax,%edx
  1008c6:	7d 1d                	jge    1008e5 <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008cb:	89 c2                	mov    %eax,%edx
  1008cd:	89 d0                	mov    %edx,%eax
  1008cf:	01 c0                	add    %eax,%eax
  1008d1:	01 d0                	add    %edx,%eax
  1008d3:	c1 e0 02             	shl    $0x2,%eax
  1008d6:	89 c2                	mov    %eax,%edx
  1008d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008db:	01 d0                	add    %edx,%eax
  1008dd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008e1:	3c a0                	cmp    $0xa0,%al
  1008e3:	74 c1                	je     1008a6 <debuginfo_eip+0x2c8>
        }
    }
    return 0;
  1008e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1008ea:	c9                   	leave  
  1008eb:	c3                   	ret    

001008ec <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  1008ec:	55                   	push   %ebp
  1008ed:	89 e5                	mov    %esp,%ebp
  1008ef:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  1008f2:	83 ec 0c             	sub    $0xc,%esp
  1008f5:	68 62 36 10 00       	push   $0x103662
  1008fa:	e8 4e f9 ff ff       	call   10024d <cprintf>
  1008ff:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100902:	83 ec 08             	sub    $0x8,%esp
  100905:	68 00 00 10 00       	push   $0x100000
  10090a:	68 7b 36 10 00       	push   $0x10367b
  10090f:	e8 39 f9 ff ff       	call   10024d <cprintf>
  100914:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
  100917:	83 ec 08             	sub    $0x8,%esp
  10091a:	68 4e 35 10 00       	push   $0x10354e
  10091f:	68 93 36 10 00       	push   $0x103693
  100924:	e8 24 f9 ff ff       	call   10024d <cprintf>
  100929:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
  10092c:	83 ec 08             	sub    $0x8,%esp
  10092f:	68 16 ea 10 00       	push   $0x10ea16
  100934:	68 ab 36 10 00       	push   $0x1036ab
  100939:	e8 0f f9 ff ff       	call   10024d <cprintf>
  10093e:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
  100941:	83 ec 08             	sub    $0x8,%esp
  100944:	68 80 fd 10 00       	push   $0x10fd80
  100949:	68 c3 36 10 00       	push   $0x1036c3
  10094e:	e8 fa f8 ff ff       	call   10024d <cprintf>
  100953:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100956:	b8 80 fd 10 00       	mov    $0x10fd80,%eax
  10095b:	05 ff 03 00 00       	add    $0x3ff,%eax
  100960:	ba 00 00 10 00       	mov    $0x100000,%edx
  100965:	29 d0                	sub    %edx,%eax
  100967:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10096d:	85 c0                	test   %eax,%eax
  10096f:	0f 48 c2             	cmovs  %edx,%eax
  100972:	c1 f8 0a             	sar    $0xa,%eax
  100975:	83 ec 08             	sub    $0x8,%esp
  100978:	50                   	push   %eax
  100979:	68 dc 36 10 00       	push   $0x1036dc
  10097e:	e8 ca f8 ff ff       	call   10024d <cprintf>
  100983:	83 c4 10             	add    $0x10,%esp
}
  100986:	90                   	nop
  100987:	c9                   	leave  
  100988:	c3                   	ret    

00100989 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100989:	55                   	push   %ebp
  10098a:	89 e5                	mov    %esp,%ebp
  10098c:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100992:	83 ec 08             	sub    $0x8,%esp
  100995:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100998:	50                   	push   %eax
  100999:	ff 75 08             	pushl  0x8(%ebp)
  10099c:	e8 3d fc ff ff       	call   1005de <debuginfo_eip>
  1009a1:	83 c4 10             	add    $0x10,%esp
  1009a4:	85 c0                	test   %eax,%eax
  1009a6:	74 15                	je     1009bd <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009a8:	83 ec 08             	sub    $0x8,%esp
  1009ab:	ff 75 08             	pushl  0x8(%ebp)
  1009ae:	68 06 37 10 00       	push   $0x103706
  1009b3:	e8 95 f8 ff ff       	call   10024d <cprintf>
  1009b8:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009bb:	eb 65                	jmp    100a22 <print_debuginfo+0x99>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009c4:	eb 1c                	jmp    1009e2 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  1009c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009cc:	01 d0                	add    %edx,%eax
  1009ce:	0f b6 00             	movzbl (%eax),%eax
  1009d1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009da:	01 ca                	add    %ecx,%edx
  1009dc:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1009e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009e5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1009e8:	7c dc                	jl     1009c6 <print_debuginfo+0x3d>
        fnname[j] = '\0';
  1009ea:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  1009f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f3:	01 d0                	add    %edx,%eax
  1009f5:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  1009f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  1009fb:	8b 55 08             	mov    0x8(%ebp),%edx
  1009fe:	89 d1                	mov    %edx,%ecx
  100a00:	29 c1                	sub    %eax,%ecx
  100a02:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a05:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a08:	83 ec 0c             	sub    $0xc,%esp
  100a0b:	51                   	push   %ecx
  100a0c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a12:	51                   	push   %ecx
  100a13:	52                   	push   %edx
  100a14:	50                   	push   %eax
  100a15:	68 22 37 10 00       	push   $0x103722
  100a1a:	e8 2e f8 ff ff       	call   10024d <cprintf>
  100a1f:	83 c4 20             	add    $0x20,%esp
}
  100a22:	90                   	nop
  100a23:	c9                   	leave  
  100a24:	c3                   	ret    

00100a25 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a25:	55                   	push   %ebp
  100a26:	89 e5                	mov    %esp,%ebp
  100a28:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a2b:	8b 45 04             	mov    0x4(%ebp),%eax
  100a2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a34:	c9                   	leave  
  100a35:	c3                   	ret    

00100a36 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a36:	55                   	push   %ebp
  100a37:	89 e5                	mov    %esp,%ebp
  100a39:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a3c:	89 e8                	mov    %ebp,%eax
  100a3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  100a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100a47:	e8 d9 ff ff ff       	call   100a25 <read_eip>
  100a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100a4f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a56:	e9 8d 00 00 00       	jmp    100ae8 <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100a5b:	83 ec 04             	sub    $0x4,%esp
  100a5e:	ff 75 f0             	pushl  -0x10(%ebp)
  100a61:	ff 75 f4             	pushl  -0xc(%ebp)
  100a64:	68 34 37 10 00       	push   $0x103734
  100a69:	e8 df f7 ff ff       	call   10024d <cprintf>
  100a6e:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
  100a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a74:	83 c0 08             	add    $0x8,%eax
  100a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100a7a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a81:	eb 26                	jmp    100aa9 <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
  100a83:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a90:	01 d0                	add    %edx,%eax
  100a92:	8b 00                	mov    (%eax),%eax
  100a94:	83 ec 08             	sub    $0x8,%esp
  100a97:	50                   	push   %eax
  100a98:	68 50 37 10 00       	push   $0x103750
  100a9d:	e8 ab f7 ff ff       	call   10024d <cprintf>
  100aa2:	83 c4 10             	add    $0x10,%esp
        for (j = 0; j < 4; j ++) {
  100aa5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100aa9:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100aad:	7e d4                	jle    100a83 <print_stackframe+0x4d>
        }
        cprintf("\n");
  100aaf:	83 ec 0c             	sub    $0xc,%esp
  100ab2:	68 58 37 10 00       	push   $0x103758
  100ab7:	e8 91 f7 ff ff       	call   10024d <cprintf>
  100abc:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
  100abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ac2:	83 e8 01             	sub    $0x1,%eax
  100ac5:	83 ec 0c             	sub    $0xc,%esp
  100ac8:	50                   	push   %eax
  100ac9:	e8 bb fe ff ff       	call   100989 <print_debuginfo>
  100ace:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
  100ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ad4:	83 c0 04             	add    $0x4,%eax
  100ad7:	8b 00                	mov    (%eax),%eax
  100ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adf:	8b 00                	mov    (%eax),%eax
  100ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100ae4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100ae8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100aec:	74 0a                	je     100af8 <print_stackframe+0xc2>
  100aee:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100af2:	0f 8e 63 ff ff ff    	jle    100a5b <print_stackframe+0x25>
    }
}
  100af8:	90                   	nop
  100af9:	c9                   	leave  
  100afa:	c3                   	ret    

00100afb <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100afb:	55                   	push   %ebp
  100afc:	89 e5                	mov    %esp,%ebp
  100afe:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
  100b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b08:	eb 0c                	jmp    100b16 <parse+0x1b>
            *buf ++ = '\0';
  100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0d:	8d 50 01             	lea    0x1(%eax),%edx
  100b10:	89 55 08             	mov    %edx,0x8(%ebp)
  100b13:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b16:	8b 45 08             	mov    0x8(%ebp),%eax
  100b19:	0f b6 00             	movzbl (%eax),%eax
  100b1c:	84 c0                	test   %al,%al
  100b1e:	74 1e                	je     100b3e <parse+0x43>
  100b20:	8b 45 08             	mov    0x8(%ebp),%eax
  100b23:	0f b6 00             	movzbl (%eax),%eax
  100b26:	0f be c0             	movsbl %al,%eax
  100b29:	83 ec 08             	sub    $0x8,%esp
  100b2c:	50                   	push   %eax
  100b2d:	68 dc 37 10 00       	push   $0x1037dc
  100b32:	e8 c1 20 00 00       	call   102bf8 <strchr>
  100b37:	83 c4 10             	add    $0x10,%esp
  100b3a:	85 c0                	test   %eax,%eax
  100b3c:	75 cc                	jne    100b0a <parse+0xf>
        }
        if (*buf == '\0') {
  100b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b41:	0f b6 00             	movzbl (%eax),%eax
  100b44:	84 c0                	test   %al,%al
  100b46:	74 65                	je     100bad <parse+0xb2>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b48:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b4c:	75 12                	jne    100b60 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b4e:	83 ec 08             	sub    $0x8,%esp
  100b51:	6a 10                	push   $0x10
  100b53:	68 e1 37 10 00       	push   $0x1037e1
  100b58:	e8 f0 f6 ff ff       	call   10024d <cprintf>
  100b5d:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
  100b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b63:	8d 50 01             	lea    0x1(%eax),%edx
  100b66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b73:	01 c2                	add    %eax,%edx
  100b75:	8b 45 08             	mov    0x8(%ebp),%eax
  100b78:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b7a:	eb 04                	jmp    100b80 <parse+0x85>
            buf ++;
  100b7c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b80:	8b 45 08             	mov    0x8(%ebp),%eax
  100b83:	0f b6 00             	movzbl (%eax),%eax
  100b86:	84 c0                	test   %al,%al
  100b88:	74 8c                	je     100b16 <parse+0x1b>
  100b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b8d:	0f b6 00             	movzbl (%eax),%eax
  100b90:	0f be c0             	movsbl %al,%eax
  100b93:	83 ec 08             	sub    $0x8,%esp
  100b96:	50                   	push   %eax
  100b97:	68 dc 37 10 00       	push   $0x1037dc
  100b9c:	e8 57 20 00 00       	call   102bf8 <strchr>
  100ba1:	83 c4 10             	add    $0x10,%esp
  100ba4:	85 c0                	test   %eax,%eax
  100ba6:	74 d4                	je     100b7c <parse+0x81>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100ba8:	e9 69 ff ff ff       	jmp    100b16 <parse+0x1b>
            break;
  100bad:	90                   	nop
        }
    }
    return argc;
  100bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bb1:	c9                   	leave  
  100bb2:	c3                   	ret    

00100bb3 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bb3:	55                   	push   %ebp
  100bb4:	89 e5                	mov    %esp,%ebp
  100bb6:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bb9:	83 ec 08             	sub    $0x8,%esp
  100bbc:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bbf:	50                   	push   %eax
  100bc0:	ff 75 08             	pushl  0x8(%ebp)
  100bc3:	e8 33 ff ff ff       	call   100afb <parse>
  100bc8:	83 c4 10             	add    $0x10,%esp
  100bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100bd2:	75 0a                	jne    100bde <runcmd+0x2b>
        return 0;
  100bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  100bd9:	e9 83 00 00 00       	jmp    100c61 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bde:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100be5:	eb 59                	jmp    100c40 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100be7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bed:	89 d0                	mov    %edx,%eax
  100bef:	01 c0                	add    %eax,%eax
  100bf1:	01 d0                	add    %edx,%eax
  100bf3:	c1 e0 02             	shl    $0x2,%eax
  100bf6:	05 00 e0 10 00       	add    $0x10e000,%eax
  100bfb:	8b 00                	mov    (%eax),%eax
  100bfd:	83 ec 08             	sub    $0x8,%esp
  100c00:	51                   	push   %ecx
  100c01:	50                   	push   %eax
  100c02:	e8 51 1f 00 00       	call   102b58 <strcmp>
  100c07:	83 c4 10             	add    $0x10,%esp
  100c0a:	85 c0                	test   %eax,%eax
  100c0c:	75 2e                	jne    100c3c <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c11:	89 d0                	mov    %edx,%eax
  100c13:	01 c0                	add    %eax,%eax
  100c15:	01 d0                	add    %edx,%eax
  100c17:	c1 e0 02             	shl    $0x2,%eax
  100c1a:	05 08 e0 10 00       	add    $0x10e008,%eax
  100c1f:	8b 10                	mov    (%eax),%edx
  100c21:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c24:	83 c0 04             	add    $0x4,%eax
  100c27:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c2a:	83 e9 01             	sub    $0x1,%ecx
  100c2d:	83 ec 04             	sub    $0x4,%esp
  100c30:	ff 75 0c             	pushl  0xc(%ebp)
  100c33:	50                   	push   %eax
  100c34:	51                   	push   %ecx
  100c35:	ff d2                	call   *%edx
  100c37:	83 c4 10             	add    $0x10,%esp
  100c3a:	eb 25                	jmp    100c61 <runcmd+0xae>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c43:	83 f8 02             	cmp    $0x2,%eax
  100c46:	76 9f                	jbe    100be7 <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c48:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c4b:	83 ec 08             	sub    $0x8,%esp
  100c4e:	50                   	push   %eax
  100c4f:	68 ff 37 10 00       	push   $0x1037ff
  100c54:	e8 f4 f5 ff ff       	call   10024d <cprintf>
  100c59:	83 c4 10             	add    $0x10,%esp
    return 0;
  100c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c61:	c9                   	leave  
  100c62:	c3                   	ret    

00100c63 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c63:	55                   	push   %ebp
  100c64:	89 e5                	mov    %esp,%ebp
  100c66:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c69:	83 ec 0c             	sub    $0xc,%esp
  100c6c:	68 18 38 10 00       	push   $0x103818
  100c71:	e8 d7 f5 ff ff       	call   10024d <cprintf>
  100c76:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
  100c79:	83 ec 0c             	sub    $0xc,%esp
  100c7c:	68 40 38 10 00       	push   $0x103840
  100c81:	e8 c7 f5 ff ff       	call   10024d <cprintf>
  100c86:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
  100c89:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c8d:	74 0e                	je     100c9d <kmonitor+0x3a>
        print_trapframe(tf);
  100c8f:	83 ec 0c             	sub    $0xc,%esp
  100c92:	ff 75 08             	pushl  0x8(%ebp)
  100c95:	e8 36 0d 00 00       	call   1019d0 <print_trapframe>
  100c9a:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c9d:	83 ec 0c             	sub    $0xc,%esp
  100ca0:	68 65 38 10 00       	push   $0x103865
  100ca5:	e8 47 f6 ff ff       	call   1002f1 <readline>
  100caa:	83 c4 10             	add    $0x10,%esp
  100cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cb4:	74 e7                	je     100c9d <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
  100cb6:	83 ec 08             	sub    $0x8,%esp
  100cb9:	ff 75 08             	pushl  0x8(%ebp)
  100cbc:	ff 75 f4             	pushl  -0xc(%ebp)
  100cbf:	e8 ef fe ff ff       	call   100bb3 <runcmd>
  100cc4:	83 c4 10             	add    $0x10,%esp
  100cc7:	85 c0                	test   %eax,%eax
  100cc9:	78 02                	js     100ccd <kmonitor+0x6a>
        if ((buf = readline("K> ")) != NULL) {
  100ccb:	eb d0                	jmp    100c9d <kmonitor+0x3a>
                break;
  100ccd:	90                   	nop
            }
        }
    }
}
  100cce:	90                   	nop
  100ccf:	c9                   	leave  
  100cd0:	c3                   	ret    

00100cd1 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100cd1:	55                   	push   %ebp
  100cd2:	89 e5                	mov    %esp,%ebp
  100cd4:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100cd7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100cde:	eb 3c                	jmp    100d1c <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100ce0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ce3:	89 d0                	mov    %edx,%eax
  100ce5:	01 c0                	add    %eax,%eax
  100ce7:	01 d0                	add    %edx,%eax
  100ce9:	c1 e0 02             	shl    $0x2,%eax
  100cec:	05 04 e0 10 00       	add    $0x10e004,%eax
  100cf1:	8b 08                	mov    (%eax),%ecx
  100cf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cf6:	89 d0                	mov    %edx,%eax
  100cf8:	01 c0                	add    %eax,%eax
  100cfa:	01 d0                	add    %edx,%eax
  100cfc:	c1 e0 02             	shl    $0x2,%eax
  100cff:	05 00 e0 10 00       	add    $0x10e000,%eax
  100d04:	8b 00                	mov    (%eax),%eax
  100d06:	83 ec 04             	sub    $0x4,%esp
  100d09:	51                   	push   %ecx
  100d0a:	50                   	push   %eax
  100d0b:	68 69 38 10 00       	push   $0x103869
  100d10:	e8 38 f5 ff ff       	call   10024d <cprintf>
  100d15:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NCOMMANDS; i ++) {
  100d18:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d1f:	83 f8 02             	cmp    $0x2,%eax
  100d22:	76 bc                	jbe    100ce0 <mon_help+0xf>
    }
    return 0;
  100d24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d29:	c9                   	leave  
  100d2a:	c3                   	ret    

00100d2b <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d2b:	55                   	push   %ebp
  100d2c:	89 e5                	mov    %esp,%ebp
  100d2e:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d31:	e8 b6 fb ff ff       	call   1008ec <print_kerninfo>
    return 0;
  100d36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d3b:	c9                   	leave  
  100d3c:	c3                   	ret    

00100d3d <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d3d:	55                   	push   %ebp
  100d3e:	89 e5                	mov    %esp,%ebp
  100d40:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d43:	e8 ee fc ff ff       	call   100a36 <print_stackframe>
    return 0;
  100d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d4d:	c9                   	leave  
  100d4e:	c3                   	ret    

00100d4f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d4f:	55                   	push   %ebp
  100d50:	89 e5                	mov    %esp,%ebp
  100d52:	83 ec 18             	sub    $0x18,%esp
  100d55:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100d5b:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d5f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100d63:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100d67:	ee                   	out    %al,(%dx)
  100d68:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d6e:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d72:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d76:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d7a:	ee                   	out    %al,(%dx)
  100d7b:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100d81:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100d85:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100d89:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d8d:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100d8e:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100d95:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100d98:	83 ec 0c             	sub    $0xc,%esp
  100d9b:	68 72 38 10 00       	push   $0x103872
  100da0:	e8 a8 f4 ff ff       	call   10024d <cprintf>
  100da5:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
  100da8:	83 ec 0c             	sub    $0xc,%esp
  100dab:	6a 00                	push   $0x0
  100dad:	e8 d2 08 00 00       	call   101684 <pic_enable>
  100db2:	83 c4 10             	add    $0x10,%esp
}
  100db5:	90                   	nop
  100db6:	c9                   	leave  
  100db7:	c3                   	ret    

00100db8 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100db8:	55                   	push   %ebp
  100db9:	89 e5                	mov    %esp,%ebp
  100dbb:	83 ec 10             	sub    $0x10,%esp
  100dbe:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100dc4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100dc8:	89 c2                	mov    %eax,%edx
  100dca:	ec                   	in     (%dx),%al
  100dcb:	88 45 f1             	mov    %al,-0xf(%ebp)
  100dce:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100dd4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100dd8:	89 c2                	mov    %eax,%edx
  100dda:	ec                   	in     (%dx),%al
  100ddb:	88 45 f5             	mov    %al,-0xb(%ebp)
  100dde:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100de4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100de8:	89 c2                	mov    %eax,%edx
  100dea:	ec                   	in     (%dx),%al
  100deb:	88 45 f9             	mov    %al,-0x7(%ebp)
  100dee:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100df4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100df8:	89 c2                	mov    %eax,%edx
  100dfa:	ec                   	in     (%dx),%al
  100dfb:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100dfe:	90                   	nop
  100dff:	c9                   	leave  
  100e00:	c3                   	ret    

00100e01 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e01:	55                   	push   %ebp
  100e02:	89 e5                	mov    %esp,%ebp
  100e04:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;
  100e07:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e11:	0f b7 00             	movzwl (%eax),%eax
  100e14:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e18:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e1b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e20:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e23:	0f b7 00             	movzwl (%eax),%eax
  100e26:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e2a:	74 12                	je     100e3e <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;
  100e2c:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100e33:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e3a:	b4 03 
  100e3c:	eb 13                	jmp    100e51 <cga_init+0x50>
    } else {
        *cp = was;
  100e3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e41:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e45:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100e48:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e4f:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100e51:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e58:	0f b7 c0             	movzwl %ax,%eax
  100e5b:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100e5f:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e63:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100e67:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100e6b:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100e6c:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e73:	83 c0 01             	add    $0x1,%eax
  100e76:	0f b7 c0             	movzwl %ax,%eax
  100e79:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e7d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100e81:	89 c2                	mov    %eax,%edx
  100e83:	ec                   	in     (%dx),%al
  100e84:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100e87:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100e8b:	0f b6 c0             	movzbl %al,%eax
  100e8e:	c1 e0 08             	shl    $0x8,%eax
  100e91:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100e94:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e9b:	0f b7 c0             	movzwl %ax,%eax
  100e9e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100ea2:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ea6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eaa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100eae:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100eaf:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100eb6:	83 c0 01             	add    $0x1,%eax
  100eb9:	0f b7 c0             	movzwl %ax,%eax
  100ebc:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ec0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ec4:	89 c2                	mov    %eax,%edx
  100ec6:	ec                   	in     (%dx),%al
  100ec7:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100eca:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100ece:	0f b6 c0             	movzbl %al,%eax
  100ed1:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100ed4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ed7:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;
  100edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100edf:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100ee5:	90                   	nop
  100ee6:	c9                   	leave  
  100ee7:	c3                   	ret    

00100ee8 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100ee8:	55                   	push   %ebp
  100ee9:	89 e5                	mov    %esp,%ebp
  100eeb:	83 ec 38             	sub    $0x38,%esp
  100eee:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100ef4:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ef8:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100efc:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f00:	ee                   	out    %al,(%dx)
  100f01:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f07:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  100f0b:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f0f:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f13:	ee                   	out    %al,(%dx)
  100f14:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f1a:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  100f1e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f22:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f26:	ee                   	out    %al,(%dx)
  100f27:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f2d:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f31:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f35:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f39:	ee                   	out    %al,(%dx)
  100f3a:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100f40:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  100f44:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f48:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f4c:	ee                   	out    %al,(%dx)
  100f4d:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100f53:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  100f57:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f5b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f5f:	ee                   	out    %al,(%dx)
  100f60:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f66:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  100f6a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f6e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f72:	ee                   	out    %al,(%dx)
  100f73:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f79:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f7d:	89 c2                	mov    %eax,%edx
  100f7f:	ec                   	in     (%dx),%al
  100f80:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f83:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100f87:	3c ff                	cmp    $0xff,%al
  100f89:	0f 95 c0             	setne  %al
  100f8c:	0f b6 c0             	movzbl %al,%eax
  100f8f:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100f94:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f9a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f9e:	89 c2                	mov    %eax,%edx
  100fa0:	ec                   	in     (%dx),%al
  100fa1:	88 45 f1             	mov    %al,-0xf(%ebp)
  100fa4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  100faa:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100fae:	89 c2                	mov    %eax,%edx
  100fb0:	ec                   	in     (%dx),%al
  100fb1:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fb4:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fb9:	85 c0                	test   %eax,%eax
  100fbb:	74 0d                	je     100fca <serial_init+0xe2>
        pic_enable(IRQ_COM1);
  100fbd:	83 ec 0c             	sub    $0xc,%esp
  100fc0:	6a 04                	push   $0x4
  100fc2:	e8 bd 06 00 00       	call   101684 <pic_enable>
  100fc7:	83 c4 10             	add    $0x10,%esp
    }
}
  100fca:	90                   	nop
  100fcb:	c9                   	leave  
  100fcc:	c3                   	ret    

00100fcd <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fcd:	55                   	push   %ebp
  100fce:	89 e5                	mov    %esp,%ebp
  100fd0:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fda:	eb 09                	jmp    100fe5 <lpt_putc_sub+0x18>
        delay();
  100fdc:	e8 d7 fd ff ff       	call   100db8 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fe1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100fe5:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  100feb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100fef:	89 c2                	mov    %eax,%edx
  100ff1:	ec                   	in     (%dx),%al
  100ff2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  100ff5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  100ff9:	84 c0                	test   %al,%al
  100ffb:	78 09                	js     101006 <lpt_putc_sub+0x39>
  100ffd:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101004:	7e d6                	jle    100fdc <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101006:	8b 45 08             	mov    0x8(%ebp),%eax
  101009:	0f b6 c0             	movzbl %al,%eax
  10100c:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101012:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101015:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101019:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10101d:	ee                   	out    %al,(%dx)
  10101e:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101024:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101028:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10102c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101030:	ee                   	out    %al,(%dx)
  101031:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101037:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  10103b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10103f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101043:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101044:	90                   	nop
  101045:	c9                   	leave  
  101046:	c3                   	ret    

00101047 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101047:	55                   	push   %ebp
  101048:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  10104a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10104e:	74 0d                	je     10105d <lpt_putc+0x16>
        lpt_putc_sub(c);
  101050:	ff 75 08             	pushl  0x8(%ebp)
  101053:	e8 75 ff ff ff       	call   100fcd <lpt_putc_sub>
  101058:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10105b:	eb 1e                	jmp    10107b <lpt_putc+0x34>
        lpt_putc_sub('\b');
  10105d:	6a 08                	push   $0x8
  10105f:	e8 69 ff ff ff       	call   100fcd <lpt_putc_sub>
  101064:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
  101067:	6a 20                	push   $0x20
  101069:	e8 5f ff ff ff       	call   100fcd <lpt_putc_sub>
  10106e:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
  101071:	6a 08                	push   $0x8
  101073:	e8 55 ff ff ff       	call   100fcd <lpt_putc_sub>
  101078:	83 c4 04             	add    $0x4,%esp
}
  10107b:	90                   	nop
  10107c:	c9                   	leave  
  10107d:	c3                   	ret    

0010107e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10107e:	55                   	push   %ebp
  10107f:	89 e5                	mov    %esp,%ebp
  101081:	53                   	push   %ebx
  101082:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101085:	8b 45 08             	mov    0x8(%ebp),%eax
  101088:	b0 00                	mov    $0x0,%al
  10108a:	85 c0                	test   %eax,%eax
  10108c:	75 07                	jne    101095 <cga_putc+0x17>
        c |= 0x0700;
  10108e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101095:	8b 45 08             	mov    0x8(%ebp),%eax
  101098:	0f b6 c0             	movzbl %al,%eax
  10109b:	83 f8 0a             	cmp    $0xa,%eax
  10109e:	74 52                	je     1010f2 <cga_putc+0x74>
  1010a0:	83 f8 0d             	cmp    $0xd,%eax
  1010a3:	74 5d                	je     101102 <cga_putc+0x84>
  1010a5:	83 f8 08             	cmp    $0x8,%eax
  1010a8:	0f 85 8e 00 00 00    	jne    10113c <cga_putc+0xbe>
    case '\b':
        if (crt_pos > 0) {
  1010ae:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010b5:	66 85 c0             	test   %ax,%ax
  1010b8:	0f 84 a4 00 00 00    	je     101162 <cga_putc+0xe4>
            crt_pos --;
  1010be:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010c5:	83 e8 01             	sub    $0x1,%eax
  1010c8:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1010d1:	b0 00                	mov    $0x0,%al
  1010d3:	83 c8 20             	or     $0x20,%eax
  1010d6:	89 c1                	mov    %eax,%ecx
  1010d8:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010dd:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  1010e4:	0f b7 d2             	movzwl %dx,%edx
  1010e7:	01 d2                	add    %edx,%edx
  1010e9:	01 d0                	add    %edx,%eax
  1010eb:	89 ca                	mov    %ecx,%edx
  1010ed:	66 89 10             	mov    %dx,(%eax)
        }
        break;
  1010f0:	eb 70                	jmp    101162 <cga_putc+0xe4>
    case '\n':
        crt_pos += CRT_COLS;
  1010f2:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010f9:	83 c0 50             	add    $0x50,%eax
  1010fc:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101102:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101109:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101110:	0f b7 c1             	movzwl %cx,%eax
  101113:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101119:	c1 e8 10             	shr    $0x10,%eax
  10111c:	89 c2                	mov    %eax,%edx
  10111e:	66 c1 ea 06          	shr    $0x6,%dx
  101122:	89 d0                	mov    %edx,%eax
  101124:	c1 e0 02             	shl    $0x2,%eax
  101127:	01 d0                	add    %edx,%eax
  101129:	c1 e0 04             	shl    $0x4,%eax
  10112c:	29 c1                	sub    %eax,%ecx
  10112e:	89 ca                	mov    %ecx,%edx
  101130:	89 d8                	mov    %ebx,%eax
  101132:	29 d0                	sub    %edx,%eax
  101134:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  10113a:	eb 27                	jmp    101163 <cga_putc+0xe5>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10113c:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101142:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101149:	8d 50 01             	lea    0x1(%eax),%edx
  10114c:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101153:	0f b7 c0             	movzwl %ax,%eax
  101156:	01 c0                	add    %eax,%eax
  101158:	01 c8                	add    %ecx,%eax
  10115a:	8b 55 08             	mov    0x8(%ebp),%edx
  10115d:	66 89 10             	mov    %dx,(%eax)
        break;
  101160:	eb 01                	jmp    101163 <cga_putc+0xe5>
        break;
  101162:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101163:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10116a:	66 3d cf 07          	cmp    $0x7cf,%ax
  10116e:	76 59                	jbe    1011c9 <cga_putc+0x14b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101170:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101175:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10117b:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101180:	83 ec 04             	sub    $0x4,%esp
  101183:	68 00 0f 00 00       	push   $0xf00
  101188:	52                   	push   %edx
  101189:	50                   	push   %eax
  10118a:	e8 68 1c 00 00       	call   102df7 <memmove>
  10118f:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101192:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101199:	eb 15                	jmp    1011b0 <cga_putc+0x132>
            crt_buf[i] = 0x0700 | ' ';
  10119b:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011a3:	01 d2                	add    %edx,%edx
  1011a5:	01 d0                	add    %edx,%eax
  1011a7:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011b0:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011b7:	7e e2                	jle    10119b <cga_putc+0x11d>
        }
        crt_pos -= CRT_COLS;
  1011b9:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011c0:	83 e8 50             	sub    $0x50,%eax
  1011c3:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011c9:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011d0:	0f b7 c0             	movzwl %ax,%eax
  1011d3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1011d7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  1011db:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1011df:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1011e3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  1011e4:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011eb:	66 c1 e8 08          	shr    $0x8,%ax
  1011ef:	0f b6 c0             	movzbl %al,%eax
  1011f2:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  1011f9:	83 c2 01             	add    $0x1,%edx
  1011fc:	0f b7 d2             	movzwl %dx,%edx
  1011ff:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  101203:	88 45 e9             	mov    %al,-0x17(%ebp)
  101206:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10120a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10120e:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10120f:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101216:	0f b7 c0             	movzwl %ax,%eax
  101219:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10121d:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  101221:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101225:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101229:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10122a:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101231:	0f b6 c0             	movzbl %al,%eax
  101234:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10123b:	83 c2 01             	add    $0x1,%edx
  10123e:	0f b7 d2             	movzwl %dx,%edx
  101241:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101245:	88 45 f1             	mov    %al,-0xf(%ebp)
  101248:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10124c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101250:	ee                   	out    %al,(%dx)
}
  101251:	90                   	nop
  101252:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101255:	c9                   	leave  
  101256:	c3                   	ret    

00101257 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101257:	55                   	push   %ebp
  101258:	89 e5                	mov    %esp,%ebp
  10125a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10125d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101264:	eb 09                	jmp    10126f <serial_putc_sub+0x18>
        delay();
  101266:	e8 4d fb ff ff       	call   100db8 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10126b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10126f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101275:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101279:	89 c2                	mov    %eax,%edx
  10127b:	ec                   	in     (%dx),%al
  10127c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10127f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101283:	0f b6 c0             	movzbl %al,%eax
  101286:	83 e0 20             	and    $0x20,%eax
  101289:	85 c0                	test   %eax,%eax
  10128b:	75 09                	jne    101296 <serial_putc_sub+0x3f>
  10128d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101294:	7e d0                	jle    101266 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101296:	8b 45 08             	mov    0x8(%ebp),%eax
  101299:	0f b6 c0             	movzbl %al,%eax
  10129c:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012a2:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012a5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012a9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
}
  1012ae:	90                   	nop
  1012af:	c9                   	leave  
  1012b0:	c3                   	ret    

001012b1 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012b1:	55                   	push   %ebp
  1012b2:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  1012b4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012b8:	74 0d                	je     1012c7 <serial_putc+0x16>
        serial_putc_sub(c);
  1012ba:	ff 75 08             	pushl  0x8(%ebp)
  1012bd:	e8 95 ff ff ff       	call   101257 <serial_putc_sub>
  1012c2:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1012c5:	eb 1e                	jmp    1012e5 <serial_putc+0x34>
        serial_putc_sub('\b');
  1012c7:	6a 08                	push   $0x8
  1012c9:	e8 89 ff ff ff       	call   101257 <serial_putc_sub>
  1012ce:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
  1012d1:	6a 20                	push   $0x20
  1012d3:	e8 7f ff ff ff       	call   101257 <serial_putc_sub>
  1012d8:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
  1012db:	6a 08                	push   $0x8
  1012dd:	e8 75 ff ff ff       	call   101257 <serial_putc_sub>
  1012e2:	83 c4 04             	add    $0x4,%esp
}
  1012e5:	90                   	nop
  1012e6:	c9                   	leave  
  1012e7:	c3                   	ret    

001012e8 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1012e8:	55                   	push   %ebp
  1012e9:	89 e5                	mov    %esp,%ebp
  1012eb:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1012ee:	eb 33                	jmp    101323 <cons_intr+0x3b>
        if (c != 0) {
  1012f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1012f4:	74 2d                	je     101323 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1012f6:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1012fb:	8d 50 01             	lea    0x1(%eax),%edx
  1012fe:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  101304:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101307:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10130d:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101312:	3d 00 02 00 00       	cmp    $0x200,%eax
  101317:	75 0a                	jne    101323 <cons_intr+0x3b>
                cons.wpos = 0;
  101319:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101320:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101323:	8b 45 08             	mov    0x8(%ebp),%eax
  101326:	ff d0                	call   *%eax
  101328:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10132b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  10132f:	75 bf                	jne    1012f0 <cons_intr+0x8>
            }
        }
    }
}
  101331:	90                   	nop
  101332:	c9                   	leave  
  101333:	c3                   	ret    

00101334 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101334:	55                   	push   %ebp
  101335:	89 e5                	mov    %esp,%ebp
  101337:	83 ec 10             	sub    $0x10,%esp
  10133a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101340:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101344:	89 c2                	mov    %eax,%edx
  101346:	ec                   	in     (%dx),%al
  101347:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10134a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10134e:	0f b6 c0             	movzbl %al,%eax
  101351:	83 e0 01             	and    $0x1,%eax
  101354:	85 c0                	test   %eax,%eax
  101356:	75 07                	jne    10135f <serial_proc_data+0x2b>
        return -1;
  101358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10135d:	eb 2a                	jmp    101389 <serial_proc_data+0x55>
  10135f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101365:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101369:	89 c2                	mov    %eax,%edx
  10136b:	ec                   	in     (%dx),%al
  10136c:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  10136f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101373:	0f b6 c0             	movzbl %al,%eax
  101376:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101379:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10137d:	75 07                	jne    101386 <serial_proc_data+0x52>
        c = '\b';
  10137f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101386:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101389:	c9                   	leave  
  10138a:	c3                   	ret    

0010138b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10138b:	55                   	push   %ebp
  10138c:	89 e5                	mov    %esp,%ebp
  10138e:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
  101391:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  101396:	85 c0                	test   %eax,%eax
  101398:	74 10                	je     1013aa <serial_intr+0x1f>
        cons_intr(serial_proc_data);
  10139a:	83 ec 0c             	sub    $0xc,%esp
  10139d:	68 34 13 10 00       	push   $0x101334
  1013a2:	e8 41 ff ff ff       	call   1012e8 <cons_intr>
  1013a7:	83 c4 10             	add    $0x10,%esp
    }
}
  1013aa:	90                   	nop
  1013ab:	c9                   	leave  
  1013ac:	c3                   	ret    

001013ad <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013ad:	55                   	push   %ebp
  1013ae:	89 e5                	mov    %esp,%ebp
  1013b0:	83 ec 28             	sub    $0x28,%esp
  1013b3:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013b9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013bd:	89 c2                	mov    %eax,%edx
  1013bf:	ec                   	in     (%dx),%al
  1013c0:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013c3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013c7:	0f b6 c0             	movzbl %al,%eax
  1013ca:	83 e0 01             	and    $0x1,%eax
  1013cd:	85 c0                	test   %eax,%eax
  1013cf:	75 0a                	jne    1013db <kbd_proc_data+0x2e>
        return -1;
  1013d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013d6:	e9 5d 01 00 00       	jmp    101538 <kbd_proc_data+0x18b>
  1013db:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1013e5:	89 c2                	mov    %eax,%edx
  1013e7:	ec                   	in     (%dx),%al
  1013e8:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013eb:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1013ef:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1013f2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1013f6:	75 17                	jne    10140f <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  1013f8:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1013fd:	83 c8 40             	or     $0x40,%eax
  101400:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101405:	b8 00 00 00 00       	mov    $0x0,%eax
  10140a:	e9 29 01 00 00       	jmp    101538 <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
  10140f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101413:	84 c0                	test   %al,%al
  101415:	79 47                	jns    10145e <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101417:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10141c:	83 e0 40             	and    $0x40,%eax
  10141f:	85 c0                	test   %eax,%eax
  101421:	75 09                	jne    10142c <kbd_proc_data+0x7f>
  101423:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101427:	83 e0 7f             	and    $0x7f,%eax
  10142a:	eb 04                	jmp    101430 <kbd_proc_data+0x83>
  10142c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101430:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101433:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101437:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10143e:	83 c8 40             	or     $0x40,%eax
  101441:	0f b6 c0             	movzbl %al,%eax
  101444:	f7 d0                	not    %eax
  101446:	89 c2                	mov    %eax,%edx
  101448:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10144d:	21 d0                	and    %edx,%eax
  10144f:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101454:	b8 00 00 00 00       	mov    $0x0,%eax
  101459:	e9 da 00 00 00       	jmp    101538 <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
  10145e:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101463:	83 e0 40             	and    $0x40,%eax
  101466:	85 c0                	test   %eax,%eax
  101468:	74 11                	je     10147b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10146a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10146e:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101473:	83 e0 bf             	and    $0xffffffbf,%eax
  101476:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  10147b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10147f:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101486:	0f b6 d0             	movzbl %al,%edx
  101489:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10148e:	09 d0                	or     %edx,%eax
  101490:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101499:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014a0:	0f b6 d0             	movzbl %al,%edx
  1014a3:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014a8:	31 d0                	xor    %edx,%eax
  1014aa:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014af:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014b4:	83 e0 03             	and    $0x3,%eax
  1014b7:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014be:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c2:	01 d0                	add    %edx,%eax
  1014c4:	0f b6 00             	movzbl (%eax),%eax
  1014c7:	0f b6 c0             	movzbl %al,%eax
  1014ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014cd:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014d2:	83 e0 08             	and    $0x8,%eax
  1014d5:	85 c0                	test   %eax,%eax
  1014d7:	74 22                	je     1014fb <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014d9:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014dd:	7e 0c                	jle    1014eb <kbd_proc_data+0x13e>
  1014df:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1014e3:	7f 06                	jg     1014eb <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  1014e5:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1014e9:	eb 10                	jmp    1014fb <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  1014eb:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1014ef:	7e 0a                	jle    1014fb <kbd_proc_data+0x14e>
  1014f1:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1014f5:	7f 04                	jg     1014fb <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  1014f7:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1014fb:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101500:	f7 d0                	not    %eax
  101502:	83 e0 06             	and    $0x6,%eax
  101505:	85 c0                	test   %eax,%eax
  101507:	75 2c                	jne    101535 <kbd_proc_data+0x188>
  101509:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101510:	75 23                	jne    101535 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
  101512:	83 ec 0c             	sub    $0xc,%esp
  101515:	68 8d 38 10 00       	push   $0x10388d
  10151a:	e8 2e ed ff ff       	call   10024d <cprintf>
  10151f:	83 c4 10             	add    $0x10,%esp
  101522:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101528:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10152c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101530:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101534:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101538:	c9                   	leave  
  101539:	c3                   	ret    

0010153a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10153a:	55                   	push   %ebp
  10153b:	89 e5                	mov    %esp,%ebp
  10153d:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
  101540:	83 ec 0c             	sub    $0xc,%esp
  101543:	68 ad 13 10 00       	push   $0x1013ad
  101548:	e8 9b fd ff ff       	call   1012e8 <cons_intr>
  10154d:	83 c4 10             	add    $0x10,%esp
}
  101550:	90                   	nop
  101551:	c9                   	leave  
  101552:	c3                   	ret    

00101553 <kbd_init>:

static void
kbd_init(void) {
  101553:	55                   	push   %ebp
  101554:	89 e5                	mov    %esp,%ebp
  101556:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
  101559:	e8 dc ff ff ff       	call   10153a <kbd_intr>
    pic_enable(IRQ_KBD);
  10155e:	83 ec 0c             	sub    $0xc,%esp
  101561:	6a 01                	push   $0x1
  101563:	e8 1c 01 00 00       	call   101684 <pic_enable>
  101568:	83 c4 10             	add    $0x10,%esp
}
  10156b:	90                   	nop
  10156c:	c9                   	leave  
  10156d:	c3                   	ret    

0010156e <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10156e:	55                   	push   %ebp
  10156f:	89 e5                	mov    %esp,%ebp
  101571:	83 ec 08             	sub    $0x8,%esp
    cga_init();
  101574:	e8 88 f8 ff ff       	call   100e01 <cga_init>
    serial_init();
  101579:	e8 6a f9 ff ff       	call   100ee8 <serial_init>
    kbd_init();
  10157e:	e8 d0 ff ff ff       	call   101553 <kbd_init>
    if (!serial_exists) {
  101583:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  101588:	85 c0                	test   %eax,%eax
  10158a:	75 10                	jne    10159c <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
  10158c:	83 ec 0c             	sub    $0xc,%esp
  10158f:	68 99 38 10 00       	push   $0x103899
  101594:	e8 b4 ec ff ff       	call   10024d <cprintf>
  101599:	83 c4 10             	add    $0x10,%esp
    }
}
  10159c:	90                   	nop
  10159d:	c9                   	leave  
  10159e:	c3                   	ret    

0010159f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10159f:	55                   	push   %ebp
  1015a0:	89 e5                	mov    %esp,%ebp
  1015a2:	83 ec 08             	sub    $0x8,%esp
    lpt_putc(c);
  1015a5:	ff 75 08             	pushl  0x8(%ebp)
  1015a8:	e8 9a fa ff ff       	call   101047 <lpt_putc>
  1015ad:	83 c4 04             	add    $0x4,%esp
    cga_putc(c);
  1015b0:	83 ec 0c             	sub    $0xc,%esp
  1015b3:	ff 75 08             	pushl  0x8(%ebp)
  1015b6:	e8 c3 fa ff ff       	call   10107e <cga_putc>
  1015bb:	83 c4 10             	add    $0x10,%esp
    serial_putc(c);
  1015be:	83 ec 0c             	sub    $0xc,%esp
  1015c1:	ff 75 08             	pushl  0x8(%ebp)
  1015c4:	e8 e8 fc ff ff       	call   1012b1 <serial_putc>
  1015c9:	83 c4 10             	add    $0x10,%esp
}
  1015cc:	90                   	nop
  1015cd:	c9                   	leave  
  1015ce:	c3                   	ret    

001015cf <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015cf:	55                   	push   %ebp
  1015d0:	89 e5                	mov    %esp,%ebp
  1015d2:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015d5:	e8 b1 fd ff ff       	call   10138b <serial_intr>
    kbd_intr();
  1015da:	e8 5b ff ff ff       	call   10153a <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015df:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015e5:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015ea:	39 c2                	cmp    %eax,%edx
  1015ec:	74 36                	je     101624 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015ee:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015f3:	8d 50 01             	lea    0x1(%eax),%edx
  1015f6:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  1015fc:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  101603:	0f b6 c0             	movzbl %al,%eax
  101606:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101609:	a1 80 f0 10 00       	mov    0x10f080,%eax
  10160e:	3d 00 02 00 00       	cmp    $0x200,%eax
  101613:	75 0a                	jne    10161f <cons_getc+0x50>
            cons.rpos = 0;
  101615:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  10161c:	00 00 00 
        }
        return c;
  10161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101622:	eb 05                	jmp    101629 <cons_getc+0x5a>
    }
    return 0;
  101624:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101629:	c9                   	leave  
  10162a:	c3                   	ret    

0010162b <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10162b:	55                   	push   %ebp
  10162c:	89 e5                	mov    %esp,%ebp
  10162e:	83 ec 14             	sub    $0x14,%esp
  101631:	8b 45 08             	mov    0x8(%ebp),%eax
  101634:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101638:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10163c:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  101642:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101647:	85 c0                	test   %eax,%eax
  101649:	74 36                	je     101681 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  10164b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10164f:	0f b6 c0             	movzbl %al,%eax
  101652:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  101658:	88 45 f9             	mov    %al,-0x7(%ebp)
  10165b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10165f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101663:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101664:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101668:	66 c1 e8 08          	shr    $0x8,%ax
  10166c:	0f b6 c0             	movzbl %al,%eax
  10166f:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  101675:	88 45 fd             	mov    %al,-0x3(%ebp)
  101678:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10167c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101680:	ee                   	out    %al,(%dx)
    }
}
  101681:	90                   	nop
  101682:	c9                   	leave  
  101683:	c3                   	ret    

00101684 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101684:	55                   	push   %ebp
  101685:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
  101687:	8b 45 08             	mov    0x8(%ebp),%eax
  10168a:	ba 01 00 00 00       	mov    $0x1,%edx
  10168f:	89 c1                	mov    %eax,%ecx
  101691:	d3 e2                	shl    %cl,%edx
  101693:	89 d0                	mov    %edx,%eax
  101695:	f7 d0                	not    %eax
  101697:	89 c2                	mov    %eax,%edx
  101699:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016a0:	21 d0                	and    %edx,%eax
  1016a2:	0f b7 c0             	movzwl %ax,%eax
  1016a5:	50                   	push   %eax
  1016a6:	e8 80 ff ff ff       	call   10162b <pic_setmask>
  1016ab:	83 c4 04             	add    $0x4,%esp
}
  1016ae:	90                   	nop
  1016af:	c9                   	leave  
  1016b0:	c3                   	ret    

001016b1 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016b1:	55                   	push   %ebp
  1016b2:	89 e5                	mov    %esp,%ebp
  1016b4:	83 ec 40             	sub    $0x40,%esp
    did_init = 1;
  1016b7:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016be:	00 00 00 
  1016c1:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1016c7:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  1016cb:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1016cf:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1016d3:	ee                   	out    %al,(%dx)
  1016d4:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1016da:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  1016de:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1016e2:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1016e6:	ee                   	out    %al,(%dx)
  1016e7:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1016ed:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  1016f1:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1016f5:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1016f9:	ee                   	out    %al,(%dx)
  1016fa:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101700:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  101704:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101708:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10170c:	ee                   	out    %al,(%dx)
  10170d:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101713:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  101717:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10171b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10171f:	ee                   	out    %al,(%dx)
  101720:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  101726:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  10172a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10172e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101732:	ee                   	out    %al,(%dx)
  101733:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101739:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  10173d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101741:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101745:	ee                   	out    %al,(%dx)
  101746:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  10174c:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  101750:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101754:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101758:	ee                   	out    %al,(%dx)
  101759:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  10175f:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  101763:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101767:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10176b:	ee                   	out    %al,(%dx)
  10176c:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101772:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  101776:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10177a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10177e:	ee                   	out    %al,(%dx)
  10177f:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101785:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  101789:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10178d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101791:	ee                   	out    %al,(%dx)
  101792:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101798:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  10179c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1017a0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017a4:	ee                   	out    %al,(%dx)
  1017a5:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1017ab:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  1017af:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1017b3:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017b7:	ee                   	out    %al,(%dx)
  1017b8:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1017be:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  1017c2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1017c6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1017ca:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017cb:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017d2:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017d6:	74 13                	je     1017eb <pic_init+0x13a>
        pic_setmask(irq_mask);
  1017d8:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017df:	0f b7 c0             	movzwl %ax,%eax
  1017e2:	50                   	push   %eax
  1017e3:	e8 43 fe ff ff       	call   10162b <pic_setmask>
  1017e8:	83 c4 04             	add    $0x4,%esp
    }
}
  1017eb:	90                   	nop
  1017ec:	c9                   	leave  
  1017ed:	c3                   	ret    

001017ee <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1017ee:	55                   	push   %ebp
  1017ef:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1017f1:	fb                   	sti    
    sti();
}
  1017f2:	90                   	nop
  1017f3:	5d                   	pop    %ebp
  1017f4:	c3                   	ret    

001017f5 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1017f5:	55                   	push   %ebp
  1017f6:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  1017f8:	fa                   	cli    
    cli();
}
  1017f9:	90                   	nop
  1017fa:	5d                   	pop    %ebp
  1017fb:	c3                   	ret    

001017fc <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  1017fc:	55                   	push   %ebp
  1017fd:	89 e5                	mov    %esp,%ebp
  1017ff:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101802:	83 ec 08             	sub    $0x8,%esp
  101805:	6a 64                	push   $0x64
  101807:	68 c0 38 10 00       	push   $0x1038c0
  10180c:	e8 3c ea ff ff       	call   10024d <cprintf>
  101811:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101814:	90                   	nop
  101815:	c9                   	leave  
  101816:	c3                   	ret    

00101817 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101817:	55                   	push   %ebp
  101818:	89 e5                	mov    %esp,%ebp
  10181a:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10181d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101824:	e9 c3 00 00 00       	jmp    1018ec <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101829:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10182c:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101833:	89 c2                	mov    %eax,%edx
  101835:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101838:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  10183f:	00 
  101840:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101843:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  10184a:	00 08 00 
  10184d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101850:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101857:	00 
  101858:	83 e2 e0             	and    $0xffffffe0,%edx
  10185b:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101862:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101865:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10186c:	00 
  10186d:	83 e2 1f             	and    $0x1f,%edx
  101870:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101877:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10187a:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101881:	00 
  101882:	83 e2 f0             	and    $0xfffffff0,%edx
  101885:	83 ca 0e             	or     $0xe,%edx
  101888:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  10188f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101892:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101899:	00 
  10189a:	83 e2 ef             	and    $0xffffffef,%edx
  10189d:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018a7:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018ae:	00 
  1018af:	83 e2 9f             	and    $0xffffff9f,%edx
  1018b2:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018bc:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018c3:	00 
  1018c4:	83 ca 80             	or     $0xffffff80,%edx
  1018c7:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d1:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018d8:	c1 e8 10             	shr    $0x10,%eax
  1018db:	89 c2                	mov    %eax,%edx
  1018dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e0:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  1018e7:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018e8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1018ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  1018f4:	0f 86 2f ff ff ff    	jbe    101829 <idt_init+0x12>
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1018fa:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  1018ff:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  101905:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  10190c:	08 00 
  10190e:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101915:	83 e0 e0             	and    $0xffffffe0,%eax
  101918:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10191d:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101924:	83 e0 1f             	and    $0x1f,%eax
  101927:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10192c:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101933:	83 e0 f0             	and    $0xfffffff0,%eax
  101936:	83 c8 0e             	or     $0xe,%eax
  101939:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10193e:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101945:	83 e0 ef             	and    $0xffffffef,%eax
  101948:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10194d:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101954:	83 c8 60             	or     $0x60,%eax
  101957:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10195c:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101963:	83 c8 80             	or     $0xffffff80,%eax
  101966:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10196b:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101970:	c1 e8 10             	shr    $0x10,%eax
  101973:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  101979:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101980:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101983:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
  101986:	90                   	nop
  101987:	c9                   	leave  
  101988:	c3                   	ret    

00101989 <trapname>:

static const char *
trapname(int trapno) {
  101989:	55                   	push   %ebp
  10198a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  10198c:	8b 45 08             	mov    0x8(%ebp),%eax
  10198f:	83 f8 13             	cmp    $0x13,%eax
  101992:	77 0c                	ja     1019a0 <trapname+0x17>
        return excnames[trapno];
  101994:	8b 45 08             	mov    0x8(%ebp),%eax
  101997:	8b 04 85 20 3c 10 00 	mov    0x103c20(,%eax,4),%eax
  10199e:	eb 18                	jmp    1019b8 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019a0:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019a4:	7e 0d                	jle    1019b3 <trapname+0x2a>
  1019a6:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019aa:	7f 07                	jg     1019b3 <trapname+0x2a>
        return "Hardware Interrupt";
  1019ac:	b8 ca 38 10 00       	mov    $0x1038ca,%eax
  1019b1:	eb 05                	jmp    1019b8 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019b3:	b8 dd 38 10 00       	mov    $0x1038dd,%eax
}
  1019b8:	5d                   	pop    %ebp
  1019b9:	c3                   	ret    

001019ba <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019ba:	55                   	push   %ebp
  1019bb:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019c4:	66 83 f8 08          	cmp    $0x8,%ax
  1019c8:	0f 94 c0             	sete   %al
  1019cb:	0f b6 c0             	movzbl %al,%eax
}
  1019ce:	5d                   	pop    %ebp
  1019cf:	c3                   	ret    

001019d0 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019d0:	55                   	push   %ebp
  1019d1:	89 e5                	mov    %esp,%ebp
  1019d3:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
  1019d6:	83 ec 08             	sub    $0x8,%esp
  1019d9:	ff 75 08             	pushl  0x8(%ebp)
  1019dc:	68 1e 39 10 00       	push   $0x10391e
  1019e1:	e8 67 e8 ff ff       	call   10024d <cprintf>
  1019e6:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
  1019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ec:	83 ec 0c             	sub    $0xc,%esp
  1019ef:	50                   	push   %eax
  1019f0:	e8 b6 01 00 00       	call   101bab <print_regs>
  1019f5:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  1019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1019fb:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1019ff:	0f b7 c0             	movzwl %ax,%eax
  101a02:	83 ec 08             	sub    $0x8,%esp
  101a05:	50                   	push   %eax
  101a06:	68 2f 39 10 00       	push   $0x10392f
  101a0b:	e8 3d e8 ff ff       	call   10024d <cprintf>
  101a10:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a13:	8b 45 08             	mov    0x8(%ebp),%eax
  101a16:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a1a:	0f b7 c0             	movzwl %ax,%eax
  101a1d:	83 ec 08             	sub    $0x8,%esp
  101a20:	50                   	push   %eax
  101a21:	68 42 39 10 00       	push   $0x103942
  101a26:	e8 22 e8 ff ff       	call   10024d <cprintf>
  101a2b:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a31:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a35:	0f b7 c0             	movzwl %ax,%eax
  101a38:	83 ec 08             	sub    $0x8,%esp
  101a3b:	50                   	push   %eax
  101a3c:	68 55 39 10 00       	push   $0x103955
  101a41:	e8 07 e8 ff ff       	call   10024d <cprintf>
  101a46:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a49:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a50:	0f b7 c0             	movzwl %ax,%eax
  101a53:	83 ec 08             	sub    $0x8,%esp
  101a56:	50                   	push   %eax
  101a57:	68 68 39 10 00       	push   $0x103968
  101a5c:	e8 ec e7 ff ff       	call   10024d <cprintf>
  101a61:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a64:	8b 45 08             	mov    0x8(%ebp),%eax
  101a67:	8b 40 30             	mov    0x30(%eax),%eax
  101a6a:	83 ec 0c             	sub    $0xc,%esp
  101a6d:	50                   	push   %eax
  101a6e:	e8 16 ff ff ff       	call   101989 <trapname>
  101a73:	83 c4 10             	add    $0x10,%esp
  101a76:	89 c2                	mov    %eax,%edx
  101a78:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7b:	8b 40 30             	mov    0x30(%eax),%eax
  101a7e:	83 ec 04             	sub    $0x4,%esp
  101a81:	52                   	push   %edx
  101a82:	50                   	push   %eax
  101a83:	68 7b 39 10 00       	push   $0x10397b
  101a88:	e8 c0 e7 ff ff       	call   10024d <cprintf>
  101a8d:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a90:	8b 45 08             	mov    0x8(%ebp),%eax
  101a93:	8b 40 34             	mov    0x34(%eax),%eax
  101a96:	83 ec 08             	sub    $0x8,%esp
  101a99:	50                   	push   %eax
  101a9a:	68 8d 39 10 00       	push   $0x10398d
  101a9f:	e8 a9 e7 ff ff       	call   10024d <cprintf>
  101aa4:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aaa:	8b 40 38             	mov    0x38(%eax),%eax
  101aad:	83 ec 08             	sub    $0x8,%esp
  101ab0:	50                   	push   %eax
  101ab1:	68 9c 39 10 00       	push   $0x10399c
  101ab6:	e8 92 e7 ff ff       	call   10024d <cprintf>
  101abb:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101abe:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ac5:	0f b7 c0             	movzwl %ax,%eax
  101ac8:	83 ec 08             	sub    $0x8,%esp
  101acb:	50                   	push   %eax
  101acc:	68 ab 39 10 00       	push   $0x1039ab
  101ad1:	e8 77 e7 ff ff       	call   10024d <cprintf>
  101ad6:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  101adc:	8b 40 40             	mov    0x40(%eax),%eax
  101adf:	83 ec 08             	sub    $0x8,%esp
  101ae2:	50                   	push   %eax
  101ae3:	68 be 39 10 00       	push   $0x1039be
  101ae8:	e8 60 e7 ff ff       	call   10024d <cprintf>
  101aed:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101af0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101af7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101afe:	eb 3f                	jmp    101b3f <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b00:	8b 45 08             	mov    0x8(%ebp),%eax
  101b03:	8b 50 40             	mov    0x40(%eax),%edx
  101b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b09:	21 d0                	and    %edx,%eax
  101b0b:	85 c0                	test   %eax,%eax
  101b0d:	74 29                	je     101b38 <print_trapframe+0x168>
  101b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b12:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b19:	85 c0                	test   %eax,%eax
  101b1b:	74 1b                	je     101b38 <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
  101b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b20:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b27:	83 ec 08             	sub    $0x8,%esp
  101b2a:	50                   	push   %eax
  101b2b:	68 cd 39 10 00       	push   $0x1039cd
  101b30:	e8 18 e7 ff ff       	call   10024d <cprintf>
  101b35:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b3c:	d1 65 f0             	shll   -0x10(%ebp)
  101b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b42:	83 f8 17             	cmp    $0x17,%eax
  101b45:	76 b9                	jbe    101b00 <print_trapframe+0x130>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b47:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4a:	8b 40 40             	mov    0x40(%eax),%eax
  101b4d:	c1 e8 0c             	shr    $0xc,%eax
  101b50:	83 e0 03             	and    $0x3,%eax
  101b53:	83 ec 08             	sub    $0x8,%esp
  101b56:	50                   	push   %eax
  101b57:	68 d1 39 10 00       	push   $0x1039d1
  101b5c:	e8 ec e6 ff ff       	call   10024d <cprintf>
  101b61:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
  101b64:	83 ec 0c             	sub    $0xc,%esp
  101b67:	ff 75 08             	pushl  0x8(%ebp)
  101b6a:	e8 4b fe ff ff       	call   1019ba <trap_in_kernel>
  101b6f:	83 c4 10             	add    $0x10,%esp
  101b72:	85 c0                	test   %eax,%eax
  101b74:	75 32                	jne    101ba8 <print_trapframe+0x1d8>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b76:	8b 45 08             	mov    0x8(%ebp),%eax
  101b79:	8b 40 44             	mov    0x44(%eax),%eax
  101b7c:	83 ec 08             	sub    $0x8,%esp
  101b7f:	50                   	push   %eax
  101b80:	68 da 39 10 00       	push   $0x1039da
  101b85:	e8 c3 e6 ff ff       	call   10024d <cprintf>
  101b8a:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b90:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b94:	0f b7 c0             	movzwl %ax,%eax
  101b97:	83 ec 08             	sub    $0x8,%esp
  101b9a:	50                   	push   %eax
  101b9b:	68 e9 39 10 00       	push   $0x1039e9
  101ba0:	e8 a8 e6 ff ff       	call   10024d <cprintf>
  101ba5:	83 c4 10             	add    $0x10,%esp
    }
}
  101ba8:	90                   	nop
  101ba9:	c9                   	leave  
  101baa:	c3                   	ret    

00101bab <print_regs>:

void
print_regs(struct pushregs *regs) {
  101bab:	55                   	push   %ebp
  101bac:	89 e5                	mov    %esp,%ebp
  101bae:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb4:	8b 00                	mov    (%eax),%eax
  101bb6:	83 ec 08             	sub    $0x8,%esp
  101bb9:	50                   	push   %eax
  101bba:	68 fc 39 10 00       	push   $0x1039fc
  101bbf:	e8 89 e6 ff ff       	call   10024d <cprintf>
  101bc4:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bca:	8b 40 04             	mov    0x4(%eax),%eax
  101bcd:	83 ec 08             	sub    $0x8,%esp
  101bd0:	50                   	push   %eax
  101bd1:	68 0b 3a 10 00       	push   $0x103a0b
  101bd6:	e8 72 e6 ff ff       	call   10024d <cprintf>
  101bdb:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bde:	8b 45 08             	mov    0x8(%ebp),%eax
  101be1:	8b 40 08             	mov    0x8(%eax),%eax
  101be4:	83 ec 08             	sub    $0x8,%esp
  101be7:	50                   	push   %eax
  101be8:	68 1a 3a 10 00       	push   $0x103a1a
  101bed:	e8 5b e6 ff ff       	call   10024d <cprintf>
  101bf2:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf8:	8b 40 0c             	mov    0xc(%eax),%eax
  101bfb:	83 ec 08             	sub    $0x8,%esp
  101bfe:	50                   	push   %eax
  101bff:	68 29 3a 10 00       	push   $0x103a29
  101c04:	e8 44 e6 ff ff       	call   10024d <cprintf>
  101c09:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0f:	8b 40 10             	mov    0x10(%eax),%eax
  101c12:	83 ec 08             	sub    $0x8,%esp
  101c15:	50                   	push   %eax
  101c16:	68 38 3a 10 00       	push   $0x103a38
  101c1b:	e8 2d e6 ff ff       	call   10024d <cprintf>
  101c20:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c23:	8b 45 08             	mov    0x8(%ebp),%eax
  101c26:	8b 40 14             	mov    0x14(%eax),%eax
  101c29:	83 ec 08             	sub    $0x8,%esp
  101c2c:	50                   	push   %eax
  101c2d:	68 47 3a 10 00       	push   $0x103a47
  101c32:	e8 16 e6 ff ff       	call   10024d <cprintf>
  101c37:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3d:	8b 40 18             	mov    0x18(%eax),%eax
  101c40:	83 ec 08             	sub    $0x8,%esp
  101c43:	50                   	push   %eax
  101c44:	68 56 3a 10 00       	push   $0x103a56
  101c49:	e8 ff e5 ff ff       	call   10024d <cprintf>
  101c4e:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c51:	8b 45 08             	mov    0x8(%ebp),%eax
  101c54:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c57:	83 ec 08             	sub    $0x8,%esp
  101c5a:	50                   	push   %eax
  101c5b:	68 65 3a 10 00       	push   $0x103a65
  101c60:	e8 e8 e5 ff ff       	call   10024d <cprintf>
  101c65:	83 c4 10             	add    $0x10,%esp
}
  101c68:	90                   	nop
  101c69:	c9                   	leave  
  101c6a:	c3                   	ret    

00101c6b <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c6b:	55                   	push   %ebp
  101c6c:	89 e5                	mov    %esp,%ebp
  101c6e:	57                   	push   %edi
  101c6f:	56                   	push   %esi
  101c70:	53                   	push   %ebx
  101c71:	83 ec 1c             	sub    $0x1c,%esp
    char c;

    switch (tf->tf_trapno) {
  101c74:	8b 45 08             	mov    0x8(%ebp),%eax
  101c77:	8b 40 30             	mov    0x30(%eax),%eax
  101c7a:	83 f8 2f             	cmp    $0x2f,%eax
  101c7d:	77 21                	ja     101ca0 <trap_dispatch+0x35>
  101c7f:	83 f8 2e             	cmp    $0x2e,%eax
  101c82:	0f 83 ff 01 00 00    	jae    101e87 <trap_dispatch+0x21c>
  101c88:	83 f8 21             	cmp    $0x21,%eax
  101c8b:	0f 84 87 00 00 00    	je     101d18 <trap_dispatch+0xad>
  101c91:	83 f8 24             	cmp    $0x24,%eax
  101c94:	74 5b                	je     101cf1 <trap_dispatch+0x86>
  101c96:	83 f8 20             	cmp    $0x20,%eax
  101c99:	74 1c                	je     101cb7 <trap_dispatch+0x4c>
  101c9b:	e9 b1 01 00 00       	jmp    101e51 <trap_dispatch+0x1e6>
  101ca0:	83 f8 78             	cmp    $0x78,%eax
  101ca3:	0f 84 96 00 00 00    	je     101d3f <trap_dispatch+0xd4>
  101ca9:	83 f8 79             	cmp    $0x79,%eax
  101cac:	0f 84 29 01 00 00    	je     101ddb <trap_dispatch+0x170>
  101cb2:	e9 9a 01 00 00       	jmp    101e51 <trap_dispatch+0x1e6>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101cb7:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101cbc:	83 c0 01             	add    $0x1,%eax
  101cbf:	a3 08 f9 10 00       	mov    %eax,0x10f908
        if (ticks % TICK_NUM == 0) {
  101cc4:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101cca:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101ccf:	89 c8                	mov    %ecx,%eax
  101cd1:	f7 e2                	mul    %edx
  101cd3:	89 d0                	mov    %edx,%eax
  101cd5:	c1 e8 05             	shr    $0x5,%eax
  101cd8:	6b c0 64             	imul   $0x64,%eax,%eax
  101cdb:	29 c1                	sub    %eax,%ecx
  101cdd:	89 c8                	mov    %ecx,%eax
  101cdf:	85 c0                	test   %eax,%eax
  101ce1:	0f 85 a3 01 00 00    	jne    101e8a <trap_dispatch+0x21f>
            print_ticks();
  101ce7:	e8 10 fb ff ff       	call   1017fc <print_ticks>
        }
        break;
  101cec:	e9 99 01 00 00       	jmp    101e8a <trap_dispatch+0x21f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cf1:	e8 d9 f8 ff ff       	call   1015cf <cons_getc>
  101cf6:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cf9:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101cfd:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d01:	83 ec 04             	sub    $0x4,%esp
  101d04:	52                   	push   %edx
  101d05:	50                   	push   %eax
  101d06:	68 74 3a 10 00       	push   $0x103a74
  101d0b:	e8 3d e5 ff ff       	call   10024d <cprintf>
  101d10:	83 c4 10             	add    $0x10,%esp
        break;
  101d13:	e9 79 01 00 00       	jmp    101e91 <trap_dispatch+0x226>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d18:	e8 b2 f8 ff ff       	call   1015cf <cons_getc>
  101d1d:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d20:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d24:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d28:	83 ec 04             	sub    $0x4,%esp
  101d2b:	52                   	push   %edx
  101d2c:	50                   	push   %eax
  101d2d:	68 86 3a 10 00       	push   $0x103a86
  101d32:	e8 16 e5 ff ff       	call   10024d <cprintf>
  101d37:	83 c4 10             	add    $0x10,%esp
        break;
  101d3a:	e9 52 01 00 00       	jmp    101e91 <trap_dispatch+0x226>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d46:	66 83 f8 1b          	cmp    $0x1b,%ax
  101d4a:	0f 84 3d 01 00 00    	je     101e8d <trap_dispatch+0x222>
            switchk2u = *tf;
  101d50:	8b 55 08             	mov    0x8(%ebp),%edx
  101d53:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  101d58:	89 d3                	mov    %edx,%ebx
  101d5a:	ba 4c 00 00 00       	mov    $0x4c,%edx
  101d5f:	8b 0b                	mov    (%ebx),%ecx
  101d61:	89 08                	mov    %ecx,(%eax)
  101d63:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
  101d67:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
  101d6b:	8d 78 04             	lea    0x4(%eax),%edi
  101d6e:	83 e7 fc             	and    $0xfffffffc,%edi
  101d71:	29 f8                	sub    %edi,%eax
  101d73:	29 c3                	sub    %eax,%ebx
  101d75:	01 c2                	add    %eax,%edx
  101d77:	83 e2 fc             	and    $0xfffffffc,%edx
  101d7a:	89 d0                	mov    %edx,%eax
  101d7c:	c1 e8 02             	shr    $0x2,%eax
  101d7f:	89 de                	mov    %ebx,%esi
  101d81:	89 c1                	mov    %eax,%ecx
  101d83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101d85:	66 c7 05 5c f9 10 00 	movw   $0x1b,0x10f95c
  101d8c:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101d8e:	66 c7 05 68 f9 10 00 	movw   $0x23,0x10f968
  101d95:	23 00 
  101d97:	0f b7 05 68 f9 10 00 	movzwl 0x10f968,%eax
  101d9e:	66 a3 48 f9 10 00    	mov    %ax,0x10f948
  101da4:	0f b7 05 48 f9 10 00 	movzwl 0x10f948,%eax
  101dab:	66 a3 4c f9 10 00    	mov    %ax,0x10f94c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101db1:	8b 45 08             	mov    0x8(%ebp),%eax
  101db4:	83 c0 44             	add    $0x44,%eax
  101db7:	a3 64 f9 10 00       	mov    %eax,0x10f964
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101dbc:	a1 60 f9 10 00       	mov    0x10f960,%eax
  101dc1:	80 cc 30             	or     $0x30,%ah
  101dc4:	a3 60 f9 10 00       	mov    %eax,0x10f960
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  101dcc:	83 e8 04             	sub    $0x4,%eax
  101dcf:	ba 20 f9 10 00       	mov    $0x10f920,%edx
  101dd4:	89 10                	mov    %edx,(%eax)
        }
        break;
  101dd6:	e9 b2 00 00 00       	jmp    101e8d <trap_dispatch+0x222>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
  101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dde:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101de2:	66 83 f8 08          	cmp    $0x8,%ax
  101de6:	0f 84 a4 00 00 00    	je     101e90 <trap_dispatch+0x225>
            tf->tf_cs = KERNEL_CS;
  101dec:	8b 45 08             	mov    0x8(%ebp),%eax
  101def:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101df5:	8b 45 08             	mov    0x8(%ebp),%eax
  101df8:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  101e01:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101e05:	8b 45 08             	mov    0x8(%ebp),%eax
  101e08:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0f:	8b 40 40             	mov    0x40(%eax),%eax
  101e12:	80 e4 cf             	and    $0xcf,%ah
  101e15:	89 c2                	mov    %eax,%edx
  101e17:	8b 45 08             	mov    0x8(%ebp),%eax
  101e1a:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e20:	8b 40 44             	mov    0x44(%eax),%eax
  101e23:	83 e8 44             	sub    $0x44,%eax
  101e26:	a3 6c f9 10 00       	mov    %eax,0x10f96c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101e2b:	a1 6c f9 10 00       	mov    0x10f96c,%eax
  101e30:	83 ec 04             	sub    $0x4,%esp
  101e33:	6a 44                	push   $0x44
  101e35:	ff 75 08             	pushl  0x8(%ebp)
  101e38:	50                   	push   %eax
  101e39:	e8 b9 0f 00 00       	call   102df7 <memmove>
  101e3e:	83 c4 10             	add    $0x10,%esp
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101e41:	8b 15 6c f9 10 00    	mov    0x10f96c,%edx
  101e47:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4a:	83 e8 04             	sub    $0x4,%eax
  101e4d:	89 10                	mov    %edx,(%eax)
        }
        break;
  101e4f:	eb 3f                	jmp    101e90 <trap_dispatch+0x225>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e51:	8b 45 08             	mov    0x8(%ebp),%eax
  101e54:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e58:	0f b7 c0             	movzwl %ax,%eax
  101e5b:	83 e0 03             	and    $0x3,%eax
  101e5e:	85 c0                	test   %eax,%eax
  101e60:	75 2f                	jne    101e91 <trap_dispatch+0x226>
            print_trapframe(tf);
  101e62:	83 ec 0c             	sub    $0xc,%esp
  101e65:	ff 75 08             	pushl  0x8(%ebp)
  101e68:	e8 63 fb ff ff       	call   1019d0 <print_trapframe>
  101e6d:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
  101e70:	83 ec 04             	sub    $0x4,%esp
  101e73:	68 95 3a 10 00       	push   $0x103a95
  101e78:	68 d2 00 00 00       	push   $0xd2
  101e7d:	68 b1 3a 10 00       	push   $0x103ab1
  101e82:	e8 2c e5 ff ff       	call   1003b3 <__panic>
        break;
  101e87:	90                   	nop
  101e88:	eb 07                	jmp    101e91 <trap_dispatch+0x226>
        break;
  101e8a:	90                   	nop
  101e8b:	eb 04                	jmp    101e91 <trap_dispatch+0x226>
        break;
  101e8d:	90                   	nop
  101e8e:	eb 01                	jmp    101e91 <trap_dispatch+0x226>
        break;
  101e90:	90                   	nop
        }
    }
}
  101e91:	90                   	nop
  101e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  101e95:	5b                   	pop    %ebx
  101e96:	5e                   	pop    %esi
  101e97:	5f                   	pop    %edi
  101e98:	5d                   	pop    %ebp
  101e99:	c3                   	ret    

00101e9a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e9a:	55                   	push   %ebp
  101e9b:	89 e5                	mov    %esp,%ebp
  101e9d:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101ea0:	83 ec 0c             	sub    $0xc,%esp
  101ea3:	ff 75 08             	pushl  0x8(%ebp)
  101ea6:	e8 c0 fd ff ff       	call   101c6b <trap_dispatch>
  101eab:	83 c4 10             	add    $0x10,%esp
}
  101eae:	90                   	nop
  101eaf:	c9                   	leave  
  101eb0:	c3                   	ret    

00101eb1 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101eb1:	6a 00                	push   $0x0
  pushl $0
  101eb3:	6a 00                	push   $0x0
  jmp __alltraps
  101eb5:	e9 67 0a 00 00       	jmp    102921 <__alltraps>

00101eba <vector1>:
.globl vector1
vector1:
  pushl $0
  101eba:	6a 00                	push   $0x0
  pushl $1
  101ebc:	6a 01                	push   $0x1
  jmp __alltraps
  101ebe:	e9 5e 0a 00 00       	jmp    102921 <__alltraps>

00101ec3 <vector2>:
.globl vector2
vector2:
  pushl $0
  101ec3:	6a 00                	push   $0x0
  pushl $2
  101ec5:	6a 02                	push   $0x2
  jmp __alltraps
  101ec7:	e9 55 0a 00 00       	jmp    102921 <__alltraps>

00101ecc <vector3>:
.globl vector3
vector3:
  pushl $0
  101ecc:	6a 00                	push   $0x0
  pushl $3
  101ece:	6a 03                	push   $0x3
  jmp __alltraps
  101ed0:	e9 4c 0a 00 00       	jmp    102921 <__alltraps>

00101ed5 <vector4>:
.globl vector4
vector4:
  pushl $0
  101ed5:	6a 00                	push   $0x0
  pushl $4
  101ed7:	6a 04                	push   $0x4
  jmp __alltraps
  101ed9:	e9 43 0a 00 00       	jmp    102921 <__alltraps>

00101ede <vector5>:
.globl vector5
vector5:
  pushl $0
  101ede:	6a 00                	push   $0x0
  pushl $5
  101ee0:	6a 05                	push   $0x5
  jmp __alltraps
  101ee2:	e9 3a 0a 00 00       	jmp    102921 <__alltraps>

00101ee7 <vector6>:
.globl vector6
vector6:
  pushl $0
  101ee7:	6a 00                	push   $0x0
  pushl $6
  101ee9:	6a 06                	push   $0x6
  jmp __alltraps
  101eeb:	e9 31 0a 00 00       	jmp    102921 <__alltraps>

00101ef0 <vector7>:
.globl vector7
vector7:
  pushl $0
  101ef0:	6a 00                	push   $0x0
  pushl $7
  101ef2:	6a 07                	push   $0x7
  jmp __alltraps
  101ef4:	e9 28 0a 00 00       	jmp    102921 <__alltraps>

00101ef9 <vector8>:
.globl vector8
vector8:
  pushl $8
  101ef9:	6a 08                	push   $0x8
  jmp __alltraps
  101efb:	e9 21 0a 00 00       	jmp    102921 <__alltraps>

00101f00 <vector9>:
.globl vector9
vector9:
  pushl $9
  101f00:	6a 09                	push   $0x9
  jmp __alltraps
  101f02:	e9 1a 0a 00 00       	jmp    102921 <__alltraps>

00101f07 <vector10>:
.globl vector10
vector10:
  pushl $10
  101f07:	6a 0a                	push   $0xa
  jmp __alltraps
  101f09:	e9 13 0a 00 00       	jmp    102921 <__alltraps>

00101f0e <vector11>:
.globl vector11
vector11:
  pushl $11
  101f0e:	6a 0b                	push   $0xb
  jmp __alltraps
  101f10:	e9 0c 0a 00 00       	jmp    102921 <__alltraps>

00101f15 <vector12>:
.globl vector12
vector12:
  pushl $12
  101f15:	6a 0c                	push   $0xc
  jmp __alltraps
  101f17:	e9 05 0a 00 00       	jmp    102921 <__alltraps>

00101f1c <vector13>:
.globl vector13
vector13:
  pushl $13
  101f1c:	6a 0d                	push   $0xd
  jmp __alltraps
  101f1e:	e9 fe 09 00 00       	jmp    102921 <__alltraps>

00101f23 <vector14>:
.globl vector14
vector14:
  pushl $14
  101f23:	6a 0e                	push   $0xe
  jmp __alltraps
  101f25:	e9 f7 09 00 00       	jmp    102921 <__alltraps>

00101f2a <vector15>:
.globl vector15
vector15:
  pushl $0
  101f2a:	6a 00                	push   $0x0
  pushl $15
  101f2c:	6a 0f                	push   $0xf
  jmp __alltraps
  101f2e:	e9 ee 09 00 00       	jmp    102921 <__alltraps>

00101f33 <vector16>:
.globl vector16
vector16:
  pushl $0
  101f33:	6a 00                	push   $0x0
  pushl $16
  101f35:	6a 10                	push   $0x10
  jmp __alltraps
  101f37:	e9 e5 09 00 00       	jmp    102921 <__alltraps>

00101f3c <vector17>:
.globl vector17
vector17:
  pushl $17
  101f3c:	6a 11                	push   $0x11
  jmp __alltraps
  101f3e:	e9 de 09 00 00       	jmp    102921 <__alltraps>

00101f43 <vector18>:
.globl vector18
vector18:
  pushl $0
  101f43:	6a 00                	push   $0x0
  pushl $18
  101f45:	6a 12                	push   $0x12
  jmp __alltraps
  101f47:	e9 d5 09 00 00       	jmp    102921 <__alltraps>

00101f4c <vector19>:
.globl vector19
vector19:
  pushl $0
  101f4c:	6a 00                	push   $0x0
  pushl $19
  101f4e:	6a 13                	push   $0x13
  jmp __alltraps
  101f50:	e9 cc 09 00 00       	jmp    102921 <__alltraps>

00101f55 <vector20>:
.globl vector20
vector20:
  pushl $0
  101f55:	6a 00                	push   $0x0
  pushl $20
  101f57:	6a 14                	push   $0x14
  jmp __alltraps
  101f59:	e9 c3 09 00 00       	jmp    102921 <__alltraps>

00101f5e <vector21>:
.globl vector21
vector21:
  pushl $0
  101f5e:	6a 00                	push   $0x0
  pushl $21
  101f60:	6a 15                	push   $0x15
  jmp __alltraps
  101f62:	e9 ba 09 00 00       	jmp    102921 <__alltraps>

00101f67 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f67:	6a 00                	push   $0x0
  pushl $22
  101f69:	6a 16                	push   $0x16
  jmp __alltraps
  101f6b:	e9 b1 09 00 00       	jmp    102921 <__alltraps>

00101f70 <vector23>:
.globl vector23
vector23:
  pushl $0
  101f70:	6a 00                	push   $0x0
  pushl $23
  101f72:	6a 17                	push   $0x17
  jmp __alltraps
  101f74:	e9 a8 09 00 00       	jmp    102921 <__alltraps>

00101f79 <vector24>:
.globl vector24
vector24:
  pushl $0
  101f79:	6a 00                	push   $0x0
  pushl $24
  101f7b:	6a 18                	push   $0x18
  jmp __alltraps
  101f7d:	e9 9f 09 00 00       	jmp    102921 <__alltraps>

00101f82 <vector25>:
.globl vector25
vector25:
  pushl $0
  101f82:	6a 00                	push   $0x0
  pushl $25
  101f84:	6a 19                	push   $0x19
  jmp __alltraps
  101f86:	e9 96 09 00 00       	jmp    102921 <__alltraps>

00101f8b <vector26>:
.globl vector26
vector26:
  pushl $0
  101f8b:	6a 00                	push   $0x0
  pushl $26
  101f8d:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f8f:	e9 8d 09 00 00       	jmp    102921 <__alltraps>

00101f94 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f94:	6a 00                	push   $0x0
  pushl $27
  101f96:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f98:	e9 84 09 00 00       	jmp    102921 <__alltraps>

00101f9d <vector28>:
.globl vector28
vector28:
  pushl $0
  101f9d:	6a 00                	push   $0x0
  pushl $28
  101f9f:	6a 1c                	push   $0x1c
  jmp __alltraps
  101fa1:	e9 7b 09 00 00       	jmp    102921 <__alltraps>

00101fa6 <vector29>:
.globl vector29
vector29:
  pushl $0
  101fa6:	6a 00                	push   $0x0
  pushl $29
  101fa8:	6a 1d                	push   $0x1d
  jmp __alltraps
  101faa:	e9 72 09 00 00       	jmp    102921 <__alltraps>

00101faf <vector30>:
.globl vector30
vector30:
  pushl $0
  101faf:	6a 00                	push   $0x0
  pushl $30
  101fb1:	6a 1e                	push   $0x1e
  jmp __alltraps
  101fb3:	e9 69 09 00 00       	jmp    102921 <__alltraps>

00101fb8 <vector31>:
.globl vector31
vector31:
  pushl $0
  101fb8:	6a 00                	push   $0x0
  pushl $31
  101fba:	6a 1f                	push   $0x1f
  jmp __alltraps
  101fbc:	e9 60 09 00 00       	jmp    102921 <__alltraps>

00101fc1 <vector32>:
.globl vector32
vector32:
  pushl $0
  101fc1:	6a 00                	push   $0x0
  pushl $32
  101fc3:	6a 20                	push   $0x20
  jmp __alltraps
  101fc5:	e9 57 09 00 00       	jmp    102921 <__alltraps>

00101fca <vector33>:
.globl vector33
vector33:
  pushl $0
  101fca:	6a 00                	push   $0x0
  pushl $33
  101fcc:	6a 21                	push   $0x21
  jmp __alltraps
  101fce:	e9 4e 09 00 00       	jmp    102921 <__alltraps>

00101fd3 <vector34>:
.globl vector34
vector34:
  pushl $0
  101fd3:	6a 00                	push   $0x0
  pushl $34
  101fd5:	6a 22                	push   $0x22
  jmp __alltraps
  101fd7:	e9 45 09 00 00       	jmp    102921 <__alltraps>

00101fdc <vector35>:
.globl vector35
vector35:
  pushl $0
  101fdc:	6a 00                	push   $0x0
  pushl $35
  101fde:	6a 23                	push   $0x23
  jmp __alltraps
  101fe0:	e9 3c 09 00 00       	jmp    102921 <__alltraps>

00101fe5 <vector36>:
.globl vector36
vector36:
  pushl $0
  101fe5:	6a 00                	push   $0x0
  pushl $36
  101fe7:	6a 24                	push   $0x24
  jmp __alltraps
  101fe9:	e9 33 09 00 00       	jmp    102921 <__alltraps>

00101fee <vector37>:
.globl vector37
vector37:
  pushl $0
  101fee:	6a 00                	push   $0x0
  pushl $37
  101ff0:	6a 25                	push   $0x25
  jmp __alltraps
  101ff2:	e9 2a 09 00 00       	jmp    102921 <__alltraps>

00101ff7 <vector38>:
.globl vector38
vector38:
  pushl $0
  101ff7:	6a 00                	push   $0x0
  pushl $38
  101ff9:	6a 26                	push   $0x26
  jmp __alltraps
  101ffb:	e9 21 09 00 00       	jmp    102921 <__alltraps>

00102000 <vector39>:
.globl vector39
vector39:
  pushl $0
  102000:	6a 00                	push   $0x0
  pushl $39
  102002:	6a 27                	push   $0x27
  jmp __alltraps
  102004:	e9 18 09 00 00       	jmp    102921 <__alltraps>

00102009 <vector40>:
.globl vector40
vector40:
  pushl $0
  102009:	6a 00                	push   $0x0
  pushl $40
  10200b:	6a 28                	push   $0x28
  jmp __alltraps
  10200d:	e9 0f 09 00 00       	jmp    102921 <__alltraps>

00102012 <vector41>:
.globl vector41
vector41:
  pushl $0
  102012:	6a 00                	push   $0x0
  pushl $41
  102014:	6a 29                	push   $0x29
  jmp __alltraps
  102016:	e9 06 09 00 00       	jmp    102921 <__alltraps>

0010201b <vector42>:
.globl vector42
vector42:
  pushl $0
  10201b:	6a 00                	push   $0x0
  pushl $42
  10201d:	6a 2a                	push   $0x2a
  jmp __alltraps
  10201f:	e9 fd 08 00 00       	jmp    102921 <__alltraps>

00102024 <vector43>:
.globl vector43
vector43:
  pushl $0
  102024:	6a 00                	push   $0x0
  pushl $43
  102026:	6a 2b                	push   $0x2b
  jmp __alltraps
  102028:	e9 f4 08 00 00       	jmp    102921 <__alltraps>

0010202d <vector44>:
.globl vector44
vector44:
  pushl $0
  10202d:	6a 00                	push   $0x0
  pushl $44
  10202f:	6a 2c                	push   $0x2c
  jmp __alltraps
  102031:	e9 eb 08 00 00       	jmp    102921 <__alltraps>

00102036 <vector45>:
.globl vector45
vector45:
  pushl $0
  102036:	6a 00                	push   $0x0
  pushl $45
  102038:	6a 2d                	push   $0x2d
  jmp __alltraps
  10203a:	e9 e2 08 00 00       	jmp    102921 <__alltraps>

0010203f <vector46>:
.globl vector46
vector46:
  pushl $0
  10203f:	6a 00                	push   $0x0
  pushl $46
  102041:	6a 2e                	push   $0x2e
  jmp __alltraps
  102043:	e9 d9 08 00 00       	jmp    102921 <__alltraps>

00102048 <vector47>:
.globl vector47
vector47:
  pushl $0
  102048:	6a 00                	push   $0x0
  pushl $47
  10204a:	6a 2f                	push   $0x2f
  jmp __alltraps
  10204c:	e9 d0 08 00 00       	jmp    102921 <__alltraps>

00102051 <vector48>:
.globl vector48
vector48:
  pushl $0
  102051:	6a 00                	push   $0x0
  pushl $48
  102053:	6a 30                	push   $0x30
  jmp __alltraps
  102055:	e9 c7 08 00 00       	jmp    102921 <__alltraps>

0010205a <vector49>:
.globl vector49
vector49:
  pushl $0
  10205a:	6a 00                	push   $0x0
  pushl $49
  10205c:	6a 31                	push   $0x31
  jmp __alltraps
  10205e:	e9 be 08 00 00       	jmp    102921 <__alltraps>

00102063 <vector50>:
.globl vector50
vector50:
  pushl $0
  102063:	6a 00                	push   $0x0
  pushl $50
  102065:	6a 32                	push   $0x32
  jmp __alltraps
  102067:	e9 b5 08 00 00       	jmp    102921 <__alltraps>

0010206c <vector51>:
.globl vector51
vector51:
  pushl $0
  10206c:	6a 00                	push   $0x0
  pushl $51
  10206e:	6a 33                	push   $0x33
  jmp __alltraps
  102070:	e9 ac 08 00 00       	jmp    102921 <__alltraps>

00102075 <vector52>:
.globl vector52
vector52:
  pushl $0
  102075:	6a 00                	push   $0x0
  pushl $52
  102077:	6a 34                	push   $0x34
  jmp __alltraps
  102079:	e9 a3 08 00 00       	jmp    102921 <__alltraps>

0010207e <vector53>:
.globl vector53
vector53:
  pushl $0
  10207e:	6a 00                	push   $0x0
  pushl $53
  102080:	6a 35                	push   $0x35
  jmp __alltraps
  102082:	e9 9a 08 00 00       	jmp    102921 <__alltraps>

00102087 <vector54>:
.globl vector54
vector54:
  pushl $0
  102087:	6a 00                	push   $0x0
  pushl $54
  102089:	6a 36                	push   $0x36
  jmp __alltraps
  10208b:	e9 91 08 00 00       	jmp    102921 <__alltraps>

00102090 <vector55>:
.globl vector55
vector55:
  pushl $0
  102090:	6a 00                	push   $0x0
  pushl $55
  102092:	6a 37                	push   $0x37
  jmp __alltraps
  102094:	e9 88 08 00 00       	jmp    102921 <__alltraps>

00102099 <vector56>:
.globl vector56
vector56:
  pushl $0
  102099:	6a 00                	push   $0x0
  pushl $56
  10209b:	6a 38                	push   $0x38
  jmp __alltraps
  10209d:	e9 7f 08 00 00       	jmp    102921 <__alltraps>

001020a2 <vector57>:
.globl vector57
vector57:
  pushl $0
  1020a2:	6a 00                	push   $0x0
  pushl $57
  1020a4:	6a 39                	push   $0x39
  jmp __alltraps
  1020a6:	e9 76 08 00 00       	jmp    102921 <__alltraps>

001020ab <vector58>:
.globl vector58
vector58:
  pushl $0
  1020ab:	6a 00                	push   $0x0
  pushl $58
  1020ad:	6a 3a                	push   $0x3a
  jmp __alltraps
  1020af:	e9 6d 08 00 00       	jmp    102921 <__alltraps>

001020b4 <vector59>:
.globl vector59
vector59:
  pushl $0
  1020b4:	6a 00                	push   $0x0
  pushl $59
  1020b6:	6a 3b                	push   $0x3b
  jmp __alltraps
  1020b8:	e9 64 08 00 00       	jmp    102921 <__alltraps>

001020bd <vector60>:
.globl vector60
vector60:
  pushl $0
  1020bd:	6a 00                	push   $0x0
  pushl $60
  1020bf:	6a 3c                	push   $0x3c
  jmp __alltraps
  1020c1:	e9 5b 08 00 00       	jmp    102921 <__alltraps>

001020c6 <vector61>:
.globl vector61
vector61:
  pushl $0
  1020c6:	6a 00                	push   $0x0
  pushl $61
  1020c8:	6a 3d                	push   $0x3d
  jmp __alltraps
  1020ca:	e9 52 08 00 00       	jmp    102921 <__alltraps>

001020cf <vector62>:
.globl vector62
vector62:
  pushl $0
  1020cf:	6a 00                	push   $0x0
  pushl $62
  1020d1:	6a 3e                	push   $0x3e
  jmp __alltraps
  1020d3:	e9 49 08 00 00       	jmp    102921 <__alltraps>

001020d8 <vector63>:
.globl vector63
vector63:
  pushl $0
  1020d8:	6a 00                	push   $0x0
  pushl $63
  1020da:	6a 3f                	push   $0x3f
  jmp __alltraps
  1020dc:	e9 40 08 00 00       	jmp    102921 <__alltraps>

001020e1 <vector64>:
.globl vector64
vector64:
  pushl $0
  1020e1:	6a 00                	push   $0x0
  pushl $64
  1020e3:	6a 40                	push   $0x40
  jmp __alltraps
  1020e5:	e9 37 08 00 00       	jmp    102921 <__alltraps>

001020ea <vector65>:
.globl vector65
vector65:
  pushl $0
  1020ea:	6a 00                	push   $0x0
  pushl $65
  1020ec:	6a 41                	push   $0x41
  jmp __alltraps
  1020ee:	e9 2e 08 00 00       	jmp    102921 <__alltraps>

001020f3 <vector66>:
.globl vector66
vector66:
  pushl $0
  1020f3:	6a 00                	push   $0x0
  pushl $66
  1020f5:	6a 42                	push   $0x42
  jmp __alltraps
  1020f7:	e9 25 08 00 00       	jmp    102921 <__alltraps>

001020fc <vector67>:
.globl vector67
vector67:
  pushl $0
  1020fc:	6a 00                	push   $0x0
  pushl $67
  1020fe:	6a 43                	push   $0x43
  jmp __alltraps
  102100:	e9 1c 08 00 00       	jmp    102921 <__alltraps>

00102105 <vector68>:
.globl vector68
vector68:
  pushl $0
  102105:	6a 00                	push   $0x0
  pushl $68
  102107:	6a 44                	push   $0x44
  jmp __alltraps
  102109:	e9 13 08 00 00       	jmp    102921 <__alltraps>

0010210e <vector69>:
.globl vector69
vector69:
  pushl $0
  10210e:	6a 00                	push   $0x0
  pushl $69
  102110:	6a 45                	push   $0x45
  jmp __alltraps
  102112:	e9 0a 08 00 00       	jmp    102921 <__alltraps>

00102117 <vector70>:
.globl vector70
vector70:
  pushl $0
  102117:	6a 00                	push   $0x0
  pushl $70
  102119:	6a 46                	push   $0x46
  jmp __alltraps
  10211b:	e9 01 08 00 00       	jmp    102921 <__alltraps>

00102120 <vector71>:
.globl vector71
vector71:
  pushl $0
  102120:	6a 00                	push   $0x0
  pushl $71
  102122:	6a 47                	push   $0x47
  jmp __alltraps
  102124:	e9 f8 07 00 00       	jmp    102921 <__alltraps>

00102129 <vector72>:
.globl vector72
vector72:
  pushl $0
  102129:	6a 00                	push   $0x0
  pushl $72
  10212b:	6a 48                	push   $0x48
  jmp __alltraps
  10212d:	e9 ef 07 00 00       	jmp    102921 <__alltraps>

00102132 <vector73>:
.globl vector73
vector73:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $73
  102134:	6a 49                	push   $0x49
  jmp __alltraps
  102136:	e9 e6 07 00 00       	jmp    102921 <__alltraps>

0010213b <vector74>:
.globl vector74
vector74:
  pushl $0
  10213b:	6a 00                	push   $0x0
  pushl $74
  10213d:	6a 4a                	push   $0x4a
  jmp __alltraps
  10213f:	e9 dd 07 00 00       	jmp    102921 <__alltraps>

00102144 <vector75>:
.globl vector75
vector75:
  pushl $0
  102144:	6a 00                	push   $0x0
  pushl $75
  102146:	6a 4b                	push   $0x4b
  jmp __alltraps
  102148:	e9 d4 07 00 00       	jmp    102921 <__alltraps>

0010214d <vector76>:
.globl vector76
vector76:
  pushl $0
  10214d:	6a 00                	push   $0x0
  pushl $76
  10214f:	6a 4c                	push   $0x4c
  jmp __alltraps
  102151:	e9 cb 07 00 00       	jmp    102921 <__alltraps>

00102156 <vector77>:
.globl vector77
vector77:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $77
  102158:	6a 4d                	push   $0x4d
  jmp __alltraps
  10215a:	e9 c2 07 00 00       	jmp    102921 <__alltraps>

0010215f <vector78>:
.globl vector78
vector78:
  pushl $0
  10215f:	6a 00                	push   $0x0
  pushl $78
  102161:	6a 4e                	push   $0x4e
  jmp __alltraps
  102163:	e9 b9 07 00 00       	jmp    102921 <__alltraps>

00102168 <vector79>:
.globl vector79
vector79:
  pushl $0
  102168:	6a 00                	push   $0x0
  pushl $79
  10216a:	6a 4f                	push   $0x4f
  jmp __alltraps
  10216c:	e9 b0 07 00 00       	jmp    102921 <__alltraps>

00102171 <vector80>:
.globl vector80
vector80:
  pushl $0
  102171:	6a 00                	push   $0x0
  pushl $80
  102173:	6a 50                	push   $0x50
  jmp __alltraps
  102175:	e9 a7 07 00 00       	jmp    102921 <__alltraps>

0010217a <vector81>:
.globl vector81
vector81:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $81
  10217c:	6a 51                	push   $0x51
  jmp __alltraps
  10217e:	e9 9e 07 00 00       	jmp    102921 <__alltraps>

00102183 <vector82>:
.globl vector82
vector82:
  pushl $0
  102183:	6a 00                	push   $0x0
  pushl $82
  102185:	6a 52                	push   $0x52
  jmp __alltraps
  102187:	e9 95 07 00 00       	jmp    102921 <__alltraps>

0010218c <vector83>:
.globl vector83
vector83:
  pushl $0
  10218c:	6a 00                	push   $0x0
  pushl $83
  10218e:	6a 53                	push   $0x53
  jmp __alltraps
  102190:	e9 8c 07 00 00       	jmp    102921 <__alltraps>

00102195 <vector84>:
.globl vector84
vector84:
  pushl $0
  102195:	6a 00                	push   $0x0
  pushl $84
  102197:	6a 54                	push   $0x54
  jmp __alltraps
  102199:	e9 83 07 00 00       	jmp    102921 <__alltraps>

0010219e <vector85>:
.globl vector85
vector85:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $85
  1021a0:	6a 55                	push   $0x55
  jmp __alltraps
  1021a2:	e9 7a 07 00 00       	jmp    102921 <__alltraps>

001021a7 <vector86>:
.globl vector86
vector86:
  pushl $0
  1021a7:	6a 00                	push   $0x0
  pushl $86
  1021a9:	6a 56                	push   $0x56
  jmp __alltraps
  1021ab:	e9 71 07 00 00       	jmp    102921 <__alltraps>

001021b0 <vector87>:
.globl vector87
vector87:
  pushl $0
  1021b0:	6a 00                	push   $0x0
  pushl $87
  1021b2:	6a 57                	push   $0x57
  jmp __alltraps
  1021b4:	e9 68 07 00 00       	jmp    102921 <__alltraps>

001021b9 <vector88>:
.globl vector88
vector88:
  pushl $0
  1021b9:	6a 00                	push   $0x0
  pushl $88
  1021bb:	6a 58                	push   $0x58
  jmp __alltraps
  1021bd:	e9 5f 07 00 00       	jmp    102921 <__alltraps>

001021c2 <vector89>:
.globl vector89
vector89:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $89
  1021c4:	6a 59                	push   $0x59
  jmp __alltraps
  1021c6:	e9 56 07 00 00       	jmp    102921 <__alltraps>

001021cb <vector90>:
.globl vector90
vector90:
  pushl $0
  1021cb:	6a 00                	push   $0x0
  pushl $90
  1021cd:	6a 5a                	push   $0x5a
  jmp __alltraps
  1021cf:	e9 4d 07 00 00       	jmp    102921 <__alltraps>

001021d4 <vector91>:
.globl vector91
vector91:
  pushl $0
  1021d4:	6a 00                	push   $0x0
  pushl $91
  1021d6:	6a 5b                	push   $0x5b
  jmp __alltraps
  1021d8:	e9 44 07 00 00       	jmp    102921 <__alltraps>

001021dd <vector92>:
.globl vector92
vector92:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $92
  1021df:	6a 5c                	push   $0x5c
  jmp __alltraps
  1021e1:	e9 3b 07 00 00       	jmp    102921 <__alltraps>

001021e6 <vector93>:
.globl vector93
vector93:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $93
  1021e8:	6a 5d                	push   $0x5d
  jmp __alltraps
  1021ea:	e9 32 07 00 00       	jmp    102921 <__alltraps>

001021ef <vector94>:
.globl vector94
vector94:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $94
  1021f1:	6a 5e                	push   $0x5e
  jmp __alltraps
  1021f3:	e9 29 07 00 00       	jmp    102921 <__alltraps>

001021f8 <vector95>:
.globl vector95
vector95:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $95
  1021fa:	6a 5f                	push   $0x5f
  jmp __alltraps
  1021fc:	e9 20 07 00 00       	jmp    102921 <__alltraps>

00102201 <vector96>:
.globl vector96
vector96:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $96
  102203:	6a 60                	push   $0x60
  jmp __alltraps
  102205:	e9 17 07 00 00       	jmp    102921 <__alltraps>

0010220a <vector97>:
.globl vector97
vector97:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $97
  10220c:	6a 61                	push   $0x61
  jmp __alltraps
  10220e:	e9 0e 07 00 00       	jmp    102921 <__alltraps>

00102213 <vector98>:
.globl vector98
vector98:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $98
  102215:	6a 62                	push   $0x62
  jmp __alltraps
  102217:	e9 05 07 00 00       	jmp    102921 <__alltraps>

0010221c <vector99>:
.globl vector99
vector99:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $99
  10221e:	6a 63                	push   $0x63
  jmp __alltraps
  102220:	e9 fc 06 00 00       	jmp    102921 <__alltraps>

00102225 <vector100>:
.globl vector100
vector100:
  pushl $0
  102225:	6a 00                	push   $0x0
  pushl $100
  102227:	6a 64                	push   $0x64
  jmp __alltraps
  102229:	e9 f3 06 00 00       	jmp    102921 <__alltraps>

0010222e <vector101>:
.globl vector101
vector101:
  pushl $0
  10222e:	6a 00                	push   $0x0
  pushl $101
  102230:	6a 65                	push   $0x65
  jmp __alltraps
  102232:	e9 ea 06 00 00       	jmp    102921 <__alltraps>

00102237 <vector102>:
.globl vector102
vector102:
  pushl $0
  102237:	6a 00                	push   $0x0
  pushl $102
  102239:	6a 66                	push   $0x66
  jmp __alltraps
  10223b:	e9 e1 06 00 00       	jmp    102921 <__alltraps>

00102240 <vector103>:
.globl vector103
vector103:
  pushl $0
  102240:	6a 00                	push   $0x0
  pushl $103
  102242:	6a 67                	push   $0x67
  jmp __alltraps
  102244:	e9 d8 06 00 00       	jmp    102921 <__alltraps>

00102249 <vector104>:
.globl vector104
vector104:
  pushl $0
  102249:	6a 00                	push   $0x0
  pushl $104
  10224b:	6a 68                	push   $0x68
  jmp __alltraps
  10224d:	e9 cf 06 00 00       	jmp    102921 <__alltraps>

00102252 <vector105>:
.globl vector105
vector105:
  pushl $0
  102252:	6a 00                	push   $0x0
  pushl $105
  102254:	6a 69                	push   $0x69
  jmp __alltraps
  102256:	e9 c6 06 00 00       	jmp    102921 <__alltraps>

0010225b <vector106>:
.globl vector106
vector106:
  pushl $0
  10225b:	6a 00                	push   $0x0
  pushl $106
  10225d:	6a 6a                	push   $0x6a
  jmp __alltraps
  10225f:	e9 bd 06 00 00       	jmp    102921 <__alltraps>

00102264 <vector107>:
.globl vector107
vector107:
  pushl $0
  102264:	6a 00                	push   $0x0
  pushl $107
  102266:	6a 6b                	push   $0x6b
  jmp __alltraps
  102268:	e9 b4 06 00 00       	jmp    102921 <__alltraps>

0010226d <vector108>:
.globl vector108
vector108:
  pushl $0
  10226d:	6a 00                	push   $0x0
  pushl $108
  10226f:	6a 6c                	push   $0x6c
  jmp __alltraps
  102271:	e9 ab 06 00 00       	jmp    102921 <__alltraps>

00102276 <vector109>:
.globl vector109
vector109:
  pushl $0
  102276:	6a 00                	push   $0x0
  pushl $109
  102278:	6a 6d                	push   $0x6d
  jmp __alltraps
  10227a:	e9 a2 06 00 00       	jmp    102921 <__alltraps>

0010227f <vector110>:
.globl vector110
vector110:
  pushl $0
  10227f:	6a 00                	push   $0x0
  pushl $110
  102281:	6a 6e                	push   $0x6e
  jmp __alltraps
  102283:	e9 99 06 00 00       	jmp    102921 <__alltraps>

00102288 <vector111>:
.globl vector111
vector111:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $111
  10228a:	6a 6f                	push   $0x6f
  jmp __alltraps
  10228c:	e9 90 06 00 00       	jmp    102921 <__alltraps>

00102291 <vector112>:
.globl vector112
vector112:
  pushl $0
  102291:	6a 00                	push   $0x0
  pushl $112
  102293:	6a 70                	push   $0x70
  jmp __alltraps
  102295:	e9 87 06 00 00       	jmp    102921 <__alltraps>

0010229a <vector113>:
.globl vector113
vector113:
  pushl $0
  10229a:	6a 00                	push   $0x0
  pushl $113
  10229c:	6a 71                	push   $0x71
  jmp __alltraps
  10229e:	e9 7e 06 00 00       	jmp    102921 <__alltraps>

001022a3 <vector114>:
.globl vector114
vector114:
  pushl $0
  1022a3:	6a 00                	push   $0x0
  pushl $114
  1022a5:	6a 72                	push   $0x72
  jmp __alltraps
  1022a7:	e9 75 06 00 00       	jmp    102921 <__alltraps>

001022ac <vector115>:
.globl vector115
vector115:
  pushl $0
  1022ac:	6a 00                	push   $0x0
  pushl $115
  1022ae:	6a 73                	push   $0x73
  jmp __alltraps
  1022b0:	e9 6c 06 00 00       	jmp    102921 <__alltraps>

001022b5 <vector116>:
.globl vector116
vector116:
  pushl $0
  1022b5:	6a 00                	push   $0x0
  pushl $116
  1022b7:	6a 74                	push   $0x74
  jmp __alltraps
  1022b9:	e9 63 06 00 00       	jmp    102921 <__alltraps>

001022be <vector117>:
.globl vector117
vector117:
  pushl $0
  1022be:	6a 00                	push   $0x0
  pushl $117
  1022c0:	6a 75                	push   $0x75
  jmp __alltraps
  1022c2:	e9 5a 06 00 00       	jmp    102921 <__alltraps>

001022c7 <vector118>:
.globl vector118
vector118:
  pushl $0
  1022c7:	6a 00                	push   $0x0
  pushl $118
  1022c9:	6a 76                	push   $0x76
  jmp __alltraps
  1022cb:	e9 51 06 00 00       	jmp    102921 <__alltraps>

001022d0 <vector119>:
.globl vector119
vector119:
  pushl $0
  1022d0:	6a 00                	push   $0x0
  pushl $119
  1022d2:	6a 77                	push   $0x77
  jmp __alltraps
  1022d4:	e9 48 06 00 00       	jmp    102921 <__alltraps>

001022d9 <vector120>:
.globl vector120
vector120:
  pushl $0
  1022d9:	6a 00                	push   $0x0
  pushl $120
  1022db:	6a 78                	push   $0x78
  jmp __alltraps
  1022dd:	e9 3f 06 00 00       	jmp    102921 <__alltraps>

001022e2 <vector121>:
.globl vector121
vector121:
  pushl $0
  1022e2:	6a 00                	push   $0x0
  pushl $121
  1022e4:	6a 79                	push   $0x79
  jmp __alltraps
  1022e6:	e9 36 06 00 00       	jmp    102921 <__alltraps>

001022eb <vector122>:
.globl vector122
vector122:
  pushl $0
  1022eb:	6a 00                	push   $0x0
  pushl $122
  1022ed:	6a 7a                	push   $0x7a
  jmp __alltraps
  1022ef:	e9 2d 06 00 00       	jmp    102921 <__alltraps>

001022f4 <vector123>:
.globl vector123
vector123:
  pushl $0
  1022f4:	6a 00                	push   $0x0
  pushl $123
  1022f6:	6a 7b                	push   $0x7b
  jmp __alltraps
  1022f8:	e9 24 06 00 00       	jmp    102921 <__alltraps>

001022fd <vector124>:
.globl vector124
vector124:
  pushl $0
  1022fd:	6a 00                	push   $0x0
  pushl $124
  1022ff:	6a 7c                	push   $0x7c
  jmp __alltraps
  102301:	e9 1b 06 00 00       	jmp    102921 <__alltraps>

00102306 <vector125>:
.globl vector125
vector125:
  pushl $0
  102306:	6a 00                	push   $0x0
  pushl $125
  102308:	6a 7d                	push   $0x7d
  jmp __alltraps
  10230a:	e9 12 06 00 00       	jmp    102921 <__alltraps>

0010230f <vector126>:
.globl vector126
vector126:
  pushl $0
  10230f:	6a 00                	push   $0x0
  pushl $126
  102311:	6a 7e                	push   $0x7e
  jmp __alltraps
  102313:	e9 09 06 00 00       	jmp    102921 <__alltraps>

00102318 <vector127>:
.globl vector127
vector127:
  pushl $0
  102318:	6a 00                	push   $0x0
  pushl $127
  10231a:	6a 7f                	push   $0x7f
  jmp __alltraps
  10231c:	e9 00 06 00 00       	jmp    102921 <__alltraps>

00102321 <vector128>:
.globl vector128
vector128:
  pushl $0
  102321:	6a 00                	push   $0x0
  pushl $128
  102323:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102328:	e9 f4 05 00 00       	jmp    102921 <__alltraps>

0010232d <vector129>:
.globl vector129
vector129:
  pushl $0
  10232d:	6a 00                	push   $0x0
  pushl $129
  10232f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102334:	e9 e8 05 00 00       	jmp    102921 <__alltraps>

00102339 <vector130>:
.globl vector130
vector130:
  pushl $0
  102339:	6a 00                	push   $0x0
  pushl $130
  10233b:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102340:	e9 dc 05 00 00       	jmp    102921 <__alltraps>

00102345 <vector131>:
.globl vector131
vector131:
  pushl $0
  102345:	6a 00                	push   $0x0
  pushl $131
  102347:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10234c:	e9 d0 05 00 00       	jmp    102921 <__alltraps>

00102351 <vector132>:
.globl vector132
vector132:
  pushl $0
  102351:	6a 00                	push   $0x0
  pushl $132
  102353:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102358:	e9 c4 05 00 00       	jmp    102921 <__alltraps>

0010235d <vector133>:
.globl vector133
vector133:
  pushl $0
  10235d:	6a 00                	push   $0x0
  pushl $133
  10235f:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102364:	e9 b8 05 00 00       	jmp    102921 <__alltraps>

00102369 <vector134>:
.globl vector134
vector134:
  pushl $0
  102369:	6a 00                	push   $0x0
  pushl $134
  10236b:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102370:	e9 ac 05 00 00       	jmp    102921 <__alltraps>

00102375 <vector135>:
.globl vector135
vector135:
  pushl $0
  102375:	6a 00                	push   $0x0
  pushl $135
  102377:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10237c:	e9 a0 05 00 00       	jmp    102921 <__alltraps>

00102381 <vector136>:
.globl vector136
vector136:
  pushl $0
  102381:	6a 00                	push   $0x0
  pushl $136
  102383:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102388:	e9 94 05 00 00       	jmp    102921 <__alltraps>

0010238d <vector137>:
.globl vector137
vector137:
  pushl $0
  10238d:	6a 00                	push   $0x0
  pushl $137
  10238f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102394:	e9 88 05 00 00       	jmp    102921 <__alltraps>

00102399 <vector138>:
.globl vector138
vector138:
  pushl $0
  102399:	6a 00                	push   $0x0
  pushl $138
  10239b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1023a0:	e9 7c 05 00 00       	jmp    102921 <__alltraps>

001023a5 <vector139>:
.globl vector139
vector139:
  pushl $0
  1023a5:	6a 00                	push   $0x0
  pushl $139
  1023a7:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1023ac:	e9 70 05 00 00       	jmp    102921 <__alltraps>

001023b1 <vector140>:
.globl vector140
vector140:
  pushl $0
  1023b1:	6a 00                	push   $0x0
  pushl $140
  1023b3:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1023b8:	e9 64 05 00 00       	jmp    102921 <__alltraps>

001023bd <vector141>:
.globl vector141
vector141:
  pushl $0
  1023bd:	6a 00                	push   $0x0
  pushl $141
  1023bf:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1023c4:	e9 58 05 00 00       	jmp    102921 <__alltraps>

001023c9 <vector142>:
.globl vector142
vector142:
  pushl $0
  1023c9:	6a 00                	push   $0x0
  pushl $142
  1023cb:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1023d0:	e9 4c 05 00 00       	jmp    102921 <__alltraps>

001023d5 <vector143>:
.globl vector143
vector143:
  pushl $0
  1023d5:	6a 00                	push   $0x0
  pushl $143
  1023d7:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1023dc:	e9 40 05 00 00       	jmp    102921 <__alltraps>

001023e1 <vector144>:
.globl vector144
vector144:
  pushl $0
  1023e1:	6a 00                	push   $0x0
  pushl $144
  1023e3:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1023e8:	e9 34 05 00 00       	jmp    102921 <__alltraps>

001023ed <vector145>:
.globl vector145
vector145:
  pushl $0
  1023ed:	6a 00                	push   $0x0
  pushl $145
  1023ef:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1023f4:	e9 28 05 00 00       	jmp    102921 <__alltraps>

001023f9 <vector146>:
.globl vector146
vector146:
  pushl $0
  1023f9:	6a 00                	push   $0x0
  pushl $146
  1023fb:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102400:	e9 1c 05 00 00       	jmp    102921 <__alltraps>

00102405 <vector147>:
.globl vector147
vector147:
  pushl $0
  102405:	6a 00                	push   $0x0
  pushl $147
  102407:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10240c:	e9 10 05 00 00       	jmp    102921 <__alltraps>

00102411 <vector148>:
.globl vector148
vector148:
  pushl $0
  102411:	6a 00                	push   $0x0
  pushl $148
  102413:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102418:	e9 04 05 00 00       	jmp    102921 <__alltraps>

0010241d <vector149>:
.globl vector149
vector149:
  pushl $0
  10241d:	6a 00                	push   $0x0
  pushl $149
  10241f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102424:	e9 f8 04 00 00       	jmp    102921 <__alltraps>

00102429 <vector150>:
.globl vector150
vector150:
  pushl $0
  102429:	6a 00                	push   $0x0
  pushl $150
  10242b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102430:	e9 ec 04 00 00       	jmp    102921 <__alltraps>

00102435 <vector151>:
.globl vector151
vector151:
  pushl $0
  102435:	6a 00                	push   $0x0
  pushl $151
  102437:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10243c:	e9 e0 04 00 00       	jmp    102921 <__alltraps>

00102441 <vector152>:
.globl vector152
vector152:
  pushl $0
  102441:	6a 00                	push   $0x0
  pushl $152
  102443:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102448:	e9 d4 04 00 00       	jmp    102921 <__alltraps>

0010244d <vector153>:
.globl vector153
vector153:
  pushl $0
  10244d:	6a 00                	push   $0x0
  pushl $153
  10244f:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102454:	e9 c8 04 00 00       	jmp    102921 <__alltraps>

00102459 <vector154>:
.globl vector154
vector154:
  pushl $0
  102459:	6a 00                	push   $0x0
  pushl $154
  10245b:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102460:	e9 bc 04 00 00       	jmp    102921 <__alltraps>

00102465 <vector155>:
.globl vector155
vector155:
  pushl $0
  102465:	6a 00                	push   $0x0
  pushl $155
  102467:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10246c:	e9 b0 04 00 00       	jmp    102921 <__alltraps>

00102471 <vector156>:
.globl vector156
vector156:
  pushl $0
  102471:	6a 00                	push   $0x0
  pushl $156
  102473:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102478:	e9 a4 04 00 00       	jmp    102921 <__alltraps>

0010247d <vector157>:
.globl vector157
vector157:
  pushl $0
  10247d:	6a 00                	push   $0x0
  pushl $157
  10247f:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102484:	e9 98 04 00 00       	jmp    102921 <__alltraps>

00102489 <vector158>:
.globl vector158
vector158:
  pushl $0
  102489:	6a 00                	push   $0x0
  pushl $158
  10248b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102490:	e9 8c 04 00 00       	jmp    102921 <__alltraps>

00102495 <vector159>:
.globl vector159
vector159:
  pushl $0
  102495:	6a 00                	push   $0x0
  pushl $159
  102497:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10249c:	e9 80 04 00 00       	jmp    102921 <__alltraps>

001024a1 <vector160>:
.globl vector160
vector160:
  pushl $0
  1024a1:	6a 00                	push   $0x0
  pushl $160
  1024a3:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1024a8:	e9 74 04 00 00       	jmp    102921 <__alltraps>

001024ad <vector161>:
.globl vector161
vector161:
  pushl $0
  1024ad:	6a 00                	push   $0x0
  pushl $161
  1024af:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1024b4:	e9 68 04 00 00       	jmp    102921 <__alltraps>

001024b9 <vector162>:
.globl vector162
vector162:
  pushl $0
  1024b9:	6a 00                	push   $0x0
  pushl $162
  1024bb:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1024c0:	e9 5c 04 00 00       	jmp    102921 <__alltraps>

001024c5 <vector163>:
.globl vector163
vector163:
  pushl $0
  1024c5:	6a 00                	push   $0x0
  pushl $163
  1024c7:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1024cc:	e9 50 04 00 00       	jmp    102921 <__alltraps>

001024d1 <vector164>:
.globl vector164
vector164:
  pushl $0
  1024d1:	6a 00                	push   $0x0
  pushl $164
  1024d3:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1024d8:	e9 44 04 00 00       	jmp    102921 <__alltraps>

001024dd <vector165>:
.globl vector165
vector165:
  pushl $0
  1024dd:	6a 00                	push   $0x0
  pushl $165
  1024df:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1024e4:	e9 38 04 00 00       	jmp    102921 <__alltraps>

001024e9 <vector166>:
.globl vector166
vector166:
  pushl $0
  1024e9:	6a 00                	push   $0x0
  pushl $166
  1024eb:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1024f0:	e9 2c 04 00 00       	jmp    102921 <__alltraps>

001024f5 <vector167>:
.globl vector167
vector167:
  pushl $0
  1024f5:	6a 00                	push   $0x0
  pushl $167
  1024f7:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1024fc:	e9 20 04 00 00       	jmp    102921 <__alltraps>

00102501 <vector168>:
.globl vector168
vector168:
  pushl $0
  102501:	6a 00                	push   $0x0
  pushl $168
  102503:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102508:	e9 14 04 00 00       	jmp    102921 <__alltraps>

0010250d <vector169>:
.globl vector169
vector169:
  pushl $0
  10250d:	6a 00                	push   $0x0
  pushl $169
  10250f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102514:	e9 08 04 00 00       	jmp    102921 <__alltraps>

00102519 <vector170>:
.globl vector170
vector170:
  pushl $0
  102519:	6a 00                	push   $0x0
  pushl $170
  10251b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102520:	e9 fc 03 00 00       	jmp    102921 <__alltraps>

00102525 <vector171>:
.globl vector171
vector171:
  pushl $0
  102525:	6a 00                	push   $0x0
  pushl $171
  102527:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10252c:	e9 f0 03 00 00       	jmp    102921 <__alltraps>

00102531 <vector172>:
.globl vector172
vector172:
  pushl $0
  102531:	6a 00                	push   $0x0
  pushl $172
  102533:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102538:	e9 e4 03 00 00       	jmp    102921 <__alltraps>

0010253d <vector173>:
.globl vector173
vector173:
  pushl $0
  10253d:	6a 00                	push   $0x0
  pushl $173
  10253f:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102544:	e9 d8 03 00 00       	jmp    102921 <__alltraps>

00102549 <vector174>:
.globl vector174
vector174:
  pushl $0
  102549:	6a 00                	push   $0x0
  pushl $174
  10254b:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102550:	e9 cc 03 00 00       	jmp    102921 <__alltraps>

00102555 <vector175>:
.globl vector175
vector175:
  pushl $0
  102555:	6a 00                	push   $0x0
  pushl $175
  102557:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10255c:	e9 c0 03 00 00       	jmp    102921 <__alltraps>

00102561 <vector176>:
.globl vector176
vector176:
  pushl $0
  102561:	6a 00                	push   $0x0
  pushl $176
  102563:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102568:	e9 b4 03 00 00       	jmp    102921 <__alltraps>

0010256d <vector177>:
.globl vector177
vector177:
  pushl $0
  10256d:	6a 00                	push   $0x0
  pushl $177
  10256f:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102574:	e9 a8 03 00 00       	jmp    102921 <__alltraps>

00102579 <vector178>:
.globl vector178
vector178:
  pushl $0
  102579:	6a 00                	push   $0x0
  pushl $178
  10257b:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102580:	e9 9c 03 00 00       	jmp    102921 <__alltraps>

00102585 <vector179>:
.globl vector179
vector179:
  pushl $0
  102585:	6a 00                	push   $0x0
  pushl $179
  102587:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10258c:	e9 90 03 00 00       	jmp    102921 <__alltraps>

00102591 <vector180>:
.globl vector180
vector180:
  pushl $0
  102591:	6a 00                	push   $0x0
  pushl $180
  102593:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102598:	e9 84 03 00 00       	jmp    102921 <__alltraps>

0010259d <vector181>:
.globl vector181
vector181:
  pushl $0
  10259d:	6a 00                	push   $0x0
  pushl $181
  10259f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1025a4:	e9 78 03 00 00       	jmp    102921 <__alltraps>

001025a9 <vector182>:
.globl vector182
vector182:
  pushl $0
  1025a9:	6a 00                	push   $0x0
  pushl $182
  1025ab:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1025b0:	e9 6c 03 00 00       	jmp    102921 <__alltraps>

001025b5 <vector183>:
.globl vector183
vector183:
  pushl $0
  1025b5:	6a 00                	push   $0x0
  pushl $183
  1025b7:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1025bc:	e9 60 03 00 00       	jmp    102921 <__alltraps>

001025c1 <vector184>:
.globl vector184
vector184:
  pushl $0
  1025c1:	6a 00                	push   $0x0
  pushl $184
  1025c3:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1025c8:	e9 54 03 00 00       	jmp    102921 <__alltraps>

001025cd <vector185>:
.globl vector185
vector185:
  pushl $0
  1025cd:	6a 00                	push   $0x0
  pushl $185
  1025cf:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1025d4:	e9 48 03 00 00       	jmp    102921 <__alltraps>

001025d9 <vector186>:
.globl vector186
vector186:
  pushl $0
  1025d9:	6a 00                	push   $0x0
  pushl $186
  1025db:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1025e0:	e9 3c 03 00 00       	jmp    102921 <__alltraps>

001025e5 <vector187>:
.globl vector187
vector187:
  pushl $0
  1025e5:	6a 00                	push   $0x0
  pushl $187
  1025e7:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1025ec:	e9 30 03 00 00       	jmp    102921 <__alltraps>

001025f1 <vector188>:
.globl vector188
vector188:
  pushl $0
  1025f1:	6a 00                	push   $0x0
  pushl $188
  1025f3:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1025f8:	e9 24 03 00 00       	jmp    102921 <__alltraps>

001025fd <vector189>:
.globl vector189
vector189:
  pushl $0
  1025fd:	6a 00                	push   $0x0
  pushl $189
  1025ff:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102604:	e9 18 03 00 00       	jmp    102921 <__alltraps>

00102609 <vector190>:
.globl vector190
vector190:
  pushl $0
  102609:	6a 00                	push   $0x0
  pushl $190
  10260b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102610:	e9 0c 03 00 00       	jmp    102921 <__alltraps>

00102615 <vector191>:
.globl vector191
vector191:
  pushl $0
  102615:	6a 00                	push   $0x0
  pushl $191
  102617:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10261c:	e9 00 03 00 00       	jmp    102921 <__alltraps>

00102621 <vector192>:
.globl vector192
vector192:
  pushl $0
  102621:	6a 00                	push   $0x0
  pushl $192
  102623:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102628:	e9 f4 02 00 00       	jmp    102921 <__alltraps>

0010262d <vector193>:
.globl vector193
vector193:
  pushl $0
  10262d:	6a 00                	push   $0x0
  pushl $193
  10262f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102634:	e9 e8 02 00 00       	jmp    102921 <__alltraps>

00102639 <vector194>:
.globl vector194
vector194:
  pushl $0
  102639:	6a 00                	push   $0x0
  pushl $194
  10263b:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102640:	e9 dc 02 00 00       	jmp    102921 <__alltraps>

00102645 <vector195>:
.globl vector195
vector195:
  pushl $0
  102645:	6a 00                	push   $0x0
  pushl $195
  102647:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10264c:	e9 d0 02 00 00       	jmp    102921 <__alltraps>

00102651 <vector196>:
.globl vector196
vector196:
  pushl $0
  102651:	6a 00                	push   $0x0
  pushl $196
  102653:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102658:	e9 c4 02 00 00       	jmp    102921 <__alltraps>

0010265d <vector197>:
.globl vector197
vector197:
  pushl $0
  10265d:	6a 00                	push   $0x0
  pushl $197
  10265f:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102664:	e9 b8 02 00 00       	jmp    102921 <__alltraps>

00102669 <vector198>:
.globl vector198
vector198:
  pushl $0
  102669:	6a 00                	push   $0x0
  pushl $198
  10266b:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102670:	e9 ac 02 00 00       	jmp    102921 <__alltraps>

00102675 <vector199>:
.globl vector199
vector199:
  pushl $0
  102675:	6a 00                	push   $0x0
  pushl $199
  102677:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10267c:	e9 a0 02 00 00       	jmp    102921 <__alltraps>

00102681 <vector200>:
.globl vector200
vector200:
  pushl $0
  102681:	6a 00                	push   $0x0
  pushl $200
  102683:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102688:	e9 94 02 00 00       	jmp    102921 <__alltraps>

0010268d <vector201>:
.globl vector201
vector201:
  pushl $0
  10268d:	6a 00                	push   $0x0
  pushl $201
  10268f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102694:	e9 88 02 00 00       	jmp    102921 <__alltraps>

00102699 <vector202>:
.globl vector202
vector202:
  pushl $0
  102699:	6a 00                	push   $0x0
  pushl $202
  10269b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1026a0:	e9 7c 02 00 00       	jmp    102921 <__alltraps>

001026a5 <vector203>:
.globl vector203
vector203:
  pushl $0
  1026a5:	6a 00                	push   $0x0
  pushl $203
  1026a7:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1026ac:	e9 70 02 00 00       	jmp    102921 <__alltraps>

001026b1 <vector204>:
.globl vector204
vector204:
  pushl $0
  1026b1:	6a 00                	push   $0x0
  pushl $204
  1026b3:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1026b8:	e9 64 02 00 00       	jmp    102921 <__alltraps>

001026bd <vector205>:
.globl vector205
vector205:
  pushl $0
  1026bd:	6a 00                	push   $0x0
  pushl $205
  1026bf:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1026c4:	e9 58 02 00 00       	jmp    102921 <__alltraps>

001026c9 <vector206>:
.globl vector206
vector206:
  pushl $0
  1026c9:	6a 00                	push   $0x0
  pushl $206
  1026cb:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1026d0:	e9 4c 02 00 00       	jmp    102921 <__alltraps>

001026d5 <vector207>:
.globl vector207
vector207:
  pushl $0
  1026d5:	6a 00                	push   $0x0
  pushl $207
  1026d7:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1026dc:	e9 40 02 00 00       	jmp    102921 <__alltraps>

001026e1 <vector208>:
.globl vector208
vector208:
  pushl $0
  1026e1:	6a 00                	push   $0x0
  pushl $208
  1026e3:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1026e8:	e9 34 02 00 00       	jmp    102921 <__alltraps>

001026ed <vector209>:
.globl vector209
vector209:
  pushl $0
  1026ed:	6a 00                	push   $0x0
  pushl $209
  1026ef:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1026f4:	e9 28 02 00 00       	jmp    102921 <__alltraps>

001026f9 <vector210>:
.globl vector210
vector210:
  pushl $0
  1026f9:	6a 00                	push   $0x0
  pushl $210
  1026fb:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102700:	e9 1c 02 00 00       	jmp    102921 <__alltraps>

00102705 <vector211>:
.globl vector211
vector211:
  pushl $0
  102705:	6a 00                	push   $0x0
  pushl $211
  102707:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10270c:	e9 10 02 00 00       	jmp    102921 <__alltraps>

00102711 <vector212>:
.globl vector212
vector212:
  pushl $0
  102711:	6a 00                	push   $0x0
  pushl $212
  102713:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102718:	e9 04 02 00 00       	jmp    102921 <__alltraps>

0010271d <vector213>:
.globl vector213
vector213:
  pushl $0
  10271d:	6a 00                	push   $0x0
  pushl $213
  10271f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102724:	e9 f8 01 00 00       	jmp    102921 <__alltraps>

00102729 <vector214>:
.globl vector214
vector214:
  pushl $0
  102729:	6a 00                	push   $0x0
  pushl $214
  10272b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102730:	e9 ec 01 00 00       	jmp    102921 <__alltraps>

00102735 <vector215>:
.globl vector215
vector215:
  pushl $0
  102735:	6a 00                	push   $0x0
  pushl $215
  102737:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10273c:	e9 e0 01 00 00       	jmp    102921 <__alltraps>

00102741 <vector216>:
.globl vector216
vector216:
  pushl $0
  102741:	6a 00                	push   $0x0
  pushl $216
  102743:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102748:	e9 d4 01 00 00       	jmp    102921 <__alltraps>

0010274d <vector217>:
.globl vector217
vector217:
  pushl $0
  10274d:	6a 00                	push   $0x0
  pushl $217
  10274f:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102754:	e9 c8 01 00 00       	jmp    102921 <__alltraps>

00102759 <vector218>:
.globl vector218
vector218:
  pushl $0
  102759:	6a 00                	push   $0x0
  pushl $218
  10275b:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102760:	e9 bc 01 00 00       	jmp    102921 <__alltraps>

00102765 <vector219>:
.globl vector219
vector219:
  pushl $0
  102765:	6a 00                	push   $0x0
  pushl $219
  102767:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10276c:	e9 b0 01 00 00       	jmp    102921 <__alltraps>

00102771 <vector220>:
.globl vector220
vector220:
  pushl $0
  102771:	6a 00                	push   $0x0
  pushl $220
  102773:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102778:	e9 a4 01 00 00       	jmp    102921 <__alltraps>

0010277d <vector221>:
.globl vector221
vector221:
  pushl $0
  10277d:	6a 00                	push   $0x0
  pushl $221
  10277f:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102784:	e9 98 01 00 00       	jmp    102921 <__alltraps>

00102789 <vector222>:
.globl vector222
vector222:
  pushl $0
  102789:	6a 00                	push   $0x0
  pushl $222
  10278b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102790:	e9 8c 01 00 00       	jmp    102921 <__alltraps>

00102795 <vector223>:
.globl vector223
vector223:
  pushl $0
  102795:	6a 00                	push   $0x0
  pushl $223
  102797:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10279c:	e9 80 01 00 00       	jmp    102921 <__alltraps>

001027a1 <vector224>:
.globl vector224
vector224:
  pushl $0
  1027a1:	6a 00                	push   $0x0
  pushl $224
  1027a3:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1027a8:	e9 74 01 00 00       	jmp    102921 <__alltraps>

001027ad <vector225>:
.globl vector225
vector225:
  pushl $0
  1027ad:	6a 00                	push   $0x0
  pushl $225
  1027af:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1027b4:	e9 68 01 00 00       	jmp    102921 <__alltraps>

001027b9 <vector226>:
.globl vector226
vector226:
  pushl $0
  1027b9:	6a 00                	push   $0x0
  pushl $226
  1027bb:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1027c0:	e9 5c 01 00 00       	jmp    102921 <__alltraps>

001027c5 <vector227>:
.globl vector227
vector227:
  pushl $0
  1027c5:	6a 00                	push   $0x0
  pushl $227
  1027c7:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1027cc:	e9 50 01 00 00       	jmp    102921 <__alltraps>

001027d1 <vector228>:
.globl vector228
vector228:
  pushl $0
  1027d1:	6a 00                	push   $0x0
  pushl $228
  1027d3:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1027d8:	e9 44 01 00 00       	jmp    102921 <__alltraps>

001027dd <vector229>:
.globl vector229
vector229:
  pushl $0
  1027dd:	6a 00                	push   $0x0
  pushl $229
  1027df:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1027e4:	e9 38 01 00 00       	jmp    102921 <__alltraps>

001027e9 <vector230>:
.globl vector230
vector230:
  pushl $0
  1027e9:	6a 00                	push   $0x0
  pushl $230
  1027eb:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1027f0:	e9 2c 01 00 00       	jmp    102921 <__alltraps>

001027f5 <vector231>:
.globl vector231
vector231:
  pushl $0
  1027f5:	6a 00                	push   $0x0
  pushl $231
  1027f7:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1027fc:	e9 20 01 00 00       	jmp    102921 <__alltraps>

00102801 <vector232>:
.globl vector232
vector232:
  pushl $0
  102801:	6a 00                	push   $0x0
  pushl $232
  102803:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102808:	e9 14 01 00 00       	jmp    102921 <__alltraps>

0010280d <vector233>:
.globl vector233
vector233:
  pushl $0
  10280d:	6a 00                	push   $0x0
  pushl $233
  10280f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102814:	e9 08 01 00 00       	jmp    102921 <__alltraps>

00102819 <vector234>:
.globl vector234
vector234:
  pushl $0
  102819:	6a 00                	push   $0x0
  pushl $234
  10281b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102820:	e9 fc 00 00 00       	jmp    102921 <__alltraps>

00102825 <vector235>:
.globl vector235
vector235:
  pushl $0
  102825:	6a 00                	push   $0x0
  pushl $235
  102827:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10282c:	e9 f0 00 00 00       	jmp    102921 <__alltraps>

00102831 <vector236>:
.globl vector236
vector236:
  pushl $0
  102831:	6a 00                	push   $0x0
  pushl $236
  102833:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102838:	e9 e4 00 00 00       	jmp    102921 <__alltraps>

0010283d <vector237>:
.globl vector237
vector237:
  pushl $0
  10283d:	6a 00                	push   $0x0
  pushl $237
  10283f:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102844:	e9 d8 00 00 00       	jmp    102921 <__alltraps>

00102849 <vector238>:
.globl vector238
vector238:
  pushl $0
  102849:	6a 00                	push   $0x0
  pushl $238
  10284b:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102850:	e9 cc 00 00 00       	jmp    102921 <__alltraps>

00102855 <vector239>:
.globl vector239
vector239:
  pushl $0
  102855:	6a 00                	push   $0x0
  pushl $239
  102857:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10285c:	e9 c0 00 00 00       	jmp    102921 <__alltraps>

00102861 <vector240>:
.globl vector240
vector240:
  pushl $0
  102861:	6a 00                	push   $0x0
  pushl $240
  102863:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102868:	e9 b4 00 00 00       	jmp    102921 <__alltraps>

0010286d <vector241>:
.globl vector241
vector241:
  pushl $0
  10286d:	6a 00                	push   $0x0
  pushl $241
  10286f:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102874:	e9 a8 00 00 00       	jmp    102921 <__alltraps>

00102879 <vector242>:
.globl vector242
vector242:
  pushl $0
  102879:	6a 00                	push   $0x0
  pushl $242
  10287b:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102880:	e9 9c 00 00 00       	jmp    102921 <__alltraps>

00102885 <vector243>:
.globl vector243
vector243:
  pushl $0
  102885:	6a 00                	push   $0x0
  pushl $243
  102887:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10288c:	e9 90 00 00 00       	jmp    102921 <__alltraps>

00102891 <vector244>:
.globl vector244
vector244:
  pushl $0
  102891:	6a 00                	push   $0x0
  pushl $244
  102893:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102898:	e9 84 00 00 00       	jmp    102921 <__alltraps>

0010289d <vector245>:
.globl vector245
vector245:
  pushl $0
  10289d:	6a 00                	push   $0x0
  pushl $245
  10289f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1028a4:	e9 78 00 00 00       	jmp    102921 <__alltraps>

001028a9 <vector246>:
.globl vector246
vector246:
  pushl $0
  1028a9:	6a 00                	push   $0x0
  pushl $246
  1028ab:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1028b0:	e9 6c 00 00 00       	jmp    102921 <__alltraps>

001028b5 <vector247>:
.globl vector247
vector247:
  pushl $0
  1028b5:	6a 00                	push   $0x0
  pushl $247
  1028b7:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1028bc:	e9 60 00 00 00       	jmp    102921 <__alltraps>

001028c1 <vector248>:
.globl vector248
vector248:
  pushl $0
  1028c1:	6a 00                	push   $0x0
  pushl $248
  1028c3:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1028c8:	e9 54 00 00 00       	jmp    102921 <__alltraps>

001028cd <vector249>:
.globl vector249
vector249:
  pushl $0
  1028cd:	6a 00                	push   $0x0
  pushl $249
  1028cf:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1028d4:	e9 48 00 00 00       	jmp    102921 <__alltraps>

001028d9 <vector250>:
.globl vector250
vector250:
  pushl $0
  1028d9:	6a 00                	push   $0x0
  pushl $250
  1028db:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1028e0:	e9 3c 00 00 00       	jmp    102921 <__alltraps>

001028e5 <vector251>:
.globl vector251
vector251:
  pushl $0
  1028e5:	6a 00                	push   $0x0
  pushl $251
  1028e7:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1028ec:	e9 30 00 00 00       	jmp    102921 <__alltraps>

001028f1 <vector252>:
.globl vector252
vector252:
  pushl $0
  1028f1:	6a 00                	push   $0x0
  pushl $252
  1028f3:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1028f8:	e9 24 00 00 00       	jmp    102921 <__alltraps>

001028fd <vector253>:
.globl vector253
vector253:
  pushl $0
  1028fd:	6a 00                	push   $0x0
  pushl $253
  1028ff:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102904:	e9 18 00 00 00       	jmp    102921 <__alltraps>

00102909 <vector254>:
.globl vector254
vector254:
  pushl $0
  102909:	6a 00                	push   $0x0
  pushl $254
  10290b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102910:	e9 0c 00 00 00       	jmp    102921 <__alltraps>

00102915 <vector255>:
.globl vector255
vector255:
  pushl $0
  102915:	6a 00                	push   $0x0
  pushl $255
  102917:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10291c:	e9 00 00 00 00       	jmp    102921 <__alltraps>

00102921 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102921:	1e                   	push   %ds
    pushl %es
  102922:	06                   	push   %es
    pushl %fs
  102923:	0f a0                	push   %fs
    pushl %gs
  102925:	0f a8                	push   %gs
    pushal
  102927:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102928:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10292d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10292f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102931:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102932:	e8 63 f5 ff ff       	call   101e9a <trap>

    # pop the pushed stack pointer
    popl %esp
  102937:	5c                   	pop    %esp

00102938 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102938:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102939:	0f a9                	pop    %gs
    popl %fs
  10293b:	0f a1                	pop    %fs
    popl %es
  10293d:	07                   	pop    %es
    popl %ds
  10293e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10293f:	83 c4 08             	add    $0x8,%esp
    iret
  102942:	cf                   	iret   

00102943 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102943:	55                   	push   %ebp
  102944:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102946:	8b 45 08             	mov    0x8(%ebp),%eax
  102949:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  10294c:	b8 23 00 00 00       	mov    $0x23,%eax
  102951:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102953:	b8 23 00 00 00       	mov    $0x23,%eax
  102958:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  10295a:	b8 10 00 00 00       	mov    $0x10,%eax
  10295f:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102961:	b8 10 00 00 00       	mov    $0x10,%eax
  102966:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102968:	b8 10 00 00 00       	mov    $0x10,%eax
  10296d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  10296f:	ea 76 29 10 00 08 00 	ljmp   $0x8,$0x102976
}
  102976:	90                   	nop
  102977:	5d                   	pop    %ebp
  102978:	c3                   	ret    

00102979 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102979:	55                   	push   %ebp
  10297a:	89 e5                	mov    %esp,%ebp
  10297c:	83 ec 10             	sub    $0x10,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  10297f:	b8 80 f9 10 00       	mov    $0x10f980,%eax
  102984:	05 00 04 00 00       	add    $0x400,%eax
  102989:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  10298e:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  102995:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102997:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  10299e:	68 00 
  1029a0:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029a5:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  1029ab:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029b0:	c1 e8 10             	shr    $0x10,%eax
  1029b3:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  1029b8:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029bf:	83 e0 f0             	and    $0xfffffff0,%eax
  1029c2:	83 c8 09             	or     $0x9,%eax
  1029c5:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029ca:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029d1:	83 c8 10             	or     $0x10,%eax
  1029d4:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029d9:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029e0:	83 e0 9f             	and    $0xffffff9f,%eax
  1029e3:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029e8:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029ef:	83 c8 80             	or     $0xffffff80,%eax
  1029f2:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029f7:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1029fe:	83 e0 f0             	and    $0xfffffff0,%eax
  102a01:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a06:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a0d:	83 e0 ef             	and    $0xffffffef,%eax
  102a10:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a15:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a1c:	83 e0 df             	and    $0xffffffdf,%eax
  102a1f:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a24:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a2b:	83 c8 40             	or     $0x40,%eax
  102a2e:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a33:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a3a:	83 e0 7f             	and    $0x7f,%eax
  102a3d:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a42:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102a47:	c1 e8 18             	shr    $0x18,%eax
  102a4a:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102a4f:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a56:	83 e0 ef             	and    $0xffffffef,%eax
  102a59:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102a5e:	68 10 ea 10 00       	push   $0x10ea10
  102a63:	e8 db fe ff ff       	call   102943 <lgdt>
  102a68:	83 c4 04             	add    $0x4,%esp
  102a6b:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102a71:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102a75:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102a78:	90                   	nop
  102a79:	c9                   	leave  
  102a7a:	c3                   	ret    

00102a7b <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102a7b:	55                   	push   %ebp
  102a7c:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102a7e:	e8 f6 fe ff ff       	call   102979 <gdt_init>
}
  102a83:	90                   	nop
  102a84:	5d                   	pop    %ebp
  102a85:	c3                   	ret    

00102a86 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102a86:	55                   	push   %ebp
  102a87:	89 e5                	mov    %esp,%ebp
  102a89:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102a8c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102a93:	eb 04                	jmp    102a99 <strlen+0x13>
        cnt ++;
  102a95:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  102a99:	8b 45 08             	mov    0x8(%ebp),%eax
  102a9c:	8d 50 01             	lea    0x1(%eax),%edx
  102a9f:	89 55 08             	mov    %edx,0x8(%ebp)
  102aa2:	0f b6 00             	movzbl (%eax),%eax
  102aa5:	84 c0                	test   %al,%al
  102aa7:	75 ec                	jne    102a95 <strlen+0xf>
    }
    return cnt;
  102aa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102aac:	c9                   	leave  
  102aad:	c3                   	ret    

00102aae <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102aae:	55                   	push   %ebp
  102aaf:	89 e5                	mov    %esp,%ebp
  102ab1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102ab4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102abb:	eb 04                	jmp    102ac1 <strnlen+0x13>
        cnt ++;
  102abd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102ac1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ac4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102ac7:	73 10                	jae    102ad9 <strnlen+0x2b>
  102ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  102acc:	8d 50 01             	lea    0x1(%eax),%edx
  102acf:	89 55 08             	mov    %edx,0x8(%ebp)
  102ad2:	0f b6 00             	movzbl (%eax),%eax
  102ad5:	84 c0                	test   %al,%al
  102ad7:	75 e4                	jne    102abd <strnlen+0xf>
    }
    return cnt;
  102ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102adc:	c9                   	leave  
  102add:	c3                   	ret    

00102ade <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102ade:	55                   	push   %ebp
  102adf:	89 e5                	mov    %esp,%ebp
  102ae1:	57                   	push   %edi
  102ae2:	56                   	push   %esi
  102ae3:	83 ec 20             	sub    $0x20,%esp
  102ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  102aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102af2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102af8:	89 d1                	mov    %edx,%ecx
  102afa:	89 c2                	mov    %eax,%edx
  102afc:	89 ce                	mov    %ecx,%esi
  102afe:	89 d7                	mov    %edx,%edi
  102b00:	ac                   	lods   %ds:(%esi),%al
  102b01:	aa                   	stos   %al,%es:(%edi)
  102b02:	84 c0                	test   %al,%al
  102b04:	75 fa                	jne    102b00 <strcpy+0x22>
  102b06:	89 fa                	mov    %edi,%edx
  102b08:	89 f1                	mov    %esi,%ecx
  102b0a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102b0d:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102b10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  102b16:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102b17:	83 c4 20             	add    $0x20,%esp
  102b1a:	5e                   	pop    %esi
  102b1b:	5f                   	pop    %edi
  102b1c:	5d                   	pop    %ebp
  102b1d:	c3                   	ret    

00102b1e <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102b1e:	55                   	push   %ebp
  102b1f:	89 e5                	mov    %esp,%ebp
  102b21:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102b24:	8b 45 08             	mov    0x8(%ebp),%eax
  102b27:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102b2a:	eb 21                	jmp    102b4d <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  102b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b2f:	0f b6 10             	movzbl (%eax),%edx
  102b32:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b35:	88 10                	mov    %dl,(%eax)
  102b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b3a:	0f b6 00             	movzbl (%eax),%eax
  102b3d:	84 c0                	test   %al,%al
  102b3f:	74 04                	je     102b45 <strncpy+0x27>
            src ++;
  102b41:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  102b45:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102b49:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  102b4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102b51:	75 d9                	jne    102b2c <strncpy+0xe>
    }
    return dst;
  102b53:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102b56:	c9                   	leave  
  102b57:	c3                   	ret    

00102b58 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102b58:	55                   	push   %ebp
  102b59:	89 e5                	mov    %esp,%ebp
  102b5b:	57                   	push   %edi
  102b5c:	56                   	push   %esi
  102b5d:	83 ec 20             	sub    $0x20,%esp
  102b60:	8b 45 08             	mov    0x8(%ebp),%eax
  102b63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  102b6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b72:	89 d1                	mov    %edx,%ecx
  102b74:	89 c2                	mov    %eax,%edx
  102b76:	89 ce                	mov    %ecx,%esi
  102b78:	89 d7                	mov    %edx,%edi
  102b7a:	ac                   	lods   %ds:(%esi),%al
  102b7b:	ae                   	scas   %es:(%edi),%al
  102b7c:	75 08                	jne    102b86 <strcmp+0x2e>
  102b7e:	84 c0                	test   %al,%al
  102b80:	75 f8                	jne    102b7a <strcmp+0x22>
  102b82:	31 c0                	xor    %eax,%eax
  102b84:	eb 04                	jmp    102b8a <strcmp+0x32>
  102b86:	19 c0                	sbb    %eax,%eax
  102b88:	0c 01                	or     $0x1,%al
  102b8a:	89 fa                	mov    %edi,%edx
  102b8c:	89 f1                	mov    %esi,%ecx
  102b8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102b91:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102b94:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  102b97:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102b9a:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102b9b:	83 c4 20             	add    $0x20,%esp
  102b9e:	5e                   	pop    %esi
  102b9f:	5f                   	pop    %edi
  102ba0:	5d                   	pop    %ebp
  102ba1:	c3                   	ret    

00102ba2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102ba2:	55                   	push   %ebp
  102ba3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102ba5:	eb 0c                	jmp    102bb3 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  102ba7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102bab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102baf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102bb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bb7:	74 1a                	je     102bd3 <strncmp+0x31>
  102bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bbc:	0f b6 00             	movzbl (%eax),%eax
  102bbf:	84 c0                	test   %al,%al
  102bc1:	74 10                	je     102bd3 <strncmp+0x31>
  102bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  102bc6:	0f b6 10             	movzbl (%eax),%edx
  102bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bcc:	0f b6 00             	movzbl (%eax),%eax
  102bcf:	38 c2                	cmp    %al,%dl
  102bd1:	74 d4                	je     102ba7 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102bd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bd7:	74 18                	je     102bf1 <strncmp+0x4f>
  102bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bdc:	0f b6 00             	movzbl (%eax),%eax
  102bdf:	0f b6 d0             	movzbl %al,%edx
  102be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102be5:	0f b6 00             	movzbl (%eax),%eax
  102be8:	0f b6 c0             	movzbl %al,%eax
  102beb:	29 c2                	sub    %eax,%edx
  102bed:	89 d0                	mov    %edx,%eax
  102bef:	eb 05                	jmp    102bf6 <strncmp+0x54>
  102bf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102bf6:	5d                   	pop    %ebp
  102bf7:	c3                   	ret    

00102bf8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102bf8:	55                   	push   %ebp
  102bf9:	89 e5                	mov    %esp,%ebp
  102bfb:	83 ec 04             	sub    $0x4,%esp
  102bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c01:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102c04:	eb 14                	jmp    102c1a <strchr+0x22>
        if (*s == c) {
  102c06:	8b 45 08             	mov    0x8(%ebp),%eax
  102c09:	0f b6 00             	movzbl (%eax),%eax
  102c0c:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102c0f:	75 05                	jne    102c16 <strchr+0x1e>
            return (char *)s;
  102c11:	8b 45 08             	mov    0x8(%ebp),%eax
  102c14:	eb 13                	jmp    102c29 <strchr+0x31>
        }
        s ++;
  102c16:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c1d:	0f b6 00             	movzbl (%eax),%eax
  102c20:	84 c0                	test   %al,%al
  102c22:	75 e2                	jne    102c06 <strchr+0xe>
    }
    return NULL;
  102c24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102c29:	c9                   	leave  
  102c2a:	c3                   	ret    

00102c2b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102c2b:	55                   	push   %ebp
  102c2c:	89 e5                	mov    %esp,%ebp
  102c2e:	83 ec 04             	sub    $0x4,%esp
  102c31:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c34:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102c37:	eb 0f                	jmp    102c48 <strfind+0x1d>
        if (*s == c) {
  102c39:	8b 45 08             	mov    0x8(%ebp),%eax
  102c3c:	0f b6 00             	movzbl (%eax),%eax
  102c3f:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102c42:	74 10                	je     102c54 <strfind+0x29>
            break;
        }
        s ++;
  102c44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102c48:	8b 45 08             	mov    0x8(%ebp),%eax
  102c4b:	0f b6 00             	movzbl (%eax),%eax
  102c4e:	84 c0                	test   %al,%al
  102c50:	75 e7                	jne    102c39 <strfind+0xe>
  102c52:	eb 01                	jmp    102c55 <strfind+0x2a>
            break;
  102c54:	90                   	nop
    }
    return (char *)s;
  102c55:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102c58:	c9                   	leave  
  102c59:	c3                   	ret    

00102c5a <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102c5a:	55                   	push   %ebp
  102c5b:	89 e5                	mov    %esp,%ebp
  102c5d:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102c60:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102c67:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102c6e:	eb 04                	jmp    102c74 <strtol+0x1a>
        s ++;
  102c70:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  102c74:	8b 45 08             	mov    0x8(%ebp),%eax
  102c77:	0f b6 00             	movzbl (%eax),%eax
  102c7a:	3c 20                	cmp    $0x20,%al
  102c7c:	74 f2                	je     102c70 <strtol+0x16>
  102c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  102c81:	0f b6 00             	movzbl (%eax),%eax
  102c84:	3c 09                	cmp    $0x9,%al
  102c86:	74 e8                	je     102c70 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  102c88:	8b 45 08             	mov    0x8(%ebp),%eax
  102c8b:	0f b6 00             	movzbl (%eax),%eax
  102c8e:	3c 2b                	cmp    $0x2b,%al
  102c90:	75 06                	jne    102c98 <strtol+0x3e>
        s ++;
  102c92:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102c96:	eb 15                	jmp    102cad <strtol+0x53>
    }
    else if (*s == '-') {
  102c98:	8b 45 08             	mov    0x8(%ebp),%eax
  102c9b:	0f b6 00             	movzbl (%eax),%eax
  102c9e:	3c 2d                	cmp    $0x2d,%al
  102ca0:	75 0b                	jne    102cad <strtol+0x53>
        s ++, neg = 1;
  102ca2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102ca6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102cad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102cb1:	74 06                	je     102cb9 <strtol+0x5f>
  102cb3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102cb7:	75 24                	jne    102cdd <strtol+0x83>
  102cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  102cbc:	0f b6 00             	movzbl (%eax),%eax
  102cbf:	3c 30                	cmp    $0x30,%al
  102cc1:	75 1a                	jne    102cdd <strtol+0x83>
  102cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  102cc6:	83 c0 01             	add    $0x1,%eax
  102cc9:	0f b6 00             	movzbl (%eax),%eax
  102ccc:	3c 78                	cmp    $0x78,%al
  102cce:	75 0d                	jne    102cdd <strtol+0x83>
        s += 2, base = 16;
  102cd0:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102cd4:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102cdb:	eb 2a                	jmp    102d07 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  102cdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102ce1:	75 17                	jne    102cfa <strtol+0xa0>
  102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce6:	0f b6 00             	movzbl (%eax),%eax
  102ce9:	3c 30                	cmp    $0x30,%al
  102ceb:	75 0d                	jne    102cfa <strtol+0xa0>
        s ++, base = 8;
  102ced:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102cf1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102cf8:	eb 0d                	jmp    102d07 <strtol+0xad>
    }
    else if (base == 0) {
  102cfa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102cfe:	75 07                	jne    102d07 <strtol+0xad>
        base = 10;
  102d00:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102d07:	8b 45 08             	mov    0x8(%ebp),%eax
  102d0a:	0f b6 00             	movzbl (%eax),%eax
  102d0d:	3c 2f                	cmp    $0x2f,%al
  102d0f:	7e 1b                	jle    102d2c <strtol+0xd2>
  102d11:	8b 45 08             	mov    0x8(%ebp),%eax
  102d14:	0f b6 00             	movzbl (%eax),%eax
  102d17:	3c 39                	cmp    $0x39,%al
  102d19:	7f 11                	jg     102d2c <strtol+0xd2>
            dig = *s - '0';
  102d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d1e:	0f b6 00             	movzbl (%eax),%eax
  102d21:	0f be c0             	movsbl %al,%eax
  102d24:	83 e8 30             	sub    $0x30,%eax
  102d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d2a:	eb 48                	jmp    102d74 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d2f:	0f b6 00             	movzbl (%eax),%eax
  102d32:	3c 60                	cmp    $0x60,%al
  102d34:	7e 1b                	jle    102d51 <strtol+0xf7>
  102d36:	8b 45 08             	mov    0x8(%ebp),%eax
  102d39:	0f b6 00             	movzbl (%eax),%eax
  102d3c:	3c 7a                	cmp    $0x7a,%al
  102d3e:	7f 11                	jg     102d51 <strtol+0xf7>
            dig = *s - 'a' + 10;
  102d40:	8b 45 08             	mov    0x8(%ebp),%eax
  102d43:	0f b6 00             	movzbl (%eax),%eax
  102d46:	0f be c0             	movsbl %al,%eax
  102d49:	83 e8 57             	sub    $0x57,%eax
  102d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d4f:	eb 23                	jmp    102d74 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102d51:	8b 45 08             	mov    0x8(%ebp),%eax
  102d54:	0f b6 00             	movzbl (%eax),%eax
  102d57:	3c 40                	cmp    $0x40,%al
  102d59:	7e 3c                	jle    102d97 <strtol+0x13d>
  102d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d5e:	0f b6 00             	movzbl (%eax),%eax
  102d61:	3c 5a                	cmp    $0x5a,%al
  102d63:	7f 32                	jg     102d97 <strtol+0x13d>
            dig = *s - 'A' + 10;
  102d65:	8b 45 08             	mov    0x8(%ebp),%eax
  102d68:	0f b6 00             	movzbl (%eax),%eax
  102d6b:	0f be c0             	movsbl %al,%eax
  102d6e:	83 e8 37             	sub    $0x37,%eax
  102d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d77:	3b 45 10             	cmp    0x10(%ebp),%eax
  102d7a:	7d 1a                	jge    102d96 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
  102d7c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102d80:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102d83:	0f af 45 10          	imul   0x10(%ebp),%eax
  102d87:	89 c2                	mov    %eax,%edx
  102d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d8c:	01 d0                	add    %edx,%eax
  102d8e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  102d91:	e9 71 ff ff ff       	jmp    102d07 <strtol+0xad>
            break;
  102d96:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  102d97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102d9b:	74 08                	je     102da5 <strtol+0x14b>
        *endptr = (char *) s;
  102d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102da0:	8b 55 08             	mov    0x8(%ebp),%edx
  102da3:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102da5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102da9:	74 07                	je     102db2 <strtol+0x158>
  102dab:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102dae:	f7 d8                	neg    %eax
  102db0:	eb 03                	jmp    102db5 <strtol+0x15b>
  102db2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102db5:	c9                   	leave  
  102db6:	c3                   	ret    

00102db7 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102db7:	55                   	push   %ebp
  102db8:	89 e5                	mov    %esp,%ebp
  102dba:	57                   	push   %edi
  102dbb:	83 ec 24             	sub    $0x24,%esp
  102dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc1:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102dc4:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  102dcb:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102dce:	88 45 f7             	mov    %al,-0x9(%ebp)
  102dd1:	8b 45 10             	mov    0x10(%ebp),%eax
  102dd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102dd7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102dda:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102dde:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102de1:	89 d7                	mov    %edx,%edi
  102de3:	f3 aa                	rep stos %al,%es:(%edi)
  102de5:	89 fa                	mov    %edi,%edx
  102de7:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102dea:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102ded:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102df0:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102df1:	83 c4 24             	add    $0x24,%esp
  102df4:	5f                   	pop    %edi
  102df5:	5d                   	pop    %ebp
  102df6:	c3                   	ret    

00102df7 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102df7:	55                   	push   %ebp
  102df8:	89 e5                	mov    %esp,%ebp
  102dfa:	57                   	push   %edi
  102dfb:	56                   	push   %esi
  102dfc:	53                   	push   %ebx
  102dfd:	83 ec 30             	sub    $0x30,%esp
  102e00:	8b 45 08             	mov    0x8(%ebp),%eax
  102e03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e06:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e0c:	8b 45 10             	mov    0x10(%ebp),%eax
  102e0f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e15:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102e18:	73 42                	jae    102e5c <memmove+0x65>
  102e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e26:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e29:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102e2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e2f:	c1 e8 02             	shr    $0x2,%eax
  102e32:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102e34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e3a:	89 d7                	mov    %edx,%edi
  102e3c:	89 c6                	mov    %eax,%esi
  102e3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102e40:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102e43:	83 e1 03             	and    $0x3,%ecx
  102e46:	74 02                	je     102e4a <memmove+0x53>
  102e48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102e4a:	89 f0                	mov    %esi,%eax
  102e4c:	89 fa                	mov    %edi,%edx
  102e4e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102e51:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e54:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  102e57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  102e5a:	eb 36                	jmp    102e92 <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102e5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e5f:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e65:	01 c2                	add    %eax,%edx
  102e67:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e6a:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e70:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  102e73:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e76:	89 c1                	mov    %eax,%ecx
  102e78:	89 d8                	mov    %ebx,%eax
  102e7a:	89 d6                	mov    %edx,%esi
  102e7c:	89 c7                	mov    %eax,%edi
  102e7e:	fd                   	std    
  102e7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102e81:	fc                   	cld    
  102e82:	89 f8                	mov    %edi,%eax
  102e84:	89 f2                	mov    %esi,%edx
  102e86:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102e89:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102e8c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  102e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102e92:	83 c4 30             	add    $0x30,%esp
  102e95:	5b                   	pop    %ebx
  102e96:	5e                   	pop    %esi
  102e97:	5f                   	pop    %edi
  102e98:	5d                   	pop    %ebp
  102e99:	c3                   	ret    

00102e9a <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102e9a:	55                   	push   %ebp
  102e9b:	89 e5                	mov    %esp,%ebp
  102e9d:	57                   	push   %edi
  102e9e:	56                   	push   %esi
  102e9f:	83 ec 20             	sub    $0x20,%esp
  102ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102eae:	8b 45 10             	mov    0x10(%ebp),%eax
  102eb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102eb7:	c1 e8 02             	shr    $0x2,%eax
  102eba:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102ebc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ec2:	89 d7                	mov    %edx,%edi
  102ec4:	89 c6                	mov    %eax,%esi
  102ec6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102ec8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102ecb:	83 e1 03             	and    $0x3,%ecx
  102ece:	74 02                	je     102ed2 <memcpy+0x38>
  102ed0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102ed2:	89 f0                	mov    %esi,%eax
  102ed4:	89 fa                	mov    %edi,%edx
  102ed6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102ed9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102edc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  102edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  102ee2:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102ee3:	83 c4 20             	add    $0x20,%esp
  102ee6:	5e                   	pop    %esi
  102ee7:	5f                   	pop    %edi
  102ee8:	5d                   	pop    %ebp
  102ee9:	c3                   	ret    

00102eea <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102eea:	55                   	push   %ebp
  102eeb:	89 e5                	mov    %esp,%ebp
  102eed:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ef9:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102efc:	eb 30                	jmp    102f2e <memcmp+0x44>
        if (*s1 != *s2) {
  102efe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102f01:	0f b6 10             	movzbl (%eax),%edx
  102f04:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102f07:	0f b6 00             	movzbl (%eax),%eax
  102f0a:	38 c2                	cmp    %al,%dl
  102f0c:	74 18                	je     102f26 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102f0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102f11:	0f b6 00             	movzbl (%eax),%eax
  102f14:	0f b6 d0             	movzbl %al,%edx
  102f17:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102f1a:	0f b6 00             	movzbl (%eax),%eax
  102f1d:	0f b6 c0             	movzbl %al,%eax
  102f20:	29 c2                	sub    %eax,%edx
  102f22:	89 d0                	mov    %edx,%eax
  102f24:	eb 1a                	jmp    102f40 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  102f26:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102f2a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  102f2e:	8b 45 10             	mov    0x10(%ebp),%eax
  102f31:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f34:	89 55 10             	mov    %edx,0x10(%ebp)
  102f37:	85 c0                	test   %eax,%eax
  102f39:	75 c3                	jne    102efe <memcmp+0x14>
    }
    return 0;
  102f3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102f40:	c9                   	leave  
  102f41:	c3                   	ret    

00102f42 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102f42:	55                   	push   %ebp
  102f43:	89 e5                	mov    %esp,%ebp
  102f45:	83 ec 38             	sub    $0x38,%esp
  102f48:	8b 45 10             	mov    0x10(%ebp),%eax
  102f4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f4e:	8b 45 14             	mov    0x14(%ebp),%eax
  102f51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102f54:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f57:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102f5d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102f60:	8b 45 18             	mov    0x18(%ebp),%eax
  102f63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102f66:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f69:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102f6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102f6f:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f7c:	74 1c                	je     102f9a <printnum+0x58>
  102f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f81:	ba 00 00 00 00       	mov    $0x0,%edx
  102f86:	f7 75 e4             	divl   -0x1c(%ebp)
  102f89:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f8f:	ba 00 00 00 00       	mov    $0x0,%edx
  102f94:	f7 75 e4             	divl   -0x1c(%ebp)
  102f97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102fa0:	f7 75 e4             	divl   -0x1c(%ebp)
  102fa3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102fa6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102fa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102faf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102fb2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102fb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102fb8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102fbb:	8b 45 18             	mov    0x18(%ebp),%eax
  102fbe:	ba 00 00 00 00       	mov    $0x0,%edx
  102fc3:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102fc6:	72 41                	jb     103009 <printnum+0xc7>
  102fc8:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102fcb:	77 05                	ja     102fd2 <printnum+0x90>
  102fcd:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102fd0:	72 37                	jb     103009 <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
  102fd2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102fd5:	83 e8 01             	sub    $0x1,%eax
  102fd8:	83 ec 04             	sub    $0x4,%esp
  102fdb:	ff 75 20             	pushl  0x20(%ebp)
  102fde:	50                   	push   %eax
  102fdf:	ff 75 18             	pushl  0x18(%ebp)
  102fe2:	ff 75 ec             	pushl  -0x14(%ebp)
  102fe5:	ff 75 e8             	pushl  -0x18(%ebp)
  102fe8:	ff 75 0c             	pushl  0xc(%ebp)
  102feb:	ff 75 08             	pushl  0x8(%ebp)
  102fee:	e8 4f ff ff ff       	call   102f42 <printnum>
  102ff3:	83 c4 20             	add    $0x20,%esp
  102ff6:	eb 1b                	jmp    103013 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102ff8:	83 ec 08             	sub    $0x8,%esp
  102ffb:	ff 75 0c             	pushl  0xc(%ebp)
  102ffe:	ff 75 20             	pushl  0x20(%ebp)
  103001:	8b 45 08             	mov    0x8(%ebp),%eax
  103004:	ff d0                	call   *%eax
  103006:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
  103009:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  10300d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103011:	7f e5                	jg     102ff8 <printnum+0xb6>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  103013:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103016:	05 f0 3c 10 00       	add    $0x103cf0,%eax
  10301b:	0f b6 00             	movzbl (%eax),%eax
  10301e:	0f be c0             	movsbl %al,%eax
  103021:	83 ec 08             	sub    $0x8,%esp
  103024:	ff 75 0c             	pushl  0xc(%ebp)
  103027:	50                   	push   %eax
  103028:	8b 45 08             	mov    0x8(%ebp),%eax
  10302b:	ff d0                	call   *%eax
  10302d:	83 c4 10             	add    $0x10,%esp
}
  103030:	90                   	nop
  103031:	c9                   	leave  
  103032:	c3                   	ret    

00103033 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  103033:	55                   	push   %ebp
  103034:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103036:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10303a:	7e 14                	jle    103050 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  10303c:	8b 45 08             	mov    0x8(%ebp),%eax
  10303f:	8b 00                	mov    (%eax),%eax
  103041:	8d 48 08             	lea    0x8(%eax),%ecx
  103044:	8b 55 08             	mov    0x8(%ebp),%edx
  103047:	89 0a                	mov    %ecx,(%edx)
  103049:	8b 50 04             	mov    0x4(%eax),%edx
  10304c:	8b 00                	mov    (%eax),%eax
  10304e:	eb 30                	jmp    103080 <getuint+0x4d>
    }
    else if (lflag) {
  103050:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103054:	74 16                	je     10306c <getuint+0x39>
        return va_arg(*ap, unsigned long);
  103056:	8b 45 08             	mov    0x8(%ebp),%eax
  103059:	8b 00                	mov    (%eax),%eax
  10305b:	8d 48 04             	lea    0x4(%eax),%ecx
  10305e:	8b 55 08             	mov    0x8(%ebp),%edx
  103061:	89 0a                	mov    %ecx,(%edx)
  103063:	8b 00                	mov    (%eax),%eax
  103065:	ba 00 00 00 00       	mov    $0x0,%edx
  10306a:	eb 14                	jmp    103080 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10306c:	8b 45 08             	mov    0x8(%ebp),%eax
  10306f:	8b 00                	mov    (%eax),%eax
  103071:	8d 48 04             	lea    0x4(%eax),%ecx
  103074:	8b 55 08             	mov    0x8(%ebp),%edx
  103077:	89 0a                	mov    %ecx,(%edx)
  103079:	8b 00                	mov    (%eax),%eax
  10307b:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  103080:	5d                   	pop    %ebp
  103081:	c3                   	ret    

00103082 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  103082:	55                   	push   %ebp
  103083:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103085:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103089:	7e 14                	jle    10309f <getint+0x1d>
        return va_arg(*ap, long long);
  10308b:	8b 45 08             	mov    0x8(%ebp),%eax
  10308e:	8b 00                	mov    (%eax),%eax
  103090:	8d 48 08             	lea    0x8(%eax),%ecx
  103093:	8b 55 08             	mov    0x8(%ebp),%edx
  103096:	89 0a                	mov    %ecx,(%edx)
  103098:	8b 50 04             	mov    0x4(%eax),%edx
  10309b:	8b 00                	mov    (%eax),%eax
  10309d:	eb 28                	jmp    1030c7 <getint+0x45>
    }
    else if (lflag) {
  10309f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1030a3:	74 12                	je     1030b7 <getint+0x35>
        return va_arg(*ap, long);
  1030a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1030a8:	8b 00                	mov    (%eax),%eax
  1030aa:	8d 48 04             	lea    0x4(%eax),%ecx
  1030ad:	8b 55 08             	mov    0x8(%ebp),%edx
  1030b0:	89 0a                	mov    %ecx,(%edx)
  1030b2:	8b 00                	mov    (%eax),%eax
  1030b4:	99                   	cltd   
  1030b5:	eb 10                	jmp    1030c7 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1030b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ba:	8b 00                	mov    (%eax),%eax
  1030bc:	8d 48 04             	lea    0x4(%eax),%ecx
  1030bf:	8b 55 08             	mov    0x8(%ebp),%edx
  1030c2:	89 0a                	mov    %ecx,(%edx)
  1030c4:	8b 00                	mov    (%eax),%eax
  1030c6:	99                   	cltd   
    }
}
  1030c7:	5d                   	pop    %ebp
  1030c8:	c3                   	ret    

001030c9 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1030c9:	55                   	push   %ebp
  1030ca:	89 e5                	mov    %esp,%ebp
  1030cc:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  1030cf:	8d 45 14             	lea    0x14(%ebp),%eax
  1030d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1030d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030d8:	50                   	push   %eax
  1030d9:	ff 75 10             	pushl  0x10(%ebp)
  1030dc:	ff 75 0c             	pushl  0xc(%ebp)
  1030df:	ff 75 08             	pushl  0x8(%ebp)
  1030e2:	e8 06 00 00 00       	call   1030ed <vprintfmt>
  1030e7:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  1030ea:	90                   	nop
  1030eb:	c9                   	leave  
  1030ec:	c3                   	ret    

001030ed <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1030ed:	55                   	push   %ebp
  1030ee:	89 e5                	mov    %esp,%ebp
  1030f0:	56                   	push   %esi
  1030f1:	53                   	push   %ebx
  1030f2:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1030f5:	eb 17                	jmp    10310e <vprintfmt+0x21>
            if (ch == '\0') {
  1030f7:	85 db                	test   %ebx,%ebx
  1030f9:	0f 84 8e 03 00 00    	je     10348d <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
  1030ff:	83 ec 08             	sub    $0x8,%esp
  103102:	ff 75 0c             	pushl  0xc(%ebp)
  103105:	53                   	push   %ebx
  103106:	8b 45 08             	mov    0x8(%ebp),%eax
  103109:	ff d0                	call   *%eax
  10310b:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10310e:	8b 45 10             	mov    0x10(%ebp),%eax
  103111:	8d 50 01             	lea    0x1(%eax),%edx
  103114:	89 55 10             	mov    %edx,0x10(%ebp)
  103117:	0f b6 00             	movzbl (%eax),%eax
  10311a:	0f b6 d8             	movzbl %al,%ebx
  10311d:	83 fb 25             	cmp    $0x25,%ebx
  103120:	75 d5                	jne    1030f7 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  103122:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  103126:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10312d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103130:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  103133:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10313a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10313d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  103140:	8b 45 10             	mov    0x10(%ebp),%eax
  103143:	8d 50 01             	lea    0x1(%eax),%edx
  103146:	89 55 10             	mov    %edx,0x10(%ebp)
  103149:	0f b6 00             	movzbl (%eax),%eax
  10314c:	0f b6 d8             	movzbl %al,%ebx
  10314f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  103152:	83 f8 55             	cmp    $0x55,%eax
  103155:	0f 87 05 03 00 00    	ja     103460 <vprintfmt+0x373>
  10315b:	8b 04 85 14 3d 10 00 	mov    0x103d14(,%eax,4),%eax
  103162:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  103164:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103168:	eb d6                	jmp    103140 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10316a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10316e:	eb d0                	jmp    103140 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103170:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  103177:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10317a:	89 d0                	mov    %edx,%eax
  10317c:	c1 e0 02             	shl    $0x2,%eax
  10317f:	01 d0                	add    %edx,%eax
  103181:	01 c0                	add    %eax,%eax
  103183:	01 d8                	add    %ebx,%eax
  103185:	83 e8 30             	sub    $0x30,%eax
  103188:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10318b:	8b 45 10             	mov    0x10(%ebp),%eax
  10318e:	0f b6 00             	movzbl (%eax),%eax
  103191:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  103194:	83 fb 2f             	cmp    $0x2f,%ebx
  103197:	7e 39                	jle    1031d2 <vprintfmt+0xe5>
  103199:	83 fb 39             	cmp    $0x39,%ebx
  10319c:	7f 34                	jg     1031d2 <vprintfmt+0xe5>
            for (precision = 0; ; ++ fmt) {
  10319e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
  1031a2:	eb d3                	jmp    103177 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1031a4:	8b 45 14             	mov    0x14(%ebp),%eax
  1031a7:	8d 50 04             	lea    0x4(%eax),%edx
  1031aa:	89 55 14             	mov    %edx,0x14(%ebp)
  1031ad:	8b 00                	mov    (%eax),%eax
  1031af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1031b2:	eb 1f                	jmp    1031d3 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
  1031b4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1031b8:	79 86                	jns    103140 <vprintfmt+0x53>
                width = 0;
  1031ba:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1031c1:	e9 7a ff ff ff       	jmp    103140 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  1031c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1031cd:	e9 6e ff ff ff       	jmp    103140 <vprintfmt+0x53>
            goto process_precision;
  1031d2:	90                   	nop

        process_precision:
            if (width < 0)
  1031d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1031d7:	0f 89 63 ff ff ff    	jns    103140 <vprintfmt+0x53>
                width = precision, precision = -1;
  1031dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1031e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1031e3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1031ea:	e9 51 ff ff ff       	jmp    103140 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1031ef:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  1031f3:	e9 48 ff ff ff       	jmp    103140 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1031f8:	8b 45 14             	mov    0x14(%ebp),%eax
  1031fb:	8d 50 04             	lea    0x4(%eax),%edx
  1031fe:	89 55 14             	mov    %edx,0x14(%ebp)
  103201:	8b 00                	mov    (%eax),%eax
  103203:	83 ec 08             	sub    $0x8,%esp
  103206:	ff 75 0c             	pushl  0xc(%ebp)
  103209:	50                   	push   %eax
  10320a:	8b 45 08             	mov    0x8(%ebp),%eax
  10320d:	ff d0                	call   *%eax
  10320f:	83 c4 10             	add    $0x10,%esp
            break;
  103212:	e9 71 02 00 00       	jmp    103488 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
  103217:	8b 45 14             	mov    0x14(%ebp),%eax
  10321a:	8d 50 04             	lea    0x4(%eax),%edx
  10321d:	89 55 14             	mov    %edx,0x14(%ebp)
  103220:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  103222:	85 db                	test   %ebx,%ebx
  103224:	79 02                	jns    103228 <vprintfmt+0x13b>
                err = -err;
  103226:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  103228:	83 fb 06             	cmp    $0x6,%ebx
  10322b:	7f 0b                	jg     103238 <vprintfmt+0x14b>
  10322d:	8b 34 9d d4 3c 10 00 	mov    0x103cd4(,%ebx,4),%esi
  103234:	85 f6                	test   %esi,%esi
  103236:	75 19                	jne    103251 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
  103238:	53                   	push   %ebx
  103239:	68 01 3d 10 00       	push   $0x103d01
  10323e:	ff 75 0c             	pushl  0xc(%ebp)
  103241:	ff 75 08             	pushl  0x8(%ebp)
  103244:	e8 80 fe ff ff       	call   1030c9 <printfmt>
  103249:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10324c:	e9 37 02 00 00       	jmp    103488 <vprintfmt+0x39b>
                printfmt(putch, putdat, "%s", p);
  103251:	56                   	push   %esi
  103252:	68 0a 3d 10 00       	push   $0x103d0a
  103257:	ff 75 0c             	pushl  0xc(%ebp)
  10325a:	ff 75 08             	pushl  0x8(%ebp)
  10325d:	e8 67 fe ff ff       	call   1030c9 <printfmt>
  103262:	83 c4 10             	add    $0x10,%esp
            break;
  103265:	e9 1e 02 00 00       	jmp    103488 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10326a:	8b 45 14             	mov    0x14(%ebp),%eax
  10326d:	8d 50 04             	lea    0x4(%eax),%edx
  103270:	89 55 14             	mov    %edx,0x14(%ebp)
  103273:	8b 30                	mov    (%eax),%esi
  103275:	85 f6                	test   %esi,%esi
  103277:	75 05                	jne    10327e <vprintfmt+0x191>
                p = "(null)";
  103279:	be 0d 3d 10 00       	mov    $0x103d0d,%esi
            }
            if (width > 0 && padc != '-') {
  10327e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103282:	7e 76                	jle    1032fa <vprintfmt+0x20d>
  103284:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  103288:	74 70                	je     1032fa <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
  10328a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10328d:	83 ec 08             	sub    $0x8,%esp
  103290:	50                   	push   %eax
  103291:	56                   	push   %esi
  103292:	e8 17 f8 ff ff       	call   102aae <strnlen>
  103297:	83 c4 10             	add    $0x10,%esp
  10329a:	89 c2                	mov    %eax,%edx
  10329c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10329f:	29 d0                	sub    %edx,%eax
  1032a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032a4:	eb 17                	jmp    1032bd <vprintfmt+0x1d0>
                    putch(padc, putdat);
  1032a6:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1032aa:	83 ec 08             	sub    $0x8,%esp
  1032ad:	ff 75 0c             	pushl  0xc(%ebp)
  1032b0:	50                   	push   %eax
  1032b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1032b4:	ff d0                	call   *%eax
  1032b6:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
  1032b9:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1032bd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1032c1:	7f e3                	jg     1032a6 <vprintfmt+0x1b9>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1032c3:	eb 35                	jmp    1032fa <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
  1032c5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1032c9:	74 1c                	je     1032e7 <vprintfmt+0x1fa>
  1032cb:	83 fb 1f             	cmp    $0x1f,%ebx
  1032ce:	7e 05                	jle    1032d5 <vprintfmt+0x1e8>
  1032d0:	83 fb 7e             	cmp    $0x7e,%ebx
  1032d3:	7e 12                	jle    1032e7 <vprintfmt+0x1fa>
                    putch('?', putdat);
  1032d5:	83 ec 08             	sub    $0x8,%esp
  1032d8:	ff 75 0c             	pushl  0xc(%ebp)
  1032db:	6a 3f                	push   $0x3f
  1032dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1032e0:	ff d0                	call   *%eax
  1032e2:	83 c4 10             	add    $0x10,%esp
  1032e5:	eb 0f                	jmp    1032f6 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
  1032e7:	83 ec 08             	sub    $0x8,%esp
  1032ea:	ff 75 0c             	pushl  0xc(%ebp)
  1032ed:	53                   	push   %ebx
  1032ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f1:	ff d0                	call   *%eax
  1032f3:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1032f6:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1032fa:	89 f0                	mov    %esi,%eax
  1032fc:	8d 70 01             	lea    0x1(%eax),%esi
  1032ff:	0f b6 00             	movzbl (%eax),%eax
  103302:	0f be d8             	movsbl %al,%ebx
  103305:	85 db                	test   %ebx,%ebx
  103307:	74 26                	je     10332f <vprintfmt+0x242>
  103309:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10330d:	78 b6                	js     1032c5 <vprintfmt+0x1d8>
  10330f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  103313:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103317:	79 ac                	jns    1032c5 <vprintfmt+0x1d8>
                }
            }
            for (; width > 0; width --) {
  103319:	eb 14                	jmp    10332f <vprintfmt+0x242>
                putch(' ', putdat);
  10331b:	83 ec 08             	sub    $0x8,%esp
  10331e:	ff 75 0c             	pushl  0xc(%ebp)
  103321:	6a 20                	push   $0x20
  103323:	8b 45 08             	mov    0x8(%ebp),%eax
  103326:	ff d0                	call   *%eax
  103328:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
  10332b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10332f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103333:	7f e6                	jg     10331b <vprintfmt+0x22e>
            }
            break;
  103335:	e9 4e 01 00 00       	jmp    103488 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10333a:	83 ec 08             	sub    $0x8,%esp
  10333d:	ff 75 e0             	pushl  -0x20(%ebp)
  103340:	8d 45 14             	lea    0x14(%ebp),%eax
  103343:	50                   	push   %eax
  103344:	e8 39 fd ff ff       	call   103082 <getint>
  103349:	83 c4 10             	add    $0x10,%esp
  10334c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10334f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103355:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103358:	85 d2                	test   %edx,%edx
  10335a:	79 23                	jns    10337f <vprintfmt+0x292>
                putch('-', putdat);
  10335c:	83 ec 08             	sub    $0x8,%esp
  10335f:	ff 75 0c             	pushl  0xc(%ebp)
  103362:	6a 2d                	push   $0x2d
  103364:	8b 45 08             	mov    0x8(%ebp),%eax
  103367:	ff d0                	call   *%eax
  103369:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  10336c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10336f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103372:	f7 d8                	neg    %eax
  103374:	83 d2 00             	adc    $0x0,%edx
  103377:	f7 da                	neg    %edx
  103379:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10337c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10337f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103386:	e9 9f 00 00 00       	jmp    10342a <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  10338b:	83 ec 08             	sub    $0x8,%esp
  10338e:	ff 75 e0             	pushl  -0x20(%ebp)
  103391:	8d 45 14             	lea    0x14(%ebp),%eax
  103394:	50                   	push   %eax
  103395:	e8 99 fc ff ff       	call   103033 <getuint>
  10339a:	83 c4 10             	add    $0x10,%esp
  10339d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1033a3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1033aa:	eb 7e                	jmp    10342a <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1033ac:	83 ec 08             	sub    $0x8,%esp
  1033af:	ff 75 e0             	pushl  -0x20(%ebp)
  1033b2:	8d 45 14             	lea    0x14(%ebp),%eax
  1033b5:	50                   	push   %eax
  1033b6:	e8 78 fc ff ff       	call   103033 <getuint>
  1033bb:	83 c4 10             	add    $0x10,%esp
  1033be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1033c4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1033cb:	eb 5d                	jmp    10342a <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
  1033cd:	83 ec 08             	sub    $0x8,%esp
  1033d0:	ff 75 0c             	pushl  0xc(%ebp)
  1033d3:	6a 30                	push   $0x30
  1033d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1033d8:	ff d0                	call   *%eax
  1033da:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  1033dd:	83 ec 08             	sub    $0x8,%esp
  1033e0:	ff 75 0c             	pushl  0xc(%ebp)
  1033e3:	6a 78                	push   $0x78
  1033e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1033e8:	ff d0                	call   *%eax
  1033ea:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1033ed:	8b 45 14             	mov    0x14(%ebp),%eax
  1033f0:	8d 50 04             	lea    0x4(%eax),%edx
  1033f3:	89 55 14             	mov    %edx,0x14(%ebp)
  1033f6:	8b 00                	mov    (%eax),%eax
  1033f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  103402:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  103409:	eb 1f                	jmp    10342a <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10340b:	83 ec 08             	sub    $0x8,%esp
  10340e:	ff 75 e0             	pushl  -0x20(%ebp)
  103411:	8d 45 14             	lea    0x14(%ebp),%eax
  103414:	50                   	push   %eax
  103415:	e8 19 fc ff ff       	call   103033 <getuint>
  10341a:	83 c4 10             	add    $0x10,%esp
  10341d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103420:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  103423:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  10342a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  10342e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103431:	83 ec 04             	sub    $0x4,%esp
  103434:	52                   	push   %edx
  103435:	ff 75 e8             	pushl  -0x18(%ebp)
  103438:	50                   	push   %eax
  103439:	ff 75 f4             	pushl  -0xc(%ebp)
  10343c:	ff 75 f0             	pushl  -0x10(%ebp)
  10343f:	ff 75 0c             	pushl  0xc(%ebp)
  103442:	ff 75 08             	pushl  0x8(%ebp)
  103445:	e8 f8 fa ff ff       	call   102f42 <printnum>
  10344a:	83 c4 20             	add    $0x20,%esp
            break;
  10344d:	eb 39                	jmp    103488 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10344f:	83 ec 08             	sub    $0x8,%esp
  103452:	ff 75 0c             	pushl  0xc(%ebp)
  103455:	53                   	push   %ebx
  103456:	8b 45 08             	mov    0x8(%ebp),%eax
  103459:	ff d0                	call   *%eax
  10345b:	83 c4 10             	add    $0x10,%esp
            break;
  10345e:	eb 28                	jmp    103488 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  103460:	83 ec 08             	sub    $0x8,%esp
  103463:	ff 75 0c             	pushl  0xc(%ebp)
  103466:	6a 25                	push   $0x25
  103468:	8b 45 08             	mov    0x8(%ebp),%eax
  10346b:	ff d0                	call   *%eax
  10346d:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  103470:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103474:	eb 04                	jmp    10347a <vprintfmt+0x38d>
  103476:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10347a:	8b 45 10             	mov    0x10(%ebp),%eax
  10347d:	83 e8 01             	sub    $0x1,%eax
  103480:	0f b6 00             	movzbl (%eax),%eax
  103483:	3c 25                	cmp    $0x25,%al
  103485:	75 ef                	jne    103476 <vprintfmt+0x389>
                /* do nothing */;
            break;
  103487:	90                   	nop
    while (1) {
  103488:	e9 68 fc ff ff       	jmp    1030f5 <vprintfmt+0x8>
                return;
  10348d:	90                   	nop
        }
    }
}
  10348e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  103491:	5b                   	pop    %ebx
  103492:	5e                   	pop    %esi
  103493:	5d                   	pop    %ebp
  103494:	c3                   	ret    

00103495 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  103495:	55                   	push   %ebp
  103496:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103498:	8b 45 0c             	mov    0xc(%ebp),%eax
  10349b:	8b 40 08             	mov    0x8(%eax),%eax
  10349e:	8d 50 01             	lea    0x1(%eax),%edx
  1034a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034a4:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1034a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034aa:	8b 10                	mov    (%eax),%edx
  1034ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034af:	8b 40 04             	mov    0x4(%eax),%eax
  1034b2:	39 c2                	cmp    %eax,%edx
  1034b4:	73 12                	jae    1034c8 <sprintputch+0x33>
        *b->buf ++ = ch;
  1034b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034b9:	8b 00                	mov    (%eax),%eax
  1034bb:	8d 48 01             	lea    0x1(%eax),%ecx
  1034be:	8b 55 0c             	mov    0xc(%ebp),%edx
  1034c1:	89 0a                	mov    %ecx,(%edx)
  1034c3:	8b 55 08             	mov    0x8(%ebp),%edx
  1034c6:	88 10                	mov    %dl,(%eax)
    }
}
  1034c8:	90                   	nop
  1034c9:	5d                   	pop    %ebp
  1034ca:	c3                   	ret    

001034cb <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1034cb:	55                   	push   %ebp
  1034cc:	89 e5                	mov    %esp,%ebp
  1034ce:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1034d1:	8d 45 14             	lea    0x14(%ebp),%eax
  1034d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1034d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034da:	50                   	push   %eax
  1034db:	ff 75 10             	pushl  0x10(%ebp)
  1034de:	ff 75 0c             	pushl  0xc(%ebp)
  1034e1:	ff 75 08             	pushl  0x8(%ebp)
  1034e4:	e8 0b 00 00 00       	call   1034f4 <vsnprintf>
  1034e9:	83 c4 10             	add    $0x10,%esp
  1034ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1034ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1034f2:	c9                   	leave  
  1034f3:	c3                   	ret    

001034f4 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1034f4:	55                   	push   %ebp
  1034f5:	89 e5                	mov    %esp,%ebp
  1034f7:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1034fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1034fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103500:	8b 45 0c             	mov    0xc(%ebp),%eax
  103503:	8d 50 ff             	lea    -0x1(%eax),%edx
  103506:	8b 45 08             	mov    0x8(%ebp),%eax
  103509:	01 d0                	add    %edx,%eax
  10350b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10350e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  103515:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103519:	74 0a                	je     103525 <vsnprintf+0x31>
  10351b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10351e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103521:	39 c2                	cmp    %eax,%edx
  103523:	76 07                	jbe    10352c <vsnprintf+0x38>
        return -E_INVAL;
  103525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10352a:	eb 20                	jmp    10354c <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  10352c:	ff 75 14             	pushl  0x14(%ebp)
  10352f:	ff 75 10             	pushl  0x10(%ebp)
  103532:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103535:	50                   	push   %eax
  103536:	68 95 34 10 00       	push   $0x103495
  10353b:	e8 ad fb ff ff       	call   1030ed <vprintfmt>
  103540:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  103543:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103546:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103549:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10354c:	c9                   	leave  
  10354d:	c3                   	ret    
