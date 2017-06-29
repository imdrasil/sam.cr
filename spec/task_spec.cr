require "./spec_helper"

describe Sam::Task do
  namespace = Sam::Namespace.new("n", nil)

  describe "#find!" do
    it "properly invokes task with same name as parent namespace" do
      task = Sam.find!("db:schema:load")
      task = task.find!("schema")
      task.path.should eq("db:schema")
    end
  end

  describe "#path" do
    it "adds own name to namespace path" do
      Sam.find!("db:schema:load").path.should eq("db:schema:load")
    end
  end

  describe "#description" do
    it "returns empty string if has no description" do
      t = namespace.task("t") { }
      t.description.should eq("")
    end
  end

  describe "#call" do
    context "dependencies" do
      it "invokes all dependencies before call" do
        arr = [] of Int32
        namespace.task("t1") { arr << 1 }
        namespace.task("t2") { arr << 2 }
        t = namespace.task("t3", ["t2", "t1"]) { arr << 3 }
        t.call(Sam::Args.new)
        arr.should eq([2, 1, 3])
      end

      it "raises exception and not invokes if dependency raise exception" do
        arr = [] of Int32
        namespace.task("t2") { 1 / 0 }
        t = namespace.task("t3", ["t2", "t1"]) { arr << 3 }
        expect_raises do
          t.call(Sam::Args.new)
        end
        arr.empty?.should eq(true)
      end
    end

    context "no arguments" do
      it "invokes without arguments" do
        t = namespace.task("t") { }
        t.call(Sam::Args.new)
      end
    end

    context "with 1 argument" do
      it "invokes with task" do
        count = 0
        t = namespace.task("t") do |task|
          count += 1
          task.is_a?(Sam::Task).should eq(true)
        end
        t.call(Sam::Args.new)
        count.should eq(1)
      end
    end

    context "with 2 arguments" do
      it "invokes with rask and arguments" do
        count = 0
        t = namespace.task("t") do |task, args|
          count += 1
          task.is_a?(Sam::Task).should eq(true)
          args.is_a?(Sam::Args).should eq(true)
        end
        t.call(Sam::Args.new)
        count.should eq(1)
      end
    end
  end

  describe "#invoke" do
    it "accepts no arguments" do
      count = 0
      namespace.task("t1") { count += 1 }
      namespace.task("t2") { |t| t.invoke("t1") }.call(Sam::Args.new)
      count.should eq(1)
    end

    it "accepts tuple at the end" do
      count = 0
      namespace.task("t1") { |t, args| count += args[0].as(Int32) }
      namespace.task("t2") { |t| t.invoke("t1", 1) }.call(Sam::Args.new)
      count.should eq(1)
    end

    it "accepts hash" do
      count = 0
      namespace.task("t1") { |t, args| count += args["count"].as(Int32) }
      namespace.task("t2") { |t| t.invoke("t1", {"count" => 2}) }.call(Sam::Args.new)
      count.should eq(2)
    end

    it "accepts arg object" do
      count = 0
      namespace.task("t1") { |t, args| count += args["count"].as(Int32) }
      namespace.task("t2") { |t, args| t.invoke("t1", args) }.call(Sam::Args.new({"count" => 2}))
      count.should eq(2)
    end

    it "accepts hash and array" do
      count = 0
      namespace.task("t1") { |t, args| count += args["count"].as(Int32) + args[0].as(Int32) }
      namespace.task("t2") { |t| t.invoke("t1", {"count" => 2}, [1]) }.call(Sam::Args.new)
      count.should eq(3)
    end
  end
end
