#/usr/bin/env bash

# general
sitename="sitename"
baseurl="http://example.org"
lang="en"

render_template(){
local title=$1
local content=$2

local html="<!DOCTYPE html>
<html lang=\"${lang:=en}\">
<head>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>${title}</title>
</head>
<body>
<nav>
<a href=\"$baseurl\">home</a>
</nav>
<main>
$content
</main>
<hr>
<footer>
Built with <a href=https://github.com/ertfm/ssg7>ssg7.</a>
</footer>
</html>
"

printf "$html"
}

wrap_index_content(){
local content=$1

local index_content="

<h1>$sitename</h1>
<ul>
$content
</ul>
"

printf "$index_content"
}


usage() {
  printf "usage: $0 SOURCE DEST\n"
  exit 1
}

[[ -d $1 ]] && source_dir=$1 || usage
[[ ! -z $2 ]] && dest_dir=$2 || usage

# remove trailing slash from baseurl
baseurl=${baseurl%/}

posts_dir="$dest_dir/posts"
posts_url="$baseurl/posts"

mkdir -p $posts_dir

mdfiles=($source_dir/*.md)
for filepath in $source_dir/*.md; do
  filename="${filepath##*/}"
  post=$(markdown $source_dir/$filename)
  [[ $post =~ \<h1\>(.*)\</h1\> ]] && post_title=${BASH_REMATCH[1]}

  render_template "$post_title" "$post" > $posts_dir/${filename%%.md}.html

  # generate posts list for index
  posts_list+="
  <li> 
  <a href=\"$posts_url/${filename%%.md}.html\">$post_title</a>
  </li>
  "
done

index_content=$(wrap_index_content "$posts_list")
render_template "$sitename" "$index_content" > $dest_dir/index.html
