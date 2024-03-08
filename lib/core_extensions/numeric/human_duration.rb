module CoreExtensions
  module Numeric
    module HumanDuration
      def to_human_duration
        mm, ss = self.divmod(60)
        hh, mm = mm.divmod(60)
        dd, hh = hh.divmod(24)
        str = ""
        str << "#{dd} days, " if dd > 0
        str << "#{hh} hours, " if hh > 0
        str << "#{mm} minutes, " if mm > 0
        str << "#{ss} seconds, " if ss > 0
        str = str[0..-3]
        str.reverse.sub(" ,", " and ".reverse).reverse
      end
    end
  end
end

Numeric.include CoreExtensions::Numeric::HumanDuration
