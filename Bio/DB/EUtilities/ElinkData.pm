# $Id$

# simple object to hold NCBI score information, other odds and end from
# elink queries; API to change dramatically

package Bio::DB::EUtilities::ElinkData;
use strict;
use warnings;
use Bio::Root::Root;
use vars '@ISA';

@ISA = 'Bio::Root::Root';

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($query_id) =  $self->_rearrange ([qw(QUERY_ID)], @args);
    $query_id     && $self->_set_query_id($query_id);
    return $self;
}

sub _set_query_id {
    my $self = shift;
    $self->{'_query_id'} = shift if @_;
    return;
}

=head2 get_score

 Title   : get_score
 Usage   : $score = $db->get_score($id);
 Function: gets score for ID (if present)
 Returns : integer (score) 
 Args    : ID values

=cut

sub get_score {
    my $self = shift;
    my $id = shift if @_;
    $self->throw("No ID given") if !$id;
    return $self->{'_rel_ids'}->{$id} if $self->{'_score'}->{$id};
    $self->warn("No score for $id");
} 

=head2 get_ids_by_score

 Title   : get_ids_by_score
 Usage   : @ids = $db->get_ids_by_score;  # returns IDs
           @ids = $db->get_ids_by_score($score); # get IDs by score
 Function: returns ref of array of ids based on relevancy score from elink;
           To return all ID's above a score, use the normal score value;
           to return all ID's below a score, append the score with '-';
 Returns : ref of array of ID's; if array, an array of IDs
 Args    : integer (score value); returns all if no arg provided

=cut

sub get_ids_by_score {
    my $self = shift;
    my $score = shift if @_;
    my @ids;
    if (!$score) {
        @ids = sort keys %{ $self->{'_scores'} };
    }
    elsif ($score && $score > 0) {
        for my $id (keys %{ $self->{'_scores'}}) {
            push @ids, $id if $self->{'_scores'}->{$id} > $score;
        }
    }
    elsif ($score && $score < 0) {
        for my $id (keys %{ $self->{'_scores'}}) {
            push @ids, $id if $self->{'_scores'}->{$id} < abs($score);
        }
    }
    if (@ids) {
        @ids = sort {$self->get_score($b) <=> $self->get_score($a)} @ids;
        return @ids if wantarray;
        return \@ids;
    }
    # if we get here, there's trouble
    $self->warn("No returned IDs!");
}

=head2 get_all_ids

 Title   : get_all_ids
 Usage   : @ids = $db->get_all_ids;  # returns IDs
 Function: returns ref of array of all ids
 Returns : ref of array of ID's; if wantarray, an array of IDs
 Args    : integer (score value); returns all if no arg provided
 Note    : This is just an alias for get_ids_by_score, called with no args

=cut

sub get_all_ids {
    my $self = shift;
    return my @arr = $self->get_ids_by_score if wantarray;
    return my $id_ref = $self->get_ids_by_score;
}

sub _add_scores {
    my ($self, $id, $score) = @_;
    $self->throw ("Must have id-score pair for hash") unless ($id && $score);
    $self->throw ("ID, score must be scalar") if
         (ref($id) && ref($score));
    $self->{'_scores'}->{$id} = $score;
}

1;
__END__