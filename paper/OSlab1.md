# OSlab1--by：於一帆，林正青，吴昌昊

## 前置

在解压后的ucroe源码包中使用make命令即可以生成所需的目标文件,例如在本次实验中

```
user@system:~../lab1$ make
```

之后就会生成一系列的目标文件：

- user.img : 被qemu访问的虚拟硬盘文件
- kernel : ELF格式的toy ucore kernel执行文，嵌入到了ucore.img中
- bootblock : 虚拟的硬盘主引导扇区(512字节)，包含了bootloader执行代码，同样嵌入了
- sign : 外部执行程序，用来生成虚拟的硬盘主引导扇区

还有其他文件，不一一列举。

如果要对修改后的ucore代码和ucore 源码进行比较，可以使用diff命令。

![01.1.png](https://i.loli.net/2020/10/03/XrvLV18xysfHM3e.png)

## 练习1：理解通过make生成执行文件的过程

列出本实验各练习中对应的OS原理的知识点，并说明本实验中的实现部分如何对应和体现了原理中的基本概念和关键知识点

在此练习中，大家需要通过静态分析代码来了解：

1. 操作系统镜像文件ucore.img是如何一步一步生成的？(需要比较详细地解释Makefile中每一条相关命令和命令参数的含义，以及说明命令导致的结果)
2. 一个被系统认为是符合规范的硬盘主引导扇区的特征是什么。

###### 操作系统镜像文件ucore.img是如何一步一步生成的？

通过使用以下命令，可以得到Makefile中具体执行的所有命令，之后就可以对每一条命令进行分析。

```
$ make "V="
```

通过这个命令会弹出来一长串信息，这个我们先不看，还是先从makefile文件入手。打开makefile文件，一下子看到一堆代码也是挺烦人的，不过可以发现里面写了注释。既然有注释，就好办多了，我们知道通过这个命令可以生成一个ucore.img文件，那我们就从ucore.img倒推回去，阅读注释，可以看到以下代码。

![01.3.png](https://i.loli.net/2020/10/03/Wv6GrdoKfsNgXUi.png)

即使我们不懂makefile的语法规则，我们也很容易知道要生成这个ucore.img需要kernel和bootblock两个文件，那就再分别从这两个文件往上追溯。

我们先从bootblock来看，bootblock需要生成bootasm.o,bootmain.o以及sign等文件

![01.4.png](https://i.loli.net/2020/10/03/vYUrM3f8yLHeDTP.png)

其中bootasm.o由bootasm.S生成，bootmain.o由bootmain.c生成，生成代码为

```
gcc -Iboot/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootasm.S -o obj/boot/bootasm.o

gcc -Iboot/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootmain.c -o obj/boot/bootmain.o
```

解释一下其中出现的参数

```
-fno-builtin	# 不承认不以__builtin_开头的函数为内建函数
-fno-PIC	# 产生与位置无关代码，即没有绝对地址，使代码可以被任意加载
-Wall	# 在编译后显示所有警告
-ggdb	# 生成专门用于gdb的调试信息
-m32	# 生成32位机器的汇编代码
-gstabs	# 以stabs格式生成调试信息
-nostdinc	# 不在标准系统文件夹中寻找头文件，只在-I中指定的文件夹搜索头文件
-I	# 添加搜索头文件的路径并且会被优先查找	
-Os	# 优化代码，减小大小
-c	# 把程序做成obj文件，就是.o
-o	# 制定目标名称
-fno-stack-protector	# 不生成用于检测缓冲区溢出的代码
```

生成sign的代码如下，编写在makefile文件中

```makefile
# create 'sign' tools
$(call add_files_host,tools/sign.c,sign,sign)
$(call create_target_host,sign,sign)
```

对应的命令是，因为没有新的参数，就不进行详细解释。

```
gcc -Itools/ -g -Wall -O2 -c tools/sign.c -o obj/sign/tools/sign.o
gcc -g -Wall -O2 obj/sign/tools/sign.o -o bin/sign
```

整个的bootblock的生成过程如下

```
# 生成bootblock.o
# 新参数 -m:模拟为i386上的链接器，-N:设置代码段和数据段可读可写，-e:指定入口，-Ttext:设置代码开始位置
ld -m    elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o

# 将bootblock.o拷贝到bootblock.out
# 新参数 -S:移除所有符号和重定位信息，-O:指定输出格式
objcopy -S -O binary obj/bootblock.o obj/bootblock.out

# 使用sign处理bootblock.out生成bootblock
bin/sign obj/bootblock bin/bootblock
```

再看kernel的相关代码如下：

![01.5.png](https://i.loli.net/2020/10/03/n2aSNwoIEqie5jA.png)

注意到KSRCDIR这一部分的内容实际上是用给定目录的方式进行对.c文件的添加，在被执行的时候就会在这些目录中选择没使用过的.c文件来编译成.o文件。之后kernel对这些所有的.o文件进行一个链接。

生成完kernel和bootblock之后，就该生成ucore.img了。由上面的生成代码即

```
# 生成一个有10000块的ucore.img文件，每个块默认大小为512字节
dd if=/dev/zero of=bin/ucore.img count=10000
# 把bootblock添加到ucore.img的第一个块之中
dd if=bin/bootblock of=bin/ucore.img conv=notrunc
# 把kernel写到ucore.img的其它块中
dd if=bin/kernel of=bin/ucore.img seek=1 conv=notrunc
# 其中几个关键参数的意义
if:输入文件，不指定从stdin中读取
of:输出文件，不指定从stdout中读取
/dev/zero:不断返回的0值
count:块数
conv = notrunc:输出不截断
seek = num:从输出文件开头跳过num个块
```

这样我们就知道了整个ucore.img是如何从无到有的。

###### 一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？

主引导扇区就是我们的bootblock被加载到的区域，而和生成bootblock有关的代码就是sign.c。查看这个文件得到如下代码

```c
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>
int main(int argc, char *argv[]) {
    struct stat st;
    if (argc != 3) {
        fprintf(stderr, "Usage: <input filename> <output filename>\n");
        return -1;
    }
    if (stat(argv[1], &st) != 0) {
        fprintf(stderr, "Error opening file '%s': %s\n", argv[1], strerror(errno));
        return -1;
    }
    printf("'%s' size: %lld bytes\n", argv[1], (long long)st.st_size);
    if (st.st_size > 510) {
        fprintf(stderr, "%lld >> 510!!\n", (long long)st.st_size);
        return -1;
    }
    char buf[512];
    memset(buf, 0, sizeof(buf));
    FILE *ifp = fopen(argv[1], "rb");
    int size = fread(buf, 1, st.st_size, ifp);
    if (size != st.st_size) {
        fprintf(stderr, "read '%s' error, size is %d.\n", argv[1], size);
        return -1;
    }
    fclose(ifp);
    buf[510] = 0x55;
    buf[511] = 0xAA;
    FILE *ofp = fopen(argv[2], "wb+");
    size = fwrite(buf, 1, 512, ofp);
    if (size != 512) {
        fprintf(stderr, "write '%s' error, size is %d.\n", argv[2], size);
        return -1;
    }
    fclose(ofp);
    printf("build 512 bytes boot sector: '%s' success!\n", argv[2]);
    return 0;
}
```

通过分析上面这段代码，我们可以得到一个合格的主引导扇区应该符合如下两个规则：

- 输入字节在510字节内
- 最后两个字节是0x55AA

## 练习2：使用qemu执行并调试lab1中的软件(简要写出练习过程)

为了熟悉使用qemu和gdb进行的调试工作，我们进行如下的小练习：

1. 从CPU加电后执行的第一条命令开始，单步跟踪BIOS的执行
2. 在初始化位置0x7c00设置实地址断点，测试断点正常
3. 从0x7c00开始跟踪代码运行，将单步跟踪反汇编得到的代码与bootasm.S和bootblock.asm进行比较
4. 自己找一个booloader或内核中的代码位置，设置断点并进行测试。







## 练习3：分析bootloader进入保护模式的过程(写出分析)

BIOS将通过读取硬盘主引导扇区到内存，并跳转到对应内存中的执行位置执行bootloader。请分析bootloader是如何完成从实模式进入保护模式的。

既然题目中都给了提示要看bootasm.S的代码，那我们就先从这个源码入手，代码内容如下：

```asm
#include <asm.h>

# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

.set PROT_MODE_CSEG,        0x8                     # kernel code segment selector
.set PROT_MODE_DSEG,        0x10                    # kernel data segment selector
.set CR0_PE_ON,             0x1                     # protected mode enable flag

# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
.globl start
start:
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    cld                                             # String operations increment

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment

    #  Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1

    # Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    lgdt gdtdesc
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    ljmp $PROT_MODE_CSEG, $protcseg

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp
    call bootmain

    # If bootmain returns (it shouldn't), loop.
spin:
    jmp spin

# Bootstrap GDT
.p2align 2                                          # force 4 byte alignment
gdt:
    SEG_NULLASM                                     # null seg
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt
```

这段代码是bootmain执行之前bootloader所做的工作。不过在正式读代码之前，先读注释。从注释之中我们可以看到我们的代码分别完成了以下几个部分的功能：

```assembly
# 第一部分:屏蔽中断，设置串地址增长方向，设置一些重要的数据段寄存器(DS,ES,SS)
# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
.globl start
start:
.code16                                             # 使用16位模式编译
    cli                                             # 屏蔽中断
    cld                                             # 设置串地址增长方向

    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment
```

在第一部分中处于实模式下，可用的内存大小不多于1M，因此需要告诉编译器使用16位模式编译。cli是禁用中断。cld将DF位置零，从而决定内存地址是增大(对应的std是将DF置一，内存地址减小)。之后使用xorw异或指令让ax寄存器值变成0，再把ax的值赋给ds，es和ss寄存器。准备工作到此结束

```assembly
 # 第二部分:启动A20
seta20.1:
    inb $0x64, %al                                 
    testb $0x2, %al
    jnz seta20.1
    movb $0xd1, %al                                 
    outb %al, $0x64                                
seta20.2:
    inb $0x64, %al                                  
    testb $0x2, %al
    jnz seta20.2
    movb $0xdf, %al                                
    outb %al, $0x60                                 
```

首先要说一下A20是一个什么东西：

- 最早的8086结构中的内存空间很小，一开始8086的地址线有20位，也就是说具有0-1M的寻址范围，不过当时的寄存器只有16位，无法满足寻址需求，所以采用了另外一种寻址方式：一个16位寄存器表示基址*16+另外一个16位寄存器表示偏移地址，这样寻址空间就超过了1M。但到了后来，地址线增加到了32位，为了让以前的机器也能使用这种方式(即向下兼容)，就在A20(第20根地址线)上做了一个开关，当A20被使能时，是一根正常的地址线，但是当不被使能时永远为零。在保护模式下，要访问高端的内存必须要打开这个开关，否则第21位一定是0.
- 8086体系结构的地址空间实际上是被“挖洞”了的。最早的1M内存被分为了640KB的低端常规内存和384KB的留给ROM和系统设备的高端内存，然后这个不具有前瞻性的设计就导致在之后的内存容量增大非常麻烦:被划分成了0-640KB,1M-最大内存的两个部分。为了解决这个问题，采用了这样的解决办法:加电之后先让ROM有效，取出ROM之后再让RAM有效，把这部分内容保存到RAM这部分地址空间中。
- 实际上A20是由一个8042键盘控制器来控制的A20 Gate，8042芯片有三个端口，其中之一是Output Port，而A20Gate就是Output Port端口的 bit1，所以控制A20的方式就是通过读写端口数据，使bit1为1。

再讲讲这个8042芯片。

- 这个芯片有两个外部端口0x60h和0x64h，相当于读写操作的地址。
- 在读Output Port时，需要先向0x64h发送0d0h命令，然后从0x60h读取Output Port的内容；
- 在写Output Port时，需要先向0x64h发送0d1h命令，然后往0x60h写入Output Port的内容。
- 在读写的同时还需要检查缓冲区是否有数据，有的话就暂停等待。

有了上面的内容我们看这部分代码就比较简单了，每一步的作用写在注释中了。

```assembly
# 第二部分:启动A20
seta20.1:	
    inb $0x64, %al			#读取当前状态到al寄存器
    testb $0x2, %al			#检查当前状态寄存器的第二位是否为1(缓冲区是否为空)
    jnz seta20.1			#若缓冲区不为0，跳转到开始处
    movb $0xd1, %al         #将0xd1h写入al寄存器
    outb %al, $0x64         #向0x64h发送0xd1h命令，表示要写                      
seta20.2:
    inb $0x64, %al          #同1
    testb $0x2, %al			#同1
    jnz seta20.2			#同1
    movb $0xdf, %al         #将0xdfh写入al寄存器                       
    outb %al, $0x60         #向0x60h写入0x60，打开A20                 
```

之后就是第三部分，初始化GDT表，通过lgdt gdtdesc指令就可以实现。

接下来第四部分就是进入保护模式，进入保护模式的原理就是让cr0寄存器中的PE值为1

```assembly
 # 第四部分
 movl %cr0, %eax
 orl  $CR0_PE_ON, %eax
 movl %eax, %cr0
```

之后的第五部分通过一个长跳转来更新CS寄存器的基地址

```assembly
ljmp $PROT_MODE_CSEG, $protcseg
```

我们可以注意到代码段最前面定义了PROT_MODE_CSGE和PROT_MODE_DSEG，分别被定义为0x8h和0x10h，这两个分别是代码段和数据段的选择子。

第六部分是设置段寄存器并建立堆栈

```assembly
# 第六部分:初始化各个段寄存器并建立堆栈	
	movw $PROT_MODE_DSEG, %ax                       
	movw %ax, %ds                                   
	movw %ax, %es                                   
	movw %ax, %fs                                  
	movw %ax, %gs                                   
	movw %ax, %ss                                 

	movl $0x0, %ebp
	movl $start, %esp
# 第七部分:调用bootmain    
	call bootmain
spin:
	jmp spin
```

这个就是将各个段寄存器设置为0x10h，ebp指向0x0h，esp指向start也就是0x7c00处，最后使用call函数将返回地址入栈，控制权交给bootmain。

最后一个spin是如果当bootmain异常返回，在这里循环。

## 练习4：分析bootloader加载ELF格式的OS过程(写出分析)

通过阅读bootmain.c,了解bootloader如何加载ELF文件，通过分析源代码和通过qemu来运行并调试bootloader&OS

- bootloader是如何读取硬盘扇区？
- bootloader是如何加载ELF格式的OS？





## 练习5：实现函数调用堆栈跟踪函数(需要编程)

我们需要在lab1中完成kdebug.c中函数print_stackframe的实现，可以通过函数print_stackframe了跟踪函数调用堆栈中记录的返回地址。

在lab1/kern/debug目录下找到kdebug.c,打开以后发现源文件中已经有一个print_stackframe函数了(虽然里面啥也没有)，要做的就是往里面添加代码，让这个函数能实现我们需要的功能。以下是初始状态的代码。

```c
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
}
```

为了实现函数调用堆栈跟踪函数，需要先了解函数调用栈的原理。

函数调用时，自栈顶(低地址)到栈底(高地址)的情况如下图所示

![05.1.png](https://i.loli.net/2020/10/04/VJfMkbU4q6ClsKe.png)

esp和ebp两个指针是其中最关键的部分，只要掌握了ebp和esp的位置，就能很容易理解函数调用过程了。根据这个图，我们可以有这样几个信息

- ss[ebp]指向上一层的ebp
- ss[ebp-4]指向局部变量
- ss[ebp+4]指向返回地址
- ss[ebp+4+4n]指向第n个参数

之后我们就可以着手实现堆栈跟踪函数了。首先我们知道在bootasm.S中将esp设置为0x7c00，ebp设置为0，就调用了bootmain函数。call指令会依次执行以下命令:push返回地址，push这一层的ebp，然后把现在的esp赋值给ebp。在执行完call之后，这个ebp指向了0x7bf8(0x7c00-4-4)。

实现之前我们看一下源代码中的注释，突然惊讶的发现注释已经非常贴心的教你怎么写了，那就按着这个注释一步一步来，写出如下的结果：

```c
void
print_stackframe(void)
{
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
	uint32_t ebp = read_ebp(), eip = read_eip();
	for(int i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++){
		cprintf("ebp=: 0x%08x | eip=: 0x%08x | args=: ", ebp, eip);
		uint32_t *args = (uint32_t *)ebp + 2;
		for(int j = 0; j < 4; j++){
			cprintf("0x%08x ", args[j]);
		}
		cprintf("\n");
		print_debuginfo(eip - 1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
```

之后在lab1目录下执行命令 $ make qemu，得到如下的输出

```
......
Kernel executable memory footprint: 64KB
ebp=: 0x00007b28 | eip=: 0x00100a63 | args=: 0x00010094 0x00010094 0x00007b58 0x00100092 
    kern/debug/kdebug.c:307: print_stackframe+21
ebp=: 0x00007b38 | eip=: 0x00100d4d | args=: 0x00000000 0x00000000 0x00000000 0x00007ba8 
    kern/debug/kmonitor.c:125: mon_backtrace+10
ebp=: 0x00007b58 | eip=: 0x00100092 | args=: 0x00000000 0x00007b80 0xffff0000 0x00007b84 
    kern/init/init.c:48: grade_backtrace2+33
ebp=: 0x00007b78 | eip=: 0x001000bc | args=: 0x00000000 0xffff0000 0x00007ba4 0x00000029 
    kern/init/init.c:53: grade_backtrace1+38
ebp=: 0x00007b98 | eip=: 0x001000db | args=: 0x00000000 0x00100000 0xffff0000 0x0000001d 
    kern/init/init.c:58: grade_backtrace0+23
ebp=: 0x00007bb8 | eip=: 0x00100101 | args=: 0x001032dc 0x001032c0 0x0000130a 0x00000000 
    kern/init/init.c:63: grade_backtrace+34
ebp=: 0x00007be8 | eip=: 0x00100055 | args=: 0x00000000 0x00000000 0x00000000 0x00007c4f 
    kern/init/init.c:28: kern_init+84
ebp=: 0x00007bf8 | eip=: 0x00007d72 | args=: 0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8 
    <unknow>: -- 0x00007d71 --
......
```

最后一行中给出了ebp，eip和args三个参数，其具体意义为

- **ebp=: 0x00007bf8** 是kern_init函数的栈顶地址，因为在先前的部分中我们知道整个栈的栈顶是0x7c00，ss[ebp]指向上一层的ebp，ss[ebp+4]指向返回地址，7bf8 + 0008 = 7c00，这意味着bootmain函数没有输入参数，只占用了旧ebp和返回地址一共8个字节
- **eip=: 0x00007d72** 是kern_init函数的返回地址，也就是调用kern_init函数对应的指令的下一条指令的地址。
- **args=: 0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8** 通常状态下，args存放的四个dword是对应4个输入参数的值。但是这里其实没有传递输入参数。不过因为此时的栈顶位置恰好在bootloader第一条指令存放的地址的上面，args是kern_init的ebp寄存器的栈顶往上的第二到第五个四字节，也就是说args其实是bootloader指令的前十六个字节，下面这个例子就能很好的说明情况

```assembly
# bootloader前三条指令对应的机器码
7c00:	cli 			fa                   	
7c01:	cld 			fc   
7c02:	xor    %eax,%eax	31 c0
# 由于是小端字节序，所以存储为 c0 31 fc fa
```

## 练习6：完善中断初始化和处理(需要编程)

请完成编码工作和回答如下问题：

1. 中断描述符表(也可简称为保护模式下的中断向量表)中一个表项占多少字节？其中哪几位代表中断处理代码的入口？
2. 请编程完善/kern/trap/trap.c中对中断向量表进行初始化的函数idt_init。在idt_init函数中，依次对所有中断入口进行初始化。使用mmu.h中的SETGATE轰，填充idt数组内容。每个中断的入口由tools/vectors.c生成，使用trap.c中声明的vectors数组即可。
3. 请编程完善trap.c中的中断处理函数trap,在对时钟中断进行处理的部分填写trap函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks“。





## 扩展练习 Challenge1(需要编程)

> 扩展proj4,增加syscall功能，即增加一用户态函数（可执行一特定系统调用：获得时钟计数值），当内核初始完毕后，可从内核态返回到用户态的函数，而用户态的函数又通过系统调用得到内核态的服务（通过网络查询所需信息，可找老师咨询。如果完成，且有兴趣做代替考试的实验，可找老师商量）。需写出详细的设计和分析报告。完成出色的可获得适当加分。

首先为了完成特权级转换，需要了解这些知识：

- int iret在不同情况下的执行步骤
- 特权级检查

阅读实验指导书，kern/init/init.c和kern/trap/trap.c文件，不难发现这个challenge需要我们完成以下四个内容：

- kern/init/init.c    中的 switch_to_user
- kern/init/init.c    中的 switch_to_kernel
- kern/trap/trap.c 中的 case T_SWITCH_TOU #to user
- kern/trap/trap.c 中的 case T_SWITCH_TOK #to kernel

因为在调用关系中是 init.c调用trap.c，所以先从init.c中入手。

先来看switch_to_user。很好，什么也没有，满足我对于难度的要求。

```c
static void
lab1_switch_to_user(void) {
    //LAB1 CHALLENGE 1 : TODO
}
```

没有东西只能白手起家，还能咋地。先把写好的代码贴出来，之后再进行详细的解释

```c
//	init.c
static void
lab1_switch_to_user(void) {
    //LAB1 CHALLENGE 1 : TODO
    asm volatile(
		    "sub $0x8,%%esp \n"
		    "int %0 \n"
		    "movl %%ebp, %%esp \n"
		    :
		    :"i"(T_SWITCH_TOU)
		);
}
static void
lab1_switch_to_kernel(void) {
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile(
		    "int %0 \n"
		    "movl %%ebp, %%esp \n"
		    :
		    :"i"(T_SWITCH_TOK)
		);
}
```

```c
// trap.c
	case T_SWITCH_TOU:
        if(tf->tf_cs != USER_CS)	//检查是不是用户态，不是就操作
        {
                // 设置用户态对应的cs,ds,es,ss四个寄存器
            	tf->tf_cs = USER_CS;
                tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
                // 为用户态带来可以I/O的快乐
                tf->tf_eflags |= FL_IOPL_MASK;
        }
        break;

	case T_SWITCH_TOK:
        if(tf->tf_cs != KERNEL_CS)	//检查是不是内核态，不是就操作
        {
            	// 设置内核态对应的cs,ds,es三个寄存器
                tf->tf_cs = KERNEL_CS;
                tf->tf_ds = tf->tf_es = KERNEL_DS;
				// 剥夺用户态可以使用I/O的快乐
                tf->tf_eflags &= ~FL_IOPL_MASK;
        }
        break;
```

一开始我以为user_to_kernel和kernel_to_user应该没有什么区别，但这个challenge1不愧是个challenge。其中的区别在中断发生的压栈状况有关系。

中断可以发生在任何一个特权级别下，但是不同的特权级处理器使用的栈不同，如果涉及到特权级的变化，需要对SS和ESP寄存器进行压栈。性质如下：

- 当低特权级向高特权级切换的压栈(**用户态到内核态**)

  需要判断是否能访问这个目标段描述符，要做的就是将找到中断描述符时的CPL与目标段描述符的DPL进行比较。当CPL特权级比DPL低(CPL>DPL)时，要往高特权级栈转移，也就是说要恢复旧栈，因此处理器临时保存旧栈的SS和ESP，然后加载新的特权级和DPL相同的段到SS和ESP中，把旧栈的SS和ESP压入新栈

- 当无特权级转化时的压栈(**内核态到用户态**)

  理论上来说从内核态到用户态也需要对栈进行切换，不过在lab1中并没有完整实现对物理内存的管理，而GDT中的每一个段除了对特权级的要求以外都一样，所以只需要修改一下权限就可以实现了。这也导致这个时候不会压栈，我们需要手动压栈(体现在lab1_switch_to_user中的sub $0x8,%%esp)。

不过在trap.c中的实现比较雷同，把对应的tf指针修改为对应态的内容就行。

###### 遇到的一些麻烦和问题

1. **关于int和iretz**

   这俩东西可以说是中断的灵魂，如果搞不懂这个真的没法做实验。用这两个中断过程来举例

   1. 中断触发后，处理器根据中断向量号找到对应的中断描述符，然后拿**中断发生时的CPL**和**中断描述符**中的**段选择子**对应的**DPL**做对比，如果发现CPL权限比DPL低(CPL数值更大)时，将旧栈压入新栈，具体表现就是将ss_old和esp_old压入ss_new和esp_new中。用户态到内核态的栈切换由TSS和硬件实现

   2. **在用户态到内核态的切换过程中**，依次压入(高地址)ss,esp,eflags,cs,eip,errorno(低地址)等参数；**在内核态到用户态的切换过程中**，依次压入(高地址)eflags,cs,eip,errorno(低地址)等参数

   3. **在用户态到内核态的切换过程中**，不用给空间，直接用int %0触发中断。这个int %0对应的是我们的输入(T_SWITCH_TOK)，调用前后函数后我们的栈帧如下

      > //调用前
      >
      > (高地址)user_ss,野指针,eflags,user_cs,eip,errorno,trapno,user_ds,user_es(低地址)
      >
      > // 调用后
      >
      > (高地址)user_ss,野指针,eflags,kernel_cs,eip,errorno,trapno,kernel_ds,kernel_es(低地址)

      **在内核态到用户态的切换过程中**，先通过sub $0x8,%%esp给8B的空间，之后同样用int %0触发中断，此时对应的就是(T_SWITCH_TOU)，调用前后的栈帧如下

      > //调用前
      >
      > (高地址)野指针,野指针,eflags,kernel_cs,eip,errorno,trapno,kernel_ds,kernel_es(低地址)
      >
      > // 调用后
      >
      > (高地址)user_ss,野指针,eflags,user_cs,eip,errorno,trapno,user_ds,user_es(低地址)

   4. 执行完中断程序之后，通过**iret**返回，依次弹出对应段选择子从而实现对栈的切换。在弹出eip和cs之后，根据cs中的RPL判断是否需要继续弹出。**也就是说，如果要返回到特权级更低的代码，就要弹出ss和esp**。

      **在用户态到内核态的切换过程中**，栈中的CS是kernel_cs，DPL=0，当前的CPL=3，代码不会返回到更低的特权级，所以不弹出esp和ss。**但是栈所在的段已经发生了变化**，也就是SS已经发生了变化：在用户态下中断会导致user_ss和user_esp被压入新的内核栈，所以最开始的ss就是kernel_ss。这也是为什么在TOK中不用设置tf_ss。

      **在内核态到用户态的切换过程中**，栈中的CS是user_cs，DPL=3，当前的CPL=0，代码会返回到更低的特权级，所以会弹出esp和ss，这个时候野指针被pop到esp，user_ss被弹出到ss，实现了栈段的切换，内核切换到了用户栈。

   5. 还有最后一句话movl %%ebp, %%esp。同样在两种情况下看

      **在用户态到内核态的切换过程中**，要回收user_ss,user_esp，所以通过这句话让esp指向ebp，并且顶掉原来储存在这个位置的user_esp，而4中我们知道了这个时候的user_ss实际上是kernel_ss，所以不用管他。

      **在内核态到用户态的切换过程中**，此时的esp是野指针，是一个内存的初始值，我们需要让他指向ebp。那怎么给ebp呢？很巧妙，在sub $0x8,%%esp这句话执行之后，栈帧状态是这样的

      > (高地址)野指针，野指针(低地址)

      但其实原来的ebp刚好就在上面，实际上是这样

      > (高地址)原ebp，(ebp指向)，野指针，野指针(低地址)

      所以这句话就能帮助我们让esp的野指针指向ebp
   
2. **在用户态和内核态的切换时，虽然eip没变，但是段在变，为什么还能正常运行?**

   一开始没想明白，后面脑子突然上线：哦，**我们现在是保护模式**

   所以我们的CS不再是直接的代码段，而是段选择子，并不是一个实际的物理段地址而是一个索引，通过这个索引去查这个段具体的物理地址。 

   具体的格式如下

   > 格式为：【索引(13)|TI(1)|RPL(2)】 
   >
   > 索引：GDT表中有8K个表项(2^13=8k) 
   >
   > TI：    0-GDT 1-LDT 
   >
   > RPL：00-kernel，11-user 
   >
   > 内核态下的8  = 【00...01|0|00】
   >
   > 用户态下的1b = 【00...11|0|11】

   这里面影响地址的只有索引，他俩的索引一个是1，3。索引和GDT表有关，那么我们看看GDT表的相关内容

   ```c
   // kern/mm/pmm.c
   static struct segdesc gdt[] = {
       SEG_NULL,
       [SEG_KTEXT] = SEG(STA_X | STA_R, 0x0, 0xFFFFFFFF, DPL_KERNEL),
       [SEG_KDATA] = SEG(STA_W, 0x0, 0xFFFFFFFF, DPL_KERNEL),
       [SEG_UTEXT] = SEG(STA_X | STA_R, 0x0, 0xFFFFFFFF, DPL_USER),
       [SEG_UDATA] = SEG(STA_W, 0x0, 0xFFFFFFFF, DPL_USER),
       [SEG_TSS]   = SEG_NULL,
   };
   ```

   1对应的是[SEG_KTEXT]，内核段，ok，3对应的是[SEG_UTEXT]，用户段，也ok。这里出现的新东西是 segdesc 和 SEG，再去看看这俩到底是个啥

   ```c
   // kern/mm/mmu.h
   struct segdesc {
       unsigned sd_lim_15_0 : 16;        // low bits of segment limit
       unsigned sd_base_15_0 : 16;        // low bits of segment base address
       unsigned sd_base_23_16 : 8;        // middle bits of segment base address
       unsigned sd_type : 4;            // segment type (see STS_ constants)
       unsigned sd_s : 1;                // 0 = system, 1 = application
       unsigned sd_dpl : 2;            // descriptor Privilege Level
       unsigned sd_p : 1;                // present
       unsigned sd_lim_19_16 : 4;        // high bits of segment limit
       unsigned sd_avl : 1;            // unused (available for software use)
       unsigned sd_rsv1 : 1;            // reserved
       unsigned sd_db : 1;                // 0 = 16-bit segment, 1 = 32-bit segment
       unsigned sd_g : 1;                // granularity: limit scaled by 4K when set
       unsigned sd_base_31_24 : 8;        // high bits of segment base address
   };
   
   #define SEG(type, base, lim, dpl)                        \
       (struct segdesc){                                    \
           ((lim) >> 12) & 0xffff, (base) & 0xffff,        \
           ((base) >> 16) & 0xff, type, 1, dpl, 1,            \
           (unsigned)(lim) >> 28, 0, 0, 1, 1,                \
           (unsigned) (base) >> 24                            \
       }
   ```

   我们看到SEG括号内的第二个参数base，都是0x0，破案了，**他们虽然表面上选择子一直在换，但是他们所指向的实际物理段基址并没有变，是一样的**。

## 扩展练习 Challenge2(需要编程)

> 用键盘实现用户模式内核模式切换。具体目标是：“键盘输入3时切换到用户模式，键盘输入0时切换到内核模式”。 基本思路是借鉴软中断(syscall功能)的代码，并且把trap.c中软中断处理的设置语句拿过来。
