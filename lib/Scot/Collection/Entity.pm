package Scot::Collection::Entity;
use lib '../../../lib';
use Moose 2;
use Data::Dumper;
extends 'Scot::Collection';
with    qw(
    Scot::Role::GetByAttr
    Scot::Role::GetTagged
    Scot::Role::GetTargeted
);

sub create_from_api {
    my $self    = shift;
    my $href    = shift;
    my $env     = $self->env;
    my $log     = $env->log;
    my $mq      = $env->mq;

    $log->trace("Creating Entity via API");

    my $request = $href->{request}->{json};
    my $entity  = $self->create($request);

    unless ( defined $entity ) {
        $log->error("Error! Failed to create Entity with data ",
                    { filter => \&Dumper, value => $request } );
        return undef;
    }
    $env->mq->send("scot", {
        action  => "created",
        data    => {
            type    => "entity",
            id      => $entity->id,
        }
    });
    return $entity;
}


sub update_entities {
    my $self    = shift;
    my $target  = shift;    # Scot::Model Object
    my $earef   = shift;    # array of hrefs that hold entityinfo

    my $env     = $self->env;
    my $log     = $env->log;
    my $mongo   = $env->mongo;

    my $type    = $target->get_collection_name;
    my $id      = $target->id;
    my $linkcol = $mongo->collection('Link');

    $log->trace("[$type $id] Updating associated entities");
    $log->trace("[$type $id] ", {filter=>\&Dumper, value=>$earef});
    
    # find entity or create it.
    # NOTE: this is a cool way to get MongoDB to do everything in one
    # fell swoop, BUT, it will not create an iid for us when creating
    # a new entity.  Bummer, so we are going to have to query and then
    # update or create
    #foreach my $entity (@$earef) {
    #    my @command    = (
    #        findAndModify   => "entity",
    #        query           => { 
    #            value   => $entity->{value}, 
    #            type    => $entity->{type},
    #        },
    #        update          => {
    #            '$setOnInsert'  => {
    #                value   => $entity->{value},
    #                type    => $entity->{type},
    #            }
    #        },
    #        new     => 1,
    #        upsert  => 1,
    #    );
    #
    #    $log->trace("Attempting: ", {filter=>\&Dumper, value=>\@command});
    #
    #    my $return = $self->_try_mongo_op(
    #        find_or_create => sub {
    #            my $dbname  = $self->meerkat->database_name;
    #            my $db      = $self->meerkat->_mongo_database($dbname);
    #            my $job     = $db->run_command(\@command);
    #            return $job;
    #        }
    #    );
    #    $log->debug("FindAndModify returned: ",
    #                { filter =>\&Dumper, value => $return });
    #    my $entity_id    = $return->{id};

    foreach my $entity (@$earef) {


        my $value   = $entity->{value};
        my $etype    = $entity->{type};
        my $entity = $self->find_one({
            value   => $value,
            type    => $etype
        });

        if ($entity) {
            $log->trace("Found matching $type entity $value");
        }
        else {
            $log->trace("Creating new $type entity $value");
            $entity = $self->create({
                value   => $value,
                type    => $etype,
            });
        }
        # $log->trace("entity is ",{filter=>\&Dumper, value=>$entity});
        my $entity_id  = $entity->id;


        my $link    = $linkcol->create_link({
            type   => "entity",
            id     => $entity_id,
        },{
            type => $type,
            id   => $id,
        });

    }
}


1;
