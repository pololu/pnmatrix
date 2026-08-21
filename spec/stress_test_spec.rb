require 'spec_helper'

describe NMatrix do
  def force_gc
    20.times do
      Array.new(1_000) { |i| "gc-pressure-#{i}" }
      GC.start
    end
  end

  def build_dense_object_reference
    values = Array.new(64 * 64) { |i| "dense-object-#{i}" }
    matrix = NMatrix.new([64, 64], values, stype: :dense, dtype: :object)

    matrix[50...64, 45...64]
  end

  def build_yale_object_reference
    rng = Random.new(5678)
    matrix = NMatrix.new([35, 35], nil, stype: :yale, dtype: :object, capacity: 1)

    700.times do |i|
      matrix[rng.rand(35), rng.rand(35)] = "yale-object-#{i}"
    end

    matrix[3...30, 4...32]
  end

  def build_nested_yale_object_reference
    rng = Random.new(6789)
    matrix = NMatrix.new([45, 45], nil, stype: :yale, dtype: :object, capacity: 1)

    1_000.times do |i|
      matrix[rng.rand(45), rng.rand(45)] = "nested-yale-object-#{i}"
    end

    matrix[5...40, 6...39][7...28, 8...30]
  end

  def build_list_object_reference
    matrix = NMatrix.new([30, 30], nil, stype: :list, dtype: :object)

    30.times do |i|
      matrix[i, (i * 7) % 30] = "list-object-#{i}"
    end

    matrix[4...28, 2...29]
  end

  def mutate_dense_object_matrix_without_external_references
    rng = Random.new(555)
    matrix = NMatrix.new([80, 80], nil, stype: :dense, dtype: :object)

    5_000.times do |i|
      matrix[rng.rand(80), rng.rand(80)] = "mut-dense-#{i}"
      GC.start if (i % 25).zero?
    end

    matrix
  end

  def mutate_yale_object_matrix_without_external_references
    rng = Random.new(333)
    matrix = NMatrix.new([80, 80], nil, stype: :yale, dtype: :object, capacity: 1)

    5_000.times do |i|
      matrix[rng.rand(80), rng.rand(80)] = "mut-yale-#{i}"
      GC.start if (i % 25).zero?
    end

    matrix
  end

  def mutate_list_object_matrix_without_external_references
    rng = Random.new(888)
    matrix = NMatrix.new([30, 30], nil, stype: :list, dtype: :object)

    500.times do |i|
      matrix[rng.rand(30), rng.rand(30)] = "mut-list-#{i}"
      GC.start if (i % 10).zero?
    end

    matrix
  end

  def touch_reference(reference)
    reference.each_stored_with_indices do |value, _i, _j|
      value.to_s.hash
    end
  end

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

  specify "does not segfault when iterating a GC-stressed object Yale reference" do
    reference = build_yale_object_reference

    force_gc

    touch_reference(reference)
  end

  specify "does not segfault when iterating a GC-stressed nested object Yale reference" do
    reference = build_nested_yale_object_reference

    force_gc

    touch_reference(reference)
  end

  specify "does not segfault when iterating a GC-stressed object dense reference" do
    reference = build_dense_object_reference

    force_gc

    reference.each_with_indices do |value, _i, _j|
      value.to_s.hash
    end
  end

  specify "does not segfault when iterating a GC-stressed object list reference" do
    reference = build_list_object_reference

    force_gc

    touch_reference(reference)
  end

  specify "does not segfault after GC-stressed object dense mutation" do
    matrix = mutate_dense_object_matrix_without_external_references

    force_gc

    matrix.each do |value|
      value.to_s.hash
    end
  end

  specify "does not segfault after GC-stressed object Yale mutation" do
    matrix = mutate_yale_object_matrix_without_external_references

    force_gc

    touch_reference(matrix)
  end

  specify "does not segfault after GC-stressed object list mutation" do
    matrix = mutate_list_object_matrix_without_external_references

    force_gc

    touch_reference(matrix)
  end
end
