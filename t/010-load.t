use v6;

use Test;

use GD;

ok 1, 'GD is loaded successfully';

my $file = $*PROGRAM.parent.add('test.png');

my $image = GD::Image.new(200, 200);
isa-ok $image, GD::Image, "Successfully created a GD::Image";

my ( $white, $black );

lives-ok {
    ok ($black = $image.colorAllocate(
        red   => 0,
        green => 0,
        blue  => 0)).defined, "colorAllocate with named arguments";

    ok $white = $image.colorAllocate("#ffffff"), "colorAllocate with hex colour";
}, 'Colors created successfully';


lives-ok {
    $image.rectangle(
        location => (10, 10),
        size     => (100, 100),
        fill     => True,
        color    => $white);
}, 'rectangle';


lives-ok {
$image.line(
    start => (10, 10),
    end   => (190, 190),
    color => $black);
}, 'line';

$file.unlink;

my $png_fh = $image.open($file.Str, "wb");

$image.output($png_fh, GD_PNG);

$png_fh.close;

ok $file.e, "Some sort of test.png written";

lives-ok {
    $image.destroy();
}, 'Survived $image.destroy';

$file.unlink;

done-testing;
