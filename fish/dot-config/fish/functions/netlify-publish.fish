function netlify-publish --description "Deploy dist/ from the current directory to Netlify"
    if not test -d dist
        echo "netlify-publish: no dist/ in "(pwd)" - build with :make or 'calepin compile . dist' first" >&2
        return 1
    end

    set -l token (pass show api/netlify/token); or return 1
    set -l site_id (pass show api/netlify/site-id); or return 1

    pushd dist
    zip -qr ../netlify-publish.zip .
    popd

    set -l url (curl -sS -X POST \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/zip" \
        --data-binary "@netlify-publish.zip" \
        "https://api.netlify.com/api/v1/sites/$site_id/deploys" \
        | jq -r '.ssl_url // .message')

    echo $url
    if string match -q 'http*' -- $url
        if set -q WAYLAND_DISPLAY; or set -q DISPLAY
            vimb $url &
        end
    end

    rm -f netlify-publish.zip
end
