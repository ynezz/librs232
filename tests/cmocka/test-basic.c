#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>

#include <librs232/rs232.h>

static void test_strerror(void **state)
{
	(void) state;
	assert_int_equal(RS232_ERR_NOERROR, 0);
	assert_int_equal(RS232_ERR_UNKNOWN, 1);
	assert_int_equal(RS232_ERR_CONFIG, 5);
	assert_null(rs232_strerror(RS232_ERR_MAX));
	assert_string_equal(rs232_strerror(RS232_ERR_UNKNOWN), "unknown error");
	assert_string_equal(rs232_strerror(RS232_ERR_FLUSH), "flush error");
	assert_string_equal(rs232_strerror(RS232_ERR_WRITE), "write error");
	assert_string_equal(rs232_strerror(RS232_ERR_PORT_CLOSED), "port closed error");
}

static void test_strbaud(void **state)
{
	(void) state;
	assert_int_equal(RS232_BAUD_300, 0);
	assert_int_equal(RS232_BAUD_19200, 4);
	assert_int_equal(RS232_BAUD_460800, 8);
	assert_null(rs232_strbaud(RS232_BAUD_MAX));
	assert_string_equal(rs232_strbaud(RS232_BAUD_2400), "2400");
	assert_string_equal(rs232_strbaud(RS232_BAUD_9600), "9600");
	assert_string_equal(rs232_strbaud(RS232_BAUD_38400), "38400");
	assert_string_equal(rs232_strbaud(RS232_BAUD_115200), "115200");
}

static void test_strdata(void **state)
{
	(void) state;
	assert_int_equal(RS232_DATA_6, 1);
	assert_int_equal(RS232_DATA_7, 2);
	assert_int_equal(RS232_DATA_8, 3);
	assert_null(rs232_strdata(RS232_DATA_MAX));
	assert_string_equal(rs232_strdata(RS232_DATA_5), "5");
	assert_string_equal(rs232_strdata(RS232_DATA_8), "8");
}

static void test_strparity(void **state)
{
	(void) state;
	assert_int_equal(RS232_PARITY_NONE, 0);
	assert_int_equal(RS232_PARITY_EVEN, 2);
	assert_null(rs232_strparity(RS232_PARITY_MAX));
	assert_string_equal(rs232_strparity(RS232_PARITY_ODD), "odd");
	assert_string_equal(rs232_strparity(RS232_PARITY_EVEN), "even");
}

static void test_strstop(void **state)
{
	(void) state;
	assert_int_equal(RS232_STOP_1, 0);
	assert_int_equal(RS232_STOP_2, 1);
	assert_null(rs232_strstop(RS232_STOP_MAX));
	assert_string_equal(rs232_strstop(RS232_STOP_1), "1");
	assert_string_equal(rs232_strstop(RS232_STOP_2), "2");
}

static void test_strflow(void **state)
{
	(void) state;
	assert_int_equal(RS232_FLOW_OFF, 0);
	assert_int_equal(RS232_FLOW_XON_XOFF, 2);
	assert_null(rs232_strflow(RS232_FLOW_MAX));
	assert_string_equal(rs232_strflow(RS232_FLOW_HW), "hardware");
	assert_string_equal(rs232_strflow(RS232_FLOW_XON_XOFF), "xon/xoff");
}

static void test_strdtr(void **state)
{
	(void) state;
	assert_int_equal(RS232_DTR_ON, 1);
	assert_int_equal(RS232_DTR_OFF, 0);
	assert_null(rs232_strdtr(RS232_DTR_MAX));
	assert_string_equal(rs232_strdtr(RS232_DTR_ON), "on");
	assert_string_equal(rs232_strdtr(RS232_DTR_OFF), "off");
}

static void test_strrts(void **state)
{
	(void) state;
	assert_int_equal(RS232_RTS_ON, 1);
	assert_int_equal(RS232_RTS_OFF, 0);
	assert_null(rs232_strrts(RS232_RTS_MAX));
	assert_string_equal(rs232_strrts(RS232_RTS_ON), "on");
	assert_string_equal(rs232_strrts(RS232_RTS_OFF), "off");
}

int main(void)
{
	const UnitTest tests[] = {
		unit_test(test_strerror),
		unit_test(test_strbaud),
		unit_test(test_strdata),
		unit_test(test_strparity),
		unit_test(test_strstop),
		unit_test(test_strflow),
		unit_test(test_strdtr),
		unit_test(test_strrts),
	};

	return run_tests(tests);
}
