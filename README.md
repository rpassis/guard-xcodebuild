# guard-xcodebuild

guard-xcodebuild automatically and selectively runs your tests when your Xcode files are modified

## Installation

Add this line to your application's Gemfile:

    gem 'guard-xcodebuild'

And then bundle it:

    $ bundle

Or install the gem:

    $ gem install guard-xcodebuild

## Dependency

- Ruby >2
- xcodebuild
- Guard 2.x

## How to Use

1) Make sure you have Xcode / xcodebuild installed

2) Create an `.xcodebuild-args` file in your project root passing the parameters relevant to your project. 
It's a simple JSON value where you can pass key value pairs. Here's an example:

```
{
  "workspace": "YourProject.xcworkspace",
  "scheme": "YourSchemeName",
  "configuration": "Debug",
  "sdk": "iphonesimulator",
  "destination": "'platform=iOS Simulator,name=iPhone 7 Plus'"
}
```

3) Configure your Guardfile

```ruby
directories %w(YourApp YourAppTests) \
.select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

guard 'xcodebuild' do
  watch(/(.*).(m|swift)/)
end
```

4) Run `bundle exec guard`

## Options

By default, xcodebuild tries to determine your target based on Xcode naming conventions
If necessary, you can specify your target by passing the ```test_target``` parameter in your
Guardfile.

```ruby
guard 'xcodebuild', :test_target => 'YourAppTests' do
  watch(...)
end
```

Xcodebuild will check for all files under the current folder for matching patterns. 
You can specify particular folder or array of folders, as test path.

```ruby
guard 'xcodebuild', :test_paths => 'YourAppTests' do
  watch(...)
end
```

```ruby
guard 'xcodebuild', :test_paths => ['YourAppUITests', 'YourAppTests'] do
  watch(...)
end
```

You can also pass any of the standard xcodebuild options using the ```:args``` option.
Note that this will be appended to any arguments specified in the .xcodebuild-args file
and that (currently) duplicates are not accepted

```ruby
guard 'xcodebuild', :args => 'CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO' do
  watch(...)
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request