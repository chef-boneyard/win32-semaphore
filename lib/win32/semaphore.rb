require 'win32/ipc'

# The Win32 module serves as a namespace only.
module Win32

   # The Semaphore class encapsulates semaphore objects on Windows.
   class Semaphore < Ipc
   
      # This is the error raised if any of the Semaphore methods fail.
      class Error < StandardError; end
   
      extend Windows::Synchronize
      extend Windows::Error
      extend Windows::Handle
      
      # The version of the win32-semaphore library
      VERSION = '0.3.1'
      
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
         
         # Used to prevent potential segfaults.
         if name && !name.is_a?(String)
            raise TypeError, 'name must be a string'
         end
         
         if inherit
            sec = 0.chr * 12 # sizeof(SECURITY_ATTRIBUTES)
            sec[0,4] = [12].pack('L')
            sec[8,4] = [1].pack('L') # 1 == TRUE
         else
            sec = 0
         end
         
         handle = CreateSemaphore(sec, initial_count, max_count, name)
         
         if handle == 0 || handle == INVALID_HANDLE_VALUE
            raise Error, get_last_error
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
         if name && !name.is_a?(String)
            raise TypeError, 'name must be a string'
         end

         bool = inherit ? 1 : 0

         # The OpenSemaphore() call here is strictly to force an error if the
         # user tries to open a semaphore that doesn't already exist.
         begin
            handle = OpenSemaphore(SEMAPHORE_ALL_ACCESS, bool, name)

            if handle == 0 || handle == INVALID_HANDLE_VALUE
               raise Error, get_last_error
            end
         ensure
            CloseHandle(handle)
         end

         self.new(0, 1, name, inherit, &block)
      end

      # Increases the count of the specified semaphore object by +amount+.
      # The default is 1. Returns the previous count of the semaphore if
      # successful. If the +amount+ exceeds the +max_count+ specified when
      # the semaphore was created then a Semaphore::Error is raised.
      #
      def release(amount = 1)
         pcount = [0].pack('L')

         unless ReleaseSemaphore(@handle, amount, pcount)
            raise Error, get_last_error   
         end

         pcount.unpack('L').first
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
