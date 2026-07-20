package testcase_pkg;

typedef enum logic [3:0] {
  FIXED_ADDR          = 4'b0000,
  RAND_ADDR           = 4'b0001,
  RAND_ADDR_INRANGE   = 4'b0010,
  SLAVE_0             = 4'b0011,
  SLAVE_1             = 4'b0100,
  ERROR_RESP          = 4'b0101,
  WAITING_STATE       = 4'b0110
} test_case;

endpackage: testcase_pkg