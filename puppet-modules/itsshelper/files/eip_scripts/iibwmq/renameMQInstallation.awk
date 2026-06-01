#!/bin/awk -f
# Edit the MQ installations file /etc/opt/mqm/mqinst.ini
# to replace the default installation names (e.g. Installation1) with
# the stack name (sp1, dv2, uat, prd etc).
BEGIN	{
	name="";
	FS="=";
	}
/^Installation:/	{
	if (name != "") {
		print "Installation:";
		print "   Name=" newname;
		print "   Description=" desc;
		print "   Identifier=" ident;
		print "   FilePath=" path;
		}
	name="";
	newname="";
	desc="";
	ident="";
	path="";
	}
/^   Name=/	{
	name=$2;
	}
/^   Description=/	{
	desc=$2;
	}
/^   Identifier=/	{
	ident=$2;
	}
/^   FilePath=/	{
	path=$2;
	fields=split(path,pathelements,"/");
	newname=pathelements[3];
	}
END	{
	if (name != "") {
                print "Installation:";
                print "   Name=" newname;
                print "   Description=" desc;
                print "   Identifier=" ident;
                print "   FilePath=" path;
                }
	}
