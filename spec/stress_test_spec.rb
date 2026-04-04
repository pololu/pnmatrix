require 'spec_helper'

describe NMatrix do
  specify do
    200.times do |i|
      size = rand(500..1000)
      m1 = NMatrix.new([size, size], 0, stype: :yale, dtype: :int32)
      m2 = m1.clone

      rand(1000).times do |j|
        m1[rand(size), rand(size)] = 1
        m2[rand(size), rand(size)] = 1
      end

      (m1*m2).det
    end
  end
end
