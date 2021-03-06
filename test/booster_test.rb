require_relative "test_helper"

class BoosterTest < Minitest::Test
  def test_dump_text
    assert_match(/0:\[f2</, booster.dump.join)
    assert_match(/0:\[feat2</, booster_with_feature_names.dump.join)
  end

  def test_dump_json
    booster_dump = booster.dump(dump_format: "json").first
    assert JSON.parse(booster_dump)
    assert_equal 2, JSON.parse(booster_dump).fetch("split")

    feature_booster_dump = booster_with_feature_names.dump(dump_format: "json").first
    assert JSON.parse(feature_booster_dump)
    assert_equal "feat2", JSON.parse(feature_booster_dump).fetch("split")
  end

  def test_dump_model_text
    booster.dump_model(tempfile)
    assert File.exist?(tempfile)
  end

  def test_dump_model_json
    booster.dump_model(tempfile, dump_format: "json")
    assert File.exist?(tempfile)
    assert JSON.parse(File.read(tempfile))
  end

  def test_score
    expected = {"f2" => 99, "f1" => 104, "f0" => 99, "f3" => 40}
    assert_equal expected.values.sort, booster.score.values.sort
  end

  def test_fscore
    assert_equal booster.score, booster.fscore
  end

  def test_attributes
    assert_nil booster["foo"]
    assert_equal({}, booster.attributes)

    booster["foo"] = "bar"

    assert_equal "bar", booster["foo"]
    assert_equal({ "foo" => "bar" }, booster.attributes)

    booster["foo"] = "baz"

    assert_equal "baz", booster["foo"]
    assert_equal({ "foo" => "baz" }, booster.attributes)

    booster["bar"] = "qux"

    assert_equal({ "foo" => "baz", "bar" => "qux" }, booster.attributes)

    booster["foo"] = nil

    refute_includes(booster.attributes, "foo")
  end

  private

  def load_booster
    XGBoost::Booster.new(model_file: "test/support/model.bin")
  end

  def booster
    @booster ||= load_booster
  end

  def booster_with_feature_names
    @booster_with_feature_names ||= load_booster.tap do |booster|
      booster.feature_names = (0...3).map { |idx| "feat#{idx}" }
    end
  end
end
