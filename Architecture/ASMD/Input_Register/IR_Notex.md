# Input Register Control (IR)

## Basic Functionality

The ASMD begins in the 'Idle' state, with the Accellerator not working. Once 'w_en' is set by the outside user data can be written (State = 'Writing'). After Writing is finished no further Data can written (State 'Working'), until the Matrix-Multiplication is finished, which is indicated by the 'calc_has_finished'-Flag being set.

![](./IR.svg)

## Writing Process


- Writing starts, as soon as the User enables 'w_en'
- The 8 Collumns of the Matrix must be written 'continously' (i.e. once 'w_en' is set for this and the next 7 cycles all lines must be written ordered top to bottom)
- DATA MUST BE ORDERED COLLUMN-WISE
- Since the Matrix-Coefficients are only '8 Bit' wide, '1 Collumn' will be written each cycle
- The 4 Values must be provided according to the following grafic

![](./Input_data_setup.svg)


## Reading & Reading Process

- Reading can occur during 'BOTH' the 'Writing' and 'Working' State.
- Our Implementation must ensure data is only read after it has been written
- Because the first 4 Values are written during the Transition from 'Idle' to 'Writing' the Calculation can start immediatly


## Further Notes

- I made the Assumption, that our input Interface is 32 Bit wide