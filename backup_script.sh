 #!/bin/bash
    #
    # Creates an incremental, rotating snapshot every day using Cron
    # Up to six (current plus 5) snapshots will be stored
    #
    
    unset PATH
    
    # The amount of snapshots from 0 to SNAPSHOT_COUNT
    SNAPSHOT_COUNT=5;
    
    # The path of the snapshot directory
    SNAPSHOT_PATH=/snapshots;
    
    # The directories or rules to exclude from backup
    EXCLUDE_PATH=$SNAPSHOT_PATH/exclude.list;
    
    CP=/bin/cp;
    MV=/bin/mv;
    RM=/bin/rm;
    SEQ=/usr/bin/seq;
    
    # Delete oldest snap if it exists
    if [ -d $SNAPSHOT_PATH/day.$SNAPSHOT_COUNT ] ; then
        $RM -rf $SNAPSHOT_PATH/day.$SNAPSHOT_COUNT ;
    fi
    
    # Rotate all other backups
    BOUND=$(($SNAPSHOT_COUNT - 1))
    for day in $($SEQ $BOUND -1 1) ;
    do
        if [ -d $SNAPSHOT_PATH/day.$day ] ; then
            $MV $SNAPSHOT_PATH/day.$day $SNAPSHOT_PATH/day.$(($day + 1)) ;
        fi
    done
    
    # Make a hard link only copy of the most recent snahpshot
    # (except for dirs) if it exists
    if [ -d $SNAPSHOT_PATH/day.0 ] ; then
        $CP -al $SNAPSHOT_PATH/day.0 $SNAPSHOT_PATH/day.1 ;
    fi
    
    # Create an Rsync backup of the current system into day.0
    /usr/bin/rsync -arogtH --links --delete --delete-excluded --exclude-from="$EXCLUDE_PATH" / $SNAPSHOT_PATH/day.0 --info=progress2 