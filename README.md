nagios-check-s3-versioning
==========================

A Nagios check for monitoring the status of s3 bucket versioning

    Usage: check_aws_s3_versioning [options]
        -b, --buckets bucket[,bucket]    which buckets do you wish to ?
        -k, --key key                    specify your AWS key ID
        -s, --secret secret              specify your AWS secret
            --debug                      enable debug mode
        -h, --help                       help

Configuration
-------------
    define command{
      command_name  check_aws_s3_versioning
      command_line  $USER1$/check_aws_s3_versioning.rb --buckets '$ARG1$' --key '$ARG2$' --secret '$ARG3$'
      }
        
    define service{
      use                             generic-service 
      host_name                       aws
      service_description             S3 Versioning
      check_command                   check_aws_s3_versioning!bucket1,bucket2!<%= @aws_nagios_key %>!<%= @aws_nagios_secret %>!
      check_interval                  5
    }

Notes:
* Since versioning can't be disabled, only suspended, you may want to disable notifications on this check if you're not paranoid.