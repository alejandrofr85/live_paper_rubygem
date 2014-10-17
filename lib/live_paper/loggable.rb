module LivePaper
  class Loggable
    attr_accessor :logs
    @@already_defined = []
    def initialize
      @logs = []
      register_loggables(to_log) unless @@already_defined.include? self.class.name.to_sym
    end

    def to_log
      []
    end

    def register_loggables(names)
      @@already_defined << self.class.name.to_sym
      names.each do |name|
        m = self.class.instance_method(name)

        self.class.send(:define_method, name) do |*args, &block|
          output = m.bind(self).(*args, &block)
          @logs << {
            method: name,
            input: args,
            output: output
          }
          output
        end
      end
    end

  end

end