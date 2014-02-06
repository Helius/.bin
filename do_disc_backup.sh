#!/bin/bash

SRCDIR="/data"
DSTDIR="/backup"
date
rsync -aO $SRCDIR/Photo $DSTDIR/photo_video_backup
rsync -aO $SRCDIR/Video $DSTDIR/photo_video_backup
rsync -aO $SRCDIR/Distrib $DSTDIR
