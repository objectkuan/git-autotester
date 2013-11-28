#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/usb.h>

//for dev_get_drvdata, dev_set_drvdata
#include <linux/device.h>

#include <verifier/rcv.h>

/* LDV_COMMENT_CHANGE_STATE Initialize allocated urb counter to zero*/
int ldv_urb_state = 0;
/* LDV_COMMENT_CHANGE_STATE Initialize allocated coherent counter to zero*/
int ldv_coherent_state = 0;

#define __ldv_alloc(the_state) \
	do {\
		/* LDV_COMMENT_OTHER Choose an arbitrary memory location*/\
		void *arbitrary_memory = ldv_undef_ptr();\
		/* LDV_COMMENT_OTHER If memory is not available*/\
		if(!arbitrary_memory) {\
			/* LDV_COMMENT_RETURN Failed to allocate memory*/\
			return NULL;\
		}\
		/* LDV_COMMENT_CHANGE_STATE Increase allocated counter*/\
		the_state += 1;\
		/* LDV_COMMENT_RETURN The memory is successfully allocated*/\
		return arbitrary_memory;\
	} while(0)

#define __ldv_free(addr_param,the_state) \
	do {\
		/* LDV_COMMENT_OTHER Now we frequently don't know that urb!=0, so*/\
		/* LDV_COMMENT_OTHER We consider only cases where urb is non zero*/\
		ldv_assume(addr_param!=0);\
		if(addr_param) {\
			/* LDV_COMMENT_ASSERT The memory must be allocated before*/\
			ldv_assert(the_state>=1);\
			/* LDV_COMMENT_CHANGE_STATE Decrease allocated counter*/\
			the_state -= 1;\
		}\
	} while(0)

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='usb_alloc_coherent') Allocates coherent memory*/
void *usb_alloc_coherent(struct usb_device *dev, size_t size,
	gfp_t mem_flags, dma_addr_t *dma) {
	__ldv_alloc(ldv_coherent_state);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='usb_free_coherent') Releases coherent memory*/
void usb_free_coherent(struct usb_device *dev, size_t size,
	void *addr, dma_addr_t dma) {
	__ldv_free(addr,ldv_coherent_state);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='usb_alloc_urb') Allocates memory for urb request*/
struct urb *usb_alloc_urb(int iso_packets, gfp_t mem_flags) {	
	__ldv_alloc(ldv_urb_state);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='usb_free_urb') Releases memory of urb request*/
void usb_free_urb(struct urb *urb) {
	__ldv_free(urb,ldv_urb_state);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_check_final_state') Check that the memory is freed at the end*/
void ldv_check_final_state(void) {
	/* LDV_COMMENT_ASSERT The urb requests must be freed at the end*/
	ldv_assert(ldv_urb_state==0);
	/* LDV_COMMENT_ASSERT The coherent memory must be freed at the end*/
	ldv_assert(ldv_coherent_state==0);
}

/*
To model usb_get_intfdata, usb_set_intfdata without aspectator we need to replace dev_get_drvdata, dev_set_drvdata
static inline void *usb_get_intfdata(struct usb_interface *intf)
{
        return dev_get_drvdata(&intf->dev);
}

static inline void usb_set_intfdata(struct usb_interface *intf, void *data)
{
        dev_set_drvdata(&intf->dev, data);
}
*/

/* 
Parametres of driver callbacks are different, hence
for now we just say that result is nonzero
*/
/* 
In 2.6.31.6 it is inline function so comment it
void *dev_get_drvdata(const struct device *dev) {
	void *data = ldv_undef_ptr();
	ldv_assume(data!=0);
	return data;
}
*/
//void dev_set_drvdata(struct device *dev, void *data) {}
