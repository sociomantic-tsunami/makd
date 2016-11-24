#!/bin/sh

# Copyright 2014-2016 Sociomantic Labs GmbH.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE or copy at http://www.boost.org/LICENSE_1_0.txt)

# Defaults
rev_file=src/Version.d
author="`git config user.name`"

# Get the current date (might be overridden by command-line options later)
date=$(date -u +"%Y-%m-%d %H:%M:%S %Z")

print_usage()
{
    echo "\
Generates a Version.d file.

Usage: $0 [OPTIONS] [TEMPLATE] [LIB1] [LIB2] ...

Options:

-o FILE      Where to write the output (Version.d) file (default: $rev_file)
-a AUTHOR    Author of the build (default: detected, currently $author)
-d DATE      Build date string (default: output of '$date_cmd')
-m MODULE    Module name to use in the module declaration (default: built from -o)
-v           Be more verbose (print a message if the file was updated)
-p           Only print this repository version and exit
-h           Shows this help and exit

TEMPLATE is template file to use

LIB1 ... are the name of the libraries this program depends on (to get the
libraries versions).

NOTE: All these options are replace in the template using sed s// command and
      this script doesn't get care of quoting, so if you use any 'special'
      character (like '/') you need to quote it yourself.
"
}

# Parse arguments
verbose=0
module=
print_only=
while getopts o:L:a:t:d:m:vph flag
do
    case $flag in
        o)  rev_file="$OPTARG";;
        a)  author="$OPTARG";;
        d)  date="$OPTARG";;
        m)  module="$OPTARG";;
        v)  verbose=1;;
        p)  print_only=1;;
        h)  print_usage ; exit 0;;
        \?) echo >&2; print_usage >&2; exit 2;;
    esac
done
shift `expr $OPTIND - 1`

version=`git describe --dirty --always`
# Add branch name if we only got a hash
echo "$version" | egrep -q '^[0-9a-f]{7}(-dirty)?$'  &&
    version=`git rev-parse --abbrev-ref HEAD`-g"$version"

# Check if the user only wanted to print the version number
if [ "$print_only" = 1 ]
then
    echo $version
    exit 0
fi

# Get compiler version
compiler="`${DC:-dmd} | head -1`"

template="$1"; shift

tmp=`mktemp mkversion.XXXXXXXXXX`

trap "rm -f '$tmp'; exit 1" INT TERM QUIT

# Generate the file (in a temporary) based on a template
cp "$template" "$tmp"
module=${module:-`echo "$rev_file" | sed -e 's|/|.|g' -e 's|.d||g'`}

sed -i "$tmp" \
    -e "s/@MODULE@/$module/" \
    -e "s/@VERSION@/$version/" \
    -e "s/@DATE@/$date/" \
    -e "s/@AUTHOR@/$author/" \
    -e "s/@COMPILER@/$compiler/"

# Generate the libraries info
libs=''
for lib in "$@"
do
    lib_base=`basename $lib`

    ver_desc=`cd $lib && git describe --dirty --always`
    # Add branch name if we only got a hash
    echo "$ver_desc" | egrep -q '^[0-9a-f]{7}(-dirty)?$'  &&
        ver_desc=`cd $lib && git rev-parse --abbrev-ref HEAD`-g"$ver_desc"

    libs="${libs}    versionInfo[\"lib_${lib_base}\"] = \"${ver_desc}\";\\n"
done
sed -i "s/@LIBRARIES@/$libs/" "$tmp"

# Check if anything has changed
if [ -e "$rev_file" ]
then
    sum1=`md5sum "$tmp" | cut -d' ' -f1`
    sum2=`md5sum "$rev_file" | cut -d' ' -f1`
    if [ $sum1 = $sum2 ]
    then
        rm "$tmp"
        exit 0
    fi
fi
mv "$tmp" "$rev_file"
if test "$verbose" -gt 0
then
    echo "$rev_file updated"
fi

# vim: set et sw=4 sts=4 :
