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



## 练习4：分析bootloader加载ELF格式的OS过程(写出分析)

通过阅读bootmain.c,了解bootloader如何加载ELF文件，通过分析源代码和通过qemu来运行并调试bootloader&OS

- bootloader是如何读取硬盘扇区？
- bootloader是如何加载ELF格式的OS？





## 练习5：实现函数调用堆栈跟踪函数(需要编程)

我们需要在lab1中完成kdebug.c中函数print_stackframe的实现，可以通过函数print_stackframe了跟踪函数调用堆栈中记录的返回地址。





## 练习6：完善中断初始化和处理(需要编程)

请完成编码工作和回答如下问题：

1. 中断描述符表(也可简称为保护模式下的中断向量表)中一个表项占多少字节？其中哪几位代表中断处理代码的入口？
2. 请编程完善/kern/trap/trap.c中对中断向量表进行初始化的函数idt_init。在idt_init函数中，依次对所有中断入口进行初始化。使用mmu.h中的SETGATE轰，填充idt数组内容。每个中断的入口由tools/vectors.c生成，使用trap.c中声明的vectors数组即可。
3. 请编程完善trap.c中的中断处理函数trap,在对时钟中断进行处理的部分填写trap函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks“。