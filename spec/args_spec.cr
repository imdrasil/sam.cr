require "./spec_helper"

describe Sam::Args do
  describe "#initialize" do
    context "without arguments" do
      it "properly create object" do
        args = Sam::Args.new
        args.raw.empty?.should eq(true)
        args.named.empty?.should eq(true)
      end
    end

    context "with array of string from prompt" do
      it "properly parse named argument aka '-name value'" do
        Sam::Args.new(["-name", "type"])["name"].should eq("type")
      end

      it "properly parse named argument aka '-name value'" do
        Sam::Args.new(["name=type"])["name"].should eq("type")
      end

      it "properly parse raw arguments" do
        Sam::Args.new(["name", "type"])[0].should eq("name")
      end

      it "properly parses mix of arguments" do
        args = Sam::Args.new(["name", "arg1=1", "type"])
        args[1].should eq("type")
        args["arg1"].should eq("1")
      end
    end

    context "with providing named and raw arguments" do
      it "properly creates object" do
        args = Sam::Args.new({"count" => "1"}, [1])
        args[0].should eq(1)
        args["count"].should eq("1")
      end
    end
  end

  describe "#raw" do
    it "returns array of raw args" do
      args = Sam::Args.new({} of String => String, [1])
      args.raw.should eq([1])
    end
  end

  describe "#named_arguments" do
  end

  describe "#size" do
    it "returns overall arguments acount" do
      Sam::Args.new({"a" => "b"}, [2]).size.should eq(2)
    end
  end

  describe "#[]" do
    args = Sam::Args.new({"a" => "b"}, [1])
    context "with integer" do
      it "returns raw argument" do
        args[0].should eq(1)
      end
    end

    context "with symbol" do
      it "converts it to string and returns named argument" do
        args[:a].should eq("b")
      end
    end

    context "with string" do
      it "returns named argument" do
        args["a"].should eq("b")
      end
    end
  end

  describe "#[]?" do
  end
end
