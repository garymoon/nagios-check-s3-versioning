#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'
require 'optparse'

EXIT_CODES = {
  :unknown => 3,
  :critical => 2,
  :warning => 1,
  :ok => 0
}

options =
{
  :debug => false
}

config = { :region => 'us-east-1' }

opt_parser = OptionParser.new do |opt|

  opt.on("-b", "--buckets bucket[,bucket]","which buckets do you wish to ?") do |buckets|
    options[:buckets] = buckets.split(',')
  end

  opt.on("-k","--key key","specify your AWS key ID") do |key|
    (config[:access_key_id] = key) unless key.empty?
  end

  opt.on("-s","--secret secret","specify your AWS secret") do |secret|
    (config[:secret_access_key] = secret) unless secret.empty?
  end

  opt.on("--debug","enable debug mode") do
    options[:debug] = true
  end

  opt.on("-h","--help","help") do
    puts opt_parser
    exit
  end
end

opt_parser.parse!

raise OptionParser::MissingArgument, 'Missing "--secret" or "--key"' if (options[:key] ^ !options[:secret])
raise OptionParser::MissingArgument, 'Missing "--bucket" or "-b"' if (!options[:buckets])

if (options[:debug])
  puts 'Options: '+options.inspect
  puts 'Config: '+config.inspect
end

bad_buckets = []

begin

  AWS.config(config)
  s3 = AWS::S3.new

  options[:buckets].each do |bucket|
    state = s3.buckets[bucket].versioning_state

    puts "#{bucket}: #{state}" if options[:debug]

    if (state != :enabled)
      bad_buckets << bucket
    end
  end

  if (bad_buckets.length > 0)
    puts "CRIT: Versioning isn't enabled on #{",".join(bad_buckets)}."
    exit EXIT_CODES[:critical]
  end

rescue SystemExit
  raise

rescue Exception => e
  puts 'CRIT: Unexpected error: ' + e.message + ' <' + e.backtrace[0] + '>'
  exit EXIT_CODES[:critical]

end

puts "OK: Versioning is enabled on all specified buckets."
exit EXIT_CODES[:ok]
