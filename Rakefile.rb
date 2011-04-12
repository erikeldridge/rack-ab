# Rakefile for Rack::AB.  -*-ruby-*-
require 'rake/rdoctask'
require 'rake/testtask'

desc "Run specs with specdoc style output"
task :spec do
  sh "specrb -Ilib:test -s -w #{ENV['TEST'] || '-a'} #{ENV['TESTOPTS']}"
end