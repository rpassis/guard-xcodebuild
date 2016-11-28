require "spec_helper"

describe Guard::XcodebuildUtil do  

  let(:xcbutil) { Class.new { include Guard::XcodebuildUtil }.new }

  describe "#test_classes_with_paths" do    
    context "with paths ending in (Test|Spec).(swift|m)" do
      it "returns inferred test classes" do
        paths = Factory.matching_paths        
        results = xcbutil.test_classes_with_paths(paths)
        expect(results.count).to eq(3)
      end
    end

    context "with non-matching paths" do
      it "returns no inferred test classes" do
        paths = Factory.non_matching_paths
        results = xcbutil.test_classes_with_paths(paths)
        expect(results.count).to eq(0)
      end
    end

    context "with duplicate paths" do
      it "returns a single copy of the duplicated inferred class" do
        paths = Factory.duplicate_paths
        results = xcbutil.test_classes_with_paths(paths)
        expect(results.count).to eq(1)
      end
    end
  end

  describe "#find_test_from_target_names" do
    it "infers a test target name from a list of targets" do
      names = ["TargetTests", "TargetSpecs", "Target", "AnotherTarget"]
      result = xcbutil.find_test_from_target_names(names)
      expect(result).to equal(names.first)
    end
    
    it "returns nil when it is unable to infer a test target" do
      names = ["TargetRandom", "AnotherRandomTargetName", "Target", "AnotherTarget"]
      result = xcbutil.find_test_from_target_names(names)
      expect(result).to be(nil)
    end

    # it "returns the target names of project in current folder"
  end

  describe "#load_args" do
    let(:json_string) {
      hash = {}
      hash[:key1] = "value1"
      hash[:key2] = "value2"
      hash[:key3] = 1
      hash.to_json
    }

    it "loads key value pairs from a valid JSON file and transforms them into arguments" do
      args = xcbutil.load_args(json_string)
      expect(args).to eq("-key1 value1 -key2 value2 -key3 1")
    end

    it "return nil for invalid json" do
      json_string = "aasdsdadadasd"
      args = xcbutil.load_args(json_string)
      expect(args).to be(nil)
    end
  end



end
