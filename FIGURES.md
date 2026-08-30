# A page with figures — the vocabulary's third test

Modelled on the dashboard's UI review passes: `~/dev/.ocr/` holds a screenshot
of every dashboard surface, captured during review, and `dashboard/docs/`
holds the written findings. A page that puts those together is the one
genuinely figure-heavy page this workspace has.

This test exists because `image` and `icon` had survived two pages without
ever being used, and an unexercised entry is an unverified one — `list` was
wrong for exactly that reason and nobody noticed until it appeared.

## The page

```
page review, "Dashboard UI review"
  stylesheet "/css/review.css"

  nav breadcrumb
    link home, "Studio"

  fact reviewed_on, .reviewed_on
  fact reviewer

  prose .introduction

  grid metrics, columns: 3
    metric surfaces_reviewed, "Surfaces"
    metric findings_open, "Open findings"
    metric worst_severity, "Worst severity"

  section surfaces, "Every surface, as reviewed"
    empty "No screenshots captured yet."

    each surface
      card
        title .name

        figure .caption
          image .screenshot, alt: .name

        list plain
          each finding
            item
              icon .severity
              badge .severity
              text .summary
              fact surface, surface.name

        actions
          link open, "Open the live page"

  section "Reading the severities"
    list plain
      item
        icon blocker
        text "Blocks the task outright."
      item
        icon warning
        text "Works, but costs the reader."
      item
        icon polish
        text "Cosmetic."

  footer "Screenshots are captured during review passes and are regenerable."
```

Thirty-nine sentences.

## What it exercised

**`image` works as drafted and needed no change.** `image .screenshot, alt:
.name` is the whole of it — the source as content, the alternative text as a
modifier, and lazy loading inferred. Two pages of not being used had not
hidden a defect.

**`icon` works and gained evidence for its inference.** The legend section is
the case the entry anticipated: `icon blocker` standing alone beside text,
versus `icon .severity` sitting inside a list item that also carries a badge
and a summary. The entry says an icon is decorative and hidden from screen
readers unless it is the only content of a control, and both uses here are
decorative, because the severity is also stated in the badge. That is the
inference doing real work rather than being asserted.

**Reaching out by name held up under two levels.** `fact surface,
surface.name` sits inside `each finding` inside `each surface`, and takes the
outer binding by name while `.severity` and `.summary` take the inner subject.
This is the third page to use the mechanism and the first to need it.

## One wall

### No word for an image with a caption

`image` has `alt:` — the text that stands *in place of* the picture — but
nothing for the text that sits *beside* it. Those are different things, and
a review page is all caption.

**Added `figure`.** The shape that matters is which way round it goes: the
caption is the content and the thing figured is the child.

```
figure "The triage view, before the fix"
```

That way a figure can hold a `chart` or a `snippet` as easily as an `image`,
which is what HTML's `<figure>` has always meant. Had `image` simply gained a
`caption:` modifier, the word would have rendered two different things
depending on whether a modifier were present, and figures of charts would have
been unreachable.

Only one wall on this page, against three for the portfolio and six for the
content page. The vocabulary is converging, which is the first evidence that
it is approaching complete rather than merely growing.

## Still standing

- **The `?` case.** Three real pages now, and not one of them reached it —
  every condition has been about the subject and carried a dot. Three misses
  is no longer weak evidence. It may be that a bare helper used as a value is
  a thing this language simply does not need, and the honest next move is to
  decide that deliberately rather than leave the hole listed forever.
- **`chart` is still a guess.** It has now gone three pages without a
  page that charts anything seriously. The portfolio used two shapes; nothing
  has tested axes, legends, scales or a second series.
