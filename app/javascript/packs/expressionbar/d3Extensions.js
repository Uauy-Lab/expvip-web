var d3 = require('d3');
require('d3-ease');
//This is a patch!
d3.selection.prototype.position = function() {
  function getVpPos(el) {
    if(el.parentElement.tagName === 'svg') {
      var ret = el.parentElement.getBoundingClientRect();
      ret.top = 0;
      ret.left = 0;
      return ret;
    }
    return getVpPos(el.parentElement);
  };
  var el = this.node();
  var elPos = el.getBoundingClientRect();
  var vpPos = getVpPos(el);
  return {
    top: elPos.top - vpPos.top,
    left: elPos.left - vpPos.left,
    width: elPos.width,
    bottom: elPos.bottom - vpPos.top,
    height: elPos.height,
    right: elPos.right - vpPos.left
  };
}

function numberWithCommas(x) {
  var num = x.toFixed(2);
  var parts = num.toString().split('.');
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  return parts.join('.');
}

module.exports.numberWithCommas = numberWithCommas;