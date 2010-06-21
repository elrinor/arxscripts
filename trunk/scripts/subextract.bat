@echo off
perl -S -x "%0" %*
goto endofperl
#!/usr/bin/perl

if ($#ARGV == -1) {
  print "Usage: subextract FILEMASKS\n";
  exit 1;
}

my %filelist;              

foreach $filemask (@ARGV) {
  @files = `dir "$filemask" /b`;
  foreach $file (@files) {
    $filelist{$file} = 1;
  }
}

foreach $file (keys %filelist) {
  chomp($file);
  print "\nProcessing $file... ";
  if(rindex($file, ".mkv") ne (length($file) - 4)) {
    print "not a .mkv file.\n";
    next;
  }
  print "\n";
  @lines = `mkvinfo "$file"`;
  my @tracks;
  my $track = 0;
  my @attachs;
  my $attach = 0;
  foreach $line (@lines) {
    chomp($line);
    if($line =~ /^\| +\+ A track.*$/i) {
      $tracks[$#tracks + 1] = $line;
      $track = 1;
    } elsif($line =~ /^\|\+.*$/i) {
      $track = 0;
    } elsif($track) {
      $tracks[$#tracks] .= $line;
    }
    if($line =~ /^\| +\+ Attached$/i) {
      @attachs[$#attachs + 1] = $line;
      $attach = 1;
    } elsif($line =~ /^\|\+.*$/i) {
      $attach = 0;
    } elsif($attach) {
      $attachs[$#attachs] .= $line;
    }
  }
  $name = substr($file, 0, length($file) - 4);
  $mkvextract = "mkvextract tracks \"" . $file . "\" ";
  my %substreams = { "srt" => 0, "ass" => 0, "sub" => 0};
  $substreams = 0;
  foreach $track (@tracks) {
    if($track =~ /^.*Track number: ([0-9]+)\|.*Track type: subtitles.*Codec ID: ([^\|]+)\|.*Language: ([a-z]+)(\|.*)?$/i) {
      $substreams++;
      $n = $1;
      $type = $2;
      if(index(uc($type), "S_TEXT/ASS") ne -1) {
        $type = "ass";
      } elsif(index(uc($type), "S_VOBSUB") ne -1) {
        $type = "sub";
      } else {
        $type = "srt";
      }
      $lang = $3;
      $substreams{$type}++;
      $mkvextract .= "\"" . $n . ":" . $name . "."; #"
      if($substreams{$type} ne 1) {
        $mkvextract .= $substreams{$type} . ".";
      }
      $mkvextract .= $type . "\" "; #";
    }
    #print $track . "\n\n";
  }
  #print "\n", $mkvextract, "\n";
  if ($substreams gt 0) {
    system $mkvextract
  } else {
    print "Nothing to do.";
  }
 
  $mkvextract = "mkvextract attachments \"" . $file . "\" ";
  my $attachn = 0; 
  foreach $attach (@attachs) {
    #print $attach, "\n\n";
    if($attach =~ /^.*File name: ([^\|]*)\|.*Mime type: [^\|]*font[^\|]*\|.*File UID: ([0-9]+)[^0-9]*(\|.*)?$/i) {
      $n = $2;
      $name = $1;
      unless (-e $name) {
        $mkvextract .= "\"" . $n . ":" . $name . "\" ";
        $attachn++;
      }              
    }
  }
  system $mkvextract if($attachn > 0);
}
   
__END__
:endofperl   
