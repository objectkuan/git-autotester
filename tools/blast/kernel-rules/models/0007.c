#include <verifier/rcv.h>

void ldv_check_return_value(int res) {
	ldv_assert(res<=0);
}
