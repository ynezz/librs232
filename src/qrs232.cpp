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

#include "librs232/qrs232.h"

QRS232::QRS232()
{
	m_open = false;
}

QRS232::~QRS232()
{
	close();
}

bool QRS232::isOpen()
{
	return m_open;
}

bool QRS232::open(QString & port, enum rs232_baud_e baud)
{
	m_port = rs232_init();
	rs232_set_device(m_port, port.toLatin1().data());
	rs232_set_baud(m_port, baud);
	unsigned int ret = rs232_open(m_port);
	if (ret == RS232_ERR_NOERROR) {
		m_open = true;
		return true;
	}

	return false;
}

QString QRS232::readTimeout(int max, int timeout)
{
	unsigned int len = 0;
	unsigned char *buf = (unsigned char *)malloc(max+1);
	if (buf == NULL)
		return QString();

	memset(buf, 0, max+1);
	unsigned int ret = rs232_read_timeout(m_port, buf, max, &len, timeout);
	if ((ret == RS232_ERR_NOERROR) && (len > 0)) {
		QString data = QString::fromLatin1((const char *)buf, len);
		free(buf);
		return data;
	}

	free(buf);
	return QString();
}

void QRS232::close()
{
	rs232_close(m_port);
	m_open = false;
	m_port = NULL;
}
