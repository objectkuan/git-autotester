/* LDV_COMMENT_BEGIN_MODEL */
#include <linux/kernel.h>
#include <linux/spinlock.h>

#include <verifier/rcv.h>

/*
CONFIG_DEBUG_SPINLOCK should be true
make menuconfig
Kernel hacking->Kernel debugging->Spinlock and rw-lock debugging: basic checks
*/

/* Need this because rerouter is buggy!.. */
extern int ldv_lock_TEMPLATE;
/* Now the actual variable goes... */
int ldv_lock_TEMPLATE = 1;

#define __ldv_spin_lock() \
	do {\
		/* LDV_COMMENT_ASSERT Lock should be in a free state*/\
		ldv_assert(ldv_lock_TEMPLATE==1);\
		/* LDV_COMMENT_CHANGE_STATE Goto locked state*/\
		ldv_lock_TEMPLATE=2;\
	} while(0)

#define __ldv_spin_unlock() \
	do {\
		/* LDV_COMMENT_ASSERT Lock should be in a locked state*/\
		ldv_assert(ldv_lock_TEMPLATE!=1);\
		/* LDV_COMMENT_CHANGE_STATE Goto free state*/\
		ldv_lock_TEMPLATE=1;\
	} while(0)

#define __ldv_spin_trylock() \
	do {\
		int is_lock_held_by_another_thread;\
		/* LDV_COMMENT_OTHER Construct an arbitrary flag*/\
		is_lock_held_by_another_thread = ldv_undef_int();\
		/* LDV_COMMENT_OTHER If lock is free choose arbitrary action*/\
		if(ldv_lock_TEMPLATE==1 && is_lock_held_by_another_thread)\
		{\
			/* LDV_COMMENT_CHANGE_STATE Goto locked state*/\
			ldv_lock_TEMPLATE=2;\
			/* LDV_COMMENT_RETURN The lock is acquired*/\
			return 1;\
		}\
		else\
		{\
			/* LDV_COMMENT_RETURN The lock is not acquired*/\
			return 0;\
		}\
	} while(0)

#define __ldv_spin_checklocked(free,busy) \
	do {\
		int is_lock_held_by_another_thread;\
		/* LDV_COMMENT_OTHER Construct an arbitrary flag*/\
		is_lock_held_by_another_thread = ldv_undef_int();\
		/* LDV_COMMENT_OTHER If lock is free choose arbitrary action*/\
		if(ldv_lock_TEMPLATE==1 && is_lock_held_by_another_thread)\
		{\
			/* LDV_COMMENT_RETURN The lock is free*/\
			return free;\
		}\
		else\
		{\
			/* LDV_COMMENT_RETURN The lock is not free*/\
			return busy;\
		}\
	} while(0)

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock_irqsave(?!_nested)') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock_irqsave_TEMPLATE(spinlock_t *lock, unsigned long flags) {
	__ldv_spin_lock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock_nested') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock_nested_TEMPLATE(spinlock_t *lock, int subclass) {
	__ldv_spin_lock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock_nest_lock') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock_nest_lock_TEMPLATE(spinlock_t *lock, void *map) {
	__ldv_spin_lock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock_irqsave_nested') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock_irqsave_nested_TEMPLATE(spinlock_t *lock, unsigned long flags, int subclass) {
	__ldv_spin_lock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_trylock_irqsave(?!_nested)') Tryies to acquire the lock and returns one if successful*/
int ldv_spin_trylock_irqsave_TEMPLATE(spinlock_t *lock, unsigned long flags) {
	__ldv_spin_trylock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock(?!_bh|_irq|_irqsave|_nested|_irqsave_nested|_nest_lock)') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_lock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock_bh') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock_bh_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_lock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock_irq(?!save|save_nested)') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock_irq_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_lock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_trylock(?!_bh|_irq|_irqsave|_irqsave_nested)') Tryies to acquire the lock and returns one if successful*/
int ldv_spin_trylock_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_trylock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_trylock_bh') Tryies to acquire the lock and returns one if successful*/
int ldv_spin_trylock_bh_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_trylock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_trylock_irq(?!save|save_nested)') Tryies to acquire the lock and returns one if successful*/
int ldv_spin_trylock_irq_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_trylock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_unlock(?!_bh|_irq|_irqrestore)') Releases the lock and checks that lock was acquired before*/
void ldv_spin_unlock_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_unlock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_unlock_bh') Releases the lock and checks that lock was acquired before*/
void ldv_spin_unlock_bh_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_unlock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_unlock_irq(?!restore)') Releases the lock and checks that lock was acquired before*/
void ldv_spin_unlock_irq_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_unlock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_unlock_irqrestore') Releases the lock and checks that lock was acquired before*/
void ldv_spin_unlock_irqrestore_TEMPLATE(spinlock_t *lock, unsigned long flags) {
	__ldv_spin_unlock();
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_unlock_wait') If the some process is holding the lock then it waits until it will be released*/
void ldv_spin_unlock_wait_TEMPLATE(spinlock_t *lock) {
	/* LDV_COMMENT_ASSERT The spinlock must not be locked by the current process*/
	ldv_assert(ldv_lock_TEMPLATE==1);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_is_locked') Checks whether the lock is free or not*/
int ldv_spin_is_locked_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_checklocked(0,1);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_is_contended')*/
int ldv_spin_is_contended_TEMPLATE(spinlock_t *lock) {
	int is_lock_contended;
	/* LDV_COMMENT_OTHER Construct an arbitrary flag*/
	is_lock_contended = ldv_undef_int();
	/* LDV_COMMENT_OTHER Choose arbitrary action*/
	if(is_lock_contended)
	{
		/* LDV_COMMENT_RETURN The lock is contended*/
		return 1;
	}
	else
	{
		/* LDV_COMMENT_RETURN The lock is not contended*/
		return 0;
	}
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_can_lock') Checks whether the lock is free or not*/
int ldv_spin_can_lock_TEMPLATE(spinlock_t *lock) {
	__ldv_spin_checklocked(1,0);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_atomic_dec_and_lock') Locks on reaching reference count zero*/
int ldv_atomic_dec_and_lock_TEMPLATE(spinlock_t *lock, atomic_t *atomic) {
	int is_atomic_counter_is_one;
	/* LDV_COMMENT_OTHER Construct an arbitrary flag*/
	is_atomic_counter_is_one = ldv_undef_int();
	/* LDV_COMMENT_OTHER Choose arbitrary action*/
	if(is_atomic_counter_is_one) {
		/* LDV_COMMENT_RETURN Set counter to zero*/
		atomic_dec(atomic);
		/* LDV_COMMENT_RETURN Acquire the lock and return true*/
		__ldv_spin_lock();
		return 1;
	} else {
		/* LDV_COMMENT_RETURN Return false*/
		return 0;
	}
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_check_final_state') Check that the spinlock is unlocked at the end*/
void ldv_check_final_state_TEMPLATE(void) 
{  	
  /* LDV_COMMENT_ASSERT The spinlock must be unlocked at the end*/
  ldv_assert(ldv_lock_TEMPLATE == 1);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_initialize') Initialize spinlock variables*/
void ldv_initialize_TEMPLATE(void) 
{  	
  /* LDV_COMMENT_ASSERT Initialize spinlock with initial model value*/
  ldv_lock_TEMPLATE = 1;
}


