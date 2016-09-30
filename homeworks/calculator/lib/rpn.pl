=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;

	my @stack;

	my %priority = (
			  	'(' => 0, ')' => 0,
			  '+' => 1, '-' => 1,
			  '*' => 2, '/' => 2,
			  'U+'=> 3, 'U-'=> 3,
			  '^' => 4
			 );
	
	my %order = (
			  '(' => 'l', ')' => 'l',
			  'U-'=> 'l', 'U+'=> 'l',
			  '+' => 'b', '-' => 'b',
			  '*' => 'b', '/' => 'l',
			  '^' => 'r'
	);
	
	for my $c(@$source){ 
		given($c){
			when(['U-', 'U+', '+', '-', '*', '/', '^']){
				while(@stack){
					my $top = $stack[-1];
					
					if($order{$top} ne 'r'){
						($priority{$c} <= $priority{$top}) ? push(@rpn, pop(@stack)) : last;
					}else{
						if($priority{$c} < $priority{$top}){
							push(@rpn, $c); 
							$c = '';				
							last;
						}
					}
				}
				
				push(@stack, $c) if $c;
			}
			when('('){
				push(@stack, $c);
			}
			when(')'){
				while((my $tmp = pop(@stack)) ne '('){
					push(@rpn, $tmp);
				}
			}
			default{
				push(@rpn,''.(0+$c));
			}
		}
	}
	
	push @rpn, reverse @stack;

	return \@rpn;
}

1;
