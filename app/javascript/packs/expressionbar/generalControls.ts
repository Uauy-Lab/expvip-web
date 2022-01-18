import jQuery from 'jquery';
import ExpressionData from "./dataContainer"
import ExpressionBar from "./expressionBar"
import Button from "./button"
import Control from './control';
import Checkbox from './checkbox';
import Select from './select';

class GeneralControls{
	#expression_bar : ExpressionBar;
	#data : ExpressionData;
	#options_div: JQuery;
	#container: JQuery;
	#updating : boolean;
	ortholog_set_select: Select;
	constructor(expression_bar : ExpressionBar , data: ExpressionData ){
		this.#expression_bar = expression_bar;
		this.#data = data;
		this.#container = jQuery('#'+expression_bar.target);
		this.#updating = false;
	}

	addButtons(){
		this.#options_div = jQuery( "<div/>" );
		this.#options_div.attr("id", `${this.#expression_bar.target}_options`);
		let pre_button = `<label for="${this.#expression_bar.target}_property" style="cursor: pointer;">Expression unit: </label><select style="cursor: pointer;" id="${this.#expression_bar.target}_property"></Select>`
		this.#options_div.append(pre_button);
		new Checkbox(this.#expression_bar, "calculateLog", "Log<sub>2</sub>", this.#options_div);
		new Button(this.#expression_bar, "saveRenderedSVG", "Save as SVG", this.#options_div);
		new Button(this.#expression_bar, "saveRenderedPNG", "Save as PNG", this.#options_div);
		new Button(this.#expression_bar, "saveRenderedData", "Save data", this.#options_div);
		new Button(this.#expression_bar, "saveRawData", "Save raw data", this.#options_div);
		new Button(this.#expression_bar, "restoreDefaults", "Restore defaults", this.#options_div);
		new Checkbox(this.#expression_bar, "showHomoeologues",  "Homoeologues", this.#options_div);
		new Checkbox(this.#expression_bar, "showTernaryPlot", "Ternary plot", this.#options_div);
		new Checkbox(this.#expression_bar, "orthologues", "Pangenome orthologues", this.#options_div);
		this.ortholog_set_select = new Select(this.#expression_bar, "ortho-set", "Orthologue set", this.#options_div);
		let chartScale = this.#expression_bar.target + '_scale';
		let post_button = `<div id="${chartScale}"></div>`
		this.#options_div.append(post_button);
		this.#container.append(this.#options_div);
	}

	updateControls(){
		if(this.#updating){
			return;
		}
		this.#updating = true;
		let eb = this.#expression_bar;
		eb.opt.plot = "Bar";
		if(eb.opt.showHomoeologues){
			jQuery(`#${eb.target}_showTernaryPlot`).prop('checked', false);
			jQuery(`#${eb.target}_showHomoeologues`).prop('checked', true);
		}
		if(eb.opt.showTernaryPlot){
			jQuery( '#' + eb.target + '_showHomoeologues' ).prop('checked', false);
			jQuery( '#' + eb.target + '_showTernaryPlot' ).prop('checked', true);
			eb.opt.showHomoeologues = true;   // For the homoeologues data to be calculated        
			eb.opt.plot = "Ternary"; 
		}
		eb.refresh();
		eb.refreshSVG();
		this.#updating = false;
	}

	toggleHomologueButtons(){
		if(!this.#data.hasHomologues){
			jQuery(`#${this.#expression_bar.target}_showHomoeologuesSpan`).hide('fast');
			jQuery(`#${this.#expression_bar.target}_showTernaryPlotSpan`).html("");
			this.#expression_bar.opt.storeValue('showTernaryPlot',false);
			this.#expression_bar.opt.storeValue('showHomoeologues',false);
		}else {  // If there is homoeologues
			jQuery(`#${this.#expression_bar.target}_showHomoeologuesSpan`).css('display', 'initial');
			jQuery(`#${this.#expression_bar.target}_showTernaryPlotSpan`).css('display', 'initial');
		}
	}

	toggleTernButtons(){
		if(this.#data.hasTern ){
			jQuery(`#${this.#expression_bar.target}_showTernaryPlotSpan`).css('display', 'initial');
		}else {
			jQuery(`#${this.#expression_bar.target}_showTernaryPlotSpan`).html("No homologies for ternary plot").css('display', 'initial').css('color', 'red');
			this.#expression_bar.opt.storeValue('showTernaryPlot',false);
		}
	}

	set data(data: ExpressionData){
		this.#data = data;
		let ogs = data.ortholog_groups.values();
		console.log(ogs);
		this.ortholog_set_select.options =[...ogs];
	}

}
export default GeneralControls;