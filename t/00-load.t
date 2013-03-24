use v6;

BEGIN @*INC.unshift('lib');

use Test;

plan 1;

use GD;

ok 1, 'GD is loaded successfully';

done;
