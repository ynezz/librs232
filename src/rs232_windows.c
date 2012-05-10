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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef UNDER_CE
#include <errno.h>
#endif

#include "librs232/rs232.h"

static wchar_t *
a2w(const char *astr)
{
	size_t len = 0;
	wchar_t *ret = NULL;

	if (astr == NULL)
		return NULL;

	len = strlen(astr);
	if (len > 0) {
		ret = (wchar_t*)malloc((len*2)+1 * sizeof(wchar_t*));
		memset(ret, 0, (len*2));
		MultiByteToWideChar(CP_ACP, 0, astr, -1, ret, (int)len);
		ret[len] = '\0';
	} else
		ret = NULL;

	return ret;
}

static char * last_error(void)
{
	unsigned long err = 0;
	unsigned long ret = 0;
	static char errbuf[MAX_PATH+1] = {0};
	static char retbuf[MAX_PATH+1] = {0};

	err = GetLastError();
	ret = FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, NULL, err, 0, errbuf, MAX_PATH, NULL);
	if (ret != 0) {
		/* CRLF fun */
		errbuf[ret-2] = 0;
		snprintf(retbuf, MAX_PATH, "LastError: %s (%d)", errbuf, ret);
	}
	else
		snprintf(retbuf, MAX_PATH, "LastError: %d (FormatMessageA failed)", ret);

	return retbuf;
}

RS232_LIB struct rs232_port_t *
rs232_init(void)
{
	struct rs232_port_t *p = NULL;
	struct rs232_windows_t *wx = NULL;
	p = (struct rs232_port_t *) malloc(sizeof(struct rs232_port_t));
	if (p == NULL)
		return NULL;

	p->pt = (struct rs232_windows_t *) malloc(sizeof(struct rs232_windows_t));
	if (p->pt == NULL)
		return NULL;

	DBG("p=%p p->pt=%p\n", (void *)p, p->pt);

	memset(p->dev, 0, RS232_STRLEN_DEVICE+1);
	strncpy(p->dev, RS232_PORT_WIN32, RS232_STRLEN_DEVICE);

	p->baud = RS232_BAUD_115200;
	p->data = RS232_DATA_8;
	p->parity = RS232_PARITY_NONE;
	p->stop = RS232_STOP_1;
	p->flow = RS232_FLOW_OFF;
	p->status = RS232_PORT_CLOSED;
	p->dtr = RS232_DTR_OFF;
	p->rts = RS232_RTS_OFF;

	wx = (struct rs232_windows_t *) p->pt;
	wx->r_timeout = 500;
	wx->w_timeout = 500;
	wx->r_buffer = 1024;
	wx->w_buffer = 1024;

	return p;
}

static unsigned int
port_buffers(struct rs232_port_t *p, unsigned int rb, unsigned int wb)
{
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p rb=%d wb=%d\n", (void *)p, p->pt, rb, wb);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	if (!SetupComm(wx->fd, rb, wb)) {
		DBG("SetupComm() %s\n", last_error());
		return RS232_ERR_UNKNOWN;
	}

	wx->r_buffer = rb;
	wx->w_buffer = wb;

	return RS232_ERR_NOERROR;
}

static unsigned int
port_timeout(struct rs232_port_t *p, unsigned int rt, unsigned int wt)
{
	struct rs232_windows_t *wx = p->pt;
	COMMTIMEOUTS t;

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_TIMEOUTS(wx->fd, &t);

	t.ReadIntervalTimeout = 0;
	t.ReadTotalTimeoutMultiplier = 0;
	t.ReadTotalTimeoutConstant = rt;
	t.WriteTotalTimeoutMultiplier = 0;
	t.WriteTotalTimeoutConstant = wt;

	SET_PORT_TIMEOUTS(wx->fd, &t);

	wx->w_timeout = wt;
	wx->r_timeout = rt;

	return RS232_ERR_NOERROR;
}

RS232_LIB void
rs232_end(struct rs232_port_t *p)
{
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p\n", (void *)p, p->pt);

	if (!rs232_port_open(p)) {
		free(p->pt);
		free(p);
		return;
	}

	rs232_flush(p);

	if (!SetCommState(wx->fd, &wx->old_dcb)) {
		DBG("SetCommState() %s\n", last_error());
		return;
	}

	if (!SetCommTimeouts(wx->fd, &wx->old_tm)) {
		DBG("SetCommTimeouts() %s\n", last_error());
		return;
	}

	rs232_close(p);
	free(p->pt);
	free(p);
}

RS232_LIB unsigned int
rs232_in_qeue(struct rs232_port_t *p, unsigned int *in_bytes)
{
	COMSTAT cs;
	unsigned long errmask = 0;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p\n", (void *)p, p->pt);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	if (!ClearCommError(wx->fd, &errmask, &cs)) {
		DBG("ClearCommError() %s\n", last_error());
		return RS232_ERR_IOCTL;
	}

	*in_bytes = cs.cbInQue;
	DBG("in_bytes=%d\n", cs.cbInQue);

	return RS232_ERR_NOERROR;
}

/* some USB<->RS232 converters buffer a lot, so this function tries to discard
   this buffer - useful mainly after rs232_open() */
RS232_LIB void
rs232_in_qeue_clear(struct rs232_port_t *p)
{
	/* TODO */
	UNREFERENCED_PARAMETER(p);
	DBG("%s\n", "sorry, not implemented yet");
}

RS232_LIB unsigned int
rs232_read(struct rs232_port_t *p, unsigned char *buf, unsigned int buf_len,
	   unsigned int *read_len)
{
	unsigned int r = 0;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p buf_len:%d\n", (void *)p, p->pt, buf_len);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	if (!ReadFile(wx->fd, buf, buf_len, &r, NULL)) {
		*read_len = 0;
		DBG("ReadFile() %s\n", last_error());
		return RS232_ERR_READ;
	}

	*read_len = r;
	DBG("read_len=%d hex='%s' ascii='%s'\n", r, rs232_hex_dump(buf, r),
		rs232_ascii_dump(buf, r));

	return RS232_ERR_NOERROR;
}

/* this function waits either for timeout or buf_len bytes,
   whatever happens first and doesn't return earlier */
RS232_LIB unsigned int
rs232_read_timeout_forced(struct rs232_port_t *p, unsigned char *buf,
		   unsigned int buf_len, unsigned int *read_len,
		   unsigned int timeout)
{
	UNREFERENCED_PARAMETER(p);
	UNREFERENCED_PARAMETER(buf);
	UNREFERENCED_PARAMETER(timeout);
	UNREFERENCED_PARAMETER(read_len);
	UNREFERENCED_PARAMETER(buf_len);

	/* TODO */
	DBG("%s\n", "sorry, not implemented yet");
	return RS232_ERR_UNKNOWN;
}

RS232_LIB unsigned int
rs232_read_timeout(struct rs232_port_t *p, unsigned char *buf,
		   unsigned int buf_len, unsigned int *read_len,
		   unsigned int timeout)
{
	unsigned int r = 0;
	struct rs232_windows_t *wx = p->pt;
	unsigned int rt = wx->r_timeout;

	DBG("p=%p p->pt=%p buf_len: %d timeout: %d\n", (void *)p, p->pt, buf_len, timeout);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	*read_len = 0;

	if (port_timeout(p, timeout, wx->w_timeout))
		return RS232_ERR_UNKNOWN;

	if (!ReadFile(wx->fd, buf, buf_len, &r, NULL)) {
		*read_len = 0;
		DBG("ReadFile() %s\n", last_error());
		return RS232_ERR_READ;
	}

	if (port_timeout(p, rt, wx->w_timeout))
		return RS232_ERR_UNKNOWN;

	*read_len = r;
	DBG("read_len=%d hex='%s' ascii='%s'\n", r, rs232_hex_dump(buf, r),
	    rs232_ascii_dump(buf, r));

	/* TODO - This is lame, since we rely on the fact, that if we read 0 bytes,
	 * that the read probably timeouted. So we should rather measure the reading
	 * interval or rework it using overlapped I/O */
	return *read_len == 0 ? RS232_ERR_TIMEOUT : RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_write(struct rs232_port_t *p, unsigned char *buf, unsigned int buf_len,
		unsigned int *write_len)
{
	unsigned int w = 0;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p buf_len:%d\n", (void *)p, p->pt, buf_len);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	if (!WriteFile(wx->fd, buf, buf_len, &w, NULL)) {
		*write_len = 0;
		DBG("WriteFile() %s\n", last_error());
		return RS232_ERR_WRITE;
	}

	if (buf_len != w)
		DBG("WriteFile() %s\n", last_error());

	*write_len = w;
	DBG("write_len=%d hex='%s' ascii='%s'\n", w, rs232_hex_dump(buf, w),
	    rs232_ascii_dump(buf, w));

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_write_timeout(struct rs232_port_t *p, unsigned char *buf,
			unsigned int buf_len, unsigned int *write_len,
			unsigned int timeout)
{
	unsigned int w = 0;
	struct rs232_windows_t *wx = p->pt;
	unsigned int wt = wx->w_timeout;

	DBG("p=%p p->pt=%p buf_len:%d\n", (void *)p, p->pt, buf_len);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	if (port_timeout(p, wx->r_timeout, timeout))
		return RS232_ERR_UNKNOWN;

	if (!WriteFile(wx->fd, buf, buf_len, &w, NULL)) {
		*write_len = 0;
		DBG("WriteFile() %s\n", last_error());
		return RS232_ERR_WRITE;
	}

	if (port_timeout(p, wx->r_timeout, wt))
		return RS232_ERR_UNKNOWN;

	*write_len = w;
	DBG("write_len=%d hex='%s' ascii='%s'\n", w, rs232_hex_dump(buf, w),
	    rs232_ascii_dump(buf, w));

	return RS232_ERR_NOERROR;
}

static char *
fix_device_name(char *device)
{
	char *s = device;
	static char ret[RS232_STRLEN_DEVICE+1] = {0};

	while (*s && !isdigit(*s))
		s++;

	if (s && (atoi(s) > 0)) {
		snprintf(ret, RS232_STRLEN_DEVICE, "\\\\.\\COM%s", s);
		return ret;
	}

	return device;
}

RS232_LIB unsigned int
rs232_open(struct rs232_port_t *p)
{
	wchar_t *wname = a2w(fix_device_name(p->dev));
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p name='%s' fix='%s'\n",
	    (void *)p, p->pt, p->dev, fix_device_name(p->dev));

	if (wname == NULL)
		return RS232_ERR_UNKNOWN;

	wx->fd = CreateFile(wname, GENERIC_READ | GENERIC_WRITE,
			    FILE_SHARE_READ | FILE_SHARE_WRITE,
			    NULL, OPEN_EXISTING, 0, NULL);

	if (wname)
		free(wname);

	if (wx->fd == INVALID_HANDLE_VALUE) {
		DBG("CreateFile() %s\n", last_error());
		return RS232_ERR_OPEN;
	}

	p->status = RS232_PORT_OPEN;
	rs232_flush(p);

	GET_PORT_STATE(wx->fd, &wx->old_dcb);
	GET_PORT_TIMEOUTS(wx->fd, &wx->old_tm);

	port_timeout(p, wx->r_timeout, wx->w_timeout);
	port_buffers(p, wx->r_buffer, wx->w_buffer);

	rs232_set_baud(p, p->baud);
	rs232_set_data(p, p->data);
	rs232_set_parity(p, p->parity);
	rs232_set_stop(p, p->stop);
	rs232_set_flow(p, p->flow);

	return RS232_ERR_NOERROR;
}

RS232_LIB void
rs232_set_device(struct rs232_port_t *p, char *device)
{
	DBG("p=%p old=%s new=%s\n", (void *)p, p->dev, device);
	strncpy(p->dev, device, RS232_STRLEN_DEVICE);

	return;
}

RS232_LIB unsigned int
rs232_set_baud(struct rs232_port_t *p, enum rs232_baud_e baud)
{
	DCB pdcb;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p baud=%d (%s bauds)\n",
	    (void *)p, p->pt, baud, rs232_strbaud(baud));

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_STATE(wx->fd, &pdcb);

	switch (baud) {
	case RS232_BAUD_300:
		pdcb.BaudRate = CBR_300;
		break;
	case RS232_BAUD_2400:
		pdcb.BaudRate = CBR_2400;
		break;
	case RS232_BAUD_4800:
		pdcb.BaudRate = CBR_4800;
		break;
	case RS232_BAUD_9600:
		pdcb.BaudRate = CBR_9600;
		break;
	case RS232_BAUD_19200:
		pdcb.BaudRate = CBR_19200;
		break;
	case RS232_BAUD_38400:
		pdcb.BaudRate = CBR_38400;
		break;
	case RS232_BAUD_57600:
		pdcb.BaudRate = CBR_57600;
		break;
	case RS232_BAUD_115200:
		pdcb.BaudRate = CBR_115200;
		break;
	case RS232_BAUD_460800:
		pdcb.BaudRate = CBR_460800;
		break;
	default:
		return RS232_ERR_UNKNOWN;
	}

	SET_PORT_STATE(wx->fd, &pdcb);
	p->baud = baud;

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_set_dtr(struct rs232_port_t *p, enum rs232_dtr_e state)
{
	DCB pdcb;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p dtr=%d (dtr control %s)\n",
	    (void *)p, p->pt, state, rs232_strdtr(state));

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_STATE(wx->fd, &pdcb);

	switch (state) {
	case RS232_DTR_OFF:
		pdcb.fDtrControl = DTR_CONTROL_DISABLE;
		break;
	case RS232_DTR_ON:
		pdcb.fDtrControl = DTR_CONTROL_ENABLE;
		break;
	default:
		return RS232_ERR_UNKNOWN;
	}

	SET_PORT_STATE(wx->fd, &pdcb);
	p->dtr = state;

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_set_rts(struct rs232_port_t *p, enum rs232_rts_e state)
{
	DCB pdcb;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p rts=%d (rts control %s)\n",
	    (void *)p, p->pt, state, rs232_strrts(state));

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_STATE(wx->fd, &pdcb);

	switch (state) {
	case RS232_DTR_OFF:
		pdcb.fRtsControl = RTS_CONTROL_DISABLE;
		break;
	case RS232_DTR_ON:
		pdcb.fRtsControl = RTS_CONTROL_ENABLE;
		break;
	default:
		return RS232_ERR_UNKNOWN;
	}

	SET_PORT_STATE(wx->fd, &pdcb);
	p->rts = state;

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_set_parity(struct rs232_port_t *p, enum rs232_parity_e parity)
{
	DCB pdcb;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p parity=%d (parity %s)\n",
	    (void *)p, p->pt, parity, rs232_strparity(parity));

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_STATE(wx->fd, &pdcb);

	switch (parity) {
	case RS232_PARITY_NONE:
		pdcb.Parity = NOPARITY;
		break;
	case RS232_PARITY_ODD:
		pdcb.Parity = ODDPARITY;
		break;
	case RS232_PARITY_EVEN:
		pdcb.Parity = EVENPARITY;
		break;
	default:
		return RS232_ERR_UNKNOWN;
	}

	SET_PORT_STATE(wx->fd, &pdcb);
	p->parity = parity;

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_set_stop(struct rs232_port_t *p, enum rs232_stop_e stop)
{
	DCB pdcb;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p stop=%d (%s stop bits)\n",
	    (void *)p, p->pt, stop, rs232_strstop(stop));

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_STATE(wx->fd, &pdcb);

	switch (stop) {
	case RS232_STOP_1:
		pdcb.StopBits = ONESTOPBIT;
		break;
	case RS232_STOP_2:
		pdcb.StopBits = TWOSTOPBITS;
		break;
	default:
		return RS232_ERR_UNKNOWN;
	}

	SET_PORT_STATE(wx->fd, &pdcb);
	p->stop = stop;

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_set_data(struct rs232_port_t *p, enum rs232_data_e data)
{
	DCB pdcb;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p data=%d (%s data bits)\n",
	    (void *)p, p->pt, data, rs232_strdata(data));

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_STATE(wx->fd, &pdcb);

	switch (data) {
	case RS232_DATA_5:
		pdcb.ByteSize = 5;
		break;
	case RS232_DATA_6:
		pdcb.ByteSize = 6;
		break;
	case RS232_DATA_7:
		pdcb.ByteSize = 7;
		break;
	case RS232_DATA_8:
		pdcb.ByteSize = 8;
		break;
	default:
		return RS232_ERR_UNKNOWN;
	}

	SET_PORT_STATE(wx->fd, &pdcb);
	p->data = data;

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_set_flow(struct rs232_port_t *p, enum rs232_flow_e flow)
{
	DCB pdcb;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p flow=%d (flow control %s)\n",
	    (void *)p, p->pt, flow, rs232_strflow(flow));

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	GET_PORT_STATE(wx->fd, &pdcb);

	switch (flow) {
	case RS232_FLOW_OFF:
		pdcb.fOutxCtsFlow = FALSE;
		pdcb.fRtsControl = RTS_CONTROL_DISABLE;
		pdcb.fInX = FALSE;
		pdcb.fOutX = FALSE;
		break;
	case RS232_FLOW_HW:
		pdcb.fOutxCtsFlow = TRUE;
		pdcb.fRtsControl = RTS_CONTROL_HANDSHAKE;
		pdcb.fInX = FALSE;
		pdcb.fOutX = FALSE;
		break;
	case RS232_FLOW_XON_XOFF:
		pdcb.fOutxCtsFlow = FALSE;
		pdcb.fRtsControl = RTS_CONTROL_DISABLE;
		pdcb.fInX = TRUE;
		pdcb.fOutX = TRUE;
		break;
	default:
		return RS232_ERR_UNKNOWN;
	}

	SET_PORT_STATE(wx->fd, &pdcb);

	p->flow = flow;

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_flush(struct rs232_port_t *p)
{
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p\n", (void *)p, p->pt);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	if (!FlushFileBuffers(wx->fd)) {
		DBG("FlushFileBuffers() %s\n", last_error());
		return RS232_ERR_FLUSH;
	}

	if (!PurgeComm(wx->fd, PURGE_TXABORT | PURGE_RXABORT |
		       PURGE_TXCLEAR | PURGE_RXCLEAR)) {
		DBG("PurgeComm() %s\n", last_error());
		return RS232_ERR_FLUSH;
	}

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_close(struct rs232_port_t *p)
{
	int ret;
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p\n", (void *)p, p->pt);

	if (!rs232_port_open(p))
		return RS232_ERR_PORT_CLOSED;

	ret = CloseHandle(wx->fd);
	if (ret == 0) {
		DBG("PurgeComm() %s\n", last_error());
		return RS232_ERR_CLOSE;
	}

	return RS232_ERR_NOERROR;
}

RS232_LIB unsigned int
rs232_fd(struct rs232_port_t *p)
{
	struct rs232_windows_t *wx = p->pt;

	DBG("p=%p p->pt=%p wx->fd=%d\n", (void *)p, p->pt, wx->fd);

	return (unsigned int) wx->fd;
}
