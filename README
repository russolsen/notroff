NotRoff Text Formatter
========

NotRoff is a simple plain text file format that allows you to embed all sort of styling, including fixed width, italics and bold into your work using plain text markers. The included notroff program will turn the plain text into an Open Office .odt document. I used NotRoff to format Eloquent Ruby.

Creating plain text in notroff is very easy -- you just write each paragraph in its own line, separated by blank lines. You can add styling to your text with simple tags: words surrounded by !! become bold, while ~~ tags italics and @@ tags code, for example like this:

!!This!! is bold, but ~~this~~ is italics and @@all of this@@ looks like code.

To do fancier stuff there are also dot commands. Each dot command starts with a period, followed by the name of the command, and then -- for most dot commands -- an argument or two. For example, there is a dot command for creating section headers:

.section NotRoff Includes Section Headers

There is also a dot command to include some program code from a source code into your final document: 

.inc gutted_doc.rb

Frequently you don't want the whole file, just a chunk of it. To do that, you can add a second argument to your .inc command, a !!tag!! which will pick out a tagged section of the file. Here's what a .inc command with a tag looks like:

.inc ex_lazy_document.rb  base_doc

And here is what the corresponding source file looks like:

.code
# This comment is not included in the .odt file

puts "first included line"   ##(base_doc
puts "also included"
puts "last included line"    ##base_doc)
.body

There is a short cut if you want to include a single line from your source file -- Just tag it with ##+tag, like this:

open_file = File.open( '/etc/passwd' )   ##+open

You can also explicitly exclude a line with ##--tag.

One of the problems with including code into text is that the indentation is frequently wrong: The code wants to have indentation that makes sense within the larger program which sometimes looks bad in the text. To deal with this, the .inc command lets you specify a 3rd parameter, the number of spaces that you want to set the indentation to:

.c1 .inc type_check_spec.rb bad_type 2

Along with pulling code from a file, you can also include single lines of code directly into the NotRoff file:

.c1  doc = get_some_kind_of_document 

Or multiple lines of code:

.code
  puts "Title: #{doc.title}" 
  puts "Author: #{doc.author}" 
  puts "Content: #{doc.content}" 
.body

Using notroff is simple: Just run the notroff script, supplying the path to the plain text file as the first argument and the path to your new OpenOffice .odt file as the second:

.c1 notroff example.nr example.odt


