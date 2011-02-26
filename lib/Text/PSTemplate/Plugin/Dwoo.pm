package Text::PSTemplate::Plugin::Dwoo;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use Text::PSTemplate;

our $VERSION = '0.01';
    
    ### ---
    ### Parse inline template if the variable is in array
    ### ---
    sub assign : TplExport(chop => 1) {
        
        my ($self, $value, $var) = @_;
        $self->Text::PSTemplate::Plugin::Control::set_var($var => $value);
        return;
    }
    
    sub capitalize : TplExport {
        
        my ($self, $value, $numwords) = @_;
        if ($numwords) {
            $value =~ s{([a-zA-Z']+\b)}{\u\L$1}g;
        } else {
            $value =~ s{([\w']+)}{\u\L$1}g;
        }
        return $value;
    }
    
    sub cat : TplExport {
        my ($self, @array) = @_;
        return join '', @array;
    }
    
    sub count_characters : TplExport {
        
        my ($self, $value, $count_spaces) = @_;
        
        if (! $count_spaces) {
            $value =~ s{\s}{}g;
        }
        return length($value);
    }
    
    sub count_paragraphs : TplExport {
        
        my ($self, $value) = @_;
        my @a = split(/\r\n|\r|\n/, $value);
        return scalar @a;
    }
    
    sub count_sentences : TplExport {
        
        my ($self, $value) = @_;
        my @a = split(/\.\s/m, $value);
        return scalar @a;
    }
    
    sub count_words : TplExport {
        
        my ($self, $value) = @_;
        my @a = split(/\s/m, $value);
        return scalar @a;
    }
    
    my $_counters = {};
    
    sub counter : TplExport {
        
        my $self = shift;
        my %args = (
            name => 'default',
            print => 1,
            @_);
        
        $_counters->{$args{name}} ||= _make_counter(%args);
        
        if ($args{start}||$args{skip}||$args{direction}) {
            $_counters->{$args{name}}->{init}->(%args);
        } else {
            $_counters->{$args{name}}->{count}->();
        }
        if ($args{print}) {
            return $_counters->{$args{name}}->{show}->();
        }
        return;
    }
    
    sub _make_counter {
        
        my $a = {
            start       => 1,
            skip        => 1,
            direction   => "up",
            @_};
        
        return {
            init    => sub{
                $a = {%$a, @_};
            },
            count   => sub{
                my $direction = {up => '1', down => '-1'}->{$a->{direction}};
                $a->{start} = $a->{start} + $a->{skip} * $direction;
            },
            show    => sub {
                return $a->{start};
            },
        };
    }
    
    sub with : TplExport {
        
        my ($self, $dataset) = @_;
        my $tpl = Text::PSTemplate::Plugable->new(undef);
        $tpl->set_exception(sub{''});
        my $tplstr = Text::PSTemplate::inline_data(0);
        my $out = '';
        while (my ($key, $value) = each(%$dataset)) {
            $tpl->set_var($key => $value);
            $tpl->set_var('_parent' => Text::PSTemplate->mother->var());
            $out .= $tpl->parse($tplstr);
        }
        return $out;
    }


1;

__END__

=head1 NAME

Text::PSTemplate::Plugin::Dwoo - 

=head1 SYNOPSIS

    use Text::PSTemplate::Plugin::Dwoo;
    Text::PSTemplate::Plugin::Dwoo->new;

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
