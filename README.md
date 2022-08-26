# Postwave 🌊

Write your posts statically. Interact with them dynamically.

## What is Postwave?

Postwave is an opinionated flat-file based based blog engine.

It lets you write posts in Markdown and then display them on a dynamic site using a client library.

## Getting Started

### Setup

```
> postwave new
```

Run this from the root directory of your project. It will create a `postwave.yaml` config file in the current directory and a `/_posts/` directory. This is where you will write your posts.

Here is what will be created:

```
|- _posts/
|  |- meta/
|     |- tags/
|     |- index.csv
|     |- summary.yaml
postwave.yaml
```

`_posts/`: This is where you write all your posts in Markdown

`_posts/meta/tags/`: This will contain files for every tag your define in your posts

`_posts/meta/index.csv`: This will contain an ordered list of all the posts

`_posts/meta/summary.yaml`: This file will contain some summary information about the posts. Total count, etc.

`postwave.yaml`: The config file for Postwave.

### Create A New Blog Post

```
> postwave post
```

This will generate at new Markdown file in the `_posts/` directory. The filename will be the current timestamp. This will eventually be overwritten by the `build` command, so don't worry too much about it. The file will have a general structure like this:

```
---
title:
date: 2022-01-01
tags:
---

Start writing!
```
Tags should be comma separated.

You can add an optional `slug:` value in the top section if you want to control the filename.

You can keep a post in "draft" status (meaning it won't get processed or added to the index) by adding `draft: true` to the top section of the post.

### Build the Blog

```
> postwave build
```

This will "build" the blog. This involves:
- regenerating the `index.csv` file
- changing the post file names to match `yyyy-dd-mm-title-or-slug.md`
- updating the `summary.yaml`
- creating and updating tag files (which will be `/tags/[tag-name].yaml` files for each tag)

## Available Client Libraries

- [Ruby](https://github.com/dorkrawk/postwave-ruby-client)

## What is Postwave Not?

Postwave is not for everything.

It is not:
- for people who want to generate a purely static site
- for people who want unlimited customization
- for giant blogs with many many thousands of posts (probably?)

## Why did you build another blogging tool?

I don't know. I probably like writing blog engines more than I like writing blog posts.

I wanted something that would let me writing simple Markdown posts but still let me just embed the index and post content into a custom dynamic site. This scratched an itch and seemed like it would be fun to build.
