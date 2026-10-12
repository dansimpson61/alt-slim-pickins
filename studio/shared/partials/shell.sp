# The app's outer frame: the element a UI's zones are laid out inside.
#
# It is named for what it is, not for where anything sits. Its old name — a
# "sidebar" — described a screen position, which is the leak this vocabulary
# refuses: presentation belongs to the `.spiff` companion, and a word in a
# page says what a thing *is*. The compiler's surface kinds agree; a shell
# surface is what this wrapper makes real.
def shell
  box
    children

