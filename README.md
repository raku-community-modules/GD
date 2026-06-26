[![Actions Status](https://github.com/raku-community-modules/GD/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/GD/actions)

NAME
====

Raku interface to the Gd graphics library.

DESCRIPTION
===========

Raku interface to Thomas Boutell's gd graphics library. GD allows you to create color drawings using a large number of graphics primitives, and emit the drawings in multiple formats.

You will need the Linux gd-libgd library or MacOS gd2 port installed in order to use GD (preferably a recent version).

SYNOPSIS
========

```raku
use GD;

if GD::Image.new(200, 200) -> $image {

    my $black = $image.colorAllocate(
      red => 0, green => 0, blue => 0
    );

    my $white = $image.colorAllocate(
      red => 255, green => 255, blue => 255
    );

    my $red   = $image.colorAllocate("#ff0000");
    my $green = $image.colorAllocate("#00ff00");
    my $blue  = $image.colorAllocate(0x0000ff);

    $image.rectangle(
      location => (10, 10),
      size     => (100, 100),
      fill     => True,
      color    => $white
    );

    $image.line(
      start => (10, 10),
      end   => (190, 190),
      color => $black
    );

    my $png_fh = $image.open("test.png", "wb");

    $image.output($png_fh, GD_PNG);

    $png_fh.close;

    $image.destroy();
}
```

API REFERENCE
=============

The Raku API

Color Control
-------------

### `colorAllocate`

Drawing Commands
----------------

### `pixel`

### `set-style`

### `setThickness`

### `line`

### `rectangle`

### `arc`

### `circumference`

### `ellipse`

### `polygon`

### `string`

Output Methods
--------------

### `open`

### `output`

Blob Generation Methods
-----------------------

### `bmp`

### `gd`

### `gif`

### `jpeg`

### `png`

### `tiff`

### `webp`

Fonts
-----

### `GD-giant-font`

### `GD-large-font`

### `GD-medium-bold-font`

### `GD-small-font`

### `GD-tiny-font`

Memory Management
-----------------

### `destroy`

AUTHORS
=======

  * Henrique Dias

  * Raku Community

SEE ALSO
========

[GD Source Repository](https://github.com/libgd).

[Alternate Raku module linking to GD](https://raku.land/zef:raku-community-modules/GD::Raw)

A few examples and a few development notes: [https://github.com/jforget/raku-sandbox-GD/](https://github.com/jforget/raku-sandbox-GD/)

COPYRIGHT AND LICENSE
=====================

Copyright 2013 Henrique Dias

Copyright 2014 - 2026 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

