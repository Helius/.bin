#!/bin/bash

SRCDIR="/data"
DSTDIR="/backup"
date
rsync -avO --delete $SRCDIR/Photo $DSTDIR/photo_video_backup
rsync -avO --delete $SRCDIR/Video $DSTDIR/photo_video_backup
rsync -avO --delete $SRCDIR/Distrib $DSTDIR

