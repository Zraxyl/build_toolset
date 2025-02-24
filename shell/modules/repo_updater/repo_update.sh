##
# Repo updater functions ( Local )
##

repo_update_local_repos() {
    local_repos=${REPO_LOCAL_LIST}

    for repo in $local_repos; do
        message "Copying over new packages to $repo"
        cd ${REPO_LOCAL_PATH}/$repo/packages

        # Copy over newly built packages from out/pkgs
        #cp -fv $TOOL_OUT/pkgs/$ARCH/$repo/*.pkg.tar.gz ${REPO_LOCAL_PATH}/$repo/packages/

        # TODO: Automatically remove older packages ( save up space )

        message "Starting to update $repo repository"

        # Creae temp folder
        mkdir -p ../temp

        # Move all packages to temp folder
        mv *${ARCH}*.pkg.tar.gz ../temp

        # Remove older repo db
        rm -f $repo.db* $repo.files*

        repo-add $repo.db.tar.gz ../temp/*${ARCH}*.gz &> ${TOOL_OUT}/toolset_${repo}_${TOOL_TIME}.log

        # Move packages back to orig place
        mv ../temp/* .

        rm -rf ../temp
        message "Repo $repo has been updated"
    done
}

repo_start_update() {
    repo_check_env

    repo_update_local_repos
}
