| Study Identified        | Summary of study   | Brief SRA description   | Manuscript title   | 
|-------------------------|--------------------|-------------------------|--------------------| 
<% Study.all.each do |s| 
    next unless s.active
%>
| <%= s.title %>          | <%= s.summary  %>  |<%= s.sra_description %> |<%= s.manuscript %> | 
<% end %>
