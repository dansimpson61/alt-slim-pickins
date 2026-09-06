# The Slim-Pickins Way: Idiomatic App Design

## The Mental Model

Slim-Pickins is designed to make a view's structure read like a human outline, unpolluted by presentation details like CSS classes, IDs, or HTML attributes. We extend the language instead of working around it. Escape hatches (like `tag` or `class:`) are for emergencies. 

The mental model for designing apps in Slim-Pickins revolves around a few key conventions:

1. **A Word is a Word is a Word:** There is no structural difference between a built-in core language primitive (`page`, `box`), a built-in UI component (`section`, `card`), or an app-specific partial (`editor`, `preview`). They all share the same rights, privileges, and syntax.
2. **The Single Source of Truth:** Every word has exactly one definition. For primitives, it is the method implementation in `words.rb` alongside its declarative preamble. For partials (both core and app-specific), the `.sp` file *is* the contract, defined entirely by its preamble.
3. **Automatic Class Inference:** When a `.sp` file is rendered, its root enclosing element automatically inherits a CSS class matching the partial's name. You don't need to manually inject `class: "editor"` — you simply create an `editor.sp` partial, and the language infers the class for you.
4. **Grow the Language:** If a layout requires a semantic element that doesn't exist, we don't fall back to `tag iframe`. We create an `iframe.sp` or `iframe` Ruby primitive. We expand the vocabulary to meet the domain's needs.

## The Design Process (Top-Down Outlining)

This model enables a top-down design process where you write the ideal semantic outline first, then define the words you just invented.

**Step 1: Write the Outline**
You sketch the view using domain-specific words that don't exist yet. The view becomes a pure semantic map of the page:
```slim-pickins
# index.sp
page "Slim-Pickins Studio"
  vocabulary 
  editor
  preview
```

**Step 2: Define the Words**
For each invented word, you create a `.sp` partial. This recursively builds out the UI.
```slim-pickins
# editor.sp
section
  heading "Write .sp Code"
  editor_nav
  editor_form
```

**Step 3: Let the Runtime Handle Presentation**
Because of Convention 3, when `index.sp` calls `editor`, the runtime wraps the output of `editor.sp` in a bounding box that automatically receives the `editor` class (`<section class="editor">`). 

The stylesheet can now target `.editor` directly, without the author ever writing the word `class` in the view logic.
