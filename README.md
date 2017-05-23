# Sam [![Build Status](https://travis-ci.org/imdrasil/sam.cr.svg)](https://travis-ci.org/imdrasil/sam.cr)

Sam is a Make-like shard which allows to specify tasks like Ruby's Rake do using plain Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  sam:
    github: imdrasil/sam.cr
```

## Usage

### Simple example

Create `sam.cr` file in your app root directory and paste next: 
```crystal
# here you should load your app configuration if 
# it will be needed to perform tasks
Sam.namespace "db" do
  namespace "schema" do
    desc "Outputs smth: requrie 2 named arguments"
    task "load" do |t, args|
      puts args["f1"]
      t.invoke("1")
      t.invoke("schema:1")
      t.invoke("db:migrate")
      t.invoke("db:db:migrate")
      t.invoke("db:ping")
      t.invoke("din:dong")
      puts "------"
      t.invoke("2", {"f2" => 1})
    end

    task "1" do
      puts "1"
    end

    task "2", ["1", "db:migrate"] do |t, args|
      puts args.named["f2"].as(Int32) + 3
    end
  end

  namespace "db" do
    task "migrate" do
      puts "migrate"
    end
  end

  task "ping" do
    puts "ping"
  end
end
Sam.help
```

To ran any of this task open prompt in root location and paste:

```shell
$ crystal sam.cr -- <your_task_path> [options]
```

To get list of all available tasks:

```shell
$ crystal sam.cr -- help
```

Each tasks has own "path" which consists of namespace names and task name joined together by ":". 

Also tasks can accept space separated arguments from prompt. To pass named argument (which have associated name) use next rules:

- `-name value`
- `-name "value with spaces"`
- `name=value`
- `name="value with spaces"`

Also just array of arguments can be passed - just past everything needed without any flags anywhere:
```shell
$ crystal sam.cr -- <your_task_path> first_raw_option "options with spaces"
```

All arguments from prompt will be parsed as `String`.

So to invoke first task from example ("load") will be used next command:

```shell
crystal sam.cr -- db:schema:load -f1 asd
```

To autoload Sam files from your dependencies - just past 
```crystal
load_dependencies "dep1", "dep2"`
```

#### Namespace

To define namespace (for now they only used for namespacing tasks) use `Sam.namespace` (opens `root` namespace) or just `namespace` inside of it. `Sam.namespace` can be called any times - everything will be added to existing staff.

#### Task
To define task use `task` method with it's name and block. Given block could take 0..2 arguments: `Task` object and `Args` object. Also as second parameter could be provided array of dependent tasks which will be invoked before current.

Another task could be invoked from current using `invoke` method. It has next signatures:

- 
  - `name : String` - task path 

- 
  - `name : String` - task path
  - `args : Args` - prepared argument object

- 
  - `name : String` - task path
  - `hash : Hash(String, String | Int32, Float32)` - hash with arguments

- 
  - `name : String` - task path
  - `args : Tuple` - raw arguments

#### Routing

When task is invoked from other one provided path will float up through current task namespace nesting and search given path on each level.

#### Args
 
 This class represents argument set for task. It can handle named arguments and just raw array of arguments. Now it supports only `String`, `Int32` and `Float32` types. To get access to named argument you can use `[](name : String)` and `[]?(name : String)` methods. For raw attributes there are `[](index : Int32)` and `[]?(index : Int32)` as well.

## Development

For now major functionality is ready but too few tests were added. So major task for next release will be increasing test coverage.

Before running tests call
```shell
$ crystal examples/sam.cr -- prepare
```

## Contributing

1. [Fork it]( https://github.com/imdrasil/sam.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [imdrasil](https://github.com/[your-github-name]) Roman Kalnytskyi - creator, maintainer
