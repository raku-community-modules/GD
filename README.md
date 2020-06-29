[![Build Status](https://travis-ci.org/raku-community-modules/raku-GD.svg)](https://travis-ci.org/raku-community-modules/raku-GD)

raku-GD
========

![GD Logo](logotype/logo_32x32.png)  
Raku interface to the Gd graphics library.

Description
-----------
Raku interface to Thomas Boutell's [gd graphics library][2]. GD allows you to create color drawings using a large number of graphics primitives, and emit the drawings in multiple formats.
You will need the Linux `gd-libgd` library or OS X `gd2` port installed in order to use raku-GD (preferably a recent version).

Synopsis
--------

WARNING: This module is Work in Progress, which means: this interface is not final. This will perhaps change in the future.  
A sample of the code can be seen below.

	use GD;

	if GD::Image.new(200, 200) -> $image {

      my $black = $image.colorAllocate(
         red   => 0,
         green => 0,
         blue  => 0);

      my $white = $image.colorAllocate(
         red   => 255,
         green => 255,
         blue  => 255);

      my $red = $image.colorAllocate("#ff0000");
      my $green = $image.colorAllocate("#00ff00");
      my $blue = $image.colorAllocate(0x0000ff);

      $image.rectangle(
         location => (10, 10),
         size     => (100, 100),
         fill     => True,
         color    => $white);

      $image.line(
         start => (10, 10),
         end   => (190, 190),
         color => $black);

      my $png_fh = $image.open("test.png", "wb");

      $image.output($png_fh, GD_PNG);

      $png_fh.close;

      $image.destroy();
   }


Installation
------------

Assuming you have a working Rakudo install (and you have the GD library installed as described above,) you should be able to do:

    zef install GD

Or if you have a local copy of this repository:

    zef install .


Support
-------

Please report any bugs or send any patches on [Github](https://github.com/raku-community-modules/raku-GD/issues)


Authors
------

Henrique Dias
Raku Community Module Authors

See Also
--------
* [GD Raku Module Documentation][1]  
* [GD Source Repository][2]
* [C examples from GD source repository][3]

License
-------

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

Please see the [LICENCE](LICENCE) in the source directory for full details.

[1]: lib/GD.pod "GD Perl6 Module Documentation"
[2]: https://bitbucket.org/pierrejoye/gd-libgd "GD Source Repository"
[3]: https://bitbucket.org/pierrejoye/gd-libgd/src/2b8f5d19e0c9/examples "C examples from GD source repository"
