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

#ifndef __LIBRS232_LOG_H__
#define __LIBRS232_LOG_H__

#include <stdarg.h>
#include "librs232/rs232.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
void rs232_log_stderr(struct rs232_port_t *p, int priority, const char *file, int line, const char *fn, const char *format, va_list args)
		      __attribute__ ((format (printf, 6, 0)));
void rs232_log(struct rs232_port_t *p, int priority, const char *file, int line, const char *fn, const char *format, ...)
	       __attribute__((format(printf, 6, 7)));
static inline void __attribute__((always_inline, format(printf, 2, 3)))
rs232_log_null(struct rs232_port_t *p, const char *format, ...) { (void) p; (void) format; }
#else
void rs232_log_stderr(struct rs232_port_t *p, int priority, const char *file, int line, const char *fn, const char *format, va_list args);
void rs232_log(struct rs232_port_t *p, int priority, const char *file, int line, const char *fn, const char *format, ...);
static inline void rs232_log_null(struct rs232_port_t *p, const char *format, ...) {}
#endif

#define rs232_log_cond(p, prio, ...) \
	do { \
		if (rs232_get_log_priority(p) >= prio) \
			rs232_log(p, prio, __FILE__, __LINE__, __FUNCTION__, ## __VA_ARGS__); \
	} while (0)

#ifdef RS232_WITH_LOGGING
  #ifdef RS232_DEBUG_LOGGING
   #define dbg(p, ...) rs232_log_cond(p, RS232_LOG_DEBUG, ## __VA_ARGS__)
  #else
   #define dbg(p, ...) rs232_log_null(p, ## __VA_ARGS__)
  #endif
 #define info(p, ...) rs232_log_cond(p, RS232_LOG_INFO, ## __VA_ARGS__)
 #define err(p, ...) rs232_log_cond(p, RS232_LOG_ERR, ## __VA_ARGS__)
#else
 #define dbg(p, ...) rs232_log_null(p, ## __VA_ARGS__)
 #define info(p, ...) rs232_log_null(p, ## __VA_ARGS__)
 #define err(p, ...) rs232_log_null(p, ## __VA_ARGS__)
#endif

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* __LIBRS232_LOG_H__ */
