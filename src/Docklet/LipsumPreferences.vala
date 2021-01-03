using Plank;

namespace Lipsum {

	public class LipsumPreferences : DockItemPreferences {

		public LipsumPreferences.with_file(GLib.File file) {
			base.with_file(file);
		}

		protected override void reset_properties() {
		}
	}
}
