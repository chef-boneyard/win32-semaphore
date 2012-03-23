################################################################
# test_semaphore.rb
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

  def test_version
    assert_equal('0.3.2', Semaphore::VERSION)
  end

  def test_open
    assert_respond_to(Semaphore, :open)
    assert_nothing_raised{ Semaphore.open('test'){} }
    assert_raises(Semaphore::Error){ Semaphore.open('bogus'){} }
  end

  def test_inheritable
    assert_respond_to(@sem, :inheritable?)
    assert_equal(true, @sem.inheritable?)
  end

  def test_release
    assert_respond_to(@sem, :release)
    assert_equal(1, @sem.release(1))
    assert_equal(2, @sem.release(1))
    assert_raises(Semaphore::Error){ @sem.release(99) }
  end

  def test_wait
    assert_respond_to(@sem, :wait)
  end

  def test_wait_any
    assert_respond_to(@sem, :wait_any)
  end

  def test_wait_all
    assert_respond_to(@sem, :wait_all)
  end

  def test_valid_constructor
    assert_nothing_raised{ Semaphore.new(0, 1){} }
    assert_nothing_raised{ Semaphore.new(0, 1, "foo"){} }
    assert_nothing_raised{ Semaphore.new(0, 1, "foo", false){} }
  end

  def test_invalid_constructor
    assert_raises(TypeError){ Semaphore.new("foo", "bar"){} }
    assert_raises(ArgumentError){ Semaphore.new(1, 1, "test", 1, 1){} }
  end

  def teardown
    @sem.close
    @sem = nil
  end
end
