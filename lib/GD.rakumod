use NativeCall :TEST, :DEFAULT;
use NativeHelpers::Array:ver<0.0.6+>:auth<zef:jonathanstowe>;
use NativeHelpers::Blob:ver<0.1.12+>:auth<zef:raku-community-modules>;
use LibraryCheck:ver<0.0.12+>:auth<zef:jonathanstowe>;

our enum GD_Format <GD_GIF GD_JPEG GD_PNG>;
subset ColorValue of Int:D where 0 <= * <= 255;
subset PInt       of Int:D where * > 0;

module GD:ver<0.0.5> {

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
            has Int $.errno    is required;
            has Str $.filename is required;

            has Str $!message;

            method message(--> Str:D) {
                $!message //= self!strerror ~ " while opening { $!filename } ({ $!errno })";
            }

            method Str(--> Str:D) { self.message }

            sub strerror_r(
              int32, CArray[uint8] $buf is raw, size_t $buflen
            --> CArray[uint8]) is native {*}

            method !strerror(--> Str:D) {
                my $array = CArray[uint8].allocate(256);
                with strerror_r($!errno, $array, $array.elems) -> $out {
                    my $buff = copy-carray-to-buf($out, $array.elems);
                    my $i = 0;
                    for $buff.list -> $byte {
                        last if !$byte;
                        $i++;
                    }

                    $buff.subbuf(0, $i).decode;
                }
                else {
                    "Unknown error"
                }
            }
        }


        sub fopen(Str, Str --> GD::File ) is native { ... }

        sub fclose(GD::File $filepointer) is native { ... }

        method new(
          Str() $filename, Str $mode
        --> GD::File) {
            if fopen($filename, $mode) -> $fh {
                $fh
            }
            else {
                die X::GD::File.new(:$errno, :$filename);
            }
        }

        method close() { fclose(self) if self }
    }

    class Image is repr('CPointer') {

        # This is pretty ugly so I'm looking for a more elegant solution...
        sub GD_add_point(
          CArray[int32] $points, int32 $idx, int32 $x, int32 $y
        ) {
            $points[$idx * 2]     = $x;
            $points[$idx * 2 + 1] = $y;
        }

        sub GD_new_set_of_points( Int $size --> CArray[int32] ) {
            CArray[int32].allocate($size * 2);
        }

        sub gdImageGif(GD::Image, GD::File) is native(LIB) { ... }

        sub gdImageJpeg(GD::Image, GD::File, int32) is native(LIB) { ... }

        sub gdImagePng(GD::Image, GD::File) is native(LIB) { ... }

        sub gdImageBmpPtr(
          GD::Image $image,
          int32     $size is rw,
          int32     $compression
        --> OpaquePointer) is native(LIB) { ... }

        sub gdImageGdPtr(
          GD::Image $image, int32 $size is rw
        --> OpaquePointer) is native(LIB) { ... }

        sub gdImageGifPtr(
          GD::Image $image, int32 $size is rw
        --> OpaquePointer) is native(LIB) { ... }

        sub gdImageJpegPtr(
          GD::Image $image, int32 $size is rw, int32 $quality
        --> OpaquePointer) is native(LIB) { ... }

        sub gdImagePngPtr(
          GD::Image, int32 $size is rw
        --> OpaquePointer) is native(LIB) { ... };

        sub gdImagePngPtrEx(
          GD::Image $image, int32 $size is rw, int32 $compression
        -->  OpaquePointer) is native(LIB) { ... }

        sub gdImageTiffPtr(
          GD::Image $image, int32 $size is rw
        -->  OpaquePointer) is native(LIB) { ... }

        sub gdImageWebpPtr(
          GD::Image $image, int32 $size is rw
        -->  OpaquePointer) is native(LIB) { ... }

        sub gdImageWebpPtrEx(
          GD::Image $image, int32 $size is rw, int32 $quality
        -->  OpaquePointer) is native(LIB) { ... }

        sub gdImageCreate(
          int32, int32
        --> GD::Image) is native(LIB) { ... }

        sub gdImageColorAllocate(
          GD::Image, int32, int32, int32
        --> int32) is native(LIB) { ... }

        sub gdImageSetPixel(
          GD::Image, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImageSetThickness(
          GD::Image $im, int32 $thickness
        ) is native(LIB) {*}

        sub gdImageLine(
          GD::Image, int32, int32, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImageFilledRectangle(
          GD::Image, int32, int32, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImageRectangle(
          GD::Image, int32, int32, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImageFilledArc(
          GD::Image, int32, int32, int32, int32, int32, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImageArc(
          GD::Image, int32, int32, int32, int32, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImageEllipse(
          GD::Image, int32, int32, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImageFilledEllipse(
          GD::Image, int32, int32, int32, int32, int32
        ) is native(LIB) { ... }

        sub gdImagePolygon(
          GD::Image, CArray[int32], int32, int32
        ) is native(LIB) { ... }

        sub gdImageOpenPolygon(
          GD::Image, CArray[int32], int32, int32
        ) is native(LIB) { ... }

        sub gdImageFilledPolygon(
          GD::Image, CArray[int32], int32, int32
        ) is native(LIB) { ... }

        sub gdFree( OpaquePointer) is native(LIB) { ... }

        sub gdImageDestroy(GD::Image) is native(LIB) { ... }

        ### METHODS ###

        method new(Int:D $width, Int:D $height) {
            gdImageCreate($width, $height);
        }

        multi method colorAllocate(
          ColorValue :$red!,
          ColorValue :$green!,
          ColorValue :$blue!,
        --> Int:D) {
            gdImageColorAllocate(self, $red, $green, $blue)
        }

        multi method colorAllocate(
          Str:D $hexstr where /^ '#' <[A..Fa..f\d]>**6 $/
        --> Int:D) {
            my $red   = ("0x" ~ $hexstr.substr(1,2)).Int;
            my $green = ("0x" ~ $hexstr.substr(3,2)).Int;
            my $blue  = ("0x" ~ $hexstr.substr(5,2)).Int;

            gdImageColorAllocate(self, $red, $green, $blue)
        }

        multi method colorAllocate(
          Int:D $hex_value where { $hex_value >= 0 }
        --> Int:D) {
            my $red   = (($hex_value +> 16) +& 0xFF).Int;
            my $green = (($hex_value +> 8) +& 0xFF).Int;
            my $blue  = (($hex_value) +& 0xFF).Int;

            gdImageColorAllocate(self, $red, $green, $blue)
        }

        method pixel(UInt $x, UInt $y, UInt $color = 0) {
            gdImageSetPixel(self, $x, $y, $color)
        }

        method setThickness(UInt $thickness) {
            gdImageSetThickness(self, $thickness);
        }

        method line(
          List:D :$start (UInt $x1, UInt $y1) = (0, 0),
          List:D :$end!  (UInt $x2, UInt $y2),
          UInt   :$color = 0
        ) {
            gdImageLine(self, $x1, $y1, $x2, $y2, $color)
        }

        multi method rectangle(
          List:D :$location (UInt $x1, UInt $y1) = (0, 0),
          List:D :$size! (Int:D $dx, Int:D $dy),
          UInt   :$color = 0,
          Bool   :$fill
        ) {
            my Int $x2 = $x1 + $dx - 1;
            my Int $y2 = $y1 + $dy - 1;
            $x2 = $x1 + 1 + $dx if $dx < 0;
            $y2 = $y1 + 1 + $dy if $dy < 0;

            $fill
              ?? gdImageFilledRectangle(self, $x1, $y1, $x2, $y2, $color)
              !! gdImageRectangle(      self, $x1, $y1, $x2, $y2, $color)
        }

        multi method rectangle(
          List:D :$location      (UInt $x1, UInt $y1) = (0, 0),
          List:D :$alt-location! (UInt $x2, UInt $y2),
          UInt   :$color = 0,
          Bool   :$fill
        ) {
            $fill
              ?? gdImageFilledRectangle(self, $x1, $y1, $x2, $y2, $color)
              !! gdImageRectangle(      self, $x1, $y1, $x2, $y2, $color)
        }

        multi method rectangle(
          List:D :$center     (UInt $x0, UInt $y0) = (0, 0),
          List:D :$half-size! (UInt $dx, UInt $dy),
          UInt   :$color = 0,
          Bool   :$fill
        ) {
            $fill
              ?? gdImageFilledRectangle(self, $x0 - $dx, $y0 - $dy, $x0 + $dx, $y0 + $dy, $color)
              !! gdImageRectangle(      self, $x0 - $dx, $y0 - $dy, $x0 + $dx, $y0 + $dy, $color)
        }

        # style to enum
        method arc(
          List:D :$center!    (Int:D $cx, Int:D $cy),
          List:D :$amplitude! (PInt $w, PInt $h),
          List:D :$aperture!  (Int:D $s, Int:D $e),
          UInt   :$color = 0,
          Int:D  :$style = 0,
          Bool   :$fill
        ) {
            $fill
              ?? gdImageFilledArc(self, $cx, $cy, $w, $h, $s, $e, $color, $style)
              !! gdImageArc(self, $cx, $cy, $w, $h, $s, $e, $color)
        }

        method ellipse(
          List:D :$center! (Int:D $cx, Int:D $cy),
          List:D :$axes!   (PInt $w, PInt $h),
          UInt   :$color = 0,
          Bool  :$fill
        ) {
            $fill
              ?? gdImageFilledEllipse(self, $cx, $cy, $w, $h, $color)
              !! gdImageArc(self, $cx, $cy, $w, $h, 0, 0, $color)
        }

        method circumference(
          List:D :$center!(Int:D $cx, Int:D $cy),
          PInt   :$diameter!,
          UInt   :$color = 0,
          Bool   :$fill
        ) {
            $fill
              ?? gdImageFilledEllipse(self, $cx, $cy, $diameter, $diameter, $color)
              !! gdImageArc(self, $cx, $cy, $diameter, $diameter, 0, 0, $color)
        }

        method polygon(
          Int:D :@points! where { @points.elems >= 6 && @points.elems % 2 == 0 },
          UInt  :$color = 0,
          Bool  :$fill,
          Bool  :$open
        --> CArray[int32]) {

            my $n_array = @points.elems;
            my $gdPoints = GD_new_set_of_points(($n_array/2).Int);

            my $n = 0;
            for @points -> $x, $y {
                GD_add_point($gdPoints, $n, $x, $y);
                $n++;
            }

            $fill
              ?? gdImageFilledPolygon(self, $gdPoints, $n, $color)
              !! $open
                ?? gdImageOpenPolygon(self, $gdPoints, $n, $color)
                !! gdImagePolygon(self, $gdPoints, $n, $color);

            $gdPoints
        }

        method open(Str() $filename, Str $mode --> GD::File ) {
            GD::File.new($filename, $mode);
        }

        method output(GD::File $filepointer, GD_Format $format, Int $quality = -1) {
            given $format {
                gdImageGif(self, $filepointer)            when GD_GIF;
                gdImageJpeg(self, $filepointer, $quality) when GD_JPEG;
                gdImagePng(self, $filepointer)            when GD_PNG;
            }
        }

        method bmp($compression = 0) {
            my int32 $size;
            my $ptr  = gdImageBmpPtr(self, $size, $compression);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        method gd() {
            my int32 $size;
            my $ptr  = gdImageGdPtr(self, $size);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        method gif() {
            my int32 $size;
            my $ptr  = gdImageGifPtr(self, $size);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        method jpeg($quality = -1) {
            my int32 $size;
            my $ptr  = gdImageJpegPtr(self, $size, $quality);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        multi method png() {
            my int32 $size;
            my $ptr  = gdImagePngPtr(self, $size);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        multi method png($level) {
            my int32 $size;
            my $ptr  = gdImagePngPtrEx(self, $size, $level);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        method tiff() {
            my int32 $size;
            my $ptr  = gdImageTiffPtr(self, $size);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        multi method webp() {
            my int32 $size;
            my $ptr  = gdImageWebpPtr(self, $size);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        multi method webp($quality) {
            my int32 $size;
            my $ptr  = gdImageWebpPtrEx(self, $size, $quality);
            my $blob = blob-from-pointer($ptr, elems => $size, type => Blob[int8]);

            gdFree($ptr);
            $blob
        }

        method destroy() { gdImageDestroy(self) }
    }
}
