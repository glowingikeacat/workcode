#!/usr2/apl/Perl/bin/perl
#--------------------------------------------------------------
# Searches the Oracle database for ACS information and produces
# formatted HTML for visual display.
#
# Created by GVGouzev (D238, 505-8418) 9/22/99
#
# Modification History:
#
# 10-DEC-2012 TWH Changed password.
#
#--------------------------------------------------------------
# Initalization and setup
require '/usr2/apl/iplanet/servers/cgi-bin/cgi-lib.pl';
$basedir = '/usr2/apl/iplanet/servers/cgi-bin/tid';

use Text::Wrap;

$ENV{'ORAENV_ASK'}  = 'no';
$ENV{'ORACLE_BASE'} = '/usr4/apl/oracle/product';
$ENV{'ORACLE_HOME'} = "$ENV{'ORACLE_BASE'}/9.2.0";
$ENV{'ORACLE_TERM'} = 'sun5';
$ENV{'PATH'} .= ":$ENV{'ORACLE_HOME'}/bin";
$ENV{'EPC_DISABLED'} = "TRUE";
$| = 1;




# Parse the input and act accordingly
if (&ReadParse(*input)) {
if ($input{'pd'} =~ /[\&\;\'\`\\\"\|\*\~\>\<\]\^\[\}\{\$\n\r]/) {exit print &PrintHeader, '<CENTER><B>BAD INPUT. USE ONLY ALPHA-NUMERIC DATA!</B></CENTER>';}

$pdnum = uc($input{'pd'});

# Analyze for which db to query until they are merged
if ($pdnum =~ /[A-Z]/) {
$hquery = 'hdr2.sql';
$aquery = 'acs2.sql';
$cquery = 'cf2.sql';
}
elsif ($pdnum < 55500)  {
$hquery = 'hdr.sql';
$aquery = 'acs.sql';
$cquery = 'cf.sql';
}
elsif ($pdnum > 55500) {
$hquery = 'hdr2.sql';
$aquery = 'acs2.sql';
$cquery = 'cf2.sql';
}

else {
print &PrintHeader, '<CENTER><B>INPUT IS INVALID!</B></CENTER></BODY></HTML>';
exit 0;
}

# Print the header, get modules, close the page
print "Pragma: cache\n";
print "Content-type: text/html\n\n",
"<HTML><HEAD><TITLE>ACS FOR PD NUMBER $pdnum</TITLE></HEAD>\n",
'<BODY BGCOLOR="#FFFFFF" LINK="#000000" VLINK="#000000" ALINK="#000000">', "\n",
"<H3 ALIGN=\"CENTER\">ACS FOR PD NUMBER $pdnum</H3></TD>\n";

print "<PRE>Report Date:   ", `date`;

&HdrInfo;
&StdFeatures;
&CustFeatures;
&PutFooter;
exit 0;
} else {
print &PrintHeader, '<CENTER><B>INPUT COULD NOT BE PARSED!</B></CENTER></BODY></HTML>';
exit 0;
}

#--------------------------------------------------------------
# Function      - PutFooter
# Description   - Outputs and HTML stream with the page footer
#--------------------------------------------------------------

sub PutFooter {
print STDOUT <<__END_OF_HTML_CODE__;
</PRE><HR SIZE="1"><center><font face="Arial, Helvetica, sans-serif" size="1">
<a href="https://solarweb.solar.cat.com/">Solar</a> <font color="#F7BF00">|</font>
<a href="https://solarweb.solar.cat.com/dept/default.htm">Departments</a> <font color="#F7BF00">|</font>
<a href="https://plm.solar.cat.com/Windchill/">Documents &amp; Drawings</a> <font color="#F7BF00">|</font>
<a href="https://solarweb.solar.cat.com/procs/default.htm">Procedures</a> <font color="#F7BF00">|</font>
<a href="https://catatwork.cat.com/wps/myportal/empcat/newsroom">News &amp; Info</a> <br>
<a href="https://solarweb.solar.cat.com/empdir/default.htm">Employee Directory</a> <font color="#F7BF00">|</font>
<a href="https://catatwork.cat.com/wps/myportal/empcat/search">Search</a> <font color="#F7BF00">|</font>
<a href="https://solarweb2.solar.cat.com/pso/comments.htm">Comments</a><BR><BR>
Caterpillar confidential: <A HREF="https://gis.cat.com/cda/layout?m=395181&x=7"><FONT COLOR="#00A000">Green</FONT></A></BR>
<A HREF="https://solarweb.solar.cat.com/corp/legal-notices.htm">Copyright ¨ Solar Turbines Incorporated.á
All rights reserved.</A></FONT></CENTER></BODY></HTML>

__END_OF_HTML_CODE__
}

#-----------------------------------------------------
# Function Name  - HdrInfo
# Description    - Retrieves PID identifying info
# Arguments      - none
#-----------------------------------------------------

sub HdrInfo {

local ($pdnum) = uc($input{'pd'});

# Open the query and execute it
if (open(QRY,"sqlplus -s techpubs/t4r4ngp0dc4st\@pds \@$basedir/$hquery \"$pdnum\" |")) {
while (<QRY>) {
if ($_ =~ /(.*);(.*);(.*);(.*)/) {
print "Project Name:  $1\n";
print "Current Rev:   $2\n";
print "Revision Date: $3\n";
print "Project Mgr:   $4\n\n";
}
}
close(QRY);
} else {
print "Could not execute Oracle query\n";
}
}

#-----------------------------------------------------
# Function Name  - StdFeatures
# Description    - Retrieves ACS standard features
# Arguments      - none
#-----------------------------------------------------

sub StdFeatures {

local ($pdnum) = uc($input{'pd'});

# Open the query and execute it
if (open(QRY,"sqlplus -s techpubs/t4r4ngp0dc4st\@pds \@$basedir/$aquery \"$pdnum\" |")) {
while (<QRY>) {
$_ =~ s/;//g;
print "$_";
}
close(QRY);
} else {
print "Could not execute Oracle query\n";
}
}

#-----------------------------------------------------
# Function Name  - CustFeatures
# Description    - Retrieves ACS standard features,
#                  stripping the RTF codes
# Arguments      - none
#-----------------------------------------------------

sub CustFeatures {

local ($pdnum) = uc($input{'pd'});

print "\n\n<B>CUSTOM FEATURES FOR PD NUMBER $pdnum</B>\n";

# Open the query and execute it
if (open(QRY,"sqlplus -s techpubs/t4r4ngp0dc4st\@pds \@$basedir/$cquery \"$pdnum\" |")) {
while (<QRY>) {
$_ =~ s/;//g;
$_ =~ s/\{.*\}//g;
$_ =~ s/\\[a-z0-9]+//g;
$_ =~ s/^\s//g;
$_ =~ s/^\}//;
if ("$_" =~ /^[1-9]/) {print "\n";}
print wrap("", "", "$_");
}
close(QRY);
} else {
print "Could not execute Oracle query\n";
}
}
