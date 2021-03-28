using Gtk;
using Gdk;
using WebKit;

namespace ThiefMD {
    public const string IPSUM = """# %s
*Emphasized* text. **Strong** text. [Link to page](https://github.com)
## Lists
1. First item
2. Second item
3. Third item
> Block Quote
> - Famous Amos
```vala
    switch (target_type) {
        case Target.STRING:
            selection_data.set (
                selection_data.get_target(),
                BYTE_BITS,
                (uchar [])_sheet_path.to_utf8());
        break;
        default:
            warning ("No known action to take.");
        break;
    }
```

### Markdown Rendered Image

![](/images/image.jpg)

### Tables

| Syntax | Description |
| ----------- | ----------- |
| Header | Title |
| Paragraph | Text | 

Here's a sentence with a footnote. [^1]

I'm basically ~~stealing~~ copying and pasting examples from [https://www.markdownguide.org/cheat-sheet](https://www.markdownguide.org/cheat-sheet).

[^1]: This is the footnote.

### Math

$$\int_{a}^{b} x^2 dx$$
""";
    public class Preview : WebKit.WebView {
        public string html;
        public string cssname = "";
        public string css_type = "";
        public bool am_dark = false;

        public Preview (string css_theme, string type) {
            Object(user_content_manager: new UserContentManager());
            cssname = css_theme;
            css_type = type;
            visible = true;
            vexpand = true;
            hexpand = true;
            var settingsweb = get_settings();
            settingsweb.enable_plugins = false;
            settingsweb.enable_page_cache = false;
            settingsweb.enable_developer_extras = false;
            settingsweb.javascript_can_open_windows_automatically = false;
            connect_signals ();

        }

        protected override bool context_menu (
            ContextMenu context_menu,
            Gdk.Event event,
            HitTestResult hit_test_result
        ) {
            return true;
        }

        public string set_stylesheet () {
            string style = "\n<style>\n";
            string file_contents = "";

            var file = File.new_for_path (Path.build_filename (".", "export-css", cssname, css_type + ".css"));
            if (file.query_exists ()) {
                GLib.FileUtils.get_contents (file.get_path (), out file_contents);
            }

            int total_votes = 0;
            int dark_votes = 0;

            try {
                Regex background_color = new Regex ("background(-color)?:\\s*#([0-9a-zA-Z]+);", RegexCompileFlags.MULTILINE | RegexCompileFlags.CASELESS, 0);
                background_color.replace_eval (
                    file_contents,
                    (ssize_t) file_contents.length,
                    0,
                    RegexMatchFlags.NOTEMPTY,
                    (match_info, result) =>
                    {
                        string? col = match_info.fetch (match_info.get_match_count () - 1);
                        if (col != null && col.chomp ().chug () != "") {
                            Clutter.Color color = Clutter.Color.from_string ("#" + col.chomp ().chug ());
                            float hue, lum, sat;
                            color.to_hls (out hue, out lum, out sat);
                            total_votes++;
                            if (lum < 0.5) {
                                dark_votes++;
                            }
                        }
                        return false;
                    });
            } catch (Error e) {
                warning ("Unable to parse color: %s", e.message);
            }

            if (total_votes != 0) {
                double sk = ((double) dark_votes) / ((double) total_votes);

                am_dark = sk > 0.5;
            } else {
                am_dark = false;
            }

            style += file_contents;
            style += "\n</style>\n";

            return style;
        }

        private void connect_signals () {
            create.connect ((navigation_action) => {
                launch_browser (navigation_action.get_request().get_uri ());
                return (Gtk.Widget) null;
            });

            decide_policy.connect ((decision, type) => {
                switch (type) {
                    case WebKit.PolicyDecisionType.NEW_WINDOW_ACTION:
                        if (decision is WebKit.ResponsePolicyDecision) {
                            WebKit.ResponsePolicyDecision response_decision = (decision as WebKit.ResponsePolicyDecision);
                            if (response_decision != null && 
                                response_decision.request != null)
                            {
                                launch_browser (response_decision.request.get_uri ());
                            }
                        }
                    break;
                    case WebKit.PolicyDecisionType.RESPONSE:
                        if (decision is WebKit.ResponsePolicyDecision) {
                            var policy = (WebKit.ResponsePolicyDecision) decision;
                            launch_browser (policy.request.get_uri ());
                            return false;
                        }
                    break;
                }

                return true;
            });

            load_changed.connect ((event) => {
                if (event == WebKit.LoadEvent.FINISHED) {
                    var rectangle = get_window_properties ().get_geometry ();
                    set_size_request (rectangle.width, rectangle.height);
                }
            });
        }

        private void launch_browser (string url) {
            if (!url.contains ("/embed/")) {
                try {
                    AppInfo.launch_default_for_uri (url, null);
                } catch (Error e) {
                    warning ("No app to handle urls: %s", e.message);
                }
                stop_loading ();
            }
        }

        public void update_html_view () {
            string stylesheet = set_stylesheet ();
            html = """
            <!doctype html>
            <html>
                <head>
                    <meta charset=utf-8>
                    %s
                </head>
                <body>
                <div class=markdown-body>
                <h1>%s</h1>

<p><em>Emphasized</em> text. <strong>Strong</strong> text. <a href="https://github.com">Link to page</a></p>

<h2>Lists</h2>

<ol>
<li>First item</li>
<li>Second item</li>
<li>Third item</li>
</ol>


<blockquote><p>Block Quote<br/>
- Famous Amos</p></blockquote>

<ul>
<li>First item</li>
<li><code>Second</code> item</li>
<li>Third item</li>
</ul>


<hr />

<pre><code class="vala  ">    switch (target_type) {  
case Target.STRING:  
    selection_data.set (  
        selection_data.get_target(),  
        BYTE_BITS,  
        (uchar [])_sheet_path.to_utf8());  
break;  
default:  
    warning ("No known action to take.");  
break;  
}  
</code></pre>

<h3>Markdown Rendered Image</h3>

<p><img src="/images/image.jpg" alt="" /></p>

<h3>Tables</h3>

<table>
<thead>
<tr>
<th> Syntax </th>
<th> Description </th>
</tr>
</thead>
<tbody>
<tr>
<td> Header </td>
<td> Title </td>
</tr>
<tr>
<td> Paragraph </td>
<td> Text </td>
</tr>
</tbody>
</table>


<p>Here&rsquo;s a sentence with a footnote. <sup id="fnref:1"><a href="#fn:1" rel="footnote">1</a></sup></p>

<p>I&rsquo;m basically <del>stealing</del> copying and pasting examples from <a href="https://www.markdownguide.org/cheat-sheet">https://www.markdownguide.org/cheat-sheet</a>.</p>

<h3>Math</h3>

<p>$$\int_{a}^{b} x^2 dx$$</p>
<div class="footnotes">
<hr/>
<ol>
<li id="fn:1">
This is the footnote.<a href="#fnref:1" rev="footnote">&#8617;</a></li>
</ol>
</div>

            </div>
                </body>
            </html>""".printf(stylesheet, gen_title(cssname));
            this.load_html (html, "file:///");
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
}