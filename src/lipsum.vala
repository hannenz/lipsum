/**
 * CLI Lorem Ipsum Generator
 *
 * @author Johannes Braun <me@hannenz.de>
 * @license GNU 
 * @version 2014-05
 *
 * TODO:
 * - random uppercase (option to)
 * - Add Option to read custom text file to use as word base (read file, strip all non-word-chars etc.)
 */
namespace Lipsum {

	public class Lipsum {
		protected static bool html = false;
		protected static bool show_version = false;
		protected static int sentence_min_len = 4;
		protected static int sentence_max_len = 15;
		protected static int paragraph_min_len = 2;
		protected static int paragraph_max_len = 10;
		protected static bool count_paragraphs =false;
		protected static bool count_sentences = false;
		protected static bool count_words = false;
		protected static bool count_chars = false;
		protected static bool start_with_lorem_ipsum = false;
		protected static string input_filename;

		private const GLib.OptionEntry[] options = {
			{ "version", 'v', 0, OptionArg.NONE, ref show_version, "Display version number", null},
			{ "html", 'H', 0, OptionArg.NONE, ref html, "Output HTML <p> Tags", null},
			{ "sentence-min", 0, 0, OptionArg.INT, ref sentence_min_len, "Minimum number of words in a sentence", "INT"},
			{ "sentence-max", 0, 0, OptionArg.INT, ref sentence_max_len, "Maximum number of words in a sentence", "INT"},
			{ "paragraph-min", 0, 0, OptionArg.INT, ref paragraph_min_len, "Minimum number of words in a paragraph", "INT"},
			{ "paragraph-max", 0, 0, OptionArg.INT, ref paragraph_max_len, "Maximum number of words in a paragraph", "INT"},
			{ "paragraphs", 'p', 0, OptionArg.NONE, ref count_paragraphs, "Count paragraphs", null},
			{ "sentences", 's', 0, OptionArg.NONE, ref count_sentences, "Count sencences", null},
			{ "words", 'w', 0, OptionArg.NONE, ref count_words, "Count words", null},
			{ "words", 'c', 0, OptionArg.NONE, ref count_chars, "Count characters", null},
			{ "lorem", 'l', 0, OptionArg.NONE, ref start_with_lorem_ipsum, "Always start with \"Lorem ipsum\"", null},
			{ "input-file", 'i', 0, OptionArg.FILENAME, ref input_filename, "Read words from input file", null},
			{ null }
		};

		protected string[] words = {
			"Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipisicing", "elit", "sed", "do", "eiusmod",
			"tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "Ut", "enim", "ad", "minim",
			"veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea",
			"commodo", "consequat", "Duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit",
			"esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "Excepteur", "sint", "occaecat", "cupidatat",
			"non", "proident", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum"
		};

		private const string version = "0.1";


		protected Rand random;



		public Lipsum() {

			this.random = new Rand();

		}

		public string create_paragraph() {

			StringBuilder paragraph = new StringBuilder();

			int len = this.random.int_range(paragraph_min_len, paragraph_max_len);

			for (int i = 0; i < len; i++){
				paragraph.append(this.create_sentence());
				if (i < len - 1){
					paragraph.append_c(' ');
				}
			}

			if (html){
				paragraph.prepend("<p>");
				paragraph.append("</p>");
			}
			return paragraph.str;
		}

		/**
		 * Create a sentence
		 * 
		 * between 4-15 words
		 */
		public string create_sentence(int len = -1) {

			StringBuilder sentence = new StringBuilder();
			if (len <= 0){
				len = this.random.int_range(sentence_min_len, sentence_max_len);
			}

			// Include comma in sentences that have more than 7 words, in approx. 2/3 of the time.
			/* TODO: Better: Commas per words ratio, then get len / ratio times comma_pos (with a set spacing)... */
			int comma_pos = (len > 7 && (this.random.int_range(0, 2) > 0)) ? this.random.int_range(3, len - 2) : -1;

			for (int i = 0; i < len ; i++){
				int r = this.random.int_range(0, words.length);
				sentence.append(this.words[r]);
				if (i < len - 1) {
					if (i == comma_pos){
						sentence.append_c(',');
					}
					sentence.append_c(' ');
				}
				else {
					sentence.append_c('.');
				}
			}
			// Upercase the first letter
			sentence.overwrite(0, sentence.str.substring(0, 1).up());
			return sentence.str;
		}

		public string output(int n) {

			string ret = "";

			if (count_paragraphs) {
				for (int i = 0; i < n ; i++){
					ret += this.create_paragraph();
					if (i < n - 1) {
						ret += "\n\n";
					}
				}
			}
			else if (count_sentences) {
				for (int i = 0; i < n ; i++){
					ret += this.create_sentence();
					if (i < n - 1){
						ret += " ";
					}
				}
			}
			else if (count_words) {
				ret = create_sentence(n);
			}
			else if (count_chars){
				do {
					ret = "";
					do {
						ret += this.create_sentence();
					} while (ret.length < n);
					ret = ret.substring(0, n);
				}
				while (ret.substring(ret.length - 1, 1) == " "); // Don't allow character sequences ending with a space
			}

			return ret;
		}

		public void read_input_file() {
			try {
				string[] custom_words = {};
				var regex = new Regex("(\\w{2,})");
				File file = File.new_for_commandline_arg(input_filename);
				var dis = new DataInputStream(file.read());
				string line;
				MatchInfo match_info;
				while (( line = dis.read_line(null)) != null){
					if (regex.match(line, 0, out match_info)){
						while (match_info.matches()){
							string word = match_info.fetch(0);
							custom_words += word;
//							stdout.printf("[%s]\n", match_info.fetch(0));
							match_info.next();
						}

					}
				}
				this.words = custom_words;
			}
			catch(Error e){
				error("Error: %s\n", e.message);
			}
		}


		public static int main(string[] args){

			try {
				var opt_context = new OptionContext(" - Lorem Ipsum generator");
				opt_context.set_help_enabled(true);
				opt_context.add_main_entries(options, null);
				opt_context.parse(ref args);
			}
			catch (Error e){
				stderr.printf("Error: %s\n", e.message);
				stderr.printf("Run %s --help to see a full list of availalbe command line options.\n", args[0]);
				return 1;
			}
			if (show_version){
				stdout.printf("%s\n", version);
				return 0;
			}
			assert (sentence_min_len < sentence_max_len);
			assert (paragraph_min_len < paragraph_max_len);
			if (!count_paragraphs && !count_sentences && !count_words && !count_chars) {
				count_paragraphs = true;
			}
			if ((int)count_paragraphs + (int)count_sentences + (int)count_words + (int)count_chars > 1){
				stderr.printf("Only one of -p, -s, -w or -c flag is allowed\n");
				return 1;
			}

			var lipsum = new Lipsum();
			if (input_filename != null){
				lipsum.read_input_file();
			}

			int n = 1;
			if (args.length == 2){
				n = int.parse(args[1]);
			}
			stdout.printf("%s%s\n", start_with_lorem_ipsum ? "Lorem ipsum " : "", lipsum.output(n));
			return 0;
		}
	}

}


