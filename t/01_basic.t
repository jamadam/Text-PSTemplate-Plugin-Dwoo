package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use lib 'lib';
use Text::PSTemplate::Plugable;
use Text::PSTemplate::Plugin::Dwoo;
use Data::Dumper;
    
    __PACKAGE__->runtests;
    
    sub assign : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(q{<% assign('foo', 'bar') %><% $bar %>});
        is($parsed, 'foo');
    }
    
    sub capitalize : Test(2) {
        
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(q{<% capitalize('this is a string what2') %>});
        is($parsed, 'This Is A String What2');
        my $parsed1 = $tpl->parse(q{<% capitalize('this is a string what2', 1) %>});
        is($parsed1, 'This Is A String what2');
    }
	
    sub cat : Test(1) {
        
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(<<'EOF');
<% assign('abc','a') %>
<% assign('def','d') %>
<% assign('ghi','g') %>
<% cat($a, $d, $g) %>
EOF

        is($parsed, <<EOF);
abcdefghi
EOF
    }
	
	sub count_characters : Test(2) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(q{<% count_characters('ab cd') %>});
        is($parsed, '4');
        my $parsed1 = $tpl->parse(q{<% count_characters('ab cd', 1) %>});
        is($parsed1, '5');
	}
	
	sub count_paragraphs : Test(2) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(qq{<% count_paragraphs('ab cd') %>});
        is($parsed, '1');
        my $parsed1 = $tpl->parse(qq{<% count_paragraphs('ab\n cd') %>});
        is($parsed1, '2');
	}
	
	sub count_sentences : Test(2) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(qq{<% count_sentences('ab cd') %>});
        is($parsed, '1');
        my $parsed1 = $tpl->parse(qq{<% count_sentences('ab. cd') %>});
        is($parsed1, '2');
	}
	
	sub count_words : Test(2) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(qq{<% count_words('ab cd') %>});
        is($parsed, '2');
	}
	
	sub counter : Test(2) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
        my $parsed = $tpl->parse(<<EOF);
<% counter(start => 10, skip => 5) %>
<% counter() %>
<% counter() %>
<% counter(start => 10, direction => 'down') %>
<% counter() %>
EOF
        is($parsed, <<EOF);
10
15
20
10
5
EOF
	}
	
	sub with : Test(10) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
		$tpl->set_var(arr => {foo => 'bar'});
        my $parsed = $tpl->parse(<<'EOF');
<% $arr->{foo} %>
<% with($arr)<<BLOCK %><% $foo %> / <% $arr->{foo} %><% BLOCK %>
EOF

        is($parsed, <<EOF);
bar
bar / 
EOF
	}
	
	sub with2 : Test(10) {
		
        my $tpl = Text::PSTemplate::Plugable->new();
		$tpl->plug('Text::PSTemplate::Plugin::Dwoo','');
		$tpl->set_var(
			arr => {'sub' => {'foo' => 'bar'}},
			url => 'example.org',
		);
        my $parsed = $tpl->parse(<<'EOF');
<% with($arr->{sub})<<BLOCK %>
<% $foo %> / <% $_root->{arr}->{sub}->{foo} %> / <% $_parent->{arr} %>
<% $_root.url %> / <% $_parent->{_parent}->{url} %>
<% BLOCK %>
EOF

        is($parsed, <<EOF);
bar / bar / bar
example.org / example.org
EOF
	}
