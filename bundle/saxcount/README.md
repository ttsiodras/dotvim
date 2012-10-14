
My first VIM plugin ever: use SAXCount to validate XMLs based on their .xsds ;
provided that they have header lines on top telling what .xsd they use,
e.g. files looking like this:

    <?xml version="1.0" encoding="utf-8" ?>
    <WhateverElement ... 
            xsi:noNamespaceSchemaLocation="something.xsd"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <AnotherElement>
            ...
        </AnotherElement>
    </WhateverElement>

The .xsd file must be at the same place as the .xml - or a "search"
functionality must be added to SAXCount - some sort of XSDPATH.

Now for the ":make" (mapped to F7) and error parsing functionality:

No need to explain this part:

    se makeprg=SAXCount\ -n\ -s\ -f\ %

But this needs explaining:

    se errorformat=%E,%C%.%#Error\ at\ file\ %f%.\ line\ %l%.\ char\ %c,%C\ \ Message:\ %m,%Z,%-G%f:\ %*[0-9]\ ms\ %.%#

It is supposed to catch error messages like these:

    $ SAXCount -n -s -f a.xml

    Error at file /var/tmp/a.xml, line 4, char 23
      Message: empty content is not valid for content model '(transferBatch|notification)'

... or Fatal errors, that similarly begin with "Fatal Error" instead of "Error":

    Fatal Error at file ...

It must also ignore lines like these:

    a.xml: 11 ms (64 elems, 207 attrs, 1133 spaces, 0 chars)

So, breaking it down, I have two errorformat "rules":

    se errorformat=
        (Error report span in multiple lines, begins with %E, ends with %Z)
        %E,%C%.%#Error\ at\ file\ %f%.\ line\ %l%.\ char\ %c,%C\ \ Message:\ %m,%Z,
        (Information emitted by SAXCount about execution time)
        %-G%f:\ %*[0-9]\ ms\ %.%#

The first rule:

    %E (begin multiline match of an error report)
    , (end of first line, which is always empty)
    %C (continuation - next line)
    %.%#Error...
    (which means match '.*Error...' - so it also catches "Fatal Error...")
    %f%.
    (filename, followed by any char - in this case, the comma,
     for some reason I could not use '\,' so I just used a '%.')
    %l and %c (similarly, line and column number)
    %C (continuation - next line)
    Message: %m
    (matches the actual message and stores if for Vim's "copen" list)
    %Z (end multiline match)

The second rule: ignore (hence the minus in %-G) this kind of informational lines... "a.xml: 11 ms (64 elems, 207 attrs, 1133 spaces, 0 chars)"

    %-G%f:\ %*[0-9]\ ms\ %.%#
    (basically: filename, colon, space, numbers, space, "ms", and ".*")

Now all I have to do to validate my .xml files is hit F7, and navigate from
each error to the next with F4 (just as I do for my Python work, via pyflakes).

Thanassis Tsiodras, Dr.-Ing.

ttsiodras@gmail.com
