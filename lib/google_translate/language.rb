class Language
  attr_reader :name, :code

  def initialize name, code
    @name = name
    @code = code
  end

  def to_s
    "(" + code + ": " + name + ")"
  end

end