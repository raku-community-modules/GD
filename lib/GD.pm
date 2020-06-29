use v6;

use NativeCall :TEST, :DEFAULT;
use NativeHelpers::Array;
use LibraryCheck;

enum GD_Format <GD_GIF GD_JPEG GD_PNG>;

module GD {

    my Str $lib;

    sub find-lib-version() {
        $lib //= do {
            my Str $name = 'gd';
            my Int $lower = 2;
            my Int $upper = 6;

            my $lib;

            for $lower .. $upper -> $version-number {
                my $version = Version.new($version-number);

                if library-exists($name, $version) {
                    $lib =  guess_library_name($name, $version) ;
                    last;
                }
            }
            $lib;
        }
    }

    constant LIB =  &find-lib-version;


    my $errno := cglobal(Str, 'errno', int32);

    class File is repr('CPointer') {

        class X::GD::File is Exception {
            has Int $.errno     is required;
            has Str $.filename  is required;

            has Str $!message;

            method message( --> Str) {
                $!message //= self!strerror ~ " while opening { $!filename } ({ $!errno })";
            }

            method Str( --> Str ) {
                self.message;
            }

            sub strerror_r(int32, CArray[uint8] $buf is raw, size_t $buflen --> CArray[uint8]) is native { * }

            method !strerror(--> Str) {
                my $array = CArray[uint8].allocate(256);
                my $out = strerror_r($!errno, $array, $array.elems);

                my $buff = copy-carray-to-buf($out, $array.elems);
                my $i = 0;
                for $buff.list -> $byte {
                    last if !$byte;
                    $i++;
                }

                $buff.subbuf(0, $i).decode;
            }
        }


        sub fopen(Str, Str --> GD::File ) is native { ... }

        sub fclose(GD::File $filepointer) is native { ... }

        method new(Str() $filename, Str $mode --> GD::File ) {
            if fopen($filename, $mode) -> $fh {
                $fh
            }
            else {
                die X::GD::File.new(:$errno, :$filename);
            }
        }

        method close() {
            fclose(self) if self;
        }
    }

    class Image is repr('CPointer') {

        # This is pretty ugly so I'm looking for a more elegant solution...
        sub GD_add_point(CArray[int32] $points, int32 $idx, int32 $x, int32 $y) {
            $points[$idx * 2] = $x;
            $points[$idx * 2 + 1] = $y;
        }

        sub GD_new_set_of_points( Int $size --> CArray[int32] ) {
            CArray[int32].allocate($size * 2);
        }

        sub gdImageGif(GD::Image, GD::File) is native(LIB) { ... };

        sub gdImageJpeg(GD::Image, GD::File, int32) is native(LIB) { ... };

        sub gdImagePng(GD::Image, GD::File) is native(LIB) { ... };

        sub gdImageCreate(int32, int32 --> GD::Image ) is native(LIB) { ... };

        sub gdImageColorAllocate(GD::Image, int32, int32, int32 --> int32 ) is native(LIB) { ... };

        sub gdImageSetPixel(GD::Image, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImageLine(GD::Image, int32, int32, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImageFilledRectangle(GD::Image, int32, int32, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImageRectangle(GD::Image, int32, int32, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImageFilledArc(GD::Image, int32, int32, int32, int32, int32, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImageArc(GD::Image, int32, int32, int32, int32, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImageEllipse(GD::Image, int32, int32, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImageFilledEllipse(GD::Image, int32, int32, int32, int32, int32)
            is native(LIB) { ... };

        sub gdImagePolygon(GD::Image, CArray[int32], int32, int32)
            is native(LIB) { ... };

        sub gdImageOpenPolygon(GD::Image, CArray[int32], int32, int32)
            is native(LIB) { ... };

        sub gdImageFilledPolygon(GD::Image, CArray[int32], int32, int32)
            is native(LIB) { ... };

        sub gdFree(OpaquePointer)
            is native(LIB) { ... };

        sub gdImageDestroy(GD::Image)
            is native(LIB) { ... };

        ### METHODS ###

        method new(Int $width, Int $height) {
            gdImageCreate($width, $height);
        }

        multi method colorAllocate( Int :$red! where 0..255, Int :$green! where 0..255, Int :$blue! where 0..255) returns Int {

            gdImageColorAllocate(self, $red, $green, $blue);
        }

        multi method colorAllocate(Str $hexstr where /^ '#' <[A..Fa..f\d]>**6 $/) returns Int {

            my $red = ("0x" ~ $hexstr.substr(1,2)).Int;
            my $green = ("0x" ~ $hexstr.substr(3,2)).Int;
            my $blue = ("0x" ~ $hexstr.substr(5,2)).Int;

            gdImageColorAllocate(self, $red, $green, $blue);
        }

        multi method colorAllocate(Int $hex_value where { $hex_value >= 0 }) returns Int {

            my $red = (($hex_value +> 16) +& 0xFF).Int;
            my $green = (($hex_value +> 8) +& 0xFF).Int;
            my $blue = (($hex_value) +& 0xFF).Int;

            return gdImageColorAllocate(self, $red, $green, $blue);
        }

        method pixel(
            Int $x where { $x >= 0 },
            Int $y where { $y >= 0 },
            Int $color where { $color >= 0 } = 0) {

            gdImageSetPixel(self, $x, $y, $color);
        }

        method line(
            List :$start (Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
            List :$end! (Int $x2 where { $x2 >= 0 }, Int $y2 where { $y2 >= 0 }),
               Int :$color where { $color >= 0 } = 0) {

            gdImageLine(self, $x1, $y1, $x2, $y2, $color);
        }

        method rectangle(
            List :$location (Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
            List :$size! (Int $x2 where { $x2 > 0 }, Int $y2 where { $y2 > 0 }),
               Int :$color where { $color >= 0 } = 0,
              Bool :$fill = False) {

            $fill ??
                gdImageFilledRectangle(self, $x1, $y1, $x2, $y2, $color) !!
                gdImageRectangle(self, $x1, $y1, $x2, $y2, $color);
        }

        # style to enum
        method arc(
            List :$center!(Int $cx, Int $cy),
            List :$amplitude!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
            List :$aperture!(Int $s, Int $e),
               Int :$color where { $color >= 0 } = 0,
              Bool :$fill = False,
               Int :$style = 0) {

            $fill ??
                gdImageFilledArc(self, $cx, $cy, $w, $h, $s, $e, $color, $style) !!
                gdImageArc(self, $cx, $cy, $w, $h, $s, $e, $color);
        }

        method ellipse(
            List :$center!(Int $cx, Int $cy),
            List :$axes!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
               Int :$color where { $color >= 0 } = 0,
              Bool :$fill = False) {

            $fill ??
                gdImageFilledEllipse(self, $cx, $cy, $w, $h, $color) !!
                gdImageArc(self, $cx, $cy, $w, $h, 0, 0, $color);
        }

        method circumference(
            List :$center!(Int $cx, Int $cy),
               Int :$diameter! where { $diameter > 0 },
               Int :$color where { $color >= 0 } = 0,
              Bool :$fill = False) {

            $fill ??
                gdImageFilledEllipse(self, $cx, $cy, $diameter, $diameter, $color) !!
                gdImageArc(self, $cx, $cy, $diameter, $diameter, 0, 0, $color);
        }

        method polygon( Int :@points! where { @points.elems >= 6 && @points.elems % 2 == 0 }, Int :$color where { $color >= 0 } = 0, Bool :$fill = False, Bool :$open = False --> CArray[int32] ) {

            my $n_array = @points.elems;
            my $gdPoints = GD_new_set_of_points(($n_array/2).Int);

            my $n = 0;
            for @points -> $x, $y {
                GD_add_point($gdPoints, $n, $x, $y);
                $n++;
            }

            $fill ??
                gdImageFilledPolygon(self, $gdPoints, $n, $color) !!
                $open ??
                    gdImageOpenPolygon(self, $gdPoints, $n, $color) !!
                    gdImagePolygon(self, $gdPoints, $n, $color);

            return $gdPoints;
        }

        method open(Str() $filename, Str $mode --> GD::File ) {
            GD::File.new($filename, $mode);
        }

        method output(GD::File $filepointer, GD_Format $format, Int $quality = -1) {
            given $format {
                gdImageGif(self, $filepointer) when GD_GIF;
                gdImageJpeg(self, $filepointer, $quality) when GD_JPEG;
                gdImagePng(self, $filepointer) when GD_PNG;
            }
        }

        method destroy() {
            gdImageDestroy(self);
        }
    }
}
