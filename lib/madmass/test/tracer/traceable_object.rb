# This class is used to test traceability on simple ruby objects.
class TraceableObject
  # you can also skip attr1 and attr2 accessor definition, the tracer will do it for you
  attr_accessor :attr1, :attr2, :attr3
  trace :attr1, :attr2
end
