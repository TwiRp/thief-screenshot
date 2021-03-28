using Gdk;
using ThiefMD.Enrichments;
namespace ThiefMD {
    public const int ss_width = 550;
    public const int ss_height = 275;

    public class CssPreviewer : Gtk.Window {
        private Preview view;
        private string dir;
        private string theme_path;
        public File theme_file;
        private string filter;

        public CssPreviewer (string theme, string type) {
            stdout.printf ("  Generating %s\n", theme);
            dir = theme;
            filter = type;
            build_ui ();
        }

        private void build_ui () {
            theme_path = Path.build_path (Path.DIR_SEPARATOR_S, ".", "export-css", dir);
            theme_file = File.new_for_path (theme_path);
            print ("  Looking in %s\n", theme_file.get_path ());
            view = new Preview (dir, filter);
            view.update_html_view ();
            view.zoom_level = 0.5;

            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = view.am_dark;

            add (view);
            set_size_request (ss_width, ss_height);
            show_all ();
            if (filter != "preview") {
                set_title (gen_title (dir + "-" + filter));
            } else {
                set_title (gen_title (dir));
            }

            Timeout.add (1000, () => {
                try {
                    int x, y;
                    get_position (out x, out y);
                    warning ("At %d, %d", x, y);
                    Gdk.Pixbuf ss = Gdk.pixbuf_get_from_window (get_screen ().get_root_window (), x, y, ss_width, ss_height);
                    File org_check = File.new_for_path (Path.build_filename (theme_file.get_path (), filter + ".css"));
                    if (org_check.query_exists ()) {
                        File preview_exists = File.new_for_path (Path.build_filename (theme_file.get_path (), dir + "-preview.png"));
                        if (filter != "preview") {
                            ss.save (Path.build_filename (theme_file.get_path (), dir + "-" + filter + "-preview.png"), "png");
                        } else {
                            ss.save (Path.build_filename (theme_file.get_path (), dir + "-preview.png"), "png");
                        }
                        if (!preview_exists.query_exists ()) {
                            ss.save (Path.build_filename (theme_file.get_path (), dir + "-preview.png"), "png");
                        }
                    }
                } catch (Error e) {
                    warning ("Could not generate screenshot: %s", e.message);
                }
                destroy ();
                return false;
            });
        }

        private string gen_title (string title) {
            string current_title = title.replace ("_", " ");
            current_title = current_title.replace ("-", " ");
            string [] parts = current_title.split (" ");
            if (parts != null && parts.length != 0) {
                current_title = "";
                foreach (var part in parts) {
                    part = part.substring (0, 1).up () + part.substring (1).down ();
                    current_title += part + " ";
                }
                current_title = current_title.chomp ();
            }

            return current_title;
        }
    }

    public class ThemePreviewer : Gtk.Window {
        private Gtk.SourceView view;
        private Gtk.SourceBuffer buffer;
        private Gtk.SourceStyleSchemeManager preview_manager;
        private string dir;
        private string theme_path;
        public File theme_file;
        private string filter;

        public ThemePreviewer (string theme, string type) {
            stdout.printf ("  Generating %s\n", theme);
            dir = theme;
            filter = type;
            build_ui ();
        }

        private Gtk.SourceLanguageManager thief_languages;
        private Gtk.SourceLanguageManager get_language_manager () {
            if (thief_languages == null) {
                thief_languages = new Gtk.SourceLanguageManager ();
                string custom_languages = "/usr/local/share/com.github.kmwallio.thiefmd/gtksourceview-4/language-specs/";
                string[] language_paths = {
                    custom_languages
                };
                thief_languages.set_search_path (language_paths);
    
                var markdown = thief_languages.get_language ("markdown");
                if (markdown == null) {
                    warning ("Could not load custom languages");
                    thief_languages = Gtk.SourceLanguageManager.get_default ();
                }
            }
    
            return thief_languages;
        }

        public Gtk.SourceLanguage get_source_language (string filename = "something.md") {
            var languages = get_language_manager ();
            Gtk.SourceLanguage? language = null;
            string file_name = filename.down ();
    
            if (file_name.has_suffix (".bib") || file_name.has_suffix (".bibtex")) {
                language = languages.get_language ("bibtex");
                if (language == null) {
                    language = languages.guess_language (null, "text/x-bibtex");
                }
            } else if (file_name.has_suffix (".fountain") || file_name.has_suffix (".fou") || file_name.has_suffix (".spmd")) {
                language = languages.get_language ("fountain");
                if (language == null) {
                    language = languages.guess_language (null, "text/fountain");
                }
            } else {
                language = languages.get_language ("markdown");
                if (language == null) {
                    language = languages.guess_language (null, "text/markdown");
                }
            }
    
            return language;
        }

        private void build_ui () {
            theme_path = Path.build_path (Path.DIR_SEPARATOR_S, ".", "themes", dir);
            theme_file = File.new_for_path (theme_path);
            print ("  Looking in %s\n", theme_file.get_path ());
            preview_manager = new Gtk.SourceStyleSchemeManager ();
            preview_manager.append_search_path (theme_file.get_path ());
            preview_manager.force_rescan ();

            view = new Gtk.SourceView ();
            view.margin = 0;
            buffer = new Gtk.SourceBuffer.with_language (get_source_language ("my.md"));

            var style = preview_manager.get_scheme (dir + "-" + filter);
            print ("  Loaded %s\n", style.get_id ());
            buffer.highlight_syntax = true;
            buffer.set_style_scheme (style);

            buffer.highlight_syntax = true;
            view.set_buffer (buffer);
            view.set_wrap_mode (Gtk.WrapMode.WORD);
            buffer.text = IPSUM.printf(gen_title (dir + "-" + filter));
            MarkdownEnrichment markdown = new MarkdownEnrichment (Path.build_path (Path.DIR_SEPARATOR_S, ".", "themes", dir) + "/" + dir + "-" + filter + ".xml");
            markdown.attach (view);
            markdown.recheck_all ();

            var preview_box = new Gtk.ScrolledWindow (null, null);
            preview_box.hexpand = true;
            preview_box.vexpand = true;

            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = (filter == "dark");

            preview_box.add (view);
            add (preview_box);
            set_size_request (ss_width, ss_height);
            show_all ();
            set_title (gen_title (dir + "-" + filter));

            Timeout.add (1000, () => {
                try {
                    int x, y;
                    get_position (out x, out y);
                    warning ("At %d, %d", x, y);
                    Gdk.Pixbuf ss = Gdk.pixbuf_get_from_window (get_screen ().get_root_window (), x, y, ss_width, ss_height);
                    ss.save (Path.build_filename (theme_file.get_path (), dir + "-" + filter + "-preview.png"), "png");
                } catch (Error e) {
                    warning ("Could not generate screenshot: %s", e.message);
                }
                destroy ();
                return false;
            });
        }

        private string gen_title (string title) {
            string current_title = title.replace ("_", " ");
            current_title = current_title.replace ("-", " ");
            string [] parts = current_title.split (" ");
            if (parts != null && parts.length != 0) {
                current_title = "";
                foreach (var part in parts) {
                    part = part.substring (0, 1).up () + part.substring (1).down ();
                    current_title += part + " ";
                }
                current_title = current_title.chomp ();
            }

            return current_title;
        }
    }

    public class ThiefShot : Gtk.Application {
        public ThiefShot () {
            Object (
                application_id: "thiefshot",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        public void work () {
            try {
                Gee.LinkedList<string> todo = new Gee.LinkedList<string>();
                Dir theme_dir = Dir.open ("./themes", 0);
                string? file_name = "";
                while ((file_name = theme_dir.read_name ()) != null) {
                    string path = Path.build_filename ("./themes", file_name);
                    if (!file_name.has_prefix (".") && FileUtils.test(path, FileTest.IS_DIR)) {
                        todo.add (file_name);
                    }
                }

                Gee.LinkedList<string> also_todo = new Gee.LinkedList<string>();
                theme_dir = Dir.open ("./export-css", 0);
                while ((file_name = theme_dir.read_name ()) != null) {
                    string path = Path.build_filename ("./export-css", file_name);
                    if (!file_name.has_prefix (".") && FileUtils.test(path, FileTest.IS_DIR)) {
                        also_todo.add (file_name);
                    }
                }

                work_it (todo, also_todo);

            } catch (Error e) {
                warning ("Could not parse themes: %s", e.message);
            }
        }

        public void work_it2 (Gee.LinkedList<string> items) {
            if (items.is_empty) {
                return;
            }

            string dir = items.poll ();
            CssPreviewer preview = new CssPreviewer (dir, "preview");
            preview.destroy.connect (() => {
                CssPreviewer preview2 = new CssPreviewer (dir, "print");
                preview2.destroy.connect (() => {
                    work_it2 (items);
                });
            });
        }

        public void work_it (Gee.LinkedList<string> items, Gee.LinkedList<string> items2) {
            if (items.is_empty) {
                work_it2 (items2);
                return;
            }

            string dir = items.poll ();
            ThemePreviewer preview = new ThemePreviewer (dir, "dark");
            preview.destroy.connect (() => {
                ThemePreviewer preview2 = new ThemePreviewer (dir, "light");
                preview2.destroy.connect (() => {
                    work_it (items, items2);
                });
            });
        }

        public void parse_dir (string dir) throws Error {
            ThemePreviewer preview = new ThemePreviewer (dir, "dark");
            preview.destroy.connect (() => {
                ThemePreviewer preview2 = new ThemePreviewer (dir, "light");
                preview2.destroy.connect (() => {
                    warning ("done");
                });
            });
        }

        protected override void activate () {
            var main_window = new Gtk.ApplicationWindow (this);
            Gtk.Label label = new Gtk.Label ("Working...");
            main_window.add (label);
            main_window.set_size_request (1200, 1200);
            main_window.show_all ();
            work ();
            label.set_label ("Done.");
        }

        public static int main (string[] args) {
            var app = new ThiefShot ();
            return app.run (args);
        }
    }
}