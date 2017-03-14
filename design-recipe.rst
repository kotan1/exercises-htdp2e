Design Recipe
=============

1.- Define information as data
------------------------------
Choose how to represent the information of the world as data.

For instance::

    ; Name is a String
    ; Age is a Number
    ; Finished is a Boolean
    ; Temperature is a Number larger than -274

Data definitions can be:
- A primitive type (Number, String, Boolean, etc)
- A structure (which may be based on other structures)
- An enumeration ("red", "orange" or "green")
- An interval (Number > -273)
- An itemization (combination of distinct previous elements: e.g. Number OR Boolean)


2.- Write function(s) signature, purpose and function header
------------------------------------------------------------
A function signature is a description of what data the function consumes, 
and what data it produces.

Examples::

    ; String -> Number
    ; Image String -> Image

The purpose is just a summary of what the function does

Examples::

    ; Returns the length of the string
    ; Returns a image with the passed text

Finally, a header is just a simple function that returns a constant value
of the class as defined in the signature

Examples::

    (define (string-length str) 0)  ; 0 is the dummy value


3.- Give some input/output examples
-----------------------------------
Write the expected outputs for a set of give inputs. Basically, write unit tests.
Those can be done with ``check-expect``. For instance, if we were working on a 
function to sum two numbers::

    ; Number Number -> Number
    ; sums two numbers

    (check-expect (sum-2-nums 1 1) 2)
    (check-expect (sum-2-nums 2 3) 5)


4.- Take inventory
------------------
Create some sort of template of what the body of the function should be.
For instance, we know the input for a function that calculates the area 
of an square, and we kinda know that we have to pass this value to another
function to actually calculate it, and maybe another argument. Thus, we
can use ``...`` as a placeholder for something that has to be implemented later.

::

    (define (square-area side)
      (... side ...))


If any of the inputs is an enumeration, interval or itemization, a check for
each posible case has to be created in the template. For instance, a function
to calculate the state of the water depending on its temperature could look
like this::

    ; Temperature -> String
    ; Returns a string describing the state of the water
    (define (water-state temp)
      (cond 
        [...condition frozen... ...value when frozen...]
        [...condition liquid... ...value when liquid]
        [...condition gas... ...value when gas]))

If the argument is an itemization of structures, it is probably a good idea to 
use data selectors here to prevent other functions to handle with the different
possible data structures. This function here should absorb all the specific details
of each structure/type/class.


5.- Implement template
----------------------
Replace the template placeholders with actual implementation that satisfies
the purpose examples. For the square-are example::

    (define (square-area side)
      (sqr side))

6.- Run the tests
-----------------
Check that all your requirements are fulfilled, and go back to any of the previous
points if necessary.