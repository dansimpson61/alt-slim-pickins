expects shape: encloses

# What one node's card says: what it is, what it carries, and who decided.
title named, .named
span word, .variant
box
  heading "Node attributes"
  list
    each row, from: .facts
      item
        span attribute, .attribute
        snippet value, .value
box
  heading "Inference decisions and conventions"
  list
    each why, from: .why
      item
        span name, .name
        # The four grades are exhaustive — the register has exactly four — so there
        # is no `otherwise`. A branch that cannot be reached is a dead guard, and
        # its badge variant would be a rule nothing could ever style.
        choose
          when .structural?
            badge structural, .owner
          when .shape?
            badge shape, .owner
          when .domain?
            badge domain, .owner
          when .axiomatic?
            badge axiomatic, .owner
        text .decides
        fact silent, .when_silent
        snippet override, .override
