# The classic UI's frame: its assets, once, and nothing else.
#
# The pages draw their own `sidebar_layout` — that is this UI's design — so the
# layout holds only what every one of them would otherwise repeat. Assets are
# exactly that: a page cannot say them once, and `page` infers this file, so
# they are said here rather than on five pages.
stylesheet "/assets/slim-pickins.css"
script "/assets/stimulus.umd.js"
script "/assets/studio.js"
contents
