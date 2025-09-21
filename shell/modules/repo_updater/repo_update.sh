##
# Repo updater functions ( Local )
##

repo_update_local_repos() {
    local_repos=${REPO_LOCAL_LIST}

    for repo in $local_repos; do
        msg_newline
        message "Starting to update $repo repository"
        msg_debug "Checking if theres packages to add"

        if [ ! -d $TOOL_OUT/pkgs/$ARCH/$repo ]; then
            mkdir -p $TOOL_OUT/pkgs/$ARCH/$repo
        fi

        if [ ! -z "$(ls -A $TOOL_OUT/pkgs/$ARCH/$repo/)" ]; then
            cd ${REPO_LOCAL_PATH}/$repo/packages

            # Copy over newly built packages from out/pkgs
            msg_debug "Moving fresh packages to $repo"
            cp -fv $TOOL_OUT/pkgs/$ARCH/$repo/*.pkg.tar.gz ${REPO_LOCAL_PATH}/$repo/packages/ || message "No new packages to add"

            ##
            # TODO: Automatically remove older packages ( save up space )
            ##

            # Creae temp folder
            msg_debug "Crating temp folder for db update"
            mkdir -p ../temp

            # Remove older repo db
            msg_debug "Removing old db"
            rm -f $repo.db* $repo.files*

            # Move all packages to temp folder
            msg_debug "Moving packages to temp folder"
            mv *${ARCH}*.pkg.tar.gz ../temp

            msg_debug "Creating new package databse"
            repo-add $repo.db.tar.gz ../temp/*${ARCH}*.gz &> ${TOOL_OUT}/toolset_${repo}_${TOOL_TIME}.log

            # START OF HACK: Edit repo-add to do this automatically
            rm $repo.{db,files}
            cp $repo.db.tar.gz $repo.db
            cp $repo.files.tar.gz $repo.files
            # END OF HACK: Edit repo-add to do this automatically

            # Move packages back to orig place
            msg_debug "Moving packages+db back to proper place"
            mv ../temp/* .

            rm -rf ../temp

            # Remove cached/temp packages that were built by toolset
            msg_debug "Removing older built package backups"
            rm -f $TOOL_OUT/pkgs/$ARCH/$repo/*.pkg.tar.gz

            message "$repo - has been updated"
        else
            message "Theres nothing to add to the repo"
        fi
        msg_newline
    done

    message "Repositories have been updated"
}

repo_start_update() {
    repo_check_env

    repo_update_local_repos
}
