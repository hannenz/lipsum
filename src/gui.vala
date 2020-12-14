using Gtk;
using Gdk;

namespace Lipsum {

	public class Gui : Gtk.Window {

		/**
		 * @var Generator  A lipsum generator instance
		 */
		protected Generator generator;

		/**
		 * @var Gtk.Clipboard  A clipboard instance
		 */
		protected Gtk.Clipboard clipboard;

		protected TextView text_view;

		protected SpinButton spin_button;

		protected RadioButton count_paragraphs_rb;

		protected RadioButton count_sentences_rb;

		protected RadioButton count_words_rb;

		protected RadioButton count_chars_rb;

		protected CheckButton html_cb;

		protected CheckButton lorem_cb;


		public Gui.with_generator(Generator generator) {

			this.generator = generator;

			this.clipboard = Gtk.Clipboard.get_for_display(Display.get_default(), Gdk.SELECTION_CLIPBOARD);

			this.build_gui();
			this.border_width = 10;
			this.destroy.connect(Gtk.main_quit);
			this.title = "Lipsum";
		}

		public void build_gui(){

			try {

				var builder = new Builder();

				builder.add_from_file("/usr/local/share/lipsum/lipsum.glade");
				builder.connect_signals(this);

				var vbox = builder.get_object("main_vbox") as Gtk.Box;
				vbox.get_parent().remove(vbox);
				this.add(vbox);

				this.text_view = builder.get_object("textview") as TextView;
				this.text_view.set_wrap_mode(Gtk.WrapMode.WORD);
				this.text_view.buffer.text = this.generator.generate();

				this.spin_button = builder.get_object("amount_spinbutton") as SpinButton;
				this.spin_button.set_value(this.generator.count);

				this.count_paragraphs_rb = builder.get_object("paragraphs_radiobutton") as RadioButton;
				this.count_paragraphs_rb.set_active(this.generator.count_paragraphs);

				this.count_sentences_rb = builder.get_object("sentences_radiobutton") as RadioButton;
				this.count_sentences_rb.set_active(this.generator.count_sentences);

				this.count_words_rb = builder.get_object("words_radiobutton") as RadioButton;
				this.count_words_rb.set_active(this.generator.count_words);

				this.count_chars_rb = builder.get_object("chars_radiobutton") as RadioButton;
				this.count_chars_rb.set_active(this.generator.count_chars);

				this.html_cb = builder.get_object("html_checkbutton") as CheckButton;
				this.html_cb.set_active(this.generator.html);

				this.lorem_cb = builder.get_object("lorem_checkbutton") as CheckButton;
				this.lorem_cb.set_active(this.generator.start_with_lorem_ipsum);

				this.set_default_size(400, 600);
				this.show_all();
			}
			catch (Error e){
				error ("%s\n", e.message);
			}
		}

		/**
		 * Callbacks
		 *
		 * To allow auto connecting signals via Glade (XML UI Builder)
		 * we have to add the [CCode (instance_pos=-1)] annotations
		 * to the callback functions.
		 * In Glade the method name is namespace_class_method_name
		 * See here for details:
		 * https://wiki.gnome.org/Projects/Vala/GTKSample#Loading_User_Interface_from_XML_File
		 */

		[CCode (instance_pos = -1)]
		public void on_generate_button_clicked(Button source) {

			this.generator.count = this.spin_button.get_value_as_int();
			this.generator.count_paragraphs = this.count_paragraphs_rb.get_active();
			this.generator.count_sentences = this.count_sentences_rb.get_active();
			this.generator.count_words = this.count_words_rb.get_active();
			this.generator.count_chars = this.count_chars_rb.get_active();
			this.generator.start_with_lorem_ipsum = this.lorem_cb.get_active();
			this.generator.html = this.html_cb.get_active();
			text_view.buffer.text = this.generator.generate();
		}

		[CCode (instance_pos = -1)]
		protected void on_copy_button_clicked(Button source) {
			this.clipboard.set_text(text_view.buffer.text, -1);
		}

		[CCode (instance_pos = -1)]
		protected void on_copy_close_button_clicked(Button source) {

			clipboard.set_text(text_view.buffer.text, -1);
			Gtk.main_quit();
		}
	}
}
