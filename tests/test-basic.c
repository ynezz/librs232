#include <stdio.h>
#include <assert.h>

#include "librs232/rs232.h"

int main(void)
{
	unsigned int ret = 0;
	struct rs232_port_t *p = rs232_init();
	assert(p != NULL);

	rs232_set_device(p, "dimdum");

	ret = rs232_open(p);
	assert(ret != RS232_ERR_NOERROR);

	rs232_end(p);
	return 0;
}
