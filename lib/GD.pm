use NativeCall;

# point NativeCall to correct library
# (may become obsolete in the future)
sub LIB  {
    given $*VM{'config'}{'load_ext'} {
        when '.so'      { return 'libgd.so' }       # Linux
        when '.bundle'  { return 'libgd.dylib' }    # Mac OS
        default         { return 'libgd' }
    }
}

enum GD_Format <GD_GIF GD_JPEG GD_PNG>;

class GD::File is repr('CPointer') {

	sub fopen(Str, Str)
		returns GD::File is native { ... }

	sub fclose(GD::File $filepointer)
		is native { ... }

	method new(Str $filename, Str $mode) {
		fopen($filename, $mode);
	}

	method close() {
		fclose(self);
	}
}

class GD::Image is repr('CPointer') {

	sub gdImageGif(GD::Image, GD::File)
		is native(LIB) { ... };

	sub gdImageJpeg(GD::Image, GD::File, int32)
		is native(LIB) { ... };

	sub gdImagePng(GD::Image, GD::File)
		is native(LIB) { ... };

	sub gdImageCreate(int32, int32)
		returns GD::Image is native(LIB) { ... };
	
	sub gdImageColorAllocate(GD::Image, int32, int32, int32)
		returns int32 is native(LIB) { ... };
 
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

	sub gdImageDestroy(GD::Image)
		is native(LIB) { ... };

	### METHODS ###

	method new(Int $width, Int $height) {
		gdImageCreate($width, $height);
	}

	multi method colorAllocate(
			Int :$red! where 0..255,
			Int :$green! where 0..255,
			Int :$blue! where 0..255) returns Int {

		return gdImageColorAllocate(self, $red, $green, $blue);
	}

	multi method colorAllocate(Str $hexstr where /^\#<[A..Fa..f\d]>**6$/) returns Int {

		my $red = ("0x" ~ $hexstr.substr(1,2)).Int;
		my $green = ("0x" ~ $hexstr.substr(3,2)).Int;
		my $blue = ("0x" ~ $hexstr.substr(5,2)).Int;

		return gdImageColorAllocate(self, $red, $green, $blue);
	}

	multi method colorAllocate(Int $hex_value where { $hex_value >= 0 }) returns Int {

		my $red = (($hex_value +> 16) +& 0xFF).Int;
		my $green = (($hex_value +> 8) +& 0xFF).Int;
		my $blue = (($hex_value) +& 0xFF).Int;

		return gdImageColorAllocate(self, $red, $green, $blue);
	}

	method line(
		Parcel :$start(Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
		Parcel :$end!(Int $x2 where { $x2 > 0 }, Int $y2 where { $y2 > 0 }),
		   Int :$color where { $color >= 0 } = 0) {

		gdImageLine(self, $x1, $y1, $x2, $y2, $color);
	}

	method rectangle(
		Parcel :$location(Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
		Parcel :$size!(Int $x2 where { $x2 > 0 }, Int $y2 where { $y2 > 0 }),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledRectangle(self, $x1, $y1, $x2, $y2, $color) !!
			gdImageRectangle(self, $x1, $y1, $x2, $y2, $color);
	}

	# style to enum
	method arc(
		Parcel :$center!(Int $cx, Int $cy),
		Parcel :$amplitude!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
		Parcel :$aperture!(Int $s, Int $e),
		   Int :$color where { $color >= 0 } = gdImageColorAllocate(self, 0, 0, 0),
		  Bool :$fill = False,
		   Int :$style = 0) {

		$fill ??
			gdImageFilledArc(self, $cx, $cy, $w, $h, $s, $e, $color, $style) !!
			gdImageArc(self, $cx, $cy, $w, $h, $s, $e, $color);
	}

	method ellipse(
		Parcel :$center!(Int $cx, Int $cy),
		Parcel :$axes!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledEllipse(self, $cx, $cy, $w, $h, $color) !!
			gdImageArc(self, $cx, $cy, $w, $h, 0, 0, $color);
	}

	method circumference(
		Parcel :$center!(Int $cx, Int $cy),
		   Int :$diameter! where { $diameter > 0 },
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledEllipse(self, $cx, $cy, $diameter, $diameter, $color) !!
			gdImageArc(self, $cx, $cy, $diameter, $diameter, 0, 0, $color);
	}

	method open(Str $filename, Str $mode) returns GD::File {
		return GD::File.new($filename, $mode);
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
