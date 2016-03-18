module Gnrd
  # Prepares results from name finding for output
  class NamesCollection
    attr_reader :names_raw, :combined

    def initialize(names_raw)
      @names_raw = names_raw
      @combined = []
    end

    def combine
      @names_raw.keys.each_with_object(@combined) do |k, cmb|
        @names_raw[k].each do |n|
          cmb << n.merge(engine: k, size: (n[:offsetEnd] - n[:offsetStart]))
        end
      end
      dedupe if @names_raw.size > 1
      self
    end

    private

    def dedupe
      deduped = []
      @combined.sort_by! { |n| [n[:offsetStart], -n[:engine][0].ord] }
      deduped << preferred_next_name until @combined.empty?
      @combined = deduped
    end

    def preferred_next_name
      name1 = @combined.shift
      name2 = @combined[0]
      case pick_one(name1, name2)
      when :no_overlap then name1
      when :left_better then
        @combined.shift
        name1
      when :right_better then @combined.shift
      end
    end

    def pick_one(l, r)
      if no_overlap?(l, r) || left_is_superset?(l, r)
        :left_better
      else
        :right_better
      end
    end

    def no_overlap?(l, r)
      r.nil? || l[:offsetEnd] < r[:offsetStart]
    end

    def left_is_superset?(l, r)
      l[:offsetStart] <= r[:offsetStart] &&
        l[:offsetEnd] >= r[:offsetEnd]
    end
  end
end
