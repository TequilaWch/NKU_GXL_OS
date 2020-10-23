# os lab1
> 成员1：1811349 董佳霖（主要负责2，3）
> 
> 成员2：1811412 戚晓睿（主要负责1，4）
>
> 成员3：1811425 孙一丁（主要负责5，6）
>
> 日期：2020.10.07
>
> Github: https://github.com/NickSkyyy/ucore_os/tree/lab1
>
> 备注：完成全部6个基本练习和2个附加练习，一起写的challenge

## 1 Exercise 1

+ 执行make，产生目录bin和obj
+ 目标文件：依赖文件
+ 命令以tab作为开头，$(x)代表变量x
+ call函数调用，$(i)代表函数传递的第i个参数
+ $^：所有依赖文件
+ $@：目标
+ $<：第一个依赖文件

### 1.1 ucore.img

1. 产生代码位于Makefile Line178-186，UCOREIMG目标文件有kernel和两个依赖文件。

`call addprefix`, 前缀, 文件列表（SLASH表示正斜杠）

`@dd`：用指定大小的块拷贝一个文件，并进行指定的转换

> `if=name`，input file 文件名
>
> `of=name`，output file 文件名
>
> `count=num`，仅拷贝num个数的块
>
> `seek=num`，从输出文件开头跳过num个数的块后再开始复制
>
> `conv=conversion`，用指定的参数进行文件转换
>
> `notrunc`，不截短输出文件
>
> 详细内容：<https://baike.baidu.com/item/dd命令>

2. 产生bootblock代码位于Line156-168，配置和产生kernel代码位于Line122-151. 

> 依赖文件中`|`的解释：<https://blog.csdn.net/sdu611zhen/article/details/53011253>

bootblock有个三个依赖文件，分别是sign、bootasm.o和bootmain.o. 对应gcc代码如下：

```
$ gcc -Iboot/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootasm.S -o obj/boot/bootasm.o
```

> `march`，指定进行优化的型号，此处是i686
>
> `fno-builtin`， 不使用c语言的内建函数（函数重名时使用）
>
> `fno-PIC`， 不生成与位置无关的代码(position independent code)
>
> `Wall`，编译后显示所有警告
>
> `ggdb`， 为GDB生成更为丰富的调试信息
>
> `gstabs`， 以stabs格式生成调试信息，但不包括上一条的GDB调试信息
>
> `nostdinc`，查找头文件时，不在标准系统目录下查找

```
$ ld -m elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootblock.o -o obj/bootblock.o
```

`@ld`：GNU的链接器，将目标文件链接为可执行文件

> `m`，类march操作，模拟i386的链接器
>
> `nostdlib`，不使用标准库
> 
> `N`，设置全读写权限
>
> `e`，指定程序的入口符号
>
> `Ttext`，指定代码段的开始位置

3. kernel的依赖文件是一个集合KOBJS，而文件具体内容由KSRCDIR指定。内容基本同上。

+ 第一个块记录了bootblock，第二个块记录了kernel

#### 1.2 主引导扇区

从工具文件sign.c寻找对应的要求，以ucore.img为例。扇区总大小为512字节，obj/bootblock.out占据496字节，不得超过510字节。其中，510字节为0x55，511字节为0xAA.

## 2 Exercise 2&3
详情见另一Markdown文件：labcodes/lab1/exe23实验过程记录.md

## 3 Exercise 4
结合exer1的Makefile流程具体解释取文件内容。
### 3.1 硬盘扇区
逻辑区块地址(Logic Block Address,LBA)，

sect函数细节：
+ 0x1F2 指定读取扇区数量，最小为1
+ 0x1F6处，第5位第7位一定为1，第6位指定模式，1为LBA，0为CHS；因此设置为0xE0
+ 0x20位数据读取命令
> https://www.yiibai.com/unix_system_calls/insl.html#

除4是用的字单位，1字=4字节

### 3.2 ELF格式OS
elf.h文件很详细

seg函数细节：
+ va的减值在于此处可能会读取超过需求量，对offset内超过整数个SECTSIZE的内容进行边界的下调。如，考虑到program segment的bss存在等。（类似汇编的align对齐）
+ 由于kernel内容从1开始（0是bootblock），secno要进行+1

整体流程：
+ 从HEADER的0处读取1页（8扇区）的内容，检查ELF文件合法性
+ 从program header位置读取所有的program segment
+ 进入HEADER指定的entry

## 4 Exercise 5
- 基本就是按照需要填写代码部分给出的逻辑提示进行编写。
#### 填写后的代码块如下

```C
void print_stackframe(void) {
     /* LAB1 YOUR CODE : STEP 1 */
     /* (1) call read_ebp() to get the value of ebp. the type is (uint32_t);
      * (2) call read_eip() to get the value of eip. the type is (uint32_t);
      * (3) from 0 .. STACKFRAME_DEPTH
      *    (3.1) printf value of ebp, eip
      *    (3.2) (uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]
      *    (3.3) cprintf("\n");
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp(); //(1)
    uint32_t eip = read_eip(); //(2)
    for(int i=0;i<STACKFRAME_DEPTH && ebp!=0;i++){
    	cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip); //(3.1) 
    	uint32_t *calling_arguments = (uint32_t *) ebp; 
    	for(int j=0;j<4;j++){
    		cprintf(" 0x%08x ", calling_arguments[j]); //(3.2)
		}
		cprintf("\n"); //(3.3)
		print_debuginfo(eip-1); //(3.4)
    	eip = ((uint32_t *)ebp)[1]; 
    	ebp = ((uint32_t *)ebp)[0]; //(3.5)
	}
}
```

- 这个exer想干什么？单纯的想实现栈帧信息打印。

- 什么原理？ebp可以想象成是一个线性链表。ebp指向上层函数的基地址，跳跳跳跳到最后。

- ebp和eip可以通过某个内联函数直接获取当前的ebp和eip。假设我们递归调用了一个函数，我们怎么从内层回溯到外层函数信息？利用函数调用时最后push进去的返回地址（ebp）。

- 怎么利用？见下图。ss:[ebp+4]为返回地址，ss:[ebp+8]为传入的第一个参数（具体是什么意思？不知道，没有给出解释。参数为什么读4个？不知道，提示要求的。）

- 参数到哪里？从地址ebp+8开始到ss:[ebp+4]读出的值（返回地址）

  ![image-20201015154006190](C:\Users\78479\AppData\Roaming\Typora\typora-user-images\image-20201015154006190.png)

一些可能不熟悉的点：

1. %08x表示把输出的整数按照8位16进制格式（不包括‘0x’）输出，不足8位的部分用0填充。

一些踩了的坑：

1. 一开始使用的printf而不是printf，发现报错了，说没引入stdio.h，但其实引了，不知道为啥。

2. 一开始循环判断没写ebp!=0，导致都到栈底了，还在打印，如下图。

   ![image-20201015154653589](C:\Users\78479\AppData\Roaming\Typora\typora-user-images\image-20201015154653589.png)

   正常的应该是下图。

   ![image-20201015154753217](C:\Users\78479\AppData\Roaming\Typora\typora-user-images\image-20201015154753217.png)

   

```asm
rexxar@rexxar-virtual-machine:~/ucore_os/labcodes/lab1$ make qemu
+ cc kern/debug/kdebug.c
+ ld bin/kernel
记录了10000+0 的读入
记录了10000+0 的写出
5120000 bytes (5.1 MB, 4.9 MiB) copied, 0.092992 s, 55.1 MB/s
记录了1+0 的读入
记录了1+0 的写出
512 bytes copied, 0.000121417 s, 4.2 MB/s
记录了154+1 的读入
记录了154+1 的写出
78912 bytes (79 kB, 77 KiB) copied, 0.000961922 s, 82.0 MB/s
WARNING: Image format was not specified for 'bin/ucore.img' and probing guessed raw.
         Automatically detecting the format is dangerous for raw images, write operations on block 0 will be restricted.
         Specify the 'raw' format explicitly to remove the restrictions.
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0x00100000 (phys)
  etext  0x0010341d (phys)
  edata  0x0010fa16 (phys)
  end    0x00110d20 (phys)
Kernel executable memory footprint: 68KB
ebp:0x00007b28 eip:0x00100ab3 args: 0x00010094  0x00010094  0x00007b58  0x00100096 
    kern/debug/kdebug.c:306: print_stackframe+25
ebp:0x00007b38 eip:0x00100db5 args: 0x00000000  0x00000000  0x00000000  0x00007ba8 
    kern/debug/kmonitor.c:125: mon_backtrace+14
ebp:0x00007b58 eip:0x00100096 args: 0x00000000  0x00007b80  0xffff0000  0x00007b84 
    kern/init/init.c:48: grade_backtrace2+37
ebp:0x00007b78 eip:0x001000c4 args: 0x00000000  0xffff0000  0x00007ba4  0x00000029 
    kern/init/init.c:53: grade_backtrace1+42
ebp:0x00007b98 eip:0x001000e7 args: 0x00000000  0x00100000  0xffff0000  0x0000001d 
    kern/init/init.c:58: grade_backtrace0+27
ebp:0x00007bb8 eip:0x00100111 args: 0x0010343c  0x00103420  0x0000130a  0x00000000 
    kern/init/init.c:63: grade_backtrace+38
ebp:0x00007be8 eip:0x00100055 args: 0x00000000  0x00000000  0x00000000  0x00007c4f 
    kern/init/init.c:28: kern_init+84
ebp:0x00007bf8 eip:0x00007d74 args: 0xc031fcfa  0xc08ed88e  0x64e4d08e  0xfa7502a8 
    <unknow>: -- 0x00007d73 --
++ setup timer interrupts

```
## 5 Exercise 6

> 2. 请编程完善kern/trap/trap.c中对中断向量表进行初始化的函数idt_init。在idt_init函数中， 依次对所有中断入口进行初始化。使用mmu.h中的SETGATE宏，填充idt数组内容。每个 中断的入口由tools/vectors.c生成，使用trap.c中声明的vectors数组即可。

首先，SETGATE，

第二个参数（读代码kern\mm\mmu.h。参数含义：是否为trap descriptor？我们是不涉及到特权切换，特权切换的部分会在challenge里实现，这里的都是interrupt-gate descriptor，肯定不是，填false）；

第三个参数（读代码kern\mm\mmu.h。参数含义：代码段选择子。根据实验指导书，代码段选择子需要包括索引[15:3]、标指示位[2]、请求特权级[1:0]。观察一下memlayout.h里面的定义，我们应该选择KERNEL_CS。KERNEL_CS中包含了索引和权限，因为#define KERNEL_CS    ((GD_KTEXT) | DPL_KERNEL)）

第四个参数（读代码kern\mm\mmu.h。参数含义：偏移量，不说了）

第五个参数（读代码kern\mm\mmu.h。参数含义：权限等级描述，见memlayout.h宏定义，只有两种，核心权限DPL_KERNEL，用户权限DPL_USER，选DPL_KERNEL核心权限）

然后，根据提示以及学堂在线讲解，要调用lidt(&idt_pd)告诉系统，我定义好中断向量表了！

代码如下。

```c
void idt_init(void) {
     /* LAB1 YOUR CODE : STEP 2 */
     /* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
      *     All ISR's entry addrs are stored in __vectors. where is uintptr_t __vectors[] ?
      *     __vectors[] is in kern/trap/vector.S which is produced by tools/vector.c
      *     (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
      *     You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later.
      * (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for (int i = 0; i < 256; i++) {
        SETGATE(idt[i], 0, KERNEL_CS, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
```

> 3. 请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写trap函数中 处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向 屏幕上打印一行文字”100 ticks”。

根据提示编写就可以了！

Too Simple? Yes, I think so!

```c
// code in kern/trap/trap.c/function:trap_dispatch
		case IRQ_OFFSET + IRQ_TIMER:
        /* LAB1 YOUR CODE : STEP 3 */
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks += 1;
        if (!(ticks % TICK_NUM)) {
            print_ticks();
        }
        break;
```

坑1：c语言里false不是关键字？学习了。改成0就成。

![image-20201015205554856](C:\Users\78479\AppData\Roaming\Typora\typora-user-images\image-20201015205554856.png)

成功截图：每100个tick就输出一下100ticks。可是我的输出频率明显比学堂在线的讲解视频快，可能是主频频率比较高（？）。然后输出的时候也可以捕获外设（键盘）的输入。也行。反正这部分也不是我自己写的。肯定能跑。

![image-20201015205220958](C:\Users\78479\AppData\Roaming\Typora\typora-user-images\image-20201015205220958.png)

## 6 Challenges
坑1：Syntax error:")" unexpected ...

![image-20201019221102201](C:\Users\78479\AppData\Roaming\Typora\typora-user-images\image-20201019221102201.png)

原因是因为我是从windows下git clone然后再扔进ubuntu下的，导致了一些编码的问题。

执行博客的如下操作：

![image-20201019221223492](C:\Users\78479\AppData\Roaming\Typora\typora-user-images\image-20201019221223492.png)

> 【1】ronmy，centos 行 2: $'\r': 未找到命令 在window 上编写的 sh
> ，CSDN，2017，(https://blog.csdn.net/ronmy/article/details/68923419)

成功解决，而且能跑出grade了。但是，再重启电脑之后。（同时还执行了上述代码之外的其他，但我忘了）

![这里写图片描述](https://img-blog.csdn.net/20170818132338136?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbWxzODA1Mzc5OTcz/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

无限memtest86，也找不到ubuntu内核了。无奈重装。淦。

相比之下，2更好设计。在KBD中断内设置对字符的检查，实现0-ring3，3-ring0的转换，并设置有当前权限的检测。

TOU/TOK两段代码实现汇编语言的软中断，三个冒号，1是输出，2是输入，3是不重要的东西。

+ 开头的sub的解释，“多popl”？
+ es和ss段加载在*_DS的解释？

eflag在最初的时候并没有进行更新和设置，共有四个状态标志位。从高到低分别是：IOPL（特权标志），NT（嵌套任务标志），RF（重启动标志），VM（Virtual 8086 Mode if set 1）