module MetaExperimentsHelper

	def self.countLoadedValues(meta_experiment:, accession:) 
		meta_exp = MetaExperiment.find_by(:name=>meta_experiment)
		return 0 unless meta_exp
		experiment = Experiment.find_by(:accession=>accession)
		return 0 unless experiment
		exp_vals = ExpressionValue.where(meta_experiment:meta_exp).count()
		return exp_vals
	end


end
