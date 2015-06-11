SELECT * FROM wheat_expression_dev.expression_values 
INNER JOIN genes ON gene_id=genes.id WHERE genes.name="Traes_7DS_FFE9ACDAB.2"; 

SELECT genes.id, genes.name FROM genes WHERE genes.id=105175;


SELECT * from type_of_values;


SELECT gene_id, genes.name, expression_values.value, type_of_values.name, experiments.accession
FROM expression_values 
INNER JOIN genes ON gene_id=genes.id 
INNER JOIN type_of_values ON expression_values.type_of_value_id = type_of_values.id
INNEr JOIN experiments ON expression_values.experiment_id = experiment_id
WHERE genes.name="Traes_7DS_FFE9ACDAB.2"; 