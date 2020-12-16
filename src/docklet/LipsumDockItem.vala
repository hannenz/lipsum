using Plank;
using Cairo;
using Gdk;

namespace Lipsum {


	public class LipsumDockItem : DockletItem {

		protected Gdk.Pixbuf icon_pixbuf;

		protected LipsumPreferences prefs;

		protected Lipsum.Generator generator;

		protected Gtk.Clipboard clipboard;
		protected string lipsum_text = "";


		protected Gtk.MenuItem item;


		public LipsumDockItem.with_dockitem_file(GLib.File file) {
			GLib.Object(Prefs: new LipsumPreferences.with_file(file));
		}


		/* Constructor */
		construct {

			// Init Logger (logsto console, Do `killall plank ; sudo plank` in terminal` to see the log
			Logger.initialize("Lipsum");
			Logger.DisplayLevel = LogLevel.NOTIFY;

			// Set Icon and Text (Tooltip);
			Icon = "resource://" + Lipsum.G_RESOURCE_PATH + "/src/docklet/icons/lipsum_icon.svg";
			Text = "Generate placeholder text on the fly";
			Button = PopupButton.RIGHT;

			this.generator = new Generator();
			this.generator.count_words = true;
			this.clipboard = Gtk.Clipboard.get_for_display(Display.get_default(), Gdk.SELECTION_CLIPBOARD);

			// Get preferences (Where do we set them?? They are not in gsettings!!
			// prefs = (LipsumPreferences) Prefs;


			try {
				icon_pixbuf = new Gdk.Pixbuf.from_resource(Lipsum.G_RESOURCE_PATH + "/src/docklet/icons/lipsum_icon.png");
			}
			catch (Error e) {
				warning("Error: " + e.message);
			}
		}


		/* Destructor */
		~LipsumDockItem () {
		}


		/**
		 * Draw the icon
		 *
		 * @param Plank.Surface 		Cairo surface to draw upon
		 * @return void
		 */
		// protected override void draw_icon(Plank.Surface surface) {
        //
		// 	Cairo.Context ctx = surface.Context;
		// 	Gdk.Pixbuf pb;
        //
		// 	pb = icon_pixbuf.scale_simple(surface.Width, surface.Height, Gdk.InterpType.BILINEAR);
        //
		// 	Gdk.cairo_set_source_pixbuf(ctx, pb, 0, 0);
		// 	ctx.paint();
        //
		// 	ctx.set_source_rgb(1.0, 1.0, 1.0);
		// 	ctx.select_font_face("Roboto", Cairo.FontSlant.NORMAL,
		// 						 Cairo.FontWeight.BOLD);
		// 	ctx.set_font_size(12);
		// 	ctx.move_to(10, 30);
		// 	
		// 	ctx.show_text("count: %u".printf(this.generator.count));
		// }



		protected override AnimationType on_scrolled(Gdk.ScrollDirection
													 direction, Gdk.ModifierType
													 mod, uint32 event_time) {

			switch (direction) {
				case Gdk.ScrollDirection.UP:
					this.generator.count += 10;
					if (this.generator.count > 500) {
						this.generator.count = 0;
					}
					break;

				case Gdk.ScrollDirection.DOWN:
					this.generator.count -= 10;
					if (this.generator.count < 0) {
						this.generator.count = 0;
					}
					break;
			}
			this.lipsum_text = this.generator.generate();
			this.Text = this.lipsum_text;
			item.set_label(this.lipsum_text);
			Logger.notification("Text: " + this.lipsum_text);

			reset_icon_buffer();

			return AnimationType.NONE;
		}



		/**
		 * Callback for when the icon gets clicked
		 *
		 * @param PopupButton
		 * @param Gdk.ModifierType
		 * @param uint32
		 * @return AnimationType
		 */
		protected override AnimationType on_clicked(PopupButton button, Gdk.ModifierType mod, uint32 event_time) {

			if (button == PopupButton.LEFT) {
				try {
					string[] spawn_args = {"lipsum", "-g"};
					string[] spawn_env = Environ.get ();
					Pid child_pid;

					Process.spawn_async ("/",
										 spawn_args,
										 spawn_env,
										 SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
										 null,
										 out child_pid);

					ChildWatch.add (child_pid, (pid, status) => {
						// Triggered when the child indicated by child_pid exits
						Process.close_pid (pid);
						// loop.quit ();
					});

				} catch (SpawnError e) {
					print ("Error: %s\n", e.message);
				}
			}
			return AnimationType.NONE;
		}


		public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
			var items = new Gee.ArrayList<Gtk.MenuItem>();

			this.generator.count = 5;
			var text5 = this.generator.generate();
			item = create_literal_menu_item(this.wrap(text5, 60));
			item.activate.connect(() => {
				this.clipboard.set_text(text5, -1);
			});
			items.add(item);

			this.generator.count = 10;
			var text10 = this.generator.generate();
			item = create_literal_menu_item(this.wrap(text10, 60));
			item.activate.connect(() => {
				this.clipboard.set_text(text10, -1);
			});
			items.add(item);

			this.generator.count = 20;
			var text20 = this.generator.generate();
			item = create_literal_menu_item(this.wrap(text20, 60));
			item.activate.connect(() => {
				this.clipboard.set_text(text20, -1);
			});
			items.add(item);

			this.generator.count = 50;
			var text50 = this.generator.generate();
			item = create_literal_menu_item(this.wrap(text50, 60));
			item.activate.connect(() => {
				this.clipboard.set_text(text50, -1);
			});
			items.add(item);

			this.generator.count = 100;
			var text100 = this.generator.generate();
			item = create_literal_menu_item(this.wrap(text100, 60));
			item.activate.connect(() => {
				this.clipboard.set_text(text100, -1);
			});
			items.add(item);

			return items;
		}


		protected string wrap(string text, int width) {
			int j = 0;
			unichar c;
			string wrapped_text = text;
			for (int i = 0; wrapped_text.get_next_char(ref i, out c);) {
				if (++j > width) {

					while (!c.isspace() && wrapped_text.get_prev_char(ref i, out c))
						;

					wrapped_text = wrapped_text.splice(i, i + 1, "\n");
					j = 0;
				}
			}

			return wrapped_text;
		}
	}


}
