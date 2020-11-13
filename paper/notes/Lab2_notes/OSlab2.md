# OSlab2--by：於一帆，林正青，吴昌昊

实验一过后大家做出来了一个可以启动的系统，实验二主要涉及操作系统的物理内存管理。 操作系统为了使用内存，还需高效地管理内存资源。在实验二中大家会了解并且自己动手完 成一个简单的物理内存管理系统。

实验目的如下

- 理解基于段页式内存地址的转换机制
- 理解页表的建立和使用方法
- 理解物理内存的管理方法

在开始实验前，别忘了将lab1中已经完成的代码填入本实验中代码有LAB1的注释的相应部分。可以采用diff和patch工具进行半自动的合并(merge)，也可以用一些图形化的比较/merge工具来合并，比如meld，eclipse中的diff/merge工具，understand中的diff/merge工具
## 练习0：合并Lab0和Lab1代码
![image-20201102235653991.png](https://i.loli.net/2020/11/05/wrHk5b68dyYtceK.png)

使用meld工具打开文件进行比较，因为lab1只修改了trap.c，init.c和kdegub.c这三个文件，所以一一比较合并即可。

## 练习1：实现first-fit连续物理内存分配算法(需要编程)

> 在实现first fit 内存分配算法的回收函数时，要考虑地址连续的空闲块之间的合并操作。提示: 在建立空闲页块链表时，需要按照空闲页块起始地址来排序，形成一个有序的链表。可能会 修改default_pmm.c中的default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数。请仔细查看和理解default_pmm.c中的注释。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> -  你的first fit算法是否有进一步的改进空间

ucore中采用面向对象编程的思想，将物理内存管理的内容抽象成若干个特定的函数，并以结构体pmm_manager作为物理内存管理器封装各个内存管理函数的指针，这样在管理物理内存时只需调用结构体内封装的函数，从而可将内存管理功能的具体实现与系统中其他部分隔离开。pmm_manager中保存的函数及其功能如下所述：

```c
struct pmm_manager {
    const char *name;                                 /*某种物理内存管理器的名称（可根据算法等具体实现的不同自定义新的内存管理器，这样也更加符合面向对象的思想）*/
    void (*init)(void);                               /*物理内存管理器初始化，包括生成内部描述和数据结构（空闲块链表和空闲页总数）*/ 
    void (*init_memmap)(struct Page *base, size_t n); /*初始化空闲页，根据初始时的空闲物理内存区域将页映射到物理内存上*/
    struct Page *(*alloc_pages)(size_t n);            //申请分配指定数量的物理页
    void (*free_pages)(struct Page *base, size_t n);  //申请释放若干指定物理页
    size_t (*nr_free_pages)(void);                    //查询当前空闲页总数
    void (*check)(void);                              //检查物理内存管理器的正确性
};
```

> 上图为pmm.h当中定义的结构体pmm_manager

涉及的结构体和宏定义：

memlayout.h中：

```c
struct Page {
    int ref;                        // page frame's reference counter
    uint32_t flags;                 //描述物理页帧状态的标志位
    unsigned int property;          //只在空闲块内第一页中用于记录该块中页数，其他页都是0
    list_entry_t page_link;         //空闲物理内存块双向链表
};
```

```c
/* Flags describing the status of a page frame */
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))
```

```c
/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header(@ with a forward ptr & a backward ptr)
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;
```

list.h：

```c
struct list_entry {
    struct list_entry *prev, *next;
};
/*list_entry_t是双链表结点的两个指针构成的集合，这个空闲块链表实际上是将各个块首页的指针集合（由prev和next构成）的指针（或者说指针集合所在地址）相连*/
typedef struct list_entry list_entry_t;
```

练习一共需实现四个函数：

- default_init：初始化物理内存管理器；
- default_init_memmap：初始化空闲页；
- default_alloc_pages：申请分配指定数量的物理页；
- default_free_pages: 申请释放若干指定物理页；

直接修改default_pmm.c中的内存管理函数来实现。

**default_init：**

```c
free_area_t free_area; /*allocate blank memory for the doublely linked list*/

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

初始化双向链表，将空闲页总数nr_free初始化为0。

**default_init_memmap：**

初始化一整个空闲物理内存块，将块内每一页对应的Page结构初始化，参数为基址和页数（因为相邻编号的页对应的Page结构在内存上是相邻的，所以可将第一个空闲物理页对应的Page结构地址作为基址，以基址+偏移量的方式访问所有空闲物理页的Page结构，**根据指导书，这个空闲块链表正是将各个块首页的指针集合（由prev和next构成）的指针（或者说指针集合所在地址）相连，并以基址区分不同的连续内存物理块**）。

根据注释，**具体流程为**：遍历块内所有空闲物理页的Page结构，将各个flags置为0以标记物理页帧有效，将property成员置零，使用 SetPageProperty宏置PG_Property标志位来标记各个页有效（具体而言，如果一页的该位为1，则对应页应是一个空闲块的块首页；若为0，则对应页要么是一个已分配块的块首页，要么不是块中首页；另一个标志位PG_Reserved在pmm_init函数里已被置位，这里用于确认对应页不是被OS内核占用的保留页，因而可用于用户程序的分配和回收），清空各物理页的引用计数ref；最后再将首页Page结构的property置为块内总页数，将全局总页数nr_free加上块内总页数，并用page_link这个双链表结点指针集合将块首页连接到空闲块链表里。

写出代码如下：

```c
static void 
default_init_memmap(struct Page *base, size_t n) {   
    assert(n > 0);
    struct Page *p = base;//块基址
    for (; p != base + n; p ++)
    {
        assert(PageReserved(p));//确认本页不是给OS的保留页
        p->flags = p->property = 0;
        SetPageProperty(p);//设置标志位
        set_page_ref(p, 0);//清空引用
    }
    nr_free += n;//增加全局总页数
    base->property=n;//本块首页的property设为n
    list_add_before(&free_list, &(base->page_link));//首页的指针集合插入空闲页链表
}
```

**default_alloc_pages(size_t n)：**

该函数分配指定页数的连续空闲物理内存空间，返回分配的空间中第一页的Page结构的指针。

流程：从起始位置开始顺序搜索空闲块链表，找到第一个页数不小于所申请页数n的块（只需检查每个Page的property成员，在其值>=n的第一个页停下），如果这个块的页数正好等于申请的页数，则可直接分配；如果块页数比申请的页数多，要将块分成两半，将起始地址较低的一半分配出去，将起始地址较高的一半作为链表内新的块，分配完成后重新计算块内空闲页数和全局空闲页数；若遍历整个空闲链表仍找不到足够大的块，则返回NULL表示分配失败。

```c
static struct Page *
default_alloc_pages(size_t n) {
    assert(n>0);
    if(n>nr_free) return NULL;//如果所有空闲页的总数都不够，直接返回NULL
    struct Page *page = NULL;
	list_entry_t *le = &free_list;
	while ((le = list_next(le)) != &free_list) {
   		struct Page *p = le2page(le, page_link);//链表内地址转换为Page结构指针
    	if (p->property >= n) {//遇到第一个页数不小于n的块
        	page = p;//可得块首页
        	break;
    	}
	}
    if (page != NULL) { //如果找到了满足条件的空闲内存块
    	for (struct Page *p = page; p != (page + n); ++p)
        	ClearPageProperty(p); //将分配出去的内存页标记为非空闲
    	if (page->property > n) { /*如果原先找到的空闲块大小大于需要的分配内存大小，进行分裂*/		  struct Page *p = page + n; //分裂出来的新的小空闲块首页
        	p->property = page->property - n; //更新新的空闲块的大小信息
        	list_add(&(page->page_link), &(p->page_link)); /*将新空闲块插入空闲块列表中*/	}
    list_del(&(page->page_link)); //从链表里删除分配出去的空闲块
    nr_free -= n; //更新全局空闲页数
	}
    return page;
}
```

**default_free_pages(struct Page *base, size_t n)：**

释放从指定的某一物理页开始的若干个被占用的连续物理页，将这些页连回空闲块链表，重置其中的标志信息，最后进行一些碎片整理性质的块合并操作。

首先根据参数提供的块基址，遍历链表找到待插入位置，插入这些页。然后将引用计数ref、flags标志位置位，最后**调用merge_blocks函数迭代地进行块合并，以获取尽可能大的连续内存块**。规则是从新插入的块开始，首先正序遍历链表，不断将链表内基址与新插入块物理地址较大一端相邻的空闲块合并到新插入块里（也是对应着分配内存块时将物理基址较大的块留在链表里）；然后反序遍历链表，不断将链表内的基址与新插入块物理地址较小一端相邻的空闲块合并到新插入块里。

代码实现如下：

```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));/*确认各个页状态是被OS占用的或是已分配的，如果释放了空闲的内存则产生异常*/
        p->flags = 0;
        SetPageProperty(p);//PG_Property重置为空闲状态
        set_page_ref(p, 0);
    }//先对块内各页进行标志信息重置
    //块首页的成员property重新赋值为n
    base->property = n;

    list_entry_t *le = list_next(&free_list);//以链表头部的下一个为起始结点，开始顺序搜索
    while (le != &free_list && le < &base->page_link) {
        le = list_next(le);
    }
    list_add_before(&free_list, &(base->page_link));
    nr_free += n;
    while (merge_block(base)); /*块合并*/
	for (list_entry_t *i = list_prev(&(base->page_link)); i!= &free_list; i = list_prev(i)) { //再将新插入的空闲块和其物理地址小的一段的所有相邻的物理空闲块进行合并
    if (!merge_block(le2page(i, page_link))) break;
}
}

static unsigned int
merge_block(struct Page *base){
    list_entry_t *le = list_next(&(base->page_link)); //获取链表中下一空闲块的地址
    if (le == &free_list) return 0; /*如果当前空闲块是物理地址最大的空闲块，则无法进行向后合并，返回合并失败*/
    struct Page *p = le2page(le, page_link);
    if (PageProperty(p) == 0) return 0;//异常情况
    if (base + base->property != p) return 0; //如果两空闲块不相邻，合并终止
    
    //合并操作
    base->property += p->property;
    p->property = 0;
    //将合并前的物理地址较大的空闲块从链表中删去
    list_del(le); 
    return 1; //返回合并成功
}
```



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
		if(!create || (temPage = alloc_page()) == NULL)
		{
			return NULL;
		}
		set_page_ref(temPage,1);
		uintptr_t pa = page2pa(temPage);
		memset(KADDR(pa),0,PGSIZE);
		*pdep = pa | PTE_U | PTE_W | PTE_P;		
	}

	return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
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

##### 遇到的坑

PDE,PDT,PTT,PTE真的很容易让人弄混，而且他们的发音真的很像，一不留神就弄混了。搞清楚关系和结构看一下注释就能很快地搞定。

## 练习3：释放某虚地址所在的页并取消对应二级页表项的映射(需要编程)

> 当释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除。请仔细查看和理解page_remove_pte函数中的注释。为此，需要补全在 kern/mm/pmm.c中的page_remove_pte函数。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？
> - 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题
##### 关于代码：

练习3可以看成是练习2的简单的逆过程，在理解了练习2的基础上，释放虚地址所在的页和取消对应二级页表项的映射可以大概分为如下步骤：

1. 通过PTE_P判断该ptep是否存在；
2. 判断Page的ref的值是否为0，若为0，则说明此时没有任何逻辑地址被映射到此物理地址，换句话说当前物理页已没人使用，因此调用free_page函数回收此物理页，使得该物理页空闲；若不为0，则说明此时仍有至少一个逻辑地址被映射到此物理地址，因此不需回收此物理页；
3. 把表示虚地址与物理地址对应关系的二级页表项清除；
4. 更新TLB；

根据Lab2中的代码提示，我们将MACROs 和 DEFINES拿出进行理解：

```c
static inline struct Page *
pte2page(pte_t pte) {//从ptep值中获取相应的页面
    if (!(pte & PTE_P)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
}

//减少该页的引用次数，返回剩下的引用次数。
static inline int  
page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}

//当修改的页表目前正在被进程使用时，使之无效。
void 
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) {
        invlpg((void *)la);
    }
}



#define PTE_P           0x001                   // Present，即最低位为1；

```

在此基础之上，我们给出完整的代码：

```C
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {

if (*ptep & PTE_P) {
        // 如果对应的二级页表项存在，如果*ptep存在，则其与PTE_P相与，得到的是1；
        struct Page *page = pte2page(*ptep);  // 获得*ptep对应的Page结构
        // 关联的page引用数自减1，page_ref_dec的返回值是现在的page->ref
       if(page_ref_dec(page) == 0) {
            // 如果自减1后，引用数为0，需要free释放掉该物理页
            free_page(page);
        }
        // 把表示虚地址与物理地址对应关系的二级页表项清除(通过把整体设置为0)
        *ptep = 0;
        // 由于页表项发生了改变，需要使TLB快表无效
        tlb_invalidate(pgdir, la);
    }
   
}
```

##### 关于问题：

Q1：数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

A：所有的物理页都有一个描述它的Page结构，所有的页表都是通过alloc_page()分配的，每个页表项都存放在一个Page结构描述的物理页中；如果 PTE 指向某物理页，同时也有一个Page结构描述这个物理页。所以有两种对应关系：

(1)可以通过 PTE 的地址计算其所在的页表的Page结构：

 将虚拟地址向下对齐到页大小，换算成物理地址(减 KERNBASE), 再将其右移 PGSHIFT(12)位获得在pages数组中的索引PPN，&pages[PPN]就是所求的Page结构地址。

(2)可以通过 PTE 指向的物理地址计算出该物理页对应的Page结构：

PTE 按位与 0xFFF获得其指向页的物理地址，再右移 PGSHIFT(12)位获得在pages数组中的索引PPN，&pages[PPN]就 PTE 指向的地址对应的Page结构。



Q2：如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题。

A：此时虚拟地址和物理地址的映射关系是：phy addr + KERNBASE = virtual addr

所以如果想让虚拟地址=物理地址，则只要让KERNBASE = 0，因此去修改memlayout.h的宏定义

```c
#define KERNBASE            0xC0000000
```




## Challenge1：buddy system(伙伴系统)分配算法(需要编程)

> Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的 大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128... 
>
> - 参考伙伴分配器的一个极简实现， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

   Buddy system是一种连续物理内存的分配算法，主要应用二叉树来完成内存的分配；可以用来替换exe1中的first-fit算法。

网上对buddy system的算法定义如下：

**分配内存：**

1.寻找大小合适的内存块（大于等于所需大小并且最接近2的幂，比如需要27，实际分配32）

​    1.1 如果找到了，分配给应用程序。
​    1.2 如果没找到，分出合适的内存块。

​       1.2.1 对半分离出高于所需大小的空闲内存块
​       1.2.2 如果分到最低限度，分配这个大小。
​       1.2.3 回溯到步骤1（寻找合适大小的块）
​       1.2.4 重复该步骤直到一个合适的块

**释放内存：**

1.释放该内存块

   1.1 寻找相邻的块，看其是否释放了。
   1.2 如果相邻块也释放了，合并这两个块，重复上述步骤直到遇上未释放的相邻块，或者达到最高上限（即所有内存都释放了）。

​        在此定义之下，我们使用数组分配器来模拟构建这样完全二叉树结构而不是真的用指针建立树结构——树结构中向上或向下的指针索引都通过数组分配器里面的下标偏移来实现。在这个“完全二叉树”结构中，二叉树的节点用于标记相应内存块的使用状态，高层节点对应大的块，低层节点对应小的块，在分配和释放中我们就通过这些节点的标记属性来进行块的分离合并。

​        在分配阶段，首先要搜索大小适配的块——这个块所表示的内存大小刚好大于等于最接近所需内存的2次幂；通过对树深度遍历，从左右子树里面找到最合适的，将内存分配。

​        在释放阶段，我们将之前分配出去的内存占有情况还原，并考察能否和同一父节点下的另一节点合并，而后递归合并，直至不能合并为止。

![image-20201110000901267.png](https://i.loli.net/2020/11/11/rVJYyaZokCqDPT1.png)

​       基于上面的理论准备，我们可以开始写代码了。因为buddy system替代的是之前的first fit算法，所以可以仿照default_pmm的格式来写。

​       首先，编写buddy.h（仿照default_pmm.h），唯一修改的地方是引入的pmm_manager不一样，要改成buddy system所使用的buddy_pmm_manager

```C
#ifndef __KERN_MM_BUDDY_PMM_H__
#define  __KERN_MM_BUDDY_PMM_H__

#include <pmm.h>

extern const struct pmm_manager buddy_pmm_manager;

#endif /* ! __KERN_MM_DEFAULT_PMM_H__ */
```

​        而后，进入buddy.c文件

   1. 因为这里使用数组来表示二叉树结构，所以需要建立正确的索引机制：每level的第一左子树的下标为2^level-1，所以如果我们得到[index]节点的所在level，那么offset的计算可以归结为(index-2^level+1) * node_size = (index+1)*node_size – node_size*2^level。其中size的计算为2^(max_depth-level)，所以node_size * 2^level = 2^max_depth = size。综上所述，可得公式offset=(index+1)*node_size – size。
      PS：式中索引的下标均从0开始，size为内存总大小，node_size为内存块对应大小。

      由上，完成宏定义。

```C++
#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)
```

          2.  因为buddy system的块大小都是2的倍数，所以我们对于输入的所需的块大小，要先计算出最接近于它的2的倍数的值以匹配buddy system的最合适块的查找。

```C
static unsigned fixsize(unsigned size) {
  size |= size >> 1;
  size |= size >> 2;
  size |= size >> 4;
  size |= size >> 8;
  size |= size >> 16;
  return size+1;
}
```

3. 构造buddy system最基本的数据结构，并初始化一个用来存放二叉树的数组。

```C++
struct buddy {
  unsigned size;//表明管理内存
  unsigned longest; 
};
struct buddy root[10000];//存放二叉树的数组，用于内存分配
```

4. buddy system是需要和实际指向空闲块双链表配合使用的，所以需要先各自初始化数组和指向空闲块的双链表。

```C++
//先初始化双链表
free_area_t free_area;
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void buddy_init()
{
    list_init(&free_list);
    nr_free=0;
}

//再初始化buddy system的数组
void buddy_new( int size ) {
  unsigned node_size;    //传入的size是这个buddy system表示的总空闲空间；node_size是对应节点所表示的空闲空间的块数
  int i;
  nr_block=0;
  if (size < 1 || !IS_POWER_OF_2(size))
    return;

  root[0].size = size;
  node_size = size * 2;   //认为总结点数是size*2

  for (i = 0; i < 2 * size - 1; ++i) {
    if (IS_POWER_OF_2(i+1))    //如果i+1是2的倍数，那么该节点所表示的二叉树就要到下一层了
      node_size /= 2;
    root[i].longest = node_size;   //longest是该节点所表示的初始空闲空间块数
  }
  return;
}
```

5. 根据pmm.h里面对于pmm_manager的统一结构化定义，我们需要对buddy system完成如下函数：

```C++
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",      // 管理器的名称
    .init = buddy_init,               // 初始化管理器
    .init_memmap = buddy_init_memmap, // 设置可管理的内存,初始化可分配的物理内存空间
    .alloc_pages = buddy_alloc_pages, // 分配>=N个连续物理页,返回分配块首地址指针 
    .free_pages = buddy_free_pages,   // 释放包括自Base基址在内的，起始的>=N个连续物理内存页
    .nr_free_pages = buddy_nr_free_pages, // 返回全局的空闲物理页数量
    .check = buddy_check,             //举例检测这个pmm_manager的正确性
};
```

​    5.1 初始化管理器（这个已在上面完成）

​    5.2 初始化可管理的物理内存空间

```C++
static void
buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n>0);
    struct Page* p=base;
    for(;p!=base + n;p++)
    {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 1;
        set_page_ref(p, 0);    //表明空闲可用
        SetPageProperty(p);
        list_add_before(&free_list,&(p->page_link));     //向双链表中加入页的管理部分
    }
    nr_free += n;     //表示总共可用的空闲页数
    int allocpages=UINT32_ROUND_DOWN(n);
    buddy2_new(allocpages);    //传入所需要表示的总内存页大小，让buddy system的数组得以初始化
}
```

​    5.3 分配所需的物理页，返回分配块首地址指针

```C++
//分配的逻辑是：首先在buddy的“二叉树”结构中找到应该分配的物理页在整个实际双向链表中的位置，而后把相应的page进行标识表明该物理页已经分出去了。
static struct Page*
buddy_alloc_pages(size_t n){
  assert(n>0);
  if(n>nr_free)
   return NULL;
  struct Page* page=NULL;
  struct Page* p;
  list_entry_t *le=&free_list,*len;
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
  int i;
  for(i=0;i<rec[nr_block].offset+1;i++)
    le=list_next(le);
  page=le2page(le,page_link);
  int allocpages;
  if(!IS_POWER_OF_2(n))
   allocpages=fixsize(n);
  else
  {
     allocpages=n;
  }
  //根据需求n得到块大小
  rec[nr_block].base=page;//记录分配块首页
  rec[nr_block].nr=allocpages;//记录分配的页数
  nr_block++;
  for(i=0;i<allocpages;i++)
  {
    len=list_next(le);
    p=le2page(le,page_link);
    ClearPageProperty(p);
    le=len;
  }//修改每一页的状态
  nr_free-=allocpages;//减去已被分配的页数
  page->property=n;
  return page;
}


//以下是在上面的分配物理内存函数中用到的结构和辅助函数
struct allocRecord//记录分配块的信息
{
  struct Page* base;
  int offset;
  size_t nr;//块大小，即包含了多少页
};

struct allocRecord rec[80000];//存放偏移量的数组
int nr_block;//已分配的块数

int buddy2_alloc(struct buddy2* self, int size) { //size就是这次要分配的物理页大小
  unsigned index = 0;  //节点的标号
  unsigned node_size;  //用于后续循环寻找合适的节点
  unsigned offset = 0;

  if (self==NULL)//无法分配
    return -1;

  if (size <= 0)//分配不合理
    size = 1;
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
    size = fixsize(size);

  if (self[index].longest < size)//根据根节点的longest，发现可分配内存不足，也返回
    return -1;

  //从根节点开始，向下寻找左右子树里面找到最合适的节点
  for(node_size = self->size; node_size != size; node_size /= 2 ) {
    if (self[LEFT_LEAF(index)].longest >= size)
    {
       if(self[RIGHT_LEAF(index)].longest>=size)
        {
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
         //找到两个相符合的节点中内存较小的结点
        }
       else
       {
         index=LEFT_LEAF(index);
       }  
    }
    else
      index = RIGHT_LEAF(index);
  }

  self[index].longest = 0;//标记节点为已使用
  offset = (index + 1) * node_size - self->size;  //offset得到的是该物理页在双向链表中距离“根节点”的偏移
  //这个节点被标记使用后，要层层向上回溯，改变父节点的longest值
  while (index) {
    index = PARENT(index);
    self[index].longest = 
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  }
  return offset;
}

```

   5.4 释放指定的内存页大小

```C++
void buddy_free_pages(struct Page* base, size_t n) {
  unsigned node_size, index = 0;
  unsigned left_longest, right_longest;
  struct buddy2* self=root;
  
  list_entry_t *le=list_next(&free_list);
  int i=0;
  for(i=0;i<nr_block;i++)  //nr_block是已分配的块数
  {
    if(rec[i].base==base)  
     break;
  }
  int offset=rec[i].offset;
  int pos=i;//暂存i
  i=0;
  while(i<offset)
  {
    le=list_next(le);
    i++;     //根据该分配块的记录信息，可以找到双链表中对应的page
  }
  int allocpages;
  if(!IS_POWER_OF_2(n))
   allocpages=fixsize(n);
  else
  {
     allocpages=n;
  }
  assert(self && offset >= 0 && offset < self->size);//是否合法
  nr_free+=allocpages;//更新空闲页的数量
  struct Page* p;
  for(i=0;i<allocpages;i++)//回收已分配的页
  {
     p=le2page(le,page_link);
     p->flags=0;
     p->property=1;
     SetPageProperty(p);
     le=list_next(le);
  }
  
  //实际的双链表信息复原后，还要对“二叉树”里面的节点信息进行更新
  node_size = 1;
  index = offset + self->size - 1;   //从原始的分配节点的最底节点开始改变longest
  self[index].longest = node_size;   //这里应该是node_size，也就是从1那层开始改变
  while (index) {//向上合并，修改父节点的记录值
    index = PARENT(index);
    node_size *= 2;
    left_longest = self[LEFT_LEAF(index)].longest;
    right_longest = self[RIGHT_LEAF(index)].longest;
    
    if (left_longest + right_longest == node_size) 
      self[index].longest = node_size;
    else
      self[index].longest = MAX(left_longest, right_longest);
  }
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录，即从分配数组里面把后面的数据往前挪
  {
    rec[i]=rec[i+1];
  }
  nr_block--;//更新分配块数的值
}
```

   5.5 返回全局的空闲物理页数

```C++
static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
```

​    5.6 检查这个pmm_manager是否正确

```C++
//以下是一个测试函数
static void
buddy_check(void) {
    struct Page  *A, *B;
    A = B  =NULL;

    assert((A = alloc_page()) != NULL);
    assert((B = alloc_page()) != NULL);

    assert( A != B);
    assert(page_ref(A) == 0 && page_ref(B) == 0);
  //free page就是free pages(p0,1)
    free_page(A);
    free_page(B);
    
    A=alloc_pages(500);     //alloc_pages返回的是开始分配的那一页的地址
    B=alloc_pages(500);
    cprintf("A %p\n",A);
    cprintf("B %p\n",B);
    free_pages(A,250);     //free_pages没有返回值
    free_pages(B,500);
    free_pages(A+250,250);
    
}
```



## Challenge2：任意大小的内存单元slub分配算法(需要编程)

> slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在 第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。 
>
> - 参考linux的slub分配算法/，在ucore中实现slub分配算法。要求有比较充分的测试用例说 明实现的正确性，需要有设计文档。

上一个challenge中的buddy system像是一个批发商，按页批发大量的内存。但是很多时候你买东西并不需要去批发，而是去零售。零售商就是我们的slub分配算法。slub运行在buddy system之上，为内核（客户）提供小内存的管理功能。

slub算法将内存分组管理，每个组分别为2^3^,2^4^,2^5^,...,2^11^B和两个特殊组96B和192B。为什么这么分，因为我们的页大小默认为4KB=2^12^B，也就是说如果我们需要大于等于2^12^B的内存，就用buddy system批发，而需要小内存的时候就用slub来分配就行。

我们可以用一个kmem_cache数组 kmalloc_caches[12]来存放上面的12个组，可以把kmem_cache想象为12个零售商，每个零售商只卖一种东西。零售商有自己的仓库和自己的店面，店面里只有一个slab，如果slab卖完了再从仓库中换出其他的slab。

在slub的使用过程中有如下几种情况

1. 刚刚创建slub系统，第一次申请空间

   此时slub刚刚建立起来，不管是仓库还是店面都没有slab，这个时候首先需要从buddy system中申请空闲的内存页，然后把这些内存页slub划分为很多的零售品object，选择一个摆在商店中，剩下的放在仓库里。然后把商品中分一个给顾客

2. 商店里有可用的object

   这个时候就直接给呗，还能不给的咯

3. 商店没东西，仓库有

   从仓库里换出一个新的空的slub，并分一个空闲object给顾客

4. 商店和仓库都没有了

   这个时候只能重新批发新的slub回来，重复1

至于其他的嘛...

![1.jpg](https://i.loli.net/2020/11/13/pYGHkwqbLjKsQWr.jpg)

我是真的不会了，写了400多行bug的挫败感确实有点大，等过段时间把手上的活忙完了再写。