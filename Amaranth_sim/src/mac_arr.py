from amaranth import *


class Mac_Arr(Elaboratable):
    def __init__(self):
        NUM_MAC = self.NUM_MAC = 4
        # IO
        self.reset_registers = Signal(1)
        self.calc = Signal(1)

        self.in_signals = []
        self.out_signals = []
        for i in range(NUM_MAC):
            self.in_signals.append(Signal(15,name="input_{}".format(i)))
            self.out_signals.append(Signal(18,name="output_{}".format(i)))
        
    
    def elaborate(self,platform):
        m = Module()
        buffer_reg_arr = []
        for i in range(self.NUM_MAC):
            buffer_reg_arr.append(Signal(18,name="Buffer_reg_{}".format(i)))


        # reset
        with m.If(self.reset_registers == 1):
            for i in range(self.NUM_MAC):
                m.d.sync += buffer_reg_arr[i].eq(0)
        #calc
        with m.Elif(self.calc):
            for i in range(self.NUM_MAC):
                m.d.sync += buffer_reg_arr[i].eq(buffer_reg_arr[i] + self.in_signals[i])
        
            
            




        # Connect output:
        for i in range(self.NUM_MAC):
            m.d.comb += self.out_signals[i].eq(buffer_reg_arr[i])

        return m