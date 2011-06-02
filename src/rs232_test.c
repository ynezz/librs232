/*
 * Copyright (c) 2011 Petr Stetiar <ynezz@true.cz>, Gaben Ltd.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

#include "librs232/rs232.h"

unsigned int err(unsigned int e);
unsigned int rs232_simple_test(void);

unsigned int err(unsigned int e)
{
	printf("%s (%s)\n", rs232_strerror(e), errno > 0 ? strerror(errno) : "");
	return e;
}

unsigned int rs232_simple_test(void)
{
	unsigned int try = 0;
	unsigned int bytes = 0;
	unsigned char data[1];
	unsigned int ret = 0;
	struct rs232_port_t *p = NULL;

	p = rs232_init();
	if (p == NULL)
		return 1;

#ifdef WIN32
	rs232_set_device(p, "COM1");
#else
	rs232_set_device(p, "/dev/ttyUSB0");
#endif
	ret = rs232_open(p);
	if (ret)
		return err(ret);

	rs232_set_baud(p, RS232_BAUD_115200);
	printf("[*] port settings: %s\n", rs232_to_string(p));

	rs232_flush(p);
	while (try++ < 10) {
		printf("%02d. [*] read: ", try);
		data[0] = 0x00;
		ret = rs232_read_timeout(p, data, 1, &bytes, 1000);
		if (ret)
			err(ret);
		else
			printf("0x%02x len: %d\n", data[0], bytes);

		data[0] = 0x05;
		bytes = 0;
		printf("%02d. [*] write: ", try);
		ret = rs232_write_timeout(p, data, 1, &bytes, 1000);
		if (ret)
			err(ret);
		else
			printf("len: %d\n", bytes);
	}

	rs232_end(p);
	return 0;
}

int main()
{
	return rs232_simple_test();
}

