
argv -> RootParser -> Argument/Parser




Argument::
    short: ?Str = null
    long: ?Str = null
    action: Action = .store
    nargs: u8 = 1
    extend: bool = false
    value: ?Str = null
    default: ?Str = null
    required: bool = false
    choices: ?[]Str = null
    help: ?Str = null

Parser::
    arguments: ArrayList(Argument)

