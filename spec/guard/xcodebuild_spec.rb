require "spec_helper"

describe Guard::Xcodebuild do
  it "has a version number" do
    expect(Guard::XcodebuildVersion::VERSION).not_to be nil
  end
end
