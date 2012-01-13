.title The Roots of Ruby
.author Fogus and Russ
.chapter The Way of the World
AAAAA In more

this is ~~italics~~ and

this is a footnote {{foot notes}} and

this is @@code@@ and

this is  !!bold!! is book.
All DocBook elements are in an XML Namespace, so the root element has an xmlns attribute to set the current namespace. Also, the root element of a DocBook document must have a version that specifies the version of the format that the document is built on.

.section A section
In more detail, the root element of the document is book. All DocBook elements are in an XML Namespace, so the root element has an xmlns attribute to set the current namespace. Also, the root element of a DocBook document must have a version that specifies the version of the format that the document is built on.
Some code
.code

# A comment surrouded by white space


# Another comment



.body
body line
.chapter A second chapter
More intro text
.section Section 1
section 1 text
more body
text
.code
foo = bar
bar = foo
.body
still more body text
.section Two
section 2 text
