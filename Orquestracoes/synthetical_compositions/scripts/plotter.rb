#! /usr/bin/ruby

data = ARGV.shift

merger = '\documentclass[11pt,a4paper]{article} % tentar book
\usepackage[section]{placeins}
\usepackage[pdftex]{graphicx}           % usamos arquivos pdf/png como figuras

\begin{document}
\section{Results}
'

files = Dir["#{data}/*.dat"].to_a
files.sort! {|a,b| a[/_a\d/]<=>b[/_a\d/]}
files.sort! {|a,b| a[/\d+_a/].to_i <=> b[/d+_a/].to_i}
files.sort! {|a,b| a[/\d+/] <=> b[/\d+/]}


files.each do |to_plot_origin|
  to_plot = to_plot_origin[/\/.*/].gsub('.', '').gsub('/', '')

  to_plot =~ /(\d+)_(\d+)_a(\d)/
  size = $1
  freq = $2
  machine_id = $3
  machine = "Aguia #{machine_id}" 

  %w(cpu ram net).each do |variable|
    var_plotter =  File.open("resources/Plotter_#{variable}").readlines
    f = File.new("/tmp/plotter", 'w')
    f.puts var_plotter.join("\n").gsub('#{input}', to_plot_origin).gsub('#{id}', machine_id).gsub('#{output}', "/tmp/#{to_plot}_#{variable}")
    f.close
    `gnuplot /tmp/plotter`

    merger << "
    \\begin{figure}
    \\includegraphics[width=\\textwidth]{/tmp/#{to_plot}_#{variable}}
    \\caption{Case: #{size} bytes and #{freq} Hz. #{variable.upcase} usage in #{machine}}
    \\end{figure}
    \\clearpage
    "
  end
end
merger << '
\end{document}
'

f = File.new('/tmp/merger.tex', 'w')
f.puts merger
f.close

`pdflatex /tmp/merger.tex`

`rm merger.aux merger.log`