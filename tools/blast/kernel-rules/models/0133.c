/* LDV_COMMENT_BEGIN_MODEL */

/*
 * CONFIG_DEBUG_LOCK_ALLOC must be turned off to apply the given model.
 * To be independ on the value of this flag there is the corresponding
 * aspect model.
 */

#include <linux/kernel.h>
#include <linux/skbuff.h>

#include <verifier/rcv.h>

enum
{
	LDV_SKB_ZERO_STATE,	// the sk buffer is already allocated
	LDV_SKB_FREE		// the buffer has already been freed
};

/* Need this because rerouter is buggy!.. */
extern int ldv_skb_TEMPLATE;
/* Now the actual variable goes... */
int ldv_skb_TEMPLATE = LDV_SKB_ZERO_STATE;

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='kfree_skb') Check skb is not NULL. Then check it hasn't been freed already and then change the model satate. */
void kfree_skb_TEMPLATE(struct sk_buff *skb)
{
	/* LDV_COMMENT_OTHER Check skb is not NULL. */
	if (!skb)
		return;
	/* LDV_COMMENT_ASSERT Check skb hasn't already been freed. */
	ldv_assert(ldv_skb_TEMPLATE == LDV_SKB_ZERO_STATE);

	/* LDV_COMMENT_CHANGE_STATE Free the skb i.e. change the model state. */
	ldv_skb_TEMPLATE = LDV_SKB_FREE;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='consume_skb') Check skb is not NULL. Then check it hasn't been freed already and then change the model satate. */
void consume_skb_TEMPLATE(struct sk_buff *skb)
{
	/* LDV_COMMENT_OTHER Check skb is not NULL. */
	if (!skb)
		return;
	/* LDV_COMMENT_ASSERT Check skb hasn't already been freed. */
	ldv_assert(ldv_skb_TEMPLATE == LDV_SKB_ZERO_STATE);

	/* LDV_COMMENT_CHANGE_STATE Free the skb i.e. change the model state. */
	ldv_skb_TEMPLATE = LDV_SKB_FREE;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='__kfree_skb') Check skb hasn't been freed already and then change the model satate. */
void __kfree_skb_TEMPLATE(struct sk_buff *skb)
{
	/* LDV_COMMENT_ASSERT Check skb hasn't already been freed. */
	ldv_assert(ldv_skb_TEMPLATE == LDV_SKB_ZERO_STATE);

	/* LDV_COMMENT_CHANGE_STATE Free the skb i.e. change the model state. */
	ldv_skb_TEMPLATE = LDV_SKB_FREE;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_handler_precall') Model reinitialization. Sould be called before each driver handler. */
void ldv_handler_precall_TEMPLATE()
{
        /* LDV_COMMENT_CHANGE_STATE Reinitialize skb with initial model value. */
	ldv_skb_TEMPLATE = LDV_SKB_ZERO_STATE;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='skb_dequeue') Model reinitialization (actually a heuristic). */
struct sk_buff *skb_dequeue(struct sk_buff_head *list)
{
	/* LDV_COMMENT_OTHER Model reinitialization. */
	ldv_handler_precall();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='__alloc_skb') Model reinitialization (actually a heuristic). */
struct sk_buff *__alloc_skb(unsigned int size, gfp_t priority, int fclone, int node)
{
	/* LDV_COMMENT_OTHER Model reinitialization. */
	ldv_handler_precall();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='__netdev_alloc_skb') Model reinitialization (actually a heuristic). */
struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int length, gfp_t gfp_mask)
{
	/* LDV_COMMENT_OTHER Model reinitialization. */
	ldv_handler_precall();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='skb_clone') Model reinitialization (actually a heuristic). */
struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t priority)
{
	/* LDV_COMMENT_OTHER Model reinitialization. */
	ldv_handler_precall();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='debug_dma_unmap_page') Model reinitialization (actually a heuristic). */
void debug_dma_unmap_page(struct device *dev, dma_addr_t addr, size_t size, int direction, bool map_single)
{
	/* LDV_COMMENT_OTHER Model reinitialization. */
	ldv_handler_precall();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='debug_dma_map_sg') Model reinitialization (actually a heuristic). */
void debug_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents, int mapped_ents, int direction)
{
	/* LDV_COMMENT_OTHER Model reinitialization. */
	ldv_handler_precall();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_initialize') Initialize skb variables. */
void ldv_initialize_TEMPLATE(void)
{
  /* LDV_COMMENT_OTHER Initialize skb with initial model value. */
  ldv_skb_TEMPLATE = LDV_SKB_ZERO_STATE;
}

/* LDV_COMMENT_END_MODEL */
