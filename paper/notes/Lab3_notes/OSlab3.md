# OSlab3--by：於一帆，林正青，吴昌昊

做完实验二后，大家可以了解并掌握物理内存管理中的连续空间分配算法的具体实现以及如 何建立二级页表。本次实验是在实验二的基础上，借助于页表机制和实验一中涉及的中断异 常处理机制，完成Page Fault异常处理和FIFO页替换算法的实现。实验原理最大的区别是在 设计了如何在磁盘上缓存内存页，从而能够支持虚存管理，提供一个比实际物理内存空间“更 大”的虚拟内存空间给系统使用。

实验目的如下

- 了解虚拟内存的Page Fault异常处理实现
- 了解页替换算法在操作系统中的实现

本次实验是在实验二的基础上，借助于页表机制和实验一中涉及的中断异常处理机制，完成 Page Fault异常处理和FIFO页替换算法的实现，结合磁盘提供的缓存空间，从而能够支持虚 存管理，提供一个比实际物理内存空间“更大”的虚拟内存空间给系统使用。这个实验与实际操 作系统中的实现比较起来要简单，不过需要了解实验一和实验二的具体实现。实际操作系统 系统中的虚拟内存管理设计与实现是相当复杂的，涉及到与进程管理系统、文件系统等的交 叉访问。如果大家有余力，可以尝试完成扩展练习，实现extended clock页替换算法。
## 练习1：给未被映射的地址映射上物理页（需要编程）

> 完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候 需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定 的页表，而不是内核的页表。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题： 
>
> -  请描述页目录项（Pag Director Entry）和页表（Page Table Entry）中组成部分对ucore 实现页替换算法的潜在用处。
> -  如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪 些事情？



## 练习2：补充完成基于FIFO的页面替换算法（需要编程）

> 完成vmm.c中的do_pgfault函数，并且在实现FIFO算法的swap_fifo.c中完成map_swappable 和swap_out_vistim函数。通过对swap的测试。
>
> 请在实验报告中简要说明你的设计实现过程。 请在实验报告中回答如下问题： 
>
> - 如果要在ucore上实现"extended clock页替换算法"请给你的设计方案，现有的 swap_manager框架是否足以支持在ucore中实现此算法？如果是，请给你的设计方案。 如果不是，请给出你的新的扩展和基此扩展的设计方案
>   - 需要被换出的页的特征是什么？
>   - 在ucore中如何判断具有这样特征的页？
>   - 何时进行换入和换出操作？

##### 关于代码

页面替换的过程可以分为页面换入和页面换出两个部分。页面换入部分在vmm.c中，承接在上一部分练习中完成的代码，而页面换出部分在swap_fifo.c中。

先来看页面换入的实现。

首先我们要先新分配一个物理页空间，保存通过 swap_in函数换出的磁盘中的数据，如果swap_in失败则报错返回。之后我们需要用page_insert这个函数将新申请的物理页面映射到线性地址上。最后因为我们是FIFO算法，把最近到达的页面排在队尾。而把页面排在队尾的功能在_fifo_map_swappable中。

因此可以编写代码如下

```c
/* vmm.c */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    switch (error_code & 3) {
    default:     
    case 2: 
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
    case 1: 
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;
    case 0: 
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
            goto failed;
        }
    }
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= PTE_W;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
    ret = -E_NO_MEM;
    pte_t *ptep=NULL;
    ptep = get_pte(mm->pgdir,addr,1);              
    if (*ptep == 0) 
    {
        if(pgdir_alloc_page(mm->pgdir,addr,perm) == NULL)
        {
            cprintf("Error:pgdir_alloc_page\n");
            goto failed;
        }                   

    }
    else 
    {
        if(swap_init_ok) 
        {
            struct Page *page=NULL;
            if((ret = swap_in(mm,addr,&page))!=0)
            {
                 cprintf("Error:swap_in\n");
                goto failed;
            }
            else
            {
                page_insert(mm->pgdir,page,addr,perm);
                swap_map_swappable(mm,addr,page,1);
                page->pra_vaddr = addr;
            }                            
        }
        else 
        {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
   ret = 0;
failed:
    return ret;
}

/* swap_fifo.c */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
}
```

既然有了IN，那肯定需要有OUT，OUT的功能主要在_fifo_swap_out_victim中实现。首先我们要找到需要被换出的页，并用一个指针le指示这个需要被换出的页。再用le2page找到对应的page，最后删除这个le指向的页并用之前找到的page替换参数中的ptr_page

代码实现如下

```c
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
     assert(head!=le);
     struct Page *p = le2page(le, pra_page_link);
     list_del(le);
     assert(p !=NULL);
     *ptr_page = p;
     return 0;
}
```

##### 关于问题

不会


## Challenge1：实现识别dirty bit的 extended clock页替 换算法（需要编程）

> 部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测 试的实验报告。完成出色的可获得适当加分。
>
> 没有任何有效的信息
>
> 如果非要说的话，应该是这个：**不是必做部分**


