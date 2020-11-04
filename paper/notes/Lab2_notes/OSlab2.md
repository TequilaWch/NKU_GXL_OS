# OSlab2--by：於一帆，林正青，吴昌昊

实验一过后大家做出来了一个可以启动的系统，实验二主要涉及操作系统的物理内存管理。 操作系统为了使用内存，还需高效地管理内存资源。在实验二中大家会了解并且自己动手完 成一个简单的物理内存管理系统。

实验目的如下

- 理解基于段页式内存地址的转换机制
- 理解页表的建立和使用方法
- 理解物理内存的管理方法

在开始实验前，别忘了将lab1中已经完成的代码填入本实验中代码有LAB1的注释的相应部分。可以采用diff和patch工具进行半自动的合并(merge)，也可以用一些图形化的比较/merge工具来合并，比如meld，eclipse中的diff/merge工具，understand中的diff/merge工具

## 练习1：实现first-fit连续物理内存分配算法(需要编程)

> 在实现first fit 内存分配算法的回收函数时，要考虑地址连续的空闲块之间的合并操作。提示: 在建立空闲页块链表时，需要按照空闲页块起始地址来排序，形成一个有序的链表。可能会 修改default_pmm.c中的default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数。请仔细查看和理解default_pmm.c中的注释。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> -  你的first fit算法是否有进一步的改进空间



## 练习2：实现寻找虚拟地址对应的页表项(需要编程)

> 通过设置页表和对应的页表项，可建立虚拟内存地址和物理内存地址的对应关系。其中的 get_pte函数是设置页表项环节中的一个重要步骤。此函数找到一个虚地址对应的二级页表项 的内核虚地址，如果此二级页表项不存在，则分配一个包含此项的二级页表。本练习需要补全get_pte函数 in kern/mm/pmm.c，实现其功能。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题： 
>
> - 请描述页目录项（Pag Director Entry）和页表（Page Table Entry）中每个组成部分的含 义和以及对ucore而言的潜在用处。
> -  如果ucore执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

首先需要知道PDT(页目录表),PDE(页目录项),PTT(页表),PTE(页表项)之间的关系:页表保存页表项，页表项被映射到物理内存地址；页目录表保存页目录项，页目录项映射到页表。

###### PDE和PTE的各部分含义及用途

PDE和PTE都是4B大小的一个元素，其高20bit被用于保存索引，低12bit用于保存属性，但是由于用处不同，内部具有细小差异，如图所示：

![pde.png](https://i.loli.net/2020/11/04/7DvHaPVIACfyjbN.png)

![pte.png](https://i.loli.net/2020/11/04/Yqdz7hTnWtEBsSc.png)

| bit  | PDE                                                          | PTE                                                        |
| ---- | ------------------------------------------------------------ | ---------------------------------------------------------- |
| 0    | Present位，0不存在，1存在下级页表                            | 同                                                         |
| 1    | Read/Write位，0只读，1可写                                   | 同                                                         |
| 2    | User/Supervisor位，0则其下页表/物理页用户无法访问，1可以访问 | 同                                                         |
| 3    | Page level Write Through，1则开启页层次的写回机制，0不开启   | 同                                                         |
| 4    | Page level Cache Disable， 1则禁止页层次缓存，0不禁止        | 同                                                         |
| 5    | Accessed位，1代表在地址翻译过程中曾被访问，0没有             | 同                                                         |
| 6    | 忽略                                                         | 脏位，判断是否有写入                                       |
| 7    | PS，当且仅当PS=1且CR4.PSE=1，页大小为4M，否则为4K            | 如果支持 PAT 分页，间接决定这项访问的页的内存类型，否则为0 |
| 8    | 忽略                                                         | Global 位。当 CR4.PGE 位为 1 时,该位为1则全局翻译          |
| 9    | 忽略                                                         | 忽略                                                       |
| 10   | 忽略                                                         | 忽略                                                       |
| 11   | 忽略                                                         | 忽略                                                       |

###### 出现页访问异常时，硬件执行的工作

- 首先需要将发生错误的线性地址la保存在CR2寄存器中
  - 这里说一下控制寄存器CR0-4的作用
  - CR0的0位是PE位，如果为1则启动保护模式，其余位也有自己的作用
  - CR1是未定义控制寄存器，留着以后用
  - CR2是**页故障线性地址寄存器**，保存最后一次出现页故障的全32位线性地址
  - CR3是**页目录基址寄存器**，保存PDT的物理地址
  - CR4在Pentium系列处理器中才实现，它处理的事务包括诸如何时启用虚拟8086模式等
- 之后需要往中断时的栈中压入EFLAGS,CS,EIP,ERROR CODE，如果这页访问异常很不巧发生在用户态，还需要先压入SS,ESP并切换到内核态
- 最后根据IDT表查询到对应的也访问异常的ISR，跳转过去并将剩下的部分交给软件处理。

###### 代码的实现

为了获取PTE，很自然需要先获取PDE，通过PDX(la)可以获得对应的PDE的索引，之后在pkdir中根据索引找到对应的PDE指针，写成代码即为

```
pde_t *pdep = &pgdir[PDX(la)];
```

之后判断其Present位是否为1(若不为1则需要为其创建新的PTT)，在创建时如果失败(创建标志为0或者分配物理内存页失败)需要立即返回，对应代码为

```c
if(!(*pdep & PTE_P))
{
	struct Page *temPage;

	if(!create || (temPage = alloc_page()) == NULL )
	{
        return NULL;
	}
    
}
```

分配物理内存页之后，把这个物理页的引用的计数通过set_page_ref更新。

获取这个temPage的物理地址，然后把这个物理页全部初始化为0(需要用KADDR转换为内核虚拟地址)。到此完成了pte的设置，还需要更新pde中的几个标识位。对应代码如下

```c
	set_page_ref(temPage,1);
	uintptr_t pa = page2pa(temPage);
	memset(KADDR(pa), 0, PGSIZE);
	// pa的地址，用户级，可写，存在
	*pdep = pa | PTE_U | PTE_W | PTE_P;
```

最后需要返回这个对应的PTE，而目前我们有的是一个pdep，存放着PTT的物理地址，根据PDE的结构，可以得出这样一个流程

1. 抹去低12位，只保留对应的PTT的起始基地址
2. 用PTX(la)获得PTT对应的PTE的索引
3. 用数组和对应的索引得到PTE并返回

~~~c
return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]; 
~~~

完整代码如下：

```c
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    /* LAB2 EXERCISE 2: YOUR CODE
     *
     * If you need to visit a physical address, please use KADDR()
     * please read pmm.h for useful macros
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   KADDR(pa) : takes a physical address and returns the corresponding kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 0
    pde_t *pdep = NULL;   // (1) find page directory entry
    if (0) {              // (2) check if entry is not present
                          // (3) check if creating is needed, then alloc page for page table
                          // CAUTION: this page is used for page table, not for common data page
                          // (4) set page reference
        uintptr_t pa = 0; // (5) get linear address of page
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    
	pde_t *pdep = &pgdir[PDX(la)];
	
	if(!(*pdep & PTE_P))
	{
		struct Page *temPage;
		if(!create || (page = alloc_page()) == NULL)
		{
			return NULL;
		}
		set_page_ref(temPage,1);
		uintptr_t pa = page2pa(temPage);
		memset(KADDR(pa),0,PGSIZE);
		*pdep = pa | PTE_U | PTE_W | PTE_P;		
	}

	resturn &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
}
```

la,PDX,PTX,PTE_ADDR,PDE_ADDR的定义可以在mmu.h下看到，具体内容如下

~~~c
// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |     Index      |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \----------- PPN(la) -----------/
//
// The PDX, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).

// page directory index
#define PDX(la) ((((uintptr_t)(la)) >> PDXSHIFT) & 0x3FF)

// page table index
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x3FF)

// offset in page
#define PGOFF(la) (((uintptr_t)(la)) & 0xFFF)

// address in page table or page directory entry
#define PTE_ADDR(pte)   ((uintptr_t)(pte) & ~0xFFF)
#define PDE_ADDR(pde)   PTE_ADDR(pde)
~~~

其高10位用作PDT的索引，中10位用作PTT的索引，末12位用作物理页偏移量

KADDR，page2pa可以在pmm.h中看到

```c
/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
#define KADDR(pa) ({                                                    \
            uintptr_t __m_pa = (pa);                                    \
            size_t __m_ppn = PPN(__m_pa);                               \
            if (__m_ppn >= npage) {                                     \
                panic("KADDR called with invalid pa %08lx", __m_pa);    \
            }                                                           \
            (void *) (__m_pa + KERNBASE);                               \
        })

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages;
}
// PGSHIFT = log2(PGSIZE) = 12
static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}
```



## 练习3：释放某虚地址所在的页并取消对应二级页表项的映射(需要编程)

> 当释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除。请仔细查看和理解page_remove_pte函数中的注释。为此，需要补全在 kern/mm/pmm.c中的page_remove_pte函数。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？
> - 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题



## Challenge1：buddy system(伙伴系统)分配算法(需要编程)

> Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的 大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128... 
>
> - 参考伙伴分配器的一个极简实现， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。



## Challenge2：任意大小的内存单元slub分配算法(需要编程)

> slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在 第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。 
>
> - 参考linux的slub分配算法/，在ucore中实现slub分配算法。要求有比较充分的测试用例说 明实现的正确性，需要有设计文档。