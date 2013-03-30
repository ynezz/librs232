/*
 * Copyright (c) 2013 Petr Stetiar <ynezz@true.cz>, Gaben Ltd.
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

#pragma once

#include "librs232/rs232.h"

#ifdef __GNUC__
typedef void (*rs232_log_fn)(struct rs232_port_t *p, int priority, const char *file,
			     int line, const char *fn, const char *format, va_list args)
			     __attribute__ ((format (printf, 6, 0)));
#else
typedef void (*rs232_log_fn)(struct rs232_port_t *p, int priority, const char *file,
			     int line, const char *fn, const char *format, va_list args);
#endif

struct rs232_port_t {
	char *device;
	void *pt; /* platform specific stuff */
	void *userdata;
#ifdef RS232_WITH_LOGGING
	rs232_log_fn log_fn;
	int log_priority;
#endif
	enum rs232_baud_e baud;
	enum rs232_data_e data;
	enum rs232_stop_e stop;
	enum rs232_flow_e flow;
	enum rs232_parity_e parity;
	enum rs232_status_e status;
	enum rs232_dtr_e dtr;
	enum rs232_rts_e rts;
};

const char * rs232_hex_dump(const void *data, unsigned int len);
const char * rs232_ascii_dump(const void *data, unsigned int len);

