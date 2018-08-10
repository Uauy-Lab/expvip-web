| Study Identified        | Summary of study   | Brief SRA description   | Manuscript title   | 
|-------------------------|--------------------|-------------------------|--------------------| 
<% Study.all.each do |s| 
    next unless s.active
    url   = ""
    url_s = ""
    if /\//.match? s.doi
        url   = "](https://doi.org/#{s.doi})" 
        url_s = "["
    end

%>
| <%= s.title.gsub("_"," ") %>          | <%= s.summary  %>  |<%= s.sra_description %> | <%= url_s %> <%= s.manuscript %> <%= url %> | 
<% end %>
