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

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "librs232/rs232.h"
#include "librs232/rs232-private.h"
#include "librs232/log.h"

void
rs232_log(struct rs232_port_t *p, int priority, const char *file,
	       int line, const char *fn, const char *format, ...)
{
	va_list args;

	va_start(args, format);
	p->log_fn(p, priority, file, line, fn, format, args);
	va_end(args);
}

void
rs232_log_stderr(struct rs232_port_t *p, int priority, const char *file,
		 int line, const char *fn, const char *format, va_list args)
{
	/* unused */
	(void) p;
	(void) file;
	(void) line;
	(void) priority;

	fprintf(stderr, "librs232: %s[%d]: ", fn, line);
	vfprintf(stderr, format, args);
}

void
rs232_set_log_fn(struct rs232_port_t *p, void (*log_fn)(struct rs232_port_t *p,
		 int priority, const char *file, int line, const char *fn,
		 const char *format, va_list args))
{
	p->log_fn = log_fn;
}

int
rs232_get_log_priority(struct rs232_port_t *p)
{
	return p->log_priority;
}

void
rs232_set_log_priority(struct rs232_port_t *p, int priority)
{
	p->log_priority = priority;
}

