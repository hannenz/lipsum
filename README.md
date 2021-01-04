# Lipsum

I could not believe that there is no simple "Lorem ipsum" generator
available for the commandline, so I wrote one myself. This was a
two-nights-project.

Update 2021-01-04: In the meantime lipsum has a cli interface as well
as a GTK UI and a Plank docklet (Plank is the dock used f.e. in
elementary os)

## Installation

Prerequisites: gtk+-3.0, libplank-dev

Clone the repository, then do

~~~
$ cd lipsum
$ make all
$ sudo make install
~~~

## Usage

### Commandline interface (cli)

~~~
Usage: lipsum [options] [count]
~~~

lipsum can output a given amount of characters, words, sentences or paragraphs of random placeholder text. If no optiopn is set, lipsum outputs paragraphs.
The default count is 1, so without any options lipsum will print one paragraph.

Use the options `-c`, `-w`, `-s` or `-p` to specify what count should stand for: characters, words, sentences or paragraphs

For all available options type `lipsum -h`

~~~
Usage:
  lipsum [OPTION...] [count]

Help Options:
  -h, --help              Show help options

Application Options:
  -v, --version           Display version number
  --sentence-min=INT      Minimum number of words in a sentence
  --sentence-max=INT      Maximum number of words in a sentence
  --paragraph-min=INT     Minimum number of sentences in a paragraph
  --paragraph-max=INT     Maximum number of sentences in a paragraph
  -p, --paragraphs        Count paragraphs
  -s, --sentences         Count sencences
  -w, --words             Count words
  -c, --words             Count characters
  -l, --lorem             Always start with "Lorem ipsum"
  -i, --input-file        Read words from input file
  -H, --html              Wrap paragraphs in HTML <p> Tags
~~~

### Desktop application (GUI)

Installing will also install a desktop entry so the app should appear
in your application launcher (f.e. wingpanel in elementary os)

Alternatively run `lipsum --gui` or `lipsum -g` on the commandline

### Plank Docklet

If you use the plank docklet, you can install lipsum as a docklet:
Ctrl-Rightcklick on the dock and choose Preferences, then go to
docklets and drag lipsum's icon into your dock. Then you can right
click the docklet to get a selection of 5 different amounts of plain
dummy text for super fast access, or left click the docklet will
launch the lipsum desktop application for more control.

