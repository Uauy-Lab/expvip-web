class ExpressionValue < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :gene
  belongs_to :meta_experiment
  belongs_to :type_of_value

  def self.find_expression_for_gene(gene_id)
  	sql=%{SELECT 
    gene_id,
    genes.name as gene_name,
    expression_values.value,
	type_of_values.name as value_name,
	expression_values.experiment_id as exp,
	experiments.accession as experiment_accession,
	studies.id as study,
    studies.accession study_accession,
	experiment_group_id, 
	experiment_groups.description as group_description
FROM
    genes
        INNER JOIN
    expression_values ON gene_id = genes.id
        INNER JOIN
    type_of_values ON expression_values.type_of_value_id = type_of_values.id
        INNER JOIN
    experiments ON expression_values.experiment_id = experiments.id
        INNER JOIN
    studies ON studies.id = experiments.study_id
		INNER JOIN 
	experiment_groups_experiments ON experiment_groups_experiments.experiment_id = experiments.id
		INNER JOIN
	experiment_groups ON experiment_groups_experiments.experiment_group_id = experiment_groups.id
WHERE
    genes.id = '#{gene_id}'
ORDER by	
	type_of_values.id,
	studies.id,
	experiments.id
; }
	rows = ExpressionValue.find_by_sql sql
	ret = Hash.new 
	ret[:values] = Hash.new
	ret[:groups] = Hash.new
	ret[:studies] = Hash.new
	rows.each do |e|  
		ret[:gene] = e.gene_name unless ret[:gene]
		ret[:values][e.value_name] = Array.new unless ret[:values][e.value_name] 
		current = Hash.new
		current[:study] = e.study
		current[:name] = e.experiment_accession
		current[:group] = e.experiment_group_id
		current[:value] = e.value
		ret[:values][e.value_name]  << current
		unless ret[:studies][e.study]
			study = Hash.new
			study[:description] = e.study_accession
			ret[:studies][e.study] = study
		end
		unless ret[:groups][e.experiment_group_id]
			group = Hash.new
			group[:description] = e.group_description
			ret[:groups][e.experiment_group_id] = group
		end
	end
	ret
  end
end
