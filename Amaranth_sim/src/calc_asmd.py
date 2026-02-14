from amaranth import *
from amaranth.lib import enum

class STATE(enum.Enum, shape=4):
    IDLE = 0
    WRITE_INPUT = 1
    CALC_COLLUMN = 2
    WRITE_COLLUMN = 3



class Read_ASMD(Elaboratable):

    def __init__(self):
        m = self.m = Module()

        self.ROM_BASE_ADDR = 0

        # Ports external
        self.start = Signal(name="START")   # Set when the ASIC should start working
        self.finish = Signal(name="FINISH") # Set when the calculation has finished
        self.ram_slot = Signal(range(16)) # Tells the module to which part of the RAM the results are written to
        # Ports to ireg
        self.ir_address = Signal(5)
        self.ir_write = Signal(32)
        self.ir_read = []
        for i in range(4):
            self.ir_read.append(Signal(5,name="ir_read_{}".format(i)))



        # Internal Signals
        self.input_counter = Signal(range(32),name="input_counter") # Counts how much data was written to the input register
        self.read_counter = Signal(range(8)) # Counts how much data was read from the registers (only goes up to 7, because 7 Input Values are needed for one output value)
        self.ram_counter = Signal(range(4)) # Counts up each time a valur is written to RAM (4 because 4 values per collumn)
        self.calc_counter = Signal(range(4)) # Increases for each Collumn that has been written to RAM

        self.ram_slot_register = Signal(range(32))
        self.rom_offset = Signal(range(16)) # Since there are 8x4=32 Coefficients and 2 Coefficients per ROM-Data-Block -> 16 different ROM-Lines must be accessed


        self.select_second = Signal() # Selects the upper/lower half of the ROM word, to select the first/second coefficient of that RAM-Block
        self.offset = Signal

        self.c_state = Signal(STATE,name="current_state")
        self.n_state = Signal(STATE,name="next_state")

        

    def select_next_state(self):
        m = self.m
        m.d.comb += self.n_state.eq(self.c_state)

        with m.Switch(self.c_state):
            with m.Case(STATE.IDLE):
                with m.If(self.start):
                    m.d.comb += self.n_state.eq(STATE.WRITE_INPUT)
            with m.Case(STATE.WRITE_INPUT):
                with m.If(self.input_counter == 31):
                    m.d.comb += self.n_state.eq(STATE.CALC_COLLUMN)
            with m.Case(STATE.CALC_COLLUMN):
                with m.If(self.read_counter == 7):
                    m.d.comb += self.n_state.eq(STATE.WRITE_COLLUMN)
            with m.Case(STATE.WRITE_COLLUMN):
                with m.If(self.ram_counter == 3):
                    with m.If(self.calc_counter == 3):
                        m.d.comb += self.n_state.eq(STATE.IDLE)
                    with m.Else():
                        m.d.comb += self.n_state.eq(STATE.CALC_COLLUMN)
        
        m.d.sync += self.c_state.eq(self.n_state)




        pass

    def current_state_output(self):
        m = self.m
        # Default values for comb Signals
        m.d.comb += self.finish.eq(0)
        m.d.comb += self.ir_address.eq(0)
        m.d.comb += self.ir_write.eq(0)

        with m.Switch(self.c_state):
            with m.Case(STATE.IDLE):
                m.d.sync += self.input_counter.eq(0)
                m.d.sync += self.calc_counter.eq(0)

                with m.If(self.start):
                    m.d.comb += self.ir_address.eq(self.input_counter) # for the first word this is still 0
                    m.d.comb += self.ir_write.eq(1)

                    m.d.sync += self.ram_slot_register.eq(self.ram_slot)
                    m.d.sync += self.input_counter.eq(1)

            with m.Case(STATE.WRITE_INPUT):
                m.d.comb += self.ir_address.eq(self.input_counter) # for the first word this is still 0
                m.d.comb += self.ir_write.eq(1)

                with m.If(self.input_counter == 31):
                    m.d.sync += self.rom_offset.eq(0)
                    m.d.sync += self.select_second.eq(0)
                    m.d.sync += self.read_counter.eq(0)

                    


            with m.Case(STATE.CALC_COLLUMN):
                for i in range(4):
                    pass

            with m.Case(STATE.WRITE_COLLUMN):
                pass


    def elaborate(self,platform):#
        m = Module()


        return m