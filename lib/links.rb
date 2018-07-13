module SequenceServer
  # Module to contain methods for generating sequence retrieval links.
  module Links
    require 'erb'
    require 'pp'
    # Provide a method to URL encode _query parameters_. See [1].
    include ERB::Util    
    #
    alias_method :encode, :url_encode    


    # Link generators return a Hash like below.
    #
    # {
    #   # Required. Display title.
    #   :title => "title",
    #
    #   # Required. Generated url.
    #   :url => url,
    #
    #   # Optional. Left-right order in which the link should appear.
    #   :order => num,
    #
    #   # Optional. Classes, if any, to apply to the link.
    #   :class => "class1 class2",
    #
    #   # Optional. Class name of a FontAwesome icon to use.
    #   :icon => "fa-icon-class"
    # }
    #
    # If no url could be generated, return nil.
    #
    # Helper methods
    # --------------
    #
    # Following helper methods are available to help with link generation.
    #
    #   encode:
    #     URL encode query params.
    #
    #     Don't use this function to encode the entire URL. Only params.
    #
    #     e.g:
    #         sequence_id = encode sequence_id
    #         url = "http://www.ncbi.nlm.nih.gov/nucleotide/#{sequence_id}"
    #
    #   querydb:
    #     Returns an array of databases that were used for BLASTing.
    #
    #   whichdb:
    #     Returns the database from which the given hit came from.
    #
    #     e.g:
    #
    #         hit_database = whichdb
    #
    # Examples:
    # ---------
    # See methods provided by default for an example implementation.

    def sequence_viewer
          
      gene  = encode self.accession                        
      gene_set = encode whichdb.first.title.sub(/\s+/, '') # Removing any whitespace between the characters
      url = "genes/forward?submit=Search&gene=#{gene}" \
            "&gene_set=#{gene_set}&search_by=gene"        

      {
        :order => 0,
        :url   => url,
        :title => 'Gene expression',
        :class => 'mutation_link',
        :icon  => 'fa-eye'
      }

    end

    def transcript_expression
          
      gene  = encode self.accession                        
      gene_set = encode whichdb.first.title.sub(/\s+/, '') # Removing any whitespace between the characters
      url = "genes/forward?submit=Search&gene=#{gene}" \
            "&gene_set=#{gene_set}&search_by=transcript"        

      {
        :order => 0,
        :url   => url,
        :title => 'Transcript expression',
        :class => 'mutation_link',
        :icon  => 'fa-eye'
      }

    end

    # Returns tuple of tuple indicating start and end coordinates of matched
    # regions of query and hit sequences.



    def fasta_download

      nil

    end

    def ncbi

      nil

    end

    def uniprot

      nil

    end

  end
end

# [1]: https://stackoverflow.com/questions/2824126/whats-the-difference-between-uri-escape-and-cgi-escape
