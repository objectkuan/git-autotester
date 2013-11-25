15a16
>     lazy_reader :mergetag_object
143d143
< 
154a155,157
>         # Modified by objectkuan
>         # Email: objectkuan@gmail.com
>         # Added: && lines[0] !~ /^mergetag object /
156c159
<         committer_line << lines.shift if lines[0] && lines[0] != '' && lines[0] !~ /^encoding/
---
>         committer_line << lines.shift if lines[0] && lines[0] != '' && lines[0] !~ /^encoding/ && lines[0] !~ /^mergetag object /
160a164,174
> 
>         # Modified by objectkuan
>         # Email: objectkuan@gmail.com
>         # Added: mertags
>         mergetag_object = nil
>         while (mergetag_object = lines.shift if lines[0] =~ /^mergetag object /)
>           break if mergetag_object.empty?
>           mergetag_object_lines = []
>           mergetag_object_lines << lines.shift[1..-1] while lines.first =~ /^ {1}/
>         end
> 
