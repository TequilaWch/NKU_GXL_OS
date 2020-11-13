#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/*  In the First Fit algorithm, the allocator keeps a list of free blocks
 * (known as the free list). Once receiving a allocation request for memory,
 * it scans along the list for the first block that is large enough to satisfy
 * the request. If the chosen block is significantly larger than requested, it
 * is usually splitted, and the remainder will be added into the list as
 * another free block.
 *  Please refer to Page 196~198, Section 8.2 of Yan Wei Min's Chinese book
 * "Data Structure -- C programming language".
*/
// LAB2 EXERCISE 1: YOUR CODE
// you should rewrite functions: `default_init`, `default_init_memmap`,
// `default_alloc_pages`, `default_free_pages`.
/*
 * Details of FFMA
 * (1) Preparation:
 *  In order to implement the First-Fit Memory Allocation (FFMA), we should
 * manage the free memory blocks using a list. The struct `free_area_t` is used
 * for the management of free memory blocks.
 *  First, you should get familiar with the struct `list` in list.h. Struct
 * `list` is a simple doubly linked list implementation. You should know how to
 * USE `list_init`, `list_add`(`list_add_after`), `list_add_before`, `list_del`,
 * `list_next`, `list_prev`.
 *  There's a tricky method that is to transform a general `list` struct to a
 * special struct (such as struct `page`), using the following MACROs: `le2page`
 * (in memlayout.h), (and in future labs: `le2vma` (in vmm.h), `le2proc` (in
 * proc.h), etc).
 * (2) `default_init`:
 *  You can reuse the demo `default_init` function to initialize the `free_list`
 * and set `nr_free` to 0. `free_list` is used to record the free memory blocks.
 * `nr_free` is the total number of the free memory blocks.
 * (3) `default_init_memmap`:
 *  CALL GRAPH: `kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` -->
 * `pmm_manager` --> `init_memmap`.
 *  This function is used to initialize a free block (with parameter `addr_base`,
 * `page_number`). In order to initialize a free block, firstly, you should
 * initialize each page (defined in memlayout.h) in this free block. This
 * procedure includes:
 *  - Setting the bit `PG_property` of `p->flags`, which means this page is
 * valid. P.S. In function `pmm_init` (in pmm.c), the bit `PG_reserved` of
 * `p->flags` is already set.
 *  - If this page is free and is not the first page of a free block,
 * `p->property` should be set to 0.
 *  - If this page is free and is the first page of a free block, `p->property`
 * should be set to be the total number of pages in the block.
 *  - `p->ref` should be 0, because now `p` is free and has no reference.
 *  After that, We can use `p->page_link` to link this page into `free_list`.
 * (e.g.: `list_add_before(&free_list, &(p->page_link));` )
 *  Finally, we should update the sum of the free memory blocks: `nr_free += n`.
 * (4) `default_alloc_pages`:
 *  Search for the first free block (block size >= n) in the free list and resize
 * the block found, returning the address of this block as the address required by
 * `malloc`.
 *  (4.1)
 *      So you should search the free list like this:
 *          list_entry_t le = &free_list;
 *          while((le=list_next(le)) != &free_list) {
 *          ...
 *      (4.1.1)
 *          In the while loop, get the struct `page` and check if `p->property`
 *      (recording the num of free pages in this block) >= n.
 *              struct Page *p = le2page(le, page_link);
 *              if(p->property >= n){ ...
 *      (4.1.2)
 *          If we find this `p`, it means we've found a free block with its size
 *      >= n, whose first `n` pages can be malloced. Some flag bits of this page
 *      should be set as the following: `PG_reserved = 1`, `PG_property = 0`.
 *      Then, unlink the pages from `free_list`.
 *          (4.1.2.1)
 *              If `p->property > n`, we should re-calculate number of the rest
 *          pages of this free block. (e.g.: `le2page(le,page_link))->property
 *          = p->property - n;`)
 *          (4.1.3)
 *              Re-caluclate `nr_free` (number of the the rest of all free block).
 *          (4.1.4)
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
 * (5) `default_free_pages`:
 *  re-link the pages into the free list, and may merge small free blocks into
 * the big ones.
 *  (5.1)
 *      According to the base address of the withdrawed blocks, search the free
 *  list for its correct position (with address from low to high), and insert
 *  the pages. (May use `list_next`, `le2page`, `list_add_before`)
 *  (5.2)
 *      Reset the fields of the pages, such as `p->ref` and `p->flags` (PageProperty)
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

/*
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}*/

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);   //使用assert宏，当为假时中止程序
    struct Page *p = base;//声明一个base的Page，随后生成起始地址为base的n个连续页
    for (; p != base + n; p ++) { //初始化n块物理页
        assert(PageReserved(p)); //确保此页不是保留页，如果是，中止程序
        p->flags = p->property= 0; //标志位置为0
        SetPageProperty(p);       //设置为保留页
        set_page_ref(p, 0);  
        list_add_before(&free_list, &(p->page_link)); //加入空闲链表
    }
    nr_free += n;  //空闲页总数置为n
    base->property = n; //修改base的连续空页值为n
}

/*
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            list_add(&free_list, &(p->page_link));
    }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}*/

static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0); 
    if (n > nr_free) { //如果需要分配的页少于空闲页的总数,返回NULL
        return NULL;
    }
    list_entry_t *le, *len; //声明一个空闲链表的头部和长度
    le = &free_list;  //空闲链表的头部

    while((le=list_next(le)) != &free_list) {//遍历整个链表
      struct Page *p = le2page(le, page_link); //转换为页
      if(p->property >= n){//找到页(whose first `n` pages can be malloced)
        int i;
        for(i=0;i<n;i++){//对前n页进行操作
          len = list_next(le); 
          struct Page *pp = le2page(le, page_link); //转换为页
          SetPageReserved(pp); //PG_reserved = '1'
          ClearPageProperty(pp);//PG_property = '0'
          list_del(le); //将此页从free_list中清除
          le = len;
        }
        if(p->property>n){ //如果页块大小大于所需大小，分割页块
          (le2page(le,page_link))->property = p->property-n;
        }
        ClearPageProperty(p);
        SetPageReserved(p);
        nr_free -= n; //减去已经分配的页块大小
        return p;
      }
    }
    return NULL;
}

/*
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
        p = le2page(le, page_link);
        le = list_next(le);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}*/

//释放掉n个页块，释放后也要考虑释放的块是否和已有的空闲块是紧挨着的，也就是可以合并的
//如果可以合并，则合并，否则直接加入双向链表

/* //another version
static void 
default_free_pages(struct Page *base, size_t n) 
{
    assert(n > 0);  //n必须大于0
    struct Page *p = base;  
    //首先将base-->base+n之间的内存的标记以及ref初始化
    for (; p != base + n; p ++)
     {
        assert(!PageReserved(p) && !PageProperty(p));
        //将flags和ref设为0
        p->flags = 0; 
        set_page_ref(p, 0);
    }
    //释放完毕后先将这一块的property改为n
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);

    // 检查能否将其合并到合适的页块中
    while (le != &free_list)
    {
        p = le2page(le, page_link);
        le = list_next(le);
        //如果这个块在下一个空闲块前面，二者可以合并
        if (base + base->property == p) 
        {
            //让base的property等于两个块的大小之和
            base->property += p->property;
            //将另一个空闲块删除即可
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        //如果这个块在上一个空闲块的后面，二者可以合并
        else if (p + p->property == base) 
        {
            //将p的property设置为二者之和
            p->property += base->property;
            //将后面的空闲块删除即可
            ClearPageProperty(base);
            base = p;
            //注意这里需要把p删除，因为之后再次去确认插入的位置
            list_del(&(p->page_link));
        }
    }
    //整体上空闲空间增大了n
    nr_free += n;
    le = list_next(&free_list);
    // 将合并好的合适的页块添加回空闲页块链表
    //因为需要按照内存从小到大的顺序排列列表，故需要找到应该插入的位置
    //??? Why small -> big?
    while (le != &free_list) 
    {
        p = le2page(le, page_link);
        //找到正确的位置：
        if (base + base->property <= p)
        {
            break;
        }
        //否则链表项向后，继续查找
        le = list_next(le);
    }
    //将base插入到刚才找到的正确位置即可
    list_add_before(le, &(base->page_link));
}*/


static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);  
    assert(PageReserved(base));    //检查需要释放的页块是否已经被分配
    list_entry_t *le = &free_list; 
    struct Page * p;
    while((le=list_next(le)) != &free_list) {//找到释放的位置
      p = le2page(le, page_link);
      if(p>base){    
        break;
      }
    }
    for(p=base;p<base+n;p++){              
      list_add_before(le, &(p->page_link)); //在这个位置开始，插入释放数量的空页
    }
    base->flags = 0;         //修改标志位
    set_page_ref(base, 0);   //修改引用次数为0 
    ClearPageProperty(base);
    SetPageProperty(base);
    base->property = n;      //设置连续大小为n
    //如果是高位，则向高地址合并
    p = le2page(le,page_link) ;
  //满足base+n==p，因此，尝试向后合并空闲页。
  //如果能合并，那么base的连续空闲页加上p的连续空闲页，且p的连续空闲页置为0；
  //如果之后的页不能合并，那么p->property一直为0，下面的代码不会对它产生影响。
    if( base+n == p ){
      base->property += p->property;
      p->property = 0;
    }
     //如果是低位且在范围内，则向低地址合并
     //获取基地址页的前一个页，如果为空，那么循环查找之前所有为空，能够合并的页
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){ //满足条件，未分配则合并
      while(le!=&free_list){
        if(p->property){ //连续
          p->property += base->property;
          base->property = 0;
          //不断更新前一个页p的property值，并将base->property置为0
          break;
        }
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }

    nr_free += n;//空闲页数量加n
    return ;
} 


static size_t
default_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}


const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

