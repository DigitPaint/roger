# Command Line Interface

The easiest way to get help is through the commandline by running

```shell
roger help
```

or to get help on a specific subcommand

```shell
roger help [subcommand]
```

## Generate

```shell
roger generate [generator] [options]
```

## Serve

```shell
roger serve [options]
```

Starts a webserver (port 9000 by default)


## Release

```shell
roger release [options]
```

Releases the project

## Test

```shell
roger test [options]
```

Tests the project


## Global options

All commands accept these options.

```
Options:
  -v, [--verbose]  # Set's verbose output
  -h, [--help]  # Help
```

## Custom options

All processors/middleware/etc. can use custom options. Roger will parse any leftover option that starts with `--` and sets it in the `project.options` hash. It even supports setting nested keys by using `:` as a separator. This means that `--release:rsync:disable=true` will become: `{release: { rsync: { disable: true}}}` in the options hash.

### Parsing
The commandline parser will work with flags in the following formats:

* `--key` will just set the flag to `true`
* `--key=value` and `--key value` will set the key `:key` to `"value"`
* `--key=true` and `--key=false` will convert to boolean `true` and `false`