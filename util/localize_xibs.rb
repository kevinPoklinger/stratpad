#!/usr/bin/ruby
# MIT license
 
# localize_xibs.rb
# This script takes a set of localized strings and creates/clobbers existing localized XIBs
# using the current English.lproj XIBs.

# can do create a single xib like this: 
# ibtool --strings-file [path/to/strings] --write [path/to/target/xib] [path/to/source/xib]
# ibtool --strings-file "es.lproj/AboutYourStrategyView.strings" --write "es.lproj/AboutYourStrategyView.xib" "en.lproj/AboutYourStrategyView.xib"
# or if you are updating a xib (n.b. final args dir changes):
# ibtool --strings-file "es.lproj/ChartMaxValueViewController.strings" --write "es.lproj/ChartMaxValueViewController.xib" "es.lproj/ChartMaxValueViewController.xib"
require 'FileUtils'
 
# Check for arguments.
if ARGV.length != 2
  puts "Usage: ruby localize_xibs.rb path_to_source_xibs path_to_strings"
  # eg. cd src/xcode/main/StratPad; ruby ../../util/localize_xibs.rb en.lproj es.lproj
  exit
end
 
# Get path arguments and 'cd' to that project path.
SOURCE_XIB_FOLDER = ARGV[0]
STRINGS_PATH = ARGV[1]
FILES_TO_IGNORE = [".svn", "." ,"..", ".DS_Store", "Localizable.strings"]

# Go through files in es.lproj and grab .strings and corresponding .xibs
# Go through files in en.lproj and grab corresponding .xibs
# run the command
 
# Iterate through the current directory.
# Iterate over the .strings language folders.
Dir.entries(STRINGS_PATH).each do |strings_file|
  
  if (!FILES_TO_IGNORE.include?(strings_file))
    ext = File.extname(strings_file)
	if (ext == ".strings")
		filename = strings_file.slice(0,strings_file.length-8)
		source_xib = SOURCE_XIB_FOLDER + "/" + filename
		strings_path = STRINGS_PATH + "/" + strings_file
	
		# Each .strings file needs to create/clobber a localized XIB in that .lproj folder.
		command = "ibtool --strings-file \"#{strings_path}\" --write \"#{STRINGS_PATH}/#{filename}.xib\" \"#{source_xib}.xib\""
	
		results = %x[#{command}]
		if results.length > 0
		  puts "FAILURE: #{command}:\n#{results}"
		else
		  puts "SUCCESS: #{STRINGS_PATH}/#{filename}.xib"
		end
	
	end
	
  end
  
end
