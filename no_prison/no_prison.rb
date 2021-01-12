#!/usr/bin/env ruby

#GEMS
require "ipaddress"

#MAIN CLASS
class Scopes

    #DEFINE VARIABLES
    @in_scope_file
    @out_scope_file
    @targets
    @bad_targets
    @final_targets

    def initialize(in_scope, out_scope)

        @in_scope_file = File.open(in_scope).readlines
        @out_scope_file = File.open(out_scope).readlines

        puts "The scope file contains:"
        puts @in_scope_file

        puts "\nThe following host ranges are out of scope:"
        puts @out_scope_file
        puts ""

        calculate_hosts

    end

    #CREATE IP RANGE FROM BOTH IN AND OUT SCOPE FILES
    def calculate_hosts

        @targets = []
        @bad_targets = []

        @in_scope_file.each do |line|
            ips = IPAddress "#{line}"

            ips.each do |host|
                @targets.push(host)
            end
        end

        @out_scope_file.each do |line|
            ips = IPAddress "#{line}"

            ips.each do |host|
                @bad_targets.push(host)
            end
        end

    end

    def remove_hosts

        @final_targets = []

        @targets.zip(@bad_targets).each do |x, y|

            if y.to_s.include? x.to_s
                #DO NOTHING
            else
                @final_targets.push(x)
            end

        end
 
    end
    
    def write_to_file

        File.open("final_targets.txt", "w+") do |ip|
            ip.puts(@final_targets)
        end
    
    end
end

#USER INPUT VARIABLES
scope_file = ARGV[0]
out_of_scope_file = ARGV[1]

#CHECKING BOTH ARGS WERE PROVIDED
if scope_file.nil? || out_of_scope_file.nil?
    puts "Please specify a file."
    puts "Example: ruby no_prison.rb inscope.txt outscope.txt"
else
    run_script = Scopes.new(scope_file, out_of_scope_file)
    run_script.remove_hosts
    run_script.write_to_file

    puts "Created 'final_targets.txt' in this working directory."
end