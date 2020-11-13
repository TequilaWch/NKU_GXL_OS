#include <slub.h>
#include <list.h>
#include <defs.h>
#include <string.h>
#include <stdio.h>

typedef struct slub_t {
	int ref;
	kmem_cache_t *p;
	uint16_t used;
	uint16_t freeoff;
	list_entry_t slub_linklist;
}slub_t;

#define SIZED_CACHE_NUM 8
#define SIZED_CACHE_MIN 16
#define SIZED_CACHE_MAX 2048

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

#define LE2SLUB(le,link) ((slub_t*)le2page((struct Page*)le,link))
#define SLUB2KVA(slub) (page2kva((struct Page*)slub))

static list_entry_t cache_chain;
static kmem_cache_t cache_cache;
static kmem_cache_t *cache_sized[SIZED_CACHE_NUM];
static char *cache_name = "cache";
static char *sized_name = "sized";

static void *kmem_cache_grow(kmem_cache_t *p){
	struct Page *page = alloc_page();
	void *kva = page2kva(page);
	slub_t *slub = (slub_t *)page;
	slub->p = p;
	slub->used = slub->freeoff = 0;
	list_add(&(p->slubs_free), &(slub->slub_linklist));
	int16_t *bufctl = kva;
	for(int i = 1; i < p->num; i++)
	{
		bufctl[i-1] = i;
	}
	bufctl[p->num-1] = -1;
	void *buf = bufctl + p->num;
	if (p->ctor)
	{
		for(void *t = buf; t < buf + p->objsize * p->num; t += p->objsize)
		{
			p->ctor(t,p,p->objsize);
		}
	}
	return slub;
}

static void kmem_slub_destory(kmem_cache_t *p, slub_t *slub)
{
	struct Page *page = (struct Page *)slub;
	int16_t *bufctl = page2kva(page);
	void *buf = bufctl + p->num;
	if(p->dtor)
	{
		for(void *t = buf; t < buf + p->objsize * p->num; t+= p->objsize)
		{
			p->dtor(t,p,p->objsize);
		}
	}
	page->property = page->flags = 0;
	list_del(&(page->page_link));
	free_page(page);
}

static int kmem_sized_index(size_t size)
{
	size_t s = ROUNDUP(size, 2);
	if(s < SIZED_CACHE_MIN){s = SIZED_CACHE_MIN;}
	int index = 0;
	for (int t = s/32; t!=0; t/=2)
	{
		index++;
	}
	return index;
}

static size_t slub_nr_free_pages(void) {
    return nr_free;
} 
// create

kmem_cache_t *kmem_cache_create(const char *name, size_t size,
		void (*ctor)(void*, kmem_cache_t *, size_t),
		void (*dtor)(void*, kmem_cache_t *, size_t)){

	assert(size <= (PGSIZE -2));
	kmem_cache_t *p = kmem_cache_alloc(&(cache_cache));
	if(p != NULL)
	{
		p->objsize = size;
		p->num = PGSIZE / (sizeof(int16_t) + size);
		p->ctor = ctor;
		p->dtor = dtor;
		memcpy(p->name, name, CACHE_NAMELEN);
		list_init(&(p->slubs_full));
		list_init(&(p->slubs_part));
		list_init(&(p->slubs_free));
		list_add(&(cache_chain), &(p->cache_link));
	}
	return p;
}

// destory

void kmem_cache_destory(kmem_cache_t *p)
{
	list_entry_t *head,*le;
	
	head = &(p->slubs_full);
	le = list_next(head);
	while(le != head)
	{
		list_entry_t *temp = le;
		le = list_next(le);
		kmem_slub_destory(p,LE2SLUB(temp, page_link));
	}

	head = &(p->slubs_part);
        le = list_next(head);
        while(le != head)
        {
                list_entry_t *temp = le;
                le = list_next(le);
                kmem_slub_destory(p,LE2SLUB(temp, page_link));
        }

	head = &(p->slubs_free);
        le = list_next(head);
        while(le != head)
        {
                list_entry_t *temp = le;
                le = list_next(le);
                kmem_slub_destory(p,LE2SLUB(temp, page_link));
        }

	kmem_cache_free(&(cache_cache),p);
}

void *kmem_cache_alloc(kmem_cache_t *p)
{
	list_entry_t *le = NULL;

	if(!list_empty(&(p->slubs_part)))
	{
		le = list_next(&(p->slubs_part));
	}
	else
	{
		if(list_empty(&(p->slubs_free)) && kmem_cache_grow(p) == NULL)
		{
			return NULL;
		}
		le = list_next(&(p->slubs_free));
	}

	list_del(le);
	slub_t *slub = LE2SLUB(le, page_link);
	void *kva = SLUB2KVA(slub);
	int16_t *bufctl = kva;
	void *buf = bufctl + p->num;
	void *obj = buf + slub->freeoff * p->objsize;

	slub->used++;
	slub->freeoff = bufctl[slub->freeoff];

	if(slub->used == p->num)
	{
		list_add(&(p->slubs_full), le);
	}
	else
	{
		list_add(&(p->slubs_part), le);
	}

	return obj;
}

void *kmem_cache_zalloc(kmem_cache_t *p)
{
	void *obj = kmem_cache_alloc(p);
	memset(obj, 0, p->objsize);
	return obj;
}

void kmem_cache_free(kmem_cache_t *p, void *obj)
{
	void *base = page2kva(pages);
	void *kva = ROUNDDOWN(obj, PGSIZE);
	slub_t *slub = (slub_t *) &pages[(kva-base)/PGSIZE];

	int16_t *bufctl = kva;
	void *buf = bufctl + p->num;
	int offset = (obj-buf) / p->objsize;

	list_del(&(slub->slub_linklist));
	bufctl[offset] = slub->freeoff;
	slub->used--;
	slub->freeoff = offset;
	if(slub->used == 0)
	{
		list_add(&(p->slubs_free), &(slub->slub_linklist));
	}
	else
	{
		list_add(&(p->slubs_part), &(slub->slub_linklist));
	}
}

size_t kmem_cache_size(kmem_cache_t *p)
{
	return p->objsize;
}

const char *kmem_cache_name(kmem_cache_t *p)
{
	return p->name;
}

int kmem_cache_shrink(kmem_cache_t *p)
{
	int count = 0;
	list_entry_t *le = list_next(&(p->slubs_free));
	while(le != &(p->slubs_free))
	{
		list_entry_t *temp = le;
		le = list_next(le);
		kmem_slub_destory(p,LE2SLUB(temp,page_link));
		count++;
	}
	return count;
}

int kmem_cache_reap()
{
	int count = 0;
	list_entry_t *le = &(cache_chain);
	while((le = list_next(le)) != &(cache_chain))
	{
		count += kmem_cache_shrink(to_struct(le, kmem_cache_t, cache_link));
	}
	return count;
}

void *kmalloc(size_t size)
{
	assert(size <= SIZED_CACHE_MAX);
	return kmem_cache_alloc(cache_sized[kmem_sized_index(size)]);
}

void kfree(void *obj)
{
	void *base = SLUB2KVA(pages);
	void *kva = ROUNDDOWN(obj,PGSIZE);
	slub_t *slub = (slub_t *)&pages[(kva-base)/PGSIZE];
        kmem_cache_free(slub->p, obj);	
}

// test code

#define TEST_LENTH 2046
#define TEST_CTVAL 0x22
#define TEST_DTVAL 0x11
static const char *test_name = "test";
typedef struct test_obj{
	char test_member[TEST_LENTH];
}test_obj;
static void test_ctor(void* obj, kmem_cache_t *p, size_t size)
{
	char *t = obj;
	for(int i = 0; i < size; i++)
	{
		t[i] = TEST_CTVAL;
	}
}
static void test_dtor(void* obj, kmem_cache_t *p, size_t size)
{
        char *t = obj;
        for(int i = 0; i < size; i++)
        {
                t[i] = TEST_DTVAL;
        }
}
static size_t list_length(list_entry_t *listelm)
{
	size_t len = 0;
	list_entry_t *le = listelm;
	while((le = list_next(le)) != listelm)
	{
		len++;
	}
	return len;
}

static void check_kmem()
{
	assert(sizeof(struct Page) == sizeof(struct slub_t));
	size_t fp = nr_free_pages();
	// create
	kmem_cache_t *cp0 = kmem_cache_create(test_name, (size_t)sizeof(test_obj), test_ctor, test_dtor);
	assert(cp0 != NULL);
	assert(kmem_cache_size(cp0) == sizeof(test_obj));
	assert(strcmp(kmem_cache_name(cp0), test_name) == 0);
	// Allocate six objects
	test_obj *p0,*p1,*p2,*p3,*p4,*p5;
	char *p;
	assert((p0 = kmem_cache_alloc(cp0)) != NULL);
	assert((p1 = kmem_cache_alloc(cp0)) != NULL);
	assert((p2 = kmem_cache_alloc(cp0)) != NULL);
	assert((p3 = kmem_cache_alloc(cp0)) != NULL);
	assert((p4 = kmem_cache_alloc(cp0)) != NULL);
	assert((p5 = kmem_cache_alloc(cp0)) != NULL);
	
	p = (char*) p4;
	for (int i = 0; i < sizeof(test_obj); i++)
	{
		assert(p[i] == TEST_CTVAL);
	}

	p = (char*) p5;
	for (int i = 0; i < sizeof(test_obj); i++)
	{
		assert(p[i] == 0);
	}

	assert(nr_free_pages()+3 == fp);
	assert(list_empty(&(cp0->slubs_free)));
	assert(list_empty(&(cp0->slubs_part)));
	assert(list_empty(&(cp0->slubs_full)));

	// Free three
	kmem_cache_free(cp0,p3);
	kmem_cache_free(cp0,p4);
	kmem_cache_free(cp0,p5);

	assert(list_length(&(cp0->slubs_free)) == 1);
	assert(list_length(&(cp0->slubs_part)) == 1);
	assert(list_length(&(cp0->slubs_full)) == 1);

	// Shrink
	assert(kmem_cache_shrink(cp0) == 1);
	assert(nr_free_pages()+2 == fp);
	assert(list_empty(&(cp0->slubs_free)));
	p = (char *)p4;
	for(int i = 0; i < sizeof(test_obj); i++)
	{
		assert(p[i] == TEST_DTVAL);
	}

	// Reap cache
	kmem_cache_free(cp0,p0);
	kmem_cache_free(cp0,p1);
	kmem_cache_free(cp0,p2);
	assert(kmem_cache_reap() == 2);
	assert(nr_free_pages() == fp);

	// Destory a cache
	kmem_cache_destory(cp0);

	// Sized alloc
	assert((p0 = kmalloc(2048)) != NULL);
	assert(nr_free_pages()+1 == fp);
	kfree(p0);
	assert(kmem_cache_reap() == 1);
	assert(nr_free_pages() == fp);

	cprintf("check_kmem succeeded!\n");

}

// end test



void kmem_init()
{
	/*cache_cache.objsize = sizeof(kmem_cache_t);
	cache_cache.num = PGSIZE / (sizeof(int16_t) + sizeof(kmem_cache_t));
	cache_cache.ctor = NULL;
	cache_cache.dtor = NULL;
	memcpy(cache_cache.name,cache_name,CACHE_NAMELEN);
	list_init(&(cache_cache.slubs_full));
	list_init(&(cache_cache.slubs_part));
        list_init(&(cache_cache.slubs_free));
	list_init(&(cache_chain));
	list_add(&(cache_chain), &(cache_cache.cache_link));

	for(int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2)
	{
		cache_sized[i] = kmem_cache_create(sized_name, size, NULL, NULL);
	}
	
	check_kmem();*/
	list_init(&free_list);
    nr_free = 0;
}
static void kmem_init_memmap(struct Page *base, size_t size) {
    assert(size > 0);
    // Init pages
    for (struct Page *p = base; p < base + size; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
    }
    base->property = size;
    SetPageProperty(base);
    nr_free += size;
    list_add_before(&free_list, &(base->page_link));

}
const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = kmem_init,
    .init_memmap = kmem_init_memmap,
    .alloc_pages = kmem_cache_alloc,
    .free_pages = kmem_cache_free,
    .nr_free_pages = slub_nr_free_pages,
    .check =  check_kmem,
};


