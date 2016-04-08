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


//= require bundle
//= require jquery
//= require jquery-ui


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

});

$(document).ready(ready);
$(document).on('page:load', ready);
