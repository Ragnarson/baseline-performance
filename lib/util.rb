def run(command, dir=".")
  puts "... Running #{command}..."
  `cd #{dir}; #{command}`.tap {|output| puts output }
end

def first_match(string, regexp)
  string.match(regexp) {|m| m[1]}
end
