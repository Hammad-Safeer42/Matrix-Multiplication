from amaranth import *




class Mul_Arr(Elaboratable):
    def __init__(self):
        NUM_MUL = self.NUM_MUL= 4
        # IO
        self.in_signals = []
        self.out_signals = []
        for i in range(NUM_MUL):
            self.in_signals.append(Signal(8,name="input_{}".format(i)))
            self.out_signals.append(Signal(8,name="output_{}".format(i)))
        self.coeff = Signal(7)        


    def elaborate(self,platform):
        m = Module()
        for i in range(self.NUM_MUL):
            m.d.comb += self.out_signals[i].eq(self.in_signals[i] * self.coeff)

        return m