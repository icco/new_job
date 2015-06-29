# New Job

You got a new job, and have to list all of your prior work in an easy to print format? This outputs some nice plain text for you.

## Setup / installation

 * `gem install bundler`
 * `bundle install`
 * `bundle exec ./projects.rb -t $GITHUB_TOKEN -d list`

## Usage

```
Usage: projects.rb [options]
    -d, --display {table,list}       Define display type. Default: table
    -s, --sort {alpha,date}          Define sort type. Default: alpha
    -t, --token <40 char auth token> User's auth token.
    -n, --[no-]netrc                 Use netrc.
    -h, --help                       Display this screen
```

## Authentication

 * You can [use a .netrc to set your username and password for your github account](https://gist.github.com/technoweenie/1072829). Does not work if you have two factor auth enabled. If you do, use the flag `-n`.
 * Or get an personal authentication code from https://github.com/settings/applications and use the flag `-t`.
