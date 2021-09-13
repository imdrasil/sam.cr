# Sam [![Build Status](https://travis-ci.org/imdrasil/sam.cr.svg)](https://travis-ci.org/imdrasil/sam.cr) [![Latest Release](https://img.shields.io/github/release/imdrasil/sam.cr.svg)](https://github.com/imdrasil/sam.cr/releases)

Sam is a Make-like utility which allows to specify tasks like Ruby's Rake do using plain Crystal code. This allows you to reuse existing application code base and/or include tasks from your dependencies.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  sam:
    github: imdrasil/sam.cr
    version: 0.4.2
```

After executing `shards install` Sam-file will be added to the root of your project (unless you already have one).

## Usage

### Task

Tasks are the main unit in `sam.cr`. Task has a name, a list of prerequisites and a list of actions (block of a code).

Sam extends the global context with own DSL. To define a task use `task` method which accepts the task name as the 1st argument.

```crystal
task "name" do
end
```

If you want to define prerequisites, add the array with their names as the 2nd argument:

```crystal
task "name", ["prereq1", "prereq2"] do
end
```

#### Executing a task

Sam does no magic with your `sam.cr` file - it is just a common `.cr` source file which allows you to recompile it with any possible code you want such amount of times you need. Therefore the most obvious way to execute any task is:

```shell
$ crystal sam.cr name
```

In addition to this you are able to configure your makefile to invoke sam tasks. This allows you to use shorten variant

```shell
$ make sam name
```

To automatically modify your Makefile run

```shell
$ crystal sam.cr generate:makefile
```

This will modify existing Makefile or create new one. Be careful - this will silent all nonexisting makefile tasks on invocation.

To see a list of all available tasks with their descriptions:

```shell
$ crystal sam.cr help
```

#### Tasks with arguments

To pass arguments to your task just list them after it's name:

```shell
$ crystal sam.cr name john rob ned
```

They are passed to a task as a 2nd block argument.

```crystal
task "name" do |_, args|
  puts args[0].as(String)
end
```

`args` here is an instance of `Sam::Args` class that contains arguments and named arguments passed to each task. Any argument passed from a console is treated as a `String` but `Int32` and `Float64` values also can be specified during task invocation from inside of another one.

> Each task has own collection of arguments; only prerequisites shares with target task same `Args` instance.

Named argument also can be specified by the following ways:

- `-argument value`
- `-argument "value with spaces"`
- `argument=value`
- `argument="value with spaces"`

Two important restriction with named arguments usage and makefile-style task invocation:

* `--` should be placed to explicitly specify that specified named arguments belongs to task not to Makefile:

```shell
$ make sam name john
$ # but
$ make same name -- argument=john
```

* makefile doesn't support named arguments with `=` sign

To invoke More than one task list them one by one (including their arguments) separating them with `@` symbol:

```shell
$ crystal sam.cr name john @ surname argument=snow
```

#### Accessing tasks programmatically

Sam allow you to invoke tasks within another ones and even passing own args object. To do this just call `#invoke` method with task name (and arguments if needed) on task object passed as 1st argument:

```crystal
task "name" do |t|
  t.invoke("surname")
end

task "surname" do
  puts "Snow"
end
```

If specified task was already invoked before - it will be ignored. To force task invocation - use `#execute`.


Another task could be invoked from current using `invoke` method. It has next signatures:

### Namespaces

as projects grow amount of defined tasks grow as well. To simplify navigation and increase readability tasks can be grouped in namespaces:

```crystal
namespace "main" do
  task "build" do
    # Build the main program
  end
end

namespace "samples" do
  task "build" do
    # Build the sample programs
  end
end

task "build", %w[main:build samples:build] do
end
```

#### Name resolution

When task is invoked from other one, provided path will float up through current task namespace and search given task path on each level until top level. Task could have same name as any existing namespace.

```crystal
task "one" do
end

namespace "one" do
  namespace "two"
    task "test" do |t|
      t.invoke("one")
    end
  end
end
```

In the example above next paths are checked (in given order):

* `one:two:one`
* `one:one`
* `one` (as task not namespace)

### Share tasks

Sam tasks can be loaded from installed dependencies. To do this helper macro `load_dependencies` can be used:

```crystal
load_dependencies "lib1", "lib2"
```

This is translated to

```crystal
require "./lib/lib1/tasks/sam.cr"
```

## Development

Before running tests call

```shell
$ crystal examples/sam.cr setup
```

## Contributing

1. [Fork it]( https://github.com/imdrasil/sam.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [imdrasil](https://github.com/imdrasil/sam.cr) Roman Kalnytskyi - creator, maintainer
