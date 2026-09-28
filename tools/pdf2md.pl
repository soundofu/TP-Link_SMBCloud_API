use strict; use utf8; binmode STDOUT,":utf8"; binmode STDERR,":utf8";
my ($in,$out,$ver)=@ARGV; $ver//="unknown"; open my $h,'<:utf8',$in or die; my @L=<$h>; close $h; chomp @L; s/\f//g for @L; s/\s+$// for @L;
# TOC entries
my @toc; my $bodyStart;
for my $i(0..$#L){ if($L[$i]=~/^\s*(1(?:\.\d+)+)\s+(.+?)\s*\.{4,}\s*\d+$/){ push @toc,[$1,$2] } elsif(@toc>5 && !$bodyStart && $L[$i]=~/^1\.1 /){ $bodyStart=$i } }
die "no body" unless $bodyStart;
# locate headings sequentially
my $pos=$bodyStart; my @secs;
for my $t(@toc){ my ($n,$title)=@$t; (my $tn=$title)=~s/\s//g; my $found;
  for my $i($pos..$#L){ next unless $L[$i]=~/^\s*(1(?:\.\d+)+)\s+(.+)$/; my ($bn,$bt)=($1,$2); $bt=~s/\s//g;
    if($bt eq $tn || ($bn eq $n && index($bt,$tn)==0)){ $found=$i; print STDERR "RENUM toc=$n body=$bn $title\n" if $bn ne $n; last } }
  if(defined $found){ push @secs,{n=>$n,title=>$title,line=>$found}; $pos=$found+1 } else { print STDERR "MISSING $n $title\n" } }
for my $k(0..$#secs){ $secs[$k]{end}= $k<$#secs ? $secs[$k+1]{line}-1 : $#L }
# chapter grouping: 1.1-1.3 -> 00, 1.4.x -> own file, 1.5 -> errors
sub chap{ my $n=shift; return '1.4.'.$1 if $n=~/^1\.4\.(\d+)/; return '1.4' if $n eq '1.4'; return $n=~/^1\.5/?'1.5':'1.1-1.3' }
my %ctitle; for(@secs){ $ctitle{$_->{n}}=$_->{title} }
my %fname; my @order; my %files;
for my $s(@secs){ my $c=chap($s->{n}); next if $c eq '1.4';
  unless($fname{$c}){ my $t = $c eq '1.1-1.3' ? '概述-鉴权-签名' : $c eq '1.5' ? '错误码' : $ctitle{$c}; $t=~s/[\s\/]+/_/g;
    my $num = $c=~/^1\.4\.(\d+)$/ ? sprintf("1.4.%02d",$1) : $c; $fname{$c}="$num-$t.md"; push @order,$c; }
  push @{$files{$c}},$s; }
mkdir $out; my @index;
for my $c(@order){ my $f=$fname{$c}; my @md=("# ".($c eq '1.1-1.3'?'1.1–1.3 概述、入门、签名、协议':"$c ".($ctitle{$c}//'错误码说明')),"","> 来源：TP-LINK商用云平台开放接口文档-$ver.pdf（pdftotext -layout 抽取，表格保留原始列排版；原文流程图/截图未保留）","");
  for my $s(@{$files{$c}}){ my $depth=()=$s->{n}=~/\./g; my $hd='#' x ($depth>4?5:$depth+1);
    my @body=@L[$s->{line}+1..$s->{end}];
    @body=grep{ !/^\s{30,}\d{1,3}$/ } @body; # page numbers (right-aligned only)
    my @b2; my $blank=0; for(@body){ if($_ eq ''){ next if $blank++; } else {$blank=0} push @b2,$_ } shift @b2 while @b2 && $b2[0] eq ''; pop @b2 while @b2 && $b2[-1] eq '';
    my $hline=scalar(@md)+1; push @md,"$hd $s->{n} $s->{title}","";
    my @paths = do{ my %u; grep{!$u{$_}++} map{ /(\/(?:tums|vms|openapi|ams|cms|nms)\/[A-Za-z0-9\/_]+)/g } @b2 };
    if(@b2){ push @md,'```text',@b2,'```',''; }
    @paths=grep{/\/v\d+\/\w/}@paths;
    # 版面错位：上一节末尾混入了本节的 Path，而本节自身没有 Path 时，把它还给本节
    if(!@paths && @index && $index[-1][5] && @{$index[-1][5]}>1){ @paths=(pop @{$index[-1][5]}); }
    push @index,[$s->{n},$s->{title},undef,$f,$hline,[@paths]]; }
  open my $o,'>:utf8',"$out/$f"; print $o join("\n",@md),"\n"; close $o; printf STDERR "%-40s %d lines\n",$f,scalar @md; }
open my $o,'>:utf8',"$out/INDEX.md";
print $o "# 章节/接口索引（$ver 版）\n\n用法：按接口 Path 或中文标题 grep 本文件，再用 Read 按\"位置\"列的行号（offset）打开对应文件读取该节。\n\n| 章节 | 标题 | Path | 位置 |\n|---|---|---|---|\n";
for(@index){ my ($n,$t,undef,$f,$l,$p)=@$_; my $ps=@$p?"`$p->[0]`":''; print $o "| $n | $t | $ps | [$f:$l]($f#L$l) |\n" } close $o;
print STDERR "sections=",scalar(@secs)," toc=",scalar(@toc),"\n";
