require "./spec_helper"

describe Sam::Task do
  describe "#initialize" do
  end

  describe "#call" do
  end

  describe "#find!" do
    it "properly invokes task with same name as parent namespace" do
      task = Sam.find!("db:schema:load")
      task = task.find!("schema")
      task.path.should eq("db:schema")
    end
  end
end
