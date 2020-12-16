/**
 * LipsumDocklet
 *
 * @author Johannes Braun <johannes.braun@hannenz.de>
 * @package lipsum
 * @version 2020-11-16
 */

public static void docklet_init(Plank.DockletManager manager) {
	manager.register_docklet(typeof(Lipsum.LipsumDocklet));
}

namespace Lipsum {

	/**
	 * Resource path for the icon
	 */
	public const string G_RESOURCE_PATH = "/de/hannenz/lipsum";


	public class LipsumDocklet : Object, Plank.Docklet {

		public unowned string get_id() {
			return "lipsum";
		}

		public unowned string get_name() {
			return "Lipsum";
		}

		public unowned string get_description() {
			return "Generate placeholder text (lorem ipsum)";
		}

		public unowned string get_icon() {
			return "resource://" + Lipsum.G_RESOURCE_PATH + "/src/docklet/icons/lipsum_icon.svg";
		}

		public bool is_supported() {
			return false;
		}

		public Plank.DockElement make_element(string launcher, GLib.File file) {
			return new LipsumDockItem.with_dockitem_file(file);
		}
	}
}
