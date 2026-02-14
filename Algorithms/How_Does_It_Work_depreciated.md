# How Does The Algorithm Work (an attempt of an explanation)

![IMAGE MISSING](../Architecture/Schematics/Top/Total_Overview_v2.svg)

The above Image shows the full hardware (without control logic).

Every possible algorithm has to satisfy the following 3 restrictions:

- Maximum of 4 Multipliers are allowed
- Only 2 Values of the Coefficient Matrix can be read each cycle
- Only ONE Value in the Input can be loaded each cycle (From Outside into the Input Registers)

Therefore, in Order to minimize Delay and maximize throughput, the multipliers must constantly calculate, from which an algorithm can be designed

## What Do The Multipliers Caclulate?

Assume the following three Matricies:

![IMAGE MISSING](./matricies.svg)

With $A$ being the input Matrix, $C$ containing the coefficients and $O$ being the results, i.e.

$$A \times C = O$$

Written differently each output value $o_{ij}$ can be calculated as

$$o_{ij} = \sum^{8}_{r=1} a_{ir}\cdot c_{rj}$$

Unrolling all of These sums results in 16 different formulas:

$$
o11 = a11c11 + a12c21 + a13c31 + a14c41 + a15c51 + a16c61 + a17c71 + a18c81 \\

o12 = a11c12 + a12c22 + a13c32 + a14c42 + a15c52 + a16c62 + a17c72 + a18c82\\

o13 = a11c13 + a12c23 + a13c33 + a14c43 + a15c53 + a16c63 + a17c73 + a18c83\\

o14 = a11c14 + a12c24 + a13c34 + a14c44 + a15c54 + a16c64 + a17c74 + a18c84\\
$$

$$
o21 = a21c11 + a22c21 + a23c31 + a24c41 + a25c51 + a26c61 + a27c71 + a28c81
\\
o22 = a21c12 + a22c22 + a23c32 + a24c42 + a25c52 + a26c62 + a27c72 + a28c82
\\
o23 = a21c13 + a22c23 + a23c33 + a24c43 + a25c53 + a26c63 + a27c73 + a28c83
\\
o24 = a21c14 + a22c24 + a23c34 + a24c44 + a25c54 + a26c64 + a27c74 + a28c84
$$

$$
o31 = a31c11 + a32c21 + a33c31 + a34c41 + a35c51 + a36c61 + a37c71 + a38c81
\\
o32 = a31c12 + a32c22 + a33c32 + a34c42 + a35c52 + a36c62 + a37c72 + a38c82
\\
o33 = a31c13 + a32c23 + a33c33 + a34c43 + a35c53 + a36c63 + a37c73 + a38c83
\\
o34 = a31c14 + a32c24 + a33c34 + a34c44 + a35c54 + a36c64 + a37c74 + a38c84
$$

$$
o41 = a41c11 + a42c21 + a43c31 + a44c41 + a45c51 + a46c61 + a47c71 + a48c81
\\
o42 = a41c12 + a42c22 + a43c32 + a44c42 + a45c52 + a46c62 + a47c72 + a48c82
\\
o43 = a41c13 + a42c23 + a43c33 + a44c43 + a45c53 + a46c63 + a47c73 + a48c83
\\
o44 = a41c14 + a42c24 + a43c34 + a44c44 + a45c54 + a46c64 + a47c74 + a48c84
$$

Since loading a coefficient from ROM takes time, it would be benefitial to perform all multiplications that require that coefficient at the same time, so that we dont have to load the coefficient again.

Taking a closer look we can see, that each coefficient is required in 4 Multiplications. Taking $c11$ as an example: it is needed to calculate $a11c11$, $a21c11$, $a31c11$ and $a41c11$.

Therefore, if we load an coefficient we can immediatly perform ALL required multiplications (since we have 4 Multipliers, and assume that we can read 4 input values at the same time).

HOWEVER: This is not the case, as effectively we can only load 1 input value each clock-cycle, which means we have to reuse these values as well.
The optimal Solution is to wait until the first 2 Values of A are available (e.g. $a11$ and $a21$) and perform the calculations $a11c11$, $a11c12$, $a21c11$ and $a21c12$ (Note that during this cycle the next value of A $a31$ is loaded as well).

In the next cycle we can now load $c13$ and $c14$ and perform the calculations $a11c13$, $a11c14$, $a21c13$ and $a21c14$, while loading $a41$ into
memory.

Now 

## How Do The Adders Work?

The naive approach would be to use 16 adders, one for each output value ($o_{ij}$). In order to save on memory, and since each product term is only used exactly once. An arcitecture for one of those adders is given below:

![IMAGE MISSING](./adder_naive.svg)

In order for such an Implementation to work, we must ensure, that at any given time only one product term is being sent from the Multipliers. Looking at the formulas above, we can realize that this requirement is fulfilled.

As an example: The $c11$ coefficent results in 4 product-terms at the output of the multipliers ($a11c11$, $a21c11$, $a31c11$ and $a41c11$), which are needed to calculate the output $o11$, $o21$, $o31$ and $o41$ respectively.
Since each of these $o11$, ... have their own ADDER, only one product-term will be sent to them each cycle.

With that, the functionality of one such unit will be as follows:

![IMAGE MISSING](./mac_schedule.svg)

## Reducing the Number of Adder Units

Since we only have 4 Multipliers, only 4 product-terms can be supplied to the adders, which means that any given clockcycle only 4 out of 16 Adders will be working at the same time.

This Realization can be used to reduce the number of Adder-Units needed, which will be explained in the following:

First, we assume that the values of the $C$ Matrix are loaded row-wise, i.e. $c11$ will be loaded first, then $c12$, then $c13$ and finally $c14$. After that, the next line will be loaded.

Looking at the 16 formulas above, it can be seen, that during those 4 clockcycles, the first "collumn" of the 16 outputs will be generated (For further explanation, the file 'Multiplier_Schedule' shows which product values are calculated each cycle). Therefore a better architecture can be generated, wich is shown in the image below:

![IMAGE MISSING](../Architecture/Schematics/MAC_Unit/MAC_Unit_v2.svg)

With 4 of those structures each adder will be used $100%$ of the time, without bottlenecking any other part of the IC. An example Schedule for one of those structures can be seen in the following image:

![IMAGE MISSING](./mac_schedule_improved.svg)
