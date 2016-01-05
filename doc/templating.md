# Templating

## Directories

Before we get started, it's good to know that there are a couple of "special" folders within any Roger project. Don't worry, you can configure these; they're not hard-coded. The folders are:

* **project-path** this is the main directory containing the Rogerfile and all other directories.
* **html-path** this is the directory where all your HTML/CSS/Javascript will go (in subdirectories of course).
* **partials-path** this is the directory where all partials reside.
* **layouts-path** this is the directory where the layouts hang out.

The default project tree looks like this:

```
project-path
  |
  |- html (html-path)
  |
  |- partials (partials-path)
  |
  \- layouts (layouts-path)
```

Only the html-path has to exist. The others are not required.

## HTML

The html-path is actually the root for all you front-end code. This is what will be served as the document-root with `roger serve` and will be the base for a release when using `roger release`.

In the html-path you can put static files (images, documents, etc.) but also templates. Anything that the [Tilt Engine](https://github.com/rtomayko/tilt) can handle is ok. The only thing Roger adds is handling for front-matter, layouts and partials. 

## Front-matter

Every template can optionally start with a bit of front-matter. Front-matter is defined as follows:

```yaml
---
key: value
---
```

Front-matter is parsed as YAML and can contain data to be used in the template, layout or partial. You can access
these values in the templates (layouts and partials included) by using `document.KEY`.

## Layouts

Layouts are basically "wrap" templates. The layout will wrap around the rendered template. In the template front-matter you define what layout it should use by setting the `layout` key. See the example below.

### Basic layout example

#### html/template.html.erb
```erb
---
layout: default
---
Template
```

#### layouts/default.html.erb
```erb
Layout (before)
<% yield %>
Layout (after)
```

#### Results
This would result in:

```
Layout (before)
Template
Layout (after)
```

### Advanced layouts

#### Using `content_for`

You can have multiple regions in your layout. That way you can yield multiple times for each region. See the example below for usage on `content_for :name do ... end` and `yield :name`.

##### `content_for` example

###### html/template.html.erb
```erb
---
layout: default
---

<% content_for :sidebar %>
  Sidebar
<% end %>

The is the rest of the content
```

###### layouts/default.html.erb
```erb
<% yield %>

<div class="sidebar">
  <% yield :sidebar %>
</div>
```

###### Result
```
The is the rest of the content 

<div class="sidebar">
  Sidebar
</div>
```

## Partials

Partials are little pieces of template that can be easily reused. You can access the partials throught the `partial("partialpath")` method. You can optionall pass variables to the partial by passing a ruby hash of options as a second parameter. This works like this:

```ruby
partial("path/to/partial/relative/to/partials-path", {:key => "value"})
```

In the partial these can be accessed as local variables. So for instance in you `test.html.erb` partial that would look like this:

```erb
<%= key %>
```

### Blocks

Just like `content_for` partials also accept block syntax. This way you can pass a block of HTML to the partial. It works like this:

```erb
<% partial "my-partial" do %>
  Pass it to the partial
<% end %>
```

Within your partial file you can then use the content by yielding it:

```erb
<div class="my-partial">
    <% yield %>
</div>
```

## Helpers
Template helpers allow you to have custom functions in your templates. These functions will be executed in the same context as the template is in. This means they will have access to all other template features like the `document` and `env` variables.

A helper is nothing more than a plain old Ruby module containing a bunch of functions.

### Registering helpers
Registering helpers can best be done in the Rogerfile. Register this module as following:

```ruby
Roger::Template.register MyHelperModule
```

After registration the helpers are available for use in all templates, partials, layouts, etc. See the [template helpers tests](../test/unit/template/template_helper_test.rb) for example usage.

## Access to Project 

You can access the Roger project with all it's might and glory by accessing `env["roger.project"]`.
