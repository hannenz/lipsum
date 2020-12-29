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

	protected override void activate() {

		var gtk_settings = Gtk.Settings.get_default();
		gtk_settings.gtk_application_prefer_dark_theme = settings.get_boolean("dark-style");

		var provider = new Gtk.CssProvider();
		provider.load_from_resource("/de/hannenz/lipsum/styles/global.css");
		Gtk.StyleContext.add_provider_for_screen(
			Gdk.Screen.get_default(),
			provider,
			Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
		);


		var window = new Lipsum.Window(this);
		add_window(window);

	}
}
