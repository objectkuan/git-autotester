#include <linux/kernel.h>
#include <linux/spinlock.h>

#include <verifier/rcv.h>

/*
CONFIG_DEBUG_SPINLOCK should be true
make menuconfig
Kernel hacking->Kernel debugging->Spinlock and rw-lock debugging: basic checks
*/
extern unsigned long ldv_spin_lock_irqsave(spinlock_t *lock);
extern void ldv_spin_unlock_irqrestore(spinlock_t *lock, unsigned long flags);
extern void ldv_spin_lock(spinlock_t *lock);
extern void ldv_spin_unlock(spinlock_t *lock);
extern int ldv_spin_trylock(spinlock_t *lock);

/* This is added since in the latest kernels (for example 2.6.33.4) the internal
 * function names (that are used since the API is in the macro form) are changed. */
extern unsigned long ldv_raw_spin_lock_irqsave(raw_spinlock_t *lock);
extern void ldv_raw_spin_unlock_irqrestore(raw_spinlock_t *lock, unsigned long flags);
extern void ldv_raw_spin_lock(raw_spinlock_t *lock);
extern void ldv_raw_spin_unlock(raw_spinlock_t *lock);
extern int ldv_raw_spin_trylock(raw_spinlock_t *lock);

/* in case if aspect is off */
#ifdef spin_lock
/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='_spin_lock_irqsave') Acquires the lock and checks for double spin lock*/
unsigned long  _spin_lock_irqsave(spinlock_t *lock)
{
  unsigned long res;
  /* LDV_COMMENT_MODEL_FUNCTION_CALL Call core model function*/
  res = ldv_spin_lock_irqsave(lock);
  /* LDV_COMMENT_RETURN Return the corresponding value*/
  return res;
}

void  _spin_unlock_irqrestore(spinlock_t *lock, unsigned long flags)  {
	ldv_spin_unlock_irqrestore(lock, flags);
}

void _spin_lock(spinlock_t *lock) {
	ldv_spin_lock(lock);
}

void  _spin_unlock(spinlock_t *lock)  {
	ldv_spin_unlock(lock);
}

int _spin_trylock(spinlock_t *lock) {
	return ldv_spin_trylock(lock);
}
#else
/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='_raw_spin_lock_irqsave') Acquires the lock and checks for double spin lock*/
unsigned long _raw_spin_lock_irqsave(raw_spinlock_t *lock)
{
  unsigned long res;
  /* LDV_COMMENT_MODEL_FUNCTION_CALL Call core model function*/
  res = ldv_raw_spin_lock_irqsave(lock);
  /* LDV_COMMENT_RETURN Return the corresponding value*/
  return res;
}

void _raw_spin_unlock_irqrestore(raw_spinlock_t *lock, unsigned long flags)
{
  ldv_raw_spin_unlock_irqrestore(lock, flags);
}

void _raw_spin_lock(raw_spinlock_t *lock)
{
  ldv_raw_spin_lock(lock);
}

void  _raw_spin_unlock(raw_spinlock_t *lock)
{
  ldv_raw_spin_unlock(lock);
}

int _raw_spin_trylock(raw_spinlock_t *lock)
{
  return ldv_raw_spin_trylock(lock);
}
#endif

/* At the moment resources aren't used so just ignore them and call the
 * "standard" functions. */
/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_raw_spin_lock_irqsave') Acquires the lock and checks for double spin lock*/
unsigned long ldv_raw_spin_lock_irqsave(raw_spinlock_t *lock)
{
  spinlock_t *lock_stub;
  unsigned long res;
  /* LDV_COMMENT_MODEL_FUNCTION_CALL Call core model function*/
  res = ldv_spin_lock_irqsave(lock_stub);
  /* LDV_COMMENT_RETURN Return the corresponding value*/
  return res;
}

void ldv_raw_spin_unlock_irqrestore(raw_spinlock_t *lock, unsigned long flags)
{
  spinlock_t *lock_stub;
  ldv_spin_unlock_irqrestore(lock_stub, flags);
}

void ldv_raw_spin_lock(raw_spinlock_t *lock)
{
  spinlock_t *lock_stub;
  ldv_spin_lock(lock_stub);
}

void ldv_raw_spin_unlock(raw_spinlock_t *lock)
{
  spinlock_t *lock_stub;
  ldv_spin_unlock(lock_stub);
}

int ldv_raw_spin_trylock(raw_spinlock_t *lock)
{
  spinlock_t *lock_stub;
  return ldv_spin_trylock(lock_stub);
}
/* Finish addition due to the latest kernel. */

/* the function
 * long __builtin_expect(long val, long res)
 * moved to ./files/0039-blast.c
 * because it does work with aspectator
 */

/* LDV_COMMENT_MODEL_STATE Lock state*/
int ldv_lock = 1;

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock_irqsave') Acquires the lock and checks for double spin lock*/
unsigned long  ldv_spin_lock_irqsave(spinlock_t *lock)
{
 unsigned long res;
 /* LDV_COMMENT_ASSERT Lock should be in a free state*/
 ldv_assert(ldv_lock==1);
 /* LDV_COMMENT_CHANGE_STATE Goto locked state*/
 ldv_lock=2;
 /* LDV_COMMENT_OTHER Construct an arbitrary result*/
 res = ldv_undef_ulong();
 /* LDV_COMMENT_RETURN Return arbitrary values of irqs*/
 return res;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_unlock_irqrestore') Releases the lock and checks that lock was acquired before*/
void  ldv_spin_unlock_irqrestore(spinlock_t *lock, unsigned long flags)
{
 /* LDV_COMMENT_ASSERT Lock should be in a locked state*/
 ldv_assert(ldv_lock!=1);
 /* LDV_COMMENT_CHANGE_STATE Goto free state*/
 ldv_lock=1;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_lock') Acquires the lock and checks for double spin lock*/
void ldv_spin_lock(spinlock_t *lock)
{
 /* LDV_COMMENT_ASSERT Lock should be in a free state*/
 ldv_assert(ldv_lock==1);
 /* LDV_COMMENT_CHANGE_STATE Goto locked state*/
 ldv_lock=2;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_unlock') Releases the lock and checks that lock was acquired before*/
void  ldv_spin_unlock(spinlock_t *lock)
{
 /* LDV_COMMENT_ASSERT Lock should be in a locked state*/
 ldv_assert(ldv_lock!=1);
 /* LDV_COMMENT_CHANGE_STATE Goto free state*/
 ldv_lock=1;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_spin_trylock') Tryies to acquire the lock and returns one if successful*/
int ldv_spin_trylock(spinlock_t *lock)
{
 int flag;
 /* LDV_COMMENT_OTHER Construct an arbitrary flag*/
 flag = ldv_undef_int();

 /* LDV_COMMENT_OTHER If lock is free choose arbitrary action*/
 if(ldv_lock==1 && flag)
 {
   /* LDV_COMMENT_CHANGE_STATE Goto locked state*/
   ldv_lock=2;
   /* LDV_COMMENT_RETURN The lock is acquired*/
   return 1;
 }
 else
 {
   /* LDV_COMMENT_RETURN The lock is not acquired*/
   return 0;
 }
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='check_final_state') Checks that all locks were released*/
void ldv_check_final_state(void)
{
 /* LDV_COMMENT_ASSERT Lock should be in a free state*/
 ldv_assert(ldv_lock==1);
}
