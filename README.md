# elmish
### _Ruby Inspired by Elm_

Ruby lets you do the silliest of things.

This began solving a real problem – I needed a workflow which could handle several different branches, including retries.  And I wanted code that was easy to comprehend. (@jessitron sums up Ruby as easy to write and [hard to reason about](https://www.youtube.com/watch?v=jJ4e6cIBgYM). The solution was a long case statement method which took a `message` and a `state` and returned a new message and updated state.  This was inspired by [Elm's](http://elm-lang.org) update pattern.

```ruby

def run
  action, state = init

  loop do
     action, state = update(action, state)
     break if action == :exit
  end

  [action, state]
end

def update(msg, state)
  case msg
  when :start then
     state.download = fetch
     [:validate, state]
  when :validate then
     if waiting(state.download) 
        sleep 1.minute
        [:start, state]
     else
        [:write, state]
     end
```

What is nice is a process can be restarted at any point.  It is easy to see the general sequence of events. Like Elm's update adding a new action is not too difficult.

What I didn't like about this was using `symbols.`  What if constants could be used instead?  

Elmish was born.

```ruby

module Counter
  extend Elmish

  Actions %w|
    Noop
    Inc
    IncN/Fixnum  # this creates a union type that accepts Fixnums
    Dec
    DecN/Fixnum
  |

  def self.init
    [Noop, 0]
  end

  # msg is an Action
  # state is whatever state object you want
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
      raise "hell"
    end
  end
end

_, state = Counter.init
#=>  [Counter::Noop, 0]

_, state = Counter.update Workflow::Inc, state
#=>  [Counter::Noop, 1]

# Look a Union type with a value of 3
_, state = Counter.update (Workflow::IncN 3), state
#=>  [Counter::Noop, 4]

# runtime type checking is better than no type checking? Maybe? 
_, state = Counter.update (Workflow::IncN 'string?'), state
#=> Elmish::Union::TypeMismatch: [String, Fixnum]

```

This is terrible and unncessary. It probably creates more problems than it solves, but it was a fun excerise.

I'm not using this in production, but if I do, I will update this code with a gem or something.
