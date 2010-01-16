##############################################################
# example_semaphore.rb
#
# A test script for general futzing.  Modify as you see fit.
#
# Note that you can run this via the 'rake example' task.
##############################################################
require "win32/semaphore"
include Win32

test = 1
s = Semaphore.new(3,3,"test")
test += 1
puts "ok #{test}"

print 'not ' unless s.wait(10) > 0
test += 1
puts "ok #{test}"

print 'not ' unless s.wait(0) > 0
test += 1
puts "ok #{test}"

printf "If you don't see 'ok %d' immediately, you'd better hit Ctrl-C\n", test+1
print 'not ' unless s.wait > 0
test += 1
puts "ok #{test}"

print 'not ' if s.wait(0) > 0
test += 1
puts "ok #{test}"

s.release
s.release(1)

print 'not ' unless (result = s.release(1)) == 2
test += 1
puts "ok #{test}\t(result is #{result})"

s.close