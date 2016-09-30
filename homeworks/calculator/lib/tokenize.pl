=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub remove_spaces{
	my @str = @_;

	shift(@str) while(@str && $str[0] eq ' ');

	return \@str;
}

sub readPower{
	my @str = @_;

	my @power = ();
	my $neg = 0;
	my $sign = 0;
		
	while(scalar @str > 0){
		my $c = $str[0];
		
		if($c =~ /\d/){
			push(@power, $c);
			shift(@str);
		}elsif($c eq '+' && $sign == 0){
			$sign = 1;
			shift(@str);
		}elsif($c eq '-' && $sign == 0){
			$sign = 1;
			$neg = 1;
			shift(@str);
		}elsif($c eq ' '){
			shift(@str);
			last;
		}else{
			(@power) ? (last) : (die 'Error');
		}
	}

	my $p = join('', @power);
	$p = -$p if $neg;

	return $p, \@str;
}

sub readNumber{
	# -------------------------------------------------------------------------
	my @str = @_;
	my $str2 = remove_spaces(@str);
	@str = @$str2;

	my @stack = ();
	# -------------------------------------------------------------------------
	
	my @number = ();

	my $frac = 0;

	my $power = 0;

	while(scalar @str > 0){
		my $c = $str[0];
		
		if($c eq ' '){
		}elsif($c =~ /\d/){
	 		push(@number, $c);
		}elsif($c eq '.'){
			if($frac == 1){
				die 'Error';
			}

			push(@number, $c);	
			$frac = 1;
		}elsif($c =~ '[e|E]'){
			shift(@str);
			
			($power, $str2) = readPower(@str);
			@str = @$str2;
			
			last;
		}else{
			last;
		}

		shift(@str) if @str;
	}

	my $num = '';
	my @n = ();

	if(@number){
		$num = 0 + join('', @number);
		$num *= (10 ** $power) if $power;
	
		push(@n, $num);
	}

	my $correct = (@n) ? (1) : (0);

	return \@n, \@str, $correct;
}

sub readSign{
	# -------------------------------------------------------------------------
	my @str = @_;
	my $str2 = remove_spaces(@str);
	@str = @$str2;

	my @stack = ();
	# -------------------------------------------------------------------------
	my $correct = 0;
	
	while(@str){
		my $c = $str[0];

		if($c eq ' '){
			shift(@str);
		}elsif($c =~ '[+|\-|*|/|^]'){
			$correct = 1;

			push(@stack, $c);
			shift(@str);
			last;
		}else{
			last;
		}
	}

	return \@stack, \@str, $correct;
}

sub get_inside{
	# -------------------------------------------------------------------------
	my @str = @_;
	my $str2 = remove_spaces(@str);
	@str = @$str2;
	# -------------------------------------------------------------------------
	my $fin = 1;
	
	my $l = scalar @str;

	my $correct = 1;

	while($str[$fin] ne ')'){
		$fin++;

		if($fin >= $l){
			$correct = 0;
			last;
		}
	}

	my @inside = @str[1..$fin-1];
	my @str_tail = @str[$fin+1..$l-1];
	
	return \@inside, $correct, \@str_tail;
}

sub read_element{
	# -------------------------------------------------------------------------
	my @str = @_;
	my $str2 = remove_spaces(@str);
	@str = @$str2;

	my @stack = ();
	# -------------------------------------------------------------------------
	my $num;
	my $num_found = 0;
	my $num_sign = 0;
	my $is_num;
	
	my $expr;
	my $is_expr;
	
	my $str_tail;
	
	my @sign_stack = ();	
	
	while(@str){
		if($str[0] =~ '[+|\-]'){
			$num_sign = 1;
			push(@sign_stack, 'U'.$str[0]);
			shift(@str);
		}elsif($str[0] eq ' '){
			shift(@str);	
		}else{
			last;
		}
	}

	die unless @str;

	my $c = $str[0];
	
	if($c eq '('){
		($expr, $is_expr, $str_tail) = get_inside(@str);
		(my $inside, $str2) = read_unitary(@$expr);

		if(scalar @$inside > 0){
			$num_found = 1;
		
			push(@stack, '(');
			push(@stack, @$inside);
			push(@stack, ')');
		}

		@str = @$str_tail;	
		$str2 = remove_spaces(@str);
		@str = @$str2;
	}else{
		($num, $str2, $is_num) = readNumber(@str);
		
		if($is_num){
			$num_found = 1;
		
			push(@stack, @$num);
		
			@str = @$str2;	
		}		
	}
	
	push(@stack, reverse @sign_stack) if @sign_stack;
	$num_sign = 0;

	return \@stack, \@str, $num_found;
}

sub read_unitary{
	# -------------------------------------------------------------------------
	my @str = @_;
	my $str2 = remove_spaces(@str);
	@str = @$str2;

	my @stack = ();
	# -------------------------------------------------------------------------
	
	# BEGIN------------------------------------------------PARSE-NUM-1---------
	(my $num1, $str2, my $num1_found) = read_element(@str);
	
	if($num1_found){
		push(@stack, @$num1);

		@str = @$str2;	
	}else{
		return \@stack, \@str;		
	}
	# END--------------------------------------------------PARSE-NUM-1---------
	while(scalar @str > 0){	
		# BEGIN--------------------------------------------PARSE-SIGN----------
		my ($sign, $str2, $is_sign) = readSign(@str);

		if($is_sign){
			push(@stack, @$sign);
		
			@str = @$str2;
		}else{
			return \@stack, \@str;		
		}
		# END----------------------------------------------PARSE-SIGN----------
		
		# BEGIN--------------------------------------------PARSE-NUM-2---------
		(my $num2, $str2, my $num2_found) = read_element(@str);
		
		if($num2_found){
			push(@stack, @$num2);

			@str = @$str2;
		}else{
			return \@stack, \@str;
		}
		# END----------------------------------------------PARSE-NUM-2---------
	}

	return \@stack, \@str;
}


sub tokenize{
	chomp(my $expr = shift);
	my @res;

	my @str = split(//,$expr);
	
	my $str2;
	
	(my $stack, @$str2) = read_unitary(@str);
	
	@res = @$stack;

	return \@res;
}

1;
