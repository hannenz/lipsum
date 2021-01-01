/**
 * CLI Lorem Ipsum Generator
 *
 * @author Johannes Braun <me@hannenz.de>
 * @license GNU
 * @version 2014-05
 *
 */
using Gtk;

namespace Lipsum {

	public class Lipsum {

		/**
		 * @var string version
		 */
		private const string version = "0.1";

		/**
		 * @var bool GUI
		 */
		protected static bool gui_mode = false;

		protected static bool show_version = false;
		protected static int sentence_min_len = 4;
		protected static int sentence_max_len = 15;
		protected static int paragraph_min_len = 2;
		protected static int paragraph_max_len = 10;
		protected static bool count_paragraphs = false;
		protected static bool count_sentences = false;
		protected static bool count_words = false;
		protected static bool count_chars = false;
		protected static bool start_with_lorem_ipsum = false;
		protected static string input_filename = null;
		protected static bool html = false;

		/**
		 * Options
		 */
		private const GLib.OptionEntry[] options = {
			{ "version", 'v', 0, OptionArg.NONE, ref show_version, "Display version number", null},
			{ "sentence-min", 0, 0, OptionArg.INT, ref sentence_min_len, "Minimum number of words in a sentence", "INT"},
			{ "sentence-max", 0, 0, OptionArg.INT, ref sentence_max_len, "Maximum number of words in a sentence", "INT"},
			{ "paragraph-min", 0, 0, OptionArg.INT, ref paragraph_min_len, "Minimum number of sentences in a paragraph", "INT"},
			{ "paragraph-max", 0, 0, OptionArg.INT, ref paragraph_max_len, "Maximum number of sentences in a paragraph", "INT"},
			{ "paragraphs", 'p', 0, OptionArg.NONE, ref count_paragraphs, "Count paragraphs", null},
			{ "sentences", 's', 0, OptionArg.NONE, ref count_sentences, "Count sencences", null},
			{ "words", 'w', 0, OptionArg.NONE, ref count_words, "Count words", null},
			{ "chars", 'c', 0, OptionArg.NONE, ref count_chars, "Count characters", null},
			{ "lorem", 'l', 0, OptionArg.NONE, ref start_with_lorem_ipsum, "Always start with \"Lorem ipsum\"", null},
			{ "input-file", 'i', 0, OptionArg.FILENAME, ref input_filename, "Read words from input file", null},
			{ "html", 'H', 0, OptionArg.NONE, ref html, "Wrap paragraphs in HTML <p> Tags", null},
			{ "gui", 'g', 0, OptionArg.NONE, ref gui_mode, "Graphical user interface", null},
			{ null }
		};

		/**
		 * main function
		 */
		public static int main(string[] args){

			// Parse options
			try {
				var opt_context = new OptionContext("[count]");
				opt_context.set_help_enabled(true);
				opt_context.add_main_entries(options, null);
				opt_context.parse(ref args);
			}
			catch (Error e){
				stderr.printf("Error: %s\n", e.message);
				stderr.printf("Run %s --help to see a full list of availalbe command line options.\n", args[0]);
				return 1;
			}

			// Show version?
			if (show_version){
				stdout.printf("%s\n", version);
				return 0;
			}

			// Make some assertions and assure that the options/ combinations are sane.
			assert (sentence_min_len < sentence_max_len);
			assert (paragraph_min_len < paragraph_max_len);

			if (!count_paragraphs && !count_sentences && !count_words && !count_chars) {
				count_paragraphs = true;
			}

			if ((int)count_paragraphs + (int)count_sentences + (int)count_words + (int)count_chars > 1){
				stderr.printf("Only one of -p, -s, -w or -c flag is allowed\n");
				return 1;
			}


			// Create generator
			var generator = new Generator();
			// Determine the "count"
			if (args.length == 2){
				generator.count = int.parse(args[1]);
			}

			// Set generator options from command line args
			generator.sentence_min_len = sentence_min_len;
			generator.sentence_max_len = sentence_max_len;
			generator.paragraph_min_len = paragraph_min_len;
			generator.paragraph_max_len = paragraph_max_len;
			generator.count_paragraphs = count_paragraphs;
			generator.count_sentences = count_sentences;
			generator.count_words = count_words;
			generator.count_chars = count_chars;
			generator.start_with_lorem_ipsum = start_with_lorem_ipsum;
			generator.html = html;

			if (gui_mode){
				var app = new Application.with_generator(generator);
				return app.run(args);
			}
			else {
				string text = generator.generate();
				stdout.printf("%s\n", text);
			}

			return 0;
		}
	}
}

