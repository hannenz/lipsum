# Lipsum

I could not believe that there is no simple "Lorem ipsum" generator available for the commandline, so I wrote one myself. This was a two-nights-project.

## Installation

Clone the repository, then do

~~~
$ cd lipsum
$ make
$ sudo make install
~~~

## Usage

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

