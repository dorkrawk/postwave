# Postwave 🌊

[![Gem Version](https://badge.fury.io/rb/postwave.svg)](https://badge.fury.io/rb/postwave)

Write your posts statically. Interact with them dynamically.

## What is Postwave?

Postwave is an opinionated flat-file based based blog engine.

It lets you write posts in Markdown and then display them on a dynamic site using the client functionality.

## Installation

```
gem install postwave
```

## Authoring Posts

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

This will generate at new Markdown file in the `_posts/` directory. The title is set to a random string of characters.  The filename will be the current timestamp.  This will eventually be overwritten by the `build` command, so don't worry too much about it. The file will have a general structure like this:

```
---
title: FNJEXWZP
date: 2022-01-01
tags:
---

Start writing!
```
Tags should be comma separated.

You can keep a post in "draft" status (meaning it won't get processed or added to the index) by adding `draft: true` to the top section of the post.

```
---
title: This Post Isn't Quite Ready
date: 2022-01-01
tags:
draft: true
---
```

### Build the Blog

```
> postwave build
```

This will "build" the blog. This involves:
- regenerating the `/meta/index.csv` file
- generating slugs for each posts based on the post title and ensuring that there are no duplicate slugs
- changing the post file names to match `yyyy-dd-mm-slug.md`
- updating the `/meta/summary.yaml`
- creating and updating tag files (which will be `/tags/[tag-name].yaml` files for each tag)
- updating the `/meta/rss` file to create a feed for your posts

## Displaying Posts

You can now use Postwave's build in client to display this posts in your project.

### Include the Client In Your Project

```ruby
require 'postwave/client'
```

### Create a Postwave Client
```ruby
postwave_client = Postwave::Client.new("path/to/config/postwave.yaml")
```

If you'd like to preload all the posts:
```ruby
postwave_client = Postwave::Client.new("path/to/config/postwave.yaml", preload: true)
```

### Get a Single Post

Pass in the stub (the filename without '.md') for the post.
```ruby
post = postwave_client.post("my-great-post")

# <Postwave::Post title="My Great Post", date=<Time ...>, tags=["tag1"], body="bla bla bla..">

puts post.title
# "My Great Post"
```

### Get a Collection of Posts

This will give you a list of posts for displaying on a page.

You can also filter by tags and specify offsets and limits (useful for pagination).

```ruby
posts = postwave_client.posts

# [<Postwave::Post ...>, <Postwave::Post ...>, ...]

tagged_posts = postwave_client.posts(tag: "lizards")

page2_posts = postwave_client.posts(offset: 10, limit: 10)
```
Posts will be in reverse chronological order.

### Get an Index of Posts

This will give you a quick list of post summaries containing the title, date, and stub, useful for building an archive page or quick index of posts.

You can also specify offsets and limits (useful for pagination).
```ruby
index = postwave_client(index)

# [<Postwave::PostStub title="My Great Post", date=<Time ...>, stub="my-great-post">, <Postwave::PostStub ...>, ...]

puts index.first.stub
# my-great-post

page2_index = postwave_client.index(offset: 10, limit: 10)
```
Index will be in reverse chronological order.

### Get Tags Used In the Blog

```ruby
tags = postwave_client.tags

# ["tag1", "tag2", "another-tag"]
```

### Get Details For A Tag

```ruby
tag = postwave_clinet.tag("tag1")

# <Postwave::Tag tile="tag1", count=1, post_slugs=["my-great-post"]>
```

### Get Text For An RSS Feed

```ruby
rss = postwave_client.rss

# "<?xml version="1.0" encoding="utf-8"?>..."
```

## Run Tests

```
rake test
```

## What is Postwave Not?

Postwave is not for everything.

It is not:
- for people who want to generate a purely static site
- for people who want unlimited customization
- for giant blogs with many many thousands of posts (maybe?)

## Why did you build another blogging tool?

I don't know. I probably like writing blog engines more than I like writing blog posts.

I wanted something that would let me writing simple Markdown posts but still let me just embed the index and post content into a custom dynamic site. This scratched an itch and seemed like it would be fun to build.
