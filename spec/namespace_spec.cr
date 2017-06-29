require "./spec_helper"

describe Sam::Namespace do
  describe "#initialize" do
  end

  describe "#namespace" do
  end

  describe "#touch_namespace" do
  end

  describe "#task" do
  end

  describe "#namespaces" do
  end

  describe "#tasks" do
  end

  describe "#find" do
    root = Sam::Namespace.new("root", nil)
    n1 = root.namespace("n1") { }
    n2 = n1.namespace("n2") { }
    t1 = n1.task("t1") { }
    t2 = n2.task("t2") { }

    context "given task name only" do
      it "returns task if in current namespece" do
        n2.find("t2").should eq(t2)
      end

      it "returns task if in parent context" do
        n2.find("t1").should eq(t1)
      end

      it "returns nil if no such task" do
        n2.find("t3").should eq(nil)
      end
    end

    context "given path" do
      it "returns task if has namespace like first part of path" do
        n1.find("n2:t2").should eq(t2)
      end

      it "returns task if parent has given path" do
        n2.find("n2:t2").should eq(t2)
      end

      it "returns task if root namespace has given path" do
        n2.find("n1:n2:t2").should eq(t2)
      end

      it "returns nil if no such path" do
        n2.find("n1:n2:asd").should eq(nil)
      end
    end

    it "raises exception if path is blank" do
      expect_raises(ArgumentError) do
        n2.find("")
      end
    end
  end

  describe "#all_tasks" do
    it "returns all tasks" do
      n1 = Sam::Namespace.new("n1", nil)
      n2 = n1.namespace("n2") { }
      t1 = n1.task("t1") { }
      t2 = n2.task("t2") { }
      n1.all_tasks.should eq([t1, t2])
      n2.all_tasks.should eq([t2])
    end
  end

  describe "#path" do
    it "properly calculates path" do
      n1 = Sam::Namespace.new("n1", nil)
      n2 = Sam::Namespace.new("n2", n1)
      n1.path.should eq("")
      n2.path.should eq("n2:")
    end
  end
end
