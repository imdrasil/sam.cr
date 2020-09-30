require "./spec_helper"

describe Sam do
  describe "::namespace" do
    pending "add" do
    end
  end

  describe "::task" do
    pending "add" do
    end
  end

  describe "::invoke" do
    it "raises error if given task is not exists" do
      expect_raises(Exception, "Task giberrish was not found") do
        Sam.invoke("giberrish")
      end
    end
  end

  describe "::find" do
    it "finds correct task by path" do
      Sam.find!("db:schema:load").name.should eq("load")
    end
  end

  describe "::help" do
    pending "add" do
    end
  end

  describe "::process_tasks" do
    context "one task" do
      it "executes given task" do
        Sam.process_tasks(["db:schema"])
        Container.tasks.should eq(["db:schema"])
      end
    end

    context "multiple tasks" do
      context "without arguments" do
        it "executes all of them" do
          Sam.process_tasks(["db:schema", "@", "db:ping"])
          Container.tasks.should eq(["db:schema", "db:ping"])
        end
      end

      context "with arguments" do
        it "executes them and pass arguments" do
          Sam.process_tasks(["db:schema", "1", "@", "db:with_argument", "f1=2"])
          Container.tasks.should eq(["db:schema", "db:with_argument"])
        end
      end
    end
  end

  describe "%load_dependencies" do
    context "given as splat array" do
      it "properly loads tasks from dependencies" do
        Sam.find!("din:dong")
      end
    end

    context "given as names tuple" do
      context "with single dependecy passed as string" do
        it "properly loads and executes task" do
          Sam.invoke("lib2:special")
          Container.tasks.should eq(["lib2:special"])
        end
      end

      context "with several dependencies" do
        context "with leading /" do
          it "properly loads nested task" do
            Sam.invoke("lib3:special")
            Container.tasks.should eq(["lib3:special"])
          end
        end
      end
    end
  end

  it "includes all default tasks" do
    Sam.find!("help")
    Sam.find!("generate:makefile")
  end
end
