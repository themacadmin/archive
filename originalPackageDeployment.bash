#/bin/bash

for packageage in $( ls /Volumes/COMMON-DEV\$/APPLE_OSX/Software/Packages/ );
	do
	if test ! -e /Users/Shared/Packages/$packageage -o /Users/Shared/Packages/$packageage -ot /Volumes/COMMON-DEV\$/APPLE_OSX/Software/Packages/$packageage
	then echo copying $packageage ; cp -R /Volumes/COMMON-DEV\$/APPLE_OSX/Software/Packages/$packageage /Users/Shared/Packages/$packageage
	fi
done

if test `arch` == "i386"
then for i in $( ls /Users/Shared/Packages/intel/ );
	do
	fn=$i
	installer -pkg /Users/Shared/Packages/ppc/$i -target /Volumes/Macintosh\ HD/
done
elif test `arch` == "ppc"
then for i in $( ls /Users/Shared/Packages/ppc/ );
	do
	fn=$i
	installer -pkg /Users/Shared/Packages/ppc/$i -target /Volumes/Macintosh\ HD/
done
fi

exit 0