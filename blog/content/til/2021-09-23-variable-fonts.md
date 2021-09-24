+++
title = "Variable Fonts"
[taxonomies]
tags = ["Font", "Web"]
+++

TIL about [variable fonts](https://web.dev/variable-fonts/). Instead of having to load a bunch of (predefined) different font weights and styles into the browser, it's possible to use one variable font which contains parametrisation for how the font looks at different weights.

Instead of:
```css
@font-face {
  font-family: "Rubik";
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url(/fonts/Rubik-Regular.woff2) format("woff2");
}
@font-face {
  font-family: "Rubik";
  font-style: normal;
  font-weight: 500;
  font-display: swap;
  src: url(/fonts/Rubik-Medium.woff2) format("woff2");
}
```

You can use:
```css
@font-face {
  font-family: "Rubik";
  font-style: normal;
  font-weight: 400 500;
  font-display: swap;
  src: url(/fonts/Rubik-VariableFont.woff2) format("woff2-variations");
}
```

Interestingly, while the `web.dev` site I linked to above suggests to use `format("woff2 supports variations")`, Mozilla's [documentation](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Fonts/Variable_Fonts_Guide) on the topic suggest to stick with `format("woff2-variations")`.

