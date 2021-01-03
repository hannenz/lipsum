using Gtk;

namespace Lipsum {

	public class Application : Gtk.Application {


		public static GLib.Settings settings;


		/**
		 * @var Lipsum.Window
		 */
		protected Window window = null;


		/**
		 * @var Generator  A lipsum generator instance
		 */
		public Generator generator { get; construct set; }






		public Application.with_generator(Generator generator) {
			Object (
				application_id: "de.hannenz.lipsum",
				flags: ApplicationFlags.FLAGS_NONE,
				generator: generator
			);
		}



		static construct {
			settings = new GLib.Settings("de.hannenz.lipsum");
			// settings.bind("lorem", generator, "start_with_lorem_ipsum", GLib.SettingsBindFlags.DEFAULT);
			// settings.bind("count", generator, "count", GLib.SettingsBindFlags.DEFAULT);
			// settings.bind("html", generator, "html", GLib.SettingsBindFlags.DEFAULT);
		}





		public override void startup() {
			base.startup();

			var action = new GLib.SimpleAction("quit", null);
			action.activate.connect(quit);
			add_action(action);

			set_accels_for_action("app.quit", { "<Control>q" });

			var builder = new Gtk.Builder.from_resource("/de/hannenz/lipsum/data/ui/menu.ui");
			var app_menu = builder.get_object("appmenu") as GLib.MenuModel;

			set_app_menu(app_menu);
		}



		protected override void activate() {

			if (this.window == null) {
				this.window = new Window(this, generator);
			}
			window.present();
		}
	}
}
