# Ghostpages.sh

### Create and organize your blog with Ghost, generate a static website and deploy on github pages.

* nodejs v.6, 8 or 10 __required__

1. Clone this repo
    * (make it private if you want to backup your data on Github as well)
    * make sure to add a `remote/origin` url
3. `sh ghostpages.sh install`
	* a `ghost` folder is created containing all your blog and required data
	* `node_modules` contains `ghost-cli` and `ghost-static-site-generator`
    * &rarr; you can now edit your blog at `localhost:2373/ghost`
4. `sh ghostpages.sh generate`
	* `static` folder contains the static website
    * a `CNAME` file is created
5. `sh ghostpages.sh publish`
	* push the `static` folder on Github-Pages via `remote/origin/gh-pages`
6. `sh ghostpages.sh backup`
    * create a zip archive of your content and database
