#!/usr/bin/env raku

use v6;

use GD;

my $file = $*PROGRAM.parent.add("images/test_polygon.png");

if GD::Image.new(300, 300) -> $image {

    my $black = $image.colorAllocate("#000000");
    my $white = $image.colorAllocate("#ffffff");
    my $red = $image.colorAllocate("#ff0000");
    my $green = $image.colorAllocate("#00ff00");
    my $blue = $image.colorAllocate("#0000ff");

    $image.rectangle(
        location => (0, 0),
        size     => (300, 300),
        fill     => True,
        color    => $green);

    $image.rectangle(
        location => (10, 10),
        size     => (100, 100),
        color    => $red);

# triangle

    my Int @points = (
    10, 20,		# first point
    100, 10,	# second point
    60, 100);	# third point

    my $storage = $image.polygon(
        points => @points,
        open   => False,
        fill   => False,
        color  => $blue);


    $file.unlink;

    my $png_fh = $image.open($file, "wb");

    $image.output($png_fh, GD_PNG);

    $png_fh.close;
    $image.destroy();
}
