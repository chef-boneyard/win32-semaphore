require 'win32/ipc'

# The Win32 module serves as a namespace only.
module Win32

  # The Semaphore class encapsulates semaphore objects on Windows.
  class Semaphore < Ipc
    typedef :ulong, :dword
    typedef :uintptr_t, :handle

    ffi_lib :kernel32

    private

    class SecurityAttributes < FFI::Struct
      layout(
        :nLength, :dword,
        :lpSecurityDescriptor, :pointer,
        :bInheritHandle, :bool
      )
    end

    attach_function :CreateSemaphoreW, [:pointer, :long, :long, :buffer_in], :handle
    attach_function :OpenSemaphoreW, [:dword, :bool, :buffer_in], :handle
    attach_function :ReleaseSemaphore, [:handle, :long, :pointer], :bool

    private_class_method :CreateSemaphoreW, :OpenSemaphoreW, :ReleaseSemaphore

    SEMAPHORE_ALL_ACCESS = 0x1F0003
    INVALID_HANDLE_VALUE = 0xFFFFFFFF

    public

    # The version of the win32-semaphore library
    VERSION = '0.4.1'

    # The initial count for the semaphore object. This value must be greater
    # than or equal to zero and less than or equal to +max_count+. The state
    # of a semaphore is signaled when its count is greater than zero and
    # nonsignaled when it is zero. The count is decreased by one whenever
    # a wait function releases a thread that was waiting for the semaphore.
    # The count is increased by a specified amount by calling
    # Semaphore#release method.
    #
    attr_reader :initial_count

    # The maximum count for the semaphore object. This value must be
    # greater than zero.
    #
    attr_reader :max_count

    # The name of the Semaphore object.
    #
    attr_reader :name

    # Creates and returns new Semaphore object. If +name+ is omitted, the
    # Semaphore object is created without a name, i.e. it's anonymous.
    #
    # If +name+ is provided and it already exists, then it is opened
    # instead, and the +initial_count+ and +max_count+ parameters are
    # ignored.
    #
    # The +initial_count+ and +max_count+ parameters set the initial count
    # and maximum count for the Semaphore object, respectively. See the
    # documentation for the corresponding accessor for more information.
    #
    # The +inherit+ attribute determines whether or not the semaphore can
    # be inherited by child processes.
    #
    def initialize(initial_count, max_count, name=nil, inherit=true)
      @initial_count = initial_count
      @max_count = max_count
      @name      = name
      @inherit   = inherit

      if name && name.encoding.to_s != 'UTF-16LE'
        name = name + 0.chr
        name.encode!('UTF-16LE')
      end

      if inherit
        sec = SecurityAttributes.new
        sec[:nLength] = SecurityAttributes.size
        sec[:bInheritHandle] = true
      else
        sec = nil
      end

      handle = CreateSemaphoreW(sec, initial_count, max_count, name)

      if handle == 0 || handle == INVALID_HANDLE_VALUE
        raise SystemCallError.new("CreateSemaphore", FFI.errno)
      end

      super(handle)

      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    # Open an existing Semaphore by +name+. The +inherit+ argument sets
    # whether or not the object was opened such that a process created by the
    # CreateProcess() function (a Windows API function) can inherit the
    # handle. The default is true.
    #
    # This method is essentially identical to Semaphore.new, except that the
    # options for +initial_count+ and +max_count+ cannot be set (since they
    # are already set). Also, this method will raise a Semaphore::Error if
    # the semaphore doesn't already exist.
    #
    # If you want "open or create" semantics, then use Semaphore.new.
    #
    def self.open(name, inherit=true, &block)
      if name && name.encoding.to_s != 'UTF-16LE'
        name = name + 0.chr
        name.encode!('UTF-16LE')
      end

      begin
        # The OpenSemaphore() call here is strictly to force an error if the
        # user tries to open a semaphore that doesn't already exist.
        handle = OpenSemaphoreW(SEMAPHORE_ALL_ACCESS, inherit, name)

        if handle == 0 || handle == INVALID_HANDLE_VALUE
          raise SystemCallError.new("OpenSemaphore", FFI.errno)
        end
      ensure
        CloseHandle(handle)
      end

      self.new(0, 1, name, inherit, &block)
    end

    # Increases the count of the specified semaphore object by +amount+.
    # The default is 1. Returns the previous count of the semaphore if
    # successful. If the +amount+ exceeds the +max_count+ specified when
    # the semaphore was created then an error is raised.
    #
    def release(amount = 1)
      pcount = FFI::MemoryPointer.new(:long)

      # Ruby doesn't translate error 298, so we treat it as an EINVAL
      unless ReleaseSemaphore(@handle, amount, pcount)
        errno = FFI.errno
        errno = 22 if errno == 298 # 22 is EINVAL
        raise SystemCallError.new("ReleaseSemaphore", errno)
      end

      pcount.read_long
    end

    # Returns whether or not the object was opened such that a process
    # created by the CreateProcess() function (a Windows API function) can
    # inherit the handle. The default is true.
    #
    def inheritable?
      @inherit
    end
  end
end
