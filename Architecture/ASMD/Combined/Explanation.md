# Read ASMD

- READ: 1 Bit, set by User to indicate a read process
- r_in_ram_addr: 5 Bit, set by user to indicate which matix should be read
- o_reg: 18 Bit register, stores one RAM-Value and splits it into two
- read_upper_half: 1 Bit, stores whether the lower or the upper half of o_reg should be sent to the output
- d_out: 9 Bit, data out
- ram_read_counter: 4 Bit, internal, stores which line is read from ram (i.e. offset)

# Calc ASMD

- START: 1 Bit, set by user to indicate start of writing and calculation
- FINISH: 1 Bit, indicates that calc has finished
- in_counter: 5 Bit, stores how many values have already been sent to the Input Registers
- calc_counter: 2 Bit, stores which output-collumn is currently being worked on
- w_ram_base_addr: 5 Bit, stores to which RAM-Slot the output should be written to
- select_second: 1 Bit, indicates whether the first or second coefficient of the ROM-Value should be loaded
- i_1 ... i_4: 8 Bit each, input to the multiplier
- offset: 4 Bit?, stores which value of the ROM is read
- read_counter: 5 Bit, stores which Input-Values are read
- ram_counter: 2 Bit, forms part of the RAM-Adress, the output is written to