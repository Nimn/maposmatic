#! /bin/sh -x

extract_django() {
    DIR=$1

    if [ -d ${DIR} ]
    then    
	pushd ${DIR}
	TEMPLANG=foobar
	django-admin.py makemessages --no-wrap -l ${TEMPLANG}
	# Remove the creation date to avoid spurious commits
	grep -v "POT-Creation-Date:" locale/${TEMPLANG}/LC_MESSAGES/django.po > locale/django.pot
	rm -rf locale/${TEMPLANG}
	popd
    fi
}

git checkout master

# Try to extract keys no matter where we are
[ -d www ]    && extract_django www
[ -d ../www ] && extract_django ../www

# Push keys to transifex
tx push --no-interactive --source

# Commit any changes
git diff

git config user.email "hakan@gurkensalat.com"
git config user.name "Hakan Tandogan"

git add scripts/transifex-extract-keys.sh
git commit -m "Updated extraction script" scripts/transifex-extract-keys.sh

git config user.email "transifex-daemon@gurkensalat.com"
git config user.name "Transifex Daemon"

git add $(find . -name \*.pot)
git commit -m "Extracted message keys" $(find . -name \*.pot)

# Done, git push to be done manually or from jenkins