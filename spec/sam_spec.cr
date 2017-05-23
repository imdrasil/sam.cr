require "./spec_helper"

describe Sam do
  describe "::namespace" do
  end

  describe "::task" do
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
  end
end
