require './elmish'

module Counter
  extend Elmish

  Actions %w|
    Noop
    Inc
    IncN/Fixnum
    Dec
    DecN/Fixnum
  |

  def self.init
    [Inc, 0]
  end

  def self.update(msg, state)
    case msg
    when Inc then
      [Noop, state + 1]
    when IncN then
      [Noop, state + msg.value]
    when Dec then
      [Noop, state - 1]
    when DecN then
      [Noop, state - msg.value]
    else
      raise 'hell'
    end
  end
end

def log(action, state)
  return_action, new_state = Counter.update action, state
  puts "#{action} #{state} -> #{new_state}"
  [return_action, new_state]
end

_, state = Counter.init
_, state = log(Counter::Inc, state)
_, state = log(Counter::IncN(3), state)
_, state = log(Counter::DecN(2), state)
_, state = log(Counter::Dec, state)
_, state = log(Counter::DecN('wrong!'), state)
