class Range
  def intersection(other)
    raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)

    my_min, my_max = first, exclude_end? ? max : last
    other_min, other_max = other.first, other.exclude_end? ? other.max : other.last

    new_min = self === other_min ? other_min : other === my_min ? my_min : nil
    new_max = self === other_max ? other_max : other === my_max ? my_max : nil

    new_min && new_max ? new_min..new_max : nil
  end

  alias_method :&, :intersection
end