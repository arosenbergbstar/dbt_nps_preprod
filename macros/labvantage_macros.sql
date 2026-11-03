{% macro map_workflow_type(column_name) %}
    case
        when {{ column_name }} like '%;%'
        then 'multitest'
        when
            lower({{ column_name }}) is null
            or lower({{ column_name }}) in ('ldt', 'ldt_panc')
        then 'pancreatic'
        when lower({{ column_name }}) = 'ldt_ovarian'
        then 'ovarian'
        when lower({{ column_name }}) in ('ldt_mcd', 'ivd_mcd')
        then 'multicancer'
        when lower({{ column_name }}) in ('ldt_pancv2', 'ivd_pancv2')
        then 'pancv2'
        when lower({{ column_name }}) = 'bioclin'
        then 'bioclin'
        -- covers specparamlimits values
        when lower({{ column_name }}) ilike '%_mcd_%'
        then 'multicancer'
        when lower({{ column_name }}) ilike '%bioclin%'
        then 'bioclin'
        else lower({{ column_name }})
    end
{% endmacro %}

{% macro eval_inequality(operator, metric_value, threshold_value) %}
    case
        when {{ operator }} = '>'
        then {{ metric_value }} > {{ threshold_value }}
        when {{ operator }} = '<'
        then {{ metric_value }} < {{ threshold_value }}
        when {{ operator }} = '='
        then {{ metric_value }} = {{ threshold_value }}
        when {{ operator }} = '>='
        then {{ metric_value }} >= {{ threshold_value }}
        when {{ operator }} = '<='
        then {{ metric_value }} <= {{ threshold_value }}
        else false
    end
{% endmacro %}

{% macro map_array_type(array_id, array_desc, array_layout_id, flowcell_process_type) %}
    case
        when array_id = 'Sample' and array_desc = 'DNA Extraction'
        then 'cfDNA Extraction'
        when array_desc = 'DNA Extraction' and array_layout_id = 'Extraction'
        then 'cfDNA Extraction Instrument'
        when array_desc = 'DNA Extraction'
        then 'cfDNA Extraction'
        when
            array_desc = '96wellPlateControl' and array_layout_id = '96wellPlateControl'
        then 'cfDNA Stock'
        when array_desc = 'QuantTransfer' and array_layout_id = 'dsDNA Quantitation'
        then 'cfDNA Spectramax'
        when
            array_desc = 'WGS Library Quantitation' and array_layout_id = 'Quantitation'
        then 'WGS Spectramax'
        when
            array_desc = '5hmC Library Quantitation'
            and array_layout_id = 'Quantitation'
        then '5hmC Spectramax'
        when
            array_desc = 'Normalization'
            and array_layout_id = 'DNANormalization'
            and array_id ilike 'Pla%'
        then 'cfDNA Norm Plate'
        when array_desc = 'Normalization' and array_layout_id = 'DNANormalization'
        then 'cfDNA Norm'
        when
            array_desc = 'WGS Library Normalization'
            and array_layout_id = 'Normalization'
            and array_id ilike 'Pla%'
        then 'WGS Norm Plate'
        when
            array_desc = 'WGS Library Normalization'
            and array_layout_id = 'Normalization'
        then 'WGS Norm'
        when
            array_desc = '5hmC Library Normalization'
            and array_layout_id = 'Normalization'
            and array_id ilike 'Pla%'
        then '5hmC Norm Plate'
        when
            array_desc = '5hmC Library Normalization'
            and array_layout_id = 'Normalization'
        then '5hmC Norm'
        when array_desc = 'Library Prep' and array_layout_id = 'LibraryPrep'
        then 'Library Prep'
        when array_desc = 'Library Prep Layout' and array_layout_id = 'LibraryPrep'
        then 'WGS Library'
        when
            array_desc = '5hmC Library Prep Module 2'
            and array_layout_id = 'LibraryPrep'
        then '5hmC Library'
        when
            array_desc = '5hmC Library Prep 2'
            and array_layout_id = '5hmC Library Prep 2'
        then '5hmC Label'
        when
            array_desc = '5hmC Bead Purification'
            and array_layout_id = 'Bead Purification'
        then '5hmC Stock'
        when array_desc = '5hmC Pool' and array_layout_id = 'Pooling 96 Well'
        then '5hmC Pool'
        when
            array_desc = 'WGS Bead Purification'
            and array_layout_id = 'Bead Purification'
        then 'WGS Stock'
        when array_desc = 'WGS Pool' and array_layout_id = 'Pooling 96 Well'
        then 'WGS Pool'
        when
            array_desc in ('Flow Cell', 'Flow Cell Failed', 'Failed Flow Cell')
            and flowcell_process_type = 'hmc'
        then '5hmC Sequencing'
        when
            array_desc in ('Flow Cell', 'Flow Cell Failed', 'Failed Flow Cell')
            and flowcell_process_type = 'wgs'
        then 'WGS Sequencing'
        when array_layout_id = 'I7 Index Master'
        then 'I7 Index Master'
        when array_layout_id = 'I5 Index Master'
        then 'I5 Index Master'
        else 'Unknown'
    end
{% endmacro %}
