/* set DEBUG_SPINLOCK */
//depends on DEBUG_KERNEL
#define CONFIG_DEBUG_KERNEL 1
//set it
#define CONFIG_DEBUG_SPINLOCK 1

#define CONFIG_SMP 1

/* unset DEBUG_LOCK_ALLOC */
//PROVE_LOCKING depends on
//#undef CONFIG_TRACE_IRQFLAGS
//selected by
#undef CONFIG_PROVE_LOCKING
//selected by
#undef CONFIG_LOCK_STAT

//unset it
#undef CONFIG_DEBUG_LOCK_ALLOC
// Some strange bool variable... It also must be undefined...
#undef CONFIG_LOCKDEP

// Issue #2875 describes a case when this's required.
#undef CONFIG_PROVE_RCU

#include "config-tracers.h"
