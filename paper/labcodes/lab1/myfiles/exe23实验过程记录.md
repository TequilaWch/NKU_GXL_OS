## 实验步骤及结果
### ~/lab1  指令： make

    \+ cc kern/init/init.c
    kern/init/init.c:95:1: warning: ‘lab1_switch_test’ defined but not used [-Wunused-function]  
    lab1_switch_test(void) {
    ^
    \+ cc kern/libs/stdio.c
    \+ cc kern/libs/readline.c
    \+ cc kern/debug/panic.c
    kern/debug/panic.c: In function ‘__panic’:
    kern/debug/panic.c:27:5: warning: implicit declaration of function 
    ‘print_stackframe’ [-Wimplicit-function-declaration]
        print_stackframe();
        ^
    \+ cc kern/debug/kdebug.c
    kern/debug/kdebug.c:251:1: warning: ‘read_eip’ defined but not used [-Wunused-function]
    read_eip(void) {
    ^
    \+ cc kern/debug/kmonitor.c
    \+ cc kern/driver/clock.c
    \+ cc kern/driver/console.c
    \+ cc kern/driver/picirq.c
    \+ cc kern/driver/intr.c
    \+ cc kern/trap/trap.c
    kern/trap/trap.c:14:13: warning: ‘print_ticks’ defined but not used [-Wunused-function]
    static void print_ticks() {
                ^
    kern/trap/trap.c:30:26: warning: ‘idt_pd’ defined but not used [-Wunused-variable]
    static struct pseudodesc idt_pd = {
                            ^
    \+ cc kern/trap/vectors.S
    \+ cc kern/trap/trapentry.S
    \+ cc kern/mm/pmm.c
    \+ cc libs/string.c
    \+ cc libs/printfmt.c
    \+ ld bin/kernel
    \+ cc boot/bootasm.S
    \+ cc boot/bootmain.c
    \+ cc tools/sign.c
    \+ ld bin/bootblock
    'obj/bootblock.out' size: 484 bytes
    build 512 bytes boot sector: 'bin/bootblock' success!
    10000+0 records in
    10000+0 records out
    5120000 bytes (5.1 MB, 4.9 MiB) copied, 0.21819 s, 23.5 MB/s
    1+0 records in
    1+0 records out
    512 bytes copied, 0.000121855 s, 4.2 MB/s
    146+1 records in
    146+1 records out
    74828 bytes (75 kB, 73 KiB) copied, 0.00337746 s, 22.2 MB/s

### make "v=" 没有尝试


### 进入gdb界面后（完全记录）

    warning: A handler for the OS ABI "GNU/Linux" is not built into this configurati
    on
    of GDB.  Attempting to continue with the default i8086 settings.

    The target architecture is assumed to be i8086
    0x0000fff0 in ?? ()
    (gdb) x /2i 0xffff0
    0xffff0:     ljmp   $0xf000,$0xe05b
    0xffff5:     xor    %dh,0x322f
     (gdb) x /10i 0xfe05b
    0xfe05b:     cmpl   $0x0,%cs:0x6c48
    0xfe062:     jne    0xfd2e1
    0xfe066:     xor    %dx,%dx
    0xfe068:     mov    %dx,%ss
    0xfe06a:     mov    $0x7000,%esp
    0xfe070:     mov    $0xf3691,%edx
    0xfe076:     jmp    0xfd165
    ---Type <return> to continue, or q <return> to quit---return
    0xfe079:     push   %ebp
    0xfe07b:     push   %edi
    0xfe07d:     push   %esi
    (gdb) si
    0x0000e062 in ?? ()
    (gdb) si
    0x0000e066 in ?? ()
    (gdb) si
    0x0000e068 in ?? ()
    (gdb) x /10i 0xfe068
    0xfe068:     mov    %dx,%ss
    0xfe06a:     mov    $0x7000,%esp
    0xfe070:     mov    $0xf3691,%edx
    0xfe076:     jmp    0xfd165
    0xfe079:     push   %ebp
    0xfe07b:     push   %edi
    0xfe07d:     push   %esi
    0xfe07f:     push   %ebx
    0xfe081:     sub    $0x20,%esp
    0xfe085:     mov    %eax,%ebx

## 这里错误
    这是错误的! 试试下面那个
    (gdb) b 0xf7c00
    No symbol table is loaded.  Use the "file" command.
    Make breakpoint pending on future shared library load? (y or [n]) y
    Breakpoint 1 (0xf7c00) pending.
    (gdb) x /10i 0xf7c00
    0xf7c00:     mov    %edx,0x10(%esp)
    0xf7c06:     mov    %cl,0x16(%esp)
    0xf7c0b:     movzbl 0x1c(%eax),%eax
    0xf7c11:     mov    0x19(%ebx),%cl
    0xf7c15:     mov    %cl,0x3(%esp)
    0xf7c1a:     mov    0x18(%ebx),%cl
    0xf7c1e:     mov    %cl,%dl
    0xf7c20:     and    $0x3f,%edx
    0xf7c24:     mov    %dl,0x1(%esp)
    0xf7c29:     mov    0x15(%ebx),%dl

## 这里错误

错误点：前面要加\*而且地址是07c00而不是f7c00,。

    (gdb) b *0x07c00
    Breakpoint 1 at 0x7c00
    (gdb) continue
    Continuing.
    Breakpoint 1, 0x00007c00 in ?? ()



### 正确的从7c00开始调试：

    Breakpoint 1, 0x00007c00 in ?? ()
    (gdb) x /10i 0x07c00
    => 0x7c00:      cli
    0x7c01:      cld
    0x7c02:      xor    %ax,%ax
    0x7c04:      mov    %ax,%ds
    0x7c06:      mov    %ax,%es
    0x7c08:      mov    %ax,%ss
    0x7c0a:      in     $0x64,%al
    0x7c0c:      test   $0x2,%al
    0x7c0e:      jne    0x7c0a
    0x7c10:      mov    $0xd1,%al
    0x00007c10 in ?? ()
    (gdb) x /10i 0x7c10
    => 0x7c10:      mov    $0xd1,%al
    0x7c12:      out    %al,$0x64
    0x7c14:      in     $0x64,%al
    0x7c16:      test   $0x2,%al
    0x7c18:      jne    0x7c14
    0x7c1a:      mov    $0xdf,%al
    0x7c1c:      out    %al,$0x60
    0x7c1e:      lgdtw  0x7c6c
    0x7c23:      mov    %cr0,%eax
    0x7c26:      or     $0x1,%eax
    (gdb) x /10i 0x07c26
    => 0x7c26:      or     $0x1,%eax
    0x7c2a:      mov    %eax,%cr0
    0x7c2d:      ljmp   $0x8,$0x7c32
    0x7c32:      mov    $0xd88e0010,%eax
    0x7c38:      mov    %ax,%es
    0x7c3a:      mov    %ax,%fs
    0x7c3c:      mov    %ax,%gs
    0x7c3e:      mov    %ax,%ss
    0x7c40:      mov    $0x0,%bp
    0x7c43:      add    %al,(%bx,%si)
    (gdb) x /10i 0x07c45
    => 0x7c45:      mov    $0x7c00,%sp
    0x7c48:      add    %al,(%bx,%si)
    0x7c4a:      call   0x7d07
    0x7c4d:      add    %al,(%bx,%si)
    0x7c4f:      jmp    0x7c4f
    0x7c51:      lea    0x0(%bp),%si
    0x7c54:      add    %al,(%bx,%si)
    0x7c56:      add    %al,(%bx,%si)
    0x7c58:      add    %al,(%bx,%si)
    0x7c5a:      add    %al,(%bx,%si)
    ......
    (gdb) 

## 下面分析boot是如何做好设置并跳转到0x7C00并转移控制权

### bootasm.S分段分析
 
把这段代码从磁盘第一山区加载进bios内存区域(物理地址 0x7c00), 在实模式下启动.此时(%cs=0 %ip=7c00.)

## 我们可以大体看到前面部分的代码是16位

    .globl start
    start:
    .code16                # Assemble for 16-bit mode
        cli                # Clear Interupt, 屏蔽中断
        cld                # String operations increment 修改串操作指令的方向

        # 设置 (DS, ES, SS).
        xorw %ax, %ax             # ax=0
        movw %ax, %ds             # -> Data Segment
        movw %ax, %es             # -> Extra Segment
        movw %ax, %ss             # -> Stack Segment   

1. 代码段寄存器CS：存放当前正在运行的程序代码所在段的段基值。

2. 数据段寄存器DS：存放数据段的段基值。

3. ES 附加段寄存器。(使用时与数据段寄存器基本相同）

4. 堆栈段寄存器SS：存放堆栈段的段基值。

## 使能A20 (依然是实模式下进行)

 # Enable A20:
 为了兼容性必须实现地址回卷. 80386的segment:offset的地址表示,当寻址到超过1MB的内存时，会发生“回卷”（不会发生异常）。

 为了保持完全的向下兼容性，IBM决定在PC AT计算机系统上加个硬件逻辑，来模仿以上的回绕特征，于是出现了A20 Gate。他们的方法就是把A20地址线控制和键盘控制器的一个输出进行AND操作，
 * 这样来控制A20地址线的打开（使能）和关闭（屏蔽\禁止）
 
    
       seta20.1:
       inb $0x64, %al          
       
        #Wait for not busy(8042 input buffer empty). inb 
        #从I/O端口读取一个字节(BYTE, HALF-WORD) ;
        #8042键盘控制器的IO端口是0x60～0x6f，
        #实际上IBM PC/AT使用的只有0x60和0x64两个端口。
        #8042通过这些端口给键盘控制器或键盘发送命令或读取状态。
       
       testb $0x2, %al  # 测试al第2位是啥,第二位是"input register (60h/64h) 有数据"
       jnz seta20.1     #如果是1(有数据),等,循环



* 现在没数据了,(或许是因为关闭中断了,可以放心不会有数据进来?)

       #我们需要写Output Port, 需要做如下操作(硬件规定):
       1. 向64h发送0d1h命令
       2. 向60h写入Output Port的数据 

       movb $0xd1, %al         # 0xd1 -> port 0x64
       outb %al, $0x64         # 0xd1 means: write data to 8042's P2 port

       seta20.2:
       inb $0x64, %al          # 故技重施,等io结束
       testb $0x2, %al
       jnz seta20.2

       movb $0xdf, %al         # 0xdf -> port 0x60
       outb %al, $0x60         # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1,完成A20设置

* Switch from real to protected mode, using a bootstrap GDT and segment translation that makes virtual addresses identical to physical addresses, so that the effective memory map does not change during the switch.

* 加载全局描述符表,这个放到后面介绍

       lgdt gdtdesc

* 修改cr0寄存器. CR0寄存器是"控制寄存器"(control register)之一. 
* 其中　PE位(Protection Enabled，CR0的第0位)当值为1时,CPU采用保护模式,同时启动段机制; 在CR0.PE为0时,CPU采用保护模式

       movl %cr0, %eax          #保存进eax
       orl $CR0_PE_ON, %eax     #对应位进行或运算,
                                # CR0_PE_ON = 0x1, 文件最上方的定义
       movl %eax, %cr0          #放回cr0

* Jump to next instruction, but in 32-bit code segment. Switches processor into 32-bit mode.
## 问题?为什么定义CS在位置0x8而不是0x0

* Long jump, use  $PROT_MODE_CSEG for the CS register and $protcseg for the EIP register:
* CS为代码段寄存器。IP为指令指针寄存器。
       
       ljmp $PROT_MODE_CSEG, $protcseg

* 对应单步调试:
   
        0x7c2d:      ljmp   $0x8,$0x7c32
* 对于上面问题的可能解答
  
        阅读附录中关于"分段模式"的介绍.
        $PROT_MODE_CSEG 是 kernel code segment selector
        段选择子的格式为:
        |INDEX(15:3)|TI(2)|RPL(1:0)|
        则对应的INDEX为1
        相当于
*   Bootstrap GDT 中
  
        .p2align 2            # force 4 byte alignment
        gdt:
            SEG_NULLASM         # null seg
            SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   
            # code seg for bootloader and kernel
            # 这里有点奇怪, 因为0xffffffff超过20位了,
            # 我的理解是这个是"以字节为单位"描述的, 需要进行转换. 
            SEG_ASM(STA_W, 0x0, 0xffffffff)   
            # data seg for bootloader and kernel

        gdtdesc:
            .word 0x17         # sizeof(gdt) - 1
            .long gdt          # address gdt  

* 这一条

        SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   

* 根据/boot/asm.h中定义
 
        # base: 0x0 (32位)
        # limit: 0xffffffff (32位)
        # type: STA_X|STA_R = 0xA (4位)
        # define SEG_ASM(type,base,lim)     \
          .word (((lim) >> 12) & 0xffff), ((base) & 0xffff); \
          .byte (((base) >> 16) & 0xff), (0x90 | (type)), \
              (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)        

    按照doc.p111,给出的图表,可以理解

1. lim转换为4k单位表示后,还剩20位,与0xffff与运算取小16放入seg-descriptor最前(0:15:0)
2. base直接取后16位存到seg-descriptor(0:31:16)
3. base取23:16位,存到seg-dexcriptor(1:7:0)
4. 接下来处理type,type是0xA, 将其与0x90相与,得到0x9A, 
   1001|1010  
   |段存在位（Segment-Present bit）1,DPL为00, 恒1位1 | type | 
5. 接下来是一些设置, 详见文档, 加上lim剩余4位
6. 最后是base最高8位

总长64位.


## 成功进入保护模式

      .code32              # Assemble for 32-bit mode
      protcseg:
          # Set up the protected-mode data segment registers
          movw $PROT_MODE_DSEG, %ax  # Our data segment selector
          movw %ax, %ds      # -> DS: Data Segment
          movw %ax, %es      # -> ES: Extra Segment
          movw %ax, %fs      # -> FS
          movw %ax, %gs      # -> GS
          movw %ax, %ss      # -> SS: Stack Segment

          # Set up the stack pointer and call into C. 
          # The stack region is from 0--start(0x7c00)
          movl $0x0, %ebp
          movl $start, %esp
          call bootmain

    就没啥好说的了,进行了一些寄存器的初始化
    （1）ESP：栈指针寄存器(extended stack pointer)，其内存放着一个指针，该指针永远指向系统栈最上面一个栈帧的栈顶。
    （2）EBP：基址指针寄存器(extended base pointer)，其内存放着一个指针，该指针永远指向系统栈最上面一个栈帧的底部。

## 单步调试 vs bootasm.S

    0x7c01:      cld
    0x7c02:      xor    %ax,%ax
    0x7c04:      mov    %ax,%ds
    0x7c06:      mov    %ax,%es
    0x7c08:      mov    %ax,%ss
    0x7c0a:      in     $0x64,%al
    0x7c0c:      test   $0x2,%al
    0x7c0e:      jne    0x7c0a
    0x7c10:      mov    $0xd1,%al
    0x7c12:      out    %al,$0x64
    0x7c14:      in     $0x64,%al
    0x7c16:      test   $0x2,%al
    0x7c18:      jne    0x7c14
    0x7c1a:      mov    $0xdf,%al
    0x7c1c:      out    %al,$0x60
    0x7c1e:      lgdtw  0x7c6c
    0x7c23:      mov    %cr0,%eax
    0x7c26:      or     $0x1,%eax
    0x7c2a:      mov    %eax,%cr0
    0x7c2d:      ljmp   $0x8,$0x7c32
    0x7c32:      mov    $0xd88e0010,%eax
    0x7c38:      mov    %ax,%es
    0x7c3a:      mov    %ax,%fs
    0x7c3c:      mov    %ax,%gs
    0x7c3e:      mov    %ax,%ss
    0x7c40:      mov    $0x0,%bp
    0x7c43:      add    %al,(%bx,%si)
    0x7c45:      mov    $0x7c00,%sp
    0x7c48:      add    %al,(%bx,%si)
    0x7c4a:      call   0x7d07
    0x7c4d:      add    %al,(%bx,%si)
    0x7c4f:      jmp    0x7c4f
    0x7c51:      lea    0x0(%bp),%si
    0x7c54:      add    %al,(%bx,%si)
    0x7c56:      add    %al,(%bx,%si)
    0x7c58:      add    %al,(%bx,%si)
    0x7c5a:      add    %al,(%bx,%si)
    ......
