##
# Repo updater functions ( Local )
##

repo_update_local_repos() {
    local_repos=${REPO_LOCAL_LIST}

    for repo in $local_repos; do
        message "Starting to update $repo repository"
        cd ${REPO_LOCAL_PATH}/$repo/packages

        if [ -f $TOOL_OUT/pkgs/$ARCH/$repo/*.pkg.tar.gz ]; then
            # Copy over newly built packages from out/pkgs
            cp -fv $TOOL_OUT/pkgs/$ARCH/$repo/*.pkg.tar.gz ${REPO_LOCAL_PATH}/$repo/packages/

            # TODO: Automatically remove older packages ( save up space )
        fi

        # Creae temp folder
        mkdir -p ../temp

        # Remove older repo db
        rm -f $repo.db* $repo.files*

        # Move all packages to temp folder
        mv *${ARCH}*.pkg.tar.gz ../temp

        repo-add $repo.db.tar.gz ../temp/*${ARCH}*.gz &> ${TOOL_OUT}/toolset_${repo}_${TOOL_TIME}.log

        # START OF HACK: Edit repo-add to do this automatically
        rm $repo.{db,files}
        cp $repo.db.tar.gz $repo.db
        cp $repo.files.tar.gz $repo.files
        # END OF HACK

        # Move packages back to orig place
        mv ../temp/* .

        rm -rf ../temp

        # Remove cached/temp packages that were built by toolset
        rm -f $TOOL_OUT/pkgs/$ARCH/$repo/*.pkg.tar.gz

        message "$repo - has been updated"
        msg_newline
    done
}

repo_start_update() {
    repo_check_env

    repo_update_local_repos
}
