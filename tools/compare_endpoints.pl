# 按接口 Path 对比两版 TP-LINK 文档中该接口所在小节（与排版顺序无关）。
# 用法：perl compare_endpoints.pl old.txt new.txt <path1> <path2> ...
# 每个 Path 输出：所在小节、字符差异数 chars_delta（仅页码/章节号变化时通常 <30）、
# 增删的英文标识符（字段名）和中文字符；A=0/B=0 表示该 Path 在旧/新版中不存在。
use strict; use utf8; binmode STDOUT,':utf8';
sub load{ open my $h,'<:utf8',shift; my @L=<$h>; my (@secs,$cur);
  for(@L){ if(/^\s*(\d+\.\d+(?:\.\d+)+)\s+(\S.*?)\s*$/ && !/\.{5,}/ && $2!~/^\d/){ $cur={title=>"$1 $2",txt=>''}; push @secs,$cur; next } $cur->{txt}.=$_ if $cur; }
  my %byp; for my $s(@secs){ my $t=$s->{txt}; $t=~s/^\s{30,}\d{1,4}\s*$//mg; # 右对齐页码
    while($t=~m{(/(?:tums|vms|openapi|ams)/open/[A-Za-z0-9/_]+|/openapi/[A-Za-z0-9/_]+)}g){ push @{$byp{$1}},$s; } }
  return \%byp }
my $A=load($ARGV[0]); my $B=load($ARGV[1]); my @paths=@ARGV[2..$#ARGV];
sub ids{ my %c; $c{$_}++ for ($_[0]=~/\b([A-Za-z_][A-Za-z0-9_]{2,})\b/g); \%c }
sub chars{ my $t=shift; $t=~s/\s//g; my %c; $c{$_}++ for split //,$t; \%c }
for my $p(@paths){ my $sa=$A->{$p}; my $sb=$B->{$p}; unless($sa&&$sb){ print "### $p : A=".($sa?scalar@$sa:0)." B=".($sb?scalar@$sb:0)."\n"; next }
  my $ta=join('',map{$_->{txt}}@$sa); my $tb=join('',map{$_->{txt}}@$sb);
  my ($ia,$ib)=(ids($ta),ids($tb)); my @rm=grep{!$ib->{$_}}sort keys %$ia; my @ad=grep{!$ia->{$_}}sort keys %$ib;
  my ($ca,$cb)=(chars($ta),chars($tb)); my %all=(%$ca,%$cb); my $dc=0; my ($plus,$minus)=('','');
  for(keys %all){ my $d=($cb->{$_}//0)-($ca->{$_}//0); next unless $d; $dc+=abs $d; if(/\P{ASCII}/){ if($d>0){$plus.=$_ x ($d>5?5:$d)} else {$minus.=$_ x (-$d>5?5:-$d)} } }
  printf "### %s  [%s]  chars_delta=%d\n", $p, join(' | ',map{$_->{title}}@$sb), $dc;
  print "   -ids: @rm\n" if @rm; print "   +ids: @ad\n" if @ad; print "   +zh: $plus\n" if $plus; print "   -zh: $minus\n" if $minus; }
