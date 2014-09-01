class ResultParser

  attr_reader :result

  def initialize result
    @result = result
  end

  def translation
    result[0][0][0]
  end

  def translit
    result[0][1][2]
  end

  def nouns
    list = []

    if result[1].size > 1
      if result[1][0]
        list = result[1][0][1]
      end
    end

    list
  end

  def verbs
    list = []

    if result[1].size > 1
      if result[1][1]
        list = result[1][1][1]
      end
    end

    list
  end

  def synonym_nouns
    list = []

    if result[11].size > 1
      if result[1][0]
        result[11][0][1].each do |r, _|
          list << r
        end
      end
    end

    list
  end

  def synonym_verbs
    list = []

    if result[11].size > 1
      if result[1][1]
        result[11][1][1].each do |r, _|
          list << r
        end
      end
    end

    list
  end

  def synonym_exclamations
    list = []

    if result[11].size > 1
      if result[1][2]
        result[11][2][1].each do |r, _|
          list << r
        end
      end
    end

    list
  end

end