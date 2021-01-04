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

		protected Switch html_switch;

		protected Switch lorem_switch;

		protected Button generate_button;

		protected InfoBar infobar;

		protected Label infobar_message_label;

		protected Button infobar_button;

		protected HeaderBar header;

		public  Generator generator { get; set construct; }

		private uint configure_id;


		public Window(Application application, Generator generator) {

			Object (
				application: application,
				generator: generator
			);
		}

		construct {

			var gtk_settings = Gtk.Settings.get_default();
			gtk_settings.gtk_application_prefer_dark_theme = Application.settings.get_boolean("dark-style");

			var provider = new Gtk.CssProvider();
			provider.load_from_resource("/de/hannenz/lipsum/data/styles/global.css");
			Gtk.StyleContext.add_provider_for_screen(
				Gdk.Screen.get_default(),
				provider,
				Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
			);

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

			this.clipboard = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.SELECTION_CLIPBOARD);

			Application.settings.get("count", "i", out this.generator.count);

			this.build_gui();
			this.show_all();

			update();
		}



		protected void build_gui() {
			try {

				var builder = new Builder();
				builder.add_from_resource("/de/hannenz/lipsum/data/ui/window.ui");
				builder.add_from_resource("/de/hannenz/lipsum/data/ui/popover.ui");

				var vbox = builder.get_object("main_vbox") as Gtk.Box;
				vbox.get_parent().remove(vbox);
				this.add(vbox);

				this.border_width = 10;
				this.text_view = builder.get_object("textview") as TextView;
				this.text_view.buffer.text = this.generator.generate();

				this.spin_button = builder.get_object("amount_spinbutton") as SpinButton;
				this.spin_button.set_value(this.generator.count);

				this.count_chars_rb = builder.get_object("chars_radiobutton") as RadioButton;
				this.count_words_rb = builder.get_object("words_radiobutton") as RadioButton;
				this.count_sentences_rb = builder.get_object("sentences_radiobutton") as RadioButton;
				this.count_paragraphs_rb = builder.get_object("paragraphs_radiobutton") as RadioButton;

				this.count_chars_rb.set_active(this.generator.count_chars);
				this.count_words_rb.set_active(this.generator.count_words);
				this.count_sentences_rb.set_active(this.generator.count_sentences);
				this.count_paragraphs_rb.set_active(this.generator.count_paragraphs);

				this.infobar = builder.get_object("infobar") as InfoBar;
				this.infobar.set_no_show_all(true);
				this.infobar_message_label = builder.get_object("infobar_message_label") as Label;
				this.infobar_button = builder.get_object("infobar_button") as Button;
				this.infobar_button.clicked.connect( () => {
					this.infobar.hide();
					this.infobar.set_revealed(true);
				});

				string selected;
				Application.settings.get("selected", "s", out selected);
				switch (selected) {
					case "chars":
						this.count_chars_rb.set_active(true);
						break;
					case "words":
						this.count_words_rb.set_active(true);
						break;
					case "sentences":
						this.count_sentences_rb.set_active(true);
						break;
					case "paragraphs":
						this.count_paragraphs_rb.set_active(true);
						break;
				}

				this.generate_button = builder.get_object("generate_button") as Button;


				header = new Gtk.HeaderBar();
				header.title = "Lipsum";
				header.get_style_context().add_class("default-decoration");
				header.show_close_button = true;
				header.decoration_layout = "close:";

				var menu_button = new MenuButton();
				menu_button.set_use_popover(true);
				menu_button.image = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
				header.pack_end(menu_button);

				var menu_popover = new Gtk.Popover(menu_button);
				menu_button.popover = menu_popover;

				var grid = builder.get_object("popover_grid") as Gtk.Grid;
				menu_popover.add(grid);

				this.lorem_switch = builder.get_object("lorem_switch") as Gtk.Switch;
				this.lorem_switch.notify["active"].connect( (sw) => {
					Application.settings.set("lorem", "b", this.lorem_switch.get_state());
					update();
				});

				this.html_switch = builder.get_object("html_switch") as Gtk.Switch;
				this.html_switch.notify["active"].connect( () => {
					Application.settings.set("html", "b", this.html_switch.get_state());
					update();
				});

				Application.settings.get("lorem", "b", out this.generator.start_with_lorem_ipsum);
				Application.settings.get("html", "b", out this.generator.html);
				lorem_switch.set_active(this.generator.start_with_lorem_ipsum);
				html_switch.set_active(this.generator.html);

				set_titlebar(header);

				builder.connect_signals(this);
			}
			catch (Error e){
				error("%s\n", e.message);
			}
		}



		public void update() {
			
			this.generator.count = this.spin_button.get_value_as_int();
			this.generator.count_paragraphs = this.count_paragraphs_rb.get_active();
			this.generator.count_sentences = this.count_sentences_rb.get_active();
			this.generator.count_words = this.count_words_rb.get_active();
			this.generator.count_chars = this.count_chars_rb.get_active();

			Application.settings.get("lorem", "b", out this.generator.start_with_lorem_ipsum);
			Application.settings.get("html", "b", out this.generator.html);

			text_view.buffer.text = this.generator.generate();

			if (this.count_chars_rb.get_active()) {
				Application.settings.set("selected", "s", "chars");
			}
			else if (this.count_words_rb.get_active()) {
				Application.settings.set("selected", "s", "words");
			}
			else if (this.count_sentences_rb.get_active()) {
				Application.settings.set("selected", "s", "sentences");
			}
			else if (this.count_paragraphs_rb.get_active()) {
				Application.settings.set("selected", "s", "paragraphs");
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
			update();
		}


		[CCode (instance_pos = -1)]
		protected void on_copy_button_clicked(Button source) {
			string text = text_view.buffer.text;
			this.clipboard.set_text(text, -1);
			this.infobar_message_label.set_text("Placeholder text has been copied to clipboard (%u characters, %u words)".printf(text.length, count_words(text)));
			this.infobar.set_revealed(true);
			this.infobar.set_message_type(MessageType.INFO);
			this.infobar.show();
		}


		[CCode (instance_pos = -1)]
		protected void on_spin_button_value_changed(SpinButton btn) {
			Application.settings.set("count", "i", btn.get_value_as_int());
			update();
		}


		[CCode (instance_pos = -1)]
		protected void on_lorem_switch_activated(Switch the_switch) {
			Application.settings.set("lorem", "b", the_switch.get_state());
			update();
		}


		[CCode (instance_pos = -1)]
		protected void on_html_switch_activated(Switch the_switch) {
			Application.settings.set("html", "b", the_switch.get_state());
			update();
		}


		// Periodically store window size and position
		public override bool configure_event(Gdk.EventConfigure event) {
			if (configure_id != 0) {
				GLib.Source.remove(configure_id);
			}

			configure_id = Timeout.add(250, () => {
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

		private int count_words(string str) {
			var words = str.split(" ");
			return words.length;
		}
	}
}
