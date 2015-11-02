#!/usr/bin/env ruby

# ================================================================
# This is a manpage autogenerator for Miller. There are various tools out there
# for creating xroff-formatted manpages, but I wanted something with minimal
# external dependencies which would also automatically generate most of its
# output from the mlr executable itself.  It turns out it's easy enough to get
# this in just a few lines of Ruby.
#
# Note for dev-viewing of the output:
# ./mkman.rb | groff -man -Tascii | less
# ================================================================

# ----------------------------------------------------------------
def main

  print make_top

  print make_section('NAME', [
    "Miller is like sed, awk, cut, join, and sort for name-indexed data such as CSV."
  ])

  print make_section('SYNOPSIS', [
`mlr --usage-synopsis`
  ])

  print make_section('DESCRIPTION', [
"""Miller operates on key-value-pair data while the familiar Unix tools operate
on integer-indexed fields: if the natural data structure for the latter is the
array, then Miller's natural data structure is the insertion-ordered hash map.
This encompasses a variety of data formats, including but not limited to the
familiar CSV.  (Miller can handle positionally-indexed data as a special
case.)"""
  ])

  print make_section('EXAMPLES', [
    ""
  ])

  print make_code_block(
"""
% mlr --csv cut -f hostname,uptime mydata.csv
% mlr --csv filter '$status != \"down\" && $upsec >= 10000' *.csv
% mlr --nidx put '$sum = $7 + 2.1*$8' *.dat
% grep -v '^#' /etc/group | mlr --ifs : --nidx --opprint label group,pass,gid,member then sort -f group
% mlr join -j account_id -f accounts.dat then group-by account_name balances.dat
% mlr put '$attr = sub($attr, \"([0-9]+)_([0-9]+)_.*\", \"\\1:\\2\")' data/*
% mlr stats1 -a min,mean,max,p10,p50,p90 -f flag,u,v data/*
% mlr stats2 -a linreg-pca -f u,v -g shape data/*
"""
  )

  print make_section('OPTIONS', [
"""In the following option flags, the version with \"i\" designates the input
stream, \"o\" the output stream, and the version without prefix sets the option
for both input and output stream. For example: --irs sets the input record
separator, --ors the output record separator, and --rs sets both the input and
output separator to the given value."""
  ])

	print make_subsection('VERB LIST', [])
	print make_code_block(`mlr --usage-list-all-verbs`)

	print make_subsection('HELP OPTIONS', [])
	print make_code_block(`mlr --usage-help-options`)

	print make_subsection('FUNCTION LIST', [])
	print make_code_block(`mlr --usage-functions`)

	print make_subsection('I/O FORMATTING', [])
	print make_code_block(`mlr --usage-data-format-options`)

	print make_subsection('SEPARATORS', [])
	print make_code_block(`mlr --usage-separator-options`)

	print make_subsection('CSV-SPECIFIC OPTIONS', [])
	print make_code_block(`mlr --usage-csv-options`)

	print make_subsection('DOUBLE-QUOTING FOR CSV/CSVLITE OUTPUT', [])
	print make_code_block(`mlr --usage-double-quoting`)

	print make_subsection('NUMERICAL FORMATTING', [])
	print make_code_block(`mlr --usage-numerical-formatting`)

	print make_subsection('OTHER OPTIONS', [])
	print make_code_block(`mlr --usage-other-options`)

	print make_subsection('THEN-CHAINING', [])
	print make_code_block(`mlr --usage-then-chaining`)

  verbs = `mlr --list-all-verbs-raw`
  print make_section('VERBS', [
    ""
  ])
  verbs = verbs.strip.split("\n")
  for verb in verbs
    print make_subsection(verb, [])
    print make_code_block(`mlr #{verb} -h`)
  end

  print make_section('AUTHOR', [
    "Miller is written by John Kerl <kerl.john.r@gmail.com>.",
    "This manual page has been composed from Miller's help output by Eric MSP Veith <eveith@veith-m.de>."
  ])
  print make_section('SEE ALSO', [
    "sed(1), awk(1), cut(1), join(1), sort(1), RFC 4180: Common Format and MIME Type for " +
    "Comma-Separated Values (CSV) Files, the miller website http://johnkerl.org/miller/doc"
  ])
end

# ================================================================
def make_top()
  t = Time::new
  stamp = t.gmtime.strftime("%Y-%m-%d")

  # Portability definitions thanks to some asciidoc output

"""'\\\" t
.\\\"     Title: mlr
.\\\"    Author: [see the \"AUTHOR\" section]
.\\\" Generator: #{$0}
.\\\"      Date: #{stamp}
.\\\"    Manual: \\ \\&
.\\\"    Source: \\ \\&
.\\\"  Language: English
.\\\"
.TH \"MILLER\" \"1\" \"#{stamp}\" \"\\ \\&\" \"\\ \\&\"
.\\\" -----------------------------------------------------------------
.\\\" * Portability definitions
.\\\" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.\\\" http://bugs.debian.org/507673
.\\\" http://lists.gnu.org/archive/html/groff/2009-02/msg00013.html
.\\\" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ie \\n(.g .ds Aq \(aq
.el       .ds Aq '
.\\\" -----------------------------------------------------------------
.\\\" * set default formatting
.\\\" -----------------------------------------------------------------
.\\\" disable hyphenation
.nh
.\\\" disable justification (adjust text to left margin only)
.ad l
.\\\" -----------------------------------------------------------------
"""
end

# ----------------------------------------------------------------
def make_section(title, paragraphs)
  retval = ".SH \"#{title}\"\n"
  paragraphs.each do |paragraph|
    retval += ".sp\n"
    retval += groff_encode(paragraph) + "\n"
  end
  retval
end

# ----------------------------------------------------------------
def make_subsection(title, paragraphs)
  retval = ".SS \"#{title}\"\n"
  paragraphs.each do |paragraph|
    retval += ".sp\n"
    retval += groff_encode(paragraph) + "\n"
  end
  retval
end

# ----------------------------------------------------------------
def make_subsubsection(title, paragraphs)
  retval  = ".sp\n";
  retval += "\\fB#{title}\\fR\n"
  paragraphs.each do |paragraph|
    retval += ".sp\n"
    retval += groff_encode(paragraph) + "\n"
  end
  retval
end

# ----------------------------------------------------------------
def make_code_block(block)
  retval  = ".if n \\{\\\n"
  retval += ".RS 0\n"
  retval += ".\\}\n"
  retval += ".nf\n"
  retval += block.gsub('\\', '\e')
  retval += ".fi\n"
  retval += ".if n \\{\\\n"
  retval += ".RE\n"
end

# ----------------------------------------------------------------
def groff_encode(line)
  #line = line.gsub(/'/, '\(cq')
  #line = line.gsub(/"/, '\(dq')
  line = line.gsub(/\./, '\&')
  #line = line.gsub(/-/, '\-')
  line = line.gsub(/\\/, '\e')
  line
end

# ================================================================
main
