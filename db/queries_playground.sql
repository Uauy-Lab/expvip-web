SELECT * FROM wheat_expression_dev.expression_values 
INNER JOIN genes ON gene_id=genes.id WHERE genes.name="Traes_7DS_FFE9ACDAB.2"; 

SELECT genes.id, genes.name FROM genes WHERE genes.id=105175;


SELECT * from type_of_values;


SELECT 
    *
FROM
    studies
        INNER JOIN
    experiments ON studies.id = experiments.study_id;

SELECT 
    gene_id,
    genes.name,
    expression_values.value,
	type_of_values.name,
	experiment_id,
	experiments.accession,
	study_id,
    studies.accession
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
WHERE
    genes.name = 'Traes_7DS_FFE9ACDAB.2'
ORDER by	
	type_of_values.id,
	studies.id,
	experiments.id
; 