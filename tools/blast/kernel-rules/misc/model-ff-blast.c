#include <verifier/rcv.h>

void ldv_always_fail(void)
{
  ldv_assert(0);
}

void ldv_check_final_state(void) {
  ldv_always_fail();
}

