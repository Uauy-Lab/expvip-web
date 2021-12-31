import jQuery from 'jquery';
import ExpressionData from "./dataContainer"
import ExpressionBar from "./expressionBar"
import Button from "./button"
import Control from './control';
import Checkbox from './checkbox';

class GeneralControls{
	#expression_bar : ExpressionBar;
	#data : ExpressionData;
	#options_div: JQuery;
	#container: JQuery;
	constructor(expression_bar : ExpressionBar , data: ExpressionData ){
		this.#expression_bar = expression_bar;
		this.#data = data;
		this.#container = jQuery('#'+expression_bar.target);
	}

	addButtons(){
		this.#options_div = jQuery( "<div/>" );
		this.#options_div.attr("id", `${this.#expression_bar.target}_options`);
		let pre_button = `<label for="${this.#expression_bar.target}_property" style="cursor: pointer;">Expression unit: </label><select style="cursor: pointer;" id="${this.#expression_bar.target}_property"></Select>`
		this.#options_div.append(pre_button);
		let eb = this.#expression_bar;
		new Checkbox(this.#expression_bar, "log2", "Log<sub>2</sub>", this.#options_div)
			.el.on('change', function(evt) {
				let checked = jQuery(this).is(":checked");
				eb.opt.calculateLog = checked;
				eb.refresh();
				eb.storeValue('calculateLog',checked);
			});

		new Button(this.#expression_bar, "save", "Save as SVG", this.#options_div)
			.el.on('click', evt => this.#expression_bar.saveRenderedSVG());
		new Button(this.#expression_bar, "save_png", "Save as PNG", this.#options_div)
			.el.on('click', evt => this.#expression_bar.saveRenderedPNG());
		new Button(this.#expression_bar, "save_data", "Save data", this.#options_div)
			.el.on('click', evt => this.#expression_bar.saveRenderedData());
		new Button(this.#expression_bar, "save_raw_data", "Save raw data", this.#options_div)
			.el.on('click', evt => this.#expression_bar.saveRawData());
		new Button(this.#expression_bar, "restore_defaults", "Restore defaults", this.#options_div)
			.el.on('click', evt => this.#expression_bar.restoreDefaults());
		
		// <span id="${this.#expression_bar.target}_showHomoeologuesSpan"><input style="cursor: pointer;" id="${this.#expression_bar.target}_showHomoeologues" type="checkbox"name="showHomoeologues" value="show"><label style="cursor: pointer;" for="${this.#expression_bar.target}_showHomoeologues">Homoeologues</label></input> </span>
		new Checkbox(this.#expression_bar, "showHomoeologues",  "Homoeologues", this.#options_div)
			.el.on('change', function(evt){
				let checked = jQuery(this).is(":checked");
				jQuery(`#${eb.target}_showTernaryPlot`).prop('checked', false);
				eb.storeValue('showTernaryPlot',false);
				eb.storeValue('showHomoeologues', checked);
				eb.opt.showHomoeologues = checked;
				eb.opt.showTernaryPlot = false;      
				eb.opt.plot = "Bar";
				eb.refresh();
   				eb.refreshSVG();
			});

		new Checkbox(this.#expression_bar, "showTernaryPlot", "Ternary plot", this.#options_div)
			.el.on('change', function(evt){
				let checked = jQuery(this).is(":checked");
				jQuery( '#' + eb.target + '_showHomoeologues' ).prop('checked', false);
				eb.storeValue('showHomoeologues',false);
				eb.storeValue('showTernaryPlot', checked);
				eb.opt.showTernaryPlot = checked;
				eb.opt.showHomoeologues = true;   // For the homoeologues data to be calculated        
				eb.opt.plot = "Ternary"; 
				if(!checked){        
				  eb.opt.showHomoeologues = false;      
				  eb.opt.plot = "Bar";        
				}
				eb.refresh();      
				eb.refreshSVG();
			})

		let chartScale = this.#expression_bar.target + '_scale';
		let post_button = ` 
		<div id="${chartScale}"></div>`
		this.#options_div.append(post_button);
		this.#container.append(this.#options_div);

	}

	toggleHomologueButtons(){
		if(!this.#data.hasHomologues){
			jQuery(`#${this.#expression_bar.target}_showHomoeologuesSpan`).hide('fast');
			jQuery(`#${this.#expression_bar.target}_showTernaryPlotSpan`).html("");
			this.#expression_bar.storeValue('showTernaryPlot',false);
			this.#expression_bar.storeValue('showHomoeologues',false);
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
			this.#expression_bar.storeValue('showTernaryPlot',false);
		}
	}

	set data(data: ExpressionData){
		this.#data = data;
	}



}
export default GeneralControls;