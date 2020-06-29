#!/usr/bin/env raku

use v6;

use Test;

use GD;

throws-like { GD::File.new("nonexistable/nonexistent", "wb") }, X::GD::File, "throws as expected with wrong directory", message => rx/'No such file or directory while opening'/;

if !"/".IO.w {
    throws-like { GD::File.new("/nonexistent", "wb") }, X::GD::File, "throws as expected with no permissions", message => rx/'Permission denied while opening'/;
}



done-testing;
