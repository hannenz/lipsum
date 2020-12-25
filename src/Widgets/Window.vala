using Gtk;

namespace Lipsum {

	public class Window : Gtk.ApplicationWindow {

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

		protected Generator generator;

		private uint configure_id;


		public Window(Application app) {

			Object (
				application: app
			);

			this.generator = app.generator;


			// Restore window size and position
			int window_x, window_y, width, height;

			// Fallback size
			this.set_default_size(360, 360);
			Application.settings.get("window-size", "(ii)", out width, out height);
			if (width != -1 || height != -1) {
				set_default_size(width, height);
			}

			Application.settings.get("window-position", "(ii)", out window_x, out window_y);
			if (window_x != -1 || window_y != -1) {
				move(window_x, window_y);
			}


			var header = new Gtk.HeaderBar();
			header.title = "Lispum";
			header.get_style_context().add_class("default-decoration");
			header.show_close_button = true;
			header.decoration_layout = "close:";
			set_titlebar(header);

			this.clipboard = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.SELECTION_CLIPBOARD);

			this.build_gui();

			this.show_all();
		}


		construct {
		}



		protected void build_gui() {
			try {

				var builder = new Builder();


				builder.add_from_file("/usr/local/share/lipsum/lipsum.glade");
				builder.connect_signals(this);

				var vbox = builder.get_object("main_vbox") as Gtk.Box;
				vbox.get_parent().remove(vbox);
				this.add(vbox);

				this.border_width = 10;
				this.text_view = builder.get_object("textview") as TextView;
				this.text_view.set_left_margin(6);
				this.text_view.set_right_margin(6);
				this.text_view.set_top_margin(6);
				this.text_view.set_bottom_margin(6);
				this.text_view.set_wrap_mode(Gtk.WrapMode.WORD);
				this.text_view.buffer.text = this.generator.generate();

				this.spin_button = builder.get_object("amount_spinbutton") as SpinButton;
				this.spin_button.set_value(3);

				// this.spin_button.set_value(this.generator.count);
                //
				// this.count_paragraphs_rb = builder.get_object("paragraphs_radiobutton") as RadioButton;
				// this.count_paragraphs_rb.set_active(this.generator.count_paragraphs);
                //
				// this.count_sentences_rb = builder.get_object("sentences_radiobutton") as RadioButton;
				// this.count_sentences_rb.set_active(this.generator.count_sentences);
                //
				// this.count_words_rb = builder.get_object("words_radiobutton") as RadioButton;
				// this.count_words_rb.set_active(this.generator.count_words);
                //
				// this.count_chars_rb = builder.get_object("chars_radiobutton") as RadioButton;
				// this.count_chars_rb.set_active(this.generator.count_chars);
                //
				// this.html_cb = builder.get_object("html_checkbutton") as CheckButton;
				// this.html_cb.set_active(this.generator.html);
                //
				// this.lorem_cb = builder.get_object("lorem_checkbutton") as CheckButton;
				// this.lorem_cb.set_active(this.generator.start_with_lorem_ipsum);

			}
			catch (Error e){
				error("%s\n", e.message);
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


		public override bool configure_event(Gdk.EventConfigure event) {
			if (configure_id != 0) {
				GLib.Source.remove(configure_id);
			}

			configure_id = Timeout.add(100, () => {
				configure_id = 0;

				int root_x, root_y, width, height;
				get_position(out root_x, out root_y);
				Application.settings.set("window-position", "(ii)", root_x, root_y);

				get_size(out width, out height);
				Application.settings.set("window-size", "(ii)", width, height);

				return false;
			});

			return base.configure_event(event);
		}
	}
}
