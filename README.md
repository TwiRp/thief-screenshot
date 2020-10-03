# Thief Screenshot

This is a tool for generating screenshots of GtkSourceView Styles generated with [Theme Generator](https://github.com/ThiefMD/theme-generator). It is used to populate the images for [thief-themes](https://github.com/ThiefMD/themes).

The code creates a Gtk.Window with a Gtk.SourceView with a theme rendered. It'll wait for a second for the window to render, then take a screenshot of the window from the screen. It repeats the process until it finishes making screenshots for all the themes in the [themes](https://github.com/ThiefMD/themes/tree/main/themes) directory.

For some reason, [Gtk.OffscreenWindow](https://valadoc.org/gtk+-3.0/Gtk.OffscreenWindow.html) did not render the syntax highlighting, but is useful in other scenarios.
