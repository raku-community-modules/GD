#!/usr/bin/env raku

use v6;

use GD;

my $file = $*PROGRAM.parent.add("images/test_noise.png");

if GD::Image.new(200, 200) -> $image {

    my $black = $image.colorAllocate("#000000");
    my $white = $image.colorAllocate("#ffffff");
    my $red = $image.colorAllocate("#ff0000");
    my $green = $image.colorAllocate("#00ff00");
    my $blue = $image.colorAllocate("#0000ff");
    my $yellow = $image.colorAllocate("#ffff00");
    my $violet = $image.colorAllocate("#ff00ff");

    my @colors = ($white, $red, $green, $blue, $yellow, $violet);

    $image.rectangle(
        location => (0, 0),
        size     => (200, 200),
        fill     => True,
        color    => $black);

    for 1..200 {
        my $x = (0 .. 200).pick;
        my $y = (0 .. 200).pick;
        $image.pixel($x, $y, @colors.pick);
    }

    $file.unlink;

    my $png_fh = $image.open($file, "wb");

    $image.output($png_fh, GD_PNG);

    $png_fh.close;

    $image.destroy();
}
