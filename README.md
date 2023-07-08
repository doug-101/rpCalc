# rpCalc

This is a simple Flutter project for a multi-platform reverse polish notation
(RPN) calculator.

## Basic Usage

If you know how to use an RPN calculator (like some Hewlett-Packard models),
you know how to use rpCalc. It stores previous results in four registers
(usually labeled X, Y, Z and T), and the numbers are entered before the
operators.

Of course the buttons can be clicked or tapped, but the quickest way to enter
numbers and the four basic operators is to use the number pad on the keyboard.
For the other keys, the name on the key can be typed (not case-sensitive). What
has been typed shows in the box below the keys. The tab key may be used to
automatically complete a partially typed command.

A few keys have unusual labels to allow them to be typed: "RCIP" is 1/X, "tn^X"
is 10^X, "R<" rolls the stack back (or down), "R>" rolls the stack forward (or
up), "x<>y" is exchange, "CLR" clears the registers, and "<-" is backspace.

A few commands ("STO", "RCL" and "PLCS") prompt for a number from zero through
nine. This number will be the memory register number or the number of decimal
places for the display.

## Options

The "OPT" button brings up a menu.  This History View shows recent calculations
in algebraic format.  The Memory View shows the contents of the ten memory
registers.  The Settings brings up options to remember window size/position,
and a view scale ratio to enlarge the text in auxiliary views on high-dpi
screens.
