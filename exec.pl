# Copyright 2012 - 2013, Steve Rader
# Copyright 2013 - 2014, Scott Kostyshak

sub task_exec {
  my ($cmd) = @_;
  my $es = 0;
  my $result = '';
  &audit("TASK EXEC $task $cmd 2>&1");
  open(IN,"echo -e \"yes\\n\" | $task $cmd 2>&1 |");
  while(<IN>) {
    chop;
    $_ =~ s/\x1b.*?m//g; # decolorize
    if ( $_ =~ /^\w+ override:/ ) { next; }
    $result .= "$_ ";
  }
  close(IN);
  if ( $! ) {
    $es = 1;
    &audit("FAILED \"$task $cmd\" error closing short pipe");
  }
  if ( $? != 0 ) {
    $es = $?;
    &audit("FAILED \"$task $cmd\" returned exit status $?");
  }
  return ($es,$result);
}

#------------------------------------------------------------------

sub shell_exec {
  my ($cmd,$mode) = @_;
  endwin();
  if ( $clear ne 'NOT_FOUND' ) { system("$clear"); }
  if ( $audit ) {
    print "$_[0]\r\n";
  }
  if ( ! fork() ) {
    &audit("EXEC $cmd");
    exec($cmd);
    exit();
  }
  wait();
  if ( $mode eq 'wait' ) {
    print "Press return to continue.\r\n";
    <STDIN>;
  }
  &init_curses('refresh');
  &draw_screen();
}

return 1;

