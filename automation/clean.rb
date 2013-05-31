# Redefine clean and clobber because rm_r is less reliable on Windows than rm_rf
Rake::Task[:clean].clear
Rake::Task[:clobber].clear
desc "Remove any temporary products."
task :clean do
	CLEAN.each { |fn| rm_rf fn rescue nil }
end
desc "Remove any generated file."
task :clobber => [:clean] do
	CLOBBER.each { |fn| rm_rf fn rescue nil }
end
