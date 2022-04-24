# argparse

An argument parser that is familiar to the python's
[argparse](https://docs.python.org/3/library/argparse.html).

## Features

- Does not allocate
- Positional arguments
- Both short (`-f`) and long (`--field`) arguments
- Store specific number of values, optionals (`?`), one-or-more (`+`), or
"anything" (`*`)
- Set default values
- Require an argument

## Usage

```zig

const std = @import("std");

pub fn main() !void {

}

```

This parser will only find and group the correct strings in the given `argv`.



## Drawbacks

- Cannot have "extend" feature
- You cannot change behaviour of `-h` and `--help`

