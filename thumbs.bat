@echo off
perl -S -x "%0" %*
goto endofperl
#!/usr/bin/perl

#use Data::Types;

if($#ARGV == -1) {
  print "thumbs - thumbnail generator\n";
  print "USAGE:\nthumbs filename [options]\n";
  print "\n";
  print "Possible options:\n";
  print "-tile XTILES:YTILES  (default -tile 4:4)\n";
  print "-width WIDTH         (default -width 1280)\n";
  print "-slow                use alternative screenshoting method (default one doesn't work on some files)\n";
  print "\n";
  print "You must have mplayer and mediainfo installed to run this script\n";
  exit 0;
}

my $filename;
my $x = 4;
my $y = 4;
my $width = 1280;
my $simplemode = 0;

for($i = 0; $i <= $#ARGV; $i++) {
  if($ARGV[$i] eq "-tile" && $i + 1 le $#ARGV) {
    @sizes = split /:/, $ARGV[$i + 1];
    if($#sizes == 1) {
      $x = $sizes[0];
      $y = $sizes[1];
    }
    #print "tile $x:$y\n";
    $i++;
  } elsif($ARGV[$i] eq "-width" && $i + 1 le $#ARGV) {
    $width = $ARGV[$i + 1];
    $i++;
    #print "width $width\n";
  } elsif($ARGV[$i] eq "-slow") {
    $simplemode = 1;
  } else {
    $filename = $ARGV[$i];
  }
}                 

my $frames = $x * $y;
my $duration = 0;

@lines = `mediainfo "--Inform=General;PlayTime : %PlayTime/String3%" "$filename"`;
#@lines = `mediainfo -f "$filename"`;
foreach (@lines) {
  if(/^PlayTime *\: ([0-9]+)\:([0-9]+)\:([0-9]+)\..*$/i) {
    $duration = $1 * 60 * 60 + $2 * 60 + $3;
  }
}

my $step = $duration / $frames;
my $n = 0;
my $i;

sub simpleIteration {
  system sprintf("mplayer \"$filename\" -nosound -vo png -frames 2 -benchmark -ss %02d:%02d:%02d", $i / 3600, ($i / 60) % 60, $i % 60);
  unlink "00000001.png";
  rename "00000002.png", sprintf("shot%04d.png", $n);
  $n++;
}

if($simplemode) {
  for($i = $step / 2; $i < $duration; $i += $step) {
    &simpleIteration;
  }
} else {
  $frameblock = 10;
  $bigstep = $step * $frameblock;
  $i = $step / 2;
  &simpleIteration;
  $i = $step * 3 / 2;
  &simpleIteration;
  $i = $step * 5 / 2;
  for(; $i + $bigstep < $duration; $i += $bigstep) {
    $i -= $step;
    system sprintf("mplayer \"$filename\" -nosound -vo png -frames %d -benchmark -sstep %d -ss %02d:%02d:%02d", $frameblock + 1, $step - 1, $i / 3600 - 0.5, ($i / 60) % 60, $i % 60);
    $i += $step;
    unlink "00000001.png";
    foreach $file (glob "0*.png") {
      rename $file, sprintf("shot%04d.png", $n);
      $n++;
    }
  }
  $i = $duration * $n / ($x * $y) + $step / 2;
  for(; $i < $duration; $i += $step) {
    &simpleIteration;
  }
}

system sprintf("mplayer mf://*.png -mf type=png -vf scale=%.0f:-2,tile=$x:$y,scale=$width -vo jpeg", $width / $x);
unlink glob "*.png";
rename "00000001.jpg", substr($filename, 0, rindex($filename, ".")).".thumbs.jpg";

__END__
:endofperl   
        
