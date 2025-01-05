
<!--#echo json="package.json" key="name" underline="=" -->
webgit-easycgi-pmb
==================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
A CGI to easily webserve only committed objects and selected branches of git
repositories.
<!--/#echo -->



Purpose
-------

I want to share some of my git repos on the intranet.
One easy way to do this is to put them on a webspace.
Well, _almost_ easy.

### Problems with the naive approach:

* Intended sharing is cumbersome:
  I'd have to (set up a mechanism to) run `git update-server-info` whenever
  I want my new commits to become visible to regular git web clients.
* Unintended sharing is easy:
  When sharing the entire `.git` directory, a snoopy web audience can access
  stuff that maybe they shouldn't. Examples:
  * My git config
  * My temporary/draft branches (see chapter "Security" below)
  * My remotes
  * Which branch I've currently checked out
  * Various temporary files from git tools, e.g.
    `COMMIT_EDITMSG` or `GIT_COLA_MSG` (when using git-cola)

### CGI to the rescue!

Thus the need for a way to easily share the parts important for cloning
selected branches, while sharing as little as possible of the other stuff.



Install
-------

1.  Clone this repo somewhere. For this tutorial, we'll assume you cloned it
    to `/home/bernd/webdev/webgitcgi`.
1.  In your webspace's CGI directory, create some subdirectory for your
    repos. For this guide we'll assume it's `/var/www/cgi-bin/repos`.
1.  Copy `stub.sh` from this repo into `/var/www/cgi-bin/repos/` as any
    filename you like and your webmaster allows; for this tutorial,
    we'll name the remote copy `gits.sh`.
    * With some combinations of server type and copy method, you may need
      to manually set the executable flag on the remote copy of the stub file.
    * If CGI doesn't easily work with your webspace, you can try to use PHP
      instead. In this case, copy `stub.php` as `gits.php`.
1.  Edit the stub file in your webspace and configure it
    (see the "Config" chapter below).
    You'll probably need to adjust at least the `share_sh_path`
    to wherever you cloned this repo. In case of this tutorial,
    it would be `/home/bernd/webdev/webgitcgi/share.sh`.
1.  Add symlinks to the `objects` directories of the git repos you want
    to share. We'll assume you want to share the repository
    `/home/bernd/webdev/brot/app-repo` as visible name `brot-app`.
    In this case, your symlink should be `/cgi-bin/repos/brot-app`
    and its target should be `/home/bernd/webdev/brot/app-repo/.gi/objects`.
1.  Assuming your webspace is on http://example.net/, visit
    http://example.net/cgi-bin/repos/gits.sh/brot-app
    (or `…/gits.php/brot-app` for the PHP approach).
    There you should see information about how to clone the repo.



Config
------

Near the top of your stub file, you'll find a marker line
`#=== Config starts here ===#`.
That section is where you should put your settings.

For descriptions of the available settings, please refer to
[`cfg.defaults.rc`](cfg.defaults.rc).





Security
--------

* Secret branches, or at least their objects, may still be discoverable
  in some circumstances:
  * If people know or guess the SHA-1 of available objects.
    * This is trivial if directory indexes are enabled on the webspace.
  * Probably packs.
  * Stuff I may have forgotten.

* Webhosting CGIs securely is hard. Take care.



<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
