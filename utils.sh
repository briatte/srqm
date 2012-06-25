#! /bin/sh
clear
echo SRQM WEB INSTALLATION SCRIPT
echo Version 1.1
echo François Briatte
echo 2012-03-05
echo 
f=SRQM
p=~/Documents;
q=http://f.briatte.org/teaching/quanti

# SETUP
echo Preparing to install the "$f" folder at
echo
echo $p
echo
echo Installation requires approx 200MB of disk space.
echo Make sure that you are online for a full install.
echo 
echo Press:
echo [Enter] to continue with these settings.
echo [c] to modify the folder path and/or name.
echo [d] to zip existing SRQM datasets locally.
echo [q] to quit without installing or zipping.
read c
echo 

# LOCAL ZIP
if [[ $c = d ]]; then
	echo Full path to existing SRQM folder:
	read p
	if [ ! -d $p/Datasets ]; then
		echo [ERROR] The folder $p/Datasets does not exist.;
		echo [ERROR] Locate your SRQM folder and rename the Datasets folder if necessary.;
		exit 1
	else
		cd $p/Datasets
		for x in qog2011 wvs2000 nhis2009 ess2008 ebm2009 gss2010; do
			echo $x
			rm $x.zip
			rm $x-docs/.DS_Store
			zip -r $x $x.dta $x-docs
		done
		echo [INFO] Everything zipped fine.
		exit 0
	fi	
fi

# MODIFIERS
if [[ $c = c ]]; then
	echo New installation full path (any stable location):
	read p
	echo New folder name (recommended name: SRQM):
	read f	
elif [[ $c = q ]]; then
	echo [INFO] Stopped. Bye.
	exit 0
fi

# SRQM FOLDER
cd $p;
if [ ! -d $f ]; then
	mkdir -p $f
	echo [INFO] The folder $f was created.;
else
	echo [ERROR] The folder $f already exists.;
	echo [ERROR] Try again at a different location, or delete existing files first.;
	exit 1
fi

# SUBFOLDERS
cd $f;
mkdir Course Datasets Projects Replication;
echo [INFO] The folder $f now has subfolders.

# MATERIAL
echo [INFO] Downloading Stata Guide...
curl -s $q/guide.pdf -o "Course/guide.pdf"

echo [INFO] Downloading course syllabus...
curl -s $q/syllabus.pdf -o "Course/syllabus.pdf"

echo [INFO] Downloading course slides...
curl -s -f $q/slides/session[1-12].pdf -o "Course/session#1.pdf";

echo [INFO] Downloading course do-files...
curl -s -f $q/code/week[1-12].do -o "Replication/week#1.do";

for n in help draft1; do
	curl -s -f $q/code/extras/$d.do -o "Replication/#1.do";
done

# DATASETS
echo [INFO] Downloading datasets...
for d in qog2011 wvs2000 nhis2009 ess2008 ebm2009 gss2010; do
	echo [INFO] Downloading $d...
	curl -s $q/data/$d.zip -o "Datasets/$d.zip"
	# Clean up desktop files from Mac OS X.
	unzip -q Datasets/$d.zip -d Datasets/
	rm -rf Datasets/__MACOSX
	# The following are unneeded when the ZIP files are well-formed.
	# mv Datasets/$d/$d.dta Datasets/
	# mv Datasets/$d Datasets/$d-docs
	rm Datasets/$d.zip
done

# FINISH
echo [INFO] Done.
echo 
echo Your $f working folder is ready.
echo In Stata, set your working folder by typing:
echo 
echo cd \"$p/$f\"
echo 
echo The SRQM course also requires that you get the course emails and readings
echo from the ENTG, and that you install a copy of Stata to your Applications.
echo 
echo You are set. Bye!
echo
exit 0






### delete tex files in slides

cd ~/Documents/Teaching/SRQM/Admin/Slides/
rm *.aux *.dvi *.toc *.log *.nav *.out *.snm *.synctex.gz *.tex.bak

### rename slides: session --> week

ls session*.tex | awk '{print("mv "$1" "$1)}' | sed 's/session/week/2'
ls session*.tex | awk '{print("mv "$1" "$1)}' | sed 's/session/week/2' | /bin/sh

### zip datasets and documentation

cd /Users/fr/Documents/Teaching/SRQM/Datasets
for x in ebm2009 ess2008 nhis2009 qog2011 wvs2000 gss2010; do
	echo $x
	rm $x.zip
	rm $x-docs/.DS_Store
	zip -r $x $x.dta $x-docs
done