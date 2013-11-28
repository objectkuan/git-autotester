/* LDV_COMMENT_BEGIN_MODEL */

/*
 * CONFIG_DEBUG_LOCK_ALLOC must be turned off to apply the given model.
 * To be independ on the value of this flag there is the corresponding 
 * aspect model.
 */

#include <linux/kernel.h>
#include <linux/mutex.h>
#include <linux/errno.h>
#include <verifier/rcv.h>

/* Need this because rerouter is buggy!.. */
extern int ldv_mutex_TEMPLATE;
/* Now the actual variable goes... */
int ldv_mutex_TEMPLATE = 1;

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='mutex_lock_interruptible') Check that the mutex was unlocked and nondeterministically lock it. Return the corresponding error code on fails*/
int mutex_lock_interruptible_TEMPLATE(struct mutex *lock) 
{
  int nondetermined;
  	
  /* LDV_COMMENT_ASSERT Mutex must be unlocked*/
  ldv_assert(ldv_mutex_TEMPLATE == 1);

  /* LDV_COMMENT_OTHER Construct the nondetermined result*/
  nondetermined = ldv_undef_int(); 
  
  /* LDV_COMMENT_ASSERT Nondeterministically lock the mutex*/
  if (nondetermined) 
  {
    /* LDV_COMMENT_CHANGE_STATE Lock the mutex*/
    ldv_mutex_TEMPLATE = 2;  
    /* LDV_COMMENT_RETURN Finish with success*/
    return 0;
  } 
  else 
  {
    /* LDV_COMMENT_RETURN Finish with the fail. The mutex is keeped unlocked*/
    return -EINTR;
  }
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='atomic_dec_and_mutex_lock') Lock if atomic decrement result is zero */
int atomic_dec_and_mutex_lock_TEMPLATE(atomic_t *cnt, struct mutex *lock)
{
  int atomic_value_after_dec;

  /* LDV_COMMENT_ASSERT Mutex must be unlocked (since we may lock it in this function) */
  ldv_assert(ldv_mutex_TEMPLATE == 1);

  /* LDV_COMMENT_OTHER Assign the result of atomic decrement */
  atomic_value_after_dec = ldv_undef_int();

  /* LDV_COMMENT_ASSERT Check if atomic decrement returns zero */
  if (atomic_value_after_dec == 0)
  {
    /* LDV_COMMENT_CHANGE_STATE Lock the mutex, as atomic has decremented to zero*/
    ldv_mutex_TEMPLATE = 2;
    /* LDV_COMMENT_RETURN Return 1 with a locked mutex */
    return 1;
  }

  /* LDV_COMMENT_RETURN Atomic decrement is still not zero, return 0 without locking the mutex */
  return 0;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='mutex_lock_killable') Check that the mutex wasn unlocked and nondeterministically lock it. Return the corresponding error code on fails*/
int __must_check mutex_lock_killable_TEMPLATE(struct mutex *lock) 
{  	
  int nondetermined;
  	
  /* LDV_COMMENT_ASSERT Mutex must be unlocked*/
  ldv_assert(ldv_mutex_TEMPLATE == 1);

  /* LDV_COMMENT_OTHER Construct the nondetermined result*/
  nondetermined = ldv_undef_int(); 
  
  /* LDV_COMMENT_ASSERT Nondeterministically lock the mutex*/  
  if (nondetermined) 
  { 
    /* LDV_COMMENT_CHANGE_STATE Lock the mutex*/
    ldv_mutex_TEMPLATE = 2;
    /* LDV_COMMENT_RETURN Finish with success*/
    return 0;
  } 
  else 
  {
    /* LDV_COMMENT_RETURN Finish with the fail. The mutex is keeped unlocked*/
    return -EINTR;
  }
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='mutex_is_locked') Checks whether the mutex is locked*/
int mutex_is_locked_TEMPLATE(struct mutex *lock)
{  
	int nondetermined;
  	
	if(ldv_mutex_TEMPLATE == 1) {
		/* LDV_COMMENT_OTHER Construct the nondetermined result*/
		nondetermined = ldv_undef_int(); 
		if(nondetermined) {
	    		/* LDV_COMMENT_RETURN the mutex is unlocked*/
			return 0;
		} else {
    			/* LDV_COMMENT_RETURN the mutex is locked*/
			return 1;
		}
	} else {
    		/* LDV_COMMENT_RETURN the mutex is locked*/
		return 1;
	}
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='mutex_lock(?!_interruptible|_killable)') Check that the mutex was not locked and lock it*/
void mutex_lock_TEMPLATE(struct mutex *lock)
{  	
  /* LDV_COMMENT_ASSERT Mutex must be unlocked*/
  ldv_assert(ldv_mutex_TEMPLATE == 1);
  /* LDV_COMMENT_CHANGE_STATE Lock the mutex*/
  ldv_mutex_TEMPLATE = 2;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='mutex_trylock') Check that the mutex was not locked and nondeterministically lock it. Return 0 on fails*/
int mutex_trylock_TEMPLATE(struct mutex *lock) 
{  	
  int is_mutex_held_by_another_thread;
  	
  /* LDV_COMMENT_ASSERT Mutex must be unlocked*/
  ldv_assert(ldv_mutex_TEMPLATE == 1);

  /* LDV_COMMENT_OTHER Construct the nondetermined result*/
  is_mutex_held_by_another_thread = ldv_undef_int(); 
  
  /* LDV_COMMENT_ASSERT Nondeterministically lock the mutex*/  
  if (is_mutex_held_by_another_thread) 
  {
    /* LDV_COMMENT_RETURN Finish with fail*/
    return 0;
  }
  else 
  {  
    /* LDV_COMMENT_CHANGE_STATE Lock the mutex*/
    ldv_mutex_TEMPLATE = 2;
    /* LDV_COMMENT_RETURN Finish with success*/
    return 1;
  } 
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='mutex_unlock') Check that the mutex was locked and unlock it*/
void mutex_unlock_TEMPLATE(struct mutex *lock) 
{  	
  /* LDV_COMMENT_ASSERT Mutex must be locked*/
  ldv_assert(ldv_mutex_TEMPLATE == 2);
  /* LDV_COMMENT_CHANGE_STATE Unlock the mutex*/
  ldv_mutex_TEMPLATE = 1;
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='check_final_state') Check that the mutex is unlocked at the end*/
void ldv_check_final_state_TEMPLATE(void) 
{  	
  /* LDV_COMMENT_ASSERT The mutex must be unlocked at the end*/
  ldv_assert(ldv_mutex_TEMPLATE == 1);
}

/* LDV_COMMENT_MODEL_FUNCTION_DEFINITION(name='ldv_initialize') Initialize mutex variables*/
void ldv_initialize_TEMPLATE(void) 
{  	
  /* LDV_COMMENT_ASSERT Initialize mutex with initial model value*/
  ldv_mutex_TEMPLATE = 1;
}

/* LDV_COMMENT_END_MODEL */
