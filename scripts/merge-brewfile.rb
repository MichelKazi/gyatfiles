# Preserve declarative intent verbatim; append only newly discovered entries.
# Brewfiles here use one declaration per line. Do not evaluate arbitrary Ruby.
existing = File.exist?(ARGV[0]) ? File.read(ARGV[0]) : ""
pattern = /^\s*(tap|brew|cask|mas|vscode|go|cargo|npm|uv|flatpak|winget|krew)\s+["']([^"']+)["']/
key = lambda do |line|
  match = pattern.match(line)
  match && [match[1], match[2].sub(%r{\Ahomebrew/(core|cask)/}, "")]
end
seen = {}
existing.each_line { |line| identity = key.call(line); seen[identity] = true if identity }
added = []
File.foreach(ARGV[1]) do |line|
  identity = key.call(line)
  next unless identity && !seen[identity]
  seen[identity] = true
  added << line
end
print existing
unless added.empty?
  print "\n" unless existing.empty? || existing.end_with?("\n")
  print "\n# Captured from locally installed packages.\n"
  added.each { |line| print line }
end
