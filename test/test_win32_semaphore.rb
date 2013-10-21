################################################################
# test_win32_semaphore.rb
#
# Test suite for the win32-semaphore package. This test should
# be run via the 'rake test' task.
################################################################
require 'win32/semaphore'
require 'test-unit'
include Win32

class TC_Semaphore < Test::Unit::TestCase
  def setup
    @sem = Semaphore.new(1, 3, 'test')
  end

  test "version is set to expected value" do
    assert_equal('0.4.2', Semaphore::VERSION)
  end

  test "initial_count basic functionality" do
    assert_respond_to(@sem, :initial_count)
  end

  test "initial count is set to value passed to constructor" do
    assert_equal(1, @sem.initial_count)
  end

  test "max_count basic functionality" do
    assert_respond_to(@sem, :max_count)
  end

  test "max_count is set to value passed to constructor" do
    assert_equal(3, @sem.max_count)
  end

  test "name method basic functionality" do
    assert_respond_to(@sem, :name)
  end

  test "name returns value passed in constructor" do
    assert_equal('test', @sem.name)
  end

  test "default name is nil" do
    sem = Semaphore.new(0,1)
    assert_nil(sem.name)
    sem.close
  end

  test "inheritable? method is defined and true by default" do
    assert_respond_to(@sem, :inheritable?)
    assert_true(@sem.inheritable?)
  end

  test "inheritable? method returns value passed to constructor" do
    sem = Semaphore.new(0,1,nil,false)
    assert_false(sem.inheritable?)
    sem.close
  end

  test "release method basic functionality" do
    assert_respond_to(@sem, :release)
    assert_kind_of(Fixnum, @sem.release)
  end

  test "release accepts an optional amount" do
    assert_equal(1, @sem.release(1))
  end

  test "release returns the total number of releases" do
    assert_equal(1, @sem.release(1))
    assert_equal(2, @sem.release(1))
  end

  test "attempting to release more than the total count raises an error" do
    assert_raise(Errno::EINVAL){ @sem.release(99) }
  end

  test "release only accepts one argument" do
    assert_raise(ArgumentError){ @sem.release(1,2) }
  end

  test "open method basic functionality" do
    assert_respond_to(Semaphore, :open)
    assert_nothing_raised{ Semaphore.open('test'){} }
  end

  test "open method fails is semaphore name is invalid" do
    assert_raise(Errno::ENOENT){ Semaphore.open('bogus'){} }
  end

  test "wait method was inherited" do
    assert_respond_to(@sem, :wait)
  end

  test "wait_any method was inherited" do
    assert_respond_to(@sem, :wait_any)
  end

  test "wait_all method was inherited" do
    assert_respond_to(@sem, :wait_all)
  end

  test "first argument to constructor must be a number" do
    assert_raise(TypeError){ Semaphore.new('foo', 1){} }
  end

  test "second argument to constructor must be a number" do
    assert_raise(TypeError){ Semaphore.new(1, 'bar'){} }
  end

  test "constructor accepts a maximum of four arguments" do
    assert_raise(ArgumentError){ Semaphore.new(1, 2, 'test', true, 1){} }
  end

  test "ffi functions are private" do
    assert_not_respond_to(Semaphore, :CreateSemaphoreW)
    assert_not_respond_to(Semaphore, :OpenSemaphoreW)
    assert_not_respond_to(Semaphore, :ReleaseSemaphore)
  end

  def teardown
    @sem.close if @sem
    @sem = nil
  end
end
