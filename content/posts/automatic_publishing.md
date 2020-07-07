+++
title = "Org-mode Workflow Part 4: Automatic Web Publishing"
author = ["Jacob Chvatal"]
date = 2019-12-20T00:00:00-05:00
lastmod = 2020-07-06T23:10:17-04:00
tags = ["emacs"]
draft = false
+++

Disclaimer: This is NOT my article. I'm using it for testing.

This is a change that has been made to a file.

Some were curious about how I was automatically publishing my
Org files, so I thought I'd try to give some insight into the process.
You can find the Github repo [here](https://github.com/jethrokuan/braindump/).

I prefer my tools to be as simple as possible, but I'm also somewhat
lazy, so I tend to use whatever was easiest. Previously, I'd be using
Org's in-built HTML export, but it was missing a bunch of niceties
that weren't that trivial to implement, like RSS and sitemaps. This
was also [around the time when Kaushal Modi's ox-hugo package was
starting to take shape](https://www.reddit.com/r/emacs/comments/6qahdz/what%5Fare%5Fyou%5Fcurrently%5Fdeveloping%5Fin%5Femacs%5Flisp/dkvxgvs?utm%5Fsource=share&utm%5Fmedium=web2x) (See a pattern here? Lot's of the things I use
is just a matter of timing), so I went with `ox-hugo`.


## Using Ox-hugo {#using-ox-hugo}

`ox-hugo` exports your Org files into Markdown files, depending on how
you configure it. I use the one-post-per-file configuration, so every
Org file within my folder gets exported to a separate Markdown file,
and will have its own webpage. For example, [org/actor\_critic.org](https://github.com/jethrokuan/braindump/blob/master/org/actor%5Fcritic.org)
generates [contents/posts/actor\_critic.md](https://github.com/jethrokuan/braindump/blob/master/content/posts/actor%5Fcritic.md). [Hugo](https://gohugo.io/) will then take these
Markdown files and generate the appropriate HTML, just like any other
Hugo site.

The one-post-per-file configuration works great with the Zettelkasten
method, where notes are meant to be short. It's also the configuration
where linking between files actually works (it generates relative web
links).


## Org-ref {#org-ref}

[Org-ref](https://github.com/jkitchin/org-ref) is a package that helps with bibliography management. I'd
noticed that `org-ref` citations were being exported in a curious
format that didn't look nice in Hugo, and had found that this was the
default markdown export style from `org-ref`. There wasn't an easy way
to change this style either, so I overrode all the related functions
and packaged those into [jethrokuan/org-ref-ox-hugo](https://github.com/jethrokuan/org-ref-ox-hugo/). Here's my
configuration for that.

```emacs-lisp
  (use-package org-ref-ox-hugo
    :straight (:host github :repo "jethrokuan/org-ref-ox-hugo" :branch "custom/overrides")
    :after org org-ref ox-hugo
    :config
    (add-to-list 'org-ref-formatted-citation-formats
                 '("md"
                   ("article" . "${author}, *${title}*, ${journal}, *${volume}(${number})*, ${pages} (${year}). ${doi}")
                   ("inproceedings" . "${author}, *${title}*, In ${editor}, ${booktitle} (pp. ${pages}) (${year}). ${address}: ${publisher}.")
                   ("book" . "${author}, *${title}* (${year}), ${address}: ${publisher}.")
                   ("phdthesis" . "${author}, *${title}* (Doctoral dissertation) (${year}). ${school}, ${address}.")
                   ("inbook" . "${author}, *${title}*, In ${editor} (Eds.), ${booktitle} (pp. ${pages}) (${year}). ${address}: ${publisher}.")
                   ("incollection" . "${author}, *${title}*, In ${editor} (Eds.), ${booktitle} (pp. ${pages}) (${year}). ${address}: ${publisher}.")
                   ("proceedings" . "${editor} (Eds.), _${booktitle}_ (${year}). ${address}: ${publisher}.")
                   ("unpublished" . "${author}, *${title}* (${year}). Unpublished manuscript.")
                   ("misc" . "${author} (${year}). *${title}*. Retrieved from [${howpublished}](${howpublished}). ${note}.")
                   (nil . "${author}, *${title}* (${year})."))))
```


## Netlify {#netlify}

Setting up automatic publishing is trivial with [Netlify](https://www.netlify.com/), which has
first-class support for Hugo websites. Just create an account, and use
the default Hugo build settings, which looks something like this:

{{< figure src="images/automatic_publishing/screenshot2019-12-20_17-37-17_.png" caption="Figure 1: Netlify Build settings" >}}

Now each push to `master` branch will trigger a build and publish in
Netlify.


## Summary {#summary}

In sum, I used `ox-hugo` for making Hugo more Org-compatible,
`org-ref` and some hacks (`org-ref-ox-hugo`) to make citations look
nice, and Netlify to publish the website. This blog is also similarly
powered by Netlify.

Hope that helps!
