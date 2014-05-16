/**
 * CLI Lorem Ipsum Generator
 *
 * @author Johannes Braun <me@hannenz.de>
 * @license GNU 
 * @version 2014-05
 *
 * Compile: valac --pkg gio-2.0 lipsum.vala
 *
 */
using Gdk;
using Gtk;

namespace Lipsum {

	public class Lipsum {

		/**
		 * @var int Count  Iteration counter
		 */
		protected static int count = 1;

		/**
		 * @var bool  Flag whether to wrap text in html <p> tags
		 */
		protected static bool html = false;

		/**
		 * @var bool  Flag whether to just show version and exit
		 */
		protected static bool show_version = false;

		/**
		 * @var int  Minimum number of words per sentence
		 */
		protected static int sentence_min_len = 4;

		/**
		 * @var int  Maximum number of words per sentence
		 */
		protected static int sentence_max_len = 15;

		/**
		 * @var int  Minimum number of sentences per paragraph
		 */
		protected static int paragraph_min_len = 2;

		/**
		 * @var int  Maximum number of sentences per paragraph
		 */
		protected static int paragraph_max_len = 10;

		/**
		 * @var bool  Flag whether to count paragraphs
		 */
		protected static bool count_paragraphs =false;

		/**
		 * @var bool  Flag whether to count sentences
		 */
		protected static bool count_sentences = false;

		/**
		 * @var bool  Flag whether to count words
		 */
		protected static bool count_words = false;

		/**
		 * @var bool  Flag whether to count characters
		 */
		protected static bool count_chars = false;

		/**
		 * @var bool  Flag whether to start with the words "Lorem ipsum"
		 */
		protected static bool start_with_lorem_ipsum = false;

		/**
		 * @var string  Input filename
		 */
		protected static string input_filename = null;

		/**
		 * @var bool GUI
		 */
		protected static bool gui_mode = false;

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
			{ "words", 'c', 0, OptionArg.NONE, ref count_chars, "Count characters", null},
			{ "lorem", 'l', 0, OptionArg.NONE, ref start_with_lorem_ipsum, "Always start with \"Lorem ipsum\"", null},
			{ "input-file", 'i', 0, OptionArg.FILENAME, ref input_filename, "Read words from input file", null},
			{ "html", 'H', 0, OptionArg.NONE, ref html, "Wrap paragraphs in HTML <p> Tags", null},
			{ "gui", 'g', 0, OptionArg.NONE, ref gui_mode, "Graphical user interface", null},
			{ null }
		};

		/**
		 * Words to use for placeholder text. This is the original "Lorem Ipsum"
		 * It is possible to read words from a custom text file (-i option)
		 */
		protected string[] words = {
			"Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipisicing", "elit", "sed", "do", "eiusmod",
			"tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "Ut", "enim", "ad", "minim",
			"veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea",
			"commodo", "consequat", "Duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit",
			"esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "Excepteur", "sint", "occaecat", "cupidatat",
			"non", "proident", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum"
		};

		/**
		 * @var string version
		 */
		private const string version = "0.1";

		/**
		 * @var Rand  random generator object
		 */
		protected Rand random;

		/**
		 * Constructor - initialize the random number generator
		 */
		public Lipsum() {

			this.random = new Rand();

		}

		/**
		 * Create a paragraph with n sentences, where n is a random number in the range of
		 * paragraph_min_len and paragraph_max_len
		 *
		 * @return void
		 */
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
		 * Create a sentence with n words, where n is a random number in the range of
		 * sentence_min_len and sentence_max_len
		 *
		 * @return void
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

		/**
		 * Generate an output according to the chosen options
		 *
		 * @return string  The generated placeholder text
		 */
		public string output() {

			string ret = "";

			if (count_paragraphs) {
				for (int i = 0; i < count ; i++){
					ret += this.create_paragraph();
					if (i < count - 1) {
						ret += "\n\n";
					}
				}
			}
			else if (count_sentences) {
				for (int i = 0; i < count ; i++){
					ret += this.create_sentence();
					if (i < count - 1){
						ret += " ";
					}
				}
			}
			else if (count_words) {
				ret = create_sentence(count);
			}
			else if (count_chars){
				do {
					ret = "";
					do {
						ret += this.create_sentence();
					} while (ret.length < count);
					ret = ret.substring(0, count);
				}
				while (ret.substring(ret.length - 1, 1) == " "); // Don't allow character sequences ending with a space
			}

			return ret;
		}

		/**
		 * Read words from a custom text file
		 *
		 * @return void
		 */
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
							custom_words += match_info.fetch(0);
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

		public void gui(){

			var clipboard = Gtk.Clipboard.get_for_display(Display.get_default(), Gdk.SELECTION_CLIPBOARD);

			var win = new Gtk.Window();
			win.set_border_width(6);
			win.destroy.connect(Gtk.main_quit);
			win.set_default_size(400, 400);

			var vbox = new Box(Orientation.VERTICAL, 0);

			var swin = new ScrolledWindow(null, null);
			var text_view = new TextView();

			vbox.pack_start(swin, true, true, 0);

			text_view.set_wrap_mode(Gtk.WrapMode.WORD);
			text_view.buffer.text = this.output();
			swin.add(text_view);

			var grid = new Gtk.Grid();

			var lorem_cb = new CheckButton.with_label("Start with \"Lorem ipsum\"");
			var html_cb = new CheckButton.with_label("Wrap paragraphs in HTML <p> Tags");
			lorem_cb.set_active(start_with_lorem_ipsum);
			html_cb.set_active(html);

			grid.attach(lorem_cb, 0, 1, 1, 1);
			grid.attach(html_cb, 0, 2, 1, 1);

			var spin_button = new Gtk.SpinButton.with_range(1, 1000, 1);
			spin_button.set_value(count);

			var radio1 = new RadioButton.with_label(null, "Paragraphs");
			var radio2 = new RadioButton.with_label_from_widget(radio1, "Sentences");
			var radio3 = new RadioButton.with_label_from_widget(radio1, "Words");
			var radio4 = new RadioButton.with_label_from_widget(radio1, "Characters");

			var button_box = new ButtonBox(Orientation.HORIZONTAL);
			var generate_button = new Button.with_label("Generate");
			var copy_button = new Button.with_label("Copy to clipboard");
			var copy_close_button = new Button.with_label("Copy and close");

			grid.attach(spin_button, 1, 1, 1, 1);
			grid.attach(radio1, 1, 2, 1, 1);
			grid.attach(radio2, 1, 3, 1, 1);
			grid.attach(radio3, 1, 4, 1, 1);
			grid.attach(radio4, 1, 5, 1, 1);

			generate_button.clicked.connect( () => {

					count = spin_button.get_value_as_int();
					count_paragraphs = radio1.get_active();
					count_sentences = radio2.get_active();
					count_words = radio3.get_active();
					count_chars = radio4.get_active();
					start_with_lorem_ipsum = lorem_cb.get_active();
					html = html_cb.get_active();

					text_view.buffer.text = this.output();
				});

			copy_button.clicked.connect( () => {
					clipboard.set_text(text_view.buffer.text, -1);
				});

			copy_close_button.clicked.connect( () => {
					clipboard.set_text(text_view.buffer.text, -1);
					Gtk.main_quit();
				});

			vbox.pack_start(grid, false, false, 0);

			button_box.add(copy_close_button);
			button_box.add(copy_button);
			button_box.add(generate_button);

			vbox.pack_start(button_box, false, false, 0);

			win.add(vbox);
			win.show_all();
		}

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

			// Determine the "count"
			if (args.length == 2){
				count = int.parse(args[1]);
			}

			// Create application object
			var lipsum = new Lipsum();

			if (gui_mode){
				Gtk.init(ref args);
				lipsum.gui();
				Gtk.main();
			}
			else {

				// If -i option has been set, read words from file
				if (input_filename != null){
					lipsum.read_input_file();
				}


				// Call generator and output result
				stdout.printf("%s%s\n", start_with_lorem_ipsum ? "Lorem ipsum " : "", lipsum.output());
			}
			return 0;
		}
	}
}

