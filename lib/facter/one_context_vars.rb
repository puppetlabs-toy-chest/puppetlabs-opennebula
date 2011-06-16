if FileTest.exists?(Facter.value(:one_context_path)) then
File.open(Facter.value(:one_context_path)).each { |line|
  next if line =~ /^#/

  (key, var) = line.split("=")
  Facter.add("one_context_var_"+key.downcase) do
    setcode do
      var
    end
  end
}
end
