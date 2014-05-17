namespace Lipsum {

	/**
	 * Generator class
	 *
	 * Generation of dummy text
	 */
	public class Generator {

		/**
		 * @var int Count  Iteration counter
		 */
		public int count = 1;

		/**
		 * @var bool  Flag whether to wrap text in html <p> tags
		 */
		public bool html = false;

		/**
		 * @var int  Minimum number of words per sentence
		 */
		public int sentence_min_len = 4;

		/**
		 * @var int  Maximum number of words per sentence
		 */
		public int sentence_max_len = 15;

		/**
		 * @var int  Minimum number of sentences per paragraph
		 */
		public int paragraph_min_len = 2;

		/**
		 * @var int  Maximum number of sentences per paragraph
		 */
		public int paragraph_max_len = 10;

		/**
		 * @var bool  Flag whether to count paragraphs
		 */
		public bool count_paragraphs =false;

		/**
		 * @var bool  Flag whether to count sentences
		 */
		public bool count_sentences = false;

		/**
		 * @var bool  Flag whether to count words
		 */
		public bool count_words = false;

		/**
		 * @var bool  Flag whether to count characters
		 */
		public bool count_chars = false;

		/**
		 * @var bool  Flag whether to start with the words "Lorem ipsum"
		 */
		public bool start_with_lorem_ipsum = false;

		/**
		 * @var string  Input filename
		 */
		public string input_filename = null;

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
		 * @var Rand  random generator object
		 */
		protected Rand random;

		/**
		 * Constructor
		 *
		 * Initialize a random number generator
		 */
		public Generator () {

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

			if (this.start_with_lorem_ipsum){
				paragraph.overwrite(0, paragraph.str.substring(0, 1).down());
				paragraph.prepend("Lorem ipsum ");
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
		public string generate() {

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
	}
}