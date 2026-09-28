# 按小节对比两版 TP-LINK 文档（pdftotext -layout 输出），与排版顺序无关。
# 用法：perl compare_sections.pl old.txt new.txt
# 输出：
#   ADDED/REMOVED  —— 只在一版中出现的小节标题
#   ### 小节       —— 同名小节中，英文标识符/4位以上数字（字段名、枚举、错误码、取值范围）
#                    或中文字符多重集有差异的，列出增删内容，需人工到文本中确认
# 标题相同的小节按出现顺序加 #2、#3 区分；新增同名小节（如"使用说明"）会导致其后的
# 同名小节错位配对，报告中这类大面积差异需结合章节号判断。
use strict; use utf8;
binmode STDOUT, ':utf8';

sub load {
    open my $h, '<:utf8', shift or die $!;
    my (%sec, @order, $cur);
    while (<$h>) {
        next if /\.{5,}/;                 # 目录行
        next if /^\s{30,}\d{1,4}\s*$/;    # 右对齐页码
        if (/^\s*(\d+\.\d+(?:\.\d+)+)\s+(\S.*?)\s*$/ && $2 !~ /^\d/) {
            (my $k = $2) =~ s/\s//g;
            my ($base, $i) = ($k, 1);
            $k = $base . '#' . ++$i while exists $sec{$k};
            push @order, [$k, $1];
            $sec{$cur = $k} = '';
            next;
        }
        $sec{$cur} .= $_ if defined $cur;
    }
    close $h;
    return (\%sec, \@order);
}

sub ids { my %c; $c{$_}++ for ($_[0] =~ /([A-Za-z_][A-Za-z0-9_]+|-?\d{4,})/g); \%c }
sub zh  { my %c; $c{$_}++ for ($_[0] =~ /(\P{ASCII})/g); \%c }

my ($A, $oa) = load($ARGV[0]);
my ($B, $ob) = load($ARGV[1]);

print "ADDED\t$_->[1] $_->[0]\n"   for grep { !exists $A->{$_->[0]} } @$ob;
print "REMOVED\t$_->[1] $_->[0]\n" for grep { !exists $B->{$_->[0]} } @$oa;

for my $e (@$ob) {
    my ($k, $num) = @$e;
    next unless exists $A->{$k};
    my ($ia, $ib) = (ids($A->{$k}), ids($B->{$k}));
    my @rm = grep { !$ib->{$_} } sort keys %$ia;
    my @ad = grep { !$ia->{$_} } sort keys %$ib;
    my ($za, $zb) = (zh($A->{$k}), zh($B->{$k}));
    my %u = (%$za, %$zb);
    my ($plus, $minus, $n) = ('', '', 0);
    for (sort keys %u) {
        my $d = ($zb->{$_} // 0) - ($za->{$_} // 0);
        next unless $d;
        $n += abs $d;
        if ($d > 0) { $plus .= $_ x ($d > 3 ? 3 : $d) } else { $minus .= $_ x (-$d > 3 ? 3 : -$d) }
    }
    next unless @rm || @ad || $n;
    print "### $num $k (zhΔ=$n)\n";
    print "   -ids: @rm\n"  if @rm;
    print "   +ids: @ad\n"  if @ad;
    print "   +zh: $plus\n" if $plus;
    print "   -zh: $minus\n" if $minus;
}
