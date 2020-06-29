use v6;

use Test;

my $file = $*PROGRAM.parent.add('test.png');

$file.unlink;

lives-ok {
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

      my $png_fh = $image.open($file.Str, "wb");

      $image.output($png_fh, GD_PNG);

      $png_fh.close;

      $image.destroy();
   }
}, "synopsis code ran okay";

ok $file.e, "and the output file was created";

$file.unlink;

done-testing;
