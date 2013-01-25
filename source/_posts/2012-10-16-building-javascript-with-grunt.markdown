---
layout: post
title: "Building Javascript with Grunt"
date: 2012-10-16 09:59
comments: false
categories: [build, grunt, jasmine, javascript, tools]
---

When you develop a Javascript lib, you need to do fun stuff like concatenating source files, validating with JSHint and minifying. After I got past the initial phase of doing it by hand (many headaches, didn't last long), I started doing it with Rake tasks and npm packages. As you can imagine, the Rake task quickly became a headache of its own.

Enters Grunt, a build tool which does all that for you, plus other goodies. It's a task-based tool so it has tasks like concat to concatenate files, which you can run with grunt concat at the command line. This post is a quick example of what you can achieve with Grunt.

<!--more-->

This is the basic structure of the configuration file.

{% codeblock lang:js %}
module.exports = function(grunt) {
 
  // Plugins.
  grunt.loadNpmTasks('grunt-rigger');
  grunt.loadNpmTasks('grunt-jasmine-runner');
 
  // Project configuration.
  grunt.initConfig({
 
    pkg: '<json:package.json>',
    meta: {
      version: '<%= pkg.version %>'
    }
 
    // ...
  });
};
{% endcodeblock %}

As you can see, there is a plugin system allowing you to include others' plugins or write your own.

The project configuration contains task configurations and other useful data. In the above example, we do two things. First we read and parse the project's package.json file into pkg. In meta, we extract the package version. We will use this information in some tasks.

## Validating with JSHint

Grunt provides the lint task for that. You can define the files to validate and JSHint options.

{% codeblock lang:js %}
lint: {
  files: ['src/myPlugin.*.js']
},
jshint: {
  globals: {
    _: true,
    $: true
  }
}
{% endcodeblock %}

Then just run grunt lint.

## Concatenating

Grunt provides the concat task.

{% codeblock lang:js %}
concat: {
  myPlugin : {
    src : [
      'vendor/jquery.js',
      'src/myPlugin.core.js',
      'src/myPlugin.components.js'
    ],
    dest : 'lib/myPlugin.js'
  }
}
{% endcodeblock %}

Here, you define that you want to concatenate three files from vendor and src into one file in lib. The concatenation has a name (myPlugin) which is shown when you run it. You can define as many as you want. They will all be performed when you run grunt concat.

## Defining a Banner

Once you have carefully chosen your favorite license, you may want to include a banner with copyright information in your javascript library. Of course, it would be nice if that banner didn't clutter your source files and was only present in the final library file. Here we define a banner that we will use in the next minification task. This banner can include data from your package file or other meta data so you don't have to repeat yourself.

{% codeblock lang:js %}
meta: {
  // ...
  banner:
    '/*!\n' +
    ' * myPlugin v<%= meta.version %>\n' +
    ' * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %>\n' +
    ' * Distributed under MIT license\n' +
    ' * <%= pkg.homepage %>\n' +
    ' */'
}
{% endcodeblock %}

## Minifying with UglifyJS

Grunt provides minification with UglifyJS with the min task.

{% codeblock lang:js %}
min: {
  myPlugin: {
    src: [
      '<banner:meta.banner>',
      '<config:concat.myPlugin.dest>'
    ],
    dest: 'lib/myPlugin.min.js'
  }
}
{% endcodeblock %}

This configuration defines that we want `lib/myPlugin.min.js` to be built by minifying our concatenated source file and prepending the banner (the banner will not be minified by UglifyJS as it starts with `/*!`). As you can see, you can use information from other tasks like concat.

If you need to configure UglifyJS options, you can add an uglify object at the same level as min.

## Running Jasmine Specs

My favorite Javascript testing framework at the moment is Jasmine. Grunt has a Jasmine plugin that allows you to run your specs headlessly with PhantomJS.

First you must install the plugin. If you're using NPM and have a package.json file, you can add this to your dependencies and run npm install:

{% codeblock lang:js %}
"devDependencies": {
  "grunt-jasmine-runner": "latest"
}
{% endcodeblock %}

Then, you must add the plugin to your Grunt configuration file:

{% codeblock lang:js %}
module.exports = function(grunt) {
 
  // Plugins.
  grunt.loadNpmTasks('grunt-jasmine-runner');
 
  // ...
};
{% endcodeblock %}

Once this is done, you can at last configure the jasmine task.

{% codeblock lang:js %}
jasmine : {
  src : [
    'vendor/jquery.js',
    'src/myPlugin.core.js',
    'src/myPlugin.components.js'
  ],
  helpers : 'spec/javascripts/helpers/*.js',
  specs : 'spec/javascripts/**/*.spec.js'
}
{% endcodeblock %}

`src` defines which source files to test (loaded first). `helpers` can include any code to help in testing. `specs` indicates the spec files containing your Jasmine tests. For more options, check out [grunt-jasmine-runner](https://github.com/jasmine-contrib/grunt-jasmine-runner).

You can now run your specs with grunt jasmine.

## Default Task

Once your project configuration is set up, you can also define a default task (or series of tasks).

{% codeblock lang:js %}
module.exports = function(grunt) {
 
  // Project configuration.
  grunt.initConfig({
    // ...
  });
 
  // Default task (when you call grunt without arguments).
  grunt.registerTask('default', 'lint concat min');
};
{% endcodeblock %}

In this case, it validates the javascript, concatenates the source files and minifies them. That way you can just run grunt and have everything ready for release. Of course, it will fail if validation doesn't pass, allowing to fix any errors before you can run it.

## Moar

The Grunt website provides a number of configuration file examples.

Go build some Javascript now.
