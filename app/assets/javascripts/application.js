// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//



//= require jquery
//= require jquery-ui
//= require bundle

Math.log2 = Math.log2 || function(x) {
  return Math.log(x) / Math.LN2;
};


var ready;
ready = (function() {
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');
  $("#gene-search-input").autocomplete({
    source: '/genes/autocomplete.json',
  });
   $("#gene-search-compare").autocomplete({
    source: '/genes/autocomplete.json',
  });

  $("#gene").autocomplete({
    source: '/genes/autocomplete.json',
  });
  $("#compare").autocomplete({
    source: '/genes/autocomplete.json',
  });

  $("#gene_set_selector").on("change", function(event){
    $.ajax({
    type: 'get',
    url: '/gene_sets/set_gene_set_session.json',

    data: {
        gene_set_selector:$("#gene_set_selector").val()
    },
    success: function (response) {
        document.getElementById("kalb"+parseInt(subcategory_id.match(/[0-9]+/)[0], 10)).innerHTML=response;
    }
});
  });

  $(".alert-error").on("click", function(event) { 
    $(this).hide();
  });
  $(".alert-info").on("click", function(event) { 
    $(this).hide();
  });
  $( "#about_studies" ).dialog({
      autoOpen: false,
      minWidth: 1000,
      maxHeight: 500,
      resizable: false,
      position: { at: "center top" },
      show: {
        effect: "fade",
        duration: 500
      },
      hide: {
        effect: "fade",
        duration: 500
      }
    });

  $( "#about" ).dialog({
      autoOpen: false,
      minWidth: 1000,
      maxHeight: 500,
      resizable: false,
      position: { at: "center top" },
      show: {
        effect: "fade",
        duration: 500
      },
      hide: {
        effect: "fade",
        duration: 500
      }
    });

  $( "#studies_button" ).click(function() {
      $( "#about_studies" ).dialog( "open" );
  });

   $( "#cite_button" ).click(function() {
      $( "#about" ).dialog( "open" );
  });
  
  //*************************************SEQUENCESERVER - START*************************************
  var search_right = $('#search_right');
  var search_left = $('#search_left');
  var introblurb = $('#introblurb');
   $('#sequenceserver').load(function(){
    var parent = $(this).contents();
    var node = $(this).contents().find('body').find('.navbar');
    var self = $(this);
    node.html('<h4>BLAST Scaffold</h4>');
    $(this).contents().find('#footer').html('');          
    // Changing the checkbox input under the textarea to a radio button  
    $(this).contents().find('#blast').find('input').eq(0).attr('type', 'radio');;

    // Removing the form after the BLAST button has been clicked
    search_btn = $(this).contents().find('#method');    
    search_btn.click(function(){
      search_right.width('100%')
      self.width('950px');
      search_left.hide();
      introblurb.hide();             

      // Adding a new column to the results table (with a time delay to let the content to be generated first and then changed)  
      $(document).ready(function($) {
        setTimeout(function(){

          // Adding the header of the column
          $('#sequenceserver').contents().find('thead').eq(0).find('th').eq(1).after('<th class="text-left"> Gene search </th>')

          // Adding the data of the column
          // ***Constructing the link(adding the gene set)
          var geneSet = '';
          var testPath = $('#sequenceserver').contents().find('#blast').find('.databases-container').find('input').each(function(index, el) {
            if($(this).prop("checked", true)){
              geneSet = $(this).parent().text();
              geneSet = $.trim(geneSet);
            }else{
              // ***If no gene set has been selected
              alert("Weird Stuff!\nPlease select a gene set");
            }
          });;
                    
          $('#sequenceserver').contents().find('tbody').eq(0).find('tr').each(function(index, el) {                         
            // ***Constructing the link(adding the gene name)
            var geneName = $(this).find('td').eq(1).children().text();   
            var link = "genes/forward?submit=Search&gene=" + geneName + "&gene_set=" + geneSet;

            var secondColResTable = $(this).find('td').eq(1);
            // var link = "genes/forward?submit=Search&gene=" + geneName + "&gene_set=IWGSC2.26";   //**************for testing purposes
            secondColResTable.after("<td> <a href=" + link + " target=\"_blank\">Search this gene</a> </td>");            
          });          
        }, 500);        
      });

    });
  });
//*************************************SEQUENCESERVER - END*************************************


});

$(document).ready(ready);
$(document).on('page:load', ready);
