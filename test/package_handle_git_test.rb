require 'helper'

class HandlePackageGitTest < Rip::Test
  test "can't handle unknown protocol" do
    out = rip "package-handle-git rack"
    assert_exited_with_error out
  end

  test "fetch git:// package" do
    out = rip "package-handle-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-98b937fa387d6b25fe3e114670d5ffc0"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")

    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/cijoe 04419882877337e70ac572a36d25416b0da9ba0f", File.read("#{target}/metadata.rip").chomp
  end

  test "fetch git:// package with ref" do
    out = rip "package-handle-git git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-5e096d4e73f7b9281514ccfb6667ec94"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")

    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f", File.read("#{target}/metadata.rip").chomp
  end

  test "fetch git:// package with floating ref" do
    out = rip "package-handle-git git://localhost/rack master"
    target = "#{@ripdir}/.packages/rack-c3d5bb01b7e8e3cf08139d8c997239ae"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/rack 01532da684cbb004661987c40d8ba8c952a773e3", File.read("#{target}/metadata.rip").chomp

    out = rip "package-handle-git git://localhost/rack rack-1.1"
    target = "#{@ripdir}/.packages/rack-d09f0f92cbc9fd9445818a3f3677854e"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/rack 1.1", File.read("#{target}/metadata.rip").chomp

    out = rip "package-handle-git git://localhost/rack rack-0.4"
    target = "#{@ripdir}/.packages/rack-30a09c76441ee7f3cc320aae57e9c99e"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/rack/methodoverride.rb")
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/rack 92f79ea8def92c3c2373b9ab5f5fa8e03aa7669d", File.read("#{target}/metadata.rip").chomp
  end

  test "fetch git:// with tag name" do
    out = rip "package-handle-git git://localhost/rack 0.9.1"
    target = "#{@ripdir}/.packages/rack-b81297be848f0dfd34bc5200acace641"
    assert_equal target, out.chomp

    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/rack 0.9.1", File.read("#{target}/metadata.rip").chomp
    assert_equal "git://localhost/rack 0.9.1", rip("package-metadata #{out}").chomp

    rip "install git://localhost/rack 0.9.1"
    assert_equal <<list, rip("list")
ripenv: base

rack (0.9.1)
list
  end

  test "fetch git:// with tag ref" do
    out = rip "package-handle-git git://localhost/rack 04ca38270fbee678eb0705510c9dd91a3b6b1dbf"
    target = "#{@ripdir}/.packages/rack-b81297be848f0dfd34bc5200acace641"
    assert_equal target, out.chomp

    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/rack 0.9.1", File.read("#{target}/metadata.rip").chomp
  end

  test "fetch git:// with tagged commmit ref" do
    out = rip "package-handle-git git://localhost/rack 488d67988ddfb7e13ad2f58272ee04809612cafe"
    target = "#{@ripdir}/.packages/rack-b81297be848f0dfd34bc5200acace641"
    assert_equal target, out.chomp

    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/rack 0.9.1", File.read("#{target}/metadata.rip").chomp
  end

  test "fetch git:// with partial tagged commmit ref" do
    out = rip "package-handle-git git://localhost/rack 488d679"
    target = "#{@ripdir}/.packages/rack-b81297be848f0dfd34bc5200acace641"
    assert_equal target, out.chomp

    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/rack 0.9.1", File.read("#{target}/metadata.rip").chomp
  end

  test "fetch git:// package with nonexistent ref" do
    out = rip "package-handle-git git://localhost/rails xyz"
    assert_equal "git://localhost/rails xyz could not be found", out.chomp
  end

  test "fetch git:// package clears remotes" do
    out = rip "package-handle-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-98b937fa387d6b25fe3e114670d5ffc0"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '', `git remote`.chomp }
  end

  test "fetch git:// package clears branches" do
    out = rip "package-handle-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-98b937fa387d6b25fe3e114670d5ffc0"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '* (no branch)', `git branch`.chomp }
  end

  test "fetch package twice" do
    out = rip "package-handle-git git://localhost/cijoe"
    assert_exited_successfully out

    out = rip "package-handle-git git://localhost/cijoe"
    assert_exited_successfully out
  end

  test "writes package.rip" do
    out = rip "package-handle-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-98b937fa387d6b25fe3e114670d5ffc0"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/cijoe 04419882877337e70ac572a36d25416b0da9ba0f\n",
      File.read("#{target}/metadata.rip")
  end

  test "reload" do
    out = rip "package-handle-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-98b937fa387d6b25fe3e114670d5ffc0"

    assert_equal target, out.chomp
    assert File.directory?(target)

    out = rip "package-reload #{target}"

    assert_equal target, out.chomp
    assert File.directory?(target)
  end
end
