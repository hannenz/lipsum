public class Application : Gtk.Application {

	public static GLib.Settings settings;


	/**
	 * @var Generator  A lipsum generator instance
	 */
	public Lipsum.Generator generator;


	static construct {
		settings = new GLib.Settings("de.hannenz.lipsum");
	}

	public Application.with_generator(Lipsum.Generator generator) {
		Object (
			application_id: "de.hannenz.lipsum",
			flags: ApplicationFlags.FLAGS_NONE
		);
		this.generator = generator;
	}


	private void preferences() {
	}


	public override void startup() {
		base.startup();

		var action = new GLib.SimpleAction("preferences", null);
		action.activate.connect(preferences);
		add_action(action);

		action = new GLib.SimpleAction("quit", null);
		action.activate.connect(quit);
		add_action(action);

		set_accels_for_action("app.quit", { "<Control>q" });

		var builder = new Gtk.Builder.from_resource("/de/hannenz/lipsum/data/ui/menu.ui");
		var app_menu = builder.get_object("appmenu") as GLib.MenuModel;


		set_app_menu(app_menu);
	}


	protected override void activate() {

		var gtk_settings = Gtk.Settings.get_default();
		gtk_settings.gtk_application_prefer_dark_theme = settings.get_boolean("dark-style");

		var provider = new Gtk.CssProvider();
		provider.load_from_resource("/de/hannenz/lipsum/data/styles/global.css");
		Gtk.StyleContext.add_provider_for_screen(
			Gdk.Screen.get_default(),
			provider,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
		);


		var window = new Lipsum.Window(this);
		add_window(window);

	}
}
