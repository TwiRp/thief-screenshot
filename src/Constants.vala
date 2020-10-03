using Gtk;
using Gdk;

namespace ThiefMD {
    public const string IPSUM = """# %s
*Emphasized* text. **Strong** text. [Link to page](https://github.com)
## Lists

1. First item
2. Second item
3. Third item

> Block Quote
> - Famous Amos

* First item
* `Second` item
* Third item

***

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
}