from amaranth import *



class IReg(Elaboratable):


    def __init__(self):

        # Input
        self.in_data = Signal(8)
        self.in_addr = Signal(5)
        self.in_write = Signal()

        # Output
        self.out_data = []
        self.out_addr = []
        for i in range(4):
            self.out_addr.append(Signal(5,name="out_addr:{}".format(i)))
            self.out_data.append(Signal(8,name="out_data_{}".format(i)))
        
    

    
    def elaborate(self,platform):
        m = Module()
        buffer = []
        for i in range(32):
            buffer.append(Signal(8,name="buffer_{}".format(i)))
        
        # in case of input (sync)
        for i in range(32):
            with m.If((self.in_addr == i) & (self.in_write == 1)):
                m.d.sync += buffer[i].eq(self.in_data)



        # in case of output (comb)
        for i in range(4):
            m.d.comb += self.out_data[i].eq(buffer[0])

        for i in range(32):
            for j in range(4):
                with m.If(self.out_addr[j] == i):
                    m.d.comb += self.out_data[j].eq(buffer[i])



        return m