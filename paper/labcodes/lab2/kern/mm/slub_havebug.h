#ifndef __KERN_MM_SLUB_H__
#define __KERN_MM_SLUB_H__

#include <pmm.h>
#include <list.h>

#define CACHE_NAMELEN 16

extern const struct pmm_manager slub_pmm_manager;

typedef struct kmem_cache_t{
	list_entry_t slubs_full;
	list_entry_t slubs_part;
	list_entry_t slubs_free;

	uint16_t objsize;
	uint16_t num;

	void (*ctor)(void *, struct kmem_cache_t *, size_t);
	void (*dtor)(void *, struct kmem_cache_t *, size_t);

	char name[CACHE_NAMELEN];
	list_entry_t cache_link;

}kmem_cache_t;

kmem_cache_t* kmem_cache_create(const char *name, size_t size, 
		void (*ctor)(void*, kmem_cache_t*, size_t),
	   	void (*dtor)(void*, kmem_cache_t*, size_t));

void kmem_cache_destory(kmem_cache_t *p);
void *kmem_cache_alloc(kmem_cache_t *p);
void *kmem_cache_zalloc(kmem_cache_t *p);
void kmem_cache_free(kmem_cache_t *p,void *obj);

size_t kmem_cache_size(kmem_cache_t *p);

const char *kmem_cache_name(kmem_cache_t *p);

int kmem_cache_shrink(kmem_cache_t *p);
int kmem_cache_reap();

void *kmalloc(size_t size);
void kfree(void *obj);

size_t ksize(void *obj);

void kmem_init();

#endif /* ! __KERN_MM_SLUB_H__ */



